# Handoff: Us / Signal Browser — Consent-First, Signal-First, Multi-Agent Personal Operating Layer

Status: READY FOR EXECUTION INTAKE
Owner requested by Troy: Chief of Staff, COO / COAX, COAX-C (/C for Chat, /CG for GPT)
Target repo: TML-4PM/the-pen
Classification: PARTIAL until site prototype, access audit, pricing model, product flow, and Reality Ledger proof are executed

---

## 1. Executive summary

This is not another browser comparison exercise. The work is to turn the comparison into a product spec, site draft, team allocation, and execution plan for **Us / Signal Browser**: a consent-first, signal-first, multi-agent operating layer for the web and connected places.

The product must show how a person shops, discovers, activates, receives, uses, and governs personalised activities, agents, snaps, spirals, and signal-based workflows.

The current browser market has strong general browsers and emerging AI browsers, but the open wedge is:

> Chrome organises pages. Comet answers questions. Atlas brings ChatGPT into the browser. Us governs human intent, consent, signal, agents, places, personalisation, and evidence across the browser.

The site must make that visible, understandable, and shoppable.

---

## 2. Product positioning

### Product name
Working name: **Us / Signal Browser**

Naming is flexible. Do not hardwire final labels. Terms like Us, Signal Browser, Signal Place, Snaps, Spiral, COAX, COAX-C, /C, /CG, Places, AgentSnaps, SuperSnaps must remain metadata-driven and renameable.

### Core claim
**Us is a consent-first, signal-first, multi-agent personal operating layer for the web.**

### Differentiation
| Dimension | Ordinary browsers | AI browsers | Us / Signal Browser |
|---|---|---|---|
| Primary unit | Page / tab | Question / assistant | Human signal / intent / consent / outcome |
| Consent | Settings and permissions | AI data controls | ConsentX actor-aware consent model |
| Agent model | Mostly none | Single assistant / agent | Multi-agent teams with roles, limits, receipts |
| Personalisation | Profile, cookies, history | Memory and context | Signal, preference, consent, context, risk, outcome |
| Evidence | Browser history | Chat or task history | Reality Ledger receipts for actions and decisions |
| Governance | Admin policy | Emerging controls | ConsentX + Reality Ledger + Command Centre |
| Safety | Browser security | Model safety | Prompt-injection aware, permission-separated agents |
| Workflow | Extensions | Agentic browsing | Command Centre orchestration, escalation, receipts |
| Places | Device/browser bounded | Browser bounded | Cross-surface places: browser, mobile, TV, car, clinic, classroom, office, home |

---

## 3. Required team allocation

### 3.1 Chief of Staff / COO / COAX
Role: Operating owner for this workstream.

Responsibilities:
- Confirm scope boundaries.
- Keep naming flexible and metadata-driven.
- Prevent browser-only thinking.
- Ensure output flows through the Pen, Command Centre, Reality Ledger, and site prototype.
- Coordinate specialist teams.
- Maintain executive summary, risks, and decisions.

Requested identity labels:
- COO: COAX
- GPT-side operator: COAX-C
- Shortcut aliases: /C for Chat, /CG for GPT

### 3.2 Documentation specialist
Role: Produce complete structured documentation comparable to the original browser comparison, but expanded into product, market, governance, and site requirements.

Deliverables:
- Browser comparison matrix.
- Feature matrix.
- Governance comparison.
- AI-agent risk matrix.
- Us / Signal Browser product spec.
- Glossary of flexible names.
- Site copy draft.
- FAQ.
- Out-of-the-box pack description.

### 3.3 Visuals specialist
Role: Turn the concept into a visible, usable site and product story.

Deliverables:
- Visual identity direction.
- Homepage wireframe.
- Product-page wireframe.
- Marketplace/shop wireframe.
- Activity detail-page wireframe.
- Consent panel mockup.
- Agent team visual.
- Signal/Place map visual.
- “What comes in the box” visual.

### 3.4 Places/access specialist
Role: Map all Places and required access surfaces.

