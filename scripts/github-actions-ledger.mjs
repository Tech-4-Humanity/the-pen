#!/usr/bin/env node
/**
 * GitHub Actions Operating Ledger v1.1
 *
 * Source: TML-4PM/the-pen#138
 *
 * Collects GitHub Actions metadata across target repos and emits a daily report.
 * Hardened 2026-06-28:
 * - TML-4PM is a user account, not always an org. Repo discovery now supports orgs and users.
 * - TARGET_REPOS may be repo names or owner/name full names.
 * - Repo/API failures are recorded in the report instead of killing the workflow.
 */

import fs from 'node:fs';
import path from 'node:path';

const GITHUB_TOKEN = process.env.GITHUB_TOKEN || process.env.GH_PAT;
if (!GITHUB_TOKEN) {
  console.error('FATAL: GITHUB_TOKEN or GH_PAT required');
  process.exit(2);
}

const OWNER = process.env.GITHUB_OWNER || 'TML-4PM';
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
const NOW = new Date();
const SINCE = new Date(NOW.getTime() - ONE_DAY_MS).toISOString();

async function gh(url) {
  const r = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${GITHUB_TOKEN}`,
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'github-ops-ledger/1.1',
      'X-GitHub-Api-Version': '2022-11-28',
    },
  });
  if (!r.ok) throw new Error(`GH ${r.status}: ${url}`);
  return r.json();
}

function normaliseRepoName(repo) {
  const trimmed = String(repo || '').trim();
  if (!trimmed) return null;
  return trimmed.includes('/') ? trimmed : `${OWNER}/${trimmed}`;
}

async function discoverOwnerRepos() {
  const repos = [];
  const endpoints = [
    `https://api.github.com/orgs/${OWNER}/repos?type=all&per_page=100`,
    `https://api.github.com/users/${OWNER}/repos?type=all&per_page=100`,
  ];

  let lastError = null;
  for (const base of endpoints) {
    try {
      let page = 1;
      while (true) {
        const data = await gh(`${base}&page=${page}`);
        repos.push(...data.map(r => r.full_name || `${OWNER}/${r.name}`));
        if (data.length < 100) break;
        page++;
      }
      if (repos.length) return [...new Set(repos)].sort();
    } catch (e) {
      lastError = e;
      repos.length = 0;
    }
  }

  throw lastError || new Error(`No repositories discovered for ${OWNER}`);
}

async function getTargetRepos() {
  if (process.env.TARGET_REPOS && process.env.TARGET_REPOS.trim()) {
    return process.env.TARGET_REPOS.split(',').map(normaliseRepoName).filter(Boolean);
  }
  return discoverOwnerRepos();
}

async function repoSummary(full) {
  const summary = { repo: full };

  try {
    const runs = await gh(`https://api.github.com/repos/${full}/actions/runs?per_page=50`);
    const recent = (runs.workflow_runs || []).filter(r => new Date(r.created_at) > new Date(SINCE));
    summary.runs_24h = recent.length;
    summary.runs_failed_24h = recent.filter(r => r.conclusion === 'failure').length;
    summary.runs_cancelled_24h = recent.filter(r => r.conclusion === 'cancelled').length;

    const issues_open = await gh(`https://api.github.com/search/issues?q=is:issue+is:open+repo:${full}&per_page=1`);
    summary.open_issues = issues_open.total_count || 0;
    const closed_recent = await gh(`https://api.github.com/search/issues?q=is:issue+is:closed+repo:${full}+closed:>${SINCE}&per_page=1`);
    summary.closed_issues_24h = closed_recent.total_count || 0;

    const prs_open = await gh(`https://api.github.com/search/issues?q=is:pr+is:open+repo:${full}&per_page=1`);
    summary.open_prs = prs_open.total_count || 0;
  } catch (e) {
    summary.error = e.message;
  }
  return summary;
}

function renderMarkdown(reports) {
  const ts = NOW.toISOString();
  let md = `# GitHub Ops Report — ${ts.split('T')[0]}\n\n`;
  md += `**Generated:** ${ts}\n`;
  md += `**Owner:** ${OWNER}\n`;
  md += `**Repos scanned:** ${reports.length}\n\n`;

  const totals = reports.reduce((acc, r) => {
    acc.runs += r.runs_24h || 0;
    acc.failed += r.runs_failed_24h || 0;
    acc.cancelled += r.runs_cancelled_24h || 0;
    acc.open_issues += r.open_issues || 0;
    acc.closed_24h += r.closed_issues_24h || 0;
    acc.open_prs += r.open_prs || 0;
    acc.errors += r.error ? 1 : 0;
    return acc;
  }, {runs:0, failed:0, cancelled:0, open_issues:0, closed_24h:0, open_prs:0, errors:0});

  md += `## Totals (last 24h)\n\n`;
  md += `| Metric | Count |\n|---|---|\n`;
  md += `| Workflow runs | ${totals.runs} |\n`;
  md += `| Failed runs | ${totals.failed} |\n`;
  md += `| Cancelled runs | ${totals.cancelled} |\n`;
  md += `| Open issues | ${totals.open_issues} |\n`;
  md += `| Issues closed 24h | ${totals.closed_24h} |\n`;
  md += `| Open PRs | ${totals.open_prs} |\n`;
  md += `| Repo scan errors | ${totals.errors} |\n\n`;

  md += `## Per-repo\n\n`;
  md += `| Repo | Runs 24h | Failed | Cancelled | Open Issues | Closed 24h | Open PRs | Notes |\n`;
  md += `|---|---|---|---|---|---|---|---|\n`;
  for (const r of reports.sort((a,b) => (b.runs_24h||0) - (a.runs_24h||0))) {
    const note = String(r.error || '').replaceAll('|', '\\|');
    md += `| ${r.repo} | ${r.runs_24h||0} | ${r.runs_failed_24h||0} | ${r.runs_cancelled_24h||0} | ${r.open_issues||0} | ${r.closed_issues_24h||0} | ${r.open_prs||0} | ${note} |\n`;
  }

  md += `\n## Receipts\n\n`;
  md += `- Workflow run URL is emitted by GitHub Actions runtime.\n`;
  md += `- Runtime receipt is written by .github/workflows/github-ops-report.yml.\n`;

  return md;
}

async function main() {
  console.log(`[ledger] Starting GitHub Actions Operating Ledger run at ${NOW.toISOString()}`);
  const repos = await getTargetRepos();
  console.log(`[ledger] Scanning ${repos.length} repos for owner ${OWNER}`);

  const reports = [];
  for (const repo of repos) {
    process.stdout.write(`  ${repo}... `);
    const s = await repoSummary(repo);
    reports.push(s);
    console.log(s.error ? `ERR: ${s.error}` : `runs=${s.runs_24h}`);
  }

  const md = renderMarkdown(reports);
  const outDir = 'reports/github-ops';
  fs.mkdirSync(outDir, { recursive: true });
  const outFile = path.join(outDir, `${NOW.toISOString().split('T')[0]}.md`);
  fs.writeFileSync(outFile, md);
  console.log(`[ledger] Report written: ${outFile} (${md.length} chars)`);

  fs.writeFileSync(outFile.replace('.md', '.json'), JSON.stringify({
    timestamp: NOW.toISOString(),
    owner: OWNER,
    repos: repos.length,
    reports
  }, null, 2));
  console.log(`[ledger] JSON written: ${outFile.replace('.md','.json')}`);
}

main().catch(e => {
  console.error('FATAL:', e);
  process.exit(1);
});
