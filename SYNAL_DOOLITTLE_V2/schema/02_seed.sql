-- Seed canonical parties
insert into doolittle.parties (party_key, display_name, party_type, provider, model, can_execute) values
('human', 'Human Operator', 'human', null, null, false),
('doolittle', 'Doolittle Translator', 'translator', null, null, false),
('croux-g', 'CROUX-G', 'llm', 'openai', 'openai/gpt-5', false),
('croux-c', 'CROUX-C', 'llm', 'anthropic', 'anthropic/claude-opus-4-7', false),
('croux-x', 'CROUX-X', 'llm', 'xai', 'xai/grok-4', false),
('croux-p', 'CROUX-P', 'llm', 'perplexity', 'perplexity/sonar-pro', false),
('f-coax', 'Federated COAX', 'control', null, null, true),
('animal', 'Animal Signal', 'subject', null, null, false),
('device', 'Device / Sensor', 'subject', null, null, false),
('system', 'System', 'system', null, null, false),
('external', 'External Party', 'external', null, null, false),
('bridge', 'T4H Bridge', 'execution', 't4h', 'zdgnab3py0', true)
on conflict (party_key) do update set
  display_name = excluded.display_name,
  party_type = excluded.party_type,
  provider = excluded.provider,
  model = excluded.model,
  can_execute = excluded.can_execute;

-- Default sovereign tenant
insert into doolittle.tenants (slug, name, product_name, plan)
values ('t4h-default', 'Tech 4 Humanity', 'Synal Doolittle', 'sovereign')
on conflict (slug) do nothing;

insert into doolittle.tenant_limits (tenant_id, max_spaces, max_threads, max_parties, monthly_model_budget, export_enabled, proof_mode_enabled)
select id, 999, 9999, 50, 10000, true, true from doolittle.tenants where slug = 't4h-default'
on conflict do nothing;

-- Default spaces
insert into doolittle.project_spaces (tenant_id, slug, name, purpose)
select id, 'doolittle-live', 'Doolittle Live', 'Animal, device, human, agent translation experiments' from doolittle.tenants where slug = 't4h-default'
on conflict (tenant_id, slug) do nothing;

insert into doolittle.project_spaces (tenant_id, slug, name, purpose)
select id, 'coax-control', 'COAX Control', 'CROUX/Federated COAX routing + executive control' from doolittle.tenants where slug = 't4h-default'
on conflict (tenant_id, slug) do nothing;

insert into doolittle.project_spaces (tenant_id, slug, name, purpose)
select id, 'agent-channel', 'Agent Channel', 'General multi-agent channel testing' from doolittle.tenants where slug = 't4h-default'
on conflict (tenant_id, slug) do nothing;
