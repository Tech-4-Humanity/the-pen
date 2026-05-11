# drain doctrine

**One rule: a thing is either REAL or it is not. PARTIAL is the default. ARCHIVE is earned.**

---

## status values

| status | meaning |
|---|---|
| `REAL` | execution happened, evidence exists, no unresolved gaps |
| `PARTIAL` | progress made, receipts missing or gaps open |
| `BLOCKED` | cannot continue from this context — dependency on another actor or environment |

Default everything to `PARTIAL`. Upgrade to `REAL` only when evidence criteria are met.

---

## what counts as REAL

All of these must be true:

- At least one `evidence` item is of type `commit_id`, `receipt_ref`, or a verified live URL with smoke result
- `gaps` is empty — or each remaining gap is explicitly marked `accepted: true` with a stated reason
- No text in the item contains "Outstanding tasks", "Next action", or "Gaps" unless those items are struck-through or marked completed

If `evidence_required: true` and there is no `commit_id` or `receipt_ref` → REAL is **forbidden**.

---

## what ARCHIVE means

ARCHIVE ≠ summarised. ARCHIVE ≠ long and detailed.

You may only ARCHIVE when:

- `status: REAL`
- `evidence_required: false` **or** all required evidence is recorded
- No unresolved `next_action` items
- No unresolved `gaps`

If the text contains "Outstanding tasks", "Next action chain", or "Gaps" → `mode` must be `CHECKPOINT` or `HANDOFF`, never `ARCHIVE`.

---

## mode values

| mode | when to use |
|---|---|
| `CHECKPOINT` | capture state + next actions; keep active; no execution complete |
| `HANDOFF` | PARTIAL/BLOCKED with a clear next-action chain; stays open until another actor produces evidence |
| `ARCHIVE` | REAL only; execution done; receipts written; no open tasks |

---

## example classifications

| item | correct status | correct mode | why |
|---|---|---|---|
| Org Atom table with outstanding cells, no wave10 evidence, no receipt | `PARTIAL` | `CHECKPOINT` | IP mature but no execution evidence |
| DRA deploy with HTML not at root, env vars not confirmed, no reality_ledger row | `PARTIAL` | `HANDOFF` | Build live but finish-line not crossed |
| ChatGPT thread, no title, no useful content | skip | `KILL` | BLAND — discard without evidence requirement |
| Any item with commit SHA + receipt_ref + smoke result | `REAL` | `ARCHIVE` | All criteria met |

---

## invariants (never break these)

1. Long narratives and detailed summaries do not qualify as REAL without execution evidence.
2. A `HANDOFF` stays open until the next actor returns a receipt. Do not auto-close.
3. `kill` / discard is valid only for items with `importance: BLAND` and `evidence_required: false`.
4. If `importance` is `IP` or `STRATEGIC`, `evidence_required` is always `true`.
5. Re-processing the same item with the same parameters must not create duplicate receipts (idempotency).
