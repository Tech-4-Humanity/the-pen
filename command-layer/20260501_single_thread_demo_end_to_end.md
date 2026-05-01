# T4H Command Layer — Single Thread Demo End-to-End

## Purpose
Make the product feel real by carrying one event across every page: Home, Role Hub, Portal, Explorer and proof state.

The demo must stop showing disconnected sections. It should show one leadership directive moving through the organisation.

## Demo thread
Command ID: wk-2026-11
Scenario: Weekly Leadership Update — signal-driven operations

Leader statement:
"Team — this week we're accelerating our shift toward signal-driven operations. The economic signals from Q1 are clear: our market position requires faster response cycles. Project managers should review their signal feeds and flag outliers. Product leads should update roadmaps with the latest signal intelligence. Data team: recalibrate discovery models for the new quarter. We're not adding tools. We're rewiring how decisions reach the people and agents that act on them."

---

## Page flow

### 1. Home — Intent
Home shows the human channel and the machine broadcast side by side.

Required third panel: Systems Activated.

```text
Systems activated:
✔ Project Manager signal feed updated
✔ Product Lead roadmap action queued
✔ Data Analyst recalibration queued
✔ Portal feed updated
✔ Explorer registry state updated
✔ Evidence log created
```

### 2. Role Hub — Interpretation
Project Manager page shows what this directive means for the PM role.

Replace generic metrics with event-specific outcomes:

```text
This directive changed your work:
✔ 12 signals routed to PM feed
✔ 3 economic signals marked high priority
✔ 1 vendor contract renewal flagged
✔ 1 stakeholder comms spike escalated
✔ 1 vendor comparison completed by agent
✔ Evidence logged to wk-2026-11
```

### 3. Portal — Execution
Portal shows the live feed for the same event.

Feed cards:

1. Leadership directive received — wk-2026-11
2. Machine broadcast generated — roles routed
3. PM agent triaged 14 signals — 11 auto-resolved, 3 surfaced
4. Product Lead roadmap updated — 3 items queued
5. Data Analyst recalibration queued — discovery model update pending
6. Evidence log written — traceable and replayable

### 4. Explorer — Memory
Explorer registry rows should reflect the event:

Project Manager:
- stage: Assisted → Augmented
- related command: wk-2026-11
- related signals: SIG-0312, SIG-0311, SIG-0309
- systems: Slack, Jira, Roadmap, ServiceNow, Reality Ledger
- evidence count: 5

Product Lead:
- related command: wk-2026-11
- action: update_roadmap
- items queued: 3

Data Analyst:
- related command: wk-2026-11
- action: recalibrate_models
- priority: critical

### 5. Proof / Ledger
Every page should expose proof state:

```yaml
proof:
  command_id: wk-2026-11
  status: actioned
  evidence:
    - machine_broadcast_generated
    - role_routes_created
    - pm_feed_updated
    - roadmap_items_queued
    - model_recalibration_queued
    - registry_state_updated
```

---

## Data object

```yaml
command:
  id: wk-2026-11
  type: leadership_directive
  priority: high
  human_summary: >
    We are accelerating signal-driven operations this week. Project managers review feeds, product leads update roadmaps, and data analysts recalibrate discovery models.
  machine_broadcast:
    routes:
      - role: project_manager
        action: review_signal_feed
        deadline: 2026-03-15
        signals: [economic, outlier]
        systems: [slack, jira, roadmap, servicenow]
        pod: pm_signal_triage_pod
      - role: product_lead
        action: update_roadmap
        source: signal_intelligence_q1
        systems: [roadmap, jira, slack]
        pod: product_impact_pod
      - role: data_analyst
        action: recalibrate_models
        scope: discovery_engine
        priority: critical
        systems: [warehouse, notebooks, model_registry]
        pod: data_recalibration_pod
  evidence_required: true
```

---

## UI components to build

1. AnnouncementRunner
2. SystemsActivatedPanel
3. RoleImpactSummary
4. SignalImpactCard
5. EvidenceBadge
6. RegistryLinkDrawer
7. EventThreadFilter
8. ProofPanel

---

## Before/after for Project Manager

| Dimension | Before | After |
|---|---|---|
| Signal discovery | Searches 12+ sources manually | Receives routed signal feed |
| Prioritisation | Decides priority from context fragments | Signals arrive ranked with source and deadline |
| Stakeholder updates | Writes updates manually | Agent drafts updates and flags only decision points |
| Risk tracking | Risk appears late | Outliers surface in real time |
| Tool updates | Jira, roadmap and Slack updated separately | Agent pod updates linked systems and logs proof |
| Evidence | Status hidden in messages | Evidence badge and command ID available |

---

## Acceptance criteria

The demo is not complete unless:
- the same command ID appears on Home, Role Hub, Portal and Explorer;
- at least one feed item links to one registry entity;
- at least one role page shows actions from the same command;
- proof panel shows evidence created;
- generic metrics are replaced with named outcomes.

---

## Reality Ledger
status: PARTIAL
result: Single-thread end-to-end demo spec created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - UI not yet implemented
  - data object not wired
  - feed-to-registry click-through not live
  - proof panel not live
next_action: Implement wk-2026-11 as the canonical demo event across Home, Role Hub, Portal and Explorer.
elevation: Converts static pages into a single coherent proof journey.
pressure_flags:
  - demo coherence gap
  - UI wiring gap
  - evidence gap
score: 0.88
