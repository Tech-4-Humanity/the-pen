# GLOBAL_RULE.md
## Tech 4 Humanity — Autonomous Execution Doctrine (GitHub Control Layer)

---

## GLOBAL RULE (NON-NEGOTIABLE)

All AI-generated actions are **intent only**.  
All execution occurs via **MCP Bridge using controlled functions**.  
Direct system access is **forbidden**.

---

## 1. ABSOLUTE RULE

**No AI, tool, script, or human-adjacent process writes to GitHub directly.**

This includes:
- ChatGPT
- Perplexity
- Grok
- Claude
- Scripts
- Local machines
- Connectors
- UI actions

---

## 2. SINGLE EXECUTION PATH

All repository operations MUST follow:

```text
ANY ACTOR
    ↓
MCP BRIDGE
    ↓
troy-intent-normalizer (optional)
    ↓
troy-code-pusher
    ↓
GitHub (PAT Auth)
    ↓
RECEIPT (Git + Supabase)
```

No alternative paths exist.

---

## 3. STANDARD PAYLOAD CONTRACT

All actors MUST emit, or be normalized to:

```json
{
  "action": "invoke_function",
  "function_name": "troy-code-pusher",
  "payload": {
    "repo": "TML-4PM/the-pen",
    "branch": "main",
    "files": [],
    "commit_message": "auto: execution"
  }
}
```

Invalid payloads are rejected.

---

## 4. CONNECTOR BAN

The following are permanently disallowed:

- GitHub UI “Create File”
- OAuth-based GitHub Apps in interactive write mode
- ChatGPT GitHub connector direct writes
- Perplexity GitHub connector direct writes
- Grok integrations with direct write access
- Claude direct GitHub write connectors
- Any direct REST API calls from AI tools to GitHub

---

## 5. ENFORCEMENT LAYER

Inside MCP Bridge:

```javascript
if (request.destination === "github" && request.source !== "troy-code-pusher") {
  throw new Error("BLOCKED: Direct GitHub access is not permitted");
}
```

---

## 6. CREDENTIAL ISOLATION

GitHub PATs are stored ONLY in:
- AWS Secrets Manager; or
- Supabase secure vault.

PATs must NEVER be exposed to:
- browser sessions
- local workstation scripts
- frontend code
- AI tool sessions
- logs
- prompt context

---

## 7. RECEIPT SYSTEM (MANDATORY)

Every execution MUST produce both:

### Git Receipt

```text
/receipts/<request_id>.json
```

Example:

```json
{
  "request_id": "pen-deploy-001",
  "status": "SUCCESS",
  "repo": "TML-4PM/the-pen",
  "commit_sha": "<sha>",
  "files": ["pen.json"],
  "timestamp": "2026-04-24T00:00:00Z"
}
```

### Supabase Log

Table: `t4h_execution_log`

Required fields:
- request_id
- actor
- repo
- commit_sha
- status: REAL / PARTIAL / FAILED
- files
- timestamp

No receipt means the action is not done.

---

## 8. ACTOR COMPLIANCE

All AI systems:
- MUST NOT call GitHub directly
- MUST emit MCP-compatible payloads
- ARE treated as stateless intent generators
- MUST NOT hold GitHub credentials
- MUST NOT bypass `troy-code-pusher`

---

## 9. NORMALIZATION LAYER

All malformed, natural-language, or partial actor inputs pass through:

```text
troy-intent-normalizer → troy-code-pusher
```

This ensures:
- consistent payload shape
- rejection of unsafe routes
- reproducible execution
- receipt binding

---

## 10. KILL SWITCH

If ANY of the following occur:
- GitHub confirmation prompt appears
- manual approval is required
- unknown execution path is detected
- direct GitHub write attempt is detected

Then:

```text
System state = PARTIAL / NON-AUTONOMOUS
```

Immediate actions:
1. Block execution.
2. Log violation.
3. Route back to MCP pathway.
4. Require a runtime receipt before claiming completion.

---

## OPERATING TRUTH

> If a human sees a confirmation dialog, the system is broken.

---

## RESULTING SYSTEM

- One execution path
- One authentication layer
- One audit system
- Infinite AI actors
- Zero connector inconsistency
- Fully autonomous GitHub operations when the MCP layer is available

---

## CANONICAL STATEMENT

```text
GLOBAL RULE:
All AI-generated actions are intent only.
All execution occurs via MCP Bridge using controlled functions.
Direct system access is forbidden.
```

---

## STATUS

**ACTIVE — ENFORCED — PERMANENT**
