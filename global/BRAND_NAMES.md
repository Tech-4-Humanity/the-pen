# BRAND_NAMES.md
## Tech 4 Humanity — Canonical Brand Name Register

**Version**: 1.0 (2026-05-15)
**Status**: ACTIVE — ENFORCED
**Authority**: GLOBAL_RULE.md hierarchy

---

## Rule

All AI actors MUST use canonical brand names when generating job titles, descriptions, payloads, and any written output.

Using an alias or informal shorthand in system-generated output is a **data quality violation**.

---

## Canonical Names

| Canonical brand name | Domain | Forbidden aliases |
|---|---|---|
| holo-org.com | holo-org.com | HoloOrg, Holo Org, HoloOrg.com, holoorg |
| WorkFamilyAI | workfamilyai.com | WorkFamily AI, Work Family AI, WFAI (in titles) |
| Augmented Humanity Coach | ahc.holo-org.com | AHC (in titles), AugmentedHumanity |
| ConsentX | consentx.org | Consent X, ConsentEx |
| Outcome Ready | outcome-ready.com | OutcomeReady, Outcome-Ready |
| Tradie AI | ai4tradies.org | TraidieAI, Tradie-AI |
| SmartPark | smartpark.tech4humanity.net | Smart Park, smartpark |
| Tech 4 Humanity | tech4humanity.com.au | T4H (in titles), Tech4Humanity, Tech for Humanity |
| MedLedger | medledger.com.au | Med Ledger, Medledger |
| Enter Australia | enteraustralia.tech | EnterAustralia, Enter-Australia |

---

## Scope

This applies to:
- `ops.work_queue` title and description fields
- `ops.job_receipts` proof_ref fields
- GitHub commit messages
- Any agent-generated written output

---

## Enforcement

Any actor generating output with a forbidden alias MUST be corrected at the prompt layer.
Job titles already in the DB with forbidden aliases are data debt — do not propagate.

---

## Change Log

- **2026-05-15 v1.0** — Created. holo-org.com / HoloOrg alias violation identified in COUX-generated job titles. All actors notified.
