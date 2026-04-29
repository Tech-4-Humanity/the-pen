# FORGE TRIAL SWEEP RECOVERY

**Target Repo:** `TML-4PM/the-pen`  
**File:** `FORGE_TRIAL_SWEEP_RECOVERY.md`  
**Classification:** Operational / Execution / Recovery  
**Reality Ledger Status:** `PARTIAL -> REAL target`  
**Canonical Rule:** the-pen is canonical for rules, contracts, enforcement, and operational recovery handoffs.

---

## 1. Intent

Restore and execute the Forge Alpha trial sweep action:

```text
forge.run_trial_sweep
```

Against the S3 history lake:

```text
s3://llm-history-lake-140548542136-ap-southeast-2
```

Required behaviour:

- read exported LLM history files
- sample records safely
- write a runtime receipt
- bind execution to evidence
- preserve idempotency
- make the action replayable

---

## 2. Source Invocation

```json
{
  "idempotency_key": "forge-alpha-trial-20260429-001",
  "pod_id": "POD_SET_ALPHA_TRIAL_20260429_001",
  "action": "forge.run_trial_sweep",
  "payload": {
    "bucket": "llm-history-lake-140548542136-ap-southeast-2",
    "region": "ap-southeast-2",
    "files": [
      "conversations.json",
      "projects.json",
      "users.json"
    ],
    "sample_limit": 250,
    "write_receipt": true,
    "receipt_path": "receipts/runtime/forge-alpha-trial-20260429-001.receipt.json"
  }
}
```

---

## 3. Current State

| Component | Status | Evidence |
|---|---:|---|
| Bridge auth | PARTIAL | one-shot `SELECT 1` succeeded once |
| `troy-sql-executor` | BLOCKED | repeated `400 sql_error`, `command:null` after warm reuse |
| Forge action registration | BLOCKED | `forge.run_trial_sweep` not callable |
| Lambda availability | BLOCKED | no callable Lambda matching forge trial sweep |
| S3 read | NOT RUN | blocked before execution |
| Receipt write | NOT RUN | blocked before execution |
| Reality Ledger status | PARTIAL | design exists, runtime proof absent |

---

## 4. Failure Root Cause

### B1: SQL Executor Degradation

Observed pattern:

```text
First 1-2 calls may succeed after cold start.
Subsequent calls fail consistently:
400 sql_error
command:null
```

Likely cause:

- Supabase connection reuse/pool failure in warm Lambda lifecycle
- executor does not safely reinitialise DB connection per invocation
- once warm state is corrupted, all follow-up registry writes and verification queries fail

Impact:

- cannot reliably query `mcp_lambda_registry`
- cannot insert registry row
- cannot write canonical change records
- cannot safely bind runtime proof

### B2: Missing Lambda Creation Path

The requested action:

```text
forge.run_trial_sweep
```

is not registered as callable.

Additional constraints:

- `troy-code-pusher` can update existing Lambda code but cannot create new Lambda functions
- no `troy-lambda-deployer`, `troy-lambda-creator`, or equivalent creation callable was available in the bridge allow-list during probe
- direct `fn_github_push` / `troy-code-pusher` invocation was forbidden as standalone callable in that session

Impact:

- there is no deployed function target for the trial sweep code
- even with source code staged, execution cannot proceed until Lambda exists and registry is healthy

---

## 5. Required Fixes

### Fix 1: Repair `troy-sql-executor`

Redeploy or patch:

```text
troy-sql-executor
```

Mandatory behaviour:

- initialise a fresh Supabase/Postgres client per invocation, or validate and recreate on each call
- do not reuse poisoned warm-state connections
- return structured failure when SQL parsing/execution fails
- preserve command text in error output where safe
- support repeat calls without warm-state degradation

Acceptance check:

```sql
SELECT 1 AS ok
```

must return success across at least 10 repeated invocations in the same warm Lambda window.

### Fix 2: Create Forge Trial Sweep Lambda

Create a Lambda shell if it does not already exist:

```text
Function: troy-forge-trial-sweep
Runtime: python3.12
Memory: 512 MB
Timeout: 300 seconds
Role: lambda-execution-role
Region: ap-southeast-2
```

The shell may be empty initially if code-pusher is then used to install final source.

### Fix 3: Register Callable

Insert/update `mcp_lambda_registry`:

```sql
INSERT INTO mcp_lambda_registry (
  function_name,
  description,
  is_callable,
  is_rdti_relevant
)
VALUES (
  'troy-forge-trial-sweep',
  'Forge trial sweep: reads LLM history lake files from S3, samples records, writes runtime receipt, and binds execution evidence.',
  true,
  true
)
ON CONFLICT (function_name)
DO UPDATE SET
  description = EXCLUDED.description,
  is_callable = true,
  is_rdti_relevant = true,
  updated_at = now();
```

Important schema correction from live discovery:

| Memory / Assumption | Actual |
|---|---|
| `lambda_name` | `function_name` |
| `is_rd` | `is_rdti_relevant` |
| PK assumption uncertain | conflict target is `function_name` |

---

## 6. Lambda Behaviour Contract

### Input

```json
{
  "bucket": "llm-history-lake-140548542136-ap-southeast-2",
  "region": "ap-southeast-2",
  "files": ["conversations.json", "projects.json", "users.json"],
  "sample_limit": 250,
  "write_receipt": true,
  "receipt_path": "receipts/runtime/forge-alpha-trial-20260429-001.receipt.json"
}
```

### Required Processing

