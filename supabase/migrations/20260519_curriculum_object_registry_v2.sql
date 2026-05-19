-- =====================================================================
-- 20260519_curriculum_object_registry_v2.sql
-- MERGED design (decision: C, text natural keys, no-HITL).
--
-- Keeps from v1 (curriculum.* deployed): dedicated schema; HARD
--   anti-fabrication (source_reference NOT NULL + non-blank).
-- Adopts from repo (b25487fa): full asset taxonomy + asset_type set;
--   linked_products[]; 10-product alignment with boundary semantics
--   (professional_only / converted_assets_only); curriculum-bound
--   learning_object fields.
-- Rejects from repo: public schema; internal_status='PRETEND'
--   (violates kernel forbidden_states).
--
-- Archive-never-delete: v1 curriculum schema is RENAMED to
--   curriculum_archived_v1, not dropped. Atomic (single migration txn).
-- THIS FILE IS THE APPLIED, RUNTIME-TRUE MIGRATION.
-- =====================================================================

ALTER SCHEMA curriculum RENAME TO curriculum_archived_v1;

CREATE SCHEMA curriculum;

CREATE OR REPLACE FUNCTION curriculum.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE curriculum.authority (
  id            text PRIMARY KEY,
  name          text NOT NULL,
  country       text,
  jurisdiction  text NOT NULL,
  precedence    int  NOT NULL,
  official_url  text,
  status        text NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','inactive','draft','deprecated')),
  is_canonical  boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE curriculum.learning_area (
  id            text PRIMARY KEY,
  authority_id  text NOT NULL REFERENCES curriculum.authority(id) ON DELETE CASCADE,
  code          text NOT NULL,
  name          text NOT NULL,
  stage_scope   text[] NOT NULL DEFAULT '{}',
  status        text NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','inactive','draft','deprecated')),
  sort_order    int  NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (authority_id, code)
);

CREATE TABLE curriculum.stage (
  id            text PRIMARY KEY,
  authority_id  text NOT NULL REFERENCES curriculum.authority(id) ON DELETE CASCADE,
  code          text NOT NULL,
  name          text NOT NULL,
  year_levels   text[] NOT NULL DEFAULT '{}',
  typical_age_range text,
  sort_order    int  NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (authority_id, code)
);

CREATE TABLE curriculum.outcome (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  authority_id      text NOT NULL REFERENCES curriculum.authority(id) ON DELETE CASCADE,
  learning_area_id  text REFERENCES curriculum.learning_area(id) ON DELETE SET NULL,
  stage_id          text REFERENCES curriculum.stage(id) ON DELETE SET NULL,
  outcome_code      text NOT NULL,
  outcome_title     text,
  outcome_statement text,
  strand            text,
  substrand         text,
  source_reference  text NOT NULL,
  source_url        text,
  source_version    text,
  verification_status text NOT NULL DEFAULT 'needs_source'
        CHECK (verification_status IN ('needs_source','source_bound','verified','deprecated','rejected')),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT outcome_source_not_blank CHECK (length(btrim(source_reference)) > 0),
  UNIQUE (authority_id, outcome_code)
);

CREATE TABLE curriculum.learning_object (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title             text NOT NULL,
  slug              text NOT NULL UNIQUE,
  description       text,
  learning_area_id  text REFERENCES curriculum.learning_area(id) ON DELETE SET NULL,
  stage_id          text REFERENCES curriculum.stage(id) ON DELETE SET NULL,
  learning_intent   text,
  success_criteria  text[] NOT NULL DEFAULT '{}',
  classroom_action_type text,
  audience          text[] NOT NULL DEFAULT '{}',
  adaptation_flags  jsonb NOT NULL DEFAULT '{}'::jsonb,
  school_safe       boolean NOT NULL DEFAULT true,
  status            text NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft','review','active','archived','deprecated')),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE curriculum.learning_object_outcome_map (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learning_object_id  uuid NOT NULL REFERENCES curriculum.learning_object(id) ON DELETE CASCADE,
  outcome_id          uuid NOT NULL REFERENCES curriculum.outcome(id) ON DELETE CASCADE,
  alignment_strength  int NOT NULL DEFAULT 3 CHECK (alignment_strength BETWEEN 1 AND 5),
  alignment_note      text,
  evidence_source     text,
  verification_status text NOT NULL DEFAULT 'unverified'
        CHECK (verification_status IN ('unverified','source_bound','verified','rejected')),
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (learning_object_id, outcome_id)
);

CREATE TABLE curriculum.education_asset_registry (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  learning_object_id  uuid REFERENCES curriculum.learning_object(id) ON DELETE SET NULL,
  title               text NOT NULL,
  slug                text NOT NULL UNIQUE,
  asset_type          text NOT NULL CHECK (asset_type IN (
                        'poster','worksheet','template','slide_deck','pack',
                        'activity','assessment','visual_aid','behaviour_support',
                        'wellbeing_resource','app_link','workflow',
                        'course_resource','stem_project','other')),
  description         text,
  canonical_business  text NOT NULL DEFAULT 'Class by Cass',
  surface             text NOT NULL,
  linked_products     text[] NOT NULL DEFAULT '{}',
  audience            text[] NOT NULL DEFAULT '{}',
  format_tags         text[] NOT NULL DEFAULT '{}',
  support_tags        text[] NOT NULL DEFAULT '{}',
  dyslexia_friendly          boolean NOT NULL DEFAULT false,
  neurodiverse_support       boolean NOT NULL DEFAULT false,
  second_language_support    boolean NOT NULL DEFAULT false,
  low_literacy_version       boolean NOT NULL DEFAULT false,
  printable                  boolean NOT NULL DEFAULT false,
  editable                   boolean NOT NULL DEFAULT false,
  home_version_available     boolean NOT NULL DEFAULT false,
  provider_version_available boolean NOT NULL DEFAULT false,
  white_label_ready          boolean NOT NULL DEFAULT false,
  monetisation_model  text NOT NULL DEFAULT 'free' CHECK (monetisation_model IN (
                        'free','paid','bundle','subscription',
                        'school_license','white_label','internal')),
  licence_model       text NOT NULL DEFAULT 'standard',
  creator_name        text,
  source_url          text,
  preview_url         text,
  review_status       text NOT NULL DEFAULT 'draft'
        CHECK (review_status IN ('draft','needs_review','approved','rejected','deprecated')),
  public_status       text NOT NULL DEFAULT 'draft'
        CHECK (public_status IN ('draft','private','public','archived')),
  internal_status     text NOT NULL DEFAULT 'PARTIAL'
        CHECK (internal_status IN ('REAL','PARTIAL','BLOCKED')),
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (learning_object_id, surface)
);

CREATE TABLE curriculum.product_alignment (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_name      text NOT NULL,
  product_slug      text NOT NULL,
  authority_id      text REFERENCES curriculum.authority(id) ON DELETE SET NULL,
  alignment_status  text NOT NULL CHECK (alignment_status IN (
                      'nsw_aligned_target','au_aligned_target',
                      'international_aligned_target','school_safe_unaligned',
                      'converted_assets_only','professional_only','not_relevant')),
  fit_score         int NOT NULL DEFAULT 0 CHECK (fit_score BETWEEN 0 AND 5),
  surface_role      text,
  reuse_fit         numeric NOT NULL DEFAULT 0 CHECK (reuse_fit >= 0 AND reuse_fit <= 1),
  boundary_note     text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (product_slug, authority_id)
);

CREATE INDEX ix_la_authority           ON curriculum.learning_area (authority_id);
CREATE INDEX ix_stage_authority        ON curriculum.stage (authority_id);
CREATE INDEX ix_outcome_auth_stage_area ON curriculum.outcome (authority_id, stage_id, learning_area_id);
CREATE INDEX ix_outcome_code           ON curriculum.outcome (outcome_code);
CREATE INDEX ix_lo_stage_area          ON curriculum.learning_object (stage_id, learning_area_id);
CREATE INDEX ix_lo_status              ON curriculum.learning_object (status);
CREATE INDEX ix_map_object             ON curriculum.learning_object_outcome_map (learning_object_id);
CREATE INDEX ix_map_outcome            ON curriculum.learning_object_outcome_map (outcome_id);
CREATE INDEX ix_asset_object           ON curriculum.education_asset_registry (learning_object_id);
CREATE INDEX ix_asset_type             ON curriculum.education_asset_registry (asset_type);
CREATE INDEX ix_asset_business         ON curriculum.education_asset_registry (canonical_business);
CREATE INDEX ix_pa_slug                ON curriculum.product_alignment (product_slug);

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'authority','learning_area','stage','outcome','learning_object',
    'learning_object_outcome_map','education_asset_registry','product_alignment'
  ] LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%s_updated_at BEFORE UPDATE ON curriculum.%I
       FOR EACH ROW EXECUTE FUNCTION curriculum.set_updated_at()', t, t);
  END LOOP;
