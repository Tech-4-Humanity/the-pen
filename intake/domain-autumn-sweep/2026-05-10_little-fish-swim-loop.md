# Little Fish Swim Loop — Domain Autumn Sweep

**Task ID:** LITTLE-FISH-DOMAIN-SWIM-2026-05-10  
**Parent Task:** DOMAIN-AUTUMN-SWEEP-2026-05-10  
**Source Artifact:** `intake/domain-autumn-sweep/2026-05-10_domain-url-rankings-autumn-sweep.md`  
**Intent:** Make the registry move automatically row-by-row instead of sitting as a static table.  
**Status:** PARTIAL — execution loop payload posted; Bridge runtime must execute validation and return receipts.  

---

## Plain English

Let the little fish swim.

Each row in the domain table becomes a small autonomous job:

1. Pick one row.
2. Check what it is.
3. Verify what can be verified.
4. Classify it.
5. Write a receipt.
6. Move to the next row.
7. Escalate only when genuinely blocked.

No big-bang rebuild. No waiting for a perfect model. No human loop unless ownership, credentials, money, legal, destructive action, or unresolved identity blocks progress.

---

# Swim Rule

```yaml
loop_name: little_fish_domain_swim
mode: event_driven
batch_size: 1
advance_rule: receipt_written_or_blocked
stop_rule: all_rows_REAL_PARTIAL_BLOCKED
human_loop: only_if_required
```

---

# State Machine

```text
RAW
  → INTAKE
  → ROW_SELECTED
  → TYPE_CLASSIFIED
  → DOMAIN_CHECKED
  → RUNTIME_CHECKED
  → REGISTRY_MATCHED
  → DECISION_ASSIGNED
  → RECEIPT_WRITTEN
  → NEXT_ROW
```

Blocked path:

```text
ANY_STATE
  → BLOCKED_WITH_REASON
  → UNRESOLVED_QUEUE
  → NEXT_ROW
```

---

# Row Execution Contract

Each row must produce one receipt:

```json
{
  "task_id": "LITTLE-FISH-DOMAIN-SWIM-2026-05-10",
  "parent_task_id": "DOMAIN-AUTUMN-SWEEP-2026-05-10",
  "row_number": 1,
  "entity_name": "Tech 4 Humanity",
  "candidate_domain": "tech4humanity.com.au",
  "entity_type": "GOVERNING_BRAND",
  "checks": {
    "domain_present": "UNKNOWN",
    "http_status": "UNKNOWN",
    "runtime_live": "UNKNOWN",
    "registry_match": "UNKNOWN",
    "ownership_evidence": "UNKNOWN",
    "monetisation_evidence": "UNKNOWN"
  },
  "decision": "TRIAGE",
  "status": "PARTIAL",
  "evidence": [],
  "next_action": "Verify DNS/runtime/registry evidence and update decision.",
  "created_at": "2026-05-10"
}
```

---

# Decision Rules

| Condition | Decision |
|---|---|
| Domain owned + runtime live + registry match + business purpose clear | LOCK |
| Domain exists but business/funnel/evidence incomplete | TRIAGE |
| Duplicate or overlapping brand/product | MERGE_REVIEW |
| Domain invalid, unowned, dead, or non-canonical | ARCHIVE |
| Unknown identity or ownership | BLOCKED_UNRESOLVED |
| Runtime broken but asset still strategically useful | RECOVER |
| No strategic use and no evidence | KILL_REVIEW |

---

# Classification Rules

Do not treat every row as a business.

Allowed entity types:

- GOVERNING_BRAND
- COMMERCIAL_BRAND
- PRODUCT
- APP_RUNTIME
- APP_ROUTE
- CORE_SYSTEM
- GOVERNANCE_SYSTEM
- SIGNAL_SURFACE
- MEDIA_SURFACE
- INTERNAL_TOOL
- DOMAIN_ONLY
- ARCHIVE
- UNKNOWN

---

# Minimum Bridge Actions Per Row

For each row:

1. Load row from parent artifact.
2. Assign or preserve stable `entity_id`.
3. Classify `entity_type`.
4. Check candidate domain or URL.
5. Check GitHub/domain registry references.
6. Check Supabase registry references if available.
7. Check Vercel/Lovable/S3/GitHub runtime source if available.
8. Assign decision.
9. Write receipt.
10. Update unresolved queue if needed.

---

# Output Files Required

Bridge should create/update:

```text
receipts/domain-autumn-sweep/row-001.json
receipts/domain-autumn-sweep/row-002.json
...
receipts/domain-autumn-sweep/row-047.json

outputs/domain-autumn-sweep/domain_registry_swim_results.csv
outputs/domain-autumn-sweep/domain_registry_swim_results.json
outputs/domain-autumn-sweep/domain_registry_unresolved_queue.md
outputs/domain-autumn-sweep/domain_registry_lock_candidates.md
outputs/domain-autumn-sweep/domain_registry_archive_candidates.md
outputs/domain-autumn-sweep/domain_registry_merge_candidates.md
outputs/domain-autumn-sweep/domain_registry_recovery_queue.md
```

---

# First Swim Batch

Start with rows 1–5 only, then continue automatically if receipts write cleanly.

| Row | Entity | Expected First Action |
|---|---|---|
| 1 | Tech 4 Humanity / tech4humanity.com.au | Verify governing brand runtime |
| 2 | Tech 4 Humanity / tech4humanity.net | Verify secondary/campaign role |
| 3 | HoloOrg / holoorg.com | Resolve TBC domain |
| 4 | Enter Australia / enteraustralia.tech | Verify commercial runtime/funnel |
| 5 | Oman / enteraustralia.tech/oman | Verify campaign route |

---

# Escalation Rules

Escalate only if:

- credentials are required
- ownership cannot be inferred from available records
- a destructive action is proposed
- legal/regulatory implications arise
- spend is required
- unresolved identity blocks classification

Otherwise continue swimming.

---

# Reality Ledger

```yaml
task_id: LITTLE-FISH-DOMAIN-SWIM-2026-05-10
intent: Convert static domain registry intake into autonomous row-by-row validation loop.
execution: GitHub file creation requested through connected GitHub tool.
output: intake/domain-autumn-sweep/2026-05-10_little-fish-swim-loop.md
status: PARTIAL
evidence:
  - type: github_file
    repo: TML-4PM/the-pen
    path: intake/domain-autumn-sweep/2026-05-10_little-fish-swim-loop.md
pressure_flags:
  - Bridge runtime execution not confirmed in this session
  - Row receipts not yet generated
  - Domain/runtime verification still pending
score: 0.78
next_action: Bridge executes the swim loop row-by-row, writes receipts, and updates canonical registry outputs.
elevation: This turns the registry from a static artifact into an event-driven execution queue where each row moves independently toward LOCK, TRIAGE, MERGE, ARCHIVE, RECOVER, or BLOCKED.
```
