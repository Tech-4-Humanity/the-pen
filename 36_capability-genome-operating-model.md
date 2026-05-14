# Capability Genome Operating Model

Status: PARTIAL until bridge receipt and Reality Ledger row are attached.

## Intent

Convert the current discussion into an executable model where conversations, market signals, country needs, SI work patterns, and internal capabilities resolve into reusable capability DNA.

The unit is not infrastructure. The unit is capability DNA.

Infrastructure, copy-paste text, prompts, checklists, campaigns, workflows, cloud templates, widgets, managed services, APIs, and department processes are all valid expressions of the same capability.

## Entity lock

| Entity | Name | Category | Function | Sale posture |
|---:|---|---|---|---|
| 31 | Memory Fabric | Runtime continuity | Operational memory across sessions, agents, workflows, decisions, and failures | Internal first; managed memory service later |
| 32 | Civic Kernel | Governance | Rules, policy, trust, conflict handling, and runtime governance | Internal first; governance service later |
| 33 | Institution Engine | Compiler | Converts capability packs into institution templates | Internal first; institution service later |
| 34 | State Engine | Orchestration | Converts intent into state transitions and deployable structures | Internal first; SDK/API later |
| 35 | Capability Supply Chain | Reuse logistics | Moves capability units across countries, sectors, partners, and channels | Internal first; partner exchange later |
| 36 | Capability Genome | Capability DNA | Canonical reusable pattern expressible in many forms | Internal doctrine; packaged externally case by case |

## Core loop

Problem detected -> capability genome selected -> expression rendered -> locality applied -> asset pack assembled -> governance checked -> deployment or handoff executed -> evidence captured -> pattern reused.

Nothing starts from zero.

## Capability Genome schema

```yaml
capability_genome:
  id: CAP-COORD-001
  canonical_name: Appointment Coordination
  intent: Reduce friction in scheduling, reminders, availability, routing, and follow-up.
  problem_types:
    - administrative_burden
    - missed_appointments
    - poor_follow_up
  compatible_industries:
    - healthcare
    - disability_services
    - aged_care
    - education
    - trades
    - government_services
    - enterprise_operations
  expressions:
    - agent
    - workflow
    - checklist
    - widget
    - website_section
    - campaign
    - brochure
    - cloud_template
    - managed_service
    - api
    - department_process
    - training_pack
  governance:
    consent_required: true
    privacy_level: medium
    audit_required: true
    human_override: true
  evidence:
    - deployed_asset_url
    - pricing_or_offer
    - runtime_log
    - user_outcome_measure
    - ledger_receipt
```

## Compact code model

Pattern:

```text
<CAPABILITY_CLASS>-<MARKET_ARCHETYPE>-<RUNTIME_PATTERN>-<MATURITY>
```

Example:

```text
DA-HC-COORD-M2
```

Meaning:
- DA = digital asset
- HC = healthcare
- COORD = coordination capability
- M2 = offer-ready maturity

## Country-level opportunity engine

The engine should produce top five opportunities by:

- country
- region
- sector
- regulatory shock
- partner channel
- speed to revenue
- reuse potential
- internal asset leverage

To customers these look local and specific. Internally they are mostly variable changes over reusable capability patterns.

## SI work as first wedge

| SI work type | Capability Genome expression |
|---|---|
| Discovery workshop | Intake and signal extraction pack |
| Requirements gathering | Business analyst agent and requirement schema |
| Process mapping | HoloOrg process decomposer |
| Solution architecture | Reference architecture compiler |
| Migration planning | Migration pattern pack |
| Change management | AHC change pack |
| Training | Course and workbook generator |
| Testing | QA and regression agent pack |
| Governance | Civic Kernel and ConsentX pack |
| Reporting | Dashboard and evidence pack |
| Runbooks | Ops automation pack |
| Support | Service desk agent pack |

Positioning: productise the repeatable part of SI work, then route genuinely complex work to partners.

## First seed genomes

```csv
id,canonical_name,capability_class,primary_expression,reuse_score,external_posture
CAP-COORD-001,Appointment Coordination,coordination,agent_workflow_widget,0.94,managed_service_ready
CAP-INTAKE-001,Service Intake,intake,form_agent_dashboard,0.96,product_pack_ready
CAP-EVIDENCE-001,Evidence Capture,evidence,ledger_dashboard_report,0.97,compliance_service_ready
CAP-CAMPAIGN-001,Campaign Launch,marketing,website_email_social_pack,0.92,campaign_in_a_box
CAP-GOV-001,Consent Governance,governance,consent_policy_audit_pack,0.95,governance_service_ready
CAP-DISCOVERY-001,Discovery Workshop Automation,consulting,agent_template_report,0.91,SI_partner_pack
CAP-TRAINING-001,Training Pack Generation,enablement,course_workbook_video_script,0.89,course_service_ready
CAP-MIGRATION-001,Migration Planning,technology,assessment_roadmap_runbook,0.90,partner_delivery_pack
```

## Execution gates

A capability is not mature until it has canonical ID, owner entity, expression matrix, localisation rules, governance rule, pricing posture, evidence requirement, deployment path, rollback rule, receipt trail, reuse score, and economic score.

## Required next execution

Run the bridge payload to:

1. create capability registry tables,
2. seed entities 31-36,
3. seed first eight capability genomes,
4. create opportunity scoring loop for country and sector top five,
5. write a Reality Ledger evidence row,
6. return receipt.

## Reality binding

status: PARTIAL
result: Canonical capability genome model prepared for execution.
evidence: GitHub commit receipt from this file creation.
gaps: Bridge execution and ledger insertion still required.
next_action: Send bridge payload for schema and seed execution.
elevation: Architecture moved from infrastructure-first to capability-DNA-first.
pressure_flags: no_hitl_requested; autonomous_finish_required; bridge_receipt_required
score: 0.78 before bridge receipt; target 0.93 after receipt and ledger row.
