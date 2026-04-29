# Signal Architecture: Non-Breaking Naming, Unknowns, and Future Signal Space

## Purpose
This package locks the architecture without locking the names.

The system must support MyNeuralSignal, shared/group/system signals, LinkedIn-derived signals, environmental signals, agent signals, and future neural-technology interactions that are not yet understood.

Names are labels. The schema is the durable truth.

---

## 1. Naming Rule

Do not hardwire names such as StrategicSignal, NetworkSignal, IntentSignal, DominoSignal, OurSignal, or AllSignal into code, schemas, routing, dashboards, or execution logic.

All signal names must be:
- metadata-driven
- renameable
- versioned
- deactivatable
- replaceable without data loss

Approved principle:

> Names are metadata. Structure is truth.

---

## 2. Three-Part Naming Pattern

Where labels are used, treat them as optional display names with this general pattern:

```text
[scope/display owner] + [qualifier] + Signal
```

Examples only, not permanent names:
- MyNeuralSignal
- SharedSomethingSignal
- CollectiveSomethingSignal
- SystemSomethingSignal
- EnvironmentSomethingSignal

The second word remains open. Do not force final naming now.

---

## 3. Core Signal Object

Every signal should be represented with stable fields, not hardcoded names.

```json
{
  "signal_id": "uuid",
  "display_name": "renameable label",
  "scope": "personal | shared | group | organisation | system | environment | global | unknown",
  "qualifier": "renameable qualifier",
  "source": "linkedin | sensor | agent | document | environment | human | external | unknown",
  "signal_class": "content | network | intent | biological | environmental | operational | emergent | unknown",
  "processing_mode": "observe | explore | classify | act | block",
  "confidence": 0.0,
  "novelty_score": 0.0,
  "leverage_score": 0.0,
  "cascade_potential": 0.0,
  "evidence_refs": [],
  "consent_state": "none | session | explicit | inherited | blocked | unknown",
  "action_refs": [],
  "version": "1.0",
  "active": true
}
```

---

## 4. Unknown Unknowns

The architecture must preserve space for signals that do not yet fit existing categories.

Unknown or emerging signals must not be forced into current labels.

Handling modes:
- observe: store and monitor only
- explore: compare against known patterns
- classify: map only when evidence supports it
- act: only when authority and confidence thresholds are met
- block: prevent unsafe or unauthorised action

Required emergent handling fields:
- novelty_score
- recurrence_count
- nearest_known_cluster
- reason_unclassified
- review_required
- evidence_refs

---

## 5. Domino Clarification

Domino is not a signal category and should not be treated as a fixed name.

Domino is a property of a signal or action:

```text
How far does this propagate if acted on?
```

Durable fields:
- leverage_score
- cascade_potential
- dependency_graph
- expected_downstream_effects
- rollback_path
- proof_requirement

The word Domino may be used as a display label, but the durable schema should use leverage and cascade fields.

---

## 6. LinkedIn Intelligence Fit

LinkedIn data remains three assets:
- Network: people, relationships, companies, clusters
- Content: articles, posts, topics, formats, engagement
- Intent: comments, messages, asks, offers, opportunities

These become signal sources, not fixed product names.

The LinkedIn engine should emit signals into the generic signal schema, then map to projects, businesses, actions, evidence, and dashboards.

---

## 7. Integrity Stack Alignment

This architecture must remain compatible with:
- Universal Biological Integrity
- MyNeuralSignal
- ID Exchange
- ConsentX
- NEUROPAK
- Tech 4 Humanity
- GCBAT

MyNeuralSignal remains the personal real-time signal integrity engine.

Shared, collective, organisational, system, environmental, or global signal layers remain movable and renameable until proven by product, governance, and usage.

---

## 8. Supabase Tables Required

Recommended tables:

```sql
create table if not exists signal_registry (
  id uuid primary key default gen_random_uuid(),
  display_name text,
  scope text,
  qualifier text,
  source text,
  signal_class text,
  processing_mode text default 'observe',
  confidence numeric default 0,
  novelty_score numeric default 0,
  leverage_score numeric default 0,
  cascade_potential numeric default 0,
  consent_state text default 'unknown',
  evidence_refs jsonb default '[]'::jsonb,
  action_refs jsonb default '[]'::jsonb,
  version text default '1.0',
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists signal_label_history (
  id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(id),
  old_display_name text,
  new_display_name text,
  reason text,
  changed_at timestamptz default now()
);

create table if not exists signal_unknowns (
  id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(id),
  reason_unclassified text,
  nearest_known_cluster text,
  recurrence_count int default 1,
  review_required boolean default true,
  created_at timestamptz default now()
);
```

---

## 9. Execution Rules

1. Never hardcode uncertain names.
2. Never collapse unknown signals into known categories without evidence.
3. Treat Domino as leverage/cascade metadata, not a signal type.
4. Treat StrategicSignal, NetworkSignal, IntentSignal and similar names as display labels only.
5. Preserve unknown unknowns as first-class records.
6. Bind every action to evidence and consent state.
7. Keep all labels renameable without destructive migration.

---

## 10. Reality Status

Classification: PARTIAL / ARCHITECTURE LOCKED

Reason:
- This file locks the non-breaking architecture and naming doctrine.
- It is not REAL until schema is applied, data is loaded, and proof entries are written through the Reality Ledger.

Next proof path:
1. Apply schema.
2. Emit first LinkedIn-derived signal rows.
3. Rename one label without data loss.
4. Store one unknown signal as observe/explore.
5. Generate one leverage/cascade score.
6. Write Reality Ledger evidence.
