# the-pen CDAP P0 Audit Receipt

Date: 2026-06-28
Repository: TML-4PM/the-pen
Issue: #209

## Status

Overall: PARTIAL / BLOCKED

- GitHub write access: REAL
- CDAP artefact commits: PARTIAL
- Workbook binary committed: BLOCKED / MISSING
- Customer effort calculator committed: BLOCKED / MISSING
- Gap-analysis rules committed: BLOCKED / MISSING
- Runtime/deployment: BLOCKED
- Vercel build logs: BLOCKED / NO BUILD EVENTS

## Evidence observed

### Repository access

The repository is accessible and push-capable from the connector.

### Issue #209

Issue #209 exists and remains open: Build Tranche 2 CDAP implementation factory.

### Earlier receipt overstatement

A prior issue comment classified the workbook as REAL and referenced commit `1c645644839f04d08de39fc68afa20713ea8a16d`.

That commit only added:

- `receipts/compliance-ready-aml-master-completion-20260628.md`

It did not commit the workbook binary or the full P0 artefact set.

### Later CDAP artefact commits observed

The following CDAP commits exist on 2026-06-28:

- `a83732218965282d82ab8eda9d6933095615e119` — Add CDAP JSON schema v1
- `f700a28ef8f9e0377aba1378489abe25c456a751` — Add CDAP input output traceability matrix
- `0be9fb2221d1b087ae432a9efc0946c90e10ffaa` — Add CDAP evidence request pack
- `fbd95c1b62570a22ba958837f7a0c4853d093445` — Add CDAP P0 artefact index
- `933b1fdced749908fc6dfbe5ff74ccf89781ab21` — Add CDAP workbook builder script

### Files observed

- `artefacts/tranche2/cdap_schema_v1.json`
- `artefacts/tranche2/input_output_traceability.csv`
- `artefacts/tranche2/evidence_request_pack.txt`
- `artefacts/tranche2/README_P0.md`
- `artefacts/tranche2/workbook_builder.py`

### Artefact quality finding

The committed artefacts are starter/skeleton assets, not a complete P0 pack.

Observed examples:

- JSON schema only defines high-level objects: organisation, ownership, staff, services, evidence.
- Traceability matrix has only four rows.
- Evidence pack is a short checklist.
- Workbook builder creates a workbook if run, but the actual XLSX is not committed.
- P0 index explicitly says workbook binary should be committed through a binary-capable route or reconstructed from the builder script.

## Vercel status

Vercel projects checked:

### the-pen

- Project ID: `prj_VGPFRbXPULFkrjFjkkkoqYorjBZB`
- Live: false
- Latest deployment: `dpl_D7iJKKu3GSAXpUrRrYGUQRVYBsd8`
- Ready state: BLOCKED
- Build logs: no build log events found

### the-pen-kt5s

- Project ID: `prj_Dl0sZdKm8AZQWGfcV9vXmxbEeN9p`
- Live: false
- Latest deployment: `dpl_6ME676FjSBmLtQxMeonEXPuNKaCt`
- Ready state: BLOCKED
- Build logs: no build log events found

GitHub combined status for latest checked commit `933b1fdced749908fc6dfbe5ff74ccf89781ab21` shows both Vercel contexts failed:

- `Vercel – the-pen`: failure
- `Vercel – the-pen-kt5s`: failure

The target URLs point to Vercel team invite/auth paths, indicating the failure is likely Vercel Git/team access or project linking, not application code compilation.

## Classification

PARTIAL:

- Some CDAP P0 source artefacts now exist in GitHub.
- The repo has a builder script capable of generating an XLSX locally.

BLOCKED:

- Vercel deployments are blocked and not live.
- No build log events exist.
- Actual workbook binary is not committed.
- Customer effort calculator is not committed.
- Gap-analysis rules are not committed.
- No runtime receipt proves the Pen worker executed the artefact pack.

## Required recovery actions

1. Fix Vercel Git/team integration for both `the-pen` and `the-pen-kt5s`, or disconnect Vercel from this non-app repo if it is only an inbox/receipt repository.
2. Commit the actual generated workbook binary through a binary-capable path or add a CI workflow that runs `artefacts/tranche2/workbook_builder.py` and uploads/commits the generated XLSX.
3. Commit missing artefacts:
   - `artefacts/tranche2/customer_effort_calculator.csv`
   - `artefacts/tranche2/gap_analysis_rules.json`
   - regulatory obligation mapping matrix
   - training assignment rules
   - generated artefact inventory
4. Replace the current skeleton schema with a complete canonical schema covering every workbook sheet and field.
5. Expand traceability so every field maps to at least one output, control, evidence item, or obligation.
6. Post a corrected issue #209 receipt classifying the state as PARTIAL/BLOCKED until the above receipts exist.