END $$;

INSERT INTO curriculum.authority (id, name, country, jurisdiction, precedence, official_url) VALUES
  ('nsw_nesa', 'NSW Education Standards Authority', 'Australia', 'NSW',      1, 'https://curriculum.nsw.edu.au'),
  ('au_acara', 'Australian Curriculum (ACARA)',     'Australia', 'National', 2, 'https://www.australiancurriculum.edu.au');

INSERT INTO curriculum.learning_area (id, authority_id, code, name, stage_scope, sort_order) VALUES
  ('nsw_english',       'nsw_nesa', 'ENG',   'English',        ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 1),
  ('nsw_mathematics',   'nsw_nesa', 'MATH',  'Mathematics',    ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 2),
  ('nsw_science',       'nsw_nesa', 'SCI',   'Science',        ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 3),
  ('nsw_pdhpe',         'nsw_nesa', 'PDHPE', 'Personal Development, Health and Physical Education', ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 4),
  ('nsw_hsie',          'nsw_nesa', 'HSIE',  'Human Society and Its Environment', ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 5),
  ('nsw_languages',     'nsw_nesa', 'LANG',  'Languages',      ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 6),
  ('nsw_creative_arts', 'nsw_nesa', 'CA',    'Creative Arts',  ARRAY['ES1','S1','S2','S3','S4','S5','S6'], 7);

