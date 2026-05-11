# Kernel V3 — Thresholds, Reports, CC Widget

**Lodged:** 2026-05-11 · **Authority:** Pillar 1 (GLOBAL_RULE_KERNEL_V3) + Pillar 2 (AUTONOMY_DOCTRINE_V1)

This document answers three questions:

1. **Do we have thresholds?** Yes — 7 of them, live in `cap_secrets` under the `DOCTRINE_DOMINATE_*` prefix.
2. **Where are reports stored?** 5 places, all real, all queryable. See §2.
3. **CC widget?** Yes — 4 widgets registered on the `command-centre` page (display_order 800-803).

---

## 1 · Live thresholds (from `cap_secrets`)

| Threshold | Value | Purpose |
|---|---|---|
| `DOCTRINE_DOMINATE_COST_CAP_HARD_AUD` | **5** | Hard daily cost cap (AUD). Hit → pause + HITL surface |
| `DOCTRINE_DOMINATE_COST_CAP_SOFT_AUD` | **0** | Soft per-task cost cap. Hit → log + continue |
| `DOCTRINE_DOMINATE_CYCLE_DETECT` | **3** | Same-state hit count before halt+surface (stagnation guard) |
| `DOCTRINE_DOMINATE_FAILURE_BUDGET` | `{read:5/240m, write:2/30m, gated:0/0m}` | Asymmetric retry budget by autonomy class |
| `DOCTRINE_DOMINATE_HITL_CHANNEL` | `{queue:ops.hitl_queue, email:ses, alert_page:cc}` | All three channels fire on hard event |
| `DOCTRINE_DOMINATE_SCOPE_LOCK` | **bounded** | Auto-approve within same biz+wave; new biz/schema/system_key = surface |
| `DOCTRINE_DOMINATE_TRIGGERS` | `{push, seal, dominate, halt, resume}` | Graduated trigger map |

**Edit policy:** thresholds are the *only* knobs an LLM should not silently tune. Change them via direct `cap_secrets` update with a `t4h_canonical_changes` row, severity ≥ NORMAL.

### Kernel scoring (per GLOBAL_RULE_KERNEL_V3)

```python
score = 0.0
if status == "REAL":            score += 0.30
if evidence:                    score += 0.20
if elevation.new_value_created: score += 0.20
if "reusable" in elevation:     score += 0.15
if not gaps:                    score -= 0.20  # hiding gaps = penalty
# Penalties applied separately
stagnation: -0.20 · drag: -0.15 · regression: -0.25
```

**Pressure activation triggers force_rewrite:**
- same output pattern twice
- no new asset
- no execution attempt
- score < 0.5

---

## 2 · Where summaries & reports are stored

| Surface | Storage | What lives there | Read via |
|---|---|---|---|
| **Reality ledger** | `public.reality_ledger` | Per-task outcome rows (REAL/PARTIAL/BLOCKED/PRETEND) with evidence jsonb | `v_cc_kernel_*` views |
| **Canonical changes** | `public.t4h_canonical_changes` | Cross-LLM broadcast log (MILESTONE/SCHEMA_CHANGE/etc) | direct table |
| **Cross-LLM scratchpad** | `public.llm_scratchpad` | Pinned context + working notes | direct table |
| **HITL queue** | `autonomous.hitl_queue` | Items needing human decision (per HITL_CHANNEL config) | direct table |
| **Agent ops ledger** | `agent_ops.v_reality_ledger_24h` | 24h reality slice for autonomy widgets | view |
| **Audit log (legacy)** | `public.reality_ledger` *(audit.log REST 404)* | Per TRAPS-C: write `public.reality_ledger` direct | bridge writes auto-log |

**Canonical destinations for *generated* reports/markdown:**
- `TML-4PM/the-pen/_canon/` — doctrine, schemas, kernel docs (this folder)
- `TML-4PM/the-pen/receipts/` — two-way receipts for job-flow work
- Drive bundles — *staging only*, must be promoted to Pen to count as canonical

**Discovery query (any LLM session):**
```sql
SELECT * FROM public.v_cc_kernel_recent_outcomes;       -- last 30 outcomes
SELECT * FROM public.v_cc_kernel_health_24h;            -- status mix
SELECT * FROM public.v_cc_kernel_open_blocks;           -- open BLOCKED
SELECT * FROM public.v_cc_kernel_thresholds;            -- live thresholds
```

---

## 3 · CC widgets (live)

Registered in `public.t4h_ui_snippet` on `page_key='command-centre'`:

| Slug | Order | Source view | Render |
|---|---|---|---|
| `kernel-thresholds` | 800 | `public.v_cc_kernel_thresholds` | table |
| `kernel-health-24h` | 801 | `public.v_cc_kernel_health_24h` | table |
| `kernel-open-blocks` | 802 | `public.v_cc_kernel_open_blocks` | alert table |
| `kernel-recent-outcomes` | 803 | `public.v_cc_kernel_recent_outcomes` | table |

Widget pattern (matches existing CC snippets):
```html
<div class="widget-card"><h3>Title</h3><div data-source="public.v_cc_kernel_*" data-render="table"></div></div>
```

**Live snapshot at lodge (2026-05-11):**
- REAL: 72 total · 5 in last 24h · 43 in last 7d
- PARTIAL: 24 total · 1 in last 24h · 11 in last 7d
- BLOCKED: 3 (drive bundle JSON/SQL set, Apex AFSL exposure, pen_schema_pcs entry_point_lock)
- PRETEND: 1 historical · 0 in last 7d ✔

---

## 4 · Closure check — contract enforcement

The kernel is **enforced** (not decorative) when *all five* are true:

- [x] thresholds live in `cap_secrets` and queryable
- [x] outcomes write to `reality_ledger` on every execution turn
- [x] BLOCKED items visible without manual lookup (CC widget #802)
- [x] score visible per row (CC widget #803)
- [x] thresholds visible to operator (CC widget #800)

All five ✔ as of this lodge.

## 5 · Open work

1. **Wire `ops.hitl_queue` → widget** — currently HITL queue config exists in cap_secrets but no CC widget surfaces queue depth. Recommend `kernel-hitl-queue` at display_order 804.
2. **Pressure-flag rollup** — add a view that surfaces drag/stagnation/regression counts across last 24h. Currently those flags live inside `evidence->'pressure_flags'` per row but no roll-up view.
3. **Cost-cap consumption widget** — thresholds exist but no widget shows current daily AUD spend vs `DOCTRINE_DOMINATE_COST_CAP_HARD_AUD=5`.
