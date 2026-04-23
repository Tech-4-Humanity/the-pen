# Say It Once — Live Interactive Demo UI Spec

## Purpose

Create a live, high-impact demo that shows how one human statement becomes role-specific, tool-native execution across a business.

This is not a chatbot demo.
This is an intent-to-execution demo.

## Demo promise

> Say it once. Watch the business stop guessing.

## Primary demo scenario

Input:

> We are starting Project Atlas on 30 March. Keep it lean. No new hires unless critical. Internal pilot first. I want risks visible by Friday.

## Screen structure

### 1. Hero input panel

Elements:
- Large text input
- Voice input placeholder
- Scenario presets
- Org size selector
- Tool environment selector

Presets:
- Project kickoff
- Budget freeze
- Staff change
- Incident response
- Product launch
- Supplier delay
- Family / household plan

### 2. Blast radius panel

After input, show calculated impact:

- Functions impacted
- Roles impacted
- People likely affected
- Systems touched
- Tools needing output
- Misalignment risk
- Manual rollout time
- Decision Drift Score

Example values:

- 7 / 10 functions impacted
- 63 roles affected
- 14 systems touched
- 9 tool outputs generated
- 41% would be missed by email-only rollout
- Drift risk: High
- Manual rollout estimate: 6–12 meetings / 3–10 days

### 3. What they heard panel

Split view:

CEO intent:
- Start controlled internal pilot
- Keep cost low
- Surface risk fast

Finance heard:
- Budget cap required
- Cost centre needed
- Hiring constraint affects forecast

HR heard:
- No new hires
- Internal capacity check required
- Burnout and redeployment risk

IT heard:
- Project board required
- Access and dependencies needed
- Pilot environment required

Ops heard:
- Process change
- Internal rollout plan
- Risk checkpoint by Friday

### 4. Tool output panel

Tabs:
- Excel / Budget
- Kanban / Delivery Board
- Email / Internal Comms
- HR / Workforce Note
- Risk Register
- Website / Customer Notice
- CRM / Customer Success Update
- Procurement / Supplier Action
- Executive Brief

Each tab should show a realistic rendered artefact, not placeholder text.

### 5. Simulation panel

Show two futures:

#### Without Say It Once
- Email sent to leadership team only
- HR receives no staffing constraint until week 2
- Finance sees budget impact after spend begins
- IT builds board without risk milestone
- Project drift appears after first checkpoint

#### With Say It Once
- All impacted teams receive role-specific outputs
- Tool artefacts generated immediately
- Risk checkpoint created
- Budget guardrails visible
- Execution starts same day

### 6. Drift replay panel

Timeline:

- T0: Decision captured
- T+5 min: Function outputs generated
- T+1 hr: Tool artefacts created
- T+24 hr: Missing acknowledgements flagged
- T+72 hr: Drift score updated

### 7. Action panel

Buttons:
- Run Decision Drift Scan
- Generate outputs
- Push to Synal Snaps
- Send to Command Centre
- Export evidence pack
- Book demo

## Visual tone

Quiet version:
- Clean enterprise dashboard
- White / dark neutral palette
- Boardroom friendly

Aggressive version:
- High contrast
- “Your business is guessing” headline
- Red/yellow drift warnings
- Before/after friction map

## Core interaction sequence

1. User enters decision
2. Demo calculates blast radius
3. Demo renders role interpretations
4. Demo generates tool outputs
5. Demo shows failure simulation
6. Demo offers Decision Drift Scan

## Demo data model

```json
{
  "decision_id": "sio_demo_project_atlas_20260330",
  "input": "We are starting Project Atlas on 30 March...",
  "context": {
    "org_size": "50-250",
    "sector": "SMB / services",
    "tools": ["Excel", "Kanban", "Email", "CRM", "HRIS"]
  },
  "blast_radius": {
    "functions_impacted": 7,
    "roles_impacted": 63,
    "systems_touched": 14,
    "tool_outputs": 9,
    "email_only_miss_rate_pct": 41,
    "drift_risk": "HIGH"
  },
  "outputs": {
    "finance": "budget_guardrail",
    "hr": "staffing_constraint_note",
    "it": "kanban_board",
    "ops": "pilot_rollout_plan",
    "risk": "risk_register"
  }
}
```

## Minimum demo artefacts required

- 1 realistic input scenario
- 5 role interpretations
- 5 tool-native outputs
- 1 drift score
- 1 before/after simulation
- 1 exportable scan report

## Conversion CTA

Primary:

> Run your Decision Drift Scan.

Secondary:

> Show us one decision that did not land properly. We will show you why.
