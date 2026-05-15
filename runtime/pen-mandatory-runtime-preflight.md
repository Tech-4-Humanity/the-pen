# Mandatory Pen Runtime Preflight Contract

Status: CANONICAL RULE
Runtime status: PARTIAL until enforced by Bridge, workers, agents, and coding/search/chat launchers.
Repository: TML-4PM/the-pen

## Purpose

The Pen is not passive documentation. The Pen is the canonical rule source for all agents, workers, chats, bridge jobs, service catalog jobs, coding jobs, search jobs, deployment jobs, and analysis jobs.

No agent, worker, LLM, bridge process, or automation may claim compliant execution unless it has loaded the current Pen rules and emitted a preflight receipt.

## Hard Rule

No Pen receipt = no execution.

No rule load = no compliance claim.

No evidence = PARTIAL.

## Required Start Sequence

Every execution unit must run this sequence before coding, talking, searching, modifying files, deploying, calling Bridge, calling GitHub, writing to Drive, writing to Supabase, changing service catalog assets, creating widgets, or performing operational work:

1. Identify task intent.
2. Identify execution actor.
3. Identify execution surface.
4. Fetch the current canonical Pen rules.
5. Load the rule hierarchy.
6. Load relevant house rules.
7. Load relevant onboarding notes.
8. Load relevant service catalog rules.
9. Determine authority, allowed actions, blocked actions, and escalation gates.
10. Emit a preflight receipt.
11. Continue only if the receipt status is PASS.

## Required Rule Hierarchy

Load in this order:

1. GLOBAL_RULE.md
2. MCP_EXECUTION_CONTRACT.md
3. ENFORCEMENT_LIVE.md
4. runtime/*.md
5. house-rules/*.md
6. onboarding/*.md
7. offboarding/*.md
8. service-catalog/*.md
9. assets/*.md
10. memos/*.md

If a higher-priority rule conflicts with a lower-priority rule, the higher-priority rule wins.

## Required Preflight Receipt

Every preflight must emit this structure:

```yaml
receipt_type: pen_preflight
receipt_id:
session_id:
task_id:
actor_id:
actor_type: human | llm | agent | bridge_worker | cron | service_catalog | ci | unknown
execution_surface: chat | bridge | github | vercel | supabase | drive | local | command_centre | other
intent:
repository_context:
service_catalog_context:
asset_context:
rules_loaded:
  - path:
    commit_sha:
    loaded_at:
    status: loaded | missing | failed
relevant_house_rules:
allowed_actions:
blocked_actions:
required_receipts:
required_telemetry:
escalation_required: true | false
escalation_reason:
status: PASS | BLOCKED | PARTIAL
created_at:
```

## Blocking Conditions

The preflight must BLOCK when:

- required rule files cannot be loaded,
- actor identity is unknown,
- task intent is unclear enough to create unsafe execution,
- requested action is destructive and no authority exists,
- credentials or secrets are requested directly,
- financial/legal/safety/identity thresholds are crossed,
- service catalog dependency is missing,
- asset reuse search has not been performed where required,
- Reality Ledger binding is unavailable for a REAL claim,
- execution would create untracked assets,
- no offboarding/session-close path exists for long-running work.

## Runtime Enforcement Points

This rule must be enforced at:

- chat start for operational work,
- agent start,
- bridge job submission,
- bridge worker pickup,
- coding task start,
- GitHub write start,
- Vercel deployment start,
- Supabase write start,
- Google Drive write start,
- Service Catalog request start,
- Command Centre widget creation,
- scheduled job start,
- offboarding/session close.

## Minimum Implementation

A compliant runtime must provide:

- `pen_preflight()` function,
- `pen_receipts` table or equivalent ledger,
- current rule commit SHA capture,
- actor identity capture,
- task intent capture,
- PASS/BLOCKED/PARTIAL status,
- machine-readable output,
- human-readable summary,
- link to evidence.

## Reality Classification

- REAL: preflight executed, rule versions loaded, receipt stored, downstream execution references receipt.
- PARTIAL: rule exists but runtime does not enforce it.
- BLOCKED: required rule source, credentials, authority, or dependency unavailable.
- PRETEND: claiming compliance without receipt.

## Operational Note

The Pen is the start gate, not the archive. Every system must prove it read the rules before work, not after failure.
