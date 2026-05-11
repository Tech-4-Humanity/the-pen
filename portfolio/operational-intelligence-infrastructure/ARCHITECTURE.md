# Operational Intelligence Infrastructure — Architecture

> **Category:** AI-native operational infrastructure for human organisations.
> **Master brand:** Tech 4 Humanity.
> **Pattern:** one engine, many wrappers, one truth.

This is the architecture document that sits behind `README.md` and `bridge_execution_envelope.json`. It is the canonical statement of how the system is built, what is reusable, and where the moat lives.

---

## 1. Layer cake

```
┌────────────────────────────────────────────────────────────────┐
│  Wrapper Layer  (market-facing terminology + workflows)        │
│  /professionals  /tradies  /health  /education  /outcome-ready │
├────────────────────────────────────────────────────────────────┤
│  Product Layer  (canonical SKUs - Desks)                       │
│  Front Desk · Proposal Desk · Booking Desk · Growth Desk       │
│  Evidence Desk · Ops Dashboard · Retention Desk                │
│  Workforce Desk · Memory Desk · Full Vertical AI OS            │
├────────────────────────────────────────────────────────────────┤
│  Capability Layer  (Factor · Gateway · MRI)                    │
│  Factor   = operational data intelligence                      │
│  Gateway  = system connections and integrations                │
│  MRI      = reporting, evidence, and audit outputs             │
├────────────────────────────────────────────────────────────────┤
│  Runtime Layer                                                 │
│  agents · orchestration · queues · workflows · billing         │
├────────────────────────────────────────────────────────────────┤
│  Governance Layer                                              │
│  REAL/PARTIAL/BLOCKED · telemetry · evidence ledger · drift    │
│  recovery · economic self-regulation · freshness · human stop  │
└────────────────────────────────────────────────────────────────┘
```

Every wrapper inherits everything below it. Wrappers only change terminology, workflow composition, required integrations, compliance packs, evidence schema details, and UI copy. The runtime, governance, billing, telemetry, and evidence layers are shared.

## 2. What is reusable

Universal event schema, agent registry, pricing tiers, governance kernel, workflow modules, canonical schema, evidence register, and per-tenant reality ledger are all shared across every wrapper.

## 3. What changes per wrapper

Only: hero copy, terminology, default SKUs, required integrations, compliance packs, evidence schema details, and case study anchor. Sourced from `wrappers.json`.

## 4. The moat

Telemetry-native governance. Evidence-bound outputs. REAL/PARTIAL/BLOCKED enforcement. Reusable wrappers. Runtime continuity. Institutional memory. Shared schemas. Economic self-regulation.

## 5. Deployment waves

| Wave | Wrappers |
|---|---|
| 1 | Professionals (Accountants live), Self-Employed, Tradies |
| 2 | Outcome Ready, Health |
| 3 | Education, Enter Australia |
| 4 | Sovereign deployments |

## 6. Acceptance gates (REAL promotion)

For any (tenant, SKU) to be classified REAL: endpoint returns 200 against a real input; event written to `oii.events` with `classification='REAL'`; evidence row written to `oii.evidence_register`; telemetry snapshot attached; recovery path validated; economic value signal != `orphan`. Enforced by `oii.promote_to_real()`.

## 7. Files

| File | Purpose |
|---|---|
| `README.md` | Category narrative |
| `ARCHITECTURE.md` | This document |
| `bridge_execution_envelope.json` | Bridge runner payload |
| `products.json` | Canonical SKU catalogue |
| `wrappers.json` | Vertical pack configuration |
| `pricing.json` | Tier definitions |
| `agents.json` | Reusable agent registry |
| `routes.json` | Site routing |
| `workflows.json` | Composable workflow modules |
| `events.schema.json` | Universal event envelope |
| `governance.json` | Classification, drift, recovery, economic policy |
| `deployment.template.json` | Wrapper clone profile |
| `migrations/001_oii_canonical_schema.sql` | Supabase canonical tables |
| `samples/professionals_landing_v1.html` | Reference wrapper surface |

## 8. Current runtime classification

| Layer | Classification |
|---|---|
| Architecture and config (this commit) | REAL |
| Supabase migration applied | PARTIAL |
| Stripe products provisioned | PARTIAL |
| API endpoints health-checked | PARTIAL |
| Telemetry round-trip validated | PARTIAL |
| Reality ledger row per SKU | PARTIAL |
| Wave-1 wrapper surfaces in prod | PARTIAL |

The gap to REAL is now bounded, payload-complete, and bridge-ready.
