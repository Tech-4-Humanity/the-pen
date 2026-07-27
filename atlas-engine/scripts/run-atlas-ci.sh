#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKBOOK="${ATLAS_WORKBOOK:-$ROOT/../workbooks/atlas/T4H_Atlas_Editorial_Progress_Workbook_v1.xlsx}"
RUN_ID="${ATLAS_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="${ATLAS_RUN_DIR:-$ROOT/receipts/$RUN_ID}"
NORMALIZED="$RUN_DIR/canonical-atlas.json"
DIST="$RUN_DIR/dist"
NPM_CACHE="${ATLAS_NPM_CACHE:-${TMPDIR:-/tmp}/t4h-atlas-npm-cache}"

mkdir -p "$RUN_DIR" "$NPM_CACHE"

{
  echo "run_id=$RUN_ID"
  echo "workbook=$WORKBOOK"
  echo "started_at=$(date -u +%FT%TZ)"
  echo "node=$(node --version)"
  echo "npm=$(npm --version)"
} > "$RUN_DIR/runtime.env"

if [[ ! -f "$WORKBOOK" ]]; then
  printf '{"classification":"BLOCKED","status":"SOURCE_MISSING","source":"%s"}\n' "$WORKBOOK" > "$RUN_DIR/final-receipt.json"
  exit 2
fi

cd "$ROOT"
npm ci --cache "$NPM_CACHE"
npm test | tee "$RUN_DIR/tests.log"
node compiler/normalize.mjs "$WORKBOOK" "$NORMALIZED" "$RUN_DIR/normalization-receipt.json" | tee "$RUN_DIR/normalize.log"
node compiler/build.mjs "$NORMALIZED" "$DIST" | tee "$RUN_DIR/build.log"

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
