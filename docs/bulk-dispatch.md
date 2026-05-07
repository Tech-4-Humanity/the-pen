# GitHub Bulk Dispatch Engine

## Purpose

The GitHub Bulk Dispatch Engine is a Synal widget and PEN fallback pattern for applying queued file create/update jobs through GitHub as an auditable execution backbone.

It is intended to reduce fragile approval loops and provide a deterministic route for file-based changes when MCP, Bridge, or Lambda execution paths are degraded.

## Status

- Classification: PARTIAL
- Reason: Documentation and receipt are committed to the PEN repository. The browser execution helper was intentionally not committed in this run because the connector safety gate blocked a PAT-oriented helper payload.
- Target state: REAL after the browser widget code is stored through an approved internal path, runtime tested, and linked to a commit receipt.

## Canonical batch schema

```json
{
  "owner": "TML-4PM",
  "repo": "the-pen",
  "branch": "main",
  "source": "synal",
  "request_id": "github-bulk-dispatch-YYYYMMDD-HHMMSS",
  "execution_mode": "direct",
  "jobs": [
    {
      "path": "docs/example.md",
      "content": "Complete file content goes here.",
      "message": "Add example file"
    }
  ]
}
```

## Required behaviour

1. Accept a JSON array of file jobs or a full batch envelope.
2. Default to `TML-4PM/the-pen/main` when target repo is omitted.
3. Fetch existing file metadata first.
4. Create file when SHA is absent.
5. Update file when SHA is present.
6. Produce a receipt containing path, action, commit SHA, timestamp, status, and errors.
7. Store receipt in the PEN receipt layer or route it into the Bridge/Reality Ledger path.

## Synal widget placement

Widget name: `GitHub Dispatch Console`

Primary surfaces:

- Synal browser widget drawer
- Command Centre operator panel
- PEN dispatch console
- Emergency/manual override console

## PEN routing rule

If a file-based MCP or Bridge job fails because of an execution-path issue, generate a GitHub Bulk Dispatch batch and surface it as the next safe execution route.

## Receipt contract

```json
{
  "task_id": "synal-github-bulk-dispatch",
  "intent": "Install GitHub bulk dispatch as reusable Synal/PEN fallback primitive",
  "execution": "docs_and_receipt_committed",
  "output": [
    "docs/bulk-dispatch.md",
    "receipts/synal-github-bulk-dispatch-receipt.json"
  ],
  "status": "PARTIAL",
  "evidence": [
    "github_commit_sha"
  ],
  "gaps": [
    "browser helper JS not committed in this run due connector safety block",
    "runtime browser test still required",
    "Bridge API receipt not available from this chat connector"
  ],
  "next_action": "Commit the browser-safe widget through approved repo path or Bridge executor and run a test dispatch against a non-sensitive fixture file.",
  "elevation": "This converts GitHub into a deterministic fallback execution rail for Synal and PEN file-based work.",
  "pressure_flags": [
    "prevents silent approval-loop drag",
    "reduces orphaned queued file work",
    "requires runtime proof before REAL classification"
  ],
  "score": 0.68
}
```

## Guardrails

- Do not store personal access tokens in repo, localStorage, logs, receipts, screenshots, or exported batches.
- Prefer GitHub App or short-lived token paths over PATs for production.
- Mask credentials in all logs.
- Do not mark REAL until a runtime dispatch has succeeded and a commit SHA is attached.
