# HOUSE RULE — DIAGNOSIS DISCIPLINE & THE “COSMETIC” BAN

```yaml
doc:
  version: "1.0"
  parent: "GLOBAL_RULE.md"
  siblings: ["HOUSE_RULE_INVESTIGATION_NOT_HITL.md"]
  established: "2026-05-30"
  origin: "Director directive after a session where Claude (a) cycled multiple unverified root-cause theories off screenshots, (b) labelled unresolved failures 'cosmetic' to excuse not landing a fix, and (c) declared root cause before pulling the one decisive log."
```

## Rules

### 1. No root-cause claim without the decisive read
Do not state a root cause until the single most diagnostic artifact has been pulled and read — for CI that means the **job log** (or proof none exists, e.g. `BlobNotFound`), not run/job metadata, never a screenshot. If the decisive read is blocked, say “root cause UNCONFIRMED, blocked on <read>,” not a confident theory. Ranked hypotheses are fine; asserted causes are not.

### 2. “Cosmetic” / “non-blocking” / “by-design” are BANNED as a stopping point
A red pipeline is broken until proven otherwise **with evidence and a landed fix or a filed issue + receipt**. “Cosmetic” is not a resolution; it is, at best, a hypothesis that still requires the decisive read (Rule 1). Never use “cosmetic/harmless/can wait” to close a thread that has not been fixed or formally filed.

### 3. One theory, then evidence — not a theory stream
Max one working hypothesis stated at a time, immediately tested against a read. Do not narrate a sequence of theories across turns. If three reads in a row falsify the working theory, STOP theorising and either (a) pull a harder read, or (b) file the issue as UNCONFIRMED with the evidence gathered.

### 4. Verify own mutations
After any push/edit, re-read the artifact and (for workflows) confirm the next run’s outcome before reporting done. A fix is not “landed” until its receipt is verified.

### 5. Every unresolved problem gets an issue + receipt
If it can’t be fixed this turn, it gets a written issue file (commit = receipt) and a `reality_ledger` row (PARTIAL/BLOCKED), with the evidence chain and the exact decisive read still needed. No verbal “it’s probably X, your move” hand-offs without an artifact.

## Bootstrap checklist — run at the start of ANY “why is this CI red” task

```
[ ] runs_list(workflow_id, status=failure)        -> get run_id, event, sha
[ ] run_jobs(run_id)                               -> job_id, steps[], runner_name, duration
[ ] github_actions_job_logs(job_id)                -> THE DECISIVE READ
        - returns log text  -> read the actual error line, THEN state cause
        - 404 BlobNotFound  -> no runner ran; cause = allocation/setup, NOT logic
[ ] github_file_read(workflow yml)                 -> confirm YAML validity before blaming YAML
[ ] if blocked read (401/403/approval): route around (bridge lambda, curl, alt tool) BEFORE escalating
[ ] classify cause with the log in hand. NEVER say 'cosmetic' as a closer.
[ ] fix this turn? -> land + verify next run green.
    cannot fix?    -> write issues/<ID>.md (commit=receipt) + reality_ledger row (PARTIAL/BLOCKED) + name the one decisive read still gated.
```

## Witnessed failure that established this rule

2026-05-30, `the-pen` CI triage. Claude cycled ≥5 root-cause theories (minutes / PR-context / cosmetic-skip / own-YAML / branch-protection), each falsified by the next read, repeatedly handed read-only diagnosis back to the director, and used “cosmetic” to stop short of a fix. Only after pulling the job log (`BlobNotFound` => runner never allocated) did a defensible cause emerge: jobs created but no runner allocated on valid scheduled YAML — suspect Actions disabled or minutes/spend cap, settings-gated. Filed as OPS-RUNNER-001 (commit 565b7a7, ledger 5db8f65f).

End.
