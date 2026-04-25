import { enrichDomains } from '../lib/risk-score.mjs';
import fetch from 'node-fetch';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/registry.v_aws_hosted_zone_registry_active?select=*`, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    }
  });

  const data = enrichDomains(await r.json());

  const html = `
  <html>
    <body style="font-family:sans-serif; padding:40px;">
      <h1>Domain Audit Report</h1>
      <p>Generated: ${new Date().toISOString()}</p>
      <table border="1" cellpadding="6" cellspacing="0">
        <tr><th>Domain</th><th>Status</th><th>Risk</th></tr>
        ${data.map(d=>`<tr><td>${d.normalized_domain}</td><td>${d.domain_status}</td><td>${d.risk.score} (${d.risk.band})</td></tr>`).join('')}
      </table>
    </body>
  </html>`;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
}
