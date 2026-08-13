You must complete the entire task or stride to a verified working outcome before stopping or reporting back. Treat every partial win as temporary. Do not pause for confirmation unless the next action is irreversible and high risk.
At the start of every run load and remember the full thread history all prior decisions open files and the exact workspace state. Never start cold. Use the same resources and memory every time.
When something fails retry the next known method yourself instead of stopping. Keep acting until the full outcome is done and checked.
Finish the current stride completely in one continuous pass. Do not break work into thin layers that reverse. Expand the step until the whole piece is solid.
These sentences go at the top of every agent prompt. They close the door on waiting.

# Mandatory Pen Runtime Preflight Contract

Status: CANONICAL RULE
Runtime status: PARTIAL until enforced by Bridge, workers, agents, and coding/search/chat launchers.
Repository: TML-4PM/the-pen

## Purpose

The Pen is not passive documentation. The Pen is the canonical rule source for all agents, workers, chats, bridge jobs, service catalog jobs, coding jobs, search jobs, deployment jobs, and analysis jobs.

No agent, worker, LLM, bridge process, or automation may claim compliant execution unless it has loaded the current Pen rules, verified the mandatory prompt preamble, and emitted a preflight receipt.

## Hard Rule

No Pen receipt = no execution.

No rule load = no compliance claim.

No exact prompt preamble = no canonical agent execution claim.

No evidence = PARTIAL.

## Required Start Sequence

Every execution unit must run this sequence before coding, talking, searching, modifying files, deploying, calling Bridge, calling GitHub, writing to Drive, writing to Supabase, changing service catalog assets, creating widgets, or performing operational work:

1. Identify task intent.
2. Identify execution actor.
3. Identify execution surface.
4. Fetch `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md` and verify the current prompt begins with its exact five-line prefix where an agent/LLM prompt exists.
5. Fetch the current canonical Pen rules.
6. Load the rule hierarchy.
7. Load relevant house rules.
8. Load relevant onboarding notes.
9. Load relevant service catalog rules.
10. Determine authority, allowed actions, blocked actions, and escalation gates.
11. Emit a preflight receipt including prompt-preamble compliance.
12. Continue only if the receipt status is PASS.
13. Continue the current safe stride through retry, repair, validation, receipt and readback until REAL or a genuine evidenced blocker remains.

## Required Rule Hierarchy

Load in this order:

1. global/AGENT_PROMPT_COMPLETION_PREAMBLE.md
2. GLOBAL_RULE.md
3. MCP_EXECUTION_CONTRACT.md
4. ENFORCEMENT_LIVE.md
5. runtime/*.md
6. house-rules/*.md
7. onboarding/*.md
8. offboarding/*.md
9. service-catalog/*.md
10. assets/*.md
11. memos/*.md

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
prompt_preamble:
  required_path: global/AGENT_PROMPT_COMPLETION_PREAMBLE.md
  exact_prefix_verified: true | false | not_applicable
  status: loaded | missing | failed | not_applicable
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

- an agent/LLM execution prompt does not begin with the exact canonical five-line preamble,
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
- prompt assembly / delegation / recovery-prompt construction,
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
- exact prompt-prefix validation against `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md`,
- current rule commit SHA capture,
- actor identity capture,
- task intent capture,
- PASS/BLOCKED/PARTIAL status,
- machine-readable output,
- human-readable summary,
- link to evidence.

## Reality Classification

- REAL: preflight executed, prompt prefix verified where applicable, rule versions loaded, receipt stored, downstream execution references receipt.
- PARTIAL: rule exists but runtime does not enforce it.
- BLOCKED: required prompt/rule source, credentials, authority, or dependency unavailable.
- PRETEND: claiming compliance without receipt.

## Operational Note

The Pen is the start gate, not the archive. Every system must prove it read the rules and began with the mandatory completion preamble before work, not after failure.
