# T4H Managed MCP — Evidence Validation

Date: 2026-07-13
Work item: GitHub issue #222
Upstream assessed: `Michaelzag/migadu-mcp`
Pinned upstream commit observed: `7b61cb83331003335337dbb40a96e821a33765c0`

## Truth classification

| Evidence class | Status | Observed evidence | Gap |
|---|---|---|---|
| Repository assessment | PARTIAL | Upstream repository exists, MIT licence is stated in README, current commit is pinned, README documents API surface and local quality commands, and CI workflow exists. | No completed T4H assessment pack, maintainer-health review, dependency review, SBOM, licence file verification, adoption score, or signed fork/wrap/reject decision. |
| Security and dependency scans | PARTIAL | Upstream GitHub Actions workflow runs Bandit source scanning as a declared quality gate. | No observed T4H-run Trivy, Gitleaks, dependency-vulnerability, Scorecard, Checkov, or SBOM receipts. No retrieved successful workflow-run receipt for the pinned commit. |
| Sandbox tests | PARTIAL | Upstream declares pytest, lint and type checks; README says tests use mocked Migadu API responses and integration tests are skipped by default. | No observed T4H sandbox environment, no read-only live inventory test, no controlled-write test, no destructive rollback/compensation test, and no independent verification receipt. |
| Receipts | MISSING | Issue #222 defines the required receipt schema. | No Migadu Managed MCP JSON, CSV or Markdown execution receipt was found in `TML-4PM/the-pen` or the upstream repository. |
| Ledger | MISSING | Issue #222 specifies a durable execution ledger as a requirement. | No Migadu-specific ledger entry, idempotency record, before/after state hash, or final execution state was found. |
| Telemetry | MISSING | Issue #222 requires OpenTelemetry instrumentation and trace references. | No Migadu-specific trace ID, span export, collector configuration, runtime metric, or telemetry validation receipt was found. |
| Fork or wrapper | MISSING | Architecture and tool authority classifications are captured in issue #222. | No T4H fork or wrapper repository was found in the connected GitHub installation, and no matching source artefact was found in `the-pen`. |

## Upstream CI observed

The pinned upstream commit includes `.github/workflows/main.yml` with declared quality gates for:

- `pytest`
- `ruff`
- `ty`
- `bandit`

The workflow also defines release build and PyPI publishing. This proves the workflow definition exists; it does not prove a successful run for the pinned commit. The combined-status query returned no status records, so upstream CI completion is not classified REAL from currently observed evidence.

## Tooling and runtime observations

- Upstream MCP supports domain, mailbox, alias, identity, forwarding and rewrite operations.
- The upstream project includes destructive and credential-sensitive capabilities.
- No upstream evidence was found for before-state snapshots, rollback, durable idempotency ledger, T4H policy gates, immutable receipts, or OpenTelemetry.
- No T4H fork or wrapper implementation was found through repository and code searches.

## Required follow-on sequence

1. Create or identify the T4H fork/wrapper repository and pin upstream commit `7b61cb83331003335337dbb40a96e821a33765c0`.
2. Generate repository assessment, licence verification, maintainer-health review, dependency inventory and SBOM.
3. Run T4H-owned scans: Trivy, Gitleaks, dependency audit and OSSF Scorecard; store raw outputs and hashes.
4. Execute mocked test suite and capture test receipt.
5. Execute read-only Migadu sandbox inventory using runtime-secret injection; independently verify counts and configuration.
6. Execute one bounded controlled-write sandbox operation; verify after-state and perform cleanup or rollback.
7. Exercise one destructive-operation compensation test against a disposable sandbox object.
8. Emit JSON, CSV and Markdown receipts.
9. Append a durable ledger entry with idempotency key, before/after hashes and evidence references.
10. Export OpenTelemetry traces and validate the trace ID against the receipt and ledger.

## Current state

`PARTIAL`

Reason: repository and upstream workflow evidence exist, but T4H execution, security receipts, sandbox validation, ledger and telemetry are not observed. No item is REAL solely because it is described in the work queue.