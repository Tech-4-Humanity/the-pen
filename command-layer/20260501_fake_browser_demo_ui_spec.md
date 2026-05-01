# Synal / Doolittles — Fake Browser Demo UI Spec

## Decision
A fake browser is the correct first implementation. The immediate goal is to prove UI, colour, interaction model, product story and demo flow — not to build a real browser runtime.

## Core reason
The market does not need a real browser to understand the value. It needs to see:
- the interface;
- the colours;
- the dock;
- the widgets;
- the command flow;
- proof that one command creates outputs.

A fake browser can sell the concept, guide the product, and reduce build risk.

---

## Product surface

### Name
Synal Demo Browser

### Purpose
A browser-shaped interactive prototype that shows:
- Doolittles speaking in tongues;
- personal agent dock;
- widgets/apps/extensions;
- tool activation cards;
- proof state;
- TV/HoloWall and car resize modes.

---

## Visual style

### Palette
- Background: deep navy / black glass.
- Primary signal: electric cyan.
- Secondary signal: teal / green.
- Alert: amber.
- Proof / success: green.
- Risk / blocked: red.
- Text: white / soft grey.
- Cards: translucent dark glass with thin glowing borders.

### Feel
- premium enterprise OS;
- cinematic but usable;
- not Chrome clone;
- not childish;
- Doolittles playful module inside serious Synal suite.

---

## Fake browser shell

### Top chrome
- Synal logo.
- Fake URL bar: synal://command/wk-2026-11
- Command state: Live / Demo / Proof.
- Buttons: Run Demo, Send to HoloWall, Car Mode.

### Left widget rail
- Snaps
- Threads
- Pulse
- Focus
- Flows
- Doolittles
- Proof
- Permissions

### Main canvas
Three tabbed scenes:
1. Speaking in Tongues
2. Agent Dock
3. Surfaces: Browser / TV / Car

### Right agent dock
Collapsed mode:
- Capture
- Ask
- Do
- Proof
- Approve

Expanded mode:
- Active Agents
- Approvals
- Receipts
- Memory / Permissions
- Tool Routes

### Bottom proof strip
- Sent
- Queued
- Created
- Validated
- Logged

---

## Demo 1 — Speaking in Tongues

### Input
"We are standardising on Microsoft next month. Prepare teams, systems, procurement, training, security and support."

### Human cards before YAML
- English executive summary.
- French recipe steps.
- Slack bullets.
- Arabic manager note.
- Hindi checklist.
- Neuroinclusive low-ambiguity version.

### YAML panel after human layer
```yaml
command: microsoft_standardisation
human_translation_complete: true
routes:
  slack: send_team_updates
  servicenow: create_rollout_ticket_and_kb
  lms: draft_training_module
  salesforce: flag_impacted_accounts
  sap: prepare_readiness_checklist
proof_required: true
```

### Output cards
- Slack message ready.
- ServiceNow ticket + KB created.
- LMS training outline drafted.
- Salesforce account-impact note created.
- SAP readiness checklist prepared.

---

## Demo 2 — Personal Agent Dock

### Collapsed state
Thin right rail with five icons:
- Capture
- Ask
- Do
- Proof
- Approve

### Expanded state
Cards:
- Doolittles Translator: 6 human outputs generated.
- Pulse: 4 signals active.
- Flows: 5 tool actions queued.
- Proof: 5 receipts logged.
- Permissions: 1 approval required.

### Demo button
"What are my agents doing?"

### Response
- 3 agents active.
- 2 actions completed.
- 1 approval required.
- 5 receipts logged.
- Option: Send to HoloWall.

---

## Demo 3 — Browser / TV / Car

### Browser mode
Full Synal browser layout with widgets, dock, cards and proof.

### TV/HoloWall mode
Same command enlarged:
- readiness score;
- active systems;
- blocked approvals;
- proof log;
- team broadcast.

### Car mode
Minimal safe view:
- command summary;
- urgent approval only;
- voice briefing;
- route/context update;
- no dense UI.

### Key line
The surface changes. The command thread does not.

---

## Interaction states

### Run Demo
Animates:
1. command received;
2. human translations generated;
3. YAML generated;
4. tool cards activated;
5. proof badges light up.

### Send to HoloWall
Switches layout to large dashboard mode.

### Car Mode
Switches to simplified mobility UI.

### Open Dock
Expands side agent dock.

### Signup
Button: Send me this output pack.
Fields:
- name;
- email;
- company;
- use case;
- product interest.

---

## Implementation approach

### Phase 1
Static HTML/CSS/JS prototype, no backend required.

### Phase 2
Add Supabase lead capture and demo event logging.

### Phase 3
Replace mocked tool cards with real Slack/webhook/GitHub/Supabase actions.

### Phase 4
Move selected patterns into actual browser extension / Synal runtime.

---

## Acceptance criteria

The fake browser demo is successful if a viewer can understand within 30 seconds:
1. Synal is a command surface.
2. Doolittles translates the command.
3. Humans get language/format-specific outputs before YAML.
4. Tools receive action payloads.
5. Proof is visible.
6. The same command can resize to browser, TV and car.

---

## Reality Ledger
status: PARTIAL
result: Fake browser demo UI spec created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - prototype not yet built
  - no visual image generated in this step
  - no lead capture wired
next_action: Build static Synal Demo Browser prototype and generate hero UI mock.
elevation: Converts Synal from big browser build into a shippable fake-browser demo that proves UI, colour, dock, widgets and surfaces.
pressure_flags:
  - prototype gap
  - visual gap
  - signup gap
score: 0.91
