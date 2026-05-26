# Connector Startup Runtime Pack

## Purpose

Stop manually reconnecting the same services every session. Treat connectors as runtime infrastructure, not ad hoc session attachments.

This pack defines the default startup spine for Troy Latter / Tech 4 Humanity sessions: load identity, verify connector access, health-check required systems, repair where authority exists, and surface failures through Command Centre instead of relying on manual discovery.

## Problem

Current session startup is too manual:

- connectors vary by session;
- capability is not obvious at the start;
- auth expiry is discovered during work, not before work;
- failures interrupt execution;
- connector state is not visible as an operating surface;
- session-to-session reliability is lower than the system ambition.

## Target State

Every serious session starts with a connector bootstrap:

1. Identify expected runtime profile.
2. Discover available connectors.
3. Confirm required system access.
4. Health-check each connector.
5. Classify state as LIVE, DEGRADED, BLOCKED, or ABSENT.
6. Attempt non-destructive repair where authority exists.
7. Write result to Reality Ledger / connector ledger.
8. Surface status in Command Centre.
9. Continue execution only with known connector truth.

## Default Connector Set

| Connector | Role | Required | Healthcheck | Failure Class |
|---|---|---:|---|---|
| GitHub | canonical rules, artefacts, issues, receipts | yes | repo read/write on TML-4PM/the-pen | BLOCKED if missing |
| Bridge | execution routing and receipts | yes | /mobile/health and queue write | BLOCKED if unavailable |
| Google Drive | artefact and evidence corpus | yes | root/staging folder read | DEGRADED/BLOCKED depending task |
| Gmail | operational messaging and evidence | conditional | inbox/draft search | DEGRADED |
| Google Calendar | scheduling and time commitments | conditional | calendar search | DEGRADED |
| Vercel | deployment/project surface | yes for web tasks | project list/deploy status | DEGRADED/BLOCKED depending task |
| Supabase | state, ledger, widget and product tables | yes | db ping + table access | BLOCKED for runtime tasks |
| Stripe | revenue and payment workflows | conditional | account/webhook check | BLOCKED for money tasks |
| Lovable | prototype/product surfaces | conditional | project lookup | DEGRADED |

## State Model

```yaml
states:
  LIVE:
    meaning: connector available and healthcheck passed
  DEGRADED:
    meaning: connector present but limited, stale, read-only, rate-limited, or partial
  BLOCKED:
    meaning: connector required but unavailable, unauthorized, or failing hard
  ABSENT:
    meaning: connector not present in current runtime
```

## Runtime Tables

### t4h_connector_registry

```sql
create table if not exists t4h_connector_registry (
  connector_id text primary key,
  connector_name text not null,
  owner text not null default 'troy.latter',
  required_default boolean not null default false,
  required_for text[] not null default '{}',
  status text not null default 'UNKNOWN',
  last_healthcheck_at timestamptz,
  last_success_at timestamptz,
  last_failure_at timestamptz,
  failure_class text,
  failure_reason text,
  repair_authority text not null default 'bridge_if_authorised',
  repair_attempts integer not null default 0,
  evidence_uri text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### t4h_connector_healthcheck_log

```sql
create table if not exists t4h_connector_healthcheck_log (
  healthcheck_id uuid primary key default gen_random_uuid(),
  connector_id text not null references t4h_connector_registry(connector_id),
  run_id text not null,
  status text not null,
  checked_at timestamptz not null default now(),
  latency_ms integer,
  evidence_type text,
  evidence_value text,
  remediation_action text,
  raw_result jsonb not null default '{}'::jsonb
);
```

### t4h_session_bootstrap_log

```sql
create table if not exists t4h_session_bootstrap_log (
  bootstrap_id uuid primary key default gen_random_uuid(),
  session_label text,
  started_at timestamptz not null default now(),
  runtime_profile text not null default 'troy-default',
  required_connectors text[] not null default '{}',
  live_connectors text[] not null default '{}',
  degraded_connectors text[] not null default '{}',
  blocked_connectors text[] not null default '{}',
  absent_connectors text[] not null default '{}',
  overall_status text not null,
  evidence_uri text,
  next_action text,
  raw_summary jsonb not null default '{}'::jsonb
);
```

## Startup Profile

```yaml
startup_profile:
  id: troy-default
  owner: Troy Latter
  timezone: Australia/Sydney
  default_status: PARTIAL_until_healthchecks_pass
  required_connectors:
    - github
    - bridge
    - supabase
    - google_drive
  conditional_connectors:
    - gmail
    - google_calendar
    - vercel
    - stripe
    - lovable
  first_action:
    - discover_available_connectors
    - test_required_connectors
    - classify_connector_state
    - log_bootstrap
    - surface_command_centre_widget
