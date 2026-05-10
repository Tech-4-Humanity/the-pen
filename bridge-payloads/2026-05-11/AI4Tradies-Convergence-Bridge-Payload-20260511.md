# AI4Tradies Convergence Bridge Payload — 2026-05-11

## Status
PARTIAL — compiled and lodged to canonical GitHub path. Bridge runtime execution and external receipt remain pending until Bridge executor consumes this payload and returns an execution receipt.

## Intent
Analyse, enhance, compile, wrap, and hand off AI4Tradies convergence work to the Bridge so the system can move from separate surfaces into one shared runtime.

## Core Finding
AI4Tradies currently reads as a strong product surface, but the maturity gap is convergence. The required next stage is not more pages. It is a canonical operating layer connecting:

- AI4Tradies UI / matrix map / 727 team model
- t4h-agent-orchestrator.lovable.app
- agent-channel.vercel.app
- shared schemas
- shared agent runtime
- shared telemetry
- shared memory
- shared event bus
- shared evidence model
- Reality Ledger status classification

## Enhancement Target
Move from product demo to ecosystem node.

AI4Tradies must become a small-business operating model that plugs into the wider T4H agent fabric. Tradies are the first wedge, but the architecture must support self-employed operators, microbusinesses, field teams, certification-heavy trades, compliance-heavy sectors, and professional services.

## Bridge Execution Requirements

### 1. Canonical Schema Pack
Create or update canonical schemas for:

```sql
create table if not exists public.agent_runtime_registry (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  surface text not null,
  agent_key text not null,
  agent_name text not null,
  family text,
  status text not null check (status in ('LIVE','IN_BUILD','PLANNED','RETIRED')),
  task_types text[] default '{}',
  staff_roles text[] default '{}',
  runtime_url text,
  evidence_model text default 'REALITY_LEDGER',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (brand, surface, agent_key)
);

create table if not exists public.agent_event_bus (
  id uuid primary key default gen_random_uuid(),
  source_surface text not null,
  target_surface text,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  priority text not null default 'NORMAL' check (priority in ('LOW','NORMAL','HIGH','CRITICAL')),
  status text not null default 'QUEUED' check (status in ('QUEUED','RUNNING','COMPLETED','FAILED','BLOCKED')),
  evidence_ref text,
  created_at timestamptz default now(),
  processed_at timestamptz
);

create table if not exists public.agent_memory_items (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  entity_type text not null,
  entity_key text not null,
  memory_type text not null,
  content jsonb not null default '{}'::jsonb,
  confidence numeric default 0.5,
  source text,
  evidence_ref text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.agent_telemetry_events (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  surface text not null,
  agent_key text,
  metric_name text not null,
  metric_value numeric,
  metric_payload jsonb not null default '{}'::jsonb,
  evidence_ref text,
  created_at timestamptz default now()
);

create table if not exists public.reality_ledger_events (
  id uuid primary key default gen_random_uuid(),
  task_id text not null,
  intent text not null,
  execution jsonb not null default '{}'::jsonb,
  output jsonb not null default '{}'::jsonb,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  evidence jsonb not null default '[]'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  next_action text not null,
  elevation text not null,
  pressure_flags jsonb not null default '[]'::jsonb,
  score numeric not null default 0,
  created_at timestamptz default now()
);
```

### 2. Seed Runtime Registry
Seed AI4Tradies as a converged runtime node:

```json
{
  "brand": "AI4Tradies",
  "surfaces": [
    "AI4Tradies Matrix Map",
    "https://t4h-agent-orchestrator.lovable.app/",
    "https://agent-channel.vercel.app/"
  ],
  "families": ["Voice AI", "Field Ops", "Money Flow", "Intelligence"],
  "total_agents_current": 18,
  "target_runtime": "727 Team / Neural Ennead compatible",
  "task_types_current": 7,
  "staff_roles_current": 9,
  "live_agents": 7,
  "in_build_agents": 6,
  "planned_agents": 5
}
```

