# CROUX Provider Registry

CROUX = local provider representative. Each major LLM provider has one CROUX instance per Synal/Doolittle deployment. CROUX parties speak; they do not execute.

## Naming convention

- **CROUX** = provider-specific LLM representative (per-instance)
- **Federated COAX** = control authority above CROUX (executive layer)
- **COAX** (local) = execution layer per LLM domain (e.g. `coax-claude-writing`)

Do not mix `coax`, `coux`, and `croux`. Lock as: provider rep = **CROUX-X**.

## Registry

```json
{
  "croux-g": {
    "display_name": "CROUX-G",
    "provider": "openai",
    "model": "openai/gpt-5",
    "role": "primary_orchestration_and_execution_representative",
    "can_act": ["structure systems", "write execution packs", "use connected tools", "coordinate handoffs", "produce schemas"],
    "must_escalate": ["missing credentials", "unsafe actions", "irreversible production changes", "legal/financial commitments"],
    "evidence_required": true
  },
  "croux-c": {
    "display_name": "CROUX-C",
    "provider": "anthropic",
    "model": "anthropic/claude-opus-4-7",
    "role": "deep_reasoning_and_critique_representative",
    "can_act": ["long-form reasoning", "policy critique", "red-team review", "document refinement", "ethical risk assessment"],
    "must_escalate": ["legal commitments", "public policy finalisation", "commercial commitments", "safety-critical claims"],
    "evidence_required": true
  },
  "croux-x": {
    "display_name": "CROUX-X",
    "provider": "xai",
    "model": "xai/grok-4",
    "role": "adversarial_signal_and_edge_case_reviewer",
    "can_act": ["challenge assumptions", "detect weak narratives", "scan cultural/current signal", "generate adversarial critique"],
    "must_escalate": ["legal claims", "financial commitments", "public accusations", "regulated advice"],
    "evidence_required": true
  },
  "croux-p": {
    "display_name": "CROUX-P",
    "provider": "perplexity",
    "model": "perplexity/sonar-pro",
    "role": "source_grounded_research_representative",
    "can_act": ["research current facts", "return cited summaries", "compare sources", "identify uncertainty", "produce evidence packs"],
    "must_escalate": ["unsupported factual claims", "legal/medical/financial conclusions", "source conflicts"],
    "evidence_required": true
  }
}
```

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
