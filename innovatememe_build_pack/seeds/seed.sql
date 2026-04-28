insert into innovateme_story (story_id, title, buyer_type, pain_statement, story_archetype, pilot_duration, indicative_price_band)
values
('policy_backlog','Policy Backlog Collapse','Policy Lead','Backlog and burnout','speed','2 weeks','$25K-$60K'),
('ai_control','Controlled AI Deployment','CIO','AI blocked by risk','risk','3 weeks','$40K-$80K');

insert into innovateme_pilot_offer (offer_key, name, level, price_min_aud, price_max_aud)
values
('workshop','Scenario Workshop',1,7500,15000),
('pilot','Controlled Pilot',3,75000,250000);