1. Validate payload.
2. Confirm idempotency key.
3. Read requested S3 files.
4. Parse JSON safely.
5. Sample up to `sample_limit` records across available source files.
6. Produce structured summary.
7. Write receipt to S3 if `write_receipt=true`.
8. Return structured execution result.

### Output Shape

```json
{
  "status": "SUCCESS|PARTIAL|FAILED",
  "idempotency_key": "forge-alpha-trial-20260429-001",
  "pod_id": "POD_SET_ALPHA_TRIAL_20260429_001",
  "files_requested": 3,
  "files_processed": 3,
  "records_sampled": 250,
  "receipt_written": true,
  "receipt_path": "receipts/runtime/forge-alpha-trial-20260429-001.receipt.json",
  "errors": [],
  "timestamp_utc": "ISO-8601"
}
```

---

## 7. Receipt Schema

```json
{
  "schema_version": "1.0",
  "idempotency_key": "forge-alpha-trial-20260429-001",
  "pod_id": "POD_SET_ALPHA_TRIAL_20260429_001",
  "action": "forge.run_trial_sweep",
  "classification": "REAL|PARTIAL|PRETEND",
  "status": "SUCCESS|PARTIAL|FAILED",
  "bucket": "llm-history-lake-140548542136-ap-southeast-2",
  "region": "ap-southeast-2",
  "files_requested": [
    "conversations.json",
    "projects.json",
    "users.json"
  ],
  "files_processed": [],
  "sample_limit": 250,
  "records_sampled": 0,
  "evidence": {
    "s3_read_attempted": true,
    "s3_read_success": false,
    "sampling_success": false,
    "receipt_write_attempted": true,
    "receipt_write_success": false,
    "replay_safe": true
  },
  "errors": [],
  "created_at_utc": "ISO-8601"
}
```

---

## 8. Proof Gates

To classify this as REAL, all gates must pass.

### Gate 1: Executor Proof

- `troy-sql-executor` returns success on repeated warm invocations
- registry queries do not flap

### Gate 2: Registry Proof

- `troy-forge-trial-sweep` exists in `mcp_lambda_registry`
- `is_callable=true`
- action alias maps correctly to function

### Gate 3: Lambda Execution Proof

- Lambda executes with the source invocation payload
- returns structured output
- no unhandled exception

### Gate 4: S3 Coverage Proof

- attempts all requested files
- returns per-file result
- distinguishes missing, unreadable, malformed, and successful files

### Gate 5: Receipt Proof

- writes receipt to:

```text
receipts/runtime/forge-alpha-trial-20260429-001.receipt.json
```

### Gate 6: Replay Proof

- repeating same idempotency key does not duplicate destructive work
- existing receipt is detected and surfaced

### Gate 7: Reality Ledger Binding

- intent, execution, output, classification, and evidence are logged
- no FINAL/REAL claim until proof exists

---

## 9. Recovery Runbook

### Phase A: Restore Executor

1. Patch/redeploy `troy-sql-executor`.
2. Run 10 repeated `SELECT 1 AS ok` calls.
3. Mark executor recovered only if all pass.

### Phase B: Create Lambda

1. Create `troy-forge-trial-sweep` if missing.
2. Apply runtime, timeout, memory, and IAM role settings.
3. Confirm Lambda can be invoked with a dry payload.

### Phase C: Push Code

1. Push final sweep code to Lambda.
2. Run smoke invocation.
3. Confirm structured response.

### Phase D: Register

1. Insert/update registry row.
2. Confirm callable status.
3. Confirm action alias/path if required by bridge resolver.

### Phase E: Execute Trial Sweep

1. Invoke original payload.
2. Read S3 files.
3. Sample records.
4. Write receipt.
5. Return proof bundle.

### Phase F: Bind Evidence

1. Write Reality Ledger record.
2. Classify as REAL only after receipt exists and replay proof passes.
3. Surface receipt in Command Centre.

---

## 10. Strategic Reuse

Once fixed, this pattern becomes the universal ingestion engine for:

- LinkedIn archive processing
- ChatGPT thread export processing
- Claude / Perplexity / Gemini history ingestion
- article clustering
- book candidate discovery
- course extraction
- business idea extraction
- dropped-action recovery
- prediction tracking
- evidence-backed research lake ingestion

Target downstream systems:

- Augmented Humanity Coach
- HoloOrg
- Outcome Ready
- Reading Buddy
- MyNeuralSignal
- LifeGraph+
- GirlMath distribution engine
- Reality Ledger
- Command Centre

---

## 11. Monetisation Path

The sweep engine is not a utility only. It should become a repeatable value loop:

```text
raw history -> structured memory -> topic clusters -> products -> offers -> campaigns -> receipts
```

Commercial outputs:

- books
- courses
- LinkedIn article packs
- founder knowledge base
- business opportunity maps
- lead magnets
- executive briefings
- paid audits
- reusable client ingestion engine

---

## 12. Final Target State

```text
STATUS: REAL
```

Required conditions:

- `troy-sql-executor` stable
- `troy-forge-trial-sweep` deployed
- registry updated
- bridge action callable
- source payload executed
- S3 files processed
- receipt written
- replay verified
- Reality Ledger bound
- Command Centre visible

---

## 13. Non-Negotiable Enforcement

Do not label this complete, final, or REAL until deploy and prove both pass.

Strongest truthful status before proof gates pass:

```text
PARTIAL / UNPROVEN
```

No paper city. No pretend infrastructure. No target-state masquerading as runtime state.
