# Holo-Org Build Handoff — Pricing Page + Product Catalog

## Source
- `handoffs/RPT_HoloOrg_Commercial_Launch_Matrix_Gap_Addendum_20260424.csv`
- Commit carrying source CSV: `cbe5785700061ed182d8da45c76a45797a20a7f4`

## Build Objective
Turn Holo-Org into a launchable commercial system by building the pricing page, catalog structure, CTA routing, and product placement from the commercial matrix.

## Core Commercial Split

### HoloOrg Patterns
Free/open reference architecture, pattern language, lead magnet, trust layer.

### Holo-Org Commercial
Paid platform, role diagnostics, deployment, governance, runtime, transformation, managed operations, and ecosystem modules.

## Pages to Build / Repair

### 1. Pricing Page
Route suggestion: `/pricing`

Sections:
1. Hero: "From random AI tools to governed AI workforces."
2. Pricing ladder:
   - Starter Agents / Packs: `$29–$499`
   - Small Team Packs: `$149–$1.5k/mo`
   - 100-Agent Org Pilot: `$15k–$75k setup + $2.5k–$15k/mo`
   - 1,000-Agent Org Transformation: `$150k–$750k setup + $20k–$100k/mo`
   - 10,000-Agent Holarchy: `$750k–$5M+ setup + $100k–$500k+/mo`
3. BYO Stack section:
   - BYO LLM
   - BYO Cloud
   - BYO Data
   - BYO Automation Stack
4. Governance modules:
   - ConsentX Governance
   - LifeGraph Provenance
   - MyNeuralSignal Interface
5. CTA routing:
   - Buy / start for lower tiers
   - Book design session for Mid
   - Talk to sales / RFP for 10x Mid

### 2. Product Catalog
Route suggestion: `/product-catalog`

Filter dimensions:
- Offer type: pattern, pack, agent, platform, service, deployment, managed ops, governance module
- Tier: residential, small, mid, 10x mid
- Deployment model: self-serve, assisted, managed, private, BYO
- Channel: web, partner, outbound, procurement
- Proof status: none, partial, real
- Launch status: live, hidden, broken, ready, blocked

Catalog groups:
- Free Patterns
- Diagnostics
- Starter Packs
- Small Team Packs
- Platform Modules
- Deployment Packages
- Governance Add-ons
- Managed Operations
- Enterprise Transformation

### 3. Start Here Flow
Route suggestion: `/start-here`

First question:
"What are you trying to build?"

Options:
- I want to test AI with a small task → Starter Pack
- I want a team workflow improved → Small Team Pack
- I want to map roles to agents → Role Analyzer
- I want a 100-agent pilot → 100-Agent Org Pilot
- I want a division transformed → 1,000-Agent Transformation
- I want enterprise/government-scale deployment → 10,000-Agent Holarchy

### 4. Role Analyzer
Route suggestion: `/role-analyzer`

Make this the wedge product:
- Free quick diagnostic
- Paid deeper assessment
- Output: recommended agent map + package
- Route output to starter pack / 100-agent pilot / transformation proposal

### 5. Enterprise / Government Page
Route suggestion: `/enterprise`

Lead with:
- Humans in command
- Consent gates
- Audit trails
- Approval chains
- Escalation logic
- Secure/private deployment
- Evidence and governance

Do not present 10,000-agent holarchy as normal SaaS.

## CTA Rules

Every CTA must resolve to one of:
- Buy now
- Start package
- Book design session
- Talk to sales
- Request RFP / procurement conversation
- Download / view free patterns

Do not leave `#` placeholder CTAs.

## Pricing Anchors

| Offer | Public Price Anchor | CTA |
|---|---:|---|
| Open HoloOrg Patterns | Free | View Patterns |
| Role Analyzer | Free–$5k | Run Diagnostic |
| Starter Agent / Pack | $29–$499 | Buy Now |
| Small Team Pack | $149–$1.5k/mo | Start Package |
| 100-Agent Org Pilot | $15k–$75k setup + $2.5k–$15k/mo | Book Design Session |
| 1,000-Agent Org Transformation | $150k–$750k setup + $20k–$100k/mo | Talk to Sales |
| 10,000-Agent Holarchy | $750k–$5M+ setup + $100k–$500k+/mo | Enterprise Proposal |
| ConsentX Governance | $500–$15k/mo | Add Governance |
| LifeGraph Provenance | $500–$20k/mo | Add Provenance |
| MyNeuralSignal Interface | Custom | Discuss Secure Deployment |

## Required Messaging

Use this positioning:

> Holo-Org helps organisations move from random AI tools to governed AI workforces.

Support points:
- Start with open HoloOrg Patterns.
- Diagnose roles before buying tools.
- Deploy a governed pilot before scaling.
- Keep humans in command.
- Price governance, consent, escalation, audit, and evidence as premium layers.

## Evidence Rules

Do not publish major deployment claims unless classified:
- REAL
- PARTIAL
- PRETEND / internal only

Add evidence placeholders where needed.

## Build Acceptance Criteria

- Pricing page exists and uses the corrected commercial ladder.
- Product catalog separates free/open patterns from paid offers.
- Role Analyzer is treated as the wedge product.
- Every CTA routes somewhere real; no `#` placeholders.
- BYO section exists.
- Governance modules exist as paid attach options.
- Enterprise page avoids cheap SaaS framing.
- CSV remains the canonical handoff source.

## Keys / HITL Boundary
No keys required for static page/catalog build.
Keys or human approval required only for:
- Stripe production wiring
- private environment variables
- production deployment writes
- destructive changes
- publishing legally sensitive case study claims