Deliverables:
- Places registry.
- Browser/app/device access model.
- Connected systems checklist.
- Permissions model.
- Consent states.
- Place activation flow.
- Cross-surface escalation model.

Places must include at least:
- Browser
- Desktop wrapper
- Mobile app
- TV
- Car
- Glasses / wearable display
- Classroom
- Clinic / studio
- Office
- Home
- Public kiosk
- Event / conference
- Bike / IoT / edge surface

### 3.5 Technical architecture team
Role: Tie the browser shell, site, shop, activity catalogue, agents, consent, signal, and receipts together.

Deliverables:
- System architecture.
- Supabase schema.
- Agent registry schema.
- Activity catalogue schema.
- ConsentX schema link.
- Reality Ledger binding.
- Command Centre widgets.
- API contracts.
- Security model.
- Prompt-injection controls.
- Deployment path.

### 3.6 Marketing team
Role: Explain what it is in market language without losing the technical wedge.

Deliverables:
- Positioning statement.
- Landing-page copy.
- Buyer personas.
- Competitive narrative.
- Launch angles.
- Sales one-pager.
- Demo script.
- Founder narrative.

### 3.7 Product and pricing team
Role: Define packages, shopping flows, what comes out of the box, and how activities are purchased, loaded, activated, governed, and upgraded.

Deliverables:
- Product tiers.
- Activity catalogue model.
- Snap / Spiral / SuperSnap packaging.
- Pricing ladder.
- Trial model.
- Enterprise model.
- Marketplace / bundle rules.
- Out-of-the-box inclusions.
- Upgrade and usage-based pricing.

### 3.8 Runner / worker / integration team
Role: Convert spec into executable work packages.

Deliverables:
- GitHub issues.
- Bridge-ready payloads.
- Site implementation task list.
- Supabase migration task list.
- Asset list.
- QA checklist.
- Proof log.

---

## 4. Product architecture concept

### 4.1 Core layers
| Layer | Function |
|---|---|
| Browser shell | User-facing surface, tabs, pages, extensions, navigation |
| Signal layer | Captures human context, attention, intent, friction, preferences, safe behavioural signals |
| Consent layer | ConsentX handles actor-aware consent, permissions, expiration, delegation, fallback |
| Agent layer | Multi-agent teams operate across tasks, places, activities, and workflows |
| Activity layer | Catalogue of installable/unloadable activities, templates, bundles, workflows |
| Place layer | Metadata-driven context: browser, home, car, office, classroom, TV, clinic, etc. |
| Personalisation layer | Unique profile built from explicit preferences, consent, signal, outcomes, and history |
| Evidence layer | Reality Ledger logs action, decision, outcome, evidence, classification |
| Command layer | Command Centre views, controls, alerts, receipts, operator dashboards |
| Marketplace layer | Shop, bundles, pricing, purchase, fulfilment, subscriptions, trials |

### 4.2 Activity model
Activities are the unit the customer shops for, installs, activates, unloads, upgrades, and audits.

Examples:
- Meeting Focus Spiral
- Reading Buddy Snap
- Email Triage AgentSnap
- Shopping Consent Guard
- Family Safety Place Pack
- Classroom Support Pack
- Executive Research Spiral
- ADHD Task Scaffold
- Browser Risk Shield
- Parent Co-Watch Companion
- NDIS Evidence Capture Pack
- WorkFamilyAI Wellbeing Check-in
- MyNeuralSignal Attention Assist
- ConsentX Personal Data Boundary Pack

### 4.3 Snap / Spiral / bundle structure
| Product object | Meaning | Example |
|---|---|---|
| Snap | Small, installable capability | “Summarise this page with consent context” |
| AgentSnap | Snap with a named agent worker attached | “Research agent monitors this topic and creates receipts” |
| Spiral | Multi-step workflow that loops through signal, action, outcome, evidence | “Reading support: detect friction → intervene → measure outcome → log evidence” |
| SuperSnap | Bundled set of Snaps, agents, consent rules, and place configuration | “Family Web Safety Pack” |
| Place Pack | Activity bundle tied to a context or surface | “Classroom”, “Home”, “Car”, “TV”, “Office” |

