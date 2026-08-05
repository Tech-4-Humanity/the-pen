# Canonical Ingest Quality and Next Waves

## Audited result

The current `20260716T232703Z` run is a valid preservation run for one source root only:

- source type: `mac`
- source root: `daily-index`
- manifest rows: 16,790
- JSON files observed: 1,444
- substantial ChatGPT/OpenAI conversation exports observed
- multiple LinkedIn complete/basic exports observed
- Google My Drive rows: 0
- Google Shared Drive rows: 0

It must not be described as the complete estate.

## Quality strengths

1. SHA-256 content addressing and metadata sidecars.
2. Duplicate classification.
3. Idempotent Python v2 uploader with remote `HeadObject` readback.
4. Upload/verify receipts.
5. Zero observed upload failures during the v2 recovery path.

## Quality defects found

1. Original Bash TSV reader used `IFS/read` against Python CSV-writer output, allowing quoted/tabbed fields to shift columns and create false S3 404 failures.
2. No single-instance lock allowed two resume uploaders to run concurrently.
3. Terminal lifecycle was coupled to the uploader; session restoration interrupted the original process.
4. Source scope was not prominent in the receipt, causing ambiguity about whether the run represented the whole Mac and cloud estate.
5. No final coverage reconciliation for My Drive, Shared Drives, newest LLM exports or newest LinkedIn export.

## Mandatory completion gate for Wave 00

Run:

```bash
python3 scripts/canonical_ingest_quality_gate.py \
  --run "$HOME/t4h-canonical-ingest/runs/20260716T232703Z" \
  --allow-deferred 0
```

`REAL` requires:

- verified rows equal canonical manifest rows
- no FAILED rows
- no MISMATCH rows
- no unresolved deferred rows
- quality report written
- final uploader summary present

## Next sequence

### Wave 01 — Mac remainder inventory

```bash
chmod +x scripts/canonical_ingest_next_wave_inventory.sh
scripts/canonical_ingest_next_wave_inventory.sh
```

This is inventory-only. It excludes the already ingested daily-index root and runtime working directories. Sensitive candidates are quarantined from the ingest manifest.

### Wave 02 — Google My Drive

Inventory the configured `gdrive:` remote first. Native Google Docs, Sheets and Slides require deterministic export formats and must retain source IDs and modification timestamps.

### Wave 03 — Shared Drives

Enumerate every Shared Drive and run one independently receipted subrun per drive. Reconcile duplicates across drives after all subruns finish.

### Wave 04 — Export gaps

Compare newest export dates for ChatGPT/OpenAI, other LLM systems, LinkedIn and mail against what Wave 00 contains. Acquire only missing/newer exports.

## Runtime hardening still required

- PID/file lock around uploader
- detached execution through `nohup`, launchd, tmux or runtime worker
- periodic atomic checkpoints
- deferred-row retry queue
- final S3 `latest` pointer
- source coverage receipt
- no Bash parsing of TSV/CSV data rows
