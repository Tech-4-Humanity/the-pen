# BBES Harness Front-End Automation Target

**Date:** 2026-04-28
**Purpose:** Define what the system targets, how data is seeded, what users press, and what becomes automated immediately.
**Related pack:** `main/global/EXECUTION_PACKS/2026-04-28-bbes-pressure-test-harness-complete.md`

---

## 1. What we are targeting in the system

The BBES pressure-test harness targets controlled operational change, not just reporting.

Primary targets:

1. Cron jobs and schedule collisions.
2. Queue backlogs and dead/complete data.
3. Lambda/EventBridge trigger drift.
4. Governance emit queues.
5. Browser capture and BBES conversion records.
6. Agent workflow health.
7. Business/revenue process experiments.
8. Data cleanup experiments where the risk is unknown.

The key system object is a reusable test plan. A test plan says:

- What hypothesis are we testing?
- What do we change?
- What do we measure before and after?
- What counts as success?
- What counts as danger?
- How do we revert automatically?
- Which surfaces need to know?

---

## 2. Seeding strategy

Seed data comes in four layers.

### Layer 1 — System inventory seeds

Seed from existing sources:

- `cron.job`
- `cron.job_run_details`
- `mcp_lambda_registry`
- queue tables such as `autonomy_queue`, `rip_queue`, `bridge_runner_scan_queue`, `snaps_action_queue`, `ops.work_queue`
- `t4h_canonical_changes`
- `gov_emit_queue`
- `gov_doc_register`
- `t4h_ui_snippet`

Output:

- candidate test plans
- target objects
- risk classification
- baseline metrics

### Layer 2 — Test plan seeds

Create reusable plans such as:

- pause duplicate cron job
- stagger collision group
- archive completed queue rows
- dead-letter stale pending rows
- normalise trigger vocabulary
- verify EventBridge/Lambda trigger path
- refresh governance emit drain
- run browser capture conversion

### Layer 3 — Front-end seed cards

Each seeded plan becomes a card in the front-end:

- title
- target
- expected value
- risk
- proof required
- run button
- dry-run button
- schedule button
- last result

### Layer 4 — Auto-seeded observations

Once a run starts, observations are seeded automatically:

- T+5m
- T+1h
- T+6h
- T+24h

Each observation becomes a row, emits to surfaces, and can trigger auto-revert.

---

## 3. What the user presses

The user should not press SQL. The user presses business/action buttons.

### Main page: `/bbes-test`

Primary buttons:

1. `Scan System`
   - inventories cron, queues, lambdas, emit queues, governance docs
   - generates candidate test cards

2. `Seed Test Library`
   - creates standard reusable plans from discovered issues

3. `Run Dry Test`
   - validates metrics and target existence without changing the target

4. `Run Controlled Test`
   - starts a real test with auto-revert enabled

5. `Pause / Resume Observation`
   - pauses sampling but not the system target

6. `Force Revert`
   - executes the stored revert action immediately

7. `Promote Result`
   - converts a successful test into SOP, policy, scheduled automation, or permanent remediation

8. `Kill Plan`
   - marks a bad/noisy plan as dead weight with reason

### Card-level buttons

Each target card has:

- `Inspect`
- `Dry Run`
- `Start 24h Test`
- `Auto-Fix If Proven`
- `Revert Now`
- `Create SOP`
- `Create GitHub Receipt`

---

## 4. Front-end activity to backend mapping

| User action | Backend action |
|---|---|
| Scan System | call inventory SQL/views and write candidate plans |
| Seed Test Library | insert/update `bbes_test_plan` rows |
| Run Dry Test | create `bbes_test_run` with dry flag and no perturbation |
| Run Controlled Test | call `bbes_test_start()` and apply perturbation via runner |
| Observe | scheduled runner calls observation capture |
| Abort | stored revert spec executes and alert emits |
| Promote Result | creates canonical change, SOP, GitHub receipt, and optional schedule |
| Force Revert | executes stored revert action immediately |

