# MCP GOOGLE DRIVE RUNTIME CONTROL PLANE — DEV
**promoted_from:** handoffs/mcp-google-drive-runtime-control-plane-20260506.md  
**promoted_at_utc:** 2026-05-06T07:58:00Z  
**env:** dev  
**status:** PROMOTED_TO_DEV  

## Execution Tasks
1. Create `public.t4h_secret_registry` table (SQL in handoff)
2. Create `public.t4h_connector_health` table (SQL in handoff)
3. Seed Google Drive canonical names + aliases
4. Apply runtime alias shim to MCP/bridge startup
5. Add startup assertions for `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REFRESH_TOKEN`
6. Add token freshness probe
7. Add drift scanner job
8. Write Reality Ledger binding
9. Emit outbound + inbound receipts under `receipts/mcp-google-drive-runtime-control-plane/`

## Canonical Google Drive Env Vars
- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET
- GOOGLE_REFRESH_TOKEN
- GOOGLE_PROJECT_ID
- GOOGLE_APPLICATION_CREDENTIALS
- GOOGLE_DRIVE_FOLDER_ID

## Close Rule
Not COMPLETE until Google Drive MCP boots + harmless probe succeeds or BLOCKED receipt exists.

## Classification
PARTIAL_UNTIL_RUNTIME_RECEIPT
