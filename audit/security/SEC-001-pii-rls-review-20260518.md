# SEC-001 · PII / RLS Exposure Review — pflisxkcxbzboxwidywf

**Date:** 2026-05-18 (Mon, Sydney)
**Project:** Supabase `pflisxkcxbzboxwidywf` (S2 / consumer-retail tenant — Apex, AI Oopsies, Books, ConsentX, etc.)
**Trigger:** Supabase security advisor + Lovable scanner screenshot (9 errors / 13 warnings)
**Classification:** Pre-production hardening (NOT a notifiable breach)
**Status:** PARTIAL — critical read-leaks closed; lower-severity items open
**Ledger:** `90894597-25b6-4d64-b393-0aeeee6ea3e4`

---

## 1 · Summary

A Supabase/Lovable scan flagged regulated-looking tables (`prescriptions`, `prescription_imprints`, `health_documents`, `sms_notifications`) as readable by anyone on the internet via RLS policies with `qual = true`. The misconfiguration was real and was closed surgically. **However**, a data check performed *after* remediation showed the three health tables are **empty (0 rows)** and the only populated sensitive table (`sms_notifications`, 28 rows) is **seed/test data** (2 distinct emails, 14/28 matching test patterns, 0 customer profiles, 3 dev auth users). There was **no exposure of any real individual's personal information** and therefore **no notifiable data breach**. The RLS fixes are retained as correct pre-emptive hardening.

---

## 2 · Verified findings (data-backed)

| Table | Rows | Nature | RLS leak real? | Real PII exposed? |
|---|---|---|---|---|
| `prescriptions` | **0** | empty | Yes (`qual=true` SELECT) | No — empty |
| `prescription_imprints` | **0** | empty | Yes (`qual=true` SELECT) | No — empty |
| `health_documents` | **0** | empty | Yes (`qual=true` SELECT) | No — empty |
| `sms_notifications` | 28 | seed/test (Aug 2-5 2025, 2 emails, 0 profiles) | Yes (`qual=true` ALL) | No — synthetic |
| `bookings` / `waitlist` | n/a | `OR true` defeated email scope | Yes | No real rows |

Project-wide context (confirms pre-production): `auth.users = 3` (dev), `profiles = 0`, `orders = 0`, `donations = 0`, `email_captures = 0`, `user_certificates = 0`, `partner_applications = 0`, `leads = 1`, `contact_submissions = 2`.

**Conclusion:** real misconfiguration, zero real-data impact. Privacy Act Notifiable Data Breaches (NDB) scheme **does not apply** — no personal information of individuals was put at likely risk of serious harm.

---

## 3 · Remediation performed (2026-05-18)

Surgical `DROP POLICY` / `CREATE POLICY` only. No data touched. Reversible.

- `prescriptions` — dropped "Anyone can view prescriptions for validation" (`qual=true`)
- `prescription_imprints` — dropped "Anyone can view imprint records" (`qual=true`)
- `health_documents` — dropped "Public QR validation access" (`qual=true`); owner-only retained
- `sms_notifications` — dropped "System can manage notifications" (`qual=true` ALL); owner + active-guardian scope retained
- `bookings` / `waitlist` — replaced `OR true` SELECT with real email-match
- `anonymous_assessments` — dropped `qual=true` SELECT; session-scoped retained
- `detail_requests` — tightened to owner-only

Verified post-fix via `pg_policies` re-query: no `qual=true` public SELECT remains on any sensitive table.

---

## 4 · Process failure (the part that matters)

**What went wrong in handling, not the database:**

The review escalated to "CRITICAL severe data-exposure incident" with a stated "mandatory OAIC notification obligation" **before checking row counts or data provenance**. The tables were empty. The escalation was disproportionate and introduced false legal urgency.

Root cause: a *scanner schema finding* was treated as an *incident* without the intervening evidence step (is there data? whose? real or seed?). The four questions — "how? whose? where? is it seed?" — are precisely the checks that should have preceded any severity claim.

This is the same failure pattern seen earlier in the engagement (catalogue, insurance, cert flow): asserting state before verifying it. Severity inflation is a specific, high-cost instance because it manufactures legal/regulatory alarm.

---

## 5 · Hardened rule (adopted)

**PII / breach severity protocol — mandatory ordering:**

1. **Schema finding ≠ incident.** A scanner/advisor result is a *hypothesis*.
2. **Count before classify.** Before any severity label, run: `SELECT count(*)`, distinct-identity count, date range, and a seed/test-pattern filter on the flagged table(s).
3. **Provenance before escalation.** Determine: real customer data vs. seed/dev/synthetic. Check sibling signals (`auth.users`, `profiles`, transactional row counts) for whether the project is even live.
4. **Severity is evidence-bound.** "Critical" / "breach" / "notifiable" requires *confirmed real personal data* of individuals plus a plausible serious-harm path. No data → "pre-production hardening", not "incident".
5. **Legal/regulatory language is gated.** Never assert a statutory notification obligation (NDB/OAIC, etc.) without step 2–3 evidence. Flag as "assess whether notifiable" only after real PII is confirmed exposed.
6. **Fix is still allowed pre-evidence.** Closing an open `qual=true` policy is safe and non-destructive — *do the fix*, but classify the severity *after* the evidence steps. Action fast; label accurately.

Applied prospectively to all portfolio projects (S1/S2 and the 6 shells).

---

## 6 · Open items (correctly severity-rated this time)

Lower harm — write/exec vectors on a pre-production project, no real data:

- ~85 permissive `INSERT`/`ALL` RLS policies (`with_check=true`) — spam/write vectors. Real but not read-leaks. Triage by table sensitivity.
- 2 anon-callable `SECURITY DEFINER` functions (`campaign_closure_audit_fn`, `handle_new_fax_user`) — revoke EXECUTE or switch to INVOKER.
- 12 public storage buckets allow listing — restrict LIST, keep object GET.
- 10 functions with mutable `search_path` — set explicitly.
- Auth: leaked-password protection disabled — enable.
- Postgres has security patches available — schedule upgrade.

None require legal assessment. All are pre-launch hygiene.

---

## 7 · Receipt envelope

```yaml
record_id: SEC-001-pii-rls-review-20260518
status: PARTIAL
intent: Document PII/RLS exposure review with verified findings + hardened rule
evidence:
  - {type: api_response, value: "prescriptions/prescription_imprints/health_documents = 0 rows"}
  - {type: api_response, value: "sms_notifications=28 rows, 2 emails, 14/28 test-pattern, 0 profiles"}
  - {type: api_response, value: "project-wide: 3 auth users, 0 profiles, 0 orders — pre-production"}
  - {type: database_result, value: "pg_policies re-query confirms no qual=true public SELECT post-fix"}
breach_determination: "NOT notifiable — no real individual PII exposed; NDB scheme N/A"
process_correction: "severity escalated before data check; rule §5 adopted to prevent recurrence"
remediation: "surgical RLS policy fixes, non-destructive, reversible, verified"
open: "85 permissive INSERT/ALL, 2 anon SECDEF fns, 12 listable buckets, 10 mutable search_path, auth pw protection, pg patch"
reusable_rule: "PII severity protocol §5 — count+provenance before classify/escalate"
```
