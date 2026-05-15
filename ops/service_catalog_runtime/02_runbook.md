# Production Runbook — Service Catalog Runtime

Status: READY_FOR_EXECUTION

## One-command target state

Bridge executes:

1. Deploy `00_schema.sql`
2. Deploy `01_seed.sql`
3. Run session freshness harness
4. Record evidence
5. Update issue #109

## Validation

Run:

```sql
SELECT * FROM ops.v_stale_sessions;
SELECT * FROM ops.v_open_contradictions;
SELECT * FROM ops.v_catalog_gaps;
SELECT * FROM ops.v_quarantined_audits;
SELECT ops.fn_catalog_active_ready('OR-RB-001');
```

Expected:
- stale sessions visible
- contradictions visible
- catalog gaps visible
- quarantined audits visible
- ACTIVE checks fail until metadata complete

## Promotion rules

Cannot promote ACTIVE until:
- evidence attached
- telemetry attached
- support model complete
- instruction SHA attached
- smoke tests passed
- runtime receipt returned

## Failure handling

If deployment partially fails:

1. stop mutations
2. write receipt
3. classify PARTIAL
4. attach blocker
5. retry idempotently
