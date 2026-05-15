# Connector Control Plane v1

## Purpose

Move connector state out of fragile chat-session memory and into a persistent operational control plane that can be used by ChatGPT, Claude, Gemini, Bridge, Dev, Synapse, Symbio, Command Centre, and any future execution layer.

The problem being solved is not just connector login persistence. The real problem is missing runtime authority, session continuity, health monitoring, intent routing, fallback routing, and receipt binding across AI-assisted work.

---

## Reality Ledger

```yaml
status: PARTIAL
result: Connector Control Plane v1 package pushed to GitHub for canonical storage and Bridge/service-catalog promotion.
evidence:
  - type: github_commit
    value: pending_from_connector_response
  - type: reusable_asset
    value: connector-control-plane/00_connector-control-plane-v1.md
gaps:
  - live Bridge execution receipt not yet observed
  - runtime deployment not yet proven
  - Supabase tables not yet created in production
  - health workers not yet deployed
  - Service Catalog product not yet published
next_action:
  - promote this package through Bridge or Dev worker
  - create Supabase schema
  - deploy health worker
  - bind connector health receipts to Reality Ledger
  - promote products to AWS Service Catalog
pressure_flags:
  - previous response created artifact but did not push to GitHub
  - missing runtime receipt remains unresolved until Bridge executes
score: 0.74
```

---

## Product Definition

```yaml
product:
  name: Connector Control Plane
  version: v1
  owner: Troy Latter / Tech 4 Humanity
  category: AI Runtime Infrastructure
  service_catalog_ready: true
  canonical_repo: TML-4PM/the-pen
  canonical_path: connector-control-plane/00_connector-control-plane-v1.md
```

---

## Target State

```yaml
target_state:
  persistent_connector_registry: true
  session_passport: true
  connector_health_watchdog: true
  intent_router: true
  authority_escrow: true
  bridge_fallback: true
  service_catalog_products: true
  reality_ledger_binding: true
```

---

## Supabase Schema

```sql
create table if not exists connector_registry (
  id uuid primary key default gen_random_uuid(),
  connector_name text not null unique,
  enabled boolean not null default true,
  authority text not null default 'read',
  route text not null default 'direct',
  fallback_route text default 'bridge',
  health text not null default 'unknown',
  priority integer not null default 100,
  owner text,
  last_check timestamptz,
  last_success timestamptz,
  last_failure timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists session_passports (
  id uuid primary key default gen_random_uuid(),
  session_id text not null,
  user_name text not null,
  authority jsonb not null default '{}'::jsonb,
  approval_mode text not null default 'safe_auto',
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists connector_receipts (
  id uuid primary key default gen_random_uuid(),
  connector text not null,
  action text not null,
  status text not null,
  result jsonb not null default '{}'::jsonb,
  receipt_type text not null default 'runtime',
  evidence jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists connector_intent_routes (
  id uuid primary key default gen_random_uuid(),
  intent text not null unique,
  primary_connector text not null,
  fallback_connector text default 'bridge',
  enabled boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

---

## Seed Data

```sql
insert into connector_registry (connector_name, authority, route, fallback_route, priority, owner)
values
  ('github', 'read_write', 'direct', 'bridge', 10, 'Troy'),
  ('google_drive', 'read_write', 'direct', 'bridge', 20, 'Troy'),
  ('notion', 'read_write', 'direct', 'bridge', 30, 'Troy'),
  ('gmail', 'read_write', 'direct', 'bridge', 40, 'Troy'),
  ('google_calendar', 'read_write', 'direct', 'bridge', 50, 'Troy'),
  ('vercel', 'read_write', 'direct', 'bridge', 60, 'Troy'),
  ('stripe', 'read_write', 'direct', 'bridge', 70, 'Troy'),
  ('bridge', 'execute', 'runtime', null, 1, 'Troy')
on conflict (connector_name) do update set
  authority = excluded.authority,
  route = excluded.route,
  fallback_route = excluded.fallback_route,
  priority = excluded.priority,
  owner = excluded.owner,
  updated_at = now();
```

---

## Service Catalog Products

```yaml
service_catalog:
  portfolio: AI Runtime Infrastructure
  products:
    - name: Connector Control Plane Core
      version: v1
      description: Persistent connector registry, session passports, health checks, and receipt logging.
    - name: Connector Runtime Enterprise
      version: v1
      description: Enterprise connector runtime with SSO, policy gates, approval rules, telemetry, and audit trail.
    - name: LLM Federation Runtime
      version: v1
      description: Shared connector authority and intent routing across ChatGPT, Claude, Gemini, Bridge, MCP, Dev, and Prod.
```

---

## Immediate Bridge / Dev Payload

```json
{
  "task_id": "connector-control-plane-v1-promote",
  "intent": "Deploy Connector Control Plane v1 from canonical GitHub package and prepare AWS Service Catalog promotion assets.",
  "repo": "TML-4PM/the-pen",
  "path": "connector-control-plane/00_connector-control-plane-v1.md",
  "actions": [
    "create_supabase_schema",
    "seed_connector_registry",
    "deploy_health_worker",
    "run_connector_health_check",
    "write_reality_ledger_receipt",
    "prepare_service_catalog_products"
  ],
  "classification": "PARTIAL_UNTIL_RUNTIME_RECEIPTS",
  "required_receipts": [
    "github_commit",
    "supabase_migration",
    "health_worker_deploy",
    "connector_health_check",
    "service_catalog_package"
  ]
}
```

---

## Ledger

```yaml
task_id: connector-control-plane-v1
intent: persistent connector runtime and service catalog promotion package
execution: GitHub canonical package creation through connector
output: connector-control-plane/00_connector-control-plane-v1.md
status: PARTIAL
reason: GitHub commit is real when connector returns SHA; Bridge/runtime proof still pending
evidence:
  - github_create_file_response
score: 0.74
```
