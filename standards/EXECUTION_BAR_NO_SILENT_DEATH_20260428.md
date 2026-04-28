# Execution Bar: No Silent Death

**Effective date:** 2026-04-28  
**Scope:** All future PEN / Bridge / Dev handoffs unless explicitly downgraded.  
**Doctrine:** A handoff is not complete when it is merely posted. It is complete only when it is accepted into an execution surface with watchdog, proof gates, recovery route, and final receipt.

## Default rule

Every future execution handoff must include:

1. **Named owner surface**
   - PEN issue, Bridge job, Symbio task, GitHub Action, or equivalent.

2. **Runnable artefact**
   - One-command runner, script, payload, workflow, or invocation envelope.

3. **Proof gates**
   - Concrete success strings, exit code, expected file/PR/commit/receipt, and failure classification.

4. **Heartbeat window**
   - Default: 2 hours for urgent execution, 24 hours for non-urgent queue work.

5. **Watchdog fallback**
   - If no proof arrives inside the heartbeat window, the issue/job must be marked stale, commented, and left runnable from a single command.

6. **No silent success**
   - Success without proof is not success.

7. **No silent failure**
   - Silence is a failure signal and must trigger visible escalation.

8. **Reality Ledger classification**
   - REAL / PARTIAL / PRETEND / BLOCKED / STALE must be stated explicitly.

9. **Receipt closure**
   - Close only after terminal tail, commit/PR/job URL, or equivalent machine-verifiable evidence is stored.

## Required handoff template

```markdown
# Execution Handoff

## Mission
<what must happen>

## Artefacts
<files/scripts/payloads>

## Runner
```bash
<one-command runner>
```

## Proof gates
- Required success string:
- Required exit code:
- Required receipt:
- Required commit/PR/job link:

## Watchdog
- Heartbeat window:
- Stale condition:
- Escalation action:
- Recovery route:

## Reality Ledger
| Component | Classification | Evidence |
|---|---:|---|

## Closure rule
Do not close without proof receipt.
```

## Operating principle

Old bar:

```text
Post task → hope someone runs it → silence
```

New bar:

```text
Post task → monitor → detect silence → escalate → recover → prove → close
```

## Application

This standard applies to SPEC-004 and all future execution handoffs from this point forward.
