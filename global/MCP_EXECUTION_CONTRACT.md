# MCP_EXECUTION_CONTRACT.md
## Tech 4 Humanity — Single Execution Contract

All actors are intent generators only. Execution must occur through MCP Bridge controlled functions.

## Canonical Execution Path

```text
ANY ACTOR -> MCP BRIDGE -> troy-intent-normalizer -> troy-code-pusher -> GitHub PAT -> RECEIPT
```

## Required Envelope

```json
{
  "action": "invoke_function",
  "function_name": "troy-code-pusher",
  "invocation_type": "RequestResponse",
  "payload": {
    "repo": "TML-4PM/the-pen",
    "branch": "main",
    "files": [
      {
        "path": "path/in/repo.ext",
        "content": "complete file content"
      }
    ],
    "commit_message": "auto: execution"
  },
  "metadata": {
    "request_id": "globally-unique-id",
    "actor": "chatgpt|claude|perplexity|grok|gemini|system",
    "source": "ai-intent",
    "timestamp_utc": "ISO-8601 timestamp"
  }
}
```

## Rejection Rules

Reject any request that:
- attempts direct GitHub write access
- contains credentials in payload
- lacks request_id
- lacks receipt path
- writes without declared actor
- uses unknown repo unless explicitly allowed

## Runtime Proof

Every successful write must produce:
- Git commit SHA
- Git receipt under `/receipts/`
- Supabase execution log entry
- Reality Ledger state: REAL, PARTIAL, or FAILED

## Status

ACTIVE — REQUIRED FOR ALL ACTORS
