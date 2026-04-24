-- AM Base Schema

create table if not exists am_place (
  id uuid primary key default gen_random_uuid(),
  name text,
  type text,
  lat double precision,
  lng double precision,
  created_at timestamptz default now()
);

create table if not exists am_memory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  title text,
  body text,
  visibility text default 'private',
  created_at timestamptz default now()
);

create table if not exists am_memory_place (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid,
  place_id uuid,
  created_at timestamptz default now()
);

create table if not exists am_event_log (
  id uuid primary key default gen_random_uuid(),
  event text,
  payload jsonb,
  created_at timestamptz default now()
);