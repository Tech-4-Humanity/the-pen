-- Connector Control Plane — seed canonical connectors
-- Idempotent: safe to re-run.

begin;

insert into public.ccp_connectors
  (connector_id, name, provider, base_url, health_url, capabilities, cost_micros, priority)
values
  ('anthropic-claude', 'Anthropic Claude', 'anthropic', 'https://api.anthropic.com', 'https://status.anthropic.com/api/v2/status.json', array['llm.generate','llm.tool_use'], 3500, 10),
  ('openai-gpt',       'OpenAI GPT',       'openai',    'https://api.openai.com',    'https://status.openai.com/api/v2/status.json',    array['llm.generate','llm.tool_use'], 3000, 20),
  ('t4h-bridge-aws',   'T4H Bridge AWS',   't4h',       'https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com', null, array['aws.invoke','aws.s3','aws.lambda'], 100, 5),
  ('supabase-rest',    'Supabase REST',    'supabase',  'https://lzfgigiyqpuuxslsygjt.supabase.co', null, array['db.read','db.write','db.rpc'], 50, 5),
  ('github-api',       'GitHub API',       'github',    'https://api.github.com',    'https://www.githubstatus.com/api/v2/status.json', array['repo.read','repo.write','repo.dispatch'], 100, 10)
on conflict (connector_id) do update set
  name = excluded.name,
  provider = excluded.provider,
  base_url = excluded.base_url,
  health_url = excluded.health_url,
  capabilities = excluded.capabilities,
  cost_micros = excluded.cost_micros,
  priority = excluded.priority,
  updated_at = now();

insert into public.ccp_intents (intent_id, description, required_capability, default_cost_budget_micros)
values
  ('llm.generate',  'Generate text via an LLM connector.',        'llm.generate', 5000),
  ('aws.invoke',    'Invoke an AWS resource via the T4H bridge.', 'aws.invoke',    500),
  ('repo.dispatch', 'Dispatch files to a GitHub repository.',     'repo.dispatch', 500),
  ('db.read',       'Read from the canonical Supabase schema.',   'db.read',       200)
on conflict (intent_id) do nothing;

commit;
