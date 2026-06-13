# Symbio Runtime Platform 1.0

Status: PARTIAL until runtime smoke receipts are returned.
Owner: TML-4PM
Canonical repo: TML-4PM/the-pen
Path: /symbio-runtime

## Runtime Order

WIP → Pen → Symbio → Gatekeeper → Synapse → Command Centre → Reality Ledger

## Purpose

Symbio is the DEV/runtime build-and-integration layer. It converts prepared work from Pen into executable runtime objects, proof gates, receipts, telemetry, and Gatekeeper-ready promotion packages.

## 1.0 Definition

Symbio 1.0 is valid when the following exist:

1. Runtime contract
2. Runtime object graph
3. Runtime SQL spine
4. Bridge payload
5. Smoke tests
6. Reality Ledger binding
7. Command Centre widget spec
8. Recovery policy
9. Execution receipts
10. Telemetry output

## Current Classification

PARTIAL. The spine is packaged and committed. Runtime proof requires Bridge/Supabase execution receipts.

## Proof Gates

- archive_ingested
- repo_path_resolved
- runtime_tables_created
- smoke_test_passed
- receipt_written
- telemetry_visible
- recovery_tested
- 72h_survivability_proven

## Reality Rule

Do not mark REAL until smoke test outputs and receipts are attached.
