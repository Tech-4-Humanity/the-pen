#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${REPO_DIR:-$HOME/projects/TML-4PM/the-pen}"
OUT_DIR="$REPO_DIR/runtime/maat-estate-recovery"
RUN_TS="$(date -u +%Y%m%dT%H%M%SZ)"
RECEIPT_DIR="$OUT_DIR/receipts/$RUN_TS"
ZIP_PATH="$HOME/Downloads/maat-estate-recovery-sprints-$RUN_TS.zip"
PRINCIPAL_ID="principal:gpt-troy"

mkdir -p "$OUT_DIR" "$RECEIPT_DIR"
cd "$REPO_DIR"

required_outputs=(
  maat_vercel_estate.csv
  maat_source_reconciliation.csv
  maat_preservation_mapping.csv
  maat_backend_dependency_map.csv
  maat_runtime_readback.csv
  maat_disposition_register.csv
  evidence_manifest.json
  recovery_receipt.json
  maat_component_match_evidence.json
  maat_backend_inventory.csv
  maat_runtime_dependencies.csv
  maat_api_contracts.csv
  maat_supabase_mapping.csv
  maat_storage_mapping.csv
  maat_runtime_health.csv
  maat_component_graph.json
  runtime_receipt.json
  maat_canonical_product_map.csv
  maat_component_registry.csv
  maat_duplicate_clusters.csv
  maat_successor_mapping.csv
  maat_rebuild_queue.csv
  maat_dependency_order.json
  maat_canonical_architecture.json
  maat_rebuild_acceptance_contract.md
  consolidation_receipt.json
  final_estate_report.md
)

printf '%s\n' \
  "SPRINT 1 — ESTATE INVENTORY (#298)" \
  "SPRINT 2 — SOURCE + S3 RECONCILIATION (#300)" \
  "SPRINT 3 — BACKEND + RUNTIME TRUTH (#301)" \
  "SPRINT 4 — CANONICAL MAP + DUPLICATE COLLAPSE (#302)" \
  "SPRINT 5 — TARGET ARCHITECTURE FREEZE" \
  "SPRINT 6 — REBUILD EXECUTION QUEUE" \
  "SPRINT 7 — P0 CONTROL PLANE" \
  "SPRINT 8 — P1 OPERATIONAL MODULES" \
  "SPRINT 9 — DATA RECONNECTION" \
  "SPRINT 10 — DOMAINS + PUBLICATION" \
  "SPRINT 11 — ARCHIVE + DUPLICATE CLOSURE" \
  "SPRINT 12 — FINAL ESTATE REPORT"

cat > "$OUT_DIR/maat_target_architecture.json" <<'JSON'
{
  "control_plane": [
    "Executive",
    "Financial Intelligence",
    "Research Intelligence",
    "Runtime Integrity",
    "Reports",
    "Administration"
  ],
  "status": "PLANNED"
}
JSON

mkdir -p \
  "$OUT_DIR/maat_source_build_receipts" \
  "$OUT_DIR/maat_s3_readback_receipts" \
  "$OUT_DIR/maat_rebuild_manifests" \
  "$OUT_DIR/maat_test_contracts" \
  "$OUT_DIR/maat_deployment_contracts" \
  "$OUT_DIR/maat_rollback_contracts"

missing=()
for rel in "${required_outputs[@]}"; do
  [[ -f "$OUT_DIR/$rel" ]] || missing+=("$rel")
done

readback_dirs=(maat_source_build_receipts maat_s3_readback_receipts)
for rel in "${readback_dirs[@]}"; do
  if ! find "$OUT_DIR/$rel" -type f -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    missing+=("$rel/<receipt>")
  fi
done

classification="REAL"
if ((${#missing[@]} > 0)); then
  classification="PARTIAL"
fi

python3 - "$RECEIPT_DIR/gap-report.json" "$classification" "${missing[@]}" <<'PY'
import json, sys
path, classification, *missing = sys.argv[1:]
with open(path, "w", encoding="utf-8") as fh:
    json.dump({
        "classification": classification,
        "missing_outputs": missing,
        "missing_count": len(missing),
    }, fh, indent=2)
    fh.write("\n")
PY

find "$OUT_DIR" -type f \
  ! -name SHA256SUMS \
  ! -path "$RECEIPT_DIR/run-receipt.json" \
  -print0 | sort -z | xargs -0 shasum -a 256 > "$OUT_DIR/SHA256SUMS"

cat > "$RECEIPT_DIR/run-receipt.json" <<JSON
{
  "principal_id": "$PRINCIPAL_ID",
  "repository": "TML-4PM/the-pen",
  "path": "runtime/maat-estate-recovery",
  "classification": "$classification",
  "generated_at": "$(date -u +%FT%TZ)",
  "missing_count": ${#missing[@]},
  "gap_report": "runtime/maat-estate-recovery/receipts/$RUN_TS/gap-report.json",
  "real_gate": "REAL only after every required output exists and source, runtime, storage, hashes and independent readback are verified"
}
JSON

rm -f "$ZIP_PATH"
cd "$REPO_DIR/runtime"
zip -qr "$ZIP_PATH" maat-estate-recovery
cd "$REPO_DIR"
unzip -tq "$ZIP_PATH" >/dev/null

ZIP_SHA256="$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')"
ZIP_BYTES="$(stat -f '%z' "$ZIP_PATH" 2>/dev/null || stat -c '%s' "$ZIP_PATH")"

# Runtime evidence is intentionally ignored in this repository. Do not force-add it.
# Only commit the runner itself when it changed.
git add -- runtime/maat-estate-recovery/scripts/run-maat-recovery-sprints.sh
if ! git diff --cached --quiet; then
  git commit -m "Fix MAAT sprint runner gap reporting and packaging"
  git push origin HEAD
fi

echo "STATUS=$classification"
echo "PRINCIPAL_ID=$PRINCIPAL_ID"
echo "ZIP=$ZIP_PATH"
echo "ZIP_SHA256=$ZIP_SHA256"
echo "ZIP_BYTES=$ZIP_BYTES"
echo "RECEIPT=$RECEIPT_DIR/run-receipt.json"
echo "GAP_REPORT=$RECEIPT_DIR/gap-report.json"
echo "MISSING_COUNT=${#missing[@]}"
echo "HEAD=$(git rev-parse HEAD)"

if [[ "$classification" != "REAL" ]]; then
  echo "BLOCKED: required MAAT sprint outputs remain missing; inspect $RECEIPT_DIR/gap-report.json" >&2
  exit 2
fi
