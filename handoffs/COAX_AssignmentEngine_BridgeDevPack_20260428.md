# COAX Assignment Engine — Bridge / Dev Handoff Pack

**Date:** 2026-04-28  
**Target:** Bridge or Dev execution path  
**Repo:** TML-4PM/the-pen  
**Classification:** PARTIAL until Bridge/Lambda/Supabase execution receipts are returned  
**Owner:** COAX / Command Centre  
**Autonomy:** No HITL until prod; execute, prove, receipt, then promote.

## Executive intent

Build and deploy the COAX Assignment Engine so unfinished work cannot silently die. The engine continuously discovers unfinished/stale items, assigns them to the best available execution team/agent, logs assignment decisions, writes Reality Ledger evidence, and exposes operational status to the Command Centre.

This is not a manual controller. It is a continuous allocation and recovery loop.

## End-state

A production-ready assignment engine with:

1. Supabase source-of-truth tables.
2. RLS policies and service-role execution posture.
3. Lambda execution engine.
4. EventBridge recurring scheduler.
5. Manual Bridge invocation payload.
6. API endpoint for Command Centre status.
7. Command Centre widget snippet.
8. Seed pack for teams/items.
9. Smoke tests.
10. Reality Ledger binding.
11. Recovery/escalation path.
12. Monetisation/value event hook.
13. Production acceptance gates.

## Files in this pack

Dev/Bridge should split this handoff into repo paths during execution:

```text
/coax-engine
  /sql/schema.sql
  /sql/rls.sql
  /sql/seed.sql
  /lambda/coax-assignment-engine.ts
  /infra/eventbridge.json
  /api/assignment-status.ts
  /widgets/assignment-dashboard.html
  /bridge/deploy-payload.json
  /bridge/sql-payload.json
  /tests/smoke-test.sh
  /docs/README.md
```

---

## 1. Supabase schema

```sql
create table if not exists public.coax_teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  skills text[] not null default '{}',
  active boolean not null default true,
  max_active_items int not null default 10,
  autonomy_tier text not null default 'AUTONOMOUS'
    check (autonomy_tier in ('AUTONOMOUS','LOG_ONLY','GATED','BLOCKED')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.coax_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  status text not null default 'todo'
    check (status in ('todo','in_progress','blocked','done','cancelled')),
  team_id uuid references public.coax_teams(id),
  tags text[] not null default '{}',
  priority int not null default 0,
  assigned_at timestamptz,
  completed_at timestamptz,
  assignment_attempts int not null default 0,
  last_assignment_reason text,
  source_system text not null default 'COAX',
  biz_key text not null default 'Research',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.coax_assignment_log (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.coax_items(id),
  team_id uuid references public.coax_teams(id),
  score numeric,
  reason text,
  action text not null default 'ASSIGNED'
    check (action in ('ASSIGNED','REASSIGNED','ESCALATED','NO_TEAM_AVAILABLE','SKIPPED')),
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.coax_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references public.coax_items(id),
  intent text not null,
  execution text not null,
  output jsonb not null default '{}'::jsonb,
  classification text not null check (classification in ('REAL','PARTIAL','PRETEND')),
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.coax_value_events (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references public.coax_items(id),
  event_type text not null default 'assignment',
  value numeric not null default 0,
  currency text not null default 'AUD',
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_coax_teams_updated_at on public.coax_teams;
create trigger trg_coax_teams_updated_at
before update on public.coax_teams
for each row execute function public.set_updated_at();

drop trigger if exists trg_coax_items_updated_at on public.coax_items;
create trigger trg_coax_items_updated_at
before update on public.coax_items
for each row execute function public.set_updated_at();

create index if not exists idx_coax_items_status on public.coax_items(status);
create index if not exists idx_coax_items_team on public.coax_items(team_id);
create index if not exists idx_coax_items_updated on public.coax_items(updated_at);
create index if not exists idx_coax_items_tags on public.coax_items using gin(tags);
create index if not exists idx_coax_assignment_log_item on public.coax_assignment_log(item_id);
create index if not exists idx_coax_reality_ledger_item on public.coax_reality_ledger(item_id);

alter table public.coax_teams enable row level security;
alter table public.coax_items enable row level security;
alter table public.coax_assignment_log enable row level security;
alter table public.coax_reality_ledger enable row level security;
alter table public.coax_value_events enable row level security;
```

---

## 2. RLS / execution posture

Service-role Lambdas bypass RLS. Browser/UI must be read-only until auth roles are formally mapped.

```sql
create policy if not exists coax_teams_read_all
on public.coax_teams for select
to authenticated
using (true);

create policy if not exists coax_items_read_all
on public.coax_items for select
to authenticated
using (true);

create policy if not exists coax_assignment_log_read_all
on public.coax_assignment_log for select
to authenticated
using (true);

create policy if not exists coax_reality_ledger_read_all
on public.coax_reality_ledger for select
to authenticated
using (true);

create policy if not exists coax_value_events_read_all
on public.coax_value_events for select
to authenticated
using (true);
```

Write access remains service-role only until production auth model is confirmed. This prevents browser clients from mutating assignments.

---

## 3. Seed pack

```sql
insert into public.coax_teams (name, skills, active, max_active_items, autonomy_tier)
values
  ('COAX', array['orchestration','routing','command-centre','recovery'], true, 25, 'AUTONOMOUS'),
  ('Pen', array['handoff','github','documentation','receipt'], true, 20, 'AUTONOMOUS'),
  ('Symbio', array['dev','lambda','supabase','eventbridge','test'], true, 20, 'AUTONOMOUS')
on conflict do nothing;

insert into public.coax_items (title, description, status, tags, priority, source_system, biz_key)
values
  ('COAX seed: route unfinished handoff', 'Seed item to prove assignment path.', 'todo', array['orchestration','handoff'], 7, 'COAX', 'Research'),
  ('COAX seed: deploy Lambda schedule', 'Seed item to prove dev execution path.', 'todo', array['dev','lambda','eventbridge'], 8, 'COAX', 'Research'),
  ('COAX seed: create receipt proof', 'Seed item to prove GitHub receipt path.', 'todo', array['github','receipt'], 6, 'COAX', 'Research')
on conflict do nothing;
```

---

## 4. Lambda execution engine

