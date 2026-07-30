# RoutineOps Canonical Workbook v2

Status: PARTIAL runtime / COMPLETE workbook artefact.

Generated workbook:
- Name: routineops_canonical_v2_100_sheet_workbook.xlsx
- Sheets: 100
- Size bytes: 94030
- Routine library rows: 260
- Partner records: 120
- Includes: GitHub receipts, schema.sql line import, commercial models, partner registry, regulatory/evidence matrices, installer/reseller economics, TAM/SAM/SOM.

Runtime gaps:
- No live Supabase migration receipt.
- No live seed-load receipt.
- No deployed /run-tag telemetry.
- No recovery test receipt.

Recovery:
The workbook bytes are committed in the adjacent `.xlsx.base64` file.
To restore:
```bash
base64 -d routineops_canonical_v2_100_sheet_workbook.xlsx.base64 > routineops_canonical_v2_100_sheet_workbook.xlsx
```
