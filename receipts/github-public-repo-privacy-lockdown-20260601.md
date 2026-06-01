# Receipt: GitHub public repo privacy lockdown

Date: 2026-06-01
Owner/account: `TML-4PM`
Operator: Troy Latter via local terminal, assisted by ChatGPT
Evidence class: REAL terminal receipt

## What happened

Troy identified that multiple GitHub repositories under `TML-4PM` were still public, including active repositories and archived public repositories visible on the GitHub profile.

The intent was explicit: all repositories under the account needed to be private.

## Initial issue

The first commands used `@me` as the owner handle:

```bash
gh repo list @me --visibility public --limit 1000 --json nameWithOwner,visibility,isArchived
```

GitHub CLI rejected this with:

```text
the owner handle "@me" was not recognized as either a GitHub user or an organization
```

The active authenticated GitHub account was confirmed as:

```text
TML-4PM
```

## Public repository inventory

The corrected inventory command was run against `TML-4PM`:

```bash
gh repo list TML-4PM --visibility public --limit 1000 --json nameWithOwner,visibility,isArchived \
  --jq '.[] | [.nameWithOwner, .visibility, .isArchived] | @tsv'
```

It returned 63 public repositories.

## First remediation pass

A loop was run to make all non-archived public repositories private:

```bash
gh repo list TML-4PM --visibility public --limit 1000 --json nameWithOwner \
  --jq '.[].nameWithOwner' |
while read repo; do
  echo "Making private: $repo"
  gh repo edit "$repo" --visibility private --accept-visibility-change-consequences
done
```

Result:

- 49 repositories were successfully changed from public to private.
- 14 repositories failed with HTTP 403 because they were archived/read-only.

Representative error:

```text
HTTP 403: Repository was archived so is read-only.
```

## Archived repository repair

The archived repositories were repaired using GitHub API PATCH operations:

1. Unarchive repository.
2. Set private visibility.
3. Re-archive repository.

Command pattern:

```bash
gh api -X PATCH "repos/$repo" -f archived=false
gh api -X PATCH "repos/$repo" -f private=true
gh api -X PATCH "repos/$repo" -f archived=true
```

Archived public repositories remediated:

- `TML-4PM/More-Free-Agents`
- `TML-4PM/free-agents-via-AHC`
- `TML-4PM/Augmented-Humanity`
- `TML-4PM/GenAI---ITOPs`
- `TML-4PM/Vendor-Contract-Agent`
- `TML-4PM/geeks2u-take-50`
- `TML-4PM/Partner-Viewer`
- `TML-4PM/Partner-Portal`
- `TML-4PM/TML-G2U-50`
- `TML-4PM/whydididothis`
- `TML-4PM/geeks2u-calculator-killedme`
- `TML-4PM/geeks2u-calculator`
- `TML-4PM/euc-job-pricing-calculator`
- `TML-4PM/euc-calculator`

## Final verification

Final command run:

```bash
echo "PUBLIC REPOS REMAINING:"
gh repo list TML-4PM --visibility public --limit 1000 --json nameWithOwner \
  --jq '.[].nameWithOwner'
```

Terminal output:

```text
PUBLIC REPOS REMAINING:
```

No repository names were returned after the heading.

## Final status

| Check | Result |
|---|---:|
| Active GitHub account | `TML-4PM` |
| Public repos initially detected | 63 |
| Non-archived repos privatised | 49 |
| Archived repos repaired and re-archived | 14 |
| Public repos remaining | 0 |
| Evidence class | REAL terminal receipt |

## Notes

GitHub Pages, Vercel deployments, app integrations, or external automations linked to these repositories may require private repository access refresh. This receipt only verifies GitHub repository visibility state for repositories returned by `gh repo list TML-4PM --visibility public` at the time of the final terminal check.
