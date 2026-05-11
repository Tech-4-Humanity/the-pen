# CROUX Provider Registry

CROUX = local provider representative. Each major LLM provider has one CROUX instance per Synal/Doolittle deployment. CROUX parties speak; they do not execute.

## Naming convention

- **CROUX** = provider-specific LLM representative (per-instance)
- **Federated COAX** = control authority above CROUX (executive layer)
- **COAX** (local) = execution layer per LLM domain (e.g. `coax-claude-writing`)

Do not mix `coax`, `coux`, and `croux`. Lock as: provider rep = **CROUX-X**.

## Registry

| Party | Provider | Model | Role |
|-------|----------|-------|------|
| `croux-g` | openai | `openai/gpt-5` | Primary orchestration + execution rep |
| `croux-c` | anthropic | `anthropic/claude-opus-4-7` | Deep reasoning + critique |
| `croux-x` | xai | `xai/grok-4` | Adversarial + edge-case review |
| `croux-p` | perplexity | `perplexity/sonar-pro` | Source-grounded research |

## Authority hierarchy

```
Human (sovereign + override)
  → Federated COAX (decides routing, escalation, proof)
    → CROUX-* (speak: translate, critique, research, propose)
    → Doolittle (translate human ↔ animal/device/signal)
    → Bridge (execute real-world action)
      → Reality Ledger (proof)
```

## Routing patterns

| Mode | Behaviour |
|------|-----------|
| `ask_one` | Single CROUX answers |
| `ask_selected` | All selected CROUX answer in parallel |
| `debate` | CROUX-X challenges CROUX-G/C output |
| `research_then_synthesise` | CROUX-P gathers, CROUX-G synthesises |
| `red_team` | CROUX-X + CROUX-C critique a proposed plan |
| `translate_signal` | Doolittle interprets, CROUX-* explain |
| `decide_and_route` | F-COAX classifies + assigns next step |

## Vercel AI Gateway

All provider calls route through `https://ai-gateway.vercel.sh/v1` using OpenAI-compatible chat completions with `model` field set to the provider/model ID above. This avoids storing per-provider keys in the app and gives a single billing/limit point.

## Authority constraints

CROUX parties **CAN**: think, translate, critique, research, propose.
CROUX parties **CANNOT**: execute tools, change DB state, push code, send funds.

Only Federated COAX + Bridge + Human have execute authority (`can_execute=true` in `doolittle.parties`).

## Per-CROUX escalation rules

### CROUX-G (OpenAI) escalates when
- Missing credentials
- Unsafe actions
- Irreversible production changes
- Legal/financial commitments

### CROUX-C (Anthropic) escalates when
- Legal commitments
- Public policy finalisation
- Commercial commitments
- Safety-critical claims

### CROUX-X (xAI) escalates when
- Legal claims
- Financial commitments
- Public accusations
- Regulated advice

### CROUX-P (Perplexity) escalates when
- Unsupported factual claims
- Legal/medical/financial conclusions
- Source conflicts
- High-reputation-risk outputs