INSERT INTO curriculum.stage (id, authority_id, code, name, year_levels, typical_age_range, sort_order) VALUES
  ('nsw_es1', 'nsw_nesa', 'ES1', 'Early Stage 1', ARRAY['Kindergarten'],        'approx 5-6',   0),
  ('nsw_s1',  'nsw_nesa', 'S1',  'Stage 1',       ARRAY['Year 1','Year 2'],     'approx 6-8',   1),
  ('nsw_s2',  'nsw_nesa', 'S2',  'Stage 2',       ARRAY['Year 3','Year 4'],     'approx 8-10',  2),
  ('nsw_s3',  'nsw_nesa', 'S3',  'Stage 3',       ARRAY['Year 5','Year 6'],     'approx 10-12', 3),
  ('nsw_s4',  'nsw_nesa', 'S4',  'Stage 4',       ARRAY['Year 7','Year 8'],     'approx 12-14', 4),
  ('nsw_s5',  'nsw_nesa', 'S5',  'Stage 5',       ARRAY['Year 9','Year 10'],    'approx 14-16', 5),
  ('nsw_s6',  'nsw_nesa', 'S6',  'Stage 6',       ARRAY['Year 11','Year 12'],   'approx 16-18', 6);

INSERT INTO curriculum.product_alignment
  (product_name, product_slug, authority_id, alignment_status, fit_score, surface_role, reuse_fit, boundary_note) VALUES
  ('Class by Cass',                     'class-by-cass',                     'nsw_nesa', 'nsw_aligned_target',       5, 'teacher_marketplace_front_door', 1.0, 'School-curriculum and classroom-resource front door.'),
  ('Reading Buddy V2',                  'reading-buddy-v2',                  'nsw_nesa', 'nsw_aligned_target',       5, 'literacy_experience',            1.0, 'Literacy engine consuming shared learning objects.'),
  ('Maths Buddy',                       'maths-buddy',                       'nsw_nesa', 'nsw_aligned_target',       5, 'numeracy_experience',            1.0, 'Numeracy engine consuming shared learning objects.'),
  ('Maths Mate',                        'maths-mate',                        'nsw_nesa', 'nsw_aligned_target',       5, 'numeracy_experience',            1.0, 'Numeracy brand/alias; consolidates into Maths Buddy.'),
  ('My Learning Buddy',                 'my-learning-buddy',                 'nsw_nesa', 'nsw_aligned_target',       4, 'home_continuity',                0.8, 'Home continuity and family-facing school assets.'),
  ('Outcome Ready',                     'outcome-ready',                     'nsw_nesa', 'converted_assets_only',    3, 'intervention_evidence',          0.6, 'School-safe converted intervention assets only.'),
  ('Institute for Integrated Humanity', 'institute-for-integrated-humanity', 'nsw_nesa', 'professional_only',        2, 'adult_professional',             0.2, 'Adult/professional learning; only school-safe converted assets belong in Class by Cass.'),
  ('AI4Tradies',                        'ai4tradies',                        'nsw_nesa', 'converted_assets_only',    2, 'vocational',                     0.3, 'Trades learning; only vocational school-safe packs belong in Class by Cass.'),
  ('CalmBound',                         'calmbound',                         'nsw_nesa', 'nsw_aligned_target',       4, 'wellbeing_regulation',           0.8, 'Classroom wellbeing, regulation and sensory resources.'),
  ('Synal / Scinal',                    'synal-scinal',                      'nsw_nesa', 'school_safe_unaligned',    3, 'workflow_browser_surface',       0.5, 'Workflow/browser layer supporting school-facing activities.');

