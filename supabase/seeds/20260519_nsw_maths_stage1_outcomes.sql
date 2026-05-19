-- =====================================================================
-- 20260519_nsw_maths_stage1_outcomes.sql
-- 17 official NSW Mathematics K-10 (2022) Stage 1 outcomes:
--   MAO-WM-01 (overarching Working mathematically, all stages) +
--   16 MA1-* Stage 1 content outcomes.
-- Source (verbatim): NESA Mathematics K-10 Syllabus (2022) outcomes
--   https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes
-- verification_status='source_bound' (official web source; not yet
--   cross-checked vs a NESA machine-readable API). NO fabricated codes.
-- Idempotent via ON CONFLICT (authority_id, outcome_code).
-- Applied to Supabase lzfgigiyqpuuxslsygjt 2026-05-19.
-- Note: MAO-WM-01 stored under stage_id nsw_s1 for Maths Buddy Stage 1
--   consumption; it is the overarching cross-stage WM outcome at source.
-- =====================================================================

INSERT INTO curriculum.outcome
  (authority_id, learning_area_id, stage_id, outcome_code, outcome_title, outcome_statement, strand, source_reference, source_url, source_version, verification_status) VALUES
  ('nsw_nesa','nsw_mathematics','nsw_s1','MAO-WM-01','Working mathematically','develops understanding and fluency in mathematics through exploring and connecting mathematical concepts, choosing and applying mathematical techniques to solve problems, and communicating their thinking and reasoning coherently and clearly','Working mathematically','NSW Mathematics K-10 Syllabus (2022), outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-RWN-01','Representing whole numbers','applies an understanding of place value and the role of zero to read, write and order two- and three-digit numbers','Number and algebra','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-RWN-02','Representing whole numbers','reasons about representations of whole numbers to 1000, partitioning numbers to use and record quantity values','Number and algebra','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-CSQ-01','Combining and separating quantities','uses number bonds and the relationship between addition and subtraction to solve problems involving partitioning','Number and algebra','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-FG-01','Forming groups','uses the structure of equal groups to solve multiplication problems, and shares or groups to solve division problems','Number and algebra','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-GM-01','Geometric measure','represents and describes the positions of objects in familiar locations','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-GM-02','Geometric measure','measures, records, compares and estimates lengths and distances using uniform informal units, as well as metres and centimetres','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-GM-03','Geometric measure','creates and recognises halves, quarters and eighths as part measures of a whole length','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-2DS-01','Two-dimensional spatial structure','recognises, describes and represents shapes including quadrilaterals and other common polygons','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-2DS-02','Two-dimensional spatial structure','measures and compares areas using uniform informal units in rows and columns','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-3DS-01','Three-dimensional spatial structure','recognises, describes and represents familiar three-dimensional objects','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-3DS-02','Three-dimensional spatial structure','measures, records, compares and estimates internal volumes (capacities) and volumes using uniform informal units','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-NSM-01','Non-spatial measure','measures, records, compares and estimates the masses of objects using uniform informal units','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-NSM-02','Non-spatial measure','describes, compares and orders durations of events, and reads half- and quarter-hour time','Measurement and space','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-DATA-01','Data','gathers and organises data, displays data in lists, tables and picture graphs','Statistics and probability','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-DATA-02','Data','reasons about representations of data to describe and interpret the results','Statistics and probability','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_mathematics','nsw_s1','MA1-CHAN-01','Chance','recognises and describes the element of chance in everyday events','Statistics and probability','NSW Mathematics K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/mathematics/mathematics-k-10-2022/outcomes','2022','source_bound')
ON CONFLICT (authority_id, outcome_code) DO NOTHING;

-- Numeracy reuse chain: shared place-value object -> Class by Cass + Maths Buddy.
WITH new_obj AS (
  INSERT INTO curriculum.learning_object
    (title, slug, description, learning_area_id, stage_id, learning_intent, success_criteria, classroom_action_type, audience, adaptation_flags, school_safe, status)
  VALUES
    ('Stage 1 Place Value Number Pack','stage1-place-value-number-pack',
     'Two- and three-digit place-value activities aligned to NSW Stage 1 Mathematics.',
     'nsw_mathematics','nsw_s1',
     'Students read, write and order 2- and 3-digit numbers using place value.',
     ARRAY['Students identify place value of each digit','Students order numbers to 1000','Teacher can adapt for home practice'],
     'numeracy_practice', ARRAY['teacher','student','parent'],
     '{"printable":true,"editable":true,"low_literacy":true,"home_version":true}'::jsonb, true, 'draft')
  ON CONFLICT (slug) DO NOTHING
  RETURNING id
)
INSERT INTO curriculum.education_asset_registry
  (learning_object_id, title, slug, asset_type, description, surface, linked_products,
   audience, format_tags, support_tags, dyslexia_friendly, neurodiverse_support,
   second_language_support, low_literacy_version, printable, editable,
   home_version_available, provider_version_available, white_label_ready,
   monetisation_model, licence_model, creator_name, review_status, public_status, internal_status)
SELECT n.id, t.title, t.slug, 'pack', t.descr, t.surface, t.linked, ARRAY['teacher','student','parent'],
   ARRAY['pdf','printable'], ARRAY['numeracy','place-value'], false,true,true,true,true,true,true,false,t.wl,
   t.mon,'CC BY 4.0','Tech 4 Humanity','draft','private','PARTIAL'
FROM new_obj n,
(VALUES
  ('Stage 1 Place Value Pack - Class by Cass','s1-place-value-cbc','Place value pack on Class by Cass marketplace.','class_by_cass',ARRAY['class-by-cass','maths-buddy','maths-mate'],true,'bundle'),
  ('Stage 1 Place Value Pack - Maths Buddy','s1-place-value-mb','Same place-value object surfaced inside Maths Buddy numeracy engine.','maths_buddy',ARRAY['maths-buddy'],false,'internal')
) AS t(title,slug,descr,surface,linked,wl,mon)
ON CONFLICT (learning_object_id, surface) DO NOTHING;

INSERT INTO curriculum.learning_object_outcome_map
  (learning_object_id, outcome_id, alignment_strength, alignment_note, evidence_source, verification_status)
SELECT lo.id, o.id, 5,
  'Place-value number pack directly targets read/write/order of 2-3 digit numbers.',
  'NSW Mathematics K-10 Syllabus (2022) outcomes page','source_bound'
FROM curriculum.learning_object lo, curriculum.outcome o
WHERE lo.slug='stage1-place-value-number-pack'
  AND o.authority_id='nsw_nesa' AND o.outcome_code='MA1-RWN-01'
UNION ALL
SELECT lo.id, o.id, 3,
  'Secondary alignment: working mathematically processes assessed alongside content.',
  'NSW Mathematics K-10 Syllabus (2022) outcomes page','source_bound'
FROM curriculum.learning_object lo, curriculum.outcome o
WHERE lo.slug='stage1-place-value-number-pack'
  AND o.authority_id='nsw_nesa' AND o.outcome_code='MAO-WM-01'
ON CONFLICT (learning_object_id, outcome_id) DO NOTHING;
