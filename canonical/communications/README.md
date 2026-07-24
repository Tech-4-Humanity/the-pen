# Canonical Communications Operating System (CCOS)

Runtime-ready canonical source package for reusable communications across T4H.

## Delivered
- 250 substantive communication objects
- 150 governed variables
- 13 sequences and 52 sequence steps
- deterministic renderer
- JSON schema and tests
- workbook export and provenance register

## Build
```bash
python canonical/communications/compiler/build_workbook.py
pytest canonical/communications/tests
```

The CSV/JSON registries are canonical. The workbook is a generated export.
Generated output is PARTIAL until required variables validate. Sent output is REAL only with a send receipt.