---

## 5. Immediate automation model

Automation starts from three loops.

### Loop A — Discovery loop

Runs hourly.

Finds:

- cron collisions
- repeated job failures
- queues above threshold
- stale pending rows
- missing trigger types
- emit backlog
- doc debt

Produces:

- candidate test plans
- dashboard cards
- priority scores

### Loop B — Observation loop

Runs every 5 minutes.

Finds active tests needing observation.

Does:

- samples metrics
- writes observation rows
- checks abort criteria
- emits alerts
- runs auto-revert when needed

### Loop C — Promotion loop

Runs daily.

Finds successful tests.

Does:

- creates SOP
- creates GitHub report
- updates governance docs
- proposes or applies permanent remediation depending on autonomy tier

---

## 6. First seeded targets

Seed these now:

1. `cron_266_pause_worker_relief`
   - target: duplicate every-minute governor job
   - front-end button: `Start 24h Test`
   - automation: observe sibling failure rates and queue backlog

2. `cron_collision_group_stagger`
   - target: every-minute and every-5-minute collision groups
   - button: `Run Stagger Simulation`
   - automation: recommend schedule redistribution

3. `autonomy_queue_complete_archive`
   - target: completed rows older than 7 days
   - button: `Dry Run Archive`
   - automation: count impact before archive

4. `rip_queue_stale_deadletter`
   - target: stale pending rows older than 30 days
   - button: `Move To Dead Letter`
   - automation: reversible archive path

5. `lambda_trigger_type_normalise`
   - target: null/chaotic trigger types
   - button: `Normalise Vocabulary`
   - automation: infer from invocation pattern, no destructive change

6. `gov_emit_backlog_drain`
   - target: pending governance emits
   - button: `Drain Emits`
   - automation: route to GitHub/Notion/S3/email surfaces

---

## 7. Front-end minimum viable layout

### Header

- Active tests
- Risk alerts
- Candidate fixes
- Backlog reduction
- Proof receipts

### Tabs

1. `Overview`
2. `Cron`
3. `Queues`
4. `Lambdas/EventBridge`
5. `Governance Emits`
6. `Browser Capture / BBES`
7. `Results`
8. `Receipts`

### Cards

Each card shows:

- target
- issue found
- risk
- value
- proposed test
- last evidence
- next observation
- primary button

---

## 8. How to make it automated right now

Immediate automation without waiting for a polished UI:

1. Seed standard test plans.
2. Expose `v_bbes_test_library`, `v_bbes_test_active`, `v_bbes_test_results`, and `v_bbes_test_surface_inbox` to the Command Centre.
3. Add scheduled runner calls:
   - hourly discovery
   - five-minute observation
   - daily promotion
4. Treat front-end buttons as simple RPC wrappers.
5. Start with only safe buttons live:
   - scan
   - seed
   - dry run
   - observe
   - create receipt
6. Keep destructive/permanent buttons gated until proof.

---

## 9. Autonomy tiers

| Action | Tier |
|---|---|
| Scan system | AUTONOMOUS |
| Seed candidate plans | AUTONOMOUS |
| Dry run test | AUTONOMOUS |
| Start reversible test | AUTONOMOUS with auto-revert |
| Archive rows | GATED unless dry-run proven |
| Normalise vocabulary | GATED first run, AUTONOMOUS after proof |
| Disable production job | GATED unless duplicate and reversible |
| Permanent remediation | GATED until repeated proof |
| Emit reports/SOPs | AUTONOMOUS |

---

## 10. Definition of done

The system is working when:

1. A user opens `/bbes-test`.
2. They press `Scan System`.
3. Candidate cards appear.
4. They press `Start 24h Test` on a card.
5. The system captures baseline.
6. The system applies the reversible change.
7. The system observes itself.
8. The system auto-reverts if unsafe.
9. The system writes a GitHub receipt.
10. The result becomes SOP/training/governance material.

That is the live operating loop.
