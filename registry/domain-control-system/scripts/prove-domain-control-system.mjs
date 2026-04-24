import fetch from 'node-fetch';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

async function q(path) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    }
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

async function main() {
  const total = await q('registry.aws_hosted_zone_registry?select=count');
  const attention = await q('registry.v_aws_hosted_zone_registry_attention?select=normalized_domain,canonical_status,domain_status');

  console.log('TOTAL_ROWS', total);
  console.log('ATTENTION_SAMPLE', attention.slice(0, 10));

  if (!total) throw new Error('No rows found');
  console.log('PASS');
}

main().catch((e) => {
  console.error('FAIL', e);
  process.exit(1);
});
