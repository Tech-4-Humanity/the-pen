# GitHub Workflow Repair Policy

**Status:** CANONICAL
**Scope:** All repositories using GitHub Actions as runtime, bridge, watchdog, audit, monitor, deploy, receipt, or command-centre execution layer
**Source issue:** [TML-4PM/the-pen#144](https://github.com/TML-4PM/the-pen/issues/144)
**Owning surface:** the-pen (canonical)
**Applied to:** TML-4PM/the-pen, TML-4PM/omnibrain-superpack, and all repos in TML-4PM with workflows

## Operating principle

Workflow failures are **systemic execution-governance events**, not isolated technical incidents. The repair loop must run end-to-end before any classification of completion.

## Canonical repair loop

```text
inspect → patch → trigger/observe → verify → receipt → classify → close
```

This is the **only** valid path. Any short-circuit (e.g. `inspect → patch → claim`) is an anti-pattern and forbidden.

## Required system-wide controls

### 1. No REAL without fresh run evidence

A workflow repair may be classified `REAL` **only** when:

- A fresh workflow run was triggered post-patch
- The run completed (success or expected failure)
- A receipt was written referencing the run ID
- The classification reflects the actual run outcome

File creation, code patch, or commit alone is `PARTIAL`, never `REAL`.

### 2. Workflow_dispatch as standard repair tool

Every repair workflow MUST support `workflow_dispatch` so the repair operator can trigger validation runs without waiting for cron or external events.

### 3. Human-as-monitor is forbidden

The operator (Troy or any director) is **not** the monitoring surface. Workflows must:

- Emit structured run results to a receipt path
- Write reality_ledger rows on completion
- Surface failures via Telegram or canonical alert channel
- Self-classify on completion

A repair that requires the operator to provide screenshots is incomplete.

### 4. Recursive watchdog failure detection

If a watchdog workflow itself fails, that failure must be surfaced through a different channel (alert workflow, manual cron, Telegram bot heartbeat) — not by the same watchdog reporting on itself.

### 5. Receipt-binding for every repair

Every workflow repair execution must produce:

- A receipt file at `receipts/runtime/workflow-repair-{workflow}-{timestamp}.receipt.json`
- A canonical_changes audit row
- A reality_ledger row with status REAL/PARTIAL/BLOCKED
- A commit linking the patch to the run

## Observed failure pattern (from #144 escalation)

The anti-pattern that triggered this policy:

1. Workflow fails
2. User provides screenshot
3. Assistant patches one local symptom
4. Assistant reports REAL too early
5. Fresh GitHub run fails again
6. User becomes monitoring surface
7. Loop repeats

**Root cause:** Operating model lacked the hard gate `inspect → patch → trigger/observe → verify → receipt → classify → close`.

## Validation gate (mandatory before close)

Before a workflow repair issue closes, all of:

- [ ] Patch commit SHA exists
- [ ] Post-patch workflow run ID exists
- [ ] Run completed with expected outcome
- [ ] Receipt file committed
- [ ] Reality ledger row written
- [ ] Canonical change audit entry references the receipt

If any item is missing: status is `PARTIAL`, issue stays open.

## Enforcement scope

- All repos in TML-4PM org
- All workflows used as runtime/bridge/watchdog/audit/monitor/deploy/receipt layer
- Applies retroactively: existing open workflow repair issues should be re-classified against this gate

## Pressure flags (avoid)

- Premature REAL classification
- Repeated user escalation
- Human-as-monitor anti-pattern
- Recursive watchdog failure
- Missing validation gate

## Provenance

| Field | Value |
|---|---|
| Authored by | Claude triage session |
| Source body | TML-4PM/the-pen#144 |
| Codified at | 2026-05-26T03:24:33.468825+00:00 |
| Escalation score | 0.81 (per issue body) |
