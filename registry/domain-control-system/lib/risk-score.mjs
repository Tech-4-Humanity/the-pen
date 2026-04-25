export function scoreDomain(row = {}) {
  let score = 0;
  const reasons = [];
  const add = (points, reason) => { score += points; reasons.push(reason); };

  if (row.canonical_status === 'kill') add(40, 'marked kill/non-canonical');
  if (row.canonical_status === 'unknown') add(25, 'unknown canonical status');
  if (row.canonical_status === 'candidate') add(15, 'candidate not confirmed');
  if (row.domain_status === 'inactive') add(35, 'inactive domain');
  if (row.domain_status === 'expired') add(45, 'expired domain');
  if (row.domain_status === 'unknown') add(20, 'unknown runtime status');
  if (row.reality_state !== 'REAL') add(20, 'not REAL in Reality Ledger classification');
  if ((row.record_count || 0) <= 4) add(10, 'low DNS record count');
  if ((row.notes || '').toLowerCase().includes('ssl_valid_to=n/a')) add(10, 'no SSL evidence');
  if ((row.notes || '').toLowerCase().includes('https=fail')) add(15, 'HTTPS failed');
  if ((row.description || '').toLowerCase().includes('mail') && row.domain_status !== 'mail_only' && row.domain_status !== 'active') add(10, 'mail intent unclear');

  score = Math.min(100, score);
  const band = score >= 70 ? 'critical' : score >= 45 ? 'high' : score >= 20 ? 'medium' : 'low';
  return { score, band, reasons };
}

export function enrichDomains(rows = []) {
  return rows.map(row => ({ ...row, risk: scoreDomain(row) }));
}
