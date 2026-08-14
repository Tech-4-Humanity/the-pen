# PLC Lifecycle Team — Recovery Escrow

Status date: 2026-08-14

## Purpose
This directory is a temporary governed recovery escrow for the Product, Market & Customer Lifecycle team qualification assets.

**Canonical target remains:** `TML-4PM/t4h-engineering-control-plane`.

This escrow does **not** redefine canonical ownership. It exists because the active GitHub App installation currently omits the canonical repository from its visible repository set, even though that repository was writable earlier in the same implementation stride.

## Current classification

- Harness contract: **REAL**
- Live event-driven worker-team runtime: **PARTIAL**
- Canonical control-plane publication/readback path: **DEGRADED**

The harness is REAL because deterministic qualification executed and passed. The live team remains PARTIAL until a real external lifecycle event wakes the production runtime, routes actual specialists, persists handoffs/outcomes, produces independent validation, receipt/ledger/telemetry/readback, and sleeps.

## Verified qualification evidence

Local deterministic qualification suite:

- tests: `3/3 PASS`
- capability contracts: `27`
- lifecycle event classes: `30`
- all capabilities have explicit required inputs and outputs
- all 27 capabilities are routable by at least one event
- BUILD_VALIDATED fixture: `9 activated`, `18 suppressed`, `0 blocked`, `0 incomplete handoffs`
- backwards-pressure events observed: `PRICE_RESISTANCE`, `USABILITY_FAILURE`
- support feedback loop: systemic usability signal routed upstream and `3` duplicate executions suppressed
- deterministic replay: PASS
- synthetic BUILD_VALIDATED harness score: `100/100`
- suite receipt: `PLCS-1a985ec8faf939832f3b`

Verified local archive:

- archive: `PLC_LIFECYCLE_TEAM_HARNESS_VERIFIED.zip`
- SHA-256: `5e29ffdadddb642825834840676d42ed520d5e77abcb0cbd82aeeadfbe4df005`

## Escrowed replay artifact

`plc_harness_selftest.py`

Replay:

```bash
python3 recovery/plc-lifecycle-team/plc_harness_selftest.py
```

It deterministically verifies:

1. exactly 27 capability contracts;
2. every capability has non-empty required inputs and outputs;
3. all capability IDs referenced by events are valid;
4. every capability is reachable from at least one lifecycle event;
5. `BUILD_VALIDATED` activates the intended minimum-fit 9-capability team, including Support and Commercial Governance, while suppressing 18 irrelevant capabilities;
6. downstream `PRICE_RESISTANCE` and `USABILITY_FAILURE` routes exist;
7. the support-pattern → usability-failure chain suppresses three duplicate executions;
8. replay key generation is deterministic.

Escrow commit containing the self-test:

`5ee90af07862350b8f73ce9aeeb56dad9d77647d`

## Input/output contract rule

A human supplies one raw lifecycle case, not 27 specialist forms. The normaliser derives specialist inputs from source material, authoritative research, existing product/build/customer evidence and upstream capability outputs.

Every applicable capability must end in one of:

`REAL | PARTIAL | BLOCKED | DEGRADED | QUARANTINED | NOT_APPLICABLE`

`BLOCKED` requires the exact missing dependency. `NOT_APPLICABLE` requires an explicit reason. Material handoffs require identity, outcome, provenance, owner, acceptance contract, authority, dependencies, fact/assumption separation, evidence/evidence gap, and next action.

## Migration / recovery rule

When `TML-4PM/t4h-engineering-control-plane` becomes visible to the authorised GitHub runtime again:

1. refresh canonical repository truth;
2. compare canonical PLC assets against this escrow and the recorded qualification hashes;
3. copy only missing/newer governed assets into the canonical repository;
4. execute the self-test and the full qualification suite from the canonical repository;
5. independently read back the canonical files, commit and runtime result;
6. update issue `[PLC-001]` with receipts;
7. mark this escrow `SUPERSEDED` with the canonical commit/readback reference;
8. retain historical evidence rather than deleting provenance.

Do not silently promote this escrow to canonical ownership.

## Next REAL gate

The next qualification is the real user-supplied `PLC-TST-001` case through the production event/runtime path:

`raw case -> normalise -> minimum-fit team -> execute -> backwards pressure as needed -> independent validation -> measurable next_outcome -> receipt + ledger + telemetry + readback -> replay/dedupe -> sleep`.

Until that production path is observed, the worker-team runtime remains PARTIAL even though the contract harness is REAL.
