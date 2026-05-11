# Ecosystem OS Monitoring and Finalisation Model

Status: PARTIAL
Task ID: ecosystem-os-catalogue-control-tower-2026-05-11
Issue: #76

## Purpose
This document defines how the Ecosystem OS catalogue/control-tower work is monitored, finalised, and prevented from silently dying between chat, GitHub, Bridge, Supabase, and Command Centre.

## Current evidence
- GitHub Issue #76 exists as the canonical execution tracker.
- Connector commit exists for the execution pack: `6580721d6b96e4696c56dbf0467ba76026f9dad2`.
- Issue #76 contains the execution plan and REAL gate.

## Monitoring surfaces

| Surface | Role | Current status | Finalisation signal |
|---|---|---|---|
| GitHub Issue #76 | Human-readable execution tracker | ACTIVE | closed only after Bridge receipt |
| Repo file path | Durable artefact storage | PARTIAL | all package files committed |
| MCP Bridge | Canonical execution path | PENDING | receipt returned |
| fn_github_push | Canonical repo write function | PENDING | commit_sha + content_sha + html_url |
| Reality Ledger | Evidence classification | PENDING | evidence row created |
| Command Centre | Operational visibility | NOT YET WIRED | widget/dashboard shows state |
| Supabase runtime | Actual system substrate | NOT YET APPLIED | schema/views/functions deployed and smoke-tested |

## Required state machine

```text
INTAKE
  -> PACKAGED
  -> TRACKED
  -> BRIDGE_SUBMITTED
  -> COMMITTED
  -> VALIDATED
  -> LEDGER_BOUND
  -> VISIBLE_IN_COMMAND_CENTRE
  -> REAL
```

Current state: TRACKED / PARTIAL.

## Closure rules

### Do not close as REAL until all are true
- Bridge receipt exists.
- All required files are committed by canonical path or formally accepted connector fallback.
- Supabase schema migration has been executed or explicitly scheduled as blocked.
- Reality Ledger row exists.
- Command Centre visibility exists or a widget spec is committed.
- Issue #76 has final receipt comment.
- Any missing runtime dependency is declared as BLOCKED, not ignored.

### Connector commit is not enough
A connector commit proves persistence. It does not prove runtime execution. Therefore connector-only evidence can advance work from ephemeral to tracked, but not from PARTIAL to REAL.

## Monitoring checklist

### Every review loop checks
- Is Issue #76 open?
- Are there new comments or receipts?
- Are all expected files present?
- Has Bridge returned receipt?
- Has any runtime validation happened?
- Has a Reality Ledger evidence row been created?
- Is there any stale item older than 24 hours with no owner/action?

## Expected files

- `00_ecosystem-os-execution-pack.md` — created by connector
- `01_ecosystem-os-control-schema.sql` — pending
- `02_bridge-execution-envelope.json` — pending
- `03_command-centre-widget-spec.md` — pending
- `04_reality-ledger-entry.json` — pending
- `05_monitoring-and-finalisation-model.md` — this file

## Finalisation receipt template

```yaml
status: REAL | PARTIAL | BLOCKED
result:
  issue: 76
  repo: TML-4PM/the-pen
  artefact_path: catalogs/ecosystem-os/2026-05-11/
  bridge_receipt: <receipt_id_or_url>
  commits:
    - path: <path>
      commit_sha: <sha>
      content_sha: <sha>
      html_url: <url>
evidence:
  - type: github_commit
    value: <sha>
  - type: bridge_receipt
    value: <receipt>
  - type: ledger_row
    value: <row_id>
gaps:
  - <remaining gap or none>
next_action: <single next action or CLOSE>
elevation: <why this matters>
pressure_flags:
  - stale_if_no_bridge_receipt
score: <0.00-1.00>
```

## Automation requirement
A future monitoring agent should poll Issue #76 and the repo path. If no Bridge receipt appears within the expected execution window, it should post an escalation comment and keep the issue open.

## Final decision rule
This work is complete only when the ecosystem control tower is no longer just described. It must be evidenced through committed artefacts, runtime execution, ledger binding, and visible operational status.
