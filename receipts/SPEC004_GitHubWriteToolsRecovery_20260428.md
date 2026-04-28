# SPEC-004 GitHub Write Tools Recovery Receipt

**Date:** 2026-04-28
**Source thread:** ChatGPT execution handoff
**Target repo:** `TML-4PM/t4h-remote-mcp-server-clean`
**Branch observed:** `fix/lazy-init-dns-cache`
**Status:** PARTIAL / BLOCKED, not complete
**Reason:** local bootstrap failed because `github_write_tools_inline_patch.js` was missing from `~/spec-004` or the `PATCH_FILE` environment variable did not point to the actual file.

## Verified terminal evidence

The user provided the following terminal output:

```text
==> SPEC-004 bootstrap: 5 GitHub write tools
    repo:   TML-4PM/t4h-remote-mcp-server-clean
    branch: fix/lazy-init-dns-cache
    work:   /tmp/spec-004-bootstrap-1777339596

Cloning into '.'...
remote: Enumerating objects: 766, done.
remote: Counting objects: 100% (766/766), done.
remote: Compressing objects: 100% (578/578), done.
remote: Total 766 (delta 128), reused 744 (delta 127), pack-reused 0 (from 0)
Receiving objects: 100% (766/766), 766.36 KiB | 6.97 MiB/s, done.
Resolving deltas: 100% (128/128), done.
==> Cloned TML-4PM/t4h-remote-mcp-server-clean (main)
Switched to a new branch 'fix/lazy-init-dns-cache'
==> On branch fix/lazy-init-dns-cache
ERROR: github_write_tools_inline_patch.js not found alongside this script.
       Place it in the same directory or set PATCH_FILE env to its path.
EXIT_CODE=1
```

## Reality Ledger classification

| Component | Classification | Evidence |
|---|---:|---|
| GitHub connector | REAL | ChatGPT connector authenticated as `TML-4PM / Tech4Humanity` and exposed write/read GitHub tools. |
| Local SPEC-004 bootstrap | FAILED | Terminal output shows `EXIT_CODE=1`. |
| Patch application | NOT REAL | Missing `github_write_tools_inline_patch.js`; no hunks applied proof. |
| Production readiness | BLOCKED | Cannot proceed until local patch file exists and bootstrap exits `0`. |

## Required recovery commands

Run on Troy's Mac:

```bash
cd ~/spec-004
ls -la
ls -la ~/Downloads | grep github_write_tools_inline_patch
```

If found in Downloads:

```bash
mv ~/Downloads/github_write_tools_inline_patch.js ~/spec-004/
```

Then rerun:

```bash
cd ~/spec-004 && \
PATCH_FILE="$PWD/github_write_tools_inline_patch.js" ./bootstrap_github_write_tools.sh; \
echo "EXIT_CODE=$?"
```

## Proof gates for completion

Completion requires all of the following:

1. `github_write_tools_inline_patch.js` present in `~/spec-004`, or `PATCH_FILE` points to its true path.
2. Bootstrap command exits with `EXIT_CODE=0`.
3. Output shows patch applied or equivalent positive verification.
4. Smoke check loads the modified file without Node/runtime error.
5. Git status confirms intended files changed only.
6. Commit/PR/receipt created against the target repo or execution repo.

## Executor instruction

Do not report SPEC-004 as complete until terminal proof includes `EXIT_CODE=0`. If the patch file is unavailable, regenerate or retrieve `github_write_tools_inline_patch.js`, place it beside `bootstrap_github_write_tools.sh`, rerun, and attach the final terminal tail to a follow-up receipt.

## Final state

This receipt is intentionally truthful: the work is wrapped and handed off, but the local toolchain is not yet complete because the required patch asset is missing.