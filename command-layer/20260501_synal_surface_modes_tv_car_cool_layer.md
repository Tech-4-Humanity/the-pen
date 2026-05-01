# Synal — Surface Modes: TV, Car, Room and Cool Layer

## Decision
The TV, car and other surfaces are not the first product dependency, but they are strategically valuable and visually powerful. They should be kept as demo modes inside the fake browser prototype and later become Synal upsell surfaces.

## Core rule
Build the fake browser first, but show TV and car modes from day one.

The TV/car/room layer proves that Synal is not just a website or browser. It is a command surface that follows the user and adapts to context.

---

## Surface hierarchy

### 1. Browser mode — command and work
Primary detailed surface.
Shows:
- command input;
- Doolittles translations;
- YAML;
- widgets;
- agent dock;
- proof panel.

### 2. TV / HoloWall mode — shared state
Room-scale visibility surface.
Shows:
- readiness board;
- active command;
- teams/systems moving;
- blockers;
- proof state;
- broadcast message.

### 3. Car mode — mobility and minimal action
Low-cognitive-load surface.
Shows:
- voice summary;
- urgent approvals only;
- route/schedule updates;
- safety-aware controls;
- no dense dashboards.

### 4. Room / office mode — place-based coordination
Context surface for meetings, clinics, studios, classrooms and offices.
Shows:
- meeting mode;
- signage;
- action board;
- room devices;
- who/what is waiting.

### 5. Mobile mode — personal interrupt and approval layer
Shows:
- short action list;
- approvals;
- alerts;
- personal instructions;
- neuroinclusive checklists.

---

## What makes the surfaces cool

The same command_id persists across every device.

Example:
```yaml
command_id: synal-demo-001
command: optimise_90_days
surfaces:
  browser:
    mode: full_control
  holowall:
    mode: shared_readiness
  car:
    mode: safe_mobility
  mobile:
    mode: personal_approval
```

The product line:
The surface changes. The command thread does not.

---

## TV / HoloWall demo scene

### Visual
Large wall display in office / home / boardroom.

### Content
- Headline: 90-Day Impact Plan Activated.
- Readiness: 82%.
- Systems moving: Slack, ServiceNow, Salesforce, LMS, Finance.
- Blockers: 1 approval required.
- Proof: 14 outputs logged.
- Next action: Finance approval.

### Copy
The HoloWall is where the organisation sees itself moving.

---

## Car demo scene

### Visual
Car dashboard with Synal mobility mode.

### Content
- Command: Optimise next 90 days.
- Voice briefing: two-minute summary ready.
- Route: adjusted for meeting and traffic.
- Approvals: one urgent approval only.
- Focus: no non-urgent alerts while driving.

### Copy
The car is not a dashboard. It is the safe version of the command thread.

---

## Mobile demo scene

### Visual
Phone receives personalised action.

### Content
- Mary: short Slack-style list.
- Johnny: French recipe steps by email.
- Troy: approval card.
- Neuroinclusive user: low-ambiguity checklist.

### Copy
Each person receives the same intent in the way they can act on.

---

## Fake browser implementation

### Buttons in prototype
- Browser Mode
- HoloWall Mode
- Car Mode
- Mobile Preview

### Behaviour
Clicking each button changes layout and density, not the underlying command.

### Required UI principle
Same command. Different affordance.

Browser = detailed work.
TV = shared visibility.
Car = safe summary.
Mobile = interrupt/approval.
Room = place-based coordination.

---

## What not to build yet
Do not build real TV, car, mobile or hardware integrations now.

Build:
- responsive UI modes;
- static demo states;
- strong visuals;
- same command_id across modes;
- proof badges.

---

## Reality Ledger
status: PARTIAL
result: TV/car/surface mode strategy added to Synal fake browser plan and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - surface visuals not generated
  - responsive demo not built
  - no real device integration
next_action: Include Browser/HoloWall/Car/Mobile mode toggle in the Synal fake browser prototype.
elevation: Keeps the cool multi-surface story while preserving the fake-browser-first execution path.
pressure_flags:
  - scope creep risk
  - visual proof gap
  - implementation gap
score: 0.90
