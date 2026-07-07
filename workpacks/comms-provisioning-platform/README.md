# Communications Provisioning Platform Workpack

Status: PARTIAL scaffold
Date: 2026-07-07
Bundle: COMMS-PROVISIONING-PLATFORM-20260707

## Objective

Discover the full Migadu communications estate and generate auditable client provisioning artefacts for macOS and iOS without narrowing scope to a fixed set of canonical accounts.

## Source of truth

Migadu API is the phase-1 provider source. The generated canonical inventory becomes the local artefact source for validation, profile generation, documentation, and future diffing.

## Required runtime environment

The runtime must supply credentials outside GitHub and outside chat:

- `MIGADU_USER`
- `MIGADU_TOKEN`
- Optional: `COMMS_ORG_NAME`
- Optional: `OUTPUT_DIR`

Do not commit secrets.

## Outputs

Expected output directory: `dist/comms-provisioning-platform/`

Generated artefacts:

- `domains.json`
- `mailboxes.json`
- `aliases.json`
- `forwarders.json`
- `catchalls.json`
- `mailboxes.csv`
- `apple-mail.mobileconfig`
- `ios-mail.mobileconfig`
- `inventory.html`
- `validation-report.html`
- `receipt.json`

## Classification

Current state is PARTIAL. GitHub scaffold and bundle commission can be receipted. Live discovery, profile generation, Mac installation, and end-to-end validation require runtime execution on a credentialed endpoint.

## Acceptance criteria

1. Every discoverable Migadu domain appears in `domains.json`.
2. Every discoverable Migadu mailbox appears in `mailboxes.json` and `mailboxes.csv`.
3. Every account in generated profiles maps back to a discovered mailbox record.
4. Validation report explicitly records missing or unverified data.
5. `receipt.json` records counts, timestamps, execution environment, warnings, and artefact paths.
6. No outcome is marked REAL without commit receipt, runtime receipt, and observable telemetry.
