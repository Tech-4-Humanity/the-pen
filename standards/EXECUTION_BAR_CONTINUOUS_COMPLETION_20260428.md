# Execution Bar: Continuous Completion — Do Not Stop at Close

**Effective date:** 2026-04-28  
**Scope:** All PEN / Bridge / Dev handoffs and future execution loops.  
**Supersedes weak close behaviour:** A handoff, issue, or receipt being closed is not completion unless proof has been stored.

## Core rule

Stopping before proof is failure.

```text
STOPPING CLOSE = FAIL
PROOF CLOSE = COMPLETE
NO PROOF = CONTINUE
```

## Completion means

A task is complete only when the system has all of the following:

1. **Execution evidence**
   - terminal tail, workflow logs, bridge receipt, PR, commit, deployment URL, or equivalent.

2. **Machine-readable success condition**
   - exit code, status field, success phrase, or structured receipt.

3. **Reality Ledger classification**
   - REAL / PARTIAL / BLOCKED / STALE / PRETEND.

4. **Recovery history**
   - if failure occurred, the recovery/retry path is visible.

5. **Next loop removed or scheduled**
   - no open silent dependency remains.

## Continuous loop requirement

Every execution item must operate as:

```text
handoff → run → prove
              ↘ fail/stale → recover → rerun → prove
```

Never:

```text
handoff → close → hope
```

## Default behaviour

If proof is absent:

- keep the issue open, or
- create a successor issue, or
- requeue to Bridge/Symbio/PEN, or
- mark BLOCKED with exact authority/access/runtime dependency.

But do **not** stop.

## Watchdog escalation ladder

1. **T+0** — issue created with runnable artefacts and proof gates.
2. **T+heartbeat** — if no proof, mark `stale`, comment escalation, rerun if authorised.
3. **T+2 heartbeat** — create successor recovery issue or bridge job.
4. **T+3 heartbeat** — classify as BLOCKED only if a real external dependency prevents execution.
5. **Never silently close.**

## Required labels

- `no-silent-death`
- `watchdog-active`
- `continuous-completion`
- one of: `real`, `partial`, `blocked`, `stale`, `pretend`

## Close policy

Allowed close:

```text
REAL + receipt + proof links
```

Disallowed close:

```text
handoff posted only
runner supplied only
waiting for executor
no terminal proof
no exit code
no receipt
```

## SPEC-004 application

SPEC-004 remains open until proof shows:

```text
SPEC004_PATCH_RESULT: applied | already_applied
EXIT_CODE=0
```

If not seen inside heartbeat, it must continue via watchdog recovery, not stop.

## Doctrine

The system is complete when reality is complete, not when the conversation is complete.
