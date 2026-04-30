# Solo CTO Control Layer — Priorities, Pricing Model, and Handoff Queue

**Date:** 2026-04-30  
**Owner:** Troy Latter / Tech 4 Humanity  
**Destination:** PEN → Symbio DEV → Synapse PROD  
**Status:** PARTIAL until build/deploy/prove receipts exist  
**Reality Ledger rule:** Nothing is REAL until execution evidence is attached.

---

## 1. Executive Position

The modern solo CTO, founder, or lean operator does not need enterprise monitoring noise. They need a low-noise, self-healing control layer that turns ordinary outages into silent recoveries, and only escalates when recovery fails.

The old model says: watch dashboards, raise tickets, assign humans, run war rooms.  
The new model says: detect, decide, remediate, validate, log, and escalate only when the system cannot heal itself.

The core doctrine is simple:

> The operator is not notified of failure. The operator is notified of failed recovery.

This can become a product line for Outcome Ready, Augmented Humanity Coach, Tradie AI, and the broader T4H ecosystem. It is not just IT monitoring. It is an operating model for any small organisation running digital, AI, customer, operational, or revenue-critical processes without an enterprise team.

---

## 2. Old Org vs New Org

| Dimension | Old Enterprise Org | New Lean / Solo Org | What Is Still The Same |
|---|---|---|---|
| Operating assumption | Many people, many teams, layered approvals | One accountable operator, automation-first | Someone still owns the outcome |
| Monitoring | Dashboards, alerts, tickets, war rooms | Exceptions, summaries, failed-recovery alerts | Systems still fail |
| Speed | Minutes to hours | Seconds to minutes | Bad shortcuts still surface later |
| Failure response | Human investigation first | Automation remediation first | Root causes still matter |
| Reporting | SLA/SLO reports, postmortems, CAB reviews | Outcome logs, recovery receipts, monthly summary | Evidence is still required |
| Risk | Slow escalation, bureaucracy, alert fatigue | Fast amplification, wrong automation, silent degradation | Design quality determines survival |
| Governance | Heavy process | Lightweight rules, evidence, approval only for unsafe actions | Accountability does not disappear |

---

## 3. The Strategic Loop

### Today

Most founders and small businesses now run on fragile stacks they barely understand: Vercel, Supabase, Stripe, AWS, Zapier, Make, CRMs, LLM APIs, website forms, booking systems, social platforms, and custom glue code. They do not want Datadog-style dashboards. They want to know when revenue, customers, reputation, or operations are at risk.

### Tomorrow

The problem becomes larger because AI agents and automation will increase the number of moving parts. More workflows will run without people watching. That is good for speed but bad for hidden failure. A broken automation can burn budget, spam customers, corrupt data, or quietly stop delivering value.

### The Gotcha

Automation removes delay. It does not remove design debt. If the business has no retry policy, fallback path, circuit breaker, validation test, escalation rule, or cost guardrail, the system does not become resilient. It becomes faster at failing.

---

## 4. Product Thesis

Build a reusable **Solo CTO Control Layer** that sits across small business and lean operating environments.

It monitors what matters, remediates what is safe, records what happened, and escalates only when action is genuinely needed.

This is useful in IT and outside IT:

| Domain | Example Failure | Control Layer Response |
|---|---|---|
| SaaS / website | Site down, lead form broken | Check endpoint, retry deployment, open fallback capture form, notify only if unresolved |
| AI workflow | Agent stalls, LLM API fails | Retry, switch provider, lower model tier, log degraded state |
| Retail / trades | Booking request missed | Re-send, create CRM task, SMS operator only if not captured |
| Finance / Stripe | Payment link failing | Validate checkout, switch to invoice/payment fallback, escalate revenue risk |
| Operations | Daily report not sent | Re-run job, regenerate report, send recovery summary |
| Customer support | Inbox or intake queue stuck | Re-poll, re-label, route to fallback mailbox |
| Compliance / governance | Evidence missing | Mark PARTIAL, request proof, prevent FINAL/REAL claim |

---

## 5. Priority Stack

### P0 — Revenue and customer trust

These are protected first because they directly affect money, customer confidence, and reputation.

- Public websites and landing pages
- Lead capture forms
- Stripe payment and checkout flows
- Booking/intake flows
- Customer email routes
- Critical demos used in sales conversations

### P1 — Operating continuity

These keep the business moving.

- Daily/weekly reports
- Agent queues
- CRM handoffs
- Supabase jobs
- GitHub/Bridge handoff receipts
- Campaign workflows

### P2 — Intelligence and improvement

These help the business improve but do not justify waking a human.

- Analytics freshness
- Content pipeline completion
- Research jobs
- Social post generation
- Non-critical dashboards

### P3 — Nice-to-have / background hygiene

These should recover quietly and appear in weekly summaries only.

