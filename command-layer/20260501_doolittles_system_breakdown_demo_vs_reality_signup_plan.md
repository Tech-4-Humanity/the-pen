# Doolittles / Signal Capture — System Breakdown, Demo vs Reality, Signup Plan

## Purpose
Break the system into buildable pieces without letting the big Synal/Suite story block the first product proof.

We need two lanes:
1. Demo lane: show the promise quickly.
2. Reality lane: build the working loop one product at a time.

## Core product split

### What we sell first
Doolittles: Talk to the Animals / Talk to the Tools.

First promise:
One announcement becomes the right messages, tasks, docs, training and proof.

### What we build underneath
Command Layer:
- command intake;
- pre-YAML human translation;
- machine YAML;
- routing;
- tool activation;
- proof/evidence.

### What becomes upsell later
Synal:
- browser;
- widgets;
- mobile;
- HoloWall;
- car/room/device surfaces;
- full communication suite.

---

## 1. System breakdown

### A. Capture
What enters the system:
- executive announcement;
- staff request;
- Slack message;
- document/email/newsletter;
- web tab/snap;
- signal button click;
- system alert.

First demo version:
- text box: enter announcement;
- button: run Doolittles.

Reality version:
- command_events table;
- signal_events table;
- browser extension/Synal later;
- Slack/email hooks later.

### B. Human translation / pre-YAML
Before machine execution, create human meaning.

Outputs:
- English summary;
- French/Spanish/etc version;
- Slack bullets;
- manager talking points;
- neuroinclusive checklist;
- role-specific action list.

First demo version:
- generate 5 fixed output cards.

Reality version:
- stakeholder_profiles;
- language profile;
- translation quality score;
- review gates for sensitive content.

### C. Machine translation / YAML
Convert intent into tool/action payloads.

Outputs:
- route YAML;
- tool payloads;
- agent pod tasks.

First demo version:
- static YAML generated from scenario.

Reality version:
- command_routes;
- tool_capabilities;
- action schema;
- safety gates.

### D. Tool activation
Make tools appear to move.

Outputs:
- Slack-style message;
- ServiceNow-style ticket/KB;
- LMS training stub;
- Salesforce account-impact stub;
- SAP readiness stub;
- proof panel.

First demo version:
- mocked cards with timestamps and statuses.

Reality version:
- start with email + GitHub/Supabase write-back;
- then Slack webhook;
- then ServiceNow/Jira integration;
- then LMS/Salesforce/SAP stubs or real connectors.

### E. Proof
No proof, no trust.

Outputs:
- Sent;
- Queued;
- Created;
- Validated;
- Logged;
- Reality state: REAL / PARTIAL / BLOCKED.

First demo version:
- proof panel created from fake/demo state.

Reality version:
- evidence_log;
- audit records;
- receipt files;
- replay/rollback later.

### F. Signup and monetisation
Convert interest into leads and paid pilots.

Outputs:
- free demo capture;
- email waitlist;
- product tier selection;
- pilot request;
- partner interest form.

First demo version:
- form: name, email, company, use case, product interest.

Reality version:
- Supabase leads table;
- Stripe later;
- CRM later;
- automated follow-up pack.

---

## 2. First demo to ship

### Demo name
Doolittles Message-to-Action Demo

### Scenario
"We are standardising on Microsoft next month. Prepare teams, systems, procurement, training, security and support."

### User flow
1. User lands on page.
2. User sees product line: Talk to the tools. Make the tools talk to each other.
3. User clicks Run Demo.
4. Page shows:
   - original announcement;
   - human translations;
   - machine YAML;
   - tool activations;
   - proof panel.
5. User enters email to receive the output pack or request pilot.

### Demo outputs
Human cards:
- Executive summary.
- Manager script.
- Slack short message.
- French recipe steps.
- Neuroinclusive checklist.

Tool cards:
- Slack: team message ready.
- ServiceNow: rollout ticket + KB draft.
- LMS: training module outline.
- Salesforce: impacted account note.
- SAP: readiness checklist.
- Microsoft/Entra: identity readiness plan.

Proof panel:
- 6 messages generated;
- 5 tools activated;
- 3 training/support artefacts created;
- evidence logged;
- status: demo proof.

---

## 3. First reality loop to build

### Reality loop name
Signal Button → Output → Proof

