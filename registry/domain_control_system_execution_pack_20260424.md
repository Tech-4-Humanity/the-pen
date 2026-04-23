# Domain Control System — Execution Pack

Date: 2026-04-24  
Status: PARTIAL / BUILD-PACK CREATED  
Source: AWS Route 53 hosted zone export from ChatGPT session  
GitHub schema seed: `registry/aws_hosted_zone_registry_20260424.sql`  
Schema commit receipt: `646040330f6ac84e5b8ceb0f04ce2be237c60a00`

## Purpose

Create one governed domain control system across:

- AWS Route 53 as source evidence
- Supabase as system of record
- GitHub as durable versioned artefact store
- Notion as human governance/control layer
- Command Centre as operational view

This system replaces memory-based domain assumptions with evidence-based registry state.

## Core Supabase Table

`registry.aws_hosted_zone_registry`

Primary functions:

1. Store all observed AWS Route 53 hosted zones.
2. Preserve raw AWS evidence.
3. Classify canonical, candidate, deprecated, kill, blocked and unknown domains.
4. Mark runtime status: active, inactive, redirect, parking, mail_only, expired, unknown.
5. Bind every domain to Reality Ledger state: REAL, PARTIAL, PRETEND, BLOCKED.
6. Preserve GitHub, Notion and AWS references.
7. Avoid deletion by using `archived_at`.

## Key Views

### `registry.v_aws_hosted_zone_registry_active`

Use for the normal Command Centre domain registry view.

### `registry.v_aws_hosted_zone_registry_attention`

Use for domains needing action:

- candidate
- kill
- blocked
- unknown
- inactive
- expired
- not REAL

## Notion Database Schema

Create Notion database: `Domain Registry`

Parent page is required by the Notion connector. Once parent page ID is available, create the database with this schema:

```sql
CREATE TABLE (
  "Domain" TITLE,
  "Canonical Status" SELECT('observed':gray, 'canonical':green, 'candidate':yellow, 'deprecated':orange, 'kill':red, 'blocked':red, 'unknown':gray),
  "Domain Status" SELECT('active':green, 'inactive':gray, 'redirect':blue, 'parking':yellow, 'mail_only':purple, 'expired':red, 'unknown':gray),
  "Business Group" SELECT('G1_CORE':blue, 'G2_SIGNAL':purple, 'G3_MISSION':green, 'G4_RETAIL_ENTRY':orange, 'G5_FUN_SIGNAL_SURFACE':pink, 'RESEARCH':gray, 'PERSONAL':yellow, 'UNKNOWN':gray),
  "Hosted Zone ID" RICH_TEXT,
  "Zone Type" SELECT('Public':green, 'Private':yellow),
  "Record Count" NUMBER,
  "Mail Control" CHECKBOX,
  "Reality State" SELECT('REAL':green, 'PARTIAL':yellow, 'PRETEND':red, 'BLOCKED':red),
  "Website" URL,
  "GitHub Source Path" RICH_TEXT,
  "Supabase Project Ref" RICH_TEXT,
  "Evidence Ref" RICH_TEXT,
  "Last Verified" DATE,
  "Notes" RICH_TEXT
)
```

## Notion Sync Rules

Supabase remains source of truth.

Notion may update:

- canonical_status
- domain_status
- business_group
- website_url
- notes

Notion must not overwrite:

- hosted_zone_id
- hosted_zone_name
- evidence_ref
- record_count unless refreshed from AWS
- reality_state unless backed by evidence

## Automation Layer

### Lambda 1: `t4h-route53-domain-sync`

Purpose:

- list Route 53 hosted zones
- upsert into Supabase table
- preserve AWS hosted_zone_id
- update record_count
- set evidence_ref
- write audit row

Schedule:

- EventBridge daily
- manual Bridge trigger allowed

Pseudo-flow:

```text
start
  get hosted zones from AWS Route53
  for each zone:
    normalize domain
    upsert registry.aws_hosted_zone_registry
    write registry.aws_hosted_zone_registry_audit action='sync'
  return summary
end
```

