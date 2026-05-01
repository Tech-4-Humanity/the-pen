# T4H Command Layer — Role Hub + Live Signal Feed Upgrade Spec

## Purpose
Upgrade the current Role Hub, Home, Portal and Explorer screens from static demo surfaces into a connected before/after operating model.

The UI should make it obvious that:
- roles change when signals arrive pre-triaged;
- agents absorb noise;
- humans focus on decisions;
- systems act and report proof;
- the registry remembers the state of the organisation.

---

## Current observed surfaces

### Role Hub
Current example: Project Manager.

Visible state:
- Transformation Stage: Assisted → Augmented
- Active Signals: 12 routed this week
- Agent Status: Active — Triage Mode
- Current Pain Points section begins below.

### Home
Visible example:
- Human channel: Weekly Leadership Update
- Machine broadcast: machine_broadcast.yaml
- Leadership speaks once; Command Layer delivers to people and machines.

### Portal
Visible example:
- Live Signal Feed
- Signals detected, triaged, routed and resolved.

### Explorer
Visible example:
- Registry: Roles, Signals, Assets & States.
- Search/filter roles, signals, assets and states.

---

## Required next UI principle
Every page should answer two questions:

1. What changed for the human?
2. What changed in the system?

If a page cannot answer both, it is only a brochure.

---

## Role Hub upgrade

### Add before/after grid per role
For every role, show the same grid.

| Dimension | Before | After Doolittles / Command Layer |
|---|---|---|
| Signals | Manually tracks 12+ sources | Receives routed, ranked, deduplicated signal feed |
| Decisions | Chases context in meetings | Sees decision-ready options with evidence |
| Tools | Updates Jira, Slack, email, docs separately | Agent pod updates linked systems and logs proof |
| Noise | Handles low-value triage | Agent auto-resolves routine signals |
| Communication | Rewrites messages for stakeholders | Personalised outputs generated automatically |
| Proof | Status buried in updates | Evidence badge and audit trail visible |
| Time | Days/weeks to align | Minutes/hours for first action |

### Add role-specific system map
For Project Manager:
- Slack / Teams
- Jira / Asana
- GitHub
- ServiceNow
- Roadmap tool
- Docs / SharePoint
- Calendar
- HoloWall
- Reality Ledger

### Add role agent pod
For Project Manager:
- Signal Triage Agent
- Dependency Mapping Agent
- Stakeholder Update Agent
- Risk Escalation Agent
- Evidence Logger Agent

### Add role action panel
Each role page needs a visible action list:

```text
Actions taken this week:
✔ 14 signals triaged
✔ 3 roadmap items queued
✔ 2 escalation summaries sent
✔ 1 ServiceNow change ticket drafted
✔ Evidence written to ledger
```

---

## Home upgrade

### Add dual-channel explanation
Left: human message.
Right: machine YAML.
Bottom: what systems did.

Current page already shows human channel and machine_broadcast.yaml. Add a third panel:

```text
Systems activated:
✔ Project Manager feed updated
✔ Product Lead roadmap action queued
✔ Data Analyst model recalibration queued
✔ Evidence log created
```

### Add CTA
Button: Run this announcement.

Output should animate:
1. human summary produced;
2. YAML produced;
3. route cards created;
4. tool activations queued;
5. proof logged.

---

## Portal upgrade

### Current live signal feed issue
The feed says things happened, but does not show enough consequence.

### Add fields to each card
- state;
- routed role;
- agent pod;
- systems touched;
- action taken;
- evidence status;
- rollback availability;
- click-through to Explorer entity.

### Example upgraded feed card

```text
New supply-chain risk detected
State: Routed → Actioned
Owner: Operations Lead
Pod: Ops Efficiency Pod
Systems: Slack, ServiceNow, Procurement, BI
Action: Risk ticket created; supplier review queued
Evidence: Logged / Replayable
Rollback: N/A
```

---

## Explorer upgrade

Explorer should become the organisation's memory layer.

### Registry row expansion
Every row should include:
- related signals;
- related systems;
- related agent pods;
- current maturity;
- last state transition;
- evidence count.

### Example row expansion
Project Manager:
```yaml
role: project_manager
stage: assisted_to_augmented
signals_this_week: 12
systems:
  - slack
  - jira
  - github
  - servicenow
  - roadmap
agent_pods:
  - signal_triage
  - dependency_mapper
  - stakeholder_update
last_actions:
  - 14_signals_triaged
  - 3_roadmap_items_created
  - 2_escalations_sent
evidence:
  count: 5
  status: traceable
```

---

## Page-to-page connection

### Home
Leadership announcement starts the flow.

### Role Hub
Shows what that announcement means for a specific human role.

### Portal
Shows live events flowing through.

### Explorer
Shows the memory and state of the organisation.

### Product
Explains Doolittles / Command Layer as the commercial solution.

---

## Demo scenario to wire first

### Scenario
Weekly Leadership Update: signal-driven operations.

### Flow
1. Leader writes weekly update.
2. Command Layer generates human summary and machine YAML.
3. Project Manager receives signal review action.
4. Product Lead receives roadmap update action.
5. Data Analyst receives model recalibration action.
6. Portal feed shows routed/actioned signals.
7. Explorer registry updates role states.
8. Evidence log records proof.

---

## Role Hub copy upgrade

Current copy:
"This is what an augmented role looks like. Signals arrive pre-triaged. Actions are structured. The agent handles the noise so you can focus on decisions."

Enhanced copy:
"This is what an augmented role looks like when the organisation speaks in signals. The Project Manager no longer searches twelve systems for context. Signals arrive ranked, duplicate work is removed, routine actions are handled by the pod, and every change is traceable."

---

## Required components

1. BeforeAfterRoleGrid
2. RoleSystemMap
3. AgentPodPanel
4. SignalImpactCard
5. EvidenceBadge
6. ToolActivationList
7. RegistryRowDrawer
8. AnnouncementRunner
9. ReadinessBoard

---

## Reality Ledger
status: PARTIAL
result: Role Hub and Live Signal Feed upgrade spec created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - UI not yet updated
  - no live data wiring
  - no evidence badge implementation
  - no Explorer click-through proof
next_action: Implement Role Hub before/after grid and Portal signal impact cards first.
elevation: Turns current T4H Command Layer pages into a coherent demo path from announcement to role change to system action to proof.
pressure_flags:
  - static demo risk
  - UI proof gap
  - data binding gap
score: 0.86
