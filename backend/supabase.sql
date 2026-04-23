create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  business text,
  offer text,
  name text,
  email text,
  organisation text,
  payload jsonb,
  status text default 'new',
  created_at timestamptz default now()
);