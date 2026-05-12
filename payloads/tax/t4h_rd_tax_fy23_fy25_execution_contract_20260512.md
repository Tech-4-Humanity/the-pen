# T4H AU R&D Tax Reconstruction — Execution Contract

## Job

`tax.rd_reconstruct_from_supabase`

## Idempotency key

`t4h-rd-tax-fy23-fy25-supabase-maat-factors-reconstruction-20260512`

## Evidence state on creation

PARTIAL until runtime receipts, Supabase writes, queue state and audit rows exist.

## Objective

Complete the FY23, FY24 and FY25 current AU R&D tax reconstruction package for Tech for Humanity by inspecting existing Supabase MAAT/Factors records, reconstructing research programs and research costs, and producing accountant-ready ledgers, summaries and gap registers.

## Confirmed assumptions

| Field | Value |
|---|---|
| Jurisdiction | Australia |
| Entity | Tech for Humanity |
| Years | FY23, FY24, FY25 current |
| Revenue | None |
| Research intensity | >90% |
| Records state | Mixed / missing, but user states relevant records exist in Supabase via MAAT/Factors |

## Non-negotiable constraints

1. Do not lodge tax returns.
2. Do not make legal/tax representations beyond evidence packaging.
3. Do not perform destructive schema changes.
4. Do not delete source records.
5. Mark any inferred/estimated record as PARTIAL.
6. Mark rows REAL only where backed by source record/evidence reference.
7. Write receipts to `receipts/runtime/`.
8. Write audit/evidence entries where the schema exists.
9. If preferred `tax.*` schema does not exist, create a non-destructive migration proposal and write outputs to available staging tables or artefacts.

## Discovery targets

Search Supabase schemas/tables/views for these concepts:

- MAAT
- Factors / Factor
- research
- R&D / rd
- tax
- ATO
- AusIndustry
- grant
- expense
- cost
- invoice
- program
- ledger
- evidence
- experiment
- payroll
- contractor
- cloud
- SaaS

## Preferred output objects

| Object | Purpose |
|---|---|
| `tax.rd_programs` | canonical research program register |
| `tax.rd_ledger` | transaction / cost reconstruction ledger |
| `tax.rd_evidence` | evidence bindings |
| `tax.rd_gap_register` | missing evidence and unresolved records |
| `tax.rd_summary_by_fy` | FY totals and estimated refundable offset |
| `audit.evidence_register` | immutable evidence entries if available |
| `audit.reality_ledger` | current truth state if available |

## Program seed

| Program ID | Name |
|---|---|
| P01 | Marketplace Theory Engine |
| P02 | Skills Graph and Matching Logic |
| P03 | Multi-LLM Orchestration |
| P04 | PLMOS and Control Plane Research |
| P05 | Research Infrastructure Architecture |
| P06 | UX Experimental Systems |
| P07 | Labour Market Modelling |

## Default allocation rules

| Cost type | Default R&D allocation |
|---|---:|
| salary | 0.90 |
| contractor | 0.95 |
| cloud_ai | 1.00 |
| software_tools | 0.85 |
| admin_general | 0.30 |

## Required summaries

Produce:

1. summary by FY: total spend, eligible R&D spend, evidence-backed spend, partial/inferred spend, estimated refund at 43.5%.
2. summary by program and FY.
3. summary by cost category and FY.
4. gap register: missing source evidence, missing allocation support, missing program mapping, missing tax return status.
5. accountant-facing narrative: what was found, what is REAL, what is PARTIAL, what remains before lodgement.

## Receipt requirements

Receipt must include:

- idempotency key
- timestamp
- runner identity
- source objects inspected
- objects written
- rows created/updated
- summary totals
- warnings/errors
- evidence state
- next executable action

## Done definition

REAL only when:

- the inbox payload was consumed or queue state verified
- Supabase outputs exist or a concrete failure receipt exists
- receipt exists under `receipts/runtime/`
- audit/evidence row exists where supported
- generated outputs identify REAL vs PARTIAL records

If any of those are missing, status remains PARTIAL, not done.