### Lambda 2: `t4h-domain-health-check`

Purpose:

- DNS resolution check
- HTTPS check
- SSL expiry check
- redirect capture
- classify domain_status
- promote REAL only if evidence exists

Rules:

- DNS + HTTPS reachable = REAL candidate
- DNS only + mail records = mail_only
- no DNS = inactive / unknown
- expired SSL = attention
- domains marked kill remain kill unless human override

### Lambda 3: `t4h-domain-notion-sync`

Purpose:

- Push Supabase rows into Notion
- Pull allowed governance fields from Notion back into Supabase
- Never let Notion destroy AWS evidence

Requires:

- NOTION_TOKEN
- NOTION_DOMAIN_REGISTRY_DATABASE_ID
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY

### Lambda 4: `t4h-domain-kill-pipeline`

Purpose:

- Process kill candidates
- Move to gated execution queue
- Produce instructions, not destructive delete by default
- Archive only after explicit evidence-backed decision

Default mode:

- DRY_RUN

## Bridge Invocation Envelopes

### Route53 Sync

```json
{
  "action": "invoke_function",
  "function_name": "t4h-route53-domain-sync",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "execute",
    "source": "aws_route53",
    "target": "supabase.registry.aws_hosted_zone_registry"
  },
  "metadata": {
    "request_id": "domain-sync-20260424",
    "source": "the-pen",
    "timestamp_utc": "2026-04-24T00:00:00Z",
    "auth_context": "service_role"
  }
}
```

### Health Check

```json
{
  "action": "invoke_function",
  "function_name": "t4h-domain-health-check",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "execute",
    "scope": "active_registry"
  },
  "metadata": {
    "request_id": "domain-health-20260424",
    "source": "the-pen",
    "timestamp_utc": "2026-04-24T00:00:00Z",
    "auth_context": "service_role"
  }
}
```

### Notion Sync

```json
{
  "action": "invoke_function",
  "function_name": "t4h-domain-notion-sync",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "execute",
    "direction": "bidirectional_guarded",
    "source_of_truth": "supabase"
  },
  "metadata": {
    "request_id": "domain-notion-sync-20260424",
    "source": "the-pen",
    "timestamp_utc": "2026-04-24T00:00:00Z",
    "auth_context": "service_role"
  }
}
```

## Command Centre Widget Requirements

Widget name: `domain-control-system`

Cards:

1. Total hosted zones
2. Canonical domains
3. Attention required
4. Kill candidates
5. Mail-only domains
6. Non-REAL rows

Table columns:

- Domain
- Canonical Status
- Domain Status
- Business Group
- Records
- Mail Control
- Reality State
- Last Verified
- Notes

Filters:

- canonical only
- attention only
- kill candidates
- mail only
- non-REAL

## Current Special Classifications

### Correct canonical URLs confirmed by user

- consentx.org
- gcbat.org
- workfamilyai.org

### Kill / non-canonical candidate

- missioncritical.com.au

Reason: user stated Mission Critical is not a valid owned operating concept and likely arose from earlier LLM drift. Keep AWS evidence but remove authority.

## Proof Gates

A domain row is REAL only when:

1. AWS hosted zone exists.
2. DNS check completed.
3. Website or mail intent confirmed.
4. Evidence ref exists.
5. Last verified timestamp is current.
6. Reality Ledger or audit row records the verification.

Until then, imported rows remain PARTIAL.

## Completion Definition

This system is complete when:

- SQL migration has run in Supabase
- Route53 sync Lambda deployed
- health-check Lambda deployed
- Notion database created and database ID stored
- bidirectional guarded Notion sync working
- Command Centre widget reading live Supabase view
- kill candidates visible but not destructively actioned without gated approval

## Operational Rule

Use data, not memory.  
Do not create brand/domain truth from chat memory.  
Observed AWS records are evidence, not automatic business authority.
