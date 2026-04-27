# ops.predev v1.0 — Build Instructions
## Status: AWAITING SYSTEM APPROVAL

---

## Artefact map

| File | Deploy target | Action |
|------|--------------|--------|
| `ddl.sql` | Supabase lzfgigiyqpuuxslsygjt | `execute_sql` via Supabase MCP |
| `lambdas/predev-ingest/` | AWS Lambda (ap-southeast-2) | New fn: predev-ingest, Node 20, 256MB, 15s |
| `lambdas/predev-promote/` | AWS Lambda (ap-southeast-2) | New fn: predev-promote, Node 20, 256MB, 15s |
| `the-pen-ingest/ingest.js` | TML-4PM/the-pen → `/api/ingest.js` | Push to repo, Vercel auto-deploys |
| `command-centre/PredevPage.tsx` | TML-4PM/mcp-command-centre → `/src/pages/PredevPage.tsx` | Push to repo + wire route in App.tsx |
| `ops-predev-design.docx` | TML-4PM/the-pen → `/docs/ops-predev-design.docx` | Design record |

---

## Build sequence (in order)

### Step 1 — DDL (Supabase MCP)
```
Supabase:execute_sql(project_id="lzfgigiyqpuuxslsygjt", query=<ddl.sql contents>)
```
Expected: table + 5 indexes + 2 triggers + 2 views created. No errors.

### Step 2 — predev-ingest Lambda
```
zip -r predev-ingest.zip lambdas/predev-ingest/
aws lambda create-function \
  --function-name predev-ingest \
  --runtime nodejs20.x \
  --handler index.handler \
  --memory-size 256 \
  --timeout 15 \
  --environment Variables={SUPABASE_URL=https://lzfgigiyqpuuxslsygjt.supabase.co,SUPABASE_SERVICE_KEY=<key>} \
  --zip-file fileb://predev-ingest.zip \
  --role <existing-lambda-role-arn>
```

### Step 3 — predev-promote Lambda
Same pattern as step 2, function-name: predev-promote.

### Step 4 — The Pen /api/ingest
```
# Push the-pen-ingest/ingest.js to TML-4PM/the-pen as api/ingest.js
# Add env vars to Vercel the-pen project:
#   PREDEV_INGEST_URL = https://<apigw>/lambda/invoke?fn=predev-ingest
#   GITHUB_WEBHOOK_SECRET = <generate: openssl rand -hex 32>
```

### Step 5 — GitHub webhook on TML-4PM/the-pen
```
POST https://api.github.com/repos/TML-4PM/the-pen/hooks
{
  "config": {
    "url": "https://the-pen.vercel.app/api/ingest",
    "content_type": "json",
    "secret": "<GITHUB_WEBHOOK_SECRET>"
  },
  "events": ["push"],
  "active": true
}
```

### Step 6 — Command Centre route
```
# Push command-centre/PredevPage.tsx to TML-4PM/mcp-command-centre
# Add to App.tsx: import PredevPage from './pages/PredevPage'
# Add route: <Route path="/predev" element={<PredevPage />} />
# Add nav entry: { path: '/predev', label: 'Pre-dev' }
```

### Step 7 — MCP server env vars (fix AWS + GitHub tools)
```
Vercel project: t4h-remote-mcp-server-clean
Add env vars:
  AWS_ACCESS_KEY_ID     = <key>
  AWS_SECRET_ACCESS_KEY = <secret>
  AWS_REGION            = ap-southeast-2
  GITHUB_TOKEN          = github_pat_11AO5POAQ0qzh6ZTBrZaou_...
```

### Step 8 — Seed initial blockers
Call predev-ingest for each known current blocker (see design doc section 3.2).

### Step 9 — Verify
```json
// Insert test item
POST predev-ingest: { "title": "test item", "item_type": "wip", "status": "ready" }
// Promote it
POST predev-promote: { "id": "<returned id>", "force": true }
// Confirm promoted, queue_id set, unblock trigger fired
```

### Step 10 — System receipt
predev-promote writes receipt row automatically. Final receipt:
```json
{
  "title": "ops.predev v1.0 — system build complete",
  "item_type": "pen",
  "source_type": "agent",
  "status": "promoted",
  "notes": "<links to deployed artefacts>"
}
```

---

## Env vars summary

| Var | Where | Value |
|-----|-------|-------|
| SUPABASE_URL | Lambda x2 | https://lzfgigiyqpuuxslsygjt.supabase.co |
| SUPABASE_SERVICE_KEY | Lambda x2 | eyJhbG... |
| PREDEV_INGEST_URL | The Pen Vercel | Lambda API GW URL |
| GITHUB_WEBHOOK_SECRET | The Pen Vercel | openssl rand -hex 32 |
| AWS_ACCESS_KEY_ID | MCP server Vercel | from IAM |
| AWS_SECRET_ACCESS_KEY | MCP server Vercel | from IAM |
| AWS_REGION | MCP server Vercel | ap-southeast-2 |
| GITHUB_TOKEN | MCP server Vercel | github_pat_11AO5POAQ0... |

---

## Receipt format
Each step writes to ops_predev:
```json
{
  "title": "RECEIPT: <step description>",
  "item_type": "pen",
  "source_type": "agent",
  "status": "promoted",
  "priority": 5,
  "notes": "{ outcome, evidence, timestamp }"
}
```