- Non-critical archive jobs
- Screenshot generation
- Document formatting
- Internal-only helper tools
- Experimental agents

---

## 6. Alert Doctrine

| Event Type | Human Notification? | Automation Action | Evidence Required |
|---|---:|---|---|
| Transient failure recovered | No | Retry, validate, log | Recovery receipt |
| Repeated failure recovered | Optional daily summary | Retry, backoff, validate | Pattern count and cause |
| Failed recovery on P0/P1 | Yes | Escalate with context | Root cause, attempts, suggested action |
| Cost anomaly | Yes if above threshold | Pause/throttle non-critical jobs | Spend delta, impacted systems |
| Data integrity risk | Yes | Stop writes, mark GATED | Before/after evidence |
| Unsafe/destructive action | Yes | Require approval or dry-run only | Risk classification |

---

## 7. Package Architecture

### Layer 1 — Signal Detection

- Uptime checks
- CloudWatch anomaly detection
- Supabase health probes
- Stripe checkout probe
- Vercel deployment probe
- Agent queue heartbeat
- Form submission synthetic tests

### Layer 2 — Decision Rules

- EventBridge routing
- Business criticality map
- Autonomy tier map
- Safe vs gated action registry
- Cost threshold rules

### Layer 3 — Remediation Playbooks

- Restart worker
- Re-run failed job
- Requeue message
- Switch model/provider
- Open fallback form
- Throttle non-critical jobs
- Restore last known good deployment
- Create GitHub issue if unresolved

### Layer 4 — Validation

- Endpoint returns 200
- Form writes to Supabase
- Stripe checkout link opens
- Queue depth decreases
- Report file/email exists
- GitHub receipt exists

### Layer 5 — Escalation

Escalation must include:

- What failed
- Business impact
- What was tried
- What recovered or did not recover
- What action is recommended
- Whether this is REAL, PARTIAL, PRETEND, GATED, or BLOCKED

---

## 8. Pricing Model

Use a ladder that works for solo founders, small businesses, agencies, and enterprise-lite teams.

| Tier | Target Customer | Monthly Price AUD ex GST | Setup Price AUD ex GST | Core Promise |
|---|---|---:|---:|---|
| Signal Check | Solo founder, micro business | $99 | $499 | Know if the basics are alive |
| Silent Recovery | Founder/operator with active revenue | $299 | $1,500 | Auto-fix common failures before notifying |
| Control Layer | Small business with multiple workflows | $799 | $4,500 | Business-aware monitoring, recovery, and escalation |
| Managed Resilience | Agency, provider, multi-site operator | $1,995 | $12,000 | Weekly review, pattern hardening, custom playbooks |
| Fractional Solo CTO | Growth business without CTO | $4,500–$9,500 | $20,000+ | CTO-grade operating control without enterprise noise |
| Enterprise-Lite Control Plane | Regulated SME / serious operator | $15,000+ | $50,000+ | Governance, evidence, audit, recovery, board reporting |

### Add-ons

| Add-on | Price AUD ex GST | Notes |
|---|---:|---|
| Extra monitored site/app | $49–$199/month | Based on criticality |
| Extra remediation playbook | $500–$2,500 one-off | Safe actions only by default |
| Stripe/payment flow probe | $199/month | Revenue critical |
| Agent queue monitoring | $299/month | Required for AI-heavy workflows |
| Reality Ledger binding | $499/month | Required for proof claims |
| Weekly COO report | $399/month | Plain-English operating summary |
| Board pack | $2,500/quarter | For serious clients |

### Pricing Doctrine

- Do not sell dashboards.
- Sell fewer interruptions.
- Sell recovered failures.
- Sell proof.
- Sell confidence that the business is not silently broken.

---

## 9. Commercial Positioning

### One-line offer

Self-healing operating control for founders and small organisations that cannot afford enterprise noise or silent failure.

### Buyer pain

- “I do not know what is broken until a customer tells me.”
- “My website, forms, payments, and automations are stitched together.”
- “I cannot watch dashboards all day.”
- “I need to know only when it matters.”
- “I want the system to fix itself first.”

### Outcome Ready positioning

Outcome Ready can sell this as resilience for education, NDIS, providers, small operators, and AI-powered service delivery. The client does not buy infrastructure. They buy continuity of outcomes.

### Augmented Humanity Coach positioning

AHC can sell this as the operational nervous system for AI-enabled organisations. Agents are not useful if no one knows when they stall, drift, overspend, or silently degrade.

### Tradie AI positioning

Tradies do not need monitoring dashboards. They need missed jobs, failed quote forms, payment issues, booking failures, and customer message failures to be caught and fixed.

---

## 10. Handoff Queue

