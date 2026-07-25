# Governed MCP GitHub Authority Receipt

- Date: 2026-07-25
- Runtime repository: `TML-4PM/t4h-remote-mcp-server-clean`
- Evidence repository: `TML-4PM/the-pen`
- Runtime PR: [TML-4PM/t4h-remote-mcp-server-clean#114](https://github.com/TML-4PM/t4h-remote-mcp-server-clean/pull/114)
- Runtime head SHA: `1001a09f83e415b618c64a93c95c6e742a44c256`
- Release SHA-256: `39c725bf67a11808bb90cfeac8e22d597f3421f9906d4c463ec5ce76b2399d4f`
- Local validation: 58/58 tests passed

## Authority implemented

The governed MCP runtime now defines separate `github:read` and
`github:write` OAuth scopes. Provider access is deny-by-default and restricted
to these repositories:

1. `TML-4PM/t4h-remote-mcp-server-clean`
2. `TML-4PM/the-pen`

The runtime reads its GitHub credential from the encrypted SSM parameter
`/t4h/governed-mcp/github/token`. Secrets are excluded from receipts and
telemetry. Writes use optimistic blob SHA checks and exact provider readback.

## Classification

- Code, tests and GitHub branch readback: **REAL**
- Current GitHub connector write to this receipt branch: **REAL**
- New MCP server live provider access: **PARTIAL** until the encrypted token is
  installed, PR #114 is deployed, and deployment readback proves pull and push
  permission for both repositories.

## Completion evidence required

The deployment receipt must report `REAL_READBACK` for GitHub and show
`read: true` and `write: true` for both allowlisted repositories.
