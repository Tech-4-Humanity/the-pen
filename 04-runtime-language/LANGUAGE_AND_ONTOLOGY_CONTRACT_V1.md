# LANGUAGE_AND_ONTOLOGY_CONTRACT_V1

**Status:** PARTIAL -> executable contract created, repository-bound, awaiting Bridge runtime ingestion, connector testing, and telemetry validation.  
**Created:** 2026-05-15  
**Owner:** Troy Latter / Tech 4 Humanity operating stack  
**Canonical repo:** `TML-4PM/the-pen`  
**Purpose:** Convert everyday language, agent instructions, onboarding/offboarding semantics, and closure claims into deterministic runtime grammar with evidence, ownership, and recovery paths.

---

## 1. Executive summary

This contract captures a recurring system failure: common human words such as `done`, `start`, `begin`, `close`, `sent`, `finished`, `handoff`, and `approved` are not stable operational primitives. They are emotionally and contextually obvious to humans, but ambiguous to agents, bridges, runtimes, dashboards, and audit systems.

The result is operational drift:

- agents claim completion when only their local step is finished;
- Bridge ingestion is mistaken for runtime execution;
- runtime execution is mistaken for human-visible closure;
- humans become frustrated because ordinary words hide invisible stage gates;
- audit trails degrade because nouns and verbs are not bound to evidence;
- onboarding and offboarding fail because work grammar is assumed rather than taught;
- the system cannot reliably distinguish `operator done`, `Bridge done`, `runtime done`, and `human done`.

The correction is not a bigger document library. The correction is a personalised runtime ontology: nouns, verbs, states, closure levels, evidence, authority, escalation, offboarding, and personal vocabulary maps that convert Troy-language and human-language into executable system-language.

This is research-relevant because it explains why agentic systems fail even when the underlying code or content is good. The failure is often semantic, not technical. The system is not missing effort; it is missing a governed grammar for movement, proof, ownership, and closure.

---

## 2. Constitutional rule: language is infrastructure

Language in this operating stack is not decorative. It is infrastructure.

Every operationally significant noun or verb must eventually resolve to:

```yaml
canonical_term:
  type: noun|verb|state|closure|evidence|authority|surface|intent
  definition: string
  owner: string
  allowed_states: []
  allowed_transitions: []
  evidence_required: []
  runtime_surface: string
  human_surface: string
  closure_impact: string
  drift_risk: LOW|MEDIUM|HIGH|CRITICAL
```

Rule:

```yaml
undefined_operational_language:
  may_be_discussed: true
  may_trigger_execution: false
  may_claim_closure: false
```

If a term is operationally meaningful but undefined, the system must treat it as a contract gap, not as a successful instruction.

---

## 3. Why the education/work gap matters

Traditional education teaches nouns and verbs as grammar categories. Work systems require nouns and verbs as executable contracts.

A child may learn that a noun is a person, place, or thing. That does not prepare an adult operator, manager, AI agent, or founder to answer:

- What object does this noun refer to?
- Who owns it?
- What state can it be in?
- What verbs are allowed to change it?
- What evidence proves the object exists?
- What evidence proves the state changed?
- What does `done` mean for this object?
- Where does a human see the outcome?

This creates frustration at 28, 48, 58, and beyond because common language is doing hidden operational work. Humans use tone, context, face, pressure, memory, and shared history to disambiguate. Agents and runtime systems require explicit mappings.

The operating stack must therefore treat language onboarding as part of system onboarding.

---

## 4. Focus areas for onboarding

Identity is not the centre of this model. The higher-value onboarding surfaces are:

1. Goals
2. Culture
3. Work grammar
4. Executive control
5. Offboarding

### 4.1 Goals

Goals define what the system is trying to create, prevent, and compound.

```yaml
goals:
  north_star: string
  desired_outcomes: []
  success_metrics: []
  non_negotiables: []
  anti_goals: []
  kill_conditions: []
```

Default anti-goals for this stack:

```yaml
anti_goals:
  - silent_failure
  - false_completion
  - human_bottleneck_by_default
  - unowned_work
  - telemetry_gap
  - simulated_completion
  - receipt_mismatch
  - ontology_drift
```

### 4.2 Culture

