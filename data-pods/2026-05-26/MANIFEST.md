# T4H Data Pod Runtime v1.0 — Integrity Manifest

**Date:** 2026-05-26
**Owner:** Troy Latter / Tech 4 Humanity Pty Ltd (ABN 70 666 271 272)
**Cluster:** `data-pods`
**Canonical repo:** TML-4PM/the-pen
**Canonical store:** Supabase S1 `lzfgigiyqpuuxslsygjt`, schema `pods`
**Ledger sink:** `public.reality_ledger`

## Bound files (SHA-256)

| Path | SHA-256 | Runtime role |
|---|---|---|
| `data-pods/2026-05-26/00_runtime_spec.md` | (existing on main, sha `70cf0199...`) | operating contract |
| `data-pods/2026-05-26/01_supabase_schema.sql` | `09ba50759f58594587217648a7eea3ba7b73a76f8724afb7ff929491aee4ec75` | canonical DDL |
| `data-pods/2026-05-26/02_pod_registry.yaml` | `5c4770ccdc46e969305820aa3ab7df284facfca2d33fe6ad09eede7afcbdb429` | 12-pod registry |
| `data-pods/2026-05-26/03_bridge_envelope.json` | `626b9e05a72dcb140c2952167e32276caa41568c253967ad011b52a120027ea2` | bridge dispatch contract |
| `data-pods/2026-05-26/04_pod00_chief_of_staff_prompt.md` | `926bc3a35f96be6738f6e22cedcf48cce3d3526b5a82d4ed9dc1a0714e43e1db` | POD-00 operating prompt |

## Deployment proof

| Layer | Proof |
|---|---|
| Cluster registration | `core.cluster_registry` row `cluster_id='data-pods'` (P1, active) |
| Schema deployment | Supabase migration `pods_runtime_v1_0_schema` applied 2026-05-26 |
| Tables created | 13 in `pods.*` (pod_registry, pod_runs, memory_objects, entity_registry, recovery_queue, research_audit, product_genome, knowledge_nodes, knowledge_edges, portfolio_health, narrative_memory, opportunity_queue, executive_briefs) |
| Pods seeded | 12 active rows in `pods.pod_registry` (POD-00, LLP-01–06, GDP-01–05) |
| RLS | Enabled on all 13 `pods.*` tables; authenticated read policy installed |
| Ledger entry | `public.reality_ledger` row `cluster_id='data-pods'`, `component='RUNTIME'`, status `PARTIAL` (first POD-00 cycle is the gate to REAL) |

## Open gaps for REAL classification

The runtime is **PARTIAL** until:

1. POD-00 emits its first non-trivial `pods.executive_briefs` row from real deltas, not seed data.
2. At least one pod_run row reaches `status='succeeded'` with a typed evidence object.
3. Scheduler (EventBridge or pg_cron) is wired to invoke POD-00 on cadence.
4. Telemetry continuity proven across at least one delta cycle.

## Promotion path

`PARTIAL → REAL` requires: first real ingest cycle complete + scheduler proof + 3+ pod_run rows with typed evidence + 1 executive_brief with `receipt_hash` set.
