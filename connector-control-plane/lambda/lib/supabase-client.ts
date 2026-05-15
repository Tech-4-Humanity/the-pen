import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const sm = new SecretsManagerClient({});
let cached: { url: string; key: string } | null = null;

export async function getSupabase(): Promise<{ url: string; key: string }> {
  if (cached) return cached;
  const arn = process.env.CCP_SUPABASE_SECRET_ARN;
  if (!arn) throw new Error('CCP_SUPABASE_SECRET_ARN not set');
  const res = await sm.send(new GetSecretValueCommand({ SecretId: arn }));
  if (!res.SecretString) throw new Error('Supabase secret has no SecretString');
  cached = JSON.parse(res.SecretString) as { url: string; key: string };
  return cached;
}

export async function pgInsert(table: string, row: Record<string, unknown>): Promise<void> {
  const { url, key } = await getSupabase();
  const res = await fetch(`${url}/rest/v1/${table}`, {
    method: 'POST',
    headers: {
      'apikey': key,
      'authorization': `Bearer ${key}`,
      'content-type': 'application/json',
      'prefer': 'return=minimal',
    },
    body: JSON.stringify(row),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`pgInsert ${table} failed: ${res.status} ${body}`);
  }
}

export async function pgSelect<T = unknown>(table: string, qs: string): Promise<T[]> {
  const { url, key } = await getSupabase();
  const res = await fetch(`${url}/rest/v1/${table}?${qs}`, {
    headers: { 'apikey': key, 'authorization': `Bearer ${key}` },
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`pgSelect ${table} failed: ${res.status} ${body}`);
  }
  return res.json() as Promise<T[]>;
}