### Why
This is smaller than full Synal and proves the engine.

### Flow
1. User clicks Signal Button: "This matters."
2. System records signal.
3. User selects intent: remember / act / share / automate.
4. System creates structured signal object.
5. System generates next action.
6. System logs proof.

### Minimum build
- one landing page;
- one signal capture form;
- one Supabase table;
- one output card;
- one evidence log row;
- one signup capture.

### Required tables
```sql
create table if not exists leads (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  name text,
  company text,
  interest text,
  source text default 'doolittles_demo',
  created_at timestamptz default now()
);
```

```sql
create table if not exists captured_signals (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid,
  source text default 'demo',
  raw_text text not null,
  intent text,
  priority text,
  output jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
```

```sql
create table if not exists evidence_log (
  id uuid primary key default gen_random_uuid(),
  signal_id uuid,
  evidence_type text,
  evidence jsonb default '{}'::jsonb,
  reality_state text default 'PARTIAL',
  created_at timestamptz default now()
);
```

---

## 4. Signup build-out

### Signup types
1. Try the demo.
2. Get the output pack.
3. Join waitlist.
4. Request team pilot.
5. Partner with us.
6. Neuroinclusive workplace pilot.

### Fields
- name;
- email;
- company;
- role;
- tool stack: Slack / Teams / ServiceNow / Salesforce / Microsoft / SAP / Other;
- pain point;
- package interest;
- urgency;
- consent checkbox.

### Lead routing
- Lite/demo leads → nurture email.
- Team pilot leads → schedule call.
- Enterprise leads → qualification pack.
- Partner leads → partner one-pager.
- Neuroinclusive leads → accessibility/product pack.

---

## 5. Product pages to create

### Page 1 — Doolittles Home
Hero:
Talk to the tools. Make the tools talk to each other.

CTA:
Run the demo.

### Page 2 — How it works
1. Capture command.
2. Translate to people.
3. Translate to systems.
4. Activate tools.
5. Prove what happened.

### Page 3 — Demo
Interactive Microsoft rollout scenario.

### Page 4 — Products
- Lite;
- Teams;
- Enterprise;
- Neuroinclusive;
- Partner Edition.

### Page 5 — Signup / Pilot
Lead capture and pilot request.

---

## 6. Product tiers for signup page

### Doolittles Lite
For teams that want better messages.

Includes:
- message translation;
- Slack/email/checklist outputs;
- 5 stakeholder profiles;
- demo proof panel.

### Doolittles Teams
For teams that want messages to become work.

Includes:
- workflow stubs;
- support/training docs;
- readiness board;
- evidence log.

### Doolittles Enterprise
For organisations that want decisions connected to systems.

Includes:
- tool mesh;
- approval gates;
- custom profiles;
- audit/evidence;
- integration roadmap.

### Synal Suite
Upsell only.

Includes:
- browser;
- widgets;
- mobile;
- HoloWall;
- multi-surface command layer.

---

## 7. What not to build yet

Do not build first:
- full Synal browser;
- real SAP integration;
- car/TV/home hardware;
- full agent marketplace;
- every widget;
- 30 SKUs at once.

These are later expansion layers.

---

## 8. Immediate execution batch

### Build batch 1
1. Doolittles landing page.
2. Interactive Microsoft rollout demo.
3. Human translation cards.
4. Machine YAML panel.
5. Tool activation cards.
6. Proof panel.
7. Signup form.
8. Leads table.
9. Captured signals table.
10. Evidence log table.

### Build batch 2
1. Signal Button mini-product.
2. Proof-of-Done widget.
3. Website Critic demo.
4. Offer Builder demo.
5. ServiceNow-style ticket generator.

### Build batch 3
1. Stripe payments.
2. Product tiers.
3. Partner one-pagers.
4. Slack webhook.
5. CRM export.

---

## Reality Ledger
status: PARTIAL
result: Doolittles system breakdown, demo/reality split and signup plan created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - landing page not implemented
  - signup tables not deployed
  - demo not live
  - proof panel not wired
next_action: Build Doolittles landing page + Microsoft rollout demo + signup capture as the first public proof.
elevation: Breaks the system into shippable first product, reality loop and later Synal upsell.
pressure_flags:
  - scope creep risk
  - live proof gap
  - signup/revenue gap
score: 0.89
