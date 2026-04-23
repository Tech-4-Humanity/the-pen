# Say It Once — Command Centre + Synal Snaps Wiring

## Objective

Connect Say It Once outputs into:
- Command Centre (visibility, tracking, evidence)
- Synal Snaps (execution + worker completion)

## Core flow

Decision → Intent Engine → Role Expansion → Tool Outputs → Snaps → Execution → Command Centre Logging

---

## 1. Supabase tables (minimum)

### sio_decisions

- id
- input_text
- source (manual / API / voice)
- org_id
- created_at

### sio_blast_radius

- decision_id
- functions_impacted
- roles_impacted
- systems_touched
- drift_risk
- miss_rate_pct

### sio_outputs

- id
- decision_id
- role (HR / Finance / IT etc)
- output_type (kanban / excel / email etc)
- content
- status (generated / pushed / executed)

### sio_snaps

- id
- decision_id
- snap_type
- assigned_worker
- execution_status
- completed_at

### sio_drift_log

- decision_id
- timestamp
- drift_score
- notes

---

## 2. Synal Snaps integration

Each role output becomes a Snap.

Example:

Decision → HR output → Snap:

- snap_type: HR_WORKFORCE_ACTION
- worker: HR_AGENT
- payload: staffing constraints

Decision → IT output → Snap:

- snap_type: IT_KANBAN_SETUP
- worker: IT_AGENT
- payload: board structure

### Snap lifecycle

1. Snap created
2. Snap assigned to worker
3. Worker executes task
4. Completion logged
5. Status returned to Command Centre

---

## 3. Command Centre widgets

### Widget 1 — Decision Feed

Shows:
- latest decisions
- blast radius summary
- drift score

### Widget 2 — Execution Status

Shows:
- snaps created
- snaps completed
- snaps pending

### Widget 3 — Drift Monitor

Shows:
- drift over time
- high-risk decisions

### Widget 4 — Impact Map

Shows:
- functions affected
- systems touched

---

## 4. Lambda / Bridge functions

### function: sio-intent-parse

Input: raw decision
Output: structured intent

### function: sio-role-expand

Input: structured intent
Output: role-specific interpretations

### function: sio-tool-render

Input: role interpretation
Output: tool artefacts

### function: sio-create-snaps

Input: outputs
Output: snaps

### function: sio-log-command-centre

Input: execution data
Output: CC records

---

## 5. Execution loop

1. Decision captured
2. Intent parsed
3. Roles expanded
4. Outputs rendered
5. Snaps created
6. Workers execute
7. Command Centre logs
8. Drift updated

---

## 6. Evidence binding (Reality Ledger)

Each step logs:

- input
- output
- execution
- status

Classification:
- REAL (executed)
- PARTIAL (generated only)
- PRETEND (demo)

---

## 7. API contract example

POST /sio/decision

{
  "input": "Start Project Atlas...",
  "org_id": "t4h_demo"
}

Response:

{
  "decision_id": "...",
  "blast_radius": {...},
  "outputs": [...],
  "snaps": [...]
}

---

## 8. Deployment note

All outputs should be visible in Command Centre within seconds.

Snaps should begin execution immediately for demo purposes.

---

## Result

Say It Once becomes:

- visible (Command Centre)
- actionable (Snaps)
- provable (Reality Ledger)
