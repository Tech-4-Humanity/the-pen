import { Route53Client, ListHostedZonesCommand } from '@aws-sdk/client-route-53';

const route53 = new Route53Client({});

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const TABLE = 'registry.aws_hosted_zone_registry';

function normalizeDomain(name) {
  return String(name || '').trim().replace(/\.$/, '').toLowerCase();
}

async function supabaseUpsert(rows) {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  }

  const res = await fetch(`${SUPABASE_URL}/rest/v1/${TABLE}?on_conflict=hosted_zone_id`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=representation'
    },
    body: JSON.stringify(rows)
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Supabase upsert failed: ${res.status} ${text}`);
  }

  return res.json();
}

export const handler = async (event = {}) => {
  const evidenceRef = event.evidence_ref || `route53-sync-${new Date().toISOString()}`;
  const hostedZones = [];
  let Marker;

  do {
    const response = await route53.send(new ListHostedZonesCommand(Marker ? { Marker } : {}));
    hostedZones.push(...(response.HostedZones || []));
    Marker = response.IsTruncated ? response.NextMarker : undefined;
  } while (Marker);

  const rows = hostedZones.map((z) => ({
    hosted_zone_name: normalizeDomain(z.Name),
    zone_type: z.Config?.PrivateZone ? 'Private' : 'Public',
    created_by: 'Route 53',
    record_count: z.ResourceRecordSetCount || 0,
    description: z.Config?.Comment || null,
    hosted_zone_id: String(z.Id || '').replace('/hostedzone/', ''),
    aws_service: 'Route 53',
    aws_region: 'global',
    canonical_status: 'observed',
    domain_status: 'unknown',
    evidence_source: 'aws_route53_api',
    evidence_ref: evidenceRef,
    reality_state: 'PARTIAL',
    last_verified_at: new Date().toISOString(),
    notes: 'Synced from AWS Route 53 API'
  }));

  const result = rows.length ? await supabaseUpsert(rows) : [];

  return {
    status: 'ok',
    synced_count: rows.length,
    evidence_ref: evidenceRef,
    sample: result.slice(0, 5)
  };
};
