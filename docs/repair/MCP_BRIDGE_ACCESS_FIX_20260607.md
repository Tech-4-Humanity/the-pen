# MCP Bridge Access Fix — 2026-06-07

## Status: RESOLVED ✅

Bridge was returning `401 UNAUTHORIZED` then `403 FORBIDDEN` on all Lambda invocations. Root cause was an auth **shape mismatch** — not a broken bridge or wrong key.

---

## Root Cause

The bridge (`mcp-bridge-invoke-handler`) reads auth from `event.headers["x-api-key"]` but also from **top-level `x-` prefixed keys** on the event object directly:

```js
// handler.mjs line 244-247
for (const [k, v] of Object.entries(event.headers || {})) headers[k.toLowerCase()] = v;
for (const k of Object.keys(event)) if (k.toLowerCase().startsWith("x-")) headers[k.toLowerCase()] = event[k];
const key = headers["x-api-key"];
```

When invoking via `aws lambda invoke`, there is no API Gateway wrapping — so `event.headers` is empty. The key must be passed **at the top level** of the event payload as `x-api-key`.

Additionally, the body requires a `fn` field (not `action`) referencing a valid function name from the Supabase `mcp_lambda_registry` table.

---

## Auth Chain

| Layer | Field | Source |
|---|---|---|
| API key | `x-api-key` (top-level event key) | SSM `/t4h/bridge/api_key` or `/t4h/canonical/BRIDGE_API_KEY` |
| Key validation | compared against `process.env.BRIDGE_API_KEY` | Lambda env var |
| HMAC | optional — only enforced if `BRIDGE_REQUIRE_HMAC=true` | currently disabled |
| Function allowlist | `body.fn` must exist in Supabase `mcp_lambda_registry` where `is_callable=true` | loaded fresh with 60s TTL |

---

## Correct Invoke Pattern

### Via `aws lambda invoke` (direct)

```bash
aws lambda invoke \
  --function-name mcp-bridge-invoke-handler \
  --cli-binary-format raw-in-base64-out \
  --payload '{"x-api-key":"<BRIDGE_API_KEY>","body":"{\\"fn\\":\\"<FUNCTION_NAME>\\",\\"payload\\":{}}"}' \
  /tmp/out.json && cat /tmp/out.json
```

### Via API Gateway / HTTP

```bash
curl -X POST <BRIDGE_URL> \
  -H "x-api-key: <BRIDGE_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"fn":"<FUNCTION_NAME>","payload":{}}'
```

### Key rules
- `x-api-key` goes in **event root** for direct Lambda invokes (not nested in `headers`)
- `body` must be a **JSON string** (not object) when sent as Lambda payload
- `fn` is the field name — never `action`
- `fn` value must be registered in `mcp_lambda_registry` with `is_callable=true`

---

## Querying the Allowlist

```bash
SUPA_URL=$(aws ssm get-parameter --name /t4h/supabase/s1/url --query Parameter.Value --output text)
SUPA_KEY=$(aws ssm get-parameter --name /t4h/supabase/s1/service_key --with-decryption --query Parameter.Value --output text)

curl -s "${SUPA_URL}/rest/v1/mcp_lambda_registry?is_callable=eq.true&select=function_name" \
  -H "apikey: $SUPA_KEY" \
  -H "Authorization: Bearer $SUPA_KEY" | python3 -c "import sys,json; [print(r['function_name']) for r in json.load(sys.stdin)]"
```

---

## Health Check

Verify the bridge is live at any time:

```bash
BRIDGE_KEY=$(aws ssm get-parameter --name /t4h/bridge/api_key --with-decryption --query Parameter.Value --output text)

aws lambda invoke \
  --function-name mcp-bridge-invoke-handler \
  --cli-binary-format raw-in-base64-out \
  --payload "{\"x-api-key\":\"$BRIDGE_KEY\",\"body\":\"{\\\"fn\\\":\\\"troy-health-check-worker\\\",\\\"payload\\\":{}}\"}"\
  /tmp/out.json && cat /tmp/out.json
```

Expected: `{"statusCode":200,"body":{"ok":true,...}}`

---

## What Was Tried & Failed

| Attempt | Result | Reason |
|---|---|---|
| `curl` to API Gateway with `x-api-key` header | 401 | Wrong API Gateway URL / stage |
| Lambda invoke with `headers:{"x-api-key":...}` in payload | 401 | `event.headers` is empty in direct Lambda invokes |
| Lambda invoke with `body:{"action":"ping"}` | 403 | `action` is not the field name; `fn` is required |
| Lambda invoke with `fn:"troy-test-ping"` | 403 | Function not in `mcp_lambda_registry` allowlist |
| Lambda invoke with `x-api-key` at event root + `fn:"troy-health-check-worker"` | **200 ✅** | Correct shape |

---

## Evidence

- `invocation_id`: `b8b83cd5-c98c-45cc-b433-3a4d849135ef`
- `started_at`: `2026-06-06T21:29:59.670364Z`
- All health components PASS: `supabase_service_role`, `audit_log_readable`, `symbio_heartbeat`, `work_queue_throughput`, `worker_runtime`
- Resolved: 2026-06-07 07:30 AEST
