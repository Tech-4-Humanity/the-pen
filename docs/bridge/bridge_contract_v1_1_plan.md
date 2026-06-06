# Bridge Contract v1.1 – Implementation Plan

## Background

An outage in the **MCP Bridge** wasn’t caused by a broken Lambda or invalid key, but by a **contract drift** between the caller and the invoked Lambda.  The bridge expected an invocation payload with the API key in the request root (`x‑api‑key`) and the function to execute under a `fn` field in the request body.  The integration code had drifted so it was sending the key in `headers.x‑api‑key` and using `action` instead of `fn`.  As a result, calls failed even though the key and the Lambda were healthy.

The correct contract is now defined as follows:

```json
{
  "x-api-key": "<BRIDGE_API_KEY>",
  "body": "{\"fn\":\"troy-health-check-worker\",\"payload\":{}}"
}
```

* **API key position:** The API key is provided at the top-level of the invocation event. AWS API Gateway treats API keys as a unique identifier to control access to an API and they are typically passed in the `X-API-Key` header. In our direct Lambda invocation we surface it at the root because there is no HTTP header context.
* **Function name field:** Use `fn` to indicate the name of the Lambda to execute rather than the generic `action` field.
* **Allow-list source:** Validate `fn` values against the `mcp_lambda_registry` table in Supabase where `is_callable=true`.
* **HMAC behaviour:** Only required if `BRIDGE_REQUIRE_HMAC=true`.
* **Health check:** `troy-health-check-worker` is the canonical probe function.
* **Secrets:** API key stored in SSM at `/t4h/bridge/api_key`.

---

## Implementation Tasks

### 1. Contract schema
Define JSON schema `schemas/bridge-contract-v1.1.json` with required fields: `x-api-key`, `body.fn`, `body.payload`.

### 2. Pre-invoke validator
Enforce:
- x-api-key exists
- fn exists
- fn is in mcp_lambda_registry
- API key matches SSM secret
- optional HMAC validation

### 3. Shape telemetry
Log:
- shape hash
- diff vs expected schema
- contract version

### 4. SDK wrapper
Provide `invokeBridge(fn, payload)` to enforce correct structure and secret handling.

### 5. Telemetry + ledger
Emit runtime receipts for:
- invocation
- success/failure
- cost attribution

### 6. Documentation
Include:
- correct/incorrect examples
- schema versioning rules
- registry usage

### 7. System alignment
Next steps:
- object graph runtime
- telemetry ledger
- orchestration engine
- deterministic recovery
- survivability testing

---

## Outcome
This eliminates contract drift by enforcing a single invocation shape and introducing validation, telemetry, and SDK-level guardrails.
