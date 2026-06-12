-- Signal provenance v1
-- Parent: #170
-- Issue: #172
-- Status: draft migration artifact

alter table synal.signal
  add column if not exists parent_signal_id uuid null,
  add column if not exists cause_id uuid null,
  add column if not exists group_id uuid null,
  add column if not exists decision_id uuid null,
  add column if not exists journey_id uuid null,
  add column if not exists evidence_ref text null,
  add column if not exists recovery_ref text null;

create index if not exists idx_synal_signal_parent_signal_id
  on synal.signal(parent_signal_id);

create index if not exists idx_synal_signal_cause_id
  on synal.signal(cause_id);

create index if not exists idx_synal_signal_group_id
  on synal.signal(group_id);

create index if not exists idx_synal_signal_decision_id
  on synal.signal(decision_id);

create index if not exists idx_synal_signal_journey_id
  on synal.signal(journey_id);

create or replace view synal.v_signal_lineage as
select
  s.id,
  s.signal_type,
  s.severity,
  s.status,
  s.agent_id,
  s.parent_signal_id,
  s.cause_id,
  s.group_id,
  s.decision_id,
  s.journey_id,
  s.evidence_ref,
  s.recovery_ref,
  s.created_at
from synal.signal s;