---

## 5. Site requirements

### 5.1 Site purpose
The site must let a user understand, shop, preview, activate, and manage Us / Signal Browser capabilities.

It must answer:
- What is this?
- Why is it different from Chrome, Comet, Atlas, Brave, Edge, Safari, Firefox?
- What can I buy or activate?
- How do I choose activities?
- What comes out of the box?
- How does consent work?
- How do agents work?
- What signals are used?
- What is private, local, shared, enterprise, or auditable?
- How do Places change the experience?

### 5.2 Primary pages
| Page | Purpose |
|---|---|
| Home | High-level story, comparison, CTA |
| Compare | Browser comparison matrix and Us wedge |
| Shop / Activity Marketplace | Browse Snaps, Spirals, AgentSnaps, SuperSnaps, Place Packs |
| Activity detail | Explain one activity, inclusions, permissions, price, outputs |
| Places | Show browser, mobile, TV, car, classroom, clinic, office, home, wearable surfaces |
| Consent | Explain ConsentX, actor-aware consent, fallback states |
| Agents | Explain multi-agent teams, roles, receipts, limits |
| Signal | Explain signal-first personalisation and safe boundaries |
| What comes in the box | Default install, default activities, starter pack |
| Pricing | Personal, Family, Team, School, Provider, Enterprise |
| Demo | Interactive guided walkthrough |
| Governance | Reality Ledger, audit, evidence, admin controls |
| Developers / Partners | APIs, integration, activity publishing |
| Command Centre | Operator view, receipts, telemetry, alerts |

---

## 6. Shopping and activation flow

### 6.1 Customer flow
1. User lands on homepage.
2. User chooses a path: Personal, Family, Work, School, Provider, Enterprise.
3. Site recommends a starter bundle.
4. User reviews included activities.
5. User opens activity cards.
6. Each activity shows:
   - What it does.
   - Where it works.
   - What signals it uses.
   - What consent it needs.
   - What agents are involved.
   - What outputs are produced.
   - What evidence is logged.
   - What risks are controlled.
   - Price and upgrade options.
7. User adds bundle/activity to cart.
8. User completes checkout or starts trial.
9. User receives an activation pack.
10. Consent setup runs first.
11. Places setup runs second.
12. Agents are activated third.
13. Activity runs in preview/sandbox first.
14. User sees receipts and can promote to live.

### 6.2 Out-of-the-box starter pack
Every default install should include:
- Consent setup wizard.
- Personal signal profile starter.
- Place registry starter.
- Agent registry starter.
- Browser comparison explanation.
- Reality Ledger receipt viewer.
- Command Centre mini-panel.
- 3 free Snaps:
  - Page Summary Snap.
  - Safe Research Snap.
  - Consent Reminder Snap.
- 1 free Spiral:
  - Focus Spiral: intent → distraction check → action support → evidence.
- Demo agent team:
  - Researcher.
  - Scheduler.
  - Consent guardian.
  - Receipt writer.
- Upgrade catalogue.

### 6.3 What the user receives
| Item | Description |
|---|---|
| Browser / wrapper | The visible operating surface |
| Account / identity | User profile linked to consent and places |
| Consent profile | Actor-aware permissions and boundaries |
| Signal profile | Explicit preferences plus safe behavioural signal settings |
| Activity library | Installed Snaps, Spirals, AgentSnaps, SuperSnaps |
| Agent team | Configured workers with roles and limits |
| Receipts | Evidence trail of actions and decisions |
| Command view | Personal dashboard of activity, alerts, and proof |
| Marketplace access | Ability to add/remove/upgrade activities |

---

## 7. Pricing draft

### 7.1 Personal
- Free: browser, consent setup, starter Snaps, limited receipts.
- Plus: expanded Snaps, personal agent team, more Places, deeper signal profile.
- Pro: advanced Spirals, automation, cross-device Places, premium receipts.

