# Doolittles / Synal — Three Demo Pack

## Purpose
Define the three demos Troy wants to see next:
1. Doolittles speaking in tongues: one product demo showing Troy / AHC speaking the same intent in multiple languages and formats before YAML.
2. Synal personal agent dock: option 4 from the Future Digital Interaction Surfaces paper, a personal agent dock that sits inside any browser and can resize onto TV/HoloWall.
3. Browser to TV and car: the same Synal surface moving from browser to TV and car.

## Source alignment
Future Digital Interaction Surfaces identified Option 4, the Personal Agent Dock, as the synthesis pattern to back if building now. The dock is the missing operating layer across browser, phone, wearables, home devices and future spatial systems: dashboard for what agents know, what they can do, what they are doing now, and what they need approval for.

---

## Demo 1 — Doolittles Speaking in Tongues

### Goal
Show the product magic before machine YAML: one intent becomes understandable to every human in their own language, format and role.

### Visual
Troy / AHC at centre. Around him: language cards and role cards.

### Input command
"We are standardising on Microsoft next month. Prepare teams, systems, procurement, training, security and support."

### Outputs
Human language cards:
- English executive summary.
- French recipe steps for Johnny.
- Spanish staff update.
- Arabic manager note.
- Hindi checklist.
- Japanese concise task list.
- Neuroinclusive low-ambiguity version.
- Slack short bullets for Mary.

### Then machine YAML
Only after the human meaning is visible, show the machine payload:

```yaml
command: microsoft_standardisation
intent: prepare_rollout
human_translation_complete: true
routes:
  slack:
    action: send_team_updates
  servicenow:
    action: create_rollout_ticket_and_kb
  lms:
    action: draft_training_module
  salesforce:
    action: flag_impacted_accounts
  sap:
    action: prepare_readiness_checklist
proof:
  required: true
```

### Proof panel
- 8 human translations generated.
- 5 tool routes prepared.
- 1 proof pack created.
- Status: demo-ready.

### Demo copy
The YAML is not the first translation. People are.

---

## Demo 2 — Synal Personal Agent Dock

### Goal
Show Option 4 as a product: a personal agent dock that sits inside any browser, follows the user, and expands to TV/HoloWall when needed.

### Positioning
A thin personal control layer for agents, trust, permissions, receipts, memory and handoff.

### Dock layout
Collapsed dock:
- small vertical side rail;
- always available inside Chrome/Edge/Safari/any browser;
- quick buttons: Capture, Ask, Do, Proof, Approve.

Expanded dock:
- agent cards;
- command input;
- recent signals;
- approvals;
- receipts;
- memory/permission controls.

TV/HoloWall mode:
- same dock becomes a large readiness/control wall;
- shows organisation state, active commands, blocked approvals, proof and readiness score.

### Agent dock modules
- Doolittles: translation.
- Pulse: live signals.
- Snaps: capture.
- Threads: context.
- Flows: action chains.
- Focus: distraction control.
- Proof: receipts/logs.
- Permissions: memory and tool access.

### Demo command
"Show me what my agents are doing and what needs approval."

### Output
- 3 agents active.
- 2 tasks completed.
- 1 approval required.
- 5 receipts logged.
- 1 cross-device handoff available: Open on HoloWall.

### Demo copy
This is not a new tab. It is your agent control surface.

---

## Demo 3 — Browser to TV to Car

### Goal
Show the same Synal surface and command thread moving across devices.

### Scenario
Troy starts in the browser, throws the command to TV/HoloWall for the room, then continues in the car.

### Browser state
Synal browser shows:
- command: optimise next 90 days;
- widgets: Snaps, Threads, Pulse, Focus, Flows, Doolittles;
- tool activation cards;
- proof badges.

### TV/HoloWall state
Same command, resized for shared view:
- readiness board;
- active systems;
- blocked approvals;
- proof log;
- team broadcast.

### Car state
Same command, mobility version:
- route optimised;
- next meeting summary;
- urgent approvals only;
- voice briefing;
- focus mode.

### Demo copy
The surface changes. The command thread does not.

---

## Combined product story

Doolittles proves translation.
Synal proves surface continuity.
Command Layer proves action and evidence.
HoloWall proves shared state.

## What to build as visuals

### Visual 1
Doolittles Speaking in Tongues: Troy/AHC with language cards before YAML.

### Visual 2
Synal Personal Agent Dock in a normal browser: collapsed and expanded states.

### Visual 3
Same Synal command shown on laptop, TV/HoloWall and car dashboard.

## What to build as UI demo

### Page /demo/doolittles-speaking
- command input;
- language selector;
- generated human cards;
- YAML appears after human translation;
- proof panel;
- signup capture.

### Page /demo/agent-dock
- simulated browser page;
- side dock collapsed/expanded;
- agent cards;
- receipts;
- permissions;
- button: Send to HoloWall.

### Page /demo/synal-surfaces
- laptop, TV and car mock panels;
- same command_id across all;
- device-specific outputs;
- proof state.

---

## Build priority
1. Doolittles Speaking in Tongues visual/demo.
2. Personal Agent Dock visual/demo.
3. Browser-to-TV-to-Car surface continuity visual/demo.

## Reality Ledger
status: PARTIAL
result: Three-demo pack created and stored in the-pen.
evidence: GitHub commit receipt for this file; uploaded Future Digital Interaction Surfaces document used as source for Option 4.
gaps:
  - visuals not generated
  - demos not implemented
  - signup capture not wired
  - no browser extension yet
next_action: Generate three hero visuals and implement the Doolittles Speaking in Tongues demo first.
elevation: Converts the broad Synal/Doolittles vision into three demonstrable product moments.
pressure_flags:
  - scope sequencing risk
  - visual proof gap
  - implementation gap
score: 0.89
