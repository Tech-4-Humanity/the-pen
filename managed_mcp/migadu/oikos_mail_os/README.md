# OIKOS Mail Operations

Status: PARTIAL until deployed and verified.

This package turns mailbox infrastructure into a governed OIKOS capability. Registries are the source of truth; folders, signatures, autoresponders, rules, tests and receipts are generated from them.

## Capability path

`Entity Registry -> Capability Library -> Activity Registry -> Rules Engine -> Event Stream -> Evidence Ledger -> Outcome Register`

## Mailbox profiles

- human
- executive
- shared
- machine
- catchall
- notification
- no_reply
- identity
- alias
- forwarder

## Runtime lifecycle

`inventory -> classify -> plan -> policy -> snapshot -> apply -> verify -> receipt -> ledger -> telemetry -> recover/close`

## Included

- `registry.json`: canonical table-of-tables, profiles, folders, signatures, autoresponders and rules.
- `schema.sql`: Supabase/PostgreSQL registry and evidence schema.
- `runtime.py`: validate, plan and render CLI.
- `test_runtime.py`: repeatable conformance tests.
- `deploy.sh`: preflight, schema apply, validation and receipt emission.
- GitHub Actions validation workflow.

## Deploy

```bash
chmod +x managed_mcp/migadu/oikos_mail_os/deploy.sh
managed_mcp/migadu/oikos_mail_os/deploy.sh --dry-run

# Apply schema when DATABASE_URL is set
managed_mcp/migadu/oikos_mail_os/deploy.sh --apply-schema
```

## Truth boundary

A successful source validation proves only that the package is internally consistent. REAL requires a live registry deployment, mailbox readback, rule execution, signature/autoreply verification, receipt, ledger entry and telemetry trace.