-- cip/schema/cip_v2_hitl.sql
-- CTO in Your Pocket — HITL gating migration v2
-- Target: Supabase S1 (lzfgigiyqpuuxslsygjt)
-- Applied: 2026-05-11
-- Doctrine update (memory edit #1 CIP EXCEPTION):
--   - Default asset mode = HITL until Troy explicitly flips an asset to AUTONOMOUS.
--   - Remediations cannot fire until cip.approvals.status='approved'.
--   - NO new Lambdas for CIP without explicit per-deploy approval.
-- Reuse: idempotent. Re-run safely.

-- 1. Per-asset mode (HITL is the default for safety)
alter table cip.assets
  add column if not exists mode text not null default 'HITL'
  check (mode in ('HITL','AUTONOMOUS','OBSERVE'));

-- 2. Per-incident pause marker (which gate is open)
alter table cip.incidents
  add column if not exists awaiting_gate text
  check (awaiting_gate in ('remediate','validate','escalate','close'));

-- 3. Approvals table — the gate itself
create table if not exists cip.approvals (
  id              uuid primary key default gen_random_uuid(),
  incident_id     uuid not null references cip.incidents(id),
  gate            text not null check (gate in ('remediate','validate','escalate','close')),
  status          text not null default 'pending'
                    check (status in ('pending','approved','denied','expired')),
  proposed_action jsonb not null,
  requested_at    timestamptz not null default now(),
  decided_at      timestamptz,
  decided_by      text,
  rationale       text
);

-- 4. Operator view — one query shows every open gate across the portfolio
create or replace view cip.v_pending_gates as
select
  ap.id              as approval_id,
  ap.gate,
  ap.requested_at,
  i.id               as incident_id,
  i.severity,
  i.detected_http_status,
  a.id               as asset_id,
  a.name             as asset_name,
  a.url              as asset_url,
  a.fallback_url,
  a.mode             as asset_mode,
  a.criticality,
  ap.proposed_action
from cip.approvals ap
join cip.incidents i on i.id = ap.incident_id
join cip.assets    a on a.id = i.asset_id
where ap.status = 'pending'
order by ap.requested_at desc;

-- 5. Approve function — sign-off only, does NOT trigger remediation itself.
--    The runner polls for status='approved' and acts on it. Sign and act are
--    deliberately separate to keep the audit trail clean.
create or replace function cip.fn_approve(
  p_approval_id uuid,
  p_decided_by  text default 'troy',
  p_rationale   text default null
)
returns jsonb language plpgsql as $body$
declare r jsonb;
begin
  update cip.approvals
     set status='approved', decided_at=now(),
         decided_by=p_decided_by, rationale=p_rationale
   where id=p_approval_id and status='pending';
  if not found then
    return jsonb_build_object(
      'ok', false, 'reason','not_pending_or_missing',
      'approval_id', p_approval_id
    );
  end if;
  select jsonb_build_object(
    'ok', true,
    'approval_id', a.id,
    'incident_id', a.incident_id,
    'gate', a.gate,
    'decided_by', a.decided_by,
    'decided_at', a.decided_at,
    'proposed_action', a.proposed_action
  ) into r from cip.approvals a where a.id=p_approval_id;
  return r;
end $body$;

-- 6. Deny function — closes the incident and records the reason.
create or replace function cip.fn_deny(
  p_approval_id uuid,
  p_decided_by  text default 'troy',
  p_rationale   text default null
)
returns jsonb language plpgsql as $body$
begin
  update cip.approvals
     set status='denied', decided_at=now(),
         decided_by=p_decided_by, rationale=p_rationale
   where id=p_approval_id and status='pending';
  if not found then
    return jsonb_build_object(
      'ok', false, 'reason','not_pending_or_missing',
      'approval_id', p_approval_id
    );
  end if;
  update cip.incidents
     set status='closed', awaiting_gate=null,
         notes=coalesce(notes,'')
               || ' | DENIED by ' || p_decided_by
               || ': ' || coalesce(p_rationale,'(no reason)')
   where id=(select incident_id from cip.approvals where id=p_approval_id);
  return jsonb_build_object('ok', true, 'approval_id', p_approval_id, 'status','denied');
end $body$;

-- Usage:
--   select * from cip.v_pending_gates;
--   select cip.fn_approve('<approval_id>'::uuid, 'troy', 'reason');
--   select cip.fn_deny   ('<approval_id>'::uuid, 'troy', 'reason');
