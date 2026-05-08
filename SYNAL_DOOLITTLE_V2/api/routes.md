# Synal Doolittle V2 — Backend Route Contracts

All routes return JSON. Auth: `Authorization: Bearer <tenant_token>` + `x-tenant-id`. Service-role calls (Bridge) use `x-bridge-key` instead.

## Spaces

### POST /api/spaces
```json
{ "slug": "doolittle-live", "name": "Doolittle Live", "purpose": "..." }
```
Returns: `{ "id": "<uuid>", "slug": "...", ... }`

### GET /api/spaces
Returns: list of spaces for tenant.

## Threads

### POST /api/threads
```json
{ "space_id": "<uuid>", "title": "Dog door behaviour" }
```

### GET /api/threads?space_id=<uuid>
Returns: list of threads.

## Parties

### POST /api/parties/invite
```json
{ "thread_id": "<uuid>", "party_keys": ["croux-g", "croux-p", "f-coax"], "role_in_thread": "reviewer" }
```

## Messages

### POST /api/messages
```json
{
  "space_id": "<uuid>",
  "thread_id": "<uuid>",
  "party_key": "human",
  "entry_type": "chat",
  "intent": "translate",
  "channel": "chat",
  "subject": "dog",
  "message": "...",
  "confidence": 0.95,
  "attachments": [{ "file_name": "x.jpg", "file_type": "image/jpeg", "file_size": 1234, "data_url": "data:..." }]
}
```

### GET /api/messages?thread_id=<uuid>
Returns: ordered list of messages with attachments.

## CROUX Routing

### POST /api/croux/route
```json
{
  "thread_id": "<uuid>",
  "to": ["croux-g", "croux-p", "croux-x"],
  "from": "human",
  "message": "...",
  "required_outputs": ["translation", "confidence", "risks", "next_action"],
  "mode": "ask_selected | debate | research_then_synthesise | red_team"
}
```
Gateway: routes via Vercel AI Gateway base `https://ai-gateway.vercel.sh/v1` using each party's `provider/model` ID.

Returns:
```json
{
  "thread_id": "<uuid>",
  "responses": [
    { "party": "croux-p", "status": "complete", "summary": "...", "evidence": [...] },
    { "party": "croux-x", "status": "complete", "summary": "...", "evidence": [...] },
    { "party": "croux-g", "status": "complete", "summary": "...", "evidence": [...] }
  ]
}
```

## Decisions

### POST /api/decisions
```json
{
  "space_id": "<uuid>",
  "thread_id": "<uuid>",
  "decided_by": "f-coax",
  "decision": "Route to CROUX-P + CROUX-X.",
  "reason": "...",
  "risk_class": "medium",
  "evidence_required": true
}
```

## Resource Allocation

### POST /api/resources/allocate
```json
{
  "space_id": "<uuid>",
  "thread_id": "<uuid>",
  "resource_type": "croux | agent | human | budget | time | tool | evidence_level | priority",
  "resource_key": "croux-p",
  "allocated_by": "human",
  "allocation_reason": "Research grounding for animal behaviour interpretation",
  "budget_amount": 20,
  "budget_unit": "calls",
  "priority": "normal"
}
```

## Evidence

### POST /api/evidence
```json
{
  "message_id": "<uuid>",
  "evidence_type": "api_response | database_result | cli_output | commit_id | url | hash | reproducible_steps",
  "evidence_value": "...",
  "status": "REAL | PARTIAL | BLOCKED"
}
```

## Exports

### POST /api/exports
```json
{ "space_id": "<uuid>", "thread_id": "<uuid>", "export_type": "txt | json | html | pdf", "scope": "thread | space | parties" }
```
Returns: `{ "storage_url": "https://..." }`

## Bridge

### POST /api/bridge/execute
Forwards to T4H bridge `zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke` with dual auth (`x-api-key` + `Authorization: Bearer`).

```json
{ "action": "<lambda_or_rpc>", "payload": { ... } }
```

Returns bridge response + writes evidence to `public.reality_ledger`.
