# Session Preflight Checklist

Status: ACTIVE
Owner: The Pen
Companion: `SESSION_REQUIREMENTS.md` §3.1 + `HOUSE_RULES_INTEGRATION.md` Session-Start
Trigger: every onboarded machine session, no exceptions

## The 60-Second Preflight

Run all four steps before any other action. Output of each step is mandatory ledger metadata.

### Step 1 — Pin the bridge
```bash
python3 -c "import socket; H='zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com'; f=open('/etc/hosts'); t=f.read(); f.close(); H in t or open('/etc/hosts','a').write(socket.gethostbyname(H)+' '+H+'\n'); print('bridge pinned')"
```
Failure → BLOCKED with bounded reason: bridge DNS unresolvable.

### Step 2 — Surface open blocks
```sql
SELECT id, system, component, last_verified
FROM public.reality_ledger
WHERE status = 'BLOCKED'
  AND last_verified > now() - interval '14 days'
ORDER BY last_verified DESC;
```
Any returned row must be acknowledged in the session log before proceeding.

### Step 3 — Verify canonical runtime objects exist
```sql
SELECT
  to_regclass('public.reality_ledger')::text              AS l4_ledger,
  to_regclass('ops.v_standard_knowledge_active')::text    AS l3_sks_view,
  to_regclass('public.t4h_business_registry')::text       AS portfolio,
  to_regclass('public.cap_secrets')::text                 AS credentials,
  to_regclass('core.cluster_registry')::text              AS clusters;
```
Any NULL → load `canonical/doctrine/TRAPS.md` and escalate before continuing.

### Step 4 — Confirm HRE active
Read first 200 chars of `machine-onboarding/HOUSE_RULES_INTEGRATION.md`. If file unreachable, the session has lost L1 binding — session is BLOCKED.

## Mandatory Ledger Fields From Preflight

Every session ledger row evidence jsonb must include:

```yaml
preflight:
  bridge_pinned: true | false
  open_blocks_count: <int>
  open_blocks_acknowledged: [<ledger_id>, ...]
  l3_sks_view_present: true | false
  l4_ledger_present: true | false
  l1_hre_loaded: true | false
  cluster_registry_present: true | false
  ran_at: <ISO timestamp>
```

## Failure Modes

| Symptom | Meaning | Action |
|---------|---------|--------|
| `bridge pinned` not in stdout | DNS not pinned | Re-run Step 1; if still fails → BLOCKED |
| Step 2 returns rows but you ignore them | HRE writeback violation | Stop, acknowledge, log |
| Step 3 returns any NULL | runtime drift | TRAPS lookup + escalate |
| Step 4 file unreachable | repo/auth break | BLOCKED — surface dependency |

## Reuse

This preflight is one of the reusable primitives — see `canonical/atomic-elements/preflight_check.yaml` (planned). Every machine running against any T4H system uses the same four steps. Drift here = drift everywhere.
