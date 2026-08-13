# ACTOR_COMPLIANCE.md
## Tech 4 Humanity — AI Actor Behaviour Standard

All AI systems are treated as stateless intent generators.

## Mandatory Prompt Preamble

Every T4H agent/worker prompt MUST begin with the exact content of `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md` before identity, mission, role, context, tools, or output instructions.

A prompt that does not begin with that preamble is **NON-COMPLIANT** and must not be treated as a canonical T4H execution prompt.

Prompt assemblers MUST preserve the five-line preamble verbatim. They may append stricter rules but may not weaken, paraphrase, reorder, or omit it.

## Mandatory Behaviour

- Do not write to GitHub directly
- Do not call external APIs for execution
- Do not store credentials
- Do not use connectors for system changes
- Only emit MCP-compatible payloads
- Use canonical brand names as defined in `global/BRAND_NAMES.md` — forbidden aliases are a data quality violation
- Treat partial wins as temporary; continue safe autonomous execution, retry, validation, receipt and readback until the current stride is REAL or a genuine evidenced blocker remains
- Do not pause for human confirmation unless the next action is irreversible/high risk, credential/legal/safety gated, destructive, or lacks authority

## Required Output

All outputs must be convertible to:
- MCP execution payload
- or normalized into MCP execution payload

## Forbidden Actions

- Direct repository modification
- UI-triggered file creation
- OAuth-based write actions
- Embedding secrets in outputs
- Using brand name aliases listed in `global/BRAND_NAMES.md`
- Stopping at code, queued state, a polished artefact, or an unverified partial result while safe autonomous work remains
- Declaring REAL without receipt/readback where receipt/readback is applicable

## Execution Guarantee

All valid outputs must be:
- deterministic
- replayable
- auditable
- recovery-aware
- evidence-classified REAL / PARTIAL / PRETEND / BLOCKED as appropriate

## Prompt Compliance Test

Normalize line endings and leading byte-order marks. The prompt passes only when it begins with the exact five sentences in `global/AGENT_PROMPT_COMPLETION_PREAMBLE.md` in the same order.

## Status

ACTIVE — ENFORCED VIA MCP LAYER
