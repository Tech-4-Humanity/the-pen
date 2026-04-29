# Ghost Claim Recovery Runner

Purpose: find every artefact that *thinks* it went through the bridge, prove where it actually landed, recover its topic identity, then rehome/replay it to the right execution surface.

This exists because `sent to bridge` has been used across PEN, WIP, MCP Command Centre, MCP remote, bridge-runner, bridge-worker-intake, Symbio/dev, Synapse/prod, orchestrator packs, and manual receipt folders.

## Operating principle

A claim is not complete until it has:

1. source claim captured
2. artefact found
3. destination classified
4. topic identity reconstructed
5. intended destination resolved
6. recovery action selected
7. rehoming/replay performed where safe
8. durable handoff receipt saved
9. runtime receipt saved when execution occurs

## Status taxonomy

- FOUND_COMMITTED: file exists in GitHub
- FOUND_INBOX: queue/inbox item exists
- FOUND_HANDOFF: handoff exists but execution not proven
- FOUND_RECEIPT: receipt exists
- FOUND_RUNTIME_PROVEN: runtime evidence exists
- FOUND_INVALID_SCHEMA: caught but rejected by worker/schema
- FOUND_DUPLICATE_MIRROR: same work mirrored across repos
- FOUND_NEEDS_REPLAY: safe candidate for replay after normalisation
- FOUND_NEEDS_REHOME: right work, wrong place
- FOUND_NEEDS_REINSTATEMENT: partially lost/incomplete and must be reconstructed
- CLAIMED_NOT_FOUND: claim detected, no artefact found yet
- CLAIM_AMBIGUOUS: topic found but destination/identity unclear

## Recovery actions

- REGISTER_ONLY: do not move; record evidence
- NORMALISE_SCHEMA: rewrite envelope to current schema
- REHOME_TO_PEN: send to `TML-4PM/the-pen/inbox/`
- REHOME_TO_WIP: send to WIP/handoff area
- REHOME_TO_DEV: send to Symbio/dev control path
- REHOME_TO_PROD: send to Synapse/prod control path, only when proof gates pass
- REHOME_TO_MCP_COMMAND: send to `mcp-command-centre` bridge runner payload path
- REHOME_TO_MCP_REMOTE: send to remote MCP executor path
- REHOME_TO_BRIDGE_RUNNER: send to bridge-runner queue
- REPLAY_SAFE: re-run idempotently
- REQUEST_HUMAN_AUTHORITY: external credential, destructive, billing, legal, or prod-risk step

## Required register fields

See `schema.sql` and `ghost_claim_recovery_runner.mjs`.

## Default routing map

- `the-pen/inbox/*.json` -> PEN replay queue
- `the-pen/handoffs/*` -> PEN handoff register; replay if no runtime receipt
- `mcp-command-centre/handoffs/*` -> MCP Command Centre queue or bridge-runner payload
- `mcp-command-centre/WIP/*` -> WIP closeout / worker allocation
- `bridge-runner/payloads/*` -> Bridge Runner execution queue
- `bridge_runner/inbox/*` -> older Bridge Runner intake
- `symbio-dev-control-plane/*` -> DEV / Symbio validation
- `symbio-synapse-ops/*` -> PROD / Synapse validation
- `claude-outputs/*` -> agent output archive; handoff if not routed

## Automation cadence

- every 15 minutes: scan last 24h commits and inbox paths
- hourly: scan 72h bridge/MCP/orchestrator/WIP/dev/prod candidates
- daily: full dedupe and replay-candidate report
- weekly: repo-sprawl audit and route-map reconciliation

## Non-negotiable metadata for every future job

```json
{
  "origin": "chatgpt|claude|perplexity|manual|worker|unknown",
  "source_chat_title": "human-readable topic or thread title",
  "source_thread_key": "stable id if known; otherwise derived slug",
  "claim_phrase": "sent to bridge|pushed to pen|handoff to dev|etc",
  "claimed_destination": "pen|wip|dev|prod|bridge|mcp_command|mcp_remote|bridge_runner|orchestrator",
  "intended_destination": "...",
  "current_repo": "owner/repo",
  "current_path": "path/to/file",
  "idempotency_key": "stable replay key",
  "recovery_mode": "REGISTER_ONLY|NORMALISE_SCHEMA|REHOME_TO_*|REPLAY_SAFE",
  "evidence_state": "REAL|PARTIAL|PRETEND",
  "handoff_receipt_path": "receipts/handoff/...json",
  "runtime_receipt_path": "receipts/runtime/...json"
}
```

## Hard truth

This runner will not magically know GPT thread IDs unless they were captured. It reconstructs identity from commit messages, paths, file names, idempotency keys, embedded source labels, and timestamps. Future jobs must include `source_thread_key` and `source_chat_title`.