Culture is not values on a wall. Culture is behaviour under pressure.

```yaml
culture:
  truth_over_comfort: true
  underclaim_over_overclaim: true
  receipts_over_assertions: true
  execution_over_theory: true
  fix_systems_not_people: true
  ambiguity_must_be_resolved: true
  no_silent_stall: true
```

### 4.3 Work grammar

Work grammar defines how nouns move through verbs into states with receipts.

```yaml
work_grammar:
  noun: object_with_state
  verb: authorised_state_change
  state: observable_condition
  evidence: proof_of_state_or_transition
  closure: level_specific_completion_claim
```

### 4.4 Executive control

Executive control does not require every detail. It requires the right exception surfaces.

```yaml
executive_surfaces:
  open_items: required
  silent_failures: required
  operator_closed_runtime_open: required
  stalled_transitions: required
  economic_impact: required
  risk_heatmap: required
  human_attention_required: required
```

### 4.5 Offboarding

Offboarding is not just revoking access. It is preserving learning and removing authority safely.

```yaml
offboarding:
  capture_memory: true
  capture_patterns: true
  transfer_ownership: true
  archive_evidence: true
  remove_authority: true
  preserve_learning: true
  close_runtime_obligations: true
```

---

## 5. Closure semantics

`Closed` is never a single state.

Every task must specify its closure level:

```yaml
closure_levels:
  closed_for_operator:
    meaning: current agent/operator completed its contracted work and handed off to next owner
    evidence: operator receipt, artifact, log, issue comment, file, or handoff payload

  closed_for_bridge:
    meaning: Bridge ingested the result, persisted it to expected surface, and recorded receipt
    evidence: Bridge receipt ID, queue record, repo commit, state-store row, or ingest log

  closed_for_runtime:
    meaning: target runtime executed and emitted observable effect
    evidence: deploy log, Lambda result, DB mutation, webhook result, telemetry event, runtime health check

  closed_for_human:
    meaning: human owner can see the expected outcome on the agreed status surface
    evidence: dashboard state, Notion/GitHub/Command Centre surface, report, notification, or visible closure row
```

No workflow may claim simply `closed` without naming the level.

Progression rule:

```yaml
closure_chain:
  - closed_for_operator
  - closed_for_bridge
  - closed_for_runtime
  - closed_for_human

higher_state_requires_lower_states: true
```

If a lower state is missing, higher closure is not achieved.

---

## 6. Runtime ontology corpus

Existing corpus files:

```text
01_NOUNS.csv
02_VERBS.csv
03_STATES.csv
04_CLOSURE.csv
05_EVIDENCE.csv
06_AUTHORITY.csv
07_ESCALATION.csv
08_OFFBOARDING.csv
09_PERSONAL_VOCABULARY.csv
```

Required expansion:

```text
10_RELATIONSHIPS.csv
11_STATE_TRANSITIONS.csv
12_RUNTIME_SURFACES.csv
13_INTENTS.csv
14_OBLIGATIONS.csv
15_RECEIPTS.csv
16_FAILURE_PATTERNS.csv
17_HUMAN_SIGNAL.csv
18_EXECUTION_GRAMMAR.csv
19_EXECUTIVE_SURFACES.csv
20_TRANSLATION_MAP.csv
21_WORKFLOW_PATTERNS.csv
22_OWNERSHIP_GRAPH.csv
23_CLOSURE_CHAIN.csv
24_RUNTIME_OBJECTS.csv
25_LANGUAGE_DRIFT.csv
```

A glossary defines terms. A runtime ontology defines movement, dependency, authority, evidence, and failure.

---

## 7. Required CSV schemas

### 10_RELATIONSHIPS.csv

```csv
id,source,target,relationship,relationship_type,authority_required,evidence_required,confidence,notes
rel_0001,done,operator_complete,maps_to,semantic,none,false,0.97,"Done often means operator complete, not full closure."
rel_0002,operator_complete,bridge_complete,precedes,state_chain,bridge,true,0.99,"Bridge cannot be complete until operator handoff exists."
rel_0003,bridge_complete,runtime_complete,precedes,state_chain,runtime,true,0.99,"Bridge receipt is not runtime execution."
rel_0004,runtime_complete,human_complete,enables,state_chain,human_surface,true,0.94,"Human closure requires visible outcome."
```

