# Staging Pattern Smoke Test

**Cluster:** AMR-CLOSEOUT-2026-05-22

If this file landed in the repo, the B-path loop is live:

```
public.fn_stage_file(target_repo, target_path, content_text, ...)
  -> public.t4h_file_staging row (pushed=false)
  -> bridge.github_bulk_dispatch (reads content_text)
  -> public.fn_mark_file_pushed(id, commit_sha, evt_id)
  -> public.reality_ledger row (REAL)
```

Director can now stage any file (text, base64, or Drive ID) via a single SQL call, and the bridge drains it.