```ts
import { createClient } from '@supabase/supabase-js';

type Team = {
  id: string;
  name: string;
  skills: string[];
  active: boolean;
  max_active_items: number;
  autonomy_tier: 'AUTONOMOUS' | 'LOG_ONLY' | 'GATED' | 'BLOCKED';
};

type Item = {
  id: string;
  title: string;
  status: string;
  team_id?: string | null;
  tags: string[];
  priority: number;
  updated_at: string;
  assignment_attempts: number;
  biz_key: string;
};

const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY || ''
);

const STALE_MINUTES = Number(process.env.COAX_STALE_MINUTES || '15');
const MAX_REASSIGNMENTS_BEFORE_ESCALATION = Number(process.env.COAX_MAX_REASSIGNMENTS || '3');

export const handler = async (event: any = {}) => {
  const runId = event?.metadata?.request_id || `coax-${Date.now()}`;
  const now = new Date();
  const staleIso = new Date(now.getTime() - STALE_MINUTES * 60_000).toISOString();

  if (!process.env.SUPABASE_URL || !(process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY)) {
    return {
      status: 'error',
      classification: 'PRETEND',
      error: 'Missing SUPABASE_URL or service role key',
      runId
    };
  }

  const { data: items, error: itemError } = await supabase
    .from('coax_items')
    .select('*')
    .in('status', ['todo', 'in_progress', 'blocked'])
    .or(`team_id.is.null,updated_at.lt.${staleIso}`)
    .order('priority', { ascending: false })
    .limit(250);

  if (itemError) throw itemError;

  const { data: teams, error: teamError } = await supabase
    .from('coax_teams')
    .select('*')
    .eq('active', true)
    .neq('autonomy_tier', 'BLOCKED');

  if (teamError) throw teamError;

  const results: any[] = [];

  for (const item of (items || []) as Item[]) {
    const decision = await assignOne(item, (teams || []) as Team[], runId);
    results.push(decision);
  }

  await supabase.from('coax_reality_ledger').insert({
    intent: 'COAX assignment cycle',
    execution: 'lambda.coax-assignment-engine.handler',
    output: { runId, processed: results.length, results },
    classification: results.length ? 'PARTIAL' : 'REAL',
    evidence: { source: 'lambda', scheduler: event?.source || 'manual_or_eventbridge', staleIso }
  });

  return {
    status: 'complete',
    runId,
    processed: results.length,
    results
  };
};

async function assignOne(item: Item, teams: Team[], runId: string) {
  if (!teams.length) {
    await log(item.id, null, null, 'NO_TEAM_AVAILABLE', 'No active non-blocked team available', { runId });
    return { itemId: item.id, action: 'NO_TEAM_AVAILABLE' };
  }

  const scored = await Promise.all(teams.map(async (team) => scoreTeam(item, team)));
  const viable = scored.filter(x => x.score > 0).sort((a, b) => b.score - a.score);
  const best = viable[0];

  if (!best) {
    await log(item.id, null, null, 'NO_TEAM_AVAILABLE', 'No viable team after scoring', { runId });
    return { itemId: item.id, action: 'NO_TEAM_AVAILABLE' };
  }

  const escalate = item.assignment_attempts >= MAX_REASSIGNMENTS_BEFORE_ESCALATION;
  const action = escalate ? 'ESCALATED' : item.team_id ? 'REASSIGNED' : 'ASSIGNED';
  const reason = `${action}: best score ${best.score.toFixed(4)} for ${best.team.name}`;

  const { error } = await supabase
    .from('coax_items')
    .update({
      team_id: best.team.id,
      assigned_at: new Date().toISOString(),
      assignment_attempts: (item.assignment_attempts || 0) + 1,
      last_assignment_reason: reason,
      status: item.status === 'todo' ? 'in_progress' : item.status
    })
    .eq('id', item.id);

  if (error) throw error;

  await log(item.id, best.team.id, best.score, action, reason, {
    runId,
    teamName: best.team.name,
    itemTags: item.tags,
    bizKey: item.biz_key,
    components: best.components
  });

  await supabase.from('coax_reality_ledger').insert({
    item_id: item.id,
    intent: 'Assign unfinished item to execution team',
    execution: 'coax_assignment_engine.assignOne',
    output: { itemId: item.id, teamId: best.team.id, action, score: best.score },
    classification: 'PARTIAL',
    evidence: { runId, reason, components: best.components }
  });

  await supabase.from('coax_value_events').insert({
    item_id: item.id,
    event_type: action.toLowerCase(),
    value: 1,
    currency: 'AUD',
    evidence: { runId, reason }
  });

  return { itemId: item.id, teamId: best.team.id, action, score: best.score };
}

async function scoreTeam(item: Item, team: Team) {
  const skills = team.skills || [];
  const tags = item.tags || [];
  const matches = tags.filter(tag => skills.includes(tag)).length;
  const skillMatch = tags.length ? matches / tags.length : 0.5;

  const { count } = await supabase
    .from('coax_items')
    .select('*', { count: 'exact', head: true })
    .eq('team_id', team.id)
    .in('status', ['in_progress', 'blocked']);

  const activeCount = count || 0;
  const capacityRatio = Math.max(0, (team.max_active_items - activeCount) / Math.max(team.max_active_items, 1));
  const capacity = capacityRatio;
  const performance = 0.8;
  const latencyPenalty = activeCount / Math.max(team.max_active_items, 1);
  const priorityBoost = Math.min(Math.max(item.priority, 0), 10) / 100;

  const score =
    skillMatch * 0.4 +
    capacity * 0.3 +
    performance * 0.2 -
    latencyPenalty * 0.1 +
    priorityBoost;

  return {
    team,
    score,
    components: { skillMatch, capacity, performance, latencyPenalty, priorityBoost, activeCount }
  };
}

async function log(itemId: string, teamId: string | null, score: number | null, action: string, reason: string, evidence: any) {
  await supabase.from('coax_assignment_log').insert({
    item_id: itemId,
    team_id: teamId,
    score,
    action,
    reason,
    evidence
  });
}
```

---

## 5. EventBridge scheduler

```json
{
  "name": "coax-assignment-engine-every-2-minutes",
  "description": "Runs COAX Assignment Engine continuously so unfinished work is assigned, recovered, and logged.",
  "schedule_expression": "rate(2 minutes)",
  "target_lambda": "coax-assignment-engine",
  "enabled": true,
  "input": {
    "source": "eventbridge.schedule",
    "metadata": {
      "source": "COAX",
      "request_id": "eventbridge-coax-assignment-cycle"
    }
  }
}
```

---

## 6. Command Centre status API

```ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY || ''
);

export default async function handler(req: any, res: any) {
  const staleIso = new Date(Date.now() - 15 * 60_000).toISOString();
  const since24h = new Date(Date.now() - 24 * 60 * 60_000).toISOString();

  const [{ count: unassigned }, { count: stale }, { count: activeTeams }, { count: assignments24h }] = await Promise.all([
    supabase.from('coax_items').select('*', { count: 'exact', head: true }).is('team_id', null).in('status', ['todo','in_progress','blocked']),
    supabase.from('coax_items').select('*', { count: 'exact', head: true }).lt('updated_at', staleIso).in('status', ['todo','in_progress','blocked']),
    supabase.from('coax_teams').select('*', { count: 'exact', head: true }).eq('active', true),
    supabase.from('coax_assignment_log').select('*', { count: 'exact', head: true }).gte('created_at', since24h)
  ]);

  res.status(200).json({
    status: 'OK',
    unassigned: unassigned || 0,
    stale: stale || 0,
    activeTeams: activeTeams || 0,
    assignments24h: assignments24h || 0,
    checkedAt: new Date().toISOString()
  });
}
```

---

## 7. Command Centre widget snippet

```html
<div class="coax-assignment-widget" style="font-family: system-ui; border: 1px solid #ddd; border-radius: 12px; padding: 16px; max-width: 720px;">
  <h2 style="margin:0 0 8px;">COAX Assignment Engine</h2>
  <p style="margin:0 0 16px;">Unfinished work allocation, stale item recovery, and Reality Ledger proof.</p>
  <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap: 12px;">
    <div><strong id="coax-unassigned">-</strong><br/>Unassigned</div>
    <div><strong id="coax-stale">-</strong><br/>Stale</div>
    <div><strong id="coax-active">-</strong><br/>Active Teams</div>
    <div><strong id="coax-assignments">-</strong><br/>24h Assignments</div>
  </div>
  <div id="coax-assignment-status" style="margin-top:12px; font-size: 13px; opacity: .8;">Loading…</div>
</div>
<script>
(async function(){
  async function loadCoaxAssignmentWidget(){
    try {
      const res = await fetch('/api/coax/assignment-status');
      const data = await res.json();
      document.getElementById('coax-unassigned').innerText = data.unassigned ?? 0;
      document.getElementById('coax-stale').innerText = data.stale ?? 0;
      document.getElementById('coax-active').innerText = data.activeTeams ?? 0;
      document.getElementById('coax-assignments').innerText = data.assignments24h ?? 0;
      document.getElementById('coax-assignment-status').innerText = `${data.status || 'OK'} · ${data.checkedAt || ''}`;
    } catch (e) {
      document.getElementById('coax-assignment-status').innerText = 'Widget API unavailable; check deployment.';
    }
  }
  await loadCoaxAssignmentWidget();
  setInterval(loadCoaxAssignmentWidget, 10000);
})();
</script>
```

---

## 8. Bridge deployment envelopes

### 8.1 SQL executor envelope

```json
{
  "action": "invoke_function",
  "function_name": "troy-sql-executor",
  "invocation_type": "RequestResponse",
  "payload": {
    "source_package": "handoffs/COAX_AssignmentEngine_BridgeDevPack_20260428.md",
    "sql_sections": ["1. Supabase schema", "2. RLS / execution posture", "3. Seed pack"],
    "dry_run": false,
    "approval_required": false
  },
  "metadata": {
    "request_id": "coax-assignment-engine-sql-20260428",
    "source": "the-pen",
    "timestamp_utc": "2026-04-28T00:00:00Z",
    "auth_context": "github_connector_handoff"
  }
}
```

### 8.2 Lambda deployer envelope

```json
{
  "action": "invoke_function",
  "function_name": "troy-lambda-deployer",
  "invocation_type": "RequestResponse",
  "payload": {
    "lambda_name": "coax-assignment-engine",
    "runtime": "nodejs18.x",
    "handler": "index.handler",
    "source_package": "handoffs/COAX_AssignmentEngine_BridgeDevPack_20260428.md",
    "environment": {
      "SUPABASE_URL": "{{SUPABASE_URL}}",
      "SUPABASE_SERVICE_ROLE_KEY": "{{SUPABASE_SERVICE_ROLE_KEY}}",
      "COAX_STALE_MINUTES": "15",
      "COAX_MAX_REASSIGNMENTS": "3"
    },
    "schedule": "rate(2 minutes)",
    "dry_run": false,
    "approval_required": false
  },
  "metadata": {
    "request_id": "coax-assignment-engine-lambda-20260428",
    "source": "the-pen",
    "timestamp_utc": "2026-04-28T00:00:00Z",
    "auth_context": "github_connector_handoff"
  }
}
```

---

## 9. Smoke test

