#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL is required}"
: "${PORT:=3000}"
RUNTIME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RECEIPT_DIR="$RUNTIME_DIR/receipts"; mkdir -p "$RECEIPT_DIR"
RECEIPT="$RECEIPT_DIR/ci-runtime-receipt.json"; SERVER_LOG="$RECEIPT_DIR/server.log"
OWNER_ID="11111111-1111-4111-8111-111111111111"; MODE_ID="quiet-hours"; STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; SERVER_PID=""
cleanup(){ if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then kill "$SERVER_PID" || true; wait "$SERVER_PID" 2>/dev/null || true; fi; }
trap cleanup EXIT
cd "$RUNTIME_DIR"
node --check src/server.js; node --check src/runtime.js; npm test
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f ../implementation/database-schema-v1.0.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
insert into people (person_id, display_name, age_band, status) values ('$OWNER_ID','CI Owner','adult','active');
insert into mode_definitions (mode_definition_id, version, name, purpose, definition, status) values ('$MODE_ID','1.0.0','Quiet Hours','CI validation mode','{}'::jsonb,'active');
SQL
PORT="$PORT" HOST="127.0.0.1" DATABASE_URL="$DATABASE_URL" node src/server.js >"$SERVER_LOG" 2>&1 & SERVER_PID=$!
for _ in $(seq 1 30); do if curl -fsS "http://127.0.0.1:$PORT/health" >/tmp/calmbound-health.json; then break; fi; sleep 1; done
curl -fsS "http://127.0.0.1:$PORT/health" >/tmp/calmbound-health.json
HOUSEHOLD_RESPONSE="$(curl -fsS -X POST "http://127.0.0.1:$PORT/v1/households" -H 'content-type: application/json' -H "x-person-id: $OWNER_ID" -H 'x-correlation-id: 22222222-2222-4222-8222-222222222222' --data '{"name":"CI Household","timezone":"Australia/Sydney"}')"
HOUSEHOLD_ID="$(printf '%s' "$HOUSEHOLD_RESPONSE" | jq -r '.id')"; test -n "$HOUSEHOLD_ID"; test "$HOUSEHOLD_ID" != "null"
OWNER_MEMBERSHIP_COUNT="$(psql "$DATABASE_URL" -Atc "select count(*) from household_memberships where household_id='$HOUSEHOLD_ID' and person_id='$OWNER_ID' and role_type='owner' and status='active';")"; test "$OWNER_MEMBERSHIP_COUNT" = "1"
MODE_RESPONSE="$(curl -fsS -X POST "http://127.0.0.1:$PORT/v1/households/$HOUSEHOLD_ID/modes" -H 'content-type: application/json' -H "x-person-id: $OWNER_ID" -H 'x-correlation-id: 33333333-3333-4333-8333-333333333333' --data "{\"modeDefinitionId\":\"$MODE_ID\",\"startsAt\":\"$STARTED_AT\"}")"
MODE_INSTANCE_ID="$(printf '%s' "$MODE_RESPONSE" | jq -r '.id')"; test -n "$MODE_INSTANCE_ID"; test "$MODE_INSTANCE_ID" != "null"
EVENT_COUNT="$(psql "$DATABASE_URL" -Atc "select count(*) from event_ledger where correlation_id in ('22222222-2222-4222-8222-222222222222','33333333-3333-4333-8333-333333333333');")"; test "$EVENT_COUNT" = "2"
ROLLBACK_BEFORE="$(psql "$DATABASE_URL" -Atc "select count(*) from households;")"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
drop schema public cascade;
create schema public;
grant all on schema public to public;
SQL
ROLLBACK_AFTER="$(psql "$DATABASE_URL" -Atc "select count(*) from information_schema.tables where table_schema='public';")"; test "$ROLLBACK_BEFORE" -ge 1; test "$ROLLBACK_AFTER" = "0"
FINISHED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
jq -n --arg status REAL --arg started_at "$STARTED_AT" --arg finished_at "$FINISHED_AT" --arg household_id "$HOUSEHOLD_ID" --arg mode_instance_id "$MODE_INSTANCE_ID" --arg owner_membership_count "$OWNER_MEMBERSHIP_COUNT" --arg event_count "$EVENT_COUNT" --arg rollback_before "$ROLLBACK_BEFORE" --arg rollback_after "$ROLLBACK_AFTER" '{status:$status,started_at:$started_at,finished_at:$finished_at,checks:{syntax:true,unit_tests:true,migration:true,health:true,household_create:true,owner_membership:($owner_membership_count|tonumber),mode_activate:true,event_receipts:($event_count|tonumber),rollback:true},objects:{household_id:$household_id,mode_instance_id:$mode_instance_id},rollback:{households_before:($rollback_before|tonumber),public_tables_after:($rollback_after|tonumber)}}' > "$RECEIPT"
cat "$RECEIPT"
