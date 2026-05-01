# Doolittles — Two-Way Change Requests

## Core idea
Doolittles is not only top-down executive command propagation. It is two-way.

People can talk back to the system. Tools can talk back to people. Agent pods can propose changes. The organisation becomes a living feedback loop.

## Product line
Drop in. Change things.

## What the Portal is showing now
Staff connect via Slack-style channels to:
- flag signals;
- suggest routing changes;
- request configuration changes;
- steer the system;
- see bot confirmations;
- create traceable change records.

This is the human-to-system side of Doolittles.

---

## Two-way model

### Direction 1 — Top-down command
Executive says:
"We are standardising on Microsoft next month."

Doolittles sends:
- personalised messages to people;
- machine-readable commands to tools;
- tasks to agent pods;
- proof to HoloWall.

### Direction 2 — Bottom-up system change request
Staff member says:
"Can we add a new routing rule for compliance? Legal is receiving the wrong signals."

Doolittles does:
- parses intent;
- checks authority;
- tests impact;
- updates routing rule;
- logs evidence;
- notifies affected channels;
- updates HoloWall.

---

## Example: Slack request to system change

### Human message
Sarah K. in #t4h-signals:
"Can we add a new routing rule for the compliance team? They're getting signals meant for legal."

### Doolittles interpretation
```yaml
request_type: routing_change
source_channel: t4h-signals
requester: sarah_k
intent: split_legal_and_compliance_signals
risk_level: medium
affected_systems:
  - signal_router
  - compliance_queue
  - legal_queue
  - audit_log
human_gate:
  required: false
  reason: non_destructive_internal_routing_change
```

### System action
```yaml
actions:
  - create_routing_rule:
      from: legal_compliance_combined
      split_by: entity_type
      targets:
        legal: legal_queue
        compliance: compliance_queue
  - notify:
      channel: t4h-signals
      message: Routing rule created. Compliance signals now split between Legal and Compliance based on entity type.
  - log:
      table: audit_log
      status: complete
```

---

## Example: threshold tuning

### Human message
James R. in #t4h-changes:
"The PM agent is escalating too many low-priority items. Can we raise the threshold?"

### Doolittles interpretation
```yaml
request_type: threshold_change
system: pm_agent
intent: reduce_low_priority_escalations
risk_level: low
affected_systems:
  - pm_agent
  - escalation_queue
  - audit_log
human_gate:
  required: false
  reason: reversible_preference_class_change
```

### System action
```yaml
actions:
  - update_config:
      system: pm_agent
      parameter: auto_resolve_threshold
      value: 3
  - notify:
      channel: t4h-changes
      message: Threshold updated. PM agent will now auto-resolve items below priority 3.
  - log:
      table: audit_log
      status: complete
```

---

## Why two-way matters
Most enterprise systems are command-and-control. They broadcast change downwards but do not listen well upwards.

Doolittles listens both ways:
- executives can command the organisation;
- staff can steer the system;
- tools can ask for clarification;
- agents can recommend better routes;
- evidence is logged either way.

## What changes

### Before
Staff sees a broken routing rule, tells a manager, manager raises a ticket, IT triages, someone changes config later.

### After
Staff says it in Slack. Doolittles understands, checks whether it is allowed, applies the change, and logs the proof.

---

## Guardrails
Two-way does not mean uncontrolled.

Every request is classified:

| Request class | Example | Human required? | Action |
|---|---|---|---|
| Preference | change channel, format, routing threshold | No | apply and log |
| Internal reversible config | routing, threshold, display rule | Usually no | apply, test, rollback available |
| Business process change | support workflow, approval flow | Sometimes | simulate, then apply |
| Cost/spend | buy licences, increase subscription | Yes above threshold | gate |
| Legal/identity/destructive | delete, sign, issue credential | Yes | gate |
| Physical-world action | turn off TVs, unlock doors, desk changes | Gate by policy | staged execution |

---

## Website section

### Title
Drop In, Change Things

### Subtitle
Doolittles is not just a broadcast layer. Staff can shape the system through the channels they already use.

### Visual layout
Left: Slack-style conversation.
Right: AHC / Doolittles team image.
Bottom: How it works.

### Copy
- #t4h-signals — flag new signals, suggest routing changes, or ask why something escalated.
- #t4h-changes — request configuration changes. The bot applies allowed changes and logs them to the audit trail.
- Every change is traceable. Staff shape the system. The system learns from staff.

---

## Product implication
This makes Doolittles more than a command translator. It becomes an organisational steering surface.

Top-down: leadership broadcasts intent.
Bottom-up: people and tools continuously improve the system.
Sideways: tools notify other tools.

## Reality Ledger
status: PARTIAL
result: Two-way change request model created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - live Slack integration not wired
  - audit table not proven
  - routing change engine not live
  - UI needs to show before/after and evidence log
next_action: Add two-way change request demo to Portal page and wire sample audit log data.
elevation: Converts Doolittles from top-down announcement engine into living organisational feedback loop.
pressure_flags:
  - integration gap
  - governance gap
  - proof gap
score: 0.84
