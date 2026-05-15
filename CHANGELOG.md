# CHANGELOG — TML-4PM/the-pen

## 2026-05-16 — GLOBAL_RULE v3.7

**Change type:** SYSTEM_CHANGE
**Severity:** NORMAL
**Affected:** [GLOBAL_RULE.md, session_runtime, connector_execution_policy]

### Summary
Merged the session-permission rule from `bridge-payloads/2026-05-13-session-permission-memory-rule.json` into the canonical `GLOBAL_RULE.md`. Closes the 3-day-old PARTIAL classification on that payload.

### What changed
1. **Version bump** 3.6 → 3.7. `last_change` → 2026-05-16.
2. **New §3.4 Session permission scope** — one explicit grant per active session authorises non-destructive connector execution within scope. Hard boundaries (destructive deletes, secret rotation, financial transactions, legal filings, mass outreach, cross-account, safety) remain explicit-confirm.
3. **§5 Execution Tiers** — added session-permission interaction note. AUTO/LOG inside granted scope = proceed + `[LOG]`. GATED still dry-run+confirm. BLOCKED still explicit.
4. **§7 Reality Ledger** — added `bridge_payload_registry` table contract: every bridge payload committed to the-pen MUST be registered in `ops.bridge_payload_registry` AND receipted in `t4h_canonical_changes`.
5. **§8 Build Principles** — added two new lines:
   - "One permission per session" (cross-ref §3.4).
   - "Build on existing schema, not parallel substrates" — probe `core`, `runtime`, `ops`, `audit`, `agoe` before proposing new schemas.
6. **§9 Silent Failure Traps** — added traps #24, #25, #26:
   - #24 Re-asking permission within granted scope is a Tier-LOG rule violation.
   - #25 Proposing to "deploy a runtime substrate" without probing existing schemas is a duplication risk.
   - #26 Bridge payloads in `bridge-payloads/` are PARTIAL until registered AND receipted.

### Origin
- Bridge payload: `bridge-payloads/2026-05-13-session-permission-memory-rule.json` (SHA: 554b845f0ce2f3559069a55f47d514413f6eb846)
- Prior PARTIAL classification: chat session 2026-05-13, runtime convergence handover
- Reason for delay: payload committed but never merged into canonical rule files, never registered in `ops.bridge_payload_registry`, never receipted in `t4h_canonical_changes`

### Receipts
- New GLOBAL_RULE.md SHA256: `256ff6c8733b2fa1aa78a28562c2e593e7bd1a2173b38624a7a992518b0402d6`
- Canonical change row: see `public.t4h_canonical_changes` memory_key=`session_permission_scope_v3_7_2026_05_16`
- Bridge payload registry row: see `ops.bridge_payload_registry` payload_key=`session-permission-memory-rule-2026-05-13`

### Rollback
Restore prior file SHA `cd179732b2eb182c714dd11e5c97c544e4c8d2c9`. Set `sealed=true` on the canonical change row. Delete the bridge_payload_registry row.

### Author
claude-opus-4-7 — session_ref `pen_runtime_handover_2026_05_16`