```bash
#!/usr/bin/env bash
set -euo pipefail

LAMBDA_URL="${LAMBDA_URL:-}"

if [ -z "$LAMBDA_URL" ]; then
  echo "Missing LAMBDA_URL"
  exit 1
fi

curl -sS -X POST "$LAMBDA_URL" \
  -H 'content-type: application/json' \
  -d '{"source":"smoke-test","metadata":{"request_id":"coax-smoke-20260428"}}' | jq .
```

Expected response after seed:

```json
{
  "status": "complete",
  "processed": 3,
  "results": [
    { "action": "ASSIGNED" }
  ]
}
```

A later `processed: 0` result is acceptable only when no unfinished/stale items exist. It should still write a cycle-level Reality Ledger row.

---

## 10. Recovery and fallback contract

If no assignment rows appear for 10 minutes while unfinished items exist:

1. Re-run Lambda manually through Bridge.
2. If Lambda fails because env vars are missing, return PARTIAL receipt with missing env list.
3. If Supabase schema is missing, execute SQL pack again.
4. If EventBridge is missing or disabled, recreate the schedule.
5. If no viable team exists, create or reactivate `COAX` fallback team.
6. If an item exceeds 3 assignment attempts, mark assignment action as `ESCALATED` and preserve item status for operator review.

Stopping without a receipt is a failure.

---

## 11. Production acceptance gates

Promote to REAL only when all are true:

- [ ] Tables exist in Supabase.
- [ ] RLS is enabled.
- [ ] Seed teams exist.
- [ ] Lambda exists as `coax-assignment-engine`.
- [ ] Lambda env vars are present.
- [ ] EventBridge schedule exists and is enabled.
- [ ] Manual invocation returns structured JSON.
- [ ] At least one seed item is assigned or reassigned.
- [ ] `coax_assignment_log` contains assignment evidence.
- [ ] `coax_reality_ledger` contains cycle and item rows.
- [ ] Widget status API returns HTTP 200.
- [ ] Receipt is posted back to GitHub Issue #35.

---

## 12. Dev execution checklist

- [ ] Split this handoff into `/coax-engine` file structure.
- [ ] Apply Supabase schema via bridge `troy-sql-executor`.
- [ ] Apply RLS and seed pack.
- [ ] Deploy Lambda via `troy-lambda-deployer` or existing CFN/SAM path.
- [ ] Bind EventBridge schedule every 2 minutes.
- [ ] Register widget in `t4h_ui_snippet` as slug `coax-assignment-engine` if Command Centre registry is available.
- [ ] Add status API to Command Centre or target service.
- [ ] Run manual Lambda invoke.
- [ ] Confirm assignment log rows.
- [ ] Confirm Reality Ledger rows.
- [ ] Return GitHub comment/receipt with deployed resource IDs and smoke output.

---

## 13. Reality Ledger current state

Current handoff state: **PARTIAL**.

Reason: assets are lodged to GitHub/the-pen. Runtime proof still requires Bridge/Supabase/Lambda receipts.

Promotion to REAL requires:

1. Supabase tables exist.
2. Lambda executes without missing env vars.
3. Scheduler exists and is enabled.
4. At least one item assignment is logged.
5. Reality Ledger receives cycle and item rows.
6. GitHub receipt is posted back with execution evidence.

---

## 14. Receipt payload required from Bridge/Dev

```json
{
  "receipt_type": "COAX_ASSIGNMENT_ENGINE_DEPLOYMENT",
  "classification": "REAL_OR_PARTIAL",
  "repo": "TML-4PM/the-pen",
  "source_file": "handoffs/COAX_AssignmentEngine_BridgeDevPack_20260428.md",
  "resources": {
    "supabase_tables": [
      "coax_teams",
      "coax_items",
      "coax_assignment_log",
      "coax_reality_ledger",
      "coax_value_events"
    ],
    "lambda_name": "coax-assignment-engine",
    "eventbridge_rule": "coax-assignment-engine-every-2-minutes",
    "widget_slug": "coax-assignment-engine",
    "status_api": "/api/coax/assignment-status"
  },
  "smoke_test": {
    "status": "pending",
    "output": null
  },
  "reality_ledger": {
    "cycle_row_written": false,
    "item_row_written": false
  },
  "next_action": "Promote to REAL only after proof gates pass."
}
```

---

## Bottom line

This handoff is complete enough for Bridge/Dev execution with no further human approval. It must remain PARTIAL until runtime proof returns. Execute, prove, receipt, and promote.
