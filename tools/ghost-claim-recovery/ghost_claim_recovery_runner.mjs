#!/usr/bin/env node

/**
 * Ghost Claim Recovery Runner
 *
 * Scans repos, finds bridge/MCP/orchestrator claims, reconstructs topic identity,
 * classifies status, and outputs rehome/replay actions.
 */

import fs from 'fs';

const ROUTE_MAP = [
  { match: /the-pen\/inbox\//, target: 'PEN_QUEUE' },
  { match: /the-pen\/handoffs\//, target: 'PEN_HANDOFF' },
  { match: /mcp-command-centre\/handoffs\//, target: 'MCP_COMMAND' },
  { match: /mcp-command-centre\/WIP\//, target: 'WIP' },
  { match: /bridge-runner\/payloads\//, target: 'BRIDGE_RUNNER' },
  { match: /bridge_runner\/inbox\//, target: 'BRIDGE_RUNNER_OLD' },
  { match: /symbio-dev-control-plane\//, target: 'DEV' },
  { match: /symbio-synapse-ops\//, target: 'PROD' },
  { match: /claude-outputs\//, target: 'AGENT_OUTPUT' }
];

function deriveTopicSlug(path) {
  const parts = path.split('/');
  return parts.slice(-1)[0].replace(/\.[^/.]+$/, '');
}

function classify(file) {
  let target = 'UNKNOWN';
  for (const route of ROUTE_MAP) {
    if (route.match.test(file.path)) {
      target = route.target;
      break;
    }
  }

  return {
    topic_slug: deriveTopicSlug(file.path),
    route_target: target
  };
}

function recoveryDecision(classification) {
  switch (classification.route_target) {
    case 'PEN_QUEUE':
      return { action: 'REPLAY_SAFE', rehome: 'PEN' };
    case 'PEN_HANDOFF':
      return { action: 'REHOME_TO_PEN', rehome: 'PEN' };
    case 'MCP_COMMAND':
      return { action: 'REHOME_TO_MCP_COMMAND', rehome: 'MCP' };
    case 'BRIDGE_RUNNER':
      return { action: 'REPLAY_SAFE', rehome: 'BRIDGE_RUNNER' };
    case 'DEV':
      return { action: 'REHOME_TO_DEV', rehome: 'DEV' };
    case 'PROD':
      return { action: 'REHOME_TO_PROD', rehome: 'PROD' };
    case 'AGENT_OUTPUT':
      return { action: 'REHOME_TO_PEN', rehome: 'PEN' };
    default:
      return { action: 'REGISTER_ONLY', rehome: 'UNKNOWN' };
  }
}

function run(files) {
  const results = [];

  for (const file of files) {
    const classification = classify(file);
    const recovery = recoveryDecision(classification);

    results.push({
      path: file.path,
      repo: file.repo,
      topic_slug: classification.topic_slug,
      route_target: classification.route_target,
      recovery_action: recovery.action,
      rehome_target: recovery.rehome
    });
  }

  return results;
}

// Example usage placeholder
if (process.argv[2] === '--example') {
  const sample = [
    { repo: 'TML-4PM/the-pen', path: 'the-pen/inbox/direct-bridge-invoke-012.json' },
    { repo: 'TML-4PM/mcp-command-centre', path: 'mcp-command-centre/handoffs/gdrive-gmail-cleanup-2026-04-29.json' }
  ];

  console.log(JSON.stringify(run(sample), null, 2));
}
