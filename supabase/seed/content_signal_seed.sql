-- ============================================================================
-- Content Signal OS — Seed Data
-- Derived from CONTENT_SIGNAL_HOUSE_RULES.md (Voice/POV + Platform Expansion).
-- Idempotent: keyed upserts only. Safe to re-run.
-- ============================================================================

insert into content_signal.brand_voice_registry
  (voice_key, speaker, business, audience, tone, default_footer, channels)
values
  ('troy_innovateme','Troy','InnovateMe','executives + founders','executive, future-facing, provocative but grounded',null,'["linkedin"]'::jsonb),
  ('tech4humanity','Tech 4 Humanity','Tech 4 Humanity','policy + public','ethical, human-centred, policy-aware',null,'["linkedin"]'::jsonb),
  ('ahc','AHC','AHC','organisational leaders','practical augmentation, organisational transformation, capability uplift',null,'["linkedin"]'::jsonb),
  ('gcbat','GC-BAT','GC-BAT','standards + governance bodies','governance, neurotechnology, standards, societal risk',null,'["linkedin"]'::jsonb),
  ('emerging_tech','Emerging Tech','Emerging Tech','frontier builders','exploratory, opportunity-driven, frontier signals',null,'["linkedin"]'::jsonb)
on conflict (voice_key) do update set speaker=excluded.speaker, business=excluded.business, audience=excluded.audience, tone=excluded.tone, channels=excluded.channels;

insert into content_signal.point_of_view_registry (pov_key, business, stance, description)
values
  ('t4h_consent','Tech 4 Humanity','human-centred governance','AI systems must respect consent, signal boundaries, and human agency'),
  ('innovateme_exec','InnovateMe','executive provocation','name the uncomfortable truth before competitors do'),
  ('gcbat_standards','GC-BAT','standards-first','neurotech and BCI require governance ahead of deployment')
on conflict (pov_key) do update set business=excluded.business, stance=excluded.stance, description=excluded.description;

insert into content_signal.platform_registry (platform_key, name, is_primary, status)
values
  ('linkedin','LinkedIn',true,'active'),('instagram','Instagram',false,'planned'),
  ('tiktok','TikTok',false,'planned'),('youtube','YouTube',false,'planned'),
  ('newsletter','Newsletter',false,'planned'),('website','Website',false,'planned'),
  ('medium','Medium',false,'planned'),('podcast','Podcast',false,'planned')
on conflict (platform_key) do update set name=excluded.name, is_primary=excluded.is_primary, status=excluded.status;

insert into content_signal.platform_format_rule (platform_id, format_key, max_length, cadence, approval_required)
select p.id, v.format_key, v.max_length, v.cadence, true
from content_signal.platform_registry p
join (values ('short',1300,'as-signalled'),('normal',3000,'as-signalled'),('long',8000,'weekly'),('extra_long',15000,'biweekly'),('essay',40000,'monthly')) as v(format_key,max_length,cadence) on true
where p.platform_key='linkedin'
on conflict (platform_id, format_key) do update set max_length=excluded.max_length, cadence=excluded.cadence;

insert into content_signal.image_style_registry (style_key, description, constraints)
values ('t4h_default','Clean, human-centred, restrained palette; no stock-AI cliche','{"no_text_in_image": true, "aspect": "1.91:1"}'::jsonb)
on conflict (style_key) do update set description=excluded.description, constraints=excluded.constraints;
