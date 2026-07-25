import fs from 'node:fs';
import path from 'node:path';
import { ROOT, emitReceipt, findCandidateExport, run, writeJSON, STATE_PATH } from './lib.mjs';

const actions = [];
const record = (name, ok, detail = '') => actions.push({ name, ok, detail });

fs.mkdirSync(path.join(ROOT, '.runtime/receipts'), { recursive: true });
record('runtime-directories', true, '.runtime/receipts');

let output = process.env.T4H_DEPLOY_SOURCE || findCandidateExport();
if (!output) {
  const issueDir = path.join(ROOT, 'runtime/issue-267/fy2425-fresh-export');
  fs.mkdirSync(issueDir, { recursive: true });
  fs.writeFileSync(path.join(issueDir, '.gitkeep'), '');
  output = issueDir;
  record('create-output-directory', true, output);
} else {
  record('discover-output-directory', true, output);
}

const requiredIssue267 = [
  'fy2425_fresh_account_summary.csv',
  'fy2425_fresh_source_file_inventory.csv',
  'fy2425_fresh_transactions.csv',
  'fy2425_statement_period_coverage.csv',
  'fy2425_balance_reconciliation.csv',
  'fy2425_transfer_pairs.csv',
  'fy2425_amex_repayment_pairs.csv',
  'fy2425_refund_reversals.csv',
  'fy2425_supplier_normalisation.csv',
  'fy2425_cost_discovery_register.csv',
  'fy2425_director_funded_candidates.csv',
  'fy2425_excluded_movements.csv',
  'fy2425_fresh_export_receipt.json'
];

const issue267Mode = output.includes('issue-267');
const present = requiredIssue267.filter(name => fs.existsSync(path.join(output, name)));
const missing = issue267Mode ? requiredIssue267.filter(name => !fs.existsSync(path.join(output, name))) : [];

const awsBuckets = run('aws', ['s3api', 'list-buckets', '--query', 'Buckets[].Name', '--output', 'json']);
record('s3-inventory', awsBuckets.ok, awsBuckets.ok ? awsBuckets.stdout : awsBuckets.stderr);
const cloudfront = run('aws', ['cloudfront', 'list-distributions', '--query', 'DistributionList.Items[].{Id:Id,DomainName:DomainName,Origins:Origins.Items[].DomainName}', '--output', 'json']);
record('cloudfront-inventory', cloudfront.ok, cloudfront.ok ? cloudfront.stdout : cloudfront.stderr);

const state = {
  output,
  issue267Mode,
  requiredIssue267,
  present,
  missing,
  archiveBucket: process.env.T4H_ARCHIVE_BUCKET || 't4h-archive-140548542136',
  archivePrefix: process.env.T4H_ARCHIVE_PREFIX || 'fy2425/non-labour/issue-267',
  websiteBucket: process.env.T4H_WEBSITE_BUCKET || null,
  cloudfrontDistribution: process.env.T4H_CLOUDFRONT_DISTRIBUTION || null,
  liveUrl: process.env.T4H_LIVE_URL || null
};
writeJSON(STATE_PATH, state);

const classification = actions.some(a => !a.ok) ? 'BLOCKED' : missing.length ? 'PARTIAL' : 'REAL';
emitReceipt('bringup', {
  classification,
  actions,
  state,
  next_stage: classification === 'BLOCKED' ? null : 'runtime:auto-advance'
});

if (classification === 'BLOCKED') process.exit(1);