### 7.2 Family
- Family plan: multi-person consent, child/parent views, co-watch, education packs, activity sharing.

### 7.3 Work / Team
- Team plan: shared activities, meeting agents, admin controls, workspace receipts, team Places.

### 7.4 School / Provider
- Education/NDIS packages: Reading Buddy, Outcome Ready, evidence capture, practitioner dashboards, reporting.

### 7.5 Enterprise
- Enterprise: policy controls, SSO, audit, compliance, private agents, custom Places, data residency, Command Centre integration.

### 7.6 Marketplace pricing
| Product object | Pricing pattern |
|---|---|
| Snap | One-off or small monthly add-on |
| AgentSnap | Monthly per worker/agent |
| Spiral | Monthly workflow subscription |
| SuperSnap | Bundled monthly package |
| Place Pack | Monthly per place/context |
| Enterprise Pack | Contract / annual |

---

## 8. Visual direction

### 8.1 Visual metaphor
The site should not look like a generic SaaS page. It should show:
- Human at centre.
- Signals orbiting the human.
- Consent gates around the human.
- Agents working in teams.
- Places as surfaces around the person.
- Activities as installable cards.
- Receipts as proof trails.

### 8.2 Key visuals
- Browser comparison wall.
- Signal-first architecture map.
- Consent-first activation flow.
- Multi-agent team card.
- Places constellation.
- Marketplace grid.
- Activity detail card.
- Out-of-the-box kit.
- Reality Ledger receipt timeline.
- Command Centre mini-dashboard.

---

## 9. Technical draft

### 9.1 Core data objects
- users
- identities
- places
- activities
- activity_versions
- installed_activities
- snaps
- spirals
- agents
- agent_roles
- agent_permissions
- consent_profiles
- consent_events
- signal_profiles
- signal_events
- receipts
- reality_ledger_entries
- product_tiers
- prices
- purchases
- subscriptions
- command_widgets

### 9.2 Required tables draft
```sql
create table if not exists public.signal_places (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  place_type text not null,
  description text,
  surface jsonb not null default '{}'::jsonb,
  consent_requirements jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.signal_activities (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  activity_type text not null check (activity_type in ('snap','agent_snap','spiral','super_snap','place_pack')),
  summary text not null,
  description text,
  included_outputs jsonb not null default '[]'::jsonb,
  required_places jsonb not null default '[]'::jsonb,
  required_signals jsonb not null default '[]'::jsonb,
  required_consent jsonb not null default '[]'::jsonb,
  default_agents jsonb not null default '[]'::jsonb,
  evidence_policy jsonb not null default '{}'::jsonb,
  price_model jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.signal_installed_activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  organisation_id uuid,
  activity_id uuid references public.signal_activities(id),
  status text not null default 'installed' check (status in ('preview','installed','active','paused','retired')),
  config jsonb not null default '{}'::jsonb,
  consent_state text not null default 'pending' check (consent_state in ('pending','full','session','none','revoked')),
  evidence_state text not null default 'partial' check (evidence_state in ('real','partial','pretend')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.signal_agent_registry (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  role text not null,
  scope jsonb not null default '{}'::jsonb,
  allowed_actions jsonb not null default '[]'::jsonb,
  blocked_actions jsonb not null default '[]'::jsonb,
  receipt_required boolean not null default true,
  consent_required boolean not null default true,
  active boolean not null default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.signal_activity_receipts (
  id uuid primary key default gen_random_uuid(),
  installed_activity_id uuid references public.signal_installed_activities(id),
  actor_type text not null,
  actor_id text,
  action text not null,
  input_summary text,
  output_summary text,
  consent_snapshot jsonb not null default '{}'::jsonb,
  signal_snapshot jsonb not null default '{}'::jsonb,
  evidence jsonb not null default '{}'::jsonb,
  classification text not null default 'partial' check (classification in ('real','partial','pretend')),
  created_at timestamptz default now()
);
```

