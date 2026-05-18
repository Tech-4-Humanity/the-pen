# PEN Poller — Canonical Loop Architecture

**Status:** CANONICAL · **Effective:** 2026-05-18 · **HITL:** none (infra autonomy)

This document is the single operational truth for how inbox payloads in `the-pen`
are picked up, executed via the bridge, and receipted. It supersedes all prior
ad-hoc descriptions of "the poller".

## The problem this closes

Two JSON inbox payloads stalled because the legacy dispatch ran on a slow `*/30`
schedule **and** wrapped the job in a `{idempotency_key, job, source,
requested_state}` envelope the bridge cannot parse. Result: silent FAILED/PARTIAL
receipts, up to 30-minute pickup latency, and ~720 no-op Actions runs/day from a
separate every-2-minute cron that self-skipped because its script was missing.
Under `GLOBAL_RULE_KERNEL_V6` that is orphan compute + runtime drift +
parallel-state conflict.

## Canonical topology (3 workflows, 1 truth)

| Workflow | Role | Trigger | Envelope | HITL |
| --- | --- | --- | --- | --- |
| `pen-inbox-dispatch.yml` | **PRIMARY executor** | push to `inbox/**` (instant) + `workflow_dispatch` | flat `{idempotency_key, fn, payload, source, mode}` | none |
| `pen-queue-cron.yml` | **SWEEP backstop** | `*/30` schedule + manual | same flat envelope | none |
| `pen-dispatch.yml` | **RETIRED** | `workflow_dispatch` only | none (no bridge call) | none |

**Primary** fires within seconds of any `inbox/**` commit — event-driven, not
polling. This is the correct place for the work to run: zero cron overhead,
no latency, idempotent (skips any payload that already has a final receipt),
and hard-gated so destructive / credential / payment payloads are BLOCKED to a
controlled path rather than auto-executed.

**Sweep** is the only remaining scheduled job. It exists solely to catch
payloads committed during an Actions outage or a missed push event. It uses the
same correct envelope and is idempotent, so it can never double-execute or
conflict with the primary path.

**Retired** keeps the historical state-count rollup as a manual read-only
utility (archive-never-delete) but has no schedule and makes no bridge calls,
so it can no longer emit bad receipts or burn minutes.

## Invariants (do not regress)

- Exactly **one** scheduled workflow (`pen-queue-cron.yml`). Never add a second cron.
- Every executor uses the **flat** bridge envelope. The `{job: job}` wrapper is forbidden.
- Every payload yields a receipt; idempotency key + existing final receipt = skip.
- Hard gate on destructive/credential/payment terms → `BLOCKED`, never silent execute.
- No HITL on infra. HITL is reserved for the kernel's bounded list only
  (legal boundary, destructive action, financial-authority threshold,
  credential issuance, regulatory submission, ethical override).

## Economic rationale (kernel: economic_self_regulation)

- Eliminated ~720 no-op Actions runs/day (the dead `*/2` cron).
- Eliminated a redundant `*/30` cron running a broken envelope.
- Pickup latency: ~30 min → seconds (push-triggered primary).
- Net scheduled compute: 2 crons → 1 idempotent sweep.
