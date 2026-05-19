-- =====================================================================
-- 20260519_nsw_english_stage1_outcomes.sql
-- 9 official NSW English K-10 (2022) Stage 1 outcomes.
-- Source (verbatim): NESA English K-10 Syllabus (2022) outcomes page
--   https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes
-- verification_status='source_bound' (transcribed from official web
--   source; not yet cross-checked against a NESA machine-readable API).
-- Honors curriculum.outcome.outcome_source_not_blank guard: every row
--   carries a real source_reference + source_url. NO fabricated codes.
-- Idempotent via ON CONFLICT (authority_id, outcome_code).
-- Applied to Supabase lzfgigiyqpuuxslsygjt 2026-05-19.
-- =====================================================================

INSERT INTO curriculum.outcome
  (authority_id, learning_area_id, stage_id, outcome_code, outcome_title, outcome_statement, strand, source_reference, source_url, source_version, verification_status) VALUES
  ('nsw_nesa','nsw_english','nsw_s1','EN1-OLC-01','Oral language and communication','communicates effectively by using interpersonal conventions and language to extend and elaborate ideas for social and learning interactions','Oral language and communication','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-VOCAB-01','Vocabulary','understands and effectively uses Tier 1, taught Tier 2 and Tier 3 vocabulary to extend and elaborate ideas','Vocabulary','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-PHOKW-01','Phonic knowledge','uses initial and extended phonics, including vowel digraphs, trigraphs to decode and encode words when reading and creating texts','Phonic knowledge and word knowledge','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-REFLU-01','Reading fluency','sustains reading unseen texts with automaticity and prosody and self-corrects errors','Reading fluency','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-RECOM-01','Reading comprehension','comprehends independently read texts that require sustained reading by activating background and word knowledge, connecting and understanding sentences and whole text, and monitoring for meaning','Reading comprehension','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-CWT-01','Creating written texts','plans, creates and revises texts written for different purposes, including paragraphs, using knowledge of vocabulary, text features and sentence structure','Creating written texts','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-SPELL-01','Spelling','applies phonological, orthographic and morphological generalisations and strategies when spelling words in a range of writing contexts','Spelling','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-HANDW-01','Handwriting','uses a legible, fluent and automatic handwriting style, and digital technology, including word-processing applications, when creating texts','Handwriting and digital transcription','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound'),
  ('nsw_nesa','nsw_english','nsw_s1','EN1-UARL-01','Understanding and responding to literature','understands and responds to literature by creating texts using similar structures, intentional language choices and features appropriate to audience and purpose','Understanding and responding to literature','NSW English K-10 Syllabus (2022), Stage 1 outcomes, NESA','https://curriculum.nsw.edu.au/learning-areas/english/english-k-10-2022/outcomes','2022','source_bound')
ON CONFLICT (authority_id, outcome_code) DO NOTHING;

-- Complete the chain: phonics learning object -> its real outcome.
INSERT INTO curriculum.learning_object_outcome_map
  (learning_object_id, outcome_id, alignment_strength, alignment_note, evidence_source, verification_status)
SELECT '00000000-0000-0000-0000-000000000a01', o.id, 5,
       'Decodable phonics pack directly targets initial/extended phonics decode-encode.',
       'NSW English K-10 Syllabus (2022) outcomes page', 'source_bound'
FROM curriculum.outcome o
WHERE o.authority_id='nsw_nesa' AND o.outcome_code='EN1-PHOKW-01'
ON CONFLICT (learning_object_id, outcome_id) DO NOTHING;