### 9.3 API draft
| Endpoint | Purpose |
|---|---|
| GET /api/activities | List shoppable activities |
| GET /api/activities/:slug | Activity detail |
| POST /api/activities/:slug/install | Install to account/org |
| POST /api/activities/:slug/preview | Run sandbox preview |
| POST /api/consent/evaluate | Evaluate consent state |
| POST /api/agents/dispatch | Dispatch agent task |
| GET /api/receipts | Show receipts |
| POST /api/reality-ledger/bind | Bind action to evidence |
| GET /api/places | List supported Places |
| POST /api/places/activate | Activate a Place |

---

## 10. Risks and controls

| Risk | Control |
|---|---|
| Agentic browser prompt injection | Permission separation, untrusted page isolation, dry-run mode, receipts |
| Overcollection of personal data | Consent-first defaults, minimal signal capture, explicit use cases |
| Confusing product language | Site must use cards, examples, and “what comes in the box” |
| Naming hardwired too early | All names stored as metadata and slugs, not hardcoded logic |
| Browser clone trap | Position as operating layer + marketplace + governance, not browser skin |
| Marketplace sprawl | Activity taxonomy and quality gates |
| Enterprise trust gap | Reality Ledger, audit, admin policy, SSO roadmap |
| Consumer overwhelm | Starter packs by persona and Places |

---

## 11. Immediate execution tasks

### Chief of Staff / COAX
- Create master workstream and decision log.
- Assign specialist streams.
- Confirm naming remains flexible.
- Ensure this handoff becomes active in Command Centre.

### Documentation specialist
- Expand browser comparison into final document.
- Build complete feature matrix.
- Produce site copy for all pages.

### Visuals specialist
- Create homepage and marketplace wireframes.
- Create out-of-the-box kit visual.
- Create Places constellation visual.

### Places/access specialist
- Build Places registry.
- Map required permissions by Place.
- Define default Places starter set.

### Technical team
- Convert SQL draft into migration.
- Build activity catalogue seed file.
- Build API routes.
- Bind receipts to Reality Ledger.
- Create Command Centre widgets.

### Marketing team
- Produce launch positioning.
- Create buyer-persona paths.
- Write landing-page CTA copy.

### Product/pricing team
- Build pricing table.
- Define starter bundles.
- Define marketplace SKU model.

### Runner / worker
- Break work into GitHub issues.
- Add labels: signal-browser, consent-first, multi-agent, marketplace, site, pricing, docs, visuals, architecture.
- Route build tasks to dev execution lane.

---

## 12. Acceptance criteria

This is not complete until:
- Site draft exists and can be viewed.
- Marketplace/shop flow is visible.
- At least 12 starter activities are loaded.
- Each activity has consent, signal, agent, place, output, and receipt fields.
- Pricing draft exists.
- Out-of-the-box kit is documented and visible.
- Reality Ledger binding is designed.
- Command Centre widget spec exists.
- Browser comparison page exists.
- Names are metadata-driven and replaceable.

---

## 13. Required sign-off request

Request sign-off and operating intake from:
- Chief of Staff
- COO / COAX
- COAX-C
- /C for Chat
- /CG for GPT
- Product
- Marketing
- Technical Architecture
- Visuals
- Places/access
- Runner / worker

Sign-off focus:
- Are Snaps, Spirals, Places, ConsentX, Signal-first personalisation, multi-agent operation, and Reality Ledger all represented?
- Does the site explain what people can shop for?
- Does the out-of-the-box pack make sense?
- Can a user understand what they receive after purchase or activation?
- Can the system prove what happened?

---

## 14. Reality status

Current status: PARTIAL.

Real evidence:
- Strategic concept captured.
- Product differentiation captured.
- Team allocation captured.
- Draft spec captured in the Pen.

Missing before REAL:
- Running site or prototype.
- Supabase migration applied.
- Activity catalogue loaded.
- Command Centre widget live.
- Reality Ledger proof entries created.
- Pricing and Stripe flow wired.
- Visual assets created.
