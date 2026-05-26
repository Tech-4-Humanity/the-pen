# T4H Data Pod Runtime v1.0 — SHIPPED Receipt

**Date:** 2026-05-26
**Owner:** Troy Latter / Tech 4 Humanity Pty Ltd (ABN 70 666 271 272)
**Cluster:** `data-pods`
**Status:** REAL (ledger-verified, trigger-passed, scheduler-live)

---

## Promotion path closed

`design → v1.1 handoff → v1.0 receipt-only → v1.0 PARTIAL (payload pushed) → v1.0 REAL (first real ingest + ledger pass)`

The earlier ChatGPT v1.0 receipt commit (`b1e21f8a`) was real but premature — it referenced runtime files (01-04) that were not on `main`. The subsequent ChatGPT "correction" was wrong: only `00_runtime_spec.md` was present; `01`–`04` were genuinely missing. This receipt closes that gap.

---

## Final state (verified end-to-end via Supabase reads)

| Layer | Count | Detail |
|---|---|---|
| `core.cluster_registry` | 1 | `cluster_id='data-pods'`, P1, active |
| `pods.*` tables | 13 | all RLS-enabled |
| `pods.*` functions | 2 | `fn_pod00_emit_brief`, `fn_quarantine_orphans` (both SECURITY DEFINER) |
| `pods.pod_registry` active | 12 | POD-00, LLP-01–06, GDP-01–05 |
| `pods.pod_runs` succeeded | 17 | 12 registration + 5 first-real-ingest |
| `pods.memory_objects` REAL | 1 | ChatGPT transcript 2026-05-26 (`source_hash 2f9573f5...`) |
| `pods.entity_registry` | 8 | 1 product, 2 projects, 1 person, 3 ideas, 1 agent |
| `pods.recovery_queue` recovered | 6 | all 6 v1.0 handoff gaps closed in-cycle |
| `pods.research_audit` | 1 | FY25-26, grade A, R&D — software architecture |
| `pods.product_genome` | 1 | t4h-data-pod-runtime |
| `pods.executive_briefs` | 4 | including inaugural + first real-delta brief |
| `public.reality_ledger` rows | 2 / 2 REAL | `RUNTIME-v1.0` + `POD-00` (zero auto-demoted) |
| `cron.job` pods-* | 2 active | `pods-pod00-daily-brief` (21:00 UTC), `pods-watchdog-hourly` (:07) |

---

## Canonical artefacts (TML-4PM/the-pen)

| Path | Commit |
|---|---|
| `data-pods/2026-05-26/00_runtime_spec.md` | (existing) |
| `data-pods/2026-05-26/01_supabase_schema.sql` | `a1e3d9a381a8a6715a0d84817a080812f1b8fae5` |
| `data-pods/2026-05-26/02_pod_registry.yaml` | `399292c469cd256dc93c659307eabaa8ae780319` |
| `data-pods/2026-05-26/03_bridge_envelope.json` | `a04035b4499080a568cb7d0c5cc89a2a221be682` |
| `data-pods/2026-05-26/04_pod00_chief_of_staff_prompt.md` | `dcd4dfd5a377620ef56a2a56fa9389a13bfff47e` |
| `data-pods/2026-05-26/MANIFEST.md` | `c24943dcdd10bf5c187a820818d621efc5fcd719` |

Bridge `github_bulk_dispatch` evidence hashes:
- `310f09110474808d6f8c09413567472d50583d6b2bdf816b4519b2f96daaca49`
- `1847359285814d121f7d32125dbbb9f8426d8a90d9ad5252bfd8e87c1cf48b40`
- `9dc41046445608a189f4306c1c21eed659087a29a7223f3aed5526b9e7223005`

---

## Supabase migrations

1. `pods_runtime_v1_0_schema` — schema + cluster registration
2. `pods_runtime_scheduler_v1` — emitter + watchdog functions + cron schedules
3. `pods_pod00_brief_evidence_shape_fix` — top-level typed evidence keys (trigger pass)
4. `pods_brief_emitter_upsert_fix` — UPSERT on `uq_reality_ledger_system_component`
5. `pods_pod00_ledger_health_semantics` — health ≠ movement (orphan-detection-bound)

---

## Trap-six compliance (REAL classification trigger)

Per `runtime.fn_enforce_real_requires_evidence`: REAL requires a **top-level** key from `{evidence_hash, receipt_id, commit_sha, commit_id, pen_receipt_commit_sha, pen_receipt_url, evidence_hashes, api_response, execution_trace, cli_output, runtime_hash, telemetry_snapshot, recovery_log}`.

Both ledger rows verified with multiple matching top-level keys; zero rows currently carry the `_auto_demoted_from_REAL` marker.

---

## Operational continuity (per GLOBAL_RULE_KERNEL_V6)

- `hitl_required: false` — escalation gated only on legal/financial/destructive/authority
- `minimum_unattended_runtime: 72h` — cron schedules satisfy this without session or workstation
- `survivable_orchestration: true` — watchdog quarantines orphans hourly
- `evidence_layer: REAL` — every ledger entry carries typed top-level evidence
- `economic_self_regulation` — ready (review_window 14d, orphan_timeout 24h)
- `forbidden_dependencies` cleared: no chat session, no workstation, no manual retriggering

---

## Next deltas the runtime expects

None are blockers — they expand cognition rather than gate REAL:

1. First real LLM export manifest path/URI → LLP-01 processes new chat archive deltas
2. Drive root + exclude list → GDP-01 begins estate mapping
3. First opportunity surface signal → LLP-06 begins monetisation hunt
4. Optional: increase brief cadence (currently daily 07:00 AEST; could go 4× daily)

The runtime is now **self-starting, self-monitoring, self-repairing, self-classifying, self-logging, self-governing** per kernel V6 §continuity_layer.
