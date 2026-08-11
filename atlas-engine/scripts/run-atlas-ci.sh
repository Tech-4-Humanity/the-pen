#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_B64="${ATLAS_SOURCE_B64:-$ROOT/../workbooks/atlas/T4H_Taxonomy_Themes_01_to_08_LOSSLESS_MASTER_FRESH.csv.gz.b64}"
EXPECTED_SOURCE_SHA256="${ATLAS_SOURCE_SHA256:-5efd321eafc9ef6a51026119593148ac9d85eeb7db64937b18d0da3d63758947}"
RUN_ID="${ATLAS_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="${ATLAS_RUN_DIR:-$ROOT/receipts/$RUN_ID}"
SOURCE="$RUN_DIR/canonical-taxonomy.csv"
NORMALIZED="$RUN_DIR/canonical-atlas.json"
DIST="$RUN_DIR/dist"
NPM_CACHE="${ATLAS_NPM_CACHE:-${TMPDIR:-/tmp}/t4h-atlas-npm-cache}"

mkdir -p "$RUN_DIR" "$NPM_CACHE"

{
  echo "run_id=$RUN_ID"
  echo "source_b64=$SOURCE_B64"
  echo "expected_source_sha256=$EXPECTED_SOURCE_SHA256"
  echo "started_at=$(date -u +%FT%TZ)"
  echo "node=$(node --version)"
  echo "npm=$(npm --version)"
} > "$RUN_DIR/runtime.env"

if [[ ! -f "$SOURCE_B64" ]]; then
  printf '{"classification":"BLOCKED","status":"SOURCE_MISSING","source":"%s"}\n' "$SOURCE_B64" > "$RUN_DIR/final-receipt.json"
  exit 2
fi
base64 --decode "$SOURCE_B64" > "$RUN_DIR/canonical-taxonomy.csv.gz"
gzip --decompress --stdout "$RUN_DIR/canonical-taxonomy.csv.gz" > "$SOURCE"
ACTUAL_SOURCE_SHA256="$(sha256sum "$SOURCE" | cut -d' ' -f1)"
if [[ "$ACTUAL_SOURCE_SHA256" != "$EXPECTED_SOURCE_SHA256" ]]; then
  printf '{"classification":"BLOCKED","status":"SOURCE_HASH_MISMATCH","expected":"%s","actual":"%s"}\n' "$EXPECTED_SOURCE_SHA256" "$ACTUAL_SOURCE_SHA256" > "$RUN_DIR/final-receipt.json"
  exit 2
fi

cd "$ROOT"
npm ci --cache "$NPM_CACHE"
npm test | tee "$RUN_DIR/tests.log"
node compiler/normalize.mjs "$SOURCE" "$NORMALIZED" "$RUN_DIR/normalization-receipt.json" | tee "$RUN_DIR/normalize.log"
ATLAS_EXPECT_COUNTS=8,61,489 node compiler/build.mjs "$NORMALIZED" "$DIST" | tee "$RUN_DIR/build.log"

node --input-type=module - "$RUN_DIR" <<'NODE'
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
const dir=process.argv[2];
const read=name=>JSON.parse(fs.readFileSync(path.join(dir,name)));
const normalization=read("normalization-receipt.json");
const build=read("dist/build-receipt.json");
const files=[];
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):[path.join(d,e.name)]);
for(const file of walk(dir)) if(!file.endsWith("SHA256SUMS")) files.push(file);
const sums=files.sort().map(file=>`${crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex")}  ${path.relative(dir,file)}`).join("\n")+"\n";
fs.writeFileSync(path.join(dir,"SHA256SUMS"),sums);
const receipt={
  classification: normalization.normalization_status==="PASS" && build.build_status==="PASS" ? "PARTIAL" : "BLOCKED",
  status: normalization.normalization_status==="PASS" && build.build_status==="PASS" ? "BUILD_VERIFIED_NOT_DEPLOYED" : "BUILD_FAILED",
  run_id:path.basename(dir),
  normalization,
  build,
  completed_at:new Date().toISOString()
};
fs.writeFileSync(path.join(dir,"final-receipt.json"),JSON.stringify(receipt,null,2));
console.log(JSON.stringify(receipt,null,2));
NODE

echo "ATLAS_RUN_DIR=$RUN_DIR"
echo "FINAL_RECEIPT=$RUN_DIR/final-receipt.json"
