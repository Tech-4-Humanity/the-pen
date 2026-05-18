# Execution Baseline — No Backward Steps

**Status:** ACTIVE doctrine for TML-4PM/the-pen. This file is the canonical floor.
**Established:** 2026-05-18 · derived from the Doolittles runtime build + its failures.

## Purpose

The Doolittles runtime reached REAL through a specific method. This file makes that method the **minimum bar for every future job** — and forbids regressing below it. It is the "copy from here" starting point.

## The loop (every job follows this, in order)

1. **VERIFY against live truth first.** Before building anything, query the real source (DB, repo, deployment). No build on remembered facts. Memory is a hypothesis, not evidence.
2. **tool_search before declaring a limit.** A BLOCKED/PARTIAL classification citing a missing capability is **invalid** unless a logged tool_search returned nothing. Belief is not evidence; a null search result is. (Two failures this session came from skipping this: false 'no SQL path', then false 'SSO blocks me' without trying web_fetch_vercel_url.)
3. **BUILD against verified shape.** Bind to real schema/columns/paths confirmed in step 1 — never guessed.
4. **PROVE by execution.** Run it. Capture the trace (exit code, output, HTTP status). No 'should work.'
5. **RECEIPT with typed status.** REAL only with executed + replayable + receipted evidence. PARTIAL/BLOCKED require a bounded reason. PRETEND is forbidden.
6. **CORRECT in the open.** Wrong memory or a false assertion gets its own FAILURE/correction receipt. Never bury it inside a success.

## No-backward-steps rules

- A job may not be filed REAL if any predecessor receipt in its chain is BLOCKED/FAILED and unresolved.
- A later receipt may supersede an earlier one only by ADDING evidence, never by removing or softening a recorded failure or limitation.
- A remembered number/fact bound to an object must be re-verified against that object before use. (Origin of logged failures: catalog_master '102 rows'; S2 '22 sellable'.)
- Before filing any blocker that cites a missing tool/path/access, a tool_search for that capability MUST be logged. No search, no blocker.
- Anti-fabrication is structural, not aspirational: adapters that cannot reach their canonical source must throw, not invent. Fixtures must be labelled in-band so they can never report as live.

## Reference implementation (copy from here)

- `doolittles/runtime.mjs` — typed contract, deterministic pure core, adapter abstraction.
- `doolittles/catalogue.live.mjs` — live adapter bound to verified schema; refuses to fabricate.
- `doolittles/runtime.test.mjs` — executable proof incl. source-honesty asserts.
- `doolittles/signal-theatre.html` — static zero-build surface, in-band fixture labelling.
- `receipts/doolittles/**` — full two-way chains incl. BLOCKER, IMPLEMENTATION, RUNTIME, CLOSURE, FAILURE, and evidence-adding supersedes.

Any new T4H surface starts by copying this skeleton and its receipt chain. If a step is skipped, the job is not REAL by definition — regardless of what it outputs.
