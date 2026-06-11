-- Payroll + Travel + Outlook + MYOB schema
-- status: PARTIAL
-- created_date: 2026-06-12
-- safety: no raw credit-card storage; tokenised references only

create schema if not exists payroll_travel;

create table if not exists payroll_travel.employees (
  employee_id text primary key,
  name text not null,
  email text not null unique,
  outlook_user_id text,
  myob_employee_id text,
  manager_id text references payroll_travel.employees(employee_id),
  default_cost_centre text,
  role text,
  employment_status text not null default 'active' check (employment_status in ('active','inactive','on_leave','terminated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists payroll_travel.trips (
  trip_id text primary key,
  employee_id text not null references payroll_travel.employees(employee_id),
  business_reason text not null,
  destination text not null,
  start_date date not null,
  end_date date not null,
  approval_status text not null default 'draft' check (approval_status in ('draft','submitted','approved','rejected','cancelled','exception_required')),
  approver_id text references payroll_travel.employees(employee_id),
  cost_centre text,
  project_code text,
  policy_profile text,
  myob_export_status text not null default 'not_ready' check (myob_export_status in ('not_ready','ready_for_export','exported','accepted_by_myob','rejected_by_myob','reconciled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists payroll_travel.flight_segments (
  segment_id text primary key,
  trip_id text not null references payroll_travel.trips(trip_id),
  airline text,
  flight_number text,
  depart_at timestamptz not null,
  arrive_at timestamptz not null,
  origin text not null,
  destination text not null,
  booking_reference text,
  outlook_event_id text,
  created_at timestamptz not null default now()
);

create table if not exists payroll_travel.hotel_options (
  hotel_id text primary key,
  trip_id text not null references payroll_travel.trips(trip_id),
  name text not null,
  address text,
  nightly_rate numeric(12,2) not null,
  currency text not null default 'AUD',
  distance_to_site_km numeric(8,2),
  cancellation_policy text,
  policy_status text not null check (policy_status in ('approved','needs_manager_approval','needs_finance_approval','blocked','exception_required')),
  created_at timestamptz not null default now()
);

create table if not exists payroll_travel.hotel_bookings (
  booking_id text primary key,
  trip_id text not null references payroll_travel.trips(trip_id),
  hotel_id text not null references payroll_travel.hotel_options(hotel_id),
  check_in date not null,
  check_out date not null,
  amount numeric(12,2) not null,
  currency text not null default 'AUD',
  payment_status text not null default 'pending' check (payment_status in ('pending','authorised','captured','refunded','failed')),
  payment_reference text,
  outlook_event_id text,
  created_at timestamptz not null default now()
);

create table if not exists payroll_travel.payment_methods (
  payment_method_id text primary key,
  owner_type text not null check (owner_type in ('employee','corporate_entity')),
  owner_id text not null,
  provider text not null,
  provider_token text not null,
  card_brand text,
  last_four char(4),
  expiry_month int check (expiry_month between 1 and 12),
  expiry_year int,
  status text not null default 'active' check (status in ('active','inactive','expired','revoked')),
  authority_reference text,
  created_by text,
  created_at timestamptz not null default now(),
  constraint no_raw_card_like_token check (length(provider_token) < 256)
);

comment on table payroll_travel.payment_methods is 'Tokenised payment metadata only. Never store PAN, CVV, PIN, or magnetic stripe data.';

create table if not exists payroll_travel.payment_events (
  payment_event_id text primary key,
  payment_method_id text references payroll_travel.payment_methods(payment_method_id),
  trip_id text references payroll_travel.trips(trip_id),
  booking_id text references payroll_travel.hotel_bookings(booking_id),
  amount numeric(12,2) not null,
  currency text not null default 'AUD',
  event_type text not null check (event_type in ('intent','authorisation','capture','refund','failure')),
  provider_reference text,
  created_at timestamptz not null default now(),
  created_by text
);

create table if not exists payroll_travel.expense_claims (
  claim_id text primary key,
  trip_id text not null references payroll_travel.trips(trip_id),
  employee_id text not null references payroll_travel.employees(employee_id),
  amount numeric(12,2) not null,
  currency text not null default 'AUD',
  receipt_reference text,
  approval_status text not null default 'draft' check (approval_status in ('draft','submitted','approved','rejected','paid')),
  myob_export_reference text,
  created_at timestamptz not null default now()
);

create table if not exists payroll_travel.audit_ledger (
  ledger_id text primary key,
  event_type text not null,
  actor_id text,
  subject_type text not null,
  subject_id text not null,
  before_hash text,
  after_hash text,
  timestamp timestamptz not null default now(),
  source_system text not null check (source_system in ('outlook','myob','payment_provider','travel_provider','admin_portal','system')),
  receipt_reference text
);

create or replace function payroll_travel.prevent_unapproved_myob_export()
returns trigger as $$
begin
  if new.myob_export_reference is not null and new.approval_status <> 'approved' then
    raise exception 'MYOB export blocked: expense claim must be approved first';
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_unapproved_myob_export on payroll_travel.expense_claims;
create trigger trg_prevent_unapproved_myob_export
before insert or update on payroll_travel.expense_claims
for each row execute function payroll_travel.prevent_unapproved_myob_export();
