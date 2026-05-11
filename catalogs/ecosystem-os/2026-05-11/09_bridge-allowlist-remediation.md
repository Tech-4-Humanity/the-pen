# Bridge Allowlist Remediation — Ecosystem OS

Status: REMEDIATION READY / RUNTIME BLOCKED  
Issue: #76  
Task ID: ecosystem-os-catalogue-control-tower-2026-05-11

## Problem

Bridge canonicalisation is blocked because the required GitHub-facing and receipt-producing functions are not allowlisted.

Observed failed functions:
- github-issue-comment
- troy-github-proxy
- fn_github_push
- troy-sql-executor

Fallback succeeded through bash REST, proving GitHub write access exists, but not through the canonical Bridge route.

## Required allowlist entries

```yaml
bridge_allowlist_required:
  github_issue_comment:
    purpose: post canonical execution comments and receipts to GitHub issues
    minimum_actions:
      - add_comment_to_issue
      - fetch_issue
      - fetch_issue_comments
  troy_github_proxy:
    purpose: controlled GitHub repository operations through Bridge
    minimum_actions:
      - create_file
      - update_file
      - add_comment_to_issue
      - fetch_file
      - fetch_commit
  fn_github_push:
    purpose: canonical repo write path required by The Pen
    minimum_outputs:
      - success
      - commit_sha
      - content_sha
      - html_url
      - receipt_path
  troy_sql_executor:
    purpose: Supabase / Reality Ledger execution and receipt insertion
    minimum_actions:
      - execute_sql
      - insert_ledger_row
      - return_structured_receipt
```

## Safety constraints

```yaml
allowlist_constraints:
  repositories:
    - TML-4PM/the-pen
    - TML-4PM/mcp-command-centre
  permitted_paths:
    - catalogs/**
    - receipts/**
    - bridge/**
    - global/**
    - docs/**
  destructive_actions:
    delete_file: blocked_by_default
    close_issue: gated
    merge_pr: gated
    repo_settings_change: blocked
  receipt_required: true
  ledger_required: true
  dry_run_supported: true
  idempotency_required: true
```

## Post-fix validation

After allowlist update, Bridge must:

1. Post a test comment to Issue #76.
2. Commit a receipt file under `receipts/ecosystem-os/`.
3. Return:
   - bridge_receipt_id
   - github_comment_id
   - commit_sha
   - content_sha/hash
   - html_url
   - receipt_path
   - ledger_row_id or bounded BLOCKED reason

## Classification

```yaml
status: BLOCKED
blocked_reason: bridge runtime functions are not allowlisted
next_action: update Bridge allowlist and rerun canonical Bridge receipt test
do_not_close_issue: true
```
