-- Agora Intelligence Platform Supabase schema v0.1
-- Status: PARTIAL. Requires execution receipt in target Supabase project.

create extension if not exists vector;

create table if not exists agora_tenants (
  tenant_id uuid primary key default gen_random_uuid(),
  display_name text not null,
  tenant_type text not null default 'standard',
  region text not null default 'au',
  data_residency text not null default 'au',
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_identities (
  identity_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  display_name text,
  verified_email text,
  role_set jsonb not null default '[]'::jsonb,
  wallet_id uuid,
  consent_state text not null default 'unknown',
  status text not null default 'invited',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_media_assets (
  media_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  owner_identity_id uuid references agora_identities(identity_id),
  title text not null,
  media_type text not null,
  source_uri text,
  s3_uri text,
  ipfs_cid text,
  checksum_sha256 text,
  duration_seconds numeric,
  visibility text not null default 'private',
  moderation_state text not null default 'pending',
  status text not null default 'uploaded',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_transcripts (
  transcript_id uuid primary key default gen_random_uuid(),
  media_id uuid not null references agora_media_assets(media_id),
  tenant_id uuid not null references agora_tenants(tenant_id),
  provider text not null default 'whisper',
  model text,
  language text,
  confidence numeric,
  full_text text,
  segments jsonb not null default '[]'::jsonb,
  status text not null default 'generated',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_comments (
  comment_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  media_id uuid references agora_media_assets(media_id),
  source_platform text,
  author_handle_hash text,
  parent_comment_id uuid references agora_comments(comment_id),
  raw_text text not null,
  normalised_text text,
  source_timestamp timestamptz,
  status text not null default 'imported',
  created_at timestamptz not null default now()
);

create table if not exists agora_entities (
  entity_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  canonical_name text not null,
  aliases jsonb not null default '[]'::jsonb,
  entity_type text not null default 'concept',
  confidence numeric,
  source_refs jsonb not null default '[]'::jsonb,
  status text not null default 'candidate',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_relationships (
  relationship_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  source_entity_id uuid not null references agora_entities(entity_id),
  target_entity_id uuid not null references agora_entities(entity_id),
  relationship_type text not null,
  claim_text text,
  polarity text,
  confidence numeric,
  evidence_refs jsonb not null default '[]'::jsonb,
  status text not null default 'candidate',
  created_at timestamptz not null default now()
);

create table if not exists agora_embeddings (
  embedding_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  object_type text not null,
  object_id uuid not null,
  content text not null,
  embedding vector(1536),
  provider text,
  model text,
  created_at timestamptz not null default now()
);

create table if not exists agora_communities (
  community_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  label text not null,
  summary text,
  member_refs jsonb not null default '[]'::jsonb,
  dominant_topics jsonb not null default '[]'::jsonb,
  confidence numeric,
  status text not null default 'detected',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_narratives (
  narrative_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  title text not null,
  summary text,
  stance_distribution jsonb not null default '{}'::jsonb,
  trajectory text,
  first_seen timestamptz,
  last_seen timestamptz,
  status text not null default 'detected',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_debates (
  debate_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  topic text not null,
  personas jsonb not null default '[]'::jsonb,
  rounds jsonb not null default '[]'::jsonb,
  citations jsonb not null default '[]'::jsonb,
  output_summary text,
  status text not null default 'requested',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_evidence_packs (
  evidence_pack_id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references agora_tenants(tenant_id),
  scope text not null,
  artefact_refs jsonb not null default '[]'::jsonb,
  checksum_sha256 text,
  export_format text not null default 'json',
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists agora_receipts (
  receipt_id uuid primary key default gen_random_uuid(),
  tenant_id uuid references agora_tenants(tenant_id),
  actor_id uuid,
  action text not null,
  object_type text not null,
  object_id text not null,
  status text not null,
  checksum_sha256 text,
  evidence_refs jsonb not null default '[]'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  previous_receipt_id uuid references agora_receipts(receipt_id),
  created_at timestamptz not null default now()
);

create index if not exists idx_agora_media_tenant on agora_media_assets(tenant_id);
create index if not exists idx_agora_transcripts_media on agora_transcripts(media_id);
create index if not exists idx_agora_entities_tenant_name on agora_entities(tenant_id, canonical_name);
create index if not exists idx_agora_relationships_source on agora_relationships(source_entity_id);
create index if not exists idx_agora_relationships_target on agora_relationships(target_entity_id);
create index if not exists idx_agora_receipts_object on agora_receipts(object_type, object_id);

-- RLS must be enabled and policy-bound during target project execution.
