#!/usr/bin/env bash
set -euo pipefail

ORG="${ORG:-TML-4PM}"
OUT_DIR="${OUT_DIR:-actions-audit-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUT_DIR"

command -v gh >/dev/null 2>&1 || { echo "gh CLI is required" >&2; exit 2; }
gh auth status >/dev/null

printf '%s\n' '{"schema_version":"1.0","organisation":"'"$ORG"'","started_at":"'"$(date -u +%FT%TZ)"'"}' > "$OUT_DIR/manifest.json"

# Organisation and billing-adjacent evidence available through GitHub APIs.
gh api "/orgs/$ORG/actions/permissions" > "$OUT_DIR/org-actions-permissions.json" 2>"$OUT_DIR/org-actions-permissions.err" || true
gh api "/orgs/$ORG/actions/permissions/selected-actions" > "$OUT_DIR/org-selected-actions.json" 2>"$OUT_DIR/org-selected-actions.err" || true

gh repo list "$ORG" --limit 1000 --json nameWithOwner,isArchived,visibility,defaultBranchRef > "$OUT_DIR/repos.json"

jq -r '.[] | select(.isArchived == false) | .nameWithOwner' "$OUT_DIR/repos.json" | while read -r repo; do
  safe="${repo//\//__}"
  mkdir -p "$OUT_DIR/repos/$safe"

  gh api "/repos/$repo/actions/permissions" > "$OUT_DIR/repos/$safe/actions-permissions.json" 2>"$OUT_DIR/repos/$safe/actions-permissions.err" || true
  gh api "/repos/$repo/actions/permissions/selected-actions" > "$OUT_DIR/repos/$safe/selected-actions.json" 2>"$OUT_DIR/repos/$safe/selected-actions.err" || true
  gh api --paginate "/repos/$repo/actions/runs?per_page=100" > "$OUT_DIR/repos/$safe/runs.json" 2>"$OUT_DIR/repos/$safe/runs.err" || true

  jq -r '.workflow_runs[]? | select(.status == "completed") | [.id,.name,.conclusion,.event,.head_sha,.html_url] | @tsv' "$OUT_DIR/repos/$safe/runs.json" 2>/dev/null | head -n 100 | while IFS=$'\t' read -r run_id run_name conclusion event head_sha url; do
    job_file="$OUT_DIR/repos/$safe/run-${run_id}-jobs.json"
    gh api --paginate "/repos/$repo/actions/runs/$run_id/jobs?per_page=100" > "$job_file" 2>"$job_file.err" || true

    jq -c --arg repo "$repo" --arg run_name "$run_name" --arg conclusion "$conclusion" --arg event "$event" --arg head_sha "$head_sha" --arg url "$url" '
      .jobs[]? |
      {
        repository:$repo,
        workflow:$run_name,
        run_id:(.run_id // null),
        job_id:.id,
        job_name:.name,
        run_conclusion:$conclusion,
        job_conclusion:.conclusion,
        event:$event,
        head_sha:$head_sha,
        url:$url,
        runner_name:(.runner_name // ""),
        runner_group_name:(.runner_group_name // ""),
        step_count:(.steps // [] | length),
        started_at:.started_at,
        completed_at:.completed_at,
        classification:(
          if ((.steps // [] | length) == 0 and (.runner_name // "") == "" and .conclusion == "failure")
          then "ZERO_STEP_RUNNER_START_FAILURE"
          elif ((.steps // [] | length) == 0 and .conclusion == "skipped")
          then "ZERO_STEP_JOB_SKIPPED"
          else "OTHER"
          end
        )
      }' "$job_file" 2>/dev/null >> "$OUT_DIR/findings.jsonl" || true
  done
done

jq -s '{
  total:length,
  runner_start_failures:(map(select(.classification=="ZERO_STEP_RUNNER_START_FAILURE"))|length),
  skipped_jobs:(map(select(.classification=="ZERO_STEP_JOB_SKIPPED"))|length),
  other:(map(select(.classification=="OTHER"))|length),
  repositories:(map(.repository)|unique|length)
}' "$OUT_DIR/findings.jsonl" > "$OUT_DIR/summary.json" 2>/dev/null || printf '%s\n' '{"total":0}' > "$OUT_DIR/summary.json"

cat > "$OUT_DIR/README.md" <<EOF
# GitHub Actions estate diagnostic

Generated: $(date -u +%FT%TZ)
Organisation: $ORG

Canonical classifications:

- ZERO_STEP_RUNNER_START_FAILURE: job record exists, no runner, zero steps, failure.
- ZERO_STEP_JOB_SKIPPED: zero steps with skipped conclusion.
- OTHER: requires normal log inspection.

No settings are changed by this script. Review permissions evidence and findings before remediation.
EOF

printf 'Receipt directory: %s\n' "$OUT_DIR"
cat "$OUT_DIR/summary.json"