### 11_STATE_TRANSITIONS.csv

```csv
id,from_state,to_state,verb,authority,evidence_required,failure_state,timeout,notes
st_0001,received,normalised,normalise,agent,false,invalid_input,5m,"Input converted into canonical task shape."
st_0002,normalised,compiled,compile,bridge,true,compile_failed,5m,"Bridge creates executable plan."
st_0003,compiled,posted,post,bridge,true,post_failed,5m,"Artifact or instruction posted to target surface."
st_0004,posted,executed,execute,runtime,true,runtime_failed,10m,"Runtime completes action and emits evidence."
st_0005,executed,validated,validate,validator,true,validation_failed,10m,"Evidence checked against expectation."
st_0006,validated,evidenced,record,evidence_engine,true,evidence_missing,5m,"Receipt is written."
st_0007,evidenced,closed_for_human,surface,command_centre,true,human_surface_missing,24h,"Human-visible status exists."
```

### 12_RUNTIME_SURFACES.csv

```csv
id,surface,owner,type,purpose,required_for_closure,notes
surf_0001,github,Bridge,repo,source_of_change,bridge,"Canonical file and issue surface."
surf_0002,supabase,Runtime,state_store,system_state,runtime,"Structured runtime state."
surf_0003,command_centre,Human,dashboard,visibility,human,"Executive status surface."
surf_0004,receipt_store,Bridge,evidence,proof_chain,bridge,"Receipt persistence."
surf_0005,vercel,Runtime,deploy_status,public_runtime,runtime,"Deployment and runtime evidence."
```

### 13_INTENTS.csv

```csv
id,intent,canonical_action,required_outcome,owner,evidence_required,closure_target
intent_0001,finish_task,execute_and_advance_closure,closure_required,Bridge,true,closed_for_human
intent_0002,deploy_runtime,runtime_execute,runtime_execution,Runtime,true,closed_for_runtime
intent_0003,close_loop,record_and_surface_evidence,evidence_written,ClosureEngine,true,closed_for_human
intent_0004,discuss,reason_and_record_if_useful,conceptual_output,Agent,false,closed_for_operator
```

### 14_OBLIGATIONS.csv

```csv
id,object,obligation,severity,evidence_required,failure_pattern
obl_0001,task,must_have_owner,HIGH,true,unowned_work
obl_0002,closure,must_have_receipt,CRITICAL,true,false_completion
obl_0003,execution,must_have_runtime_evidence,CRITICAL,true,simulated_completion
obl_0004,runtime,must_emit_telemetry,HIGH,true,silent_failure
obl_0005,handoff,must_name_next_owner,HIGH,true,dead_handoff
```

### 15_RECEIPTS.csv

```csv
id,receipt_type,required_fields,valid_evidence_types,closure_level
rec_0001,operator,task_id+timestamp+artifact+next_owner,artifact|log|file|issue,closed_for_operator
rec_0002,bridge,task_id+bridge_id+storage_surface+status,api_response|db_result|commit_id,closed_for_bridge
rec_0003,runtime,task_id+runtime_id+result+telemetry,cli_output|api_response|url|db_result,closed_for_runtime
rec_0004,human,task_id+status_surface+visible_state,url|dashboard|notification|report,closed_for_human
```

### 16_FAILURE_PATTERNS.csv

```csv
id,pattern,signal,classification,recovery_action
fail_0001,receipt_missing,operator_done_only,PARTIAL,request_bridge_receipt
fail_0002,runtime_missing,bridge_closed_runtime_open,PARTIAL,trigger_runtime_check
fail_0003,state_loop,repeated_transition_without_progress,LOOPING,escalate_to_recovery
fail_0004,silent_timeout,no_activity_after_timeout,DEAD,reopen_and_assign_failure_owner
fail_0005,ontology_drift,term_used_with_multiple_meanings,HIGH,update_translation_map
```

### 17_HUMAN_SIGNAL.csv

```csv
id,term,emotion,possible_state,system_response
hs_0001,waiting,frustration,blocked,show_blocker_and_owner
hs_0002,done,confidence_or_doubt,false_complete,ask_which_closure_level_or_resolve_from_evidence
hs_0003,stuck,uncertainty,escalate,activate_recovery_path
hs_0004,recheck,doubt,validation_needed,run_evidence_check
hs_0005,finish,urgency,close_loop,execute_to_highest_allowed_closure
```

