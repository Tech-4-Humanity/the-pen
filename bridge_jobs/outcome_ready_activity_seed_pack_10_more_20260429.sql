-- Outcome Ready Activity Seed Pack: 10 additional activities
-- Purpose: expand the NeuroProfile Activity Engine with safe, non-diagnostic functional support activities.
-- Boundary: educational and functional support only. Not diagnosis, treatment advice, prescribing, or a replacement for qualified professional care.

insert into public.or_activity_library (
  activity_key,
  activity_name,
  domain_key,
  activity_type,
  audience,
  description,
  steps,
  outcome_markers,
  minimum_review_role,
  safety_boundary,
  resale_ready,
  active
)
values
(
  'two_minute_body_double_start',
  'Two-minute body-double start',
  'executive_function',
  'routine',
  'mixed',
  'A short co-working start routine that helps a person begin a task with another person present or virtually present.',
  '[{"step":1,"text":"Name the task in one sentence."},{"step":2,"text":"Choose the smallest visible first action."},{"step":3,"text":"Start a two-minute timer with a support person present or virtually present."},{"step":4,"text":"Record whether the person started, paused, avoided, or needed another scaffold."}]'::jsonb,
  array['task_start_latency'],
  'trained_support_worker_or_practitioner',
  'This activity supports task initiation only. It is not diagnosis or treatment advice.',
  true,
  true
),
(
  'attention_anchor_card',
  'Attention anchor card',
  'attention_regulation',
  'exercise',
  'mixed',
  'A simple visual or written anchor that helps a person return to the intended task after distraction.',
  '[{"step":1,"text":"Write the task goal on one card or screen note."},{"step":2,"text":"Place the anchor in sight before starting."},{"step":3,"text":"When distracted, read the anchor and choose one return action."},{"step":4,"text":"Record how many returns were needed and how long recovery took."}]'::jsonb,
  array['focus_recovery_time'],
  'trained_support_worker_or_practitioner',
  'This activity supports attention recovery only. It is not diagnosis or treatment advice.',
  true,
  true
),
(
  'sensory_map_the_room',
  'Sensory map the room',
  'sensory_load',
  'environment_change',
  'parent_carer',
  'A room-scanning activity that identifies sensory load sources and chooses one practical adjustment.',
  '[{"step":1,"text":"Stand in the space and identify sound, light, smell, texture, movement, and crowding factors."},{"step":2,"text":"Ask which factor feels most difficult right now."},{"step":3,"text":"Make one small change such as light, seat, noise, object, break, or position."},{"step":4,"text":"Record whether comfort, participation, or recovery improved."}]'::jsonb,
  array['sensory_recovery_need'],
  'parent_carer_or_trained_support_worker',
  'This activity supports environmental awareness only. It is not diagnosis or treatment advice.',
  true,
  true
),
(
  'traffic_light_regulation_check',
  'Traffic light regulation check',
  'emotional_regulation',
  'reflection',
  'child',
  'A colour-based check-in that helps children communicate regulation state and choose a support action.',
  '[{"step":1,"text":"Ask the child to choose green, yellow, or red for current regulation state."},{"step":2,"text":"Name one body clue that matches the colour."},{"step":3,"text":"Choose one matching support action such as continue, pause, breathe, move, ask for help, or reduce noise."},{"step":4,"text":"Check again after five minutes and record any change."}]'::jsonb,
  array['regulation_recovery_time'],
  'parent_carer_or_trained_support_worker',
  'This activity supports communication about regulation only. It is not crisis care, diagnosis, or treatment advice.',
  true,
  true
),
(
  'three_sentence_repair',
  'Three-sentence repair',
  'social_communication',
  'communication_script',
  'mixed',
  'A short script for repairing misunderstanding while reducing blame and escalation.',
  '[{"step":1,"text":"Sentence one: say what you think happened."},{"step":2,"text":"Sentence two: say what you meant or needed."},{"step":3,"text":"Sentence three: ask what the other person understood or needs next."},{"step":4,"text":"Record whether the conversation became clearer, stayed stuck, or needed support."}]'::jsonb,
  array['communication_repair_load'],
  'trained_support_worker_or_practitioner',
  'This activity supports communication repair only. It is not counselling, mediation, diagnosis, or treatment advice.',
  true,
  true
),
(
  'read_pause_predict_check',
  'Read, pause, predict, check',
  'learning_access',
  'exercise',
  'mixed',
  'A reading scaffold that improves active comprehension by pausing to predict and then checking meaning.',
  '[{"step":1,"text":"Read a short paragraph or page."},{"step":2,"text":"Pause and predict what comes next or what the point was."},{"step":3,"text":"Read the next section or summary cue."},{"step":4,"text":"Check whether the prediction helped comprehension and persistence."}]'::jsonb,
  array['reading_scaffold_benefit'],
  'teacher_tutor_parent_carer_or_practitioner',
  'This activity supports reading access only. It is not diagnosis or treatment advice.',
  true,
  true
),
(
  'ai_help_slider',
  'AI help slider',
  'ai_sweet_spot',
  'ai_scaffold',
  'mixed',
  'A comparison activity that tests whether low, medium, or high AI support improves output without creating dependency or overload.',
  '[{"step":1,"text":"Choose one low-risk task."},{"step":2,"text":"Complete a short attempt with low AI help."},{"step":3,"text":"Repeat with medium or higher scaffolded help."},{"step":4,"text":"Compare output quality, effort, independence, confidence, and fatigue."}]'::jsonb,
  array['ai_support_tolerance'],
  'trained_support_worker_or_practitioner',
  'This activity explores support preference and cognitive load only. It is not clinical assessment or treatment advice.',
  true,
  true
),
(
  'morning_launch_board',
  'Morning launch board',
  'executive_function',
  'routine',
  'parent_carer',
  'A simple visual morning routine board that reduces repeated prompting and tracks launch friction.',
  '[{"step":1,"text":"List three to five morning actions in visible order."},{"step":2,"text":"Let the person mark each action as started or done."},{"step":3,"text":"Use one neutral prompt only when stuck."},{"step":4,"text":"Record where the routine stalled and what helped movement resume."}]'::jsonb,
  array['task_start_latency','regulation_recovery_time'],
  'parent_carer_or_trained_support_worker',
  'This activity supports routine building only. It is not diagnosis or treatment advice.',
  true,
  true
),
(
  'choice_pair_reset',
  'Choice-pair reset',
  'emotional_regulation',
  'routine',
  'mixed',
  'A low-pressure choice routine that helps restore agency when a person feels stuck, overloaded, or oppositional.',
  '[{"step":1,"text":"Offer two acceptable choices, both safe and realistic."},{"step":2,"text":"Avoid adding extra explanation or persuasion."},{"step":3,"text":"Let the person choose or request a short pause."},{"step":4,"text":"Record whether choice reduced friction and helped re-engagement."}]'::jsonb,
  array['regulation_recovery_time','task_start_latency'],
  'parent_carer_or_trained_support_worker',
  'This activity supports agency and re-engagement only. It is not behavioural therapy, diagnosis, or treatment advice.',
  true,
  true
),
(
  'five_point_transition_bridge',
  'Five-point transition bridge',
  'attention_regulation',
  'routine',
  'mixed',
  'A transition support routine for moving from one activity, place, or demand to another with less friction.',
  '[{"step":1,"text":"Name the current activity."},{"step":2,"text":"Name the next activity."},{"step":3,"text":"Give a clear time or event cue."},{"step":4,"text":"Choose one bridge action such as pack up, stand up, move object, or check list."},{"step":5,"text":"Record whether the transition was smooth, delayed, distressed, or incomplete."}]'::jsonb,
  array['focus_recovery_time','regulation_recovery_time'],
  'parent_carer_teacher_or_trained_support_worker',
  'This activity supports transitions only. It is not diagnosis or treatment advice.',
  true,
  true
)
on conflict (activity_key) do update set
  activity_name = excluded.activity_name,
  domain_key = excluded.domain_key,
  activity_type = excluded.activity_type,
  audience = excluded.audience,
  description = excluded.description,
  steps = excluded.steps,
  outcome_markers = excluded.outcome_markers,
  minimum_review_role = excluded.minimum_review_role,
  safety_boundary = excluded.safety_boundary,
  resale_ready = excluded.resale_ready,
  active = excluded.active,
  updated_at = now();

insert into public.or_reality_ledger (event_key, event_type, object_ref, claim, evidence, classification)
values
(
  'or-activity-seed-pack-10-more-20260429',
  'seed_package',
  'outcome_ready_activity_library',
  'Ten additional non-diagnostic functional support activities created for the Outcome Ready NeuroProfile Activity Engine.',
  jsonb_build_object(
    'repo','TML-4PM/the-pen',
    'path','bridge_jobs/outcome_ready_activity_seed_pack_10_more_20260429.sql',
    'activity_count',10,
    'boundary','Functional support only; not diagnosis, treatment advice, or prescribing.'
  ),
  'PARTIAL'
)
on conflict (event_key) do update set
  claim = excluded.claim,
  evidence = excluded.evidence,
  classification = excluded.classification;
