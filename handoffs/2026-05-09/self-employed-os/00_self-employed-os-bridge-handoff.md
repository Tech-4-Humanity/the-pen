# Self-Employed OS — Bridge Handoff

**Date:** 2026-05-09  
**Owner:** Tech 4 Humanity / AI for Tradies / Augmented Humanity Coach  
**Status:** PARTIAL → ready for Bridge execution  
**Canonical intent:** Expand AI for Tradies into a national self-employed and microbusiness operating system, with tradies as the first vertical wedge.

---

## 1. Executive thesis

AI for Tradies is too narrow if it only solves quoting, invoices, and admin. The real opportunity is the owner-operator economy: sole traders, self-employed workers, microbusinesses, mobile service providers, care providers, creators, consultants, and compliance-heavy local businesses.

The product should become:

> **Self-Employed OS — the AI back office, qualification tracker, compliance coach, learning buddy, marketing engine, and cashflow assistant for people who work for themselves.**

AI for Tradies remains the first vertical brand because the pain is obvious, regulation is high, and the language is simple. The platform underneath must be reusable across many industries.

---

## 2. Market scope

### Primary market

- Self-employed / non-employing businesses
- Sole traders
- Microbusinesses with 1–4 staff
- Family businesses
- Mobile services
- Licence-heavy operators
- Compliance-heavy operators
- Side hustles moving to full-time work
- New migrants starting service businesses
- Apprentices moving toward self-employment

### Strategic frame

Large companies have HR, finance, legal, compliance, learning, marketing, procurement, admin, IT, and operations.

Self-employed people have themselves.

AI becomes the missing department stack.

---

## 3. Brand architecture

### Umbrella platform

**Self-Employed OS**

### Marketable promise

> Get qualified. Stay compliant. Win work. Get paid. Grow without burning out.

### Vertical brands

1. AI for Tradies
2. AI for Care Providers
3. AI for Beauty & Wellness
4. AI for Mobile Services
5. AI for Creators & Consultants
6. AI for Hospitality Operators
7. AI for Rural & Farm Services
8. AI for Local Retail
9. AI for Professional Services
10. AI for Side Hustles

### Relationship to existing ecosystem

| Existing asset | Role in Self-Employed OS |
|---|---|
| AI for Tradies | First vertical wedge |
| Outcome Ready | Readiness scoring, evidence packs, provider compliance |
| Augmented Humanity Coach | Business uplift and coaching layer |
| WorkFamilyAI | Agent orchestration and workforce model |
| HoloOrg | Role-to-agent mapping and operating model |
| ConsentX | Consent, data sharing, client permission layer |
| MyNeuralSignal | Burnout, cognitive load, work rhythm signals |
| Reading Buddy | Learning, certification, trade literacy, microlearning |
| Reality Ledger | Evidence classification and proof of progress |
| Command Centre | Portfolio telemetry and operator dashboard |

---

## 4. Product layers

### Layer 1 — Start

- ABN checklist
- Business name checklist
- GST threshold guidance
- Bank account setup checklist
- Insurance checklist
- Starter website
- Local listing setup
- Starter quote and invoice templates
- First customer checklist

### Layer 2 — Learn

- Apprenticeship pathway finder
- Qualification checklist
- RTO/course matcher
- Trade/business literacy support
- Microlearning
- Safety training explainer
- Certificate upload
- Evidence portfolio

### Layer 3 — Certify

- Licence/ticket requirement matrix
- Application document checklist
- Supervised work evidence tracker
- State-by-state licence guidance
- Renewal calendar
- CPD tracker
- Insurance renewal tracker
- Specialist tickets tracker

### Layer 4 — Operate

- AI receptionist
- Quote builder
- Invoice generator
- Job scheduler
- SMS/email follow-up
- Customer CRM
- Photo-to-job-note
- Supplier price tracker
- Expense capture
- Payment chasing

### Layer 5 — Comply

- SWMS generator
- Risk assessment assistant
- Before/after evidence pack
- Customer signoff
- Incident log
- Audit pack
- Regulator checklist
- Document expiry alerts

### Layer 6 — Grow

- Google Business Profile helper
- Review request engine
- Local SEO content generator
- Referral engine
- Seasonal campaign generator
- Social media post generator
- Lead scoring
- Grant/tender finder
- Subcontractor network readiness

### Layer 7 — Scale

- First hire checklist
- Apprentice onboarding
- Subcontractor onboarding
- SOP generator
- Role-to-agent mapping
- Job profitability dashboard
- Route optimisation
- Multi-operator handoff
- Franchise/playbook readiness

---

## 5. Vertical pack matrix

