# AI for Tradies Final Execution Bundle

## Task ID
ai-tradies-commercial-pack-v1-final

## Intent
Complete AI for Tradies from commercial architecture to deployable execution package covering agent runtime, Stripe, Supabase, API, site, telemetry, evidence, recovery, and repeatable cloning for future verticals.

## Execution Scope

### 1. Database
Execute `supabase_schema.sql` against the approved Supabase project.
Required evidence:
- db_result
- table count
- seed product rows
- reality ledger insert

### 2. Stripe
Create Stripe products and prices:
- AI Tradies Starter — AUD 99 monthly
- AI Tradies Growth — AUD 299 monthly
- AI Tradies Pro — AUD 799 monthly
- AI Tradies Enterprise — AUD 1999 monthly or quote-led

Required evidence:
- stripe_product_ids
- stripe_price_ids
- customer portal enabled
- webhook endpoint registered

### 3. API Layer
Implement `/ai-tradies/v1` endpoints:
- POST /intake
- POST /quote
- POST /book
- POST /followup
- GET /metrics
- POST /agent/run

Required evidence:
- deployed URL
- smoke test responses
- auth posture confirmed
- logs captured

### 4. Site Layer
Deploy customer-facing conversion site with:
- Home
- How It Works
- Pricing
- Industries
- Demo
- Contact

Required evidence:
- live URL
- screenshot or response code
- CTA route tested
- lead capture route tested

### 5. Agent Runtime
Register and route 120 agents using the architecture file.
Required evidence:
- agent registry seed count
- successful sample runs from Analyse, Write, Convert, Track, Govern, Loop
- cost controls active
- error recovery path active

### 6. Telemetry and Reality Ledger
Every execution must write:
- task_id
- intent
- execution
- output
- status
- evidence
- gaps
- next_action
- score

Required evidence:
- ledger rows
- statuses classified as REAL, PARTIAL, or BLOCKED

### 7. Clone Factory
Package this as the base vertical AI operating system template for:
- accountants
- property managers
- medical practices
- NDIS providers
- franchises
- other small businesses

Required evidence:
- clone variables documented
- minimum viable domain-change checklist
- reusable pricing template
- reusable agent mapping

## Acceptance Gates

PASS only if:
1. Supabase schema executed successfully.
2. Stripe test or live products exist.
3. API endpoint responds.
4. Site is reachable.
5. At least six agent domains have one successful run each.
6. Reality Ledger contains evidence rows.
7. Final receipt includes URLs, IDs, logs, and commit references.

## Reality Classification
Current state: PARTIAL
Reason: GitHub/PEN artefacts exist, but runtime execution is not proven in this session.

## Next Executor
MCP Bridge or authorised deployment runner.

## Required Closeout Format
Return:
- status
- result
- evidence
- gaps
- next_action
- elevation
- pressure_flags
- score
- ledger entry id
