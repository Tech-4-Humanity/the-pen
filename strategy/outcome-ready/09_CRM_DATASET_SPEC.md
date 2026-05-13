# 09 — CRM & Dataset Specification

## Goal

One unified contact/activity dataset across both brands. Same backend (Supabase S1, `lzfgigiyqpuuxslsygjt`). Brand-aware fields. Agent-readable. Audit-friendly.

This deprecates the ad-hoc CSV approach used to date — that was a useful seed, not a system.

## Schema (Supabase)

### `outcome.contact`

```sql
create table if not exists outcome.contact (
  id uuid primary key default gen_random_uuid(),
  brand text check (brand in ('biz','kids','both')) not null,
  entity_type text check (entity_type in ('parent','practitioner','provider','school','partner','government','other')) not null,
  name text,
  organisation text,
  email text,
  phone text,
  location text,
  state text,
  country text default 'AU',
  role text,
  segment text,
  channel_preference text,
  source text,
  consent_marketing boolean default false,
  consent_marketing_at timestamptz,
  consent_data_processing boolean default false,
  consent_data_processing_at timestamptz,
  ndis_status text,
  thriving_kids_relevance text,
  thriving_biz_relevance text,
  risk_level text check (risk_level in ('low','medium','high','critical','unknown')) default 'unknown',
  priority_score int check (priority_score between 0 and 10),
  notes text,
  owner text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### `outcome.activity`

```sql
create table if not exists outcome.activity (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references outcome.contact(id) on delete cascade,
  brand text check (brand in ('biz','kids','both')) not null,
  campaign_name text,
  product_skn text,
  message_angle text,
  channel text,
  direction text check (direction in ('outbound','inbound','passive')) not null,
  contact_status text check (contact_status in ('new','contacted','engaged','assessment_sent','assessment_completed','offer_made','converted','lost','unsubscribed')),
  last_contacted timestamptz default now(),
  next_action text,
  next_action_due timestamptz,
  owner text,
  notes text,
  evidence_ref text,
  created_at timestamptz default now()
);
```

### `outcome.outcome_event`

```sql
create table if not exists outcome.outcome_event (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references outcome.contact(id) on delete cascade,
  brand text check (brand in ('biz','kids','both')) not null,
  outcome_type text,
  product_skn text,
  revenue_aud numeric,
  recurring boolean default false,
  conversion_stage text,
  reality_status text check (reality_status in ('REAL','PARTIAL','BLOCKED')) default 'REAL',
  evidence text,
  created_at timestamptz default now()
);
```

### `outcome.campaign`

```sql
create table if not exists outcome.campaign (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  brand text check (brand in ('biz','kids','both')) not null,
  window_label text,
  starts_at timestamptz,
  ends_at timestamptz,
  spotlight_skn text,
  content_theme text,
  conversion_goal text,
  target_segment text,
  target_count int,
  actual_count int default 0,
  notes text,
  created_at timestamptz default now()
);
```

### `outcome.consent_link`

```sql
create table if not exists outcome.consent_link (
  id uuid primary key default gen_random_uuid(),
  contact_id uuid references outcome.contact(id) on delete cascade,
  brand text check (brand in ('biz','kids','both')) not null,
  purpose text not null,
  granted boolean default false,
  granted_at timestamptz,
  revoked_at timestamptz,
  evidence text,
  created_at timestamptz default now()
);
```

## Pipeline States

```
new → contacted → engaged → assessment_sent → assessment_completed → offer_made → converted → expansion → retention
(off-path: lost, unsubscribed)
```

## Segments (Pre-Defined)

| Segment | Brand | Definition |
|---------|-------|-----------|
| `biz_sil_provider` | biz | SIL provider under July registration mandate |
| `biz_platform_provider` | biz | Platform provider under July registration mandate |
| `biz_sole_practitioner` | biz | Therapist / allied health solo |
| `biz_mid_market_provider` | biz | Multi-staff therapy clinic |
| `biz_accountant_channel` | biz | Accountant resell partner |
| `kids_parent_high_risk` | kids | Parent reporting plan reduction |
| `kids_parent_general` | kids | Parent in affected cohort but not yet impacted |
| `kids_practitioner` | kids | Therapist working with kids |
| `kids_provider` | kids | Provider transitioning to Foundational Supports |
| `kids_school_pilot` | kids | School in pilot discussions |
| `kids_school_active` | kids | School with active licence |
| `kids_2e_parent` | kids | Parent of twice-exceptional child |

## Reality Ledger Integration

Every conversion event must also write to `public.reality_ledger`:

```sql
insert into public.reality_ledger (entity, status, evidence)
values ('outcome.outcome_event:<id>', 'REAL', '<stripe invoice id>');
```

## Operating Rules

1. **Every outreach is an `outcome.activity` row.** No untracked touches.
2. **Every conversion is an `outcome.outcome_event` row + reality_ledger row.** Pair always.
3. **Every consent is a `outcome.consent_link` row.** Default to deny.
4. **Brand isolation enforced at query layer.** Never send a Kids campaign to Biz-only contacts.
5. **No PII in agent training or model fine-tuning.**

## Open Questions For Troy

- [ ] Confirm Supabase schema name (`outcome` vs nested under existing schema)
- [ ] Confirm linkage to existing `core.registry_entities` for org-level contacts
- [ ] Confirm Stripe webhook handler writes directly into `outcome_event` + `reality_ledger`
- [ ] Confirm ConsentX `consentx.*` tables are the canonical consent source, with `outcome.consent_link` as the shim
