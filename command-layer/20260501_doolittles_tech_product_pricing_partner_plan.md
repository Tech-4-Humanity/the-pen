# Doolittles — Tech, Product, Pricing and Partner Plan

## Core product truth
The magic is not machines talking.

The magic is everyone hearing the same thing, in their own language, at the same time — and acting instantly.

Doolittles is the layer that turns one command into coordinated human understanding, tool activation, agent execution and evidence-backed proof.

---

## 1. Product architecture

### Layer 1 — Command intake
Inputs:
- executive announcement;
- staff Slack request;
- incident signal;
- document/email/newsletter;
- system alert;
- workflow trigger.

Outputs:
- command_id;
- intent;
- risk class;
- affected roles;
- affected systems;
- human/system split.

### Layer 2 — Translation engine
Converts the command into:
- human-readable summaries;
- role-specific action lists;
- stakeholder preference formats;
- machine-readable YAML/API payloads;
- agent pod tasks.

### Layer 3 — Profile and registry layer
Stores:
- stakeholder communication preferences;
- role maps;
- tool capability maps;
- system risk gates;
- agent pods;
- evidence requirements.

### Layer 4 — Tool mesh / integration layer
Connects:
- Slack / Teams;
- ServiceNow / Jira;
- Salesforce;
- SAP stubs first, live later;
- Microsoft 365 / Entra;
- LMS;
- HRIS / payroll;
- GitHub / Vercel / Supabase;
- email;
- BI / HoloWall.

### Layer 5 — Agent pod layer
Pods perform translation, execution, validation and reporting.

Examples:
- Executive Translator Pod;
- People Ops Pod;
- Finance Control Pod;
- IT Optimisation Pod;
- ServiceNow Readiness Pod;
- Revenue Response Pod;
- Neuroinclusive Comms Pod;
- Evidence Logger Pod.

### Layer 6 — Proof and readiness layer
Every action must log:
- what was requested;
- who/what acted;
- systems touched;
- output created;
- evidence;
- rollback availability;
- state: queued / actioned / validated / complete / blocked.

---

## 2. Recommended technical stack

### Frontend
- Existing Lovable/Vercel app for product demo.
- Next.js/Vercel production path when hardened.

### Runtime/API
- Vercel serverless functions for lightweight demo and partner-facing API.
- AWS Lambda / MCP Bridge for deeper execution and existing T4H stack operations.

### Data
- Supabase Postgres for command, profile, registry, tool activation and evidence tables.
- pgvector or equivalent embedding layer for matching repeated commands, stakeholders and assets.

### AI orchestration
- Vercel AI Gateway can unify calls to multiple model providers through a single gateway; Vercel docs show Anthropic SDK use with `baseURL: https://ai-gateway.vercel.sh` and `AI_GATEWAY_API_KEY`.
- Model routing should support OpenAI, Claude, Gemini and other providers through the existing multi-LLM strategy.

### Scheduled jobs
- Vercel Cron for lightweight demo refresh jobs and daily scenario simulations.
- AWS EventBridge / bridge cron for production-grade orchestration where stronger control is required.

### Partner events
- Vercel marketplace/integration patterns include partner event callbacks for installation/resource changes. This is useful later if Doolittles becomes a Vercel-style installable integration.

---

## 3. Core schemas

### stakeholder_profiles
```sql
create table if not exists stakeholder_profiles (
  id uuid primary key default gen_random_uuid(),
  stakeholder_key text unique not null,
  name text,
  role text,
  preferred_language text default 'en',
  preferred_channel text default 'email',
  preferred_format text default 'summary',
  detail_level text default 'medium',
  accessibility_flags text[],
  meeting_load_preference text default 'minimise',
  metadata jsonb default '{}'::jsonb,
  updated_at timestamptz default now()
);
```

### command_events
```sql
create table if not exists command_events (
  id uuid primary key default gen_random_uuid(),
  command_key text unique not null,
  source text not null,
  raw_text text not null,
  intent text,
  risk_level text default 'medium',
  status text default 'received',
  created_at timestamptz default now()
);
```

### command_routes
```sql
create table if not exists command_routes (
  id uuid primary key default gen_random_uuid(),
  command_key text not null,
  target_type text not null,
  target_key text not null,
  output_format text,
  payload jsonb default '{}'::jsonb,
  status text default 'queued',
  evidence jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
```

