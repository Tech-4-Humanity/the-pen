# IMPLEMENTATION — T4H Closed-Loop Execution Fabric

## 1. Runtime Self-Healing Layer

### Components
- EventBridge Scheduler
- Lambda Router (t4h-autofix-router)
- Heartbeat Lambda (t4h-scheduler-heartbeat)
- Repair Lambda (t4h-scheduler-repair)
- DLQ + Replay Lambda (t4h-dlq-replayer)

### Requirements

- Scheduler must be reconciled via:
  - `reconcile_scheduler.sh`
  - GitHub workflow: `reconcile-control-tower-scheduler.yml`
  - Optional EC2 loop (systemd)

- Heartbeat runs every 5 minutes and:
  - checks last execution timestamps
  - writes to scheduler_health_log
  - triggers repair when stale

- Repair Lambda must:
  - rerun reconcile script logic
  - reattach Lambda permissions
  - rebind EventBridge targets
  - force test invocation

- DLQ replay must:
  - retry up to 3 times
  - log retry_count
  - escalate after threshold

---

## 2. Evidence + Economic Engine

### Supabase Tables

execution_log:
- id (uuid)
- function_name
- status
- latency_ms
- payload (jsonb)
- value_usd
- cost_usd
- profit_usd (generated)
- business
- product
- created_at

scheduler_health_log:
- id
- component
- last_seen
- status
- action_taken
- revenue_at_risk
- created_at

value_rules:
- id
- function_name
- rule_type
- value_formula

billing_events:
- id
- execution_id
- amount
- status

---

### Requirements

- Every Lambda must emit structured execution output.
- Value attribution must be applied via value_rules.
- Revenue router must convert execution to billing_events.
- Stripe integration must be stubbed or active depending on environment.

---

## 3. Documentation Publishing

### Required Docs

- README.md
- Operations_Runbook.md
- Architecture.md
- Execution_Contract.md

### Requirements

- All docs must be written to Google Drive.
- All writes must return URLs.
- URLs must be stored in Supabase doc_registry.

---

## 4. Command Centre Integration

### Widgets

- scheduler-health
- execution-economy
- system-docs

### Requirements

- Widgets must read from Supabase.
- Must show live execution, health, and revenue data.

---

## 5. Distribution + Optimisation

### Optimizer Lambda

- identify low-profit executions
- reduce frequency or batch
- increase parallelism for high-profit flows

### Distribution Hooks

- email
- reports
- lead capture

---

## 6. Proof Requirements

Must include:

- Successful scheduler invocation
- Lambda execution logs
- Supabase rows inserted
- Google Drive URLs returned
- GitHub workflow run

---

## 7. Reality Ledger Classification

- PARTIAL/UNPROVEN until proof exists
- REAL only after:
  - execution proof
  - coverage proof
  - ledger entries

---

## 8. Completion Trigger

System is complete when:

- nothing can silently fail
- failures self-heal automatically
- all executions are logged and valued
- docs are generated and linked
- Command Centre shows live state

No partial acceptance.
