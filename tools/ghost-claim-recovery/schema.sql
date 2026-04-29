-- Ghost Claim Recovery Register

create table if not exists public.bridge_claim_recovery (
  id uuid primary key default gen_random_uuid(),

  -- Source / identity
  origin text,
  source_chat_title text,
  source_thread_key text,
  claim_phrase text,
  claimed_destination text,
  intended_destination text,

  -- Current location
  current_repo text,
  current_commit_sha text,
  current_path text,
  discovered_at timestamptz default now(),

  -- Classification
  status text,
  topic_slug text,
  agent_source text,
  idempotency_key text,

  -- Recovery decision
  recovery_mode text,
  rehome_target text,
  replay_safe boolean default false,

  -- Evidence
  evidence_state text,
  handoff_receipt_path text,
  runtime_receipt_path text,

  -- Lifecycle
  last_checked timestamptz default now(),
  recovered boolean default false,
  notes text
);

create index if not exists idx_bridge_claim_topic on public.bridge_claim_recovery(topic_slug);
create index if not exists idx_bridge_claim_status on public.bridge_claim_recovery(status);
create index if not exists idx_bridge_claim_repo_path on public.bridge_claim_recovery(current_repo, current_path);
