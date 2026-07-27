#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${REPO_DIR:-$HOME/projects/TML-4PM/the-pen}"
OUT_DIR="$REPO_DIR/runtime/maat-estate-recovery"
RECEIPT_DIR="$OUT_DIR/receipts/$(date -u +%Y%m%dT%H%M%SZ)"
ZIP_PATH="$HOME/Downloads/maat-estate-recovery-sprints-$(date -u +%Y%m%dT%H%M%SZ).zip"
PRINCIPAL_ID="principal:gpt-troy"

mkdir -p "$OUT_DIR" "$RECEIPT_DIR"
cd "$REPO_DIR"

echo "SPRINT 1 — ESTATE INVENTORY (#298)"
# Required outputs:
# maat_vercel_estate.csv
# maat_source_reconciliation.csv
# maat_preservation_mapping.csv
# maat_backend_dependency_map.csv
# maat_runtime_readback.csv
# maat_disposition_register.csv
# evidence_manifest.json
# recovery_receipt.json
# SHA256SUMS

echo "SPRINT 2 — SOURCE + S3 RECONCILIATION (#300)"
# Required outputs:
# maat_component_match_evidence.json
# maat_source_build_receipts/
# maat_s3_readback_receipts/

echo "SPRINT 3 — BACKEND + RUNTIME TRUTH (#301)"
# Required outputs:
# maat_backend_inventory.csv
# maat_runtime_dependencies.csv
# maat_api_contracts.csv
# maat_supabase_mapping.csv
# maat_storage_mapping.csv
# maat_runtime_health.csv
# maat_component_graph.json
# runtime_receipt.json

echo "SPRINT 4 — CANONICAL MAP + DUPLICATE COLLAPSE (#302)"
# Required outputs:
# maat_canonical_product_map.csv
# maat_component_registry.csv
# maat_duplicate_clusters.csv
# maat_successor_mapping.csv
# maat_rebuild_queue.csv
# maat_dependency_order.json
# maat_canonical_architecture.json
# maat_rebuild_acceptance_contract.md
# consolidation_receipt.json

echo "SPRINT 5 — TARGET ARCHITECTURE FREEZE"
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

echo "SPRINT 6 — REBUILD EXECUTION QUEUE"
mkdir -p "$OUT_DIR/maat_rebuild_manifests" "$OUT_DIR/maat_test_contracts" "$OUT_DIR/maat_deployment_contracts" "$OUT_DIR/maat_rollback_contracts"

echo "SPRINT 7 — P0 CONTROL PLANE"
echo "SPRINT 8 — P1 OPERATIONAL MODULES"
echo "SPRINT 9 — DATA RECONNECTION"
echo "SPRINT 10 — DOMAINS + PUBLICATION"
echo "SPRINT 11 — ARCHIVE + DUPLICATE CLOSURE"
echo "SPRINT 12 — FINAL ESTATE REPORT"

find "$OUT_DIR" -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 shasum -a 256 > "$OUT_DIR/SHA256SUMS"

cat > "$RECEIPT_DIR/run-receipt.json" <<JSON
{
  "principal_id": "$PRINCIPAL_ID",
  "repository": "TML-4PM/the-pen",
  "path": "runtime/maat-estate-recovery",
  "classification": "PARTIAL",
  "generated_at": "$(date -u +%FT%TZ)",
  "real_gate": "REAL only after runtime, storage, hashes and independent readback are verified"
}
JSON

rm -f "$ZIP_PATH"
cd "$REPO_DIR/runtime"
zip -qr "$ZIP_PATH" maat-estate-recovery
cd "$REPO_DIR"

git add runtime/maat-estate-recovery
if ! git diff --cached --quiet; then
  git commit -m "Add MAAT estate recovery sprint bundle runner"
  git push origin HEAD
fi

echo "STATUS=PARTIAL"
echo "PRINCIPAL_ID=$PRINCIPAL_ID"
echo "ZIP=$ZIP_PATH"
echo "RECEIPT=$RECEIPT_DIR/run-receipt.json"
echo "HEAD=$(git rev-parse HEAD)"
