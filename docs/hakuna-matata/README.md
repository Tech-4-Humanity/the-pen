# Hakuna Matata Runtime Pack

Hakuna Matata is the canonical **table of tables** for The Pen runtime. It registers canonical tables, their contracts, their relationships, and the validators that prove each state transition can be consumed by the next.

This pack implements four connected capabilities:

1. **Table registry** — canonical definitions for organisation, customer, asset, person, agent, provider, capability, workflow, policy, evidence, receipt, telemetry, outcome, perspective and related tables.
2. **Loop engineering** — chained loops with explicit inputs, outputs, evidence, recovery and next-state contracts.
3. **Perspective engine** — weighted executive, 729-role, 1,000-agent and 10,000-person impact modelling.
4. **Provider routing** — provider-neutral architect/implementer/verifier routing with benchmark evidence.

## Run

```bash
python3 runtime/hakuna_matata/bootstrap.py
python3 runtime/hakuna_matata/validate.py
python3 runtime/hakuna_matata/perspective.py examples/questions/standard-business-question.json
```

The bootstrap is idempotent and writes receipts under `runtime/hakuna_matata/out/receipts/`.

## House contract

Every registered table and loop must:

- consume a canonical contract;
- validate its incoming state;
- produce a canonical outgoing contract;
- emit evidence and a receipt;
- identify the next valid state;
- provide a recovery path;
- never claim `REAL` without observable evidence.

## Runtime state classifications

`REAL`, `PARTIAL`, `BLOCKED`, `DEGRADED`, `QUARANTINED`, `ASPIRATIONAL`.