### tool_capabilities
```sql
create table if not exists tool_capabilities (
  id uuid primary key default gen_random_uuid(),
  tool_key text unique not null,
  tool_name text not null,
  category text,
  can_read boolean default true,
  can_write boolean default false,
  can_execute boolean default false,
  risk_level text default 'medium',
  supported_actions text[],
  integration_status text default 'stub',
  metadata jsonb default '{}'::jsonb,
  updated_at timestamptz default now()
);
```

### tool_activation_events
```sql
create table if not exists tool_activation_events (
  id uuid primary key default gen_random_uuid(),
  command_key text,
  tool_key text not null,
  action text not null,
  status text default 'queued',
  proof jsonb default '{}'::jsonb,
  rollback_available boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### evidence_log
```sql
create table if not exists evidence_log (
  id uuid primary key default gen_random_uuid(),
  command_key text,
  evidence_type text not null,
  evidence_ref text,
  evidence jsonb default '{}'::jsonb,
  reality_state text default 'PARTIAL',
  created_at timestamptz default now()
);
```

---

## 4. Product packages

### Product 1 — Doolittles Lite: Message Translator
For teams starting small.

Capabilities:
- one announcement in;
- email, Slack and checklist variants out;
- stakeholder preference profiles;
- neuroinclusive formatting;
- evidence of delivery.

Target buyers:
- small teams;
- HR/comms;
- transformation leads;
- project teams.

### Product 2 — Doolittles Teams: Command + Workflow
Adds light system activation.

Capabilities:
- Slack/Teams output;
- Jira/ServiceNow-style ticket stubs;
- LMS/training drafts;
- readiness board;
- evidence log.

Target buyers:
- PMO;
- support teams;
- IT change teams;
- internal comms.

### Product 3 — Doolittles Enterprise: Tool Mesh
Adds enterprise tool orchestration.

Capabilities:
- Slack/Teams;
- ServiceNow/Jira;
- Salesforce;
- Microsoft 365;
- LMS;
- SAP/SFDC/HRIS stubs or connectors;
- approval gates;
- audit proof;
- partner integration model.

Target buyers:
- CIO;
- COO;
- CHRO;
- enterprise transformation;
- contact centre ops.

### Product 4 — Doolittles Neuroinclusive Workplace
A specialised package for accessibility and neurodiverse communication.

Capabilities:
- low-ambiguity instructions;
- preferred-channel delivery;
- concrete task checklists;
- sensory/social-load minimisation;
- manager scripts;
- support for ADHD/autism/dyslexia-friendly communication patterns.

Target buyers:
- HR;
- DEI;
- education;
- NDIS providers;
- large employers.

### Product 5 — Doolittles Partner Edition
For Slack, ServiceNow, Salesforce, SAP, Microsoft and consultancies.

Capabilities:
- partner-branded demo;
- integration blueprint;
- command-to-tool activation scenarios;
- vertical playbooks.

---

## 5. Pricing model

### Doolittles Lite
- Free / demo tier: 3 commands per month, 5 stakeholders, static outputs.
- Starter: AUD $49–$99/month, 50 commands, 25 stakeholders.

### Doolittles Teams
- AUD $299–$999/month per team.
- Includes Slack/Teams style outputs, workflow stubs, readiness board and evidence log.

### Doolittles Enterprise
- AUD $2,500–$15,000/month depending on seats, systems and connectors.
- Setup fee: AUD $10,000–$75,000 for integrations, stakeholder profiles and governance model.

### Doolittles Neuroinclusive Workplace
- AUD $5–$15/user/month or enterprise package.
- Strong fit as an add-on to WorkFamilyAI, AHC and HR transformation offerings.

### Partner Edition
- Co-sell / revenue share / fixed pilot.
- Pilot: AUD $25,000–$100,000.
- Enterprise partner integration: AUD $100,000+ depending on scope.

Pricing must be tested. These are initial packaging bands, not final market validation.

---

## 6. Partner strategy

### Slack / Teams
Role: communication rail.

Pitch:
"Doolittles turns Slack from a message channel into a personalised organisational command rail. One executive announcement becomes the right message, in the right format, for every worker."

Partner value:
- higher message relevance;
- less channel noise;
- stronger workflow adoption;
- neuroinclusive communication layer.

### ServiceNow
Role: change/support/work execution rail.

Pitch:
"ServiceNow should not receive tickets after confusion starts. It should receive structured change intent the moment leadership announces direction."

Partner value:
- pre-change support readiness;
- auto-created KBs/macros/tickets;
- reduced avoidable incidents;
- stronger change governance.

### Salesforce
Role: customer/revenue impact layer.

Pitch:
"Salesforce should hear strategic change early enough to prepare customer messaging, account risk and renewal actions before sales teams improvise."

Partner value:
- account impact mapping;
- revenue risk signals;
- customer comms generation;
- sales enablement.

### SAP
Role: enterprise core system.

Pitch:
"Doolittles does not start by rewiring SAP. It prepares the people, training, support and surrounding systems before SAP change hits users."

Partner value:
- adoption readiness;
- training and support prep;
- process impact mapping;
- less SAP change pain.

### Microsoft
Role: platform and adoption stack.

Pitch:
"Microsoft rollouts should not be meeting-driven. One command should create Teams messaging, Entra/IAM readiness, SharePoint docs, training and support workflows."

Partner value:
- Copilot adoption;
- M365 readiness;
- Teams integration;
- security/admin workflows.

### Atlassian / Jira / Confluence
Role: product/work/documentation layer.

Pitch:
"Leadership decisions become issues, docs, decision logs and release notes before teams manually rewrite the brief."

### Consultancies / SIs
Role: delivery channel.

Pitch:
"Use Doolittles to compress change discovery, comms, training and readiness work for transformation programs."

---

## 7. First demos to commercialise

### Demo 1 — Message Translator
Input: leadership update.
Output:
- email;
- Slack;
- French email;
- neuroinclusive checklist;
- manager script.

### Demo 2 — Microsoft Rollout
Input: "We are standardising on Microsoft next month."
Output:
- Slack comms;
- ServiceNow ticket/KB;
- LMS training;
- Entra readiness checklist;
- finance licence model;
- HoloWall readiness board.

### Demo 3 — ServiceNow Support Readiness
Input: "Reduce call centre complaints before launch."
Output:
- change ticket;
- KB article;
- macros;
- escalation rules;
- Slack alert;
- training note.

### Demo 4 — SAP Change Preparation
Input: "SAP process is changing next quarter."
Output:
- Slack update;
- training module;
- ServiceNow support flow;
- finance/procurement checklist;
- readiness board.

### Demo 5 — Marketing Campaign Sprint
Input: "We need a campaign by tomorrow."
Output:
- landing page copy;
- email;
- LinkedIn post;
- sales one-pager;
- CRM segment stub;
- internal launch note.

---

## 8. Revenue path

### Phase 1 — Demo-led lead capture
- interactive website;
- free message translator;
- downloadable output pack;
- newsletter/campaign examples.

### Phase 2 — Paid team pilots
- $5k–$25k pilot for one function;
- HR/comms/support/PMO easiest first.

### Phase 3 — Enterprise proof
- $25k–$100k command-layer pilot with 2–3 tools.

### Phase 4 — Partner co-sell
- Slack/ServiceNow/Salesforce/Microsoft/SAP ecosystem stories.

### Phase 5 — Platform
- multi-tenant Doolittles command registry;
- connector marketplace;
- role/pod templates;
- neuroinclusive comms library.

---

## 9. Public positioning

### Taglines
- Say it once. Everyone hears it correctly. Everything starts moving.
- Talk to the animals. Make the animals talk to each other.
- The command layer for humans, tools and agents.
- Stop managing change. Start broadcasting executable intent.
- One announcement. Every language. Every system.

### Short explainer
Doolittles turns one leadership command into personalised human messages, machine-readable system actions, agent tasks and proof. People hear it their way. Tools receive the payload they need. The organisation starts moving immediately.

---

## 10. Risks

- Overclaiming full SAP/ServiceNow automation before connectors exist.
- Using unvalidated stats publicly.
- Making the metaphor too cute for enterprise buyers.
- Triggering risky system changes without gates.
- Ignoring consent/accessibility boundaries.

Mitigation:
- stage adoption from message to workflow to system activation;
- use stubs before live integrations;
- show evidence and rollback;
- keep Doolittles playful but operationally serious.

---

## Reality Ledger
status: PARTIAL
result: Tech, product, pricing and partner plan created and stored in the-pen.
evidence: GitHub commit receipt for this file.
gaps:
  - pricing not market validated
  - partner outreach not sent
  - live integrations not wired
  - public stats need validation before use
next_action: Build Product/Pricing page and partner one-pagers; wire Demo 1 Message Translator first.
elevation: Converts Doolittles from narrative into commercial packaging and GTM structure.
pressure_flags:
  - pricing validation gap
  - integration gap
  - public claim validation gap
score: 0.86
