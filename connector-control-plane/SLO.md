# Connector Control Plane — Service Level Objectives

| Metric                              | Target            | Window  | Alarm threshold     |
| ----------------------------------- | ----------------- | ------- | ------------------- |
| Intent router availability          | 99.5%             | 30 days | < 99.5% rolling 24h |
| Intent router p95 latency           | < 1500 ms         | 7 days  | > 2000 ms p95 1h    |
| Health probe success per connector  | > 95%             | 24h     | < 90% 1h            |
| Receipt write success               | 99.9%             | 30 days | < 99% 1h            |
| DLQ depth                           | 0                 | live    | > 0 for 5 min       |

## Error budget policy
- If any SLO is breached in a rolling 7-day window, **freeze feature work** until restored.
- All BLOCKED receipts must be reviewed within 24h; root cause logged in `ccp_receipts.evidence`.

## Definition of REAL
A workflow is REAL only when:
1. CDK stack deployed (CloudFormation `CREATE_COMPLETE` or `UPDATE_COMPLETE`).
2. Schema migrations 001/002/003 applied.
3. At least one health probe receipt written in the last 10 minutes.
4. At least one intent receipt written end-to-end.
5. All five alarms in OK state.

Anything short of all five = PARTIAL.
