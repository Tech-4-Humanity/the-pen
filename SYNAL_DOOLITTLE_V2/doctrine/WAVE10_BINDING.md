# Wave10 Binding — Synal Doolittle V2

Wave10 requires 8 components. Any missing component = PARTIAL.

| # | Component | Status | Evidence |
|---|-----------|--------|----------|
| 1 | runtime | REAL | `doolittle.*` schema deployed; 12 tables; RLS enabled; HTML app + doctrine staged |
| 2 | value-loop | PARTIAL | Parties + decisions + resource_allocations tables exist; no live LLM call yet returning evidence |
| 3 | revenue | PARTIAL | `tenants` + `tenant_limits` model defined with 6 tiers (Free → Sovereign); Stripe products not wired |
| 4 | distribution | PARTIAL | Pack staged for `TML-4PM/the-pen`; Vercel deploy of `app/index.html` pending; `/api/*` routes pending |
| 5 | observability | REAL | `messages`, `evidence_logs`, `decisions`, `resource_allocations`, `exports` tables with RLS |
| 6 | recovery | REAL | `archived_at` columns on tenants/spaces/threads/messages; no DELETE policy; archive-not-delete |
| 7 | evidence | REAL | `public.reality_ledger` entry payload defined (`bridge/ledger_entry.json`) |
| 8 | lifecycle | REAL | Status enums: tenant.status, space.status, thread.status, message.status, decision.status |

## Overall: PARTIAL

## Gaps to flip to REAL

1. Deploy `app/index.html` to a Vercel project (e.g. `synal-doolittle.vercel.app`)
2. Implement `/api/croux/route` calling Vercel AI Gateway with the four provider models
3. Implement `/api/messages` write-through to `doolittle.messages`
4. Implement `/api/bridge/execute` forwarding to `zdgnab3py0` with dual auth
5. First real CROUX call returning evidence with status=REAL
6. First Federated COAX decision logged with evidence binding
7. First export written to object storage with retrievable URL
8. Stripe products + `/api/billing/usage` for tenant metering (revenue → REAL)
