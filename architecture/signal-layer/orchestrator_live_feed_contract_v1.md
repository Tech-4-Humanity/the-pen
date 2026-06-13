# Orchestrator Live Feed Contract v1

Parent: #170
Issue: #173
Status: PARTIAL

## Data Source
Primary view:
- v_orchestrator_signal_feed

Secondary view:
- synal.v_signal_lineage

## Required Fields
- signal_type
- severity
- status
- agent_id
- created_at
- parent_signal_id
- cause_id
- group_id
- decision_id
- journey_id

## Panels
### Live Feed
Chronological signal stream.

### Lineage Drawer
Show parent signal and root cause.

### Group View
Group by group_id.

### Decision View
Filter by decision_id.

### Journey View
Filter by journey_id.

## Actions
- acknowledge
- action
- close

Actions must not mutate lineage fields.

## Realtime
- subscribe to inserts
- subscribe to updates
- preserve ordering by created_at

## Success Criteria
- no synthetic data
- realtime updates visible
- lineage visible
- provenance preserved

Ledger:
- task_id: signal-orchestrator-173
- status: PARTIAL
