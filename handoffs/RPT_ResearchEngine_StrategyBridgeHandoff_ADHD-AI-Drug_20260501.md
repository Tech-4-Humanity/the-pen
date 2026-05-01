# Research Engine Strategy Bridge Handoff

**Asset:** RPT_ResearchEngine_StrategyBridgeHandoff_ADHD-AI-Drug_20260501  
**Date:** 2026-05-01  
**Owner:** Tech 4 Humanity / Outcome Ready / AI Sweet Spots  
**Status:** PARTIAL → Bridge Execution Required  
**Intent:** Close the research-data-study-survey-atlas-recommendation-monetisation system into an executable bridge package.

---

## 1. Executive Summary

This package converts the research best-practice framework and flagship ADHD × AI × Drug Interaction study into a bridge-ready execution handoff.

The strategy is complete. The current system spine includes:

- study master template
- flagship study example
- protocol model
- data dictionary requirements
- participant lifecycle
- survey intake
- ingestion API
- Supabase schema
- Atlas dashboard concept
- recommendation engine
- monetisation ladder
- Reality Ledger binding
- proof gates

The system is not yet fully REAL because the four final operating links are not wired:

1. event wiring
2. recommendation persistence
3. monetisation event capture
4. evidence auto-binding

Bridge must finish these as execution work, not further strategy.

---

## 2. Canonical Study

| Field | Value |
|---|---|
| Study ID | STUDY_AISS2_ADHD_AI_DRUG_20260501 |
| Study Name | ADHD, AI Augmentation, and Drug Interaction Study |
| Program | AI Sweet Spots / Outcome Ready |
| Topic | Neurodiversity, AI augmentation, stimulant use, cognitive performance |
| Type | Mixed-method: survey + behavioural + inferred signal analysis |
| Location | Australia + Global digital |
| Population | Adults 18–65, neurodiverse and neurotypical |
| Target Sample | 10,000 |
| Claimed Actual Sample | 11,241 |
| Evidence State | PARTIAL until raw dataset and reproducible queries are bound |
| Product Surfaces | Outcome Ready, Reading Buddy, Drug Resilience Atlas, WorkFamilyAI |

---

## 3. Study System Scope

The bridge package must preserve the full end-to-end loop:

```text
Study → Protocol → Survey → Consent → Participant → Data Point → Atlas → Recommendation → Offer → Evidence → Report → Reuse
```

Nothing is complete unless the loop can be replayed.

---

## 4. Required Supabase Schema Closure

The previous schema needs to be hardened with these missing production tables.

```sql
create table if not exists research_variable_dictionary (
  id uuid primary key default gen_random_uuid(),
  study_id uuid references studies(id),
  variable_name text not null,
  label text,
  description text,
  data_type text check (data_type in ('text','number','boolean','date','category','json')),
  allowed_values jsonb,
  unit text,
  source text,
  sensitivity text check (sensitivity in ('public','internal','confidential','restricted')) default 'internal',
  required boolean default false,
  active boolean default true,
  created_at timestamptz default now(),
  unique(study_id, variable_name)
);

create table if not exists research_recommendations (
  id uuid primary key default gen_random_uuid(),
  study_id uuid references studies(id),
  participant_id uuid,
  input_snapshot jsonb not null,
  recommendation_type text not null,
  recommendation_text text not null,
  confidence text check (confidence in ('low','medium','high')) default 'medium',
  evidence_state text check (evidence_state in ('REAL','PARTIAL','BLOCKED','PRETEND')) default 'PARTIAL',
  created_at timestamptz default now()
);

create table if not exists monetisation_events (
  id uuid primary key default gen_random_uuid(),
  study_id uuid references studies(id),
  participant_id uuid,
  recommendation_id uuid references research_recommendations(id),
  offer_code text,
  offer_name text,
  price_cents int,
  currency text default 'AUD',
  event_type text check (event_type in ('offer_shown','offer_clicked','checkout_started','payment_completed','payment_failed')),
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists research_execution_proofs (
  id uuid primary key default gen_random_uuid(),
  study_id uuid references studies(id),
  proof_type text check (proof_type in ('ingestion','atlas','recommendation','monetisation','report','ledger')),
  proof_payload jsonb not null,
  evidence_location text,
  classification text check (classification in ('REAL','PARTIAL','BLOCKED','PRETEND')) default 'PARTIAL',
  created_at timestamptz default now()
);
```

---

## 5. Mandatory Event Wiring

Bridge must wire every step to `system_events`.

Required event types:

| Event | Trigger | Required Payload |
|---|---|---|
| survey_submitted | Survey form submitted | study_id, participant_id, raw_answers |
| data_ingested | Data written to Supabase | study_id, participant_id, row_count |
| recommendation_ready | Recommendation generated | recommendation_id, participant_id, offer_candidate |
| monetisation_trigger | Offer shown or clicked | recommendation_id, offer_code, event_type |
| evidence_bound | Proof written | proof_type, classification, evidence_location |
| report_ready | Weekly or manual report generated | report_id, study_id, output_location |

Acceptance rule: no survey submission is valid unless it emits at least `survey_submitted`, `data_ingested`, and `recommendation_ready`.

---

## 6. Survey Completion Requirements

The current MVP survey is too thin. It must capture the full flagship study intent.

Minimum production survey sections:

1. participant context
2. neurotype
3. AI usage percentage
4. medication use
5. stimulant/non-stimulant category
6. perceived medication impact
7. task performance
8. cognitive load using simplified NASA-TLX style scoring
9. wellbeing / stress / sleep proxy
10. consent and recontact preference

Required variables:

```text
neurotype
ai_usage_pct
medication_use
medication_category
medication_frequency
performance_score
cognitive_load_score
focus_score
task_completion_score
overload_flag
wellbeing_score
consent_status
recontact_allowed
```

