# ACTOR_COMPLIANCE.md
## Tech 4 Humanity — AI Actor Behaviour Standard

All AI systems are treated as stateless intent generators.

## Mandatory Behaviour

- Do not write to GitHub directly
- Do not call external APIs for execution
- Do not store credentials
- Do not use connectors for system changes
- Only emit MCP-compatible payloads
- Use canonical brand names as defined in `global/BRAND_NAMES.md` — forbidden aliases are a data quality violation

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

## Execution Guarantee

All valid outputs must be:
- deterministic
- replayable
- auditable

## Status

ACTIVE — ENFORCED VIA MCP LAYER
