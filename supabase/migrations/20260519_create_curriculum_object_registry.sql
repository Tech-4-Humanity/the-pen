-- 20260519_create_curriculum_object_registry.sql
-- Class by Cass / Reading Buddy / Maths Buddy curriculum object registry
-- NSW-first, Australian Curriculum second, international mappings third.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.curriculum_authority (
  authority_id uuid primary key default gen_random_uuid(),
  authority_code text unique not null,
  authority_name text not null,
  country text,
  jurisdiction text,
  priority_order integer not null default 999,
  status text not null default 'active' check (status in ('active','inactive','draft','deprecated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_curriculum_authority_updated_at on public.curriculum_authority;
create trigger trg_curriculum_authority_updated_at
before update on public.curriculum_authority
for each row execute function public.set_updated_at();

create table if not exists public.curriculum_learning_area (
  learning_area_id uuid primary key default gen_random_uuid(),
  authority_id uuid not null references public.curriculum_authority(authority_id) on delete cascade,
  area_code text not null,
  area_name text not null,
  stage_scope text[] not null default '{}',
  status text not null default 'active' check (status in ('active','inactive','draft','deprecated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(authority_id, area_code)
);

drop trigger if exists trg_curriculum_learning_area_updated_at on public.curriculum_learning_area;
create trigger trg_curriculum_learning_area_updated_at
before update on public.curriculum_learning_area
for each row execute function public.set_updated_at();

create table if not exists public.curriculum_stage (
  stage_id uuid primary key default gen_random_uuid(),
  authority_id uuid not null references public.curriculum_authority(authority_id) on delete cascade,
  stage_code text not null,
  stage_name text not null,
  year_levels text[] not null default '{}',
  typical_age_range text,
  sort_order integer not null default 999,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(authority_id, stage_code)
);

drop trigger if exists trg_curriculum_stage_updated_at on public.curriculum_stage;
create trigger trg_curriculum_stage_updated_at
before update on public.curriculum_stage
for each row execute function public.set_updated_at();

create table if not exists public.curriculum_outcome (
  outcome_id uuid primary key default gen_random_uuid(),
  authority_id uuid not null references public.curriculum_authority(authority_id) on delete cascade,
  learning_area_id uuid references public.curriculum_learning_area(learning_area_id) on delete set null,
  stage_id uuid references public.curriculum_stage(stage_id) on delete set null,
  outcome_code text not null,
  outcome_title text,
  outcome_statement text,
  strand text,
  substrand text,
  source_url text,
  source_version text,
  verification_status text not null default 'needs_source' check (verification_status in ('needs_source','source_bound','verified','deprecated','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(authority_id, outcome_code),
  constraint curriculum_outcome_source_rule check (
    verification_status = 'needs_source'
    or source_url is not null
  )
);

drop trigger if exists trg_curriculum_outcome_updated_at on public.curriculum_outcome;
create trigger trg_curriculum_outcome_updated_at
before update on public.curriculum_outcome
for each row execute function public.set_updated_at();

create table if not exists public.learning_object (
  learning_object_id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  description text,
  learning_area_id uuid references public.curriculum_learning_area(learning_area_id) on delete set null,
  stage_id uuid references public.curriculum_stage(stage_id) on delete set null,
  learning_intent text,
  success_criteria text[] not null default '{}',
  classroom_action_type text,
  school_safe boolean not null default true,
  status text not null default 'draft' check (status in ('draft','review','active','archived','deprecated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_learning_object_updated_at on public.learning_object;
create trigger trg_learning_object_updated_at
before update on public.learning_object
for each row execute function public.set_updated_at();

create table if not exists public.learning_object_outcome_map (
  map_id uuid primary key default gen_random_uuid(),
  learning_object_id uuid not null references public.learning_object(learning_object_id) on delete cascade,
  outcome_id uuid not null references public.curriculum_outcome(outcome_id) on delete cascade,
  alignment_strength integer not null default 3 check (alignment_strength between 1 and 5),
  alignment_note text,
  evidence_source text,
  verification_status text not null default 'unverified' check (verification_status in ('unverified','source_bound','verified','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(learning_object_id, outcome_id)
);

drop trigger if exists trg_learning_object_outcome_map_updated_at on public.learning_object_outcome_map;
create trigger trg_learning_object_outcome_map_updated_at
before update on public.learning_object_outcome_map
for each row execute function public.set_updated_at();

create table if not exists public.education_asset_registry (
  asset_id uuid primary key default gen_random_uuid(),
  learning_object_id uuid references public.learning_object(learning_object_id) on delete set null,
  title text not null,
  slug text unique not null,
  asset_type text not null check (asset_type in ('poster','worksheet','template','slide_deck','pack','activity','assessment','visual_aid','behaviour_support','wellbeing_resource','app_link','workflow','course_resource','stem_project','other')),
  description text,
  canonical_business text not null default 'Class by Cass',
  linked_products text[] not null default '{}',
  audience text[] not null default '{}',
  format_tags text[] not null default '{}',
  support_tags text[] not null default '{}',
  dyslexia_friendly boolean not null default false,
  neurodiverse_support boolean not null default false,
  second_language_support boolean not null default false,
  low_literacy_version boolean not null default false,
  printable boolean not null default false,
  editable boolean not null default false,
  home_version_available boolean not null default false,
  provider_version_available boolean not null default false,
  white_label_ready boolean not null default false,
  monetisation_model text not null default 'free' check (monetisation_model in ('free','paid','bundle','subscription','school_license','white_label','internal')),
  licence_model text not null default 'standard',
  creator_name text,
  source_url text,
  preview_url text,
  review_status text not null default 'draft' check (review_status in ('draft','needs_review','approved','rejected','deprecated')),
  public_status text not null default 'draft' check (public_status in ('draft','private','public','archived')),
  internal_status text not null default 'PARTIAL' check (internal_status in ('REAL','PARTIAL','BLOCKED','PRETEND')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_education_asset_registry_updated_at on public.education_asset_registry;
create trigger trg_education_asset_registry_updated_at
before update on public.education_asset_registry
for each row execute function public.set_updated_at();

create table if not exists public.product_curriculum_alignment (
  product_alignment_id uuid primary key default gen_random_uuid(),
  product_name text not null,
  product_slug text not null,
  curriculum_authority_id uuid references public.curriculum_authority(authority_id) on delete set null,
  alignment_status text not null check (alignment_status in ('nsw_aligned_target','au_aligned_target','international_aligned_target','school_safe_unaligned','converted_assets_only','professional_only','not_relevant')),
  fit_score integer not null default 0 check (fit_score between 0 and 5),
  boundary_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(product_slug, curriculum_authority_id)
);

drop trigger if exists trg_product_curriculum_alignment_updated_at on public.product_curriculum_alignment;
create trigger trg_product_curriculum_alignment_updated_at
before update on public.product_curriculum_alignment
for each row execute function public.set_updated_at();

create index if not exists idx_curriculum_learning_area_authority on public.curriculum_learning_area(authority_id);
create index if not exists idx_curriculum_stage_authority on public.curriculum_stage(authority_id);
create index if not exists idx_curriculum_outcome_authority_stage_area on public.curriculum_outcome(authority_id, stage_id, learning_area_id);
create index if not exists idx_curriculum_outcome_code on public.curriculum_outcome(outcome_code);
create index if not exists idx_learning_object_stage_area on public.learning_object(stage_id, learning_area_id);
create index if not exists idx_learning_object_status on public.learning_object(status);
create index if not exists idx_learning_object_outcome_map_object on public.learning_object_outcome_map(learning_object_id);
create index if not exists idx_learning_object_outcome_map_outcome on public.learning_object_outcome_map(outcome_id);
create index if not exists idx_education_asset_registry_learning_object on public.education_asset_registry(learning_object_id);
create index if not exists idx_education_asset_registry_asset_type on public.education_asset_registry(asset_type);
create index if not exists idx_education_asset_registry_public_status on public.education_asset_registry(public_status);
create index if not exists idx_product_curriculum_alignment_slug on public.product_curriculum_alignment(product_slug);

insert into public.curriculum_authority (authority_code, authority_name, country, jurisdiction, priority_order, status)
values
  ('NSW_NESA','NSW Education Standards Authority','Australia','NSW',1,'active'),
  ('AUS_ACARA','Australian Curriculum / ACARA','Australia','National',2,'active')
on conflict (authority_code) do update set
  authority_name = excluded.authority_name,
  country = excluded.country,
  jurisdiction = excluded.jurisdiction,
  priority_order = excluded.priority_order,
  status = excluded.status,
  updated_at = now();

with nsw as (
  select authority_id from public.curriculum_authority where authority_code = 'NSW_NESA'
)
insert into public.curriculum_stage (authority_id, stage_code, stage_name, year_levels, typical_age_range, sort_order)
select nsw.authority_id, seed.stage_code, seed.stage_name, seed.year_levels, seed.typical_age_range, seed.sort_order
from nsw
cross join (values
  ('ES1','Early Stage 1',array['Kindergarten'],'approx 5-6',1),
  ('S1','Stage 1',array['Year 1','Year 2'],'approx 6-8',2),
  ('S2','Stage 2',array['Year 3','Year 4'],'approx 8-10',3),
  ('S3','Stage 3',array['Year 5','Year 6'],'approx 10-12',4),
  ('S4','Stage 4',array['Year 7','Year 8'],'approx 12-14',5),
  ('S5','Stage 5',array['Year 9','Year 10'],'approx 14-16',6),
  ('S6','Stage 6',array['Year 11','Year 12'],'approx 16-18',7)
) as seed(stage_code, stage_name, year_levels, typical_age_range, sort_order)
on conflict (authority_id, stage_code) do update set
  stage_name = excluded.stage_name,
  year_levels = excluded.year_levels,
  typical_age_range = excluded.typical_age_range,
  sort_order = excluded.sort_order,
  updated_at = now();

with nsw as (
  select authority_id from public.curriculum_authority where authority_code = 'NSW_NESA'
)
insert into public.curriculum_learning_area (authority_id, area_code, area_name, stage_scope, status)
select nsw.authority_id, seed.area_code, seed.area_name, seed.stage_scope, 'active'
from nsw
cross join (values
  ('ENG','English',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('MATH','Mathematics',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('PDHPE','Personal Development, Health and Physical Education',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('SCI','Science',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('LANG','Languages',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('CA','Creative Arts',array['ES1','S1','S2','S3','S4','S5','S6']),
  ('HSIE','Human Society and Its Environment',array['ES1','S1','S2','S3','S4','S5','S6'])
) as seed(area_code, area_name, stage_scope)
on conflict (authority_id, area_code) do update set
  area_name = excluded.area_name,
  stage_scope = excluded.stage_scope,
  status = excluded.status,
  updated_at = now();

with nsw as (
  select authority_id from public.curriculum_authority where authority_code = 'NSW_NESA'
)
insert into public.product_curriculum_alignment (product_name, product_slug, curriculum_authority_id, alignment_status, fit_score, boundary_note)
select seed.product_name, seed.product_slug, nsw.authority_id, seed.alignment_status, seed.fit_score, seed.boundary_note
from nsw
cross join (values
  ('Class by Cass','class-by-cass','nsw_aligned_target',5,'School-curriculum and classroom-resource front door.'),
  ('Reading Buddy V2','reading-buddy-v2','nsw_aligned_target',5,'Literacy engine consuming shared learning objects.'),
  ('Maths Buddy','maths-buddy','nsw_aligned_target',5,'Numeracy engine consuming shared learning objects.'),
  ('Maths Mate','maths-mate','nsw_aligned_target',5,'Numeracy brand/product alias consuming shared objects.'),
  ('My Learning Buddy','my-learning-buddy','nsw_aligned_target',4,'Home continuity and family-facing school assets.'),
  ('Outcome Ready','outcome-ready','converted_assets_only',3,'School-safe converted intervention assets only.'),
  ('Institute for Integrated Humanity','institute-for-integrated-humanity','professional_only',2,'Adult/professional learning; only school-safe converted assets belong in Class by Cass.'),
  ('AI4Tradies','ai4tradies','converted_assets_only',2,'Trades learning; only vocational school-safe packs belong in Class by Cass.'),
  ('CalmBound','calmbound','nsw_aligned_target',4,'Classroom wellbeing, regulation and sensory resources.'),
  ('Synal / Scinal','synal-scinal','school_safe_unaligned',3,'Workflow/browser layer supporting school-facing activities.')
) as seed(product_name, product_slug, alignment_status, fit_score, boundary_note)
on conflict (product_slug, curriculum_authority_id) do update set
  product_name = excluded.product_name,
  alignment_status = excluded.alignment_status,
  fit_score = excluded.fit_score,
  boundary_note = excluded.boundary_note,
  updated_at = now();

insert into public.learning_object (title, slug, description, learning_intent, success_criteria, classroom_action_type, school_safe, status)
values
  ('Reading Buddy sample: phonics classroom pack','reading-buddy-sample-phonics-classroom-pack','Smoke-test learning object for Reading Buddy V2 and Class by Cass shared registry. Replace with source-bound curriculum mapping before public curriculum claims.','Students practise phonics through classroom-ready activities.',array['Students identify target sounds','Students practise decoding with support','Teacher can adapt activity for home practice'],'literacy_practice',true,'draft'),
  ('Class by Cass sample: classroom routine poster','class-by-cass-sample-classroom-routine-poster','Smoke-test learning object for classroom poster reuse, white-label packaging and asset registry validation.','Students understand and follow classroom routine cues.',array['Students identify routine step','Students follow visual cue','Teacher can print or adapt poster'],'classroom_routine',true,'draft')
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  learning_intent = excluded.learning_intent,
  success_criteria = excluded.success_criteria,
  classroom_action_type = excluded.classroom_action_type,
  school_safe = excluded.school_safe,
  status = excluded.status,
  updated_at = now();

insert into public.education_asset_registry (
  learning_object_id,
  title,
  slug,
  asset_type,
  description,
  canonical_business,
  linked_products,
  audience,
  format_tags,
  support_tags,
  dyslexia_friendly,
  neurodiverse_support,
  second_language_support,
  low_literacy_version,
  printable,
  editable,
  home_version_available,
  provider_version_available,
  white_label_ready,
  monetisation_model,
  licence_model,
  creator_name,
  review_status,
  public_status,
  internal_status
)
select
  lo.learning_object_id,
  seed.title,
  seed.slug,
  seed.asset_type,
  seed.description,
  seed.canonical_business,
  seed.linked_products,
  seed.audience,
  seed.format_tags,
  seed.support_tags,
  seed.dyslexia_friendly,
  seed.neurodiverse_support,
  seed.second_language_support,
  seed.low_literacy_version,
  seed.printable,
  seed.editable,
  seed.home_version_available,
  seed.provider_version_available,
  seed.white_label_ready,
  seed.monetisation_model,
  seed.licence_model,
  seed.creator_name,
  seed.review_status,
  seed.public_status,
  seed.internal_status
from (values
  ('reading-buddy-sample-phonics-classroom-pack','Reading Buddy sample phonics worksheet','reading-buddy-sample-phonics-worksheet','worksheet','Smoke-test worksheet asset shared by Reading Buddy V2 and Class by Cass.','Class by Cass',array['reading-buddy-v2','class-by-cass'],array['teacher','student','parent'],array['pdf','printable'],array['literacy','phonics','dyslexia-friendly'],true,true,false,true,true,true,true,false,true,'internal','standard','Tech 4 Humanity','draft','private','PARTIAL'),
  ('class-by-cass-sample-classroom-routine-poster','Class by Cass sample classroom routine poster','class-by-cass-sample-classroom-routine-poster','poster','Smoke-test poster asset for reusable classroom routines and white-label packaging.','Class by Cass',array['class-by-cass','calmbound','my-learning-buddy'],array['teacher','student','parent'],array['pdf','poster','printable'],array['wellbeing','classroom-routine','visual-support'],false,true,true,true,true,true,true,true,true,'internal','standard','Tech 4 Humanity','draft','private','PARTIAL')
) as seed(learning_slug,title,slug,asset_type,description,canonical_business,linked_products,audience,format_tags,support_tags,dyslexia_friendly,neurodiverse_support,second_language_support,low_literacy_version,printable,editable,home_version_available,provider_version_available,white_label_ready,monetisation_model,licence_model,creator_name,review_status,public_status,internal_status)
join public.learning_object lo on lo.slug = seed.learning_slug
on conflict (slug) do update set
  learning_object_id = excluded.learning_object_id,
  title = excluded.title,
  asset_type = excluded.asset_type,
  description = excluded.description,
  canonical_business = excluded.canonical_business,
  linked_products = excluded.linked_products,
  audience = excluded.audience,
  format_tags = excluded.format_tags,
  support_tags = excluded.support_tags,
  dyslexia_friendly = excluded.dyslexia_friendly,
  neurodiverse_support = excluded.neurodiverse_support,
  second_language_support = excluded.second_language_support,
  low_literacy_version = excluded.low_literacy_version,
  printable = excluded.printable,
  editable = excluded.editable,
  home_version_available = excluded.home_version_available,
  provider_version_available = excluded.provider_version_available,
  white_label_ready = excluded.white_label_ready,
  monetisation_model = excluded.monetisation_model,
  licence_model = excluded.licence_model,
  creator_name = excluded.creator_name,
  review_status = excluded.review_status,
  public_status = excluded.public_status,
  internal_status = excluded.internal_status,
  updated_at = now();

comment on table public.curriculum_outcome is 'Stores source-bound curriculum outcomes. Do not fabricate official outcome content; keep verification_status=needs_source until source_url/source_version is attached.';
comment on table public.learning_object is 'Canonical reusable learning object shared across Class by Cass, Reading Buddy, Maths Buddy and other school-facing products.';
comment on table public.education_asset_registry is 'Canonical reusable asset registry for posters, worksheets, templates, slides, packs, app links and classroom resources.';