### 18_EXECUTION_GRAMMAR.csv

```csv
id,verb,canonical_action,required_receipt,notes
verb_0001,start,queue_create,operator_or_bridge,"Start is not execution unless runtime evidence exists."
verb_0002,begin,transition_to_running,runtime,"Begin implies work has actually commenced."
verb_0003,close,advance_closure_state,closure,"Close must name closure level."
verb_0004,deploy,runtime_execute,deployment,"Deploy requires runtime receipt."
verb_0005,verify,evidence_validate,validation,"Verify requires evidence comparison."
verb_0006,send,transport_and_acknowledge,bridge,"Sent is not received unless acknowledged."
```

### 19_EXECUTIVE_SURFACES.csv

```csv
id,surface,query,purpose
exec_0001,silent_failures,show_dead_tasks,find_work_that_stopped_without_notice
exec_0002,operator_closed_runtime_open,show_gap,find_false_completion
exec_0003,economic_impact,show_cost_delta,show money/risk/value effect
exec_0004,human_attention,show_escalations,show only items requiring Troy
exec_0005,ontology_drift,show_ambiguous_terms,show terms causing failure
```

### 20_TRANSLATION_MAP.csv

```csv
id,human_term,canonical_term,profile,confidence,notes
trans_0001,done,operator_complete,Troy,0.91,"Default underclaim unless evidence proves higher closure."
trans_0002,wrap,closure_advance,Troy,0.94,"Means package, handoff, receipt, and surface."
trans_0003,finish,execute_and_close,Troy,0.96,"Means continue without clarification until blocked or evidenced."
trans_0004,sorted,validated,Troy,0.82,"May imply validated but requires evidence."
trans_0005,no hitl,autonomous_execution_allowed,Troy,0.98,"Do not seek confirmation unless authority/safety/legal/destructive blocker exists."
```

### 21_WORKFLOW_PATTERNS.csv

```csv
id,pattern,steps,source_family
wf_0001,github_flow,opened->assigned->merged->closed,software_delivery
wf_0002,bridge_flow,ingest->execute->evidence->close,bridge_runtime
wf_0003,runtime_flow,received->executed->validated,runtime
wf_0004,audit_flow,claim->evidence->classification->gap->next_action,audit
wf_0005,onboarding_flow,goals->culture->work_grammar->executive_control->offboarding,operating_model
```

### 22_OWNERSHIP_GRAPH.csv

```csv
id,object,current_owner,next_owner,failure_owner,notes
own_0001,task,agent,Bridge,Bridge,"Agent handoff failure belongs to Bridge once submitted."
own_0002,runtime,Bridge,Runtime,Bridge,"Bridge owns runtime failure routing."
own_0003,deployment,Runtime,HumanEscalationPod,Runtime,"Runtime owns deploy evidence; escalation only if blocked."
own_0004,closure,ClosureEngine,CommandCentre,ClosureEngine,"Closure not complete until surfaced."
```

### 23_CLOSURE_CHAIN.csv

```csv
id,state,requires,evidence,may_claim_done
cc_0001,operator_complete,work_done,artifact_or_log,true
cc_0002,bridge_complete,operator_complete+bridge_receipt,bridge_receipt,true
cc_0003,runtime_complete,bridge_complete+runtime_execution,runtime_receipt,true
cc_0004,human_complete,runtime_complete+visible_status,human_surface,true
```

### 24_RUNTIME_OBJECTS.csv

```csv
id,object_type,required_fields,allowed_states,evidence_required
obj_0001,task,id+owner+state+intent,received|normalised|compiled|executed|closed,true
obj_0002,receipt,id+task_id+evidence+timestamp,created|validated|rejected,true
obj_0003,workflow,id+steps+authority+owner,draft|active|stalled|closed,true
obj_0004,runtime,endpoint+health+owner,available|degraded|failed,true
obj_0005,evidence,type+location+hash,submitted|validated|rejected,true
```

### 25_LANGUAGE_DRIFT.csv

```csv
id,term,old_meaning,new_meaning,risk,action
ld_0001,done,completed,operator_complete,HIGH,force_closure_level
ld_0002,bridge,transport,execution_spine,MEDIUM,update_noun_definition
ld_0003,close,finished,state_transition,HIGH,require_closure_receipt
ld_0004,start,begin_work,queue_or_runtime_start,HIGH,split_start_vs_begin
ld_0005,send,emit,deliver_and_acknowledge,MEDIUM,require_acknowledgement
```

---

## 8. Code implementation backlog: 25 workstreams

These 25 steps must not be forgotten. They are the implementation spine for turning this document into runtime infrastructure.

```yaml
implementation_steps:
  01_nouns:
    code: create ontology node loader for nouns
    output: ops.ontology_nodes entries where type = noun
    tests:
      - rejects empty term
      - rejects duplicate id
      - validates owner/state/evidence fields

  02_verbs:
    code: create verb registry and canonical action resolver
    output: verb -> canonical_action mappings
    tests:
      - start does not imply runtime execution
      - close requires closure level
      - verify requires evidence

  03_states:
    code: create state registry and state validator
    output: allowed states and invalid transition detection
    tests:
      - rejects unknown states
      - rejects illegal promotion
      - preserves prior state in receipt

  04_closure:
    code: implement closure chain engine
    output: closed_for_operator/bridge/runtime/human gates
    tests:
      - cannot claim human closure without runtime closure
      - cannot claim bridge closure without receipt
      - underclaims when evidence missing

  05_evidence:
    code: implement evidence type registry and validator
    output: typed evidence enforcement
    tests:
      - REAL requires typed evidence
      - url/hash/api_response/commit_id accepted
      - unsupported evidence rejected

  06_authority:
    code: implement authority resolver
    output: who may move which object through which state
    tests:
      - unauthorised state change blocked
      - failure_owner assigned
      - authority gap downgraded to PARTIAL/BLOCKED

  07_escalation:
    code: implement escalation rules and timeout detector
    output: stalled/dead/blocked transition escalation
    tests:
      - timeout creates escalation receipt
      - dead handoff assigned to failure_owner
      - no silent failure allowed

  08_offboarding:
    code: implement offboarding capture and authority removal checklist
    output: memory, ownership, authority, evidence closure
    tests:
      - authority removed after transfer
      - evidence archived
      - open obligations preserved

  09_personal_vocabulary:
    code: implement Troy vocabulary profile resolver
    output: human_term -> canonical_term translations
    tests:
      - no hitl maps to autonomous execution allowed
      - take your time maps to careful audit-grade execution
      - done defaults to underclaimed closure

  10_relationships:
    code: implement ontology edge loader
    output: ops.ontology_edges entries
    tests:
      - validates source and target exist
      - supports maps_to/precedes/requires/enables/blocks
      - detects cycles where forbidden

  11_state_transitions:
    code: implement transition engine
    output: from_state -> to_state enforcement
    tests:
      - evidence-required transition fails without evidence
      - failure state emitted on invalid move
      - transition receipt written

  12_runtime_surfaces:
    code: implement surface registry
    output: GitHub/Supabase/Command Centre/Vercel/receipt store mappings
    tests:
      - closure target requires matching surface
      - missing human surface blocks human closure
      - stale surface marked degraded

  13_intents:
    code: implement intent classifier and canonical action router
    output: intent -> required outcome -> owner
    tests:
      - finish_task routes to closure engine
      - deploy_runtime routes to runtime executor
      - discuss does not falsely trigger execution

  14_obligations:
    code: implement obligation checker
    output: required owner/evidence/receipt checks
    tests:
      - task without owner fails
      - closure without receipt fails
      - runtime without telemetry fails

  15_receipts:
    code: implement receipt writer and schema validator
    output: ops.ontology_receipts rows/files
    tests:
      - receipt ids unique
      - required fields enforced
      - receipt hash optional but supported

  16_failure_patterns:
    code: implement failure classifier
    output: false_completion/dead_handoff/runtime_missing/etc.
    tests:
      - operator_done_only -> PARTIAL
      - bridge_closed_runtime_open -> PARTIAL
      - no_activity_after_timeout -> DEAD

  17_human_signal:
    code: implement human language signal detector
    output: frustration/doubt/urgency/blocker hints
    tests:
      - waiting maps to blocked/frustration
      - recheck maps to validation_needed
      - stuck maps to escalation

  18_execution_grammar:
    code: implement verb-to-action runtime grammar
    output: canonical executable command forms
    tests:
      - send requires acknowledgement
      - begin means running not queued
      - close requires explicit level

  19_executive_surfaces:
    code: implement executive queries/widgets
    output: silent_failures, operator_closed_runtime_open, economic impact
    tests:
      - surfaces only exceptions by default
      - shows evidence gap
      - shows human attention required

  20_translation_map:
    code: implement profile-aware translator
    output: Troy-language/persona-language -> canonical language
    tests:
      - profile-specific mapping overrides generic mapping
      - low confidence mapping asks resolver or underclaims
      - drift event emitted on mismatch

  21_workflow_patterns:
    code: implement workflow pattern registry
    output: reusable GitHub/Bridge/runtime/audit/onboarding flows
    tests:
      - pattern expands into ordered steps
      - step failures assigned to owner
      - pattern version recorded in receipt

  22_ownership_graph:
    code: implement ownership graph and failure owner resolver
    output: current_owner,next_owner,failure_owner graph
    tests:
      - handoff requires next_owner
      - failed transition not orphaned
      - owner changes are receipted

  23_closure_chain:
    code: implement closure progression guard
    output: sequential closure enforcement
    tests:
      - higher closure cannot skip lower closure
      - evidence mismatch blocks promotion
      - closure underclaims correctly

  24_runtime_objects:
    code: implement runtime object model
    output: typed task/receipt/workflow/runtime/evidence objects
    tests:
      - required fields enforced
      - allowed states enforced
      - object evidence required when configured

  25_language_drift:
    code: implement drift detector and remediation queue
    output: ontology_drift events and update suggestions
    tests:
      - detects multiple meanings for same term
      - flags high-risk closure drift
      - creates update proposal for translation map
```

---

## 9. Connector test plan

The new connector/access path must be tested by others, not just by the creating operator.

### 9.1 Testers required

```yaml
connector_testing:
  required_testers:
    - Bridge operator
    - Runtime operator or automation
    - Human reviewer / Troy delegate
    - External agent where available
```

### 9.2 Required connector tests

```yaml
tests:
  github_connector:
    - locate repo TML-4PM/the-pen
    - fetch LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md
    - verify blob sha
    - create or update issue/comment receipt
    - confirm permission level

  notion_connector:
    - confirm reachable
    - identify valid parent page or database
    - create human-visible status page
    - write backlink to GitHub commit
    - confirm page URL visible to reviewer

  bridge_ingest_connector:
    - ingest repo file
    - parse required sections
    - parse CSV schemas
    - create Bridge receipt
    - report closed_for_bridge only after receipt exists

  runtime_connector:
    - create ontology tables if absent
    - upsert sample nodes and edges
    - write runtime receipt
    - expose state to query surface

  command_centre_connector:
    - surface executive status
    - show open gaps
    - show false-completion risks
    - show human attention required
```

### 9.3 Acceptance criteria

```yaml
acceptance:
  closed_for_operator:
    requires:
      - repo commit exists
      - issue receipt exists

  closed_for_bridge:
    requires:
      - Bridge ingest receipt exists
      - parsed sections validated
      - Bridge status surface updated

  closed_for_runtime:
    requires:
      - ontology tables/state store updated
      - sample transition executed
      - runtime evidence emitted

  closed_for_human:
    requires:
      - Command Centre or Notion page visible
      - human-readable status shows closure level
      - open gaps are visible
```

---

## 10. Bridge receipt request

```yaml
bridge_receipt_request:
  task_id: language_ontology_contract_v1_20260515
  request_type: ingest_and_test
  source:
    repo: TML-4PM/the-pen
    path: 04-runtime-language/LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md
    commit_sha_latest: TO_BE_FILLED_BY_COMMIT
  required_receipts:
    - operator_commit_receipt
    - bridge_ingest_receipt
    - connector_test_receipt
    - runtime_activation_receipt
    - human_surface_receipt
  required_test_assignment:
    - assign others to test GitHub connector
    - assign others to test Notion connector parent creation
    - assign others to test Bridge ingest
    - assign others to test runtime state table creation
  closure_claim_allowed_now: closed_for_operator_only
  closure_claim_blocked:
    - closed_for_bridge
    - closed_for_runtime
    - closed_for_human
```

---

## 11. Personal vocabulary profile

This stack must support personalised language maps. Troy's language has operational meaning that generic corpora will miss.

```yaml
vocabulary_profile:
  owner: Troy Latter
  profile_id: troy_runtime_language_v1
  principles:
    - execution_first
    - no_unnecessary_hitl
    - underclaim_until_evidenced
    - close_means_visible_outcome
    - bridge_is_execution_path_when_available
    - unavailable_tools_are_not_a_stop_condition
```

Example mappings:

```yaml
terms:
  "take your time":
    canonical_intent: careful_audit_grade_execution
    implication: do_not_rush_summary; produce durable artifact; bind evidence

  "close":
    canonical_intent: complete_to_highest_available_closure_level
    implication: do not stop at explanation if execution tools exist

  "get receipt":
    canonical_intent: obtain_typed_evidence
    implication: commit_id, issue_url, api_response, db_result, runtime_log, or explicit blocker

  "no hitl":
    canonical_intent: autonomous_execution_allowed
    implication: continue unless blocked by authority, credentials, legal, destructive, financial, or safety gates
```

---

## 12. Bridge ingestion contract

Bridge must ingest this file and create/update ontology tables or equivalent state stores.

```yaml
bridge_ingest_contract:
  name: language_and_ontology_contract_v1
  trigger:
    - repo_file_created_or_updated
    - manual_bridge_ingest
    - audit_recovery_run
  input:
    repo: TML-4PM/the-pen
    path: 04-runtime-language/LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md
  validation:
    - file_exists
    - required_sections_present
    - csv_schemas_parseable
    - closure_chain_present
    - translation_map_present
    - implementation_steps_25_present
    - connector_test_plan_present
  processing:
    - extract_sections
    - compile_csv_schema_targets
    - upsert_ontology_nodes
    - upsert_ontology_edges
    - upsert_translation_map
    - upsert_closure_chain
    - create_receipt
    - assign_connector_tests
  output:
    - ontology_runtime_state_updated
    - receipt_written
    - connector_test_receipt_created
    - command_centre_status_updated
  failure:
    - classify_as_PARTIAL
    - write_gap_report
    - assign_failure_owner
  evidence:
    - commit_id
    - github_issue_url
    - bridge_receipt_id
    - state_store_rows
    - command_centre_url
  authority:
    read: repo_file
    write: ontology_state_store, receipt_store, command_centre_status
  closure_level_target: closed_for_bridge
  next_owner: Bridge
  failure_owner: Bridge
```

---

## 13. Supabase/runtime table targets

The minimum runtime tables are:

```sql
create table if not exists ops.ontology_nodes (
  id text primary key,
  term text not null,
  type text not null,
  definition text,
  owner text,
  confidence numeric,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists ops.ontology_edges (
  id text primary key,
  source_id text not null,
  target_id text not null,
  relationship text not null,
  relationship_type text,
  evidence_required boolean default false,
  confidence numeric,
  created_at timestamptz default now()
);

create table if not exists ops.ontology_runtime_state (
  id text primary key,
  object_type text not null,
  object_id text not null,
  state text not null,
  owner text,
  evidence_id text,
  updated_at timestamptz default now()
);

create table if not exists ops.ontology_translation (
  id text primary key,
  profile_id text not null,
  human_term text not null,
  canonical_term text not null,
  confidence numeric,
  notes text,
  updated_at timestamptz default now()
);

create table if not exists ops.ontology_receipts (
  id text primary key,
  task_id text,
  receipt_type text not null,
  closure_level text,
  evidence jsonb,
  status text not null,
  created_at timestamptz default now()
);

create table if not exists ops.ontology_drift (
  id text primary key,
  term text not null,
  old_meaning text,
  new_meaning text,
  risk text,
  action text,
  created_at timestamptz default now()
);
```

---

## 14. Audit relevance

This explains recurring audit and research failures:

| Failure | Likely semantic cause | Correction |
|---|---|---|
| Task marked complete but no visible result | closure level collapsed | force closure level naming |
| Agent stops after writing artifact | operator closure mistaken for human closure | require next owner + status surface |
| Bridge receipt missing | handoff verb not tied to evidence | require receipt schema |
| Runtime not executed | Bridge closure mistaken for runtime closure | add closed_for_runtime |
| Troy frustration increases | human expectation and system state diverge | personalised vocabulary profile |
| Documents accumulate but system does not improve | manuals copied without executable grammar | mine patterns into ontology |
| Audit cannot prove status | evidence not bound to state transitions | ontology_receipts + Reality Ledger |

---

## 15. Reality Ledger entry

```yaml
ledger:
  task_id: language_ontology_contract_v1_20260515
  intent: create audit-grade runtime language ontology contract and submit to Bridge path
  execution:
    github_repo: TML-4PM/the-pen
    file_path: 04-runtime-language/LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md
    bridge_target: language_and_ontology_contract_v1
  output:
    - canonical contract document
    - required CSV schema expansion 10-25
    - 25 implementation workstreams
    - connector test plan
    - closure semantics upgrade
    - personalised vocabulary profile
    - Bridge ingest contract
    - Supabase table targets
  status: PARTIAL
  evidence:
    - commit_id_required_after_github_update
    - issue_url_required_after_bridge_receipt_issue
    - notion_or_command_centre_surface_required_after_ingest
  gaps:
    - Bridge runtime ingestion not yet evidenced
    - Supabase tables not yet created by this action
    - Command Centre surface not yet updated by this action
    - connector testing assigned but not yet performed by others
    - 72h survivability unproven
  next_action:
    - Bridge ingest file from repo
    - create ontology state tables if missing
    - upsert CSV schema definitions
    - emit Bridge receipt
    - assign and record connector testing by others
    - expose Command Centre executive surfaces
    - run drift detector across recent LLM/GitHub/Drive corpora
  elevation:
    - converts language ambiguity into runtime-governed infrastructure
    - creates audit explanation for false completion, dead handoffs, and semantic drift
    - converts 25 ontology files into code workstreams
  pressure_flags:
    - ontology_drift
    - false_completion
    - silent_failure
    - human_expectation_gap
    - connector_test_gap
  score:
    execution: 0.78
    evidence: 0.76
    economic: 0.84
    reuse: 0.97
    delta: 0.95
    overall: 0.86
```

---

## 16. Required next execution envelope

```json
{
  "task_id": "language_ontology_contract_v1_20260515",
  "intent": "ingest and activate runtime language ontology contract",
  "authority": "Bridge",
  "source": {
    "repo": "TML-4PM/the-pen",
    "path": "04-runtime-language/LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md"
  },
  "actions": [
    "fetch_repo_file",
    "validate_required_sections",
    "compile_csv_schemas_10_to_25",
    "create_or_update_ops_ontology_tables",
    "upsert_language_nodes_and_edges",
    "upsert_troy_translation_profile",
    "upsert_closure_chain",
    "write_reality_ledger_receipt",
    "create_connector_test_assignments",
    "surface_command_centre_status"
  ],
  "closure_target": "closed_for_bridge",
  "runtime_target": "closed_for_runtime_after_table_upsert_and_status_surface",
  "human_target": "closed_for_human_after_command_centre_visibility",
  "evidence_required": [
    "commit_id",
    "github_issue_url",
    "bridge_receipt_id",
    "connector_test_receipt",
    "db_result_or_table_upsert_log",
    "command_centre_url_or_status_surface"
  ],
  "failure_owner": "Bridge",
  "timeout_policy": {
    "bridge_ingest": "5m",
    "connector_test_assignment": "24h",
    "runtime_activation": "10m",
    "human_surface": "24h"
  }
}
```

---

## 17. Closure statement

This document is `closed_for_operator` only when committed to the canonical repo and accompanied by a commit receipt.

It becomes `closed_for_bridge` only after Bridge ingests it and emits a Bridge receipt.

It becomes `closed_for_runtime` only after ontology tables/state stores are updated and runtime evidence exists.

It becomes `closed_for_human` only after the Command Centre or equivalent human-visible surface shows the status.

Until then, any claim of simple `closed` is invalid.
