# When to AI — Bridge Completion Handoff

Status: PARTIAL — executable handoff lodged, runtime execution still requires Bridge/API/Vercel/Supabase access.

Source audit: user-provided forensic audit for `whentoai.aisweetspots.com` / AI Sweet Spots, May 2026.

## Intent
Complete the When to AI product from strong static/research prototype to live evidence-producing product.

## Current finding
The app is structurally close to production but is not truly live because persistence and email capture are broken:

- `/api/bridge` returns 404, so session logging and contact send fail.
- `/api/subscribe` returns 404, so email capture appears successful but is not stored.
- All displayed data is synthetic: 5,550 simulated sessions, 200 virtual participants, seed 42.
- Persistent SIMULATED banner is truthful and must remain until real persistence is proven.
- Contact form has a likely state binding defect: JS reads `S.ct_email`, while field ID is `f-email`.
- `evidence_source` is hardcoded to `REAL_USER`, which contaminates test/prod data.

## Required build

### P0 — Production blockers
1. Recreate `/api/bridge` route.
2. Wire bridge to existing Lambda executor path for:
   - `troy-sql-executor`
   - `troy-email-send`
3. Recreate `/api/subscribe` route.
4. Fix contact form email binding.
5. Add test/prod evidence flag: `EVIDENCE_SOURCE=TEST|REAL_USER`.
6. Add sanitised insert contract for `ass_time.task_session` and `ass_time.next_day_check`.
7. Verify T4H lead widget and checkout widget.
8. Keep SIMULATED banner until smoke tests prove real data.

### P1 — Data completeness
1. Capture UTM params.
2. Add role and industry fields to email gate.
3. Capture session duration.
4. Add page/event log table.
5. Add session counter: Day X of 14.
6. Store every submitted field and event.

### P2 — Value loop
1. Gate email confirmation.
2. Day 7 progress email.
3. Day 14 playbook unlock.
4. Data-driven personal playbook after 14 sessions.
5. Evidence maturity tracker: SIMULATED → WITHIN_PERSON → SMALL_GROUP → REPLICATED.
6. Team invite CTA and Team/School upsell.

## Schema delta

```sql
create schema if not exists ass_time;

create table if not exists ass_time.page_event (
  id bigserial primary key,
  user_id_hash text,
  event_type text not null,
  event_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table ass_time.task_session
  add column if not exists utm_source text,
  add column if not exists utm_medium text,
  add column if not exists utm_campaign text,
  add column if not exists role_segment text,
  add column if not exists industry_segment text,
  add column if not exists session_duration_seconds integer,
  add column if not exists evidence_env text default 'TEST';
```

## Smoke tests required for REAL

- `GET /api/bridge/health` or equivalent returns 200.
- Test insert reaches `ass_time.task_session`.
- Test insert reaches `ass_time.next_day_check`.
- `/api/subscribe` stores email and source metadata.
- Contact form delivers to `troy@workfamilyai.org` or configured inbox.
- T4H lead widget submits and creates CRM/DB record.
- Shop widget loads at least one live Stripe SKU.
- Evidence source records TEST in non-prod and REAL_USER only after launch.
- SQL injection test is rejected or safely parameterised.

## Bridge payload

```json
{
  "action": "complete_whentoai_prod_wiring",
  "source": "chatgpt",
  "target_system": "bridge",
  "product": "When to AI",
  "domain": "whentoai.aisweetspots.com",
  "repo_hint": "locate Vercel/Lovable/SPA source for whentoai or rhythmmethod",
  "required_runtime": ["Vercel", "Supabase", "AWS Lambda", "Stripe", "T4H lead API"],
  "tasks": [
    "restore /api/bridge",
    "restore /api/subscribe",
    "fix contact email binding",
    "add schema delta",
    "add UTM role industry duration capture",
    "add smoke tests",
    "run tests",
    "return receipts"
  ],
  "completion_gate": "REAL only when smoke tests produce typed evidence and receipts"
}
```

## Reality Ledger

| Field | Value |
|---|---|
| task_id | whentoai-bridge-completion-2026-05-11 |
| intent | Build and pass When to AI completion package to Bridge/Pen |
| execution | GitHub handoff created in canonical Pen repo |
| output | `handoffs/2026-05-11-whentoai-bridge-completion/00_bridge-handoff.md` |
| status | PARTIAL |
| evidence | GitHub commit receipt from create_file |
| gaps | Bridge runtime not exposed here; Vercel/Supabase/AWS/Stripe smoke tests not executed here |
| next_action | Bridge/dev runtime must execute payload and return receipts |
| elevation | Converts forensic audit into executable build order with proof gates |
| pressure_flags | stagnation=false; drag=false; regression=false |
| score | 0.78 |
```
