-- LinkedIn Intelligence Schema

create table if not exists linkedin_content (
  id uuid primary key default gen_random_uuid(),
  content_type text,
  text_content text,
  created_at timestamptz,
  source_url text,
  engagement_score int,
  raw_json jsonb
);

create table if not exists linkedin_themes (
  id uuid primary key default gen_random_uuid(),
  theme text,
  subtheme text,
  volume int,
  engagement_score int,
  maturity text
);

create table if not exists linkedin_articles (
  id uuid primary key default gen_random_uuid(),
  title text,
  created_at timestamptz,
  source_url text,
  theme text,
  summary text,
  key_insights jsonb
);

create table if not exists linkedin_books (
  id uuid primary key default gen_random_uuid(),
  theme text,
  title text,
  chapters jsonb,
  readiness_score int
);

create table if not exists linkedin_actions (
  id uuid primary key default gen_random_uuid(),
  idea text,
  source_ref text,
  status text,
  priority int
);

create table if not exists linkedin_business_map (
  id uuid primary key default gen_random_uuid(),
  content_id uuid,
  mapped_business text,
  opportunity_type text
);

create table if not exists linkedin_predictions (
  id uuid primary key default gen_random_uuid(),
  prediction text,
  created_at timestamptz,
  status text,
  accuracy_score int
);

create table if not exists linkedin_connections (
  id uuid primary key default gen_random_uuid(),
  name text,
  role text,
  company text,
  cluster text,
  value_score int
);

-- Reality Ledger binding
create table if not exists linkedin_audit_runs (
  id uuid primary key default gen_random_uuid(),
  run_date timestamptz default now(),
  input_s3_path text,
  output_s3_path text,
  classification text,
  evidence jsonb
);