---

## 7. Recommendation Logic Completion

Current recommendation logic exists only as stateless code. Bridge must persist it.

Minimum rules:

| Condition | Recommendation | Offer |
|---|---|---|
| ADHD + AI >55% + overload | Reduce AI slightly and tune support | AI Optimisation Coaching |
| Neurotypical + AI >40% + lower performance | Reduce AI reliance and rebalance workflow | Cognitive Load Review |
| Dyslexia + AI <40% + low performance | Increase assistive AI layer | Reading Buddy / AI Support Plan |
| High performance + low overload | Maintain band and monitor | Monthly Optimisation Report |
| Org/domain email or workplace cohort | Aggregate enterprise dashboard | Enterprise API / Team Review |

Every recommendation must write to `research_recommendations` and emit `recommendation_ready`.

---

## 8. Monetisation Closure

Minimum monetisation proof does not require full Stripe checkout on day one, but it must log value intent.

Required flow:

```text
recommendation_ready → offer_shown → offer_clicked OR dismissed → monetisation_events row
```

Minimum offers:

| Offer Code | Offer | Price |
|---|---|---|
| OR_FREE_REPORT | Free personalised report | 0 |
| OR_OPTIMISE_9 | AI optimisation report | AUD 9 |
| OR_COACH_29 | AI optimisation coaching | AUD 29/month |
| OR_TEAM_999 | Team / enterprise insight pack | AUD 999+ |

Stripe can be added after proof, but the bridge should create payment-link-ready metadata now.

---

## 9. Evidence Binding

Every claim must bind to evidence.

Required chain:

```text
claim → source rows/query → result → proof record → evidence ledger classification
```

No finding can be marked REAL without:

1. stored dataset rows
2. reproducible SQL query
3. query result snapshot
4. proof record
5. evidence ledger entry

Minimum proof query:

```sql
select
  dp1.value as neurotype,
  case
    when dp2.value_numeric < 30 then 'Low'
    when dp2.value_numeric < 60 then 'Medium'
    else 'High'
  end as ai_band,
  count(distinct dp1.participant_id) as participants,
  avg(dp3.value_numeric) as avg_performance
from data_points dp1
join data_points dp2 on dp1.participant_id = dp2.participant_id
join data_points dp3 on dp1.participant_id = dp3.participant_id
where dp1.variable_name = 'neurotype'
  and dp2.variable_name = 'ai_usage_pct'
  and dp3.variable_name = 'performance_score'
group by 1,2;
```

---

## 10. Atlas Acceptance Criteria

The Atlas dashboard is accepted only when it shows:

- at least 10 submissions
- at least 2 neurotypes
- at least 2 AI bands
- performance score aggregation
- cognitive load aggregation
- evidence classification per segment
- drill-through to recommendation count
- monetisation events per segment

---

## 11. Bridge Execution Tasks

### Task A — Schema Hardening
Add missing production tables and indexes.

### Task B — Survey Expansion
Expand survey to capture medication, cognitive load, wellbeing, consent, and drop-off state.

### Task C — Event Wiring
Emit and process system events at every step.

### Task D — Recommendation Persistence
Persist recommendations and connect them to participant records.

### Task E — Monetisation Event Capture
Create offer display/click logging and Stripe-ready payloads.

### Task F — Evidence Auto-Binding
Write proof records automatically from queries and downgrade claims without proof.

### Task G — Atlas Upgrade
Add cognition, medication, overload, evidence, and monetisation dimensions.

### Task H — Smoke Test
Seed or submit 10 entries, run Atlas query, create recommendation, emit offer, write proof.

---

## 12. Definition of Done

This work is done only when the bridge can produce this ledger:

| Layer | Minimum Proof | Status Required |
|---|---|---|
| Study | study row exists | REAL |
| Survey | 10 submissions | REAL |
| Ingestion | data_points rows written | REAL |
| Events | event chain created | REAL |
| Atlas | non-empty segmented result | REAL |
| Recommendations | persisted rows | REAL |
| Monetisation | offer event rows | PARTIAL or REAL |
| Evidence | execution proof rows | REAL |
| Revenue | payment link or checkout event | PARTIAL until paid |

---

## 13. Reality Ledger Record

Create or update equivalent operational ledger record:

```json
{
  "task_id": "RPT_ResearchEngine_StrategyBridgeHandoff_ADHD-AI-Drug_20260501",
  "intent": "Convert research best-practice template and flagship ADHD x AI x Drug study into executable bridge package",
  "execution": "GitHub handoff created; bridge execution required for runtime completion",
  "output": "handoffs/RPT_ResearchEngine_StrategyBridgeHandoff_ADHD-AI-Drug_20260501.md",
  "status": "PARTIAL",
  "evidence": "GitHub file receipt required from connector response",
  "gaps": [
    "event wiring not yet executed",
    "recommendation persistence not yet executed",
    "monetisation event capture not yet executed",
    "evidence auto-binding not yet executed",
    "runtime proof not yet generated"
  ],
  "next_action": "Bridge executes Tasks A-H and returns commit/runtime receipts",
  "elevation": "This is the canonical research engine completion package for Outcome Ready, AI Sweet Spots, Reading Buddy and Drug Resilience Atlas",
  "pressure_flags": ["no_simulated_completion", "runtime_required", "evidence_required"],
  "score": 0.74
}
```

---

## 14. Final Classification

**Status:** PARTIAL  
**Reason:** Strategy package complete and handed to GitHub; runtime execution still required before REAL.  
**Bridge instruction:** Execute Tasks A-H without redesign. Return receipts for schema migration, smoke test, Atlas output, recommendation row, monetisation event, and evidence ledger entry.
