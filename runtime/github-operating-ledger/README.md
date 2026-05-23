# GitHub Operating Ledger

Automatic daily report of all TML-4PM GitHub activity: repos, issues, PRs, stuck work, receipt debt, and repo hygiene.

## Reports

- `reports/latest.md` — latest Markdown report
- `reports/latest.json` — latest JSON report
- `reports/YYYY-MM-DD.md` — dated archive

## Workflow

Runs daily at 01:00 UTC via `github-operating-ledger.yml`. Trigger manually via workflow_dispatch.

## Stuck-work detection rules

| Rule | Threshold |
|---|---|
| Critical issue no update | 24h |
| Bridge-ready no receipt | 24h |
| Critical unassigned | immediate |
| General stale | 7d |
| Archived repo with open issues | immediate |

## Status

REAL — deployed 2026-05-23. Closes [the-pen #134](https://github.com/TML-4PM/the-pen/issues/134).