```

## Bridge Handoff Contract

Bridge should receive a single startup invocation envelope that can be reused at the start of any session or scheduled healthcheck.

```json
{
  "task_id": "connector-startup-runtime-v1",
  "intent": "Bootstrap Troy's default connector profile, test required connectors, repair where authorised, and log connector truth before execution.",
  "runtime_profile": "troy-default",
  "required_connectors": ["github", "bridge", "supabase", "google_drive"],
  "conditional_connectors": ["gmail", "google_calendar", "vercel", "stripe", "lovable"],
  "actions": [
    "discover_connectors",
    "healthcheck_connectors",
    "classify_status",
    "attempt_authorised_repair",
    "write_connector_registry",
    "write_session_bootstrap_log",
    "publish_command_centre_widget"
  ],
  "reality_ledger_required": true,
  "non_destructive": true
}
```

## Command Centre Widget

Minimum widget:

```text
CONNECTOR STARTUP

GitHub: LIVE
Bridge: LIVE
Supabase: LIVE
Google Drive: LIVE
Vercel: DEGRADED
Gmail: CONDITIONAL
Stripe: CONDITIONAL

Overall: PARTIAL until Bridge + Supabase runtime proof is returned.
```

## Enforcement Rules

1. No future session should start blind.
2. If connector state is unknown, classify as PARTIAL, not REAL.
3. Required connector failure blocks runtime claims.
4. Conditional connector failure degrades only affected task families.
5. Bridge may repair token/secret lifecycle where authority exists.
6. Manual reconnect is only acceptable where platform policy requires user reauthorization.
7. All startup results must be logged.
8. Command Centre must show connector truth.

## Reality Ledger

```yaml
ledger:
  task_id: connector-startup-runtime-v1
  intent: remove recurring manual connector setup by creating persistent startup profile and connector ledger
  execution:
    github_repo_verified: true
    pack_committed: true
    bridge_issue_required: true
    runtime_deploy_proven: false
  output:
    - operations/connector-startup/00_connector-startup-runtime.md
    - operations/connector-startup/01_connector-startup-bridge-handoff.yaml
  status: PARTIAL
  evidence:
    - type: repo_permission
      value: TML-4PM/the-pen admin/write confirmed through GitHub connector
    - type: artifact
      value: connector startup runtime pack committed
  gaps:
    - Bridge runtime invocation not directly available in this ChatGPT session
    - Supabase tables not yet executed
    - Command Centre widget not yet deployed
    - External connector platform reauth cannot be bypassed if provider requires it
  next_action:
    - Bridge executes handoff envelope
    - create Supabase connector tables
    - wire Command Centre connector status widget
    - schedule recurring connector healthchecks
  elevation: high
  pressure_flags:
    - recurring_manual_drag
    - startup_blindness
    - connector_state_not_persistent
  score:
    execution: 0.62
    evidence: 0.70
    economic: 0.78
    reuse: 0.88
    delta: 0.84
    overall: 0.74
```

## Operator Note

This does not magically override OAuth/platform reauthorization rules. It does eliminate avoidable manual discovery by making connector state visible, persistent, testable, repairable where authorised, and bound to the execution spine.
