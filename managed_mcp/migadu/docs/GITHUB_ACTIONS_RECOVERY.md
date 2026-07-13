# GitHub Actions Recovery — T4H Managed Migadu MCP

## Intent

Restore GitHub CLI access, verify the available credential source, repair repository Actions permissions, dispatch the managed Migadu MCP validation workflow, and capture durable evidence without storing the token.

## Included assets

- `scripts/repair_github_actions.sh` — complete repair and validation runner.
- `config/github-actions-repair.env.example` — optional non-secret configuration.
- `receipts/` — generated locally at execution time; secrets are never written.

## Credential discovery order

1. `GH_TOKEN` environment variable.
2. `GITHUB_TOKEN` environment variable.
3. macOS Keychain service `t4h-github-token`.
4. Optional 1Password secret reference through `TOKEN_OP_REFERENCE`.
5. Optional AWS SSM parameter through `TOKEN_SSM_PARAMETER`.
6. Hidden interactive input.

GitHub repository and Actions secrets cannot be read back through GitHub. They can only be supplied to a workflow at execution time.

## Required authority

The token must allow administration of Actions settings for `TML-4PM/the-pen`. Fine-grained permissions should include:

- Administration: read/write, or equivalent permission to update Actions settings.
- Actions: read/write.
- Contents: read/write.
- Metadata: read.
- Pull requests: read/write where PR updates are required.

## Execute

```bash
chmod +x managed_mcp/migadu/scripts/repair_github_actions.sh
managed_mcp/migadu/scripts/repair_github_actions.sh
```

Optional configuration:

```bash
export REPO=TML-4PM/the-pen
export BRANCH=feat/migadu-managed-mcp
export WORKFLOW=migadu-managed-mcp-validation.yml
export LEDGER_FILE="$PWD/managed_mcp/migadu/ledger/execution_ledger.jsonl"
```

## Outputs

Each run emits:

- Raw terminal log.
- JSON receipt.
- Markdown receipt.
- Workflow log when available.
- Downloaded workflow artifacts when available.
- Optional append-only ledger entry.

## Truth states

- `REAL`: Actions settings were verified and the dispatched validation workflow concluded successfully.
- `PARTIAL`: repair executed, but workflow failed or evidence was incomplete.
- `BLOCKED`: network, credentials, authority, installation, or repository access prevented execution.

## Recovery

The script stops at the first failed stage, records the exact failure, and emits receipts through an exit trap. Rerunning is safe: Actions settings are idempotent and each run uses a unique receipt ID.
