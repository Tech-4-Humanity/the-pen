#!/usr/bin/env bash
# deploy-schema-v1-v4.sh
# Deploys pcs_v1–v4 migration chain to Supabase project lzfgigiyqpuuxslsygjt
# Run from repo root. Requires: supabase CLI authenticated + linked to project.
# Issue: https://github.com/TML-4PM/the-pen/issues/108
# Created: 2026-05-20 by Perplexity MCP batch

set -euo pipefail

PROJECT_REF="lzfgigiyqpuuxslsygjt"
MIGRATION_DIR="supabase/migrations"

echo "=== Schema Deploy: pcs_v1-v4 ==="
echo "Project: $PROJECT_REF"
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Confirm linked
supabase projects list | grep "$PROJECT_REF" || { echo "ERROR: Project not linked. Run: supabase link --project-ref $PROJECT_REF"; exit 1; }

# Run migrations in order
FILES=(
  "$MIGRATION_DIR/pcs_v1_migration.sql"
  "$MIGRATION_DIR/pcs_v2_secrets_migration.sql"
  "$MIGRATION_DIR/pcs_v3_url_census.sql"
  "$MIGRATION_DIR/pcs_v4_handover.sql"
)

for f in "${FILES[@]}"; do
  echo ">>> Applying: $f"
  supabase db execute --file "$f" --project-ref "$PROJECT_REF"
  echo "    OK"
done

echo ""
echo "=== DONE: pcs_v1-v4 deployed ==="
echo "Post receipt to issue #108 confirming completion."