| Queue ID | Priority | Workstream | Task | Owner Target | Acceptance Criteria | Reality Status |
|---|---:|---|---|---|---|---|
| SCTO-001 | P0 | Product | Create product definition page for Solo CTO Control Layer | COO/Product | Offer, buyer, pain, tiers, outcomes documented | PARTIAL |
| SCTO-002 | P0 | Architecture | Define monitored asset registry schema | Symbio DEV | Supabase DDL for assets, probes, playbooks, incidents, evidence | PRETEND |
| SCTO-003 | P0 | Architecture | Define autonomy tier and safe action registry | Symbio DEV | SAFE, DRY_RUN, GATED, BLOCKED action taxonomy created | PRETEND |
| SCTO-004 | P0 | Engineering | Build synthetic probe worker | Symbio DEV | Probe can test URL, form, Stripe link, queue, and API endpoint | PRETEND |
| SCTO-005 | P0 | Engineering | Build remediation runner | Symbio DEV | Runner executes idempotent playbooks and records attempts | PRETEND |
| SCTO-006 | P0 | Engineering | Build validation runner | Symbio DEV | Validates after remediation and returns pass/fail receipt | PRETEND |
| SCTO-007 | P0 | Evidence | Bind every incident to Reality Ledger | Symbio DEV | intent → execution → output → classification → evidence row exists | PRETEND |
| SCTO-008 | P1 | Ops | Create low-noise escalation template | COO/Ops | Notification includes impact, attempted fixes, and recommended action | PARTIAL |
| SCTO-009 | P1 | GTM | Build pricing one-pager | Marketing/Sales | 6-tier pricing ladder and add-ons ready for brochure | PARTIAL |
| SCTO-010 | P1 | GTM | Build sales discovery checklist | Marketing/Sales | Captures stack, critical flows, outage history, revenue risk | PRETEND |
| SCTO-011 | P1 | Delivery | Define onboarding workflow | Ops | Intake → registry → probes → playbooks → prove → monthly review | PRETEND |
| SCTO-012 | P1 | DevOps | Create GitHub Actions or Bridge route for scheduled probes | Symbio DEV | Scheduled probe run produces durable receipt | PRETEND |
| SCTO-013 | P2 | Reporting | Create weekly COO report template | COO/Ops | Shows recoveries, unresolved risks, costs, weak spots | PRETEND |
| SCTO-014 | P2 | Command Centre | Create no-noise control widget | Symbio DEV | Shows only green/recovered/escalated states, not raw metrics | PRETEND |
| SCTO-015 | P2 | Content | Convert article into brochure, website copy, and LinkedIn article | Marketing | Three reusable content outputs created | PRETEND |

---

## 11. Minimum Viable Build

The MVP must not try to replicate enterprise observability. It must prove the small business loop.

### MVP scope

- Asset registry
- Probe runner
- Incident table
- Remediation playbook table
- Validation runner
- Escalation formatter
- Weekly summary
- Reality Ledger link

### MVP assets to test

- 1 public website
- 1 lead form
- 1 Stripe payment link
- 1 Supabase health query
- 1 agent/job queue
- 1 GitHub/Bridge receipt check

### MVP proof gates

- Probe detects failure
- Safe remediation triggers
- Validation checks result
- Incident is logged
- Failed recovery escalates
- Weekly summary generated

---

## 12. Delivery Sequence

### Phase 1 — Codify

- Write schemas
- Define action taxonomy
- Define probe types
- Define pricing and packages

### Phase 2 — Build

- Build runners
- Build playbook execution
- Build validation checks
- Build escalation messages

### Phase 3 — Prove

- Run against test assets
- Force simulated failures
- Capture receipts
- Classify outcomes in Reality Ledger

### Phase 4 — Package

- Create brochure
- Create sales checklist
- Create COO report
- Create buyer-facing service page

### Phase 5 — Replicate

- Outcome Ready version
- AHC version
- Tradie AI version
- Generic Solo CTO version

---

## 13. Hard Rules

- No dashboards as the product.
- No alerting before remediation is attempted.
- No claim of REAL until evidence exists.
- No destructive remediation without gating.
- No hiding repeated recoveries; repeated recoveries become design debt.
- No static thresholds where anomaly detection or business rules are better.
- No enterprise ceremony unless the buyer needs compliance evidence.

---

## 14. COO Handoff

COO should form a small pod:

- Product owner: package the offer and buyer journey
- Engineer: build probe/remediation/validation loop
- Ops lead: define escalation and reporting templates
- Sales/Marketing: convert into brochure and service page
- Evidence owner: bind proof to Reality Ledger

First target customer is internal: T4H ecosystem sites and workflows. Eat our own dog food first, then sell the recovered-failure story.

---

## 15. Closeout Status

This document is a lodged strategy and execution handoff. It is not yet deployed infrastructure. Next receipt required: Symbio DEV creates schema + first runner + first proof incident.