### 3. Shared Runtime Contract
Create a bridge executor contract:

```ts
export type AgentRuntimeEvent = {
  task_id: string;
  brand: string;
  source_surface: string;
  target_surface?: string;
  agent_key?: string;
  event_type: 'DISCOVER' | 'TRIAGE' | 'EXECUTE' | 'VERIFY' | 'MONETISE' | 'ESCALATE' | 'ARCHIVE';
  payload: Record<string, unknown>;
  reality_required: boolean;
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'CRITICAL';
};

export type RealityLedgerResult = {
  task_id: string;
  status: 'REAL' | 'PARTIAL' | 'BLOCKED';
  result: Record<string, unknown>;
  evidence: Array<{ type: string; value: string }>;
  gaps: string[];
  next_action: string;
  elevation: string;
  pressure_flags: string[];
  score: number;
};
```

### 4. UI / Widget Asset
Create a Command Centre widget named `ai4tradies_convergence_status` with:

- Current surfaces attached
- Agent runtime count
- Event bus health
- Memory health
- Telemetry health
- Reality Ledger status
- Gap list
- Next bridge action

### 5. Routing Rules
All AI4Tradies actions must route through:

1. intent capture
2. canonical schema validation
3. event bus queue
4. runtime execution
5. telemetry write
6. memory write when reusable
7. Reality Ledger write
8. receipt return

### 6. Monetisation Layer
Attach AI4Tradies to small business commercial offers:

- Starter: AI front office for solo operator
- Pro: quoting, follow-up, certification reminders, field ops workflow
- Team: dispatch, compliance, job tracking, customer memory
- Franchise / Association: shared playbooks, benchmark telemetry, qualification intelligence
- Government / education: workforce transition and certification pathway intelligence

### 7. Evidence Model
No final state can be marked REAL until there is evidence of:

- schema migration executed
- seed records inserted
- bridge event accepted
- runtime endpoint invoked or queued
- widget created or updated
- Reality Ledger row written
- receipt returned

## Bridge Payload

```json
{
  "task_id": "AI4TRADIES-CONVERGENCE-20260511",
  "intent": "Converge AI4Tradies, Agent Orchestrator, and Agent Channel into a canonical shared runtime with telemetry, memory, event bus, and evidence binding.",
  "priority": "HIGH",
  "target_repo": "TML-4PM/the-pen",
  "target_surfaces": [
    "AI4Tradies",
    "https://t4h-agent-orchestrator.lovable.app/",
    "https://agent-channel.vercel.app/"
  ],
  "actions": [
    "apply_schema_pack",
    "seed_runtime_registry",
    "create_runtime_contract",
    "create_command_centre_widget",
    "queue_bridge_event",
    "write_reality_ledger_event",
    "return_receipt"
  ],
  "required_receipt_fields": [
    "task_id",
    "status",
    "execution_id",
    "commit_sha",
    "schema_result",
    "widget_result",
    "ledger_result",
    "gaps",
    "next_action"
  ]
}
```

## Reality Ledger Entry

```yaml
task_id: AI4TRADIES-CONVERGENCE-20260511
intent: converge AI4Tradies runtime surfaces into canonical shared runtime
execution:
  github_lodgement: complete
  bridge_runtime_execution: pending external bridge receipt
output:
  asset: bridge-payloads/2026-05-11/AI4Tradies-Convergence-Bridge-Payload-20260511.md
status: PARTIAL
evidence:
  - type: github_file
    value: bridge-payloads/2026-05-11/AI4Tradies-Convergence-Bridge-Payload-20260511.md
gaps:
  - Bridge executor receipt not yet returned in this chat
  - Supabase migration execution not directly verified here
  - Runtime/widget deployment not directly verified here
next_action: Bridge executor must consume payload, execute, and return receipt
elevation: HIGH — convergence is the maturity jump from separate product surfaces to operating fabric
pressure_flags:
  - no_simulated_completion
  - receipt_required
  - runtime_binding_required
score: 0.72
```
