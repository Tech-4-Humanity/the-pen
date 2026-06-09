# DEPLOY.md

<!-- Rule reference: STANDING-RULE-DEPLOYABLE-ARTEFACT-PACKS v1.0 (TML-4PM/the-pen) -->
<!-- Execution loop: generate → post → receipt → continue — no HITL -->

## Pack identity

| Field | Value |
|---|---|
| Pack name | `<pack-name>` |
| Version | `<semver>` |
| Date | `<YYYY-MM-DD>` |
| Owner | Tech4Humanity |
| Target environment | `<dev / staging / prod>` |
| Target repo | `<org/repo>` |
| Governed by | STANDING-RULE-DEPLOYABLE-ARTEFACT-PACKS v1.0 |

---

## Artefacts in this pack

- [ ] DEPLOY.md (this file)
- [ ] Terraform / CloudFormation / CDK
- [ ] Deployment scripts
- [ ] SSM parameter definitions
- [ ] Smoke tests
- [ ] Docs
- [ ] GitHub operations (branches / PRs / issues)
- [ ] Machine-readable receipts

---

## Pre-flight checklist

Agent MUST verify before execution:

- [ ] Credentials available (cloud, GitHub, registry)
- [ ] Target repository / workspace is accessible
- [ ] No destructive production actions without declared change plan
- [ ] No legal / safety boundary conflicts
- [ ] External dependencies reachable

If any check fails → emit blocker receipt → halt → escalate.

---

## Execution plan

### Step 1 — Infrastructure / config

```
# Describe infra steps here
# e.g. terraform init && terraform apply -auto-approve
```

### Step 2 — Deploy

```
# Describe deploy steps here
# e.g. ./scripts/deploy.sh
```

### Step 3 — SSM parameter registry

```
# Describe SSM writes here (non-destructive, scoped)
```

### Step 4 — Smoke tests

```
# Describe smoke tests here
# e.g. ./scripts/smoke-test.sh
```

### Step 5 — Docs and GitHub operations

```
# Describe GitHub posting, issue updates, PR creation here
```

---

## Receipt spec

Every material operation in this pack MUST emit a machine-readable receipt:

```json
{
  "receipt_id": "<agent>-<YYYY-MM-DD>-<NNN>",
  "pack": "<pack-name>",
  "version": "<semver>",
  "step": "<step-name>",
  "status": "success | blocked | failed",
  "target": "<resource>",
  "executed_by": "<agent-id>",
  "timestamp": "<ISO8601>",
  "evidence": "<commit-sha | resource-arn | url>",
  "blocker_type": null
}
```

Blocker receipt adds:

```json
{
  "status": "blocked",
  "blocker_type": "missing_credentials | missing_repository_access | destructive_production_action | legal_safety_boundary | external_dependency_failure",
  "proposed_next_step": "<human-readable resolution>"
}
```

Receipts land at: `receipts/runtime/<agent>/<receipt-id>.json`

---

## Hard blockers (execution stops)

1. Missing credentials
2. Missing repository or workspace access
3. Destructive production action
4. Legal / safety boundary
5. External dependency failure

---

## Post-deploy

- [ ] All receipts written and verified
- [ ] Smoke tests passed
- [ ] GitHub issue / PR updated with receipt summary
- [ ] Escalations (if any) surfaced to orchestration layer
