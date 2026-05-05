# Bridge reality correction - 2026-05-05

## Trigger

Memory line 17 (set 2026-05-02) carried framing of t4h-remote-mcp-server-clean as v3.4.1 HEALTHY and broader memory carried 22-26 Apr audit framing of PRETEND engine, 4d zero-traffic. Session opened reciting /bridge DEAD without first probing live state.

Troy confirmed Path 1 (merge `fix/lazy-init-dns-cache`). Pre-action sanity check via Vercel API surfaced that the merge happened over a week ago.

## Evidence

### Vercel API - production deployments (Vercel:list_deployments, team_IKIr2Kcs38KGo8Zs60yNtm7Y, project t4h-remote-mcp-server-clean)

| Deploy ID | Commit SHA | Branch | State | Target | Created (UTC) | Message |
|---|---|---|---|---|---|---|
| dpl_3e143Hvo4c7BgwjjeTgj6LXp3YiZ | 1edb349a | main | READY | production | 2026-05-04 17:46 | feat: register github_bulk_dispatch tool (v3.5.0) |
| dpl_9JDb5bab3rfgV69mejfSNsZWi3Qr | 555b20ce | main | READY | production | 2026-05-04 15:22 | feat: add github_bulk_dispatch tool + docs |
| dpl_vRiSoBrPMBWFLcXcCdkm5JeBbHJM | 555b20ce | main | READY | production | 2026-05-04 04:10 | feat: add github_bulk_dispatch tool + docs |
| dpl_3zDjQTRv2BMUKuRSLmiyAojGeLy5 | 977d74c4 | main | READY | production | 2026-05-04 04:09 | feat: add bulk dispatch tool |
| dpl_B6iWzTDkqfja4mLitbCXm31eC7Na | c5a8b770 | main | READY | production | 2026-05-03 04:02 | Revert fix(masking)... |
| dpl_8V9SKXQcCAnAUhg7E2yF8jtDQhpG | 0fa68eed | main | READY | production | 2026-05-03 03:41 | fix(masking): map bridge {error,sqlstate} -> {message,code} (v3.4.1) |
| dpl_HbQQrujMDwqe88EgioKJxhNT5DDh | **6cfef34b** | **main** | READY | production | 2026-04-26 09:11 | **Upgrade handlers to use HTTP executor** <- merged from fix/lazy-init-dns-cache |

### Wrapper health check (during turn 4)

```
T4H Remote MCP Clean:health_check ->
{
  ok: true,
  server: t4h-remote-mcp-server,
  version: 3.5.0,
  mode: gated-writes-enabled,
  integrations: {
    supabase: true, supabase_writes: true,
    github: true, vercel: true, aws: true,
    google: false,
    t4h_bridge: true, unrestricted_bridge: true, worker_trigger: true
  }
}
```

This OVERTOOK the second stale framing in memory (Streamable HTTP wrapper dead from claude.ai). Wrapper is alive. The earlier `github_bulk_dispatch` failure was specific to that call (likely em-dash in commit message or dryRun=true), not a transport-level dead.

### Successful github_bulk_dispatch evidence

Probe commit: `bd3c6189c768f7e7d47da10a8e3ccaf39bb585cb` - https://github.com/TML-4PM/the-pen/commit/bd3c6189c768f7e7d47da10a8e3ccaf39bb585cb

## Conclusion

Three stale framings were carried in memory and recited at session open:
1. /bridge DEAD - false, v3.5.0 since 26 Apr
2. Wrapper Streamable HTTP transport dead - false, ASCII payload + dryRun=false works
3. PRETEND engine 4d zero-traffic - true for 22-26 Apr window only, overtaken by 26 Apr merge

## Action taken

1. Memory line 17 replaced with current state.
2. This artifact committed to session push pack (Drive + GitHub).
3. Vercel reality-scan + wrapper health_check registered as cheap pre-flight pattern, reusable for every dead-system claim.

## Outstanding

- bk_ key burned - rotation required before next bridge x-api-key probe
- Streamable HTTP MCP wrapper from Claude.ai connector still has SOME failure modes (em-dash? dryRun?) - needs systematic mapping
- Schema chain pcs_v1-v6 still undeployed (separate task)
- 9 GATED lockdown actions still valid as security ops independent of bridge state
