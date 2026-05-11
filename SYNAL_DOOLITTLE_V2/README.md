# Synal Doolittle V2 — Multi-Party Translation Operating Room

**Status: PARTIAL** — Schema deployed to Supabase (`doolittle.*`). 12 parties seeded. 3 spaces seeded. App + doctrine + API contracts staged. Runtime backend not yet wired.

## What this is

A white-label multi-party translation surface where Humans, Doolittle (animal/device/signal interpreter), CROUX provider representatives (G/C/X/P), Federated COAX (control), Bridge (execution), and external parties operate together inside Project Spaces with thread-level resource allocation, decision logs, evidence binding, and persistence.

## Architecture

```
Synal UI
  → Project Space (per tenant)
    → Thread
      → Parties (CROUX-G/C/X/P + Doolittle + F-COAX + Human + Device + Animal + System + External + Bridge)
        → Messages (text + image + signal)
          → Resource Allocations
          → Decisions (Federated COAX)
          → Evidence Logs
          → Exports
            → Reality Ledger (T4H proof)
```

## CROUX Registry

| Party | Provider | Model | Role | Can Execute |
|-------|----------|-------|------|-------------|
| CROUX-G | OpenAI | `openai/gpt-5` | Orchestration / drafting | No |
| CROUX-C | Anthropic | `anthropic/claude-opus-4-7` | Reasoning / critique | No |
| CROUX-X | xAI | `xai/grok-4` | Adversarial / current signal | No |
| CROUX-P | Perplexity | `perplexity/sonar-pro` | Source-grounded research | No |
| Doolittle | translator | n/a | Human ↔ animal ↔ device interpretation | No |
| Federated COAX | control | n/a | Routing + proof authority | Yes |
| Bridge | execution | `zdgnab3py0` | Real-world action | Yes |
| Human | operator | n/a | Sovereign + override | Yes |

**Rule:** CROUX parties speak. Federated COAX decides. Bridge executes. Reality Ledger proves.

## Files

- `app/index.html` — V2 multi-party UI (localStorage + API stubs)
- `schema/01_tables.sql` — Supabase DDL (deployed to `doolittle.*` 2026-05-08)
- `schema/02_seed.sql` — canonical parties + default tenant + 3 spaces
- `api/routes.md` — backend route contracts
- `doctrine/CROUX_REGISTRY.md` — provider routing
- `doctrine/WAVE10_BINDING.md` — 8-component check
- `bridge/ledger_entry.json` — reality ledger payload

## Wave10 Binding (Overall: PARTIAL)

| Component | Status | Evidence |
|-----------|--------|----------|
| runtime | REAL | Schema deployed, app shipped to Pen |
| value-loop | PARTIAL | Parties registered, no live LLM calls yet |
| revenue | PARTIAL | Tenant tiers + limits defined, no Stripe wired |
| distribution | PARTIAL | GitHub commit done, Vercel deploy pending |
| observability | REAL | messages + evidence_logs + decisions tables with RLS |
| recovery | REAL | archived_at columns, no DELETE policy |
| evidence | REAL | reality_ledger entry written |
| lifecycle | REAL | thread/space/decision state machines |

## Persistence Modes

| Mode | Behaviour |
|------|-----------|
| OFF | session memory only (V1 default) |
| LOCAL | browser `localStorage` (V2 default) |
| PROJECT | Supabase `doolittle.*` write-through |
| PROOF | Supabase + GitHub receipt + Reality Ledger |

## White-Label Tiers

| Tier | Capabilities |
|------|--------------|
| Free / Demo | Local simulation, export only |
| Starter | Project spaces, parties, logs, exports |
| Pro | CROUX routing, model calls, decision logs |
| Team | Shared spaces, roles, branded exports |
| Enterprise | White-label, custom domains, SSO, audit |
| Sovereign | Bridge + Reality Ledger + dedicated infra (T4H default) |

## Acceptance Gate

V2 passes when a user can: create a space → invite CROUX-G + CROUX-P + CROUX-X + F-COAX → attach an image → ask for translation → allocate budget → record a F-COAX decision → export the thread → see logs → recover the session → Bridge writes a Reality Ledger entry.
