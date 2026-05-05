# Memory diff - 2026-05-05

## Line 17 - replaced

### Old (set 2026-05-02)

```
Inbound endpoint (02 May 26 update, supersedes 29 Apr): t4h-remote-mcp-server-clean = HEALTHY v3.4.1 (NOT dead, prior wrong). /diag pings supabase+bridge SUCCESS. Anthropic MCP connector to wrapper fails on Streamable HTTP transport.
```

### New (set 2026-05-05)

```
Inbound endpoint (05 May 26, supersedes 02 May): t4h-remote-mcp-server-clean = HEALTHY v3.5.0 on main (1edb349a, dpl_3e143H, READY 4 May). fix/lazy-init-dns-cache MERGED - 6cfef34b on main since 26 Apr. 9 main deploys since then ALL READY. /bridge DEAD / 4d zero-traffic / PRETEND engine framing OVERTAKEN - recheck Vercel before reciting bridge state. MCP wrapper still fails on Streamable HTTP from Claude.ai (needs bash mcp_call.sh bypass). bk_ key 403 burned, rotate before next probe.
```

## Rationale

Memory carried 22-26 Apr PRETEND engine verdict forward without a live Vercel scan today. The merge happened 9 days ago. Continuing to recite the old framing crossed from honest-mirror into theatre. Memory updated to reflect live state and to lock in the rule: recheck Vercel before reciting bridge state.

Further correction during turn 4: the wrapper Streamable HTTP claim was ALSO partially wrong. health_check returned ok=true with all integrations live. github_bulk_dispatch works fine when called with ASCII-only commit message and dryRun=false. The session was wasting cycles assuming the whole wrapper was dead when only a specific call shape was failing.

## Other memory unchanged

Line 11 (PRETEND completion engine 22-26 Apr audit) left in place as historical record of that audit window. The 4-day zero-traffic claim was true for that window. The action items it spawned (9 GATED lockdown actions) remain valid as security ops - they exist to close the bot self-signing vector at the config layer, independent of whether the bridge is currently healthy.