INSERT INTO curriculum.learning_object
  (id, title, slug, description, learning_area_id, stage_id, learning_intent, success_criteria, classroom_action_type, audience, adaptation_flags, school_safe, status) VALUES
  ('00000000-0000-0000-0000-000000000a01',
   'Stage 1 Phonics Classroom Pack', 'stage1-phonics-classroom-pack',
   'Decodable phonics pack aligned to NSW Stage 1 English.',
   'nsw_english', 'nsw_s1',
   'Students practise phonics through classroom-ready activities.',
   ARRAY['Students identify target sounds','Students decode with support','Teacher can adapt for home practice'],
   'literacy_practice', ARRAY['teacher','student','parent'],
   '{"printable":true,"editable":true,"dyslexia_friendly":true,"home_version":true}'::jsonb, true, 'draft'),
  ('00000000-0000-0000-0000-000000000a02',
   'Classroom Routine Poster', 'classroom-routine-poster',
   'Visual classroom routine poster for early primary.',
   NULL, 'nsw_es1',
   'Students understand and follow classroom routine cues.',
   ARRAY['Students identify routine step','Students follow visual cue','Teacher can print or adapt'],
   'classroom_routine', ARRAY['teacher','student'],
   '{"printable":true,"neurodiverse":true}'::jsonb, true, 'draft');

INSERT INTO curriculum.education_asset_registry
  (learning_object_id, title, slug, asset_type, description, surface, linked_products,
   audience, format_tags, support_tags, dyslexia_friendly, neurodiverse_support,
   second_language_support, low_literacy_version, printable, editable,
   home_version_available, provider_version_available, white_label_ready,
   monetisation_model, licence_model, creator_name, review_status, public_status, internal_status) VALUES
  ('00000000-0000-0000-0000-000000000a01', 'Stage 1 Phonics Pack - Class by Cass', 'stage1-phonics-pack-cbc',
   'pack', 'Phonics pack surfaced on Class by Cass marketplace.', 'class_by_cass',
   ARRAY['class-by-cass','reading-buddy-v2'], ARRAY['teacher','student','parent'],
   ARRAY['pdf','printable'], ARRAY['literacy','phonics','dyslexia-friendly'],
   true,true,false,true,true,true,true,false,true,
   'bundle','CC BY 4.0','Tech 4 Humanity','draft','private','PARTIAL'),
  ('00000000-0000-0000-0000-000000000a01', 'Stage 1 Phonics Pack - Reading Buddy', 'stage1-phonics-pack-rb',
   'pack', 'Same phonics object surfaced inside Reading Buddy literacy engine.', 'reading_buddy',
   ARRAY['reading-buddy-v2'], ARRAY['teacher','student'],
   ARRAY['pdf','printable'], ARRAY['literacy','phonics'],
   true,true,false,true,true,true,true,false,false,
   'internal','internal','Tech 4 Humanity','draft','private','PARTIAL'),
  ('00000000-0000-0000-0000-000000000a02', 'Classroom Routine Poster - Class by Cass', 'classroom-routine-poster-cbc',
   'poster', 'Routine poster surfaced on Class by Cass.', 'class_by_cass',
   ARRAY['class-by-cass','calmbound','my-learning-buddy'], ARRAY['teacher','student','parent'],
   ARRAY['pdf','poster','printable'], ARRAY['wellbeing','classroom-routine','visual-support'],
   false,true,true,true,true,true,true,true,true,
   'free','CC BY 4.0','Tech 4 Humanity','draft','private','PARTIAL');

COMMENT ON TABLE curriculum.outcome IS 'Source-bound curriculum outcomes. source_reference is mandatory and non-blank. Do not fabricate official NSW outcome content.';
COMMENT ON TABLE curriculum.learning_object IS 'Canonical reusable learning object shared across Class by Cass, Reading Buddy, Maths Buddy and other school-facing surfaces.';
COMMENT ON TABLE curriculum.education_asset_registry IS 'Reusable asset registry. internal_status excludes PRETEND by kernel policy.';
COMMENT ON SCHEMA curriculum_archived_v1 IS 'Archived v1 curriculum schema (2026-05-19). Superseded by merged v2. Retained per archive-never-delete.';