| Vertical | Pain | Must-have modules | First paid offer |
|---|---|---|---|
| Tradies | Licensing, quoting, job admin, evidence | Licence Wallet, Quote Assistant, SWMS, Job Evidence | Tradie Back Office Starter |
| Care Providers | NDIS complexity, documentation, compliance | Participant notes, audit pack, provider readiness, consent | Provider Readiness Pack |
| Beauty & Wellness | Bookings, reviews, repeat visits, local marketing | Booking assistant, review engine, client memory | Local Growth Pack |
| Mobile Services | Route/time chaos, quotes, photos, invoices | Scheduler, route/job notes, invoice chasing | Mobile Operator Pack |
| Creators & Consultants | Offers, proposals, lead flow, delivery evidence | Proposal builder, CRM, content engine | Solo Expert Pack |
| Hospitality | Rostering, food safety, local demand | Compliance calendar, menu/social engine | Small Venue Pack |
| Rural/Farm Services | Distance, equipment, seasonal work | Job planner, asset log, quote templates | Rural Operator Pack |
| Local Retail | Inventory, promotions, customer retention | Campaign engine, stock notes, loyalty | Local Retail Pack |
| Professional Services | Admin, proposals, reminders, compliance | Proposal/admin/copilot, document templates | Professional Back Office Pack |
| Side Hustles | Setup uncertainty, first customer, pricing | Starter passport, landing page, offer builder | Side Hustle Launch Pack |

---

## 6. MVP offer suite

### Offer 1 — Self-Employed Starter Passport

**Price target:** AUD $49–$149 one-off  
**Purpose:** Help a person move from idea/side hustle to legitimate operating baseline.

Includes:
- ABN/GST/business setup checklist
- Insurance prompt checklist
- Local listing checklist
- Starter website copy
- Quote/invoice templates
- First 10 customer actions
- Basic AI assistant prompts

### Offer 2 — AI Back Office Lite

**Price target:** AUD $29–$79/month  
**Purpose:** Replace 5–10 hours/month of admin for a sole operator.

Includes:
- Quote generator
- Invoice follow-up scripts
- Customer memory
- Review requests
- Weekly admin checklist
- Basic CRM
- Expense capture prompts

### Offer 3 — Licence & Renewal Wallet

**Price target:** AUD $9–$29/month or bundled  
**Purpose:** Track qualifications, certificates, tickets, CPD, insurance, and renewals.

Includes:
- Certificate storage
- Expiry calendar
- Renewal alerts
- Evidence pack
- State/industry notes
- CPD tracker

### Offer 4 — Vertical Pro Pack

**Price target:** AUD $299–$999 setup + $99–$299/month  
**Purpose:** Industry-specific operating pack.

Includes:
- Landing page
- Quote/invoice workflows
- Compliance templates
- Review engine
- Email/SMS scripts
- Job evidence pack
- Reporting dashboard

### Offer 5 — Done-With-You / AHC Upgrade

**Price target:** AUD $2,500–$12,000  
**Purpose:** Higher-touch business transformation for operators ready to scale.

Includes:
- Business audit
- AI workflow setup
- SOP creation
- Agent mapping
- Local marketing setup
- Compliance evidence pack
- Team/subcontractor onboarding

---

## 7. Required data tables

The Bridge should create or map these into Supabase/Command Centre if not already present.

### `operator_segments`

Tracks vertical markets.

Core fields:
- id
- name
- slug
- parent_category
- audience_type
- regulatory_intensity
- admin_intensity
- ai_uplift_score
- market_priority
- first_offer
- status

### `operator_personas`

Tracks persona variants.

Core fields:
- id
- segment_id
- persona_name
- role_type
- business_stage
- pains
- desired_outcomes
- objections
- buying_trigger
- pricing_sensitivity

### `qualification_requirements`

Tracks education, certification, licences, tickets, CPD.

Core fields:
- id
- segment_id
- trade_or_role
- jurisdiction
- qualification_name
- qualification_type
- initial_or_renewal
- renewal_period_months
- evidence_required
- source_url
- confidence_state
- reviewed_at

### `operator_modules`

Reusable product modules.

Core fields:
- id
- module_name
- module_slug
- layer
- description
- input_required
- output_generated
- reusable_across_segments
- monetisation_role
- evidence_required

### `operator_offers`

Commercial offers and bundles.

Core fields:
- id
- offer_name
- slug
- target_segment
- price_low
- price_high
- billing_model
- included_modules
- delivery_mode
- stripe_product_id
- landing_page_url
- status

### `operator_workflows`

Repeatable automations.

Core fields:
- id
- workflow_name
- segment_id
- trigger_event
- steps_json
- systems_involved
- human_gate_required
- output_asset
- evidence_event
- status

### `operator_evidence_events`

Reality Ledger binding.

Core fields:
- id
- operator_id
- segment_id
- module_id
- event_type
- evidence_type
- evidence_url
- classification
- confidence_score
- created_at

---

## 8. Build tasks for Bridge

### Task A — Create canonical product registry entries

Create product registry entries for:
- Self-Employed OS
- AI for Tradies
- AI for Care Providers
- AI for Beauty & Wellness
- AI for Mobile Services
- AI for Creators & Consultants

### Task B — Create Supabase schema migration

Generate SQL migration for the tables listed above. Bind to Reality Ledger where available.

### Task C — Seed first segment records

Seed at least 10 vertical segments:
- Tradies
- Care Providers
- Beauty & Wellness
- Mobile Services
- Creators & Consultants
- Hospitality Operators
- Rural & Farm Services
- Local Retail
- Professional Services
- Side Hustles

### Task D — Seed reusable modules

Seed at least 25 reusable modules across Start, Learn, Certify, Operate, Comply, Grow, Scale.

### Task E — Generate first landing page copy

Create landing page copy for:
- Self-Employed OS umbrella
- AI for Tradies vertical
- AI Back Office Lite offer
- Licence & Renewal Wallet offer

### Task F — Generate pricing model

Create Stripe-ready product/price mapping. Do not charge or create live products unless authorised by environment policy. Prepare payloads.

### Task G — Create Command Centre widget spec

Widget name: `self_employed_os_portfolio_status`

Shows:
- segments
- offers
- modules
- evidence state
- launch readiness
- revenue status
- next action

### Task H — Create Reality Ledger record

Classify as PARTIAL until schema migration, seeded records, and deploy receipts exist.

---

## 9. Bridge invocation envelope

```json
{
  "action": "invoke_function",
  "function_name": "troy-sql-executor",
  "invocation_type": "request_response",
  "payload": {
    "task_id": "SEO-SELFEMP-OS-20260509-001",
    "intent": "Create Self-Employed OS schema, seed vertical packs, module registry, offers, evidence bindings, and Command Centre widget spec.",
    "execution_mode": "dry_run_then_execute_if_safe",
    "source": "ChatGPT bridge handoff",
    "required_outputs": [
      "sql_migration",
      "seed_data",
      "product_registry_entries",
      "offer_registry_entries",
      "command_centre_widget_spec",
      "reality_ledger_record",
      "execution_receipt"
    ],
    "human_gate_required": false,
    "reality_state_target": "PARTIAL_TO_REAL_WITH_EVIDENCE"
  },
  "metadata": {
    "request_id": "SEO-SELFEMP-OS-20260509-001",
    "source": "the-pen",
    "timestamp_utc": "2026-05-08T19:00:00Z",
    "auth_context": "existing_bridge_runtime"
  }
}
```

---

## 10. Acceptance criteria

This job is not REAL until all of the following exist:

1. GitHub receipt for handoff bundle.
2. SQL migration generated.
3. Seed records generated or inserted.
4. Product/offer registry updated.
5. Reality Ledger record written.
6. Command Centre widget spec created.
7. Evidence links returned.
8. Bridge receipt captured.

---

## 11. Reality Ledger

| Field | Value |
|---|---|
| task_id | SEO-SELFEMP-OS-20260509-001 |
| intent | Expand AI for Tradies into Self-Employed OS and hand off to Bridge |
| execution | GitHub handoff bundle prepared |
| output | Product architecture, schema requirements, offer suite, bridge envelope |
| status | PARTIAL |
| evidence | GitHub commit receipt required after write |
| gaps | Actual bridge execution, Supabase migration, seed insertion, runtime widget, Stripe payload creation |
| next_action | Bridge executes schema + seeds + registry + widget |
| elevation | Converts small-business concept into reusable operating-system product architecture |
| pressure_flags | Avoid generic SaaS; anchor each vertical to compliance, cashflow, customer acquisition, and renewal burden |
| score | 9.2 |

---

## 12. Immediate commercial wedge

The strongest wedge is not “AI productivity.”

It is:

> **Your AI Back Office — for people who work for themselves.**

First market campaign:

- “You are not buying AI. You are hiring the back office you could never afford.”
- “Get qualified. Stay compliant. Win work. Get paid.”
- “Run your one-person business like a proper company.”

First lead magnet:

> **Free Self-Employed Business Readiness Check**

Outputs:
- score
- missing setup items
- renewal risks
- admin burden estimate
- recommended AI pack
- upsell path

---

## 13. Notes for Bridge / Pen

Do not reduce this back into tradies only. Tradies are the first vertical wedge. The platform is broader: small business, sole traders, microbusinesses, and self-employed workers.

Prioritise reusable tables, reusable modules, reusable offer logic, and evidence-bound execution.
