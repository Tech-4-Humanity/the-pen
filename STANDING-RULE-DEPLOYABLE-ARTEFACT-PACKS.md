# STANDING RULE — DEPLOYABLE ARTEFACT PACKS (NO HITL)

Status: Active  
Version: 1.0  
Date: 2026-06-09  
Owner: Tech4Humanity / GLOBAL_RULE_KERNEL_V6  
Applies to: Deployable artefact packs (infra + CI/CD + docs)  

---

## 1. Scope

This rule applies to deployable artefact packs that include any of:

- `DEPLOY.md`
- Terraform modules and plans
- CloudFormation stacks and templates
- AWS CDK apps
- Deployment scripts (CI/CD jobs, shell, Node, Python, etc.)
- SSM parameter registry definitions and updates (non-destructive, scoped)
- Smoke tests and health checks
- Documentation updates
- GitHub operations (branches, commits, PRs, tags)
- Issue and project updates
- Machine-readable runtime receipts

---

## 2. Default behaviour

For in-scope packs, the default execution loop is:

```
generate → post → receipt → continue
```

- No human-in-the-loop once a session is authorised
- No repeated approval prompts
- Every material operation MUST emit a machine-readable receipt
- Execution stops only on a true hard blocker (see §3)

Receipts MUST conform to the active receipt spec (COAX / Gatekeeper), be machine-parseable, and be written to the configured `receipts/runtime/...` path for the executing agent.

---

## 3. Allowed hard blockers

Execution MUST halt and surface a blocker receipt ONLY when one or more of:

1. **Missing credentials**  
   Required cloud, GitHub, registry, or secret material is unavailable or invalid.

2. **Missing repository or workspace access**  
   Target repo, branch, environment, workspace, or project cannot be read or written.

3. **Destructive production action**  
   Operation would irreversibly destroy or corrupt production data or infra beyond explicitly declared safety rails and change plans.

4. **Legal / safety boundary**  
   Action would violate legal, compliance, privacy, or safety constraints for the organisation or affected parties.

5. **External dependency failure**  
   Critical external systems (APIs, build systems, cloud infra, SCM) are failing, unreachable, or returning non-transient errors.

On any hard blocker, the agent MUST:

- Stop the affected operation
- Emit a blocker-class receipt with: `blocker_type`, `detected_by`, `target`, `proposed_next_step`
- Surface the blocker to the orchestration layer for escalation

---

## 4. Governance alignment

This rule inherits and implements:

- **WAVE-20 Execution Contract** — build to real end-state, leave nothing passive, partial, or dependent on a human
- **GLOBAL_RULE_KERNEL_V6** — minimum scoring thresholds:
  - execution ≥ 0.85
  - evidence ≥ 0.90
  - economic ≥ 0.80
  - reuse ≥ 0.85
  - delta ≥ 0.80
  - survivability ≥ 0.90
  - autonomy ≥ 0.85
  - recovery ≥ 0.85
  - telemetry ≥ 0.90

Interaction mode for in-scope packs: `Autonomous`  
Governance level: `Medium` (or as declared in pack manifest)

Public-facing collateral (marketing sites, press, legal docs) may define stricter HITL requirements in their own rules; those override this rule where they conflict.

---

## 5. Storage and precedence

- Canonical copy lives in `TML-4PM/the-pen` (repo root)
- Where there is a conflict between this file and local pack rules, the-pen version takes precedence
- Packs SHOULD reference this rule in their `DEPLOY.md` header

---

## 6. Machine-readable manifest

```json
{
  "rule_id": "STANDING-RULE-DEPLOYABLE-ARTEFACT-PACKS",
  "version": "1.0",
  "status": "active",
  "date": "2026-06-09",
  "hitl_required": false,
  "default_loop": ["generate", "post", "receipt", "continue"],
  "blockers": [
    "missing_credentials",
    "missing_repository_access",
    "destructive_production_action",
    "legal_safety_boundary",
    "external_dependency_failure"
  ],
  "governance_parents": ["WAVE-20-EXECUTION-CONTRACT", "GLOBAL_RULE_KERNEL_V6"],
  "interaction_mode": "Autonomous",
  "canonical_repo": "TML-4PM/the-pen",
  "canonical_path": "STANDING-RULE-DEPLOYABLE-ARTEFACT-PACKS.md"
}
```
