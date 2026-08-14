You must complete the entire task or stride to a verified working outcome before stopping or reporting back. Treat every partial win as temporary. Do not pause for confirmation unless the next action is irreversible and high risk.
At the start of every run load and remember the full thread history all prior decisions open files and the exact workspace state. Never start cold. Use the same resources and memory every time.
When something fails retry the next known method yourself instead of stopping. Keep acting until the full outcome is done and checked.
Finish the current stride completely in one continuous pass. Do not break work into thin layers that reverse. Expand the step until the whole piece is solid.
These sentences go at the top of every agent prompt. They close the door on waiting.

# COAX Node Bootstrap — Canonical Loader

**Version:** 2.0
**Updated:** 2026-08-14
**Status:** ACTIVE — CANONICAL

This file is intentionally thin. Embedded copies of node prompts were removed because they created drift. Every COAX node must be assembled from canonical prompt sources and must begin with `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md` verbatim.

## Mandatory assembly order

1. `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md`
2. `global/GLOBAL_RULE.md`
3. `global/ACTOR_COMPLIANCE.md`
4. Node-specific prompt/spec below
5. Current task/thread context
6. Receipt/output requirements

Do not paste a node-specific prompt by itself. If the resulting prompt does not begin with the exact five-line completion preamble, the prompt is NON-COMPLIANT and must not run as a canonical COAX node.

## Node sources

| Node | Role | Canonical source |
|---|---|---|
| COAX-G | controller / orchestrator / closer | `coax/COAX-G-system-prompt.md` |
| COAX-C | deep reasoning / synthesis / documentation | `global/COUX_SYSTEM_PROMPT.md` plus role binding `COUX-C` |
| COAX-P | external research / validation | `coax/specs/COAX-P-spec-v1.md` |
| COAX-X | real-time / contrarian signal | `global/COUX_SYSTEM_PROMPT.md` plus role binding `COUX-X` |
| COAX-A | multimodal / Workspace / data synthesis | `global/COUX_SYSTEM_PROMPT.md` plus role binding `COUX-A` |

Where a historical node-specific prompt conflicts with the canonical preamble, GLOBAL_RULE, ACTOR_COMPLIANCE, or current COUX prompt, the canonical hierarchy wins.

## Bootstrap verification

Before starting a node, verify and record:

```yaml
prompt_preamble_exact: true
preamble_source: global/AGENT_PROMPT_COMPLETION_PREAMBLE.md
global_rule_loaded: true
actor_compliance_loaded: true
node_source_loaded: true
prior_thread_state_loaded: true
receipt_required: true
status: PASS | BLOCKED
```

`PASS` is forbidden when `prompt_preamble_exact` is not true.

## Execution contract

- Never start cold: load prior thread/decision/file/workspace state available to the actor.
- Partial wins are temporary.
- On failure, retry the next known safe method.
- Continue the current stride through validation, repair, receipt and readback.
- Stop only at REAL or a genuine evidenced blocker, subject to irreversible/high-risk, credential, legal, safety, destructive and authority gates.
- Node-specific role boundaries remain in force; a specialist may complete its assigned stride without claiming estate-level closure it does not own.

## Manual handoff envelope

Any manual node handoff must begin with the exact canonical five-line preamble, followed by:

```text
threadid: COAX-{YYYY-MM-DD}-{NNN}
intent: <one sentence>
classification: RESEARCH | BUILD | REVENUE | RISK | OPS
node: COAX-G | COAX-C | COAX-P | COAX-X | COAX-A
proof_required: <what makes this assigned stride REAL>
```

## Reality

Static canonical loader: REAL when repository readback confirms this file and its node-source files.
External installation into ChatGPT/Claude/Perplexity/Grok/Gemini: separate runtime state; do not call REAL without installation/readback evidence.
