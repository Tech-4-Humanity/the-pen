import fs from 'node:fs';
import path from 'node:path';
import { ROOT, emitReceipt, requireCommand, gitRoot, gitStatus, awsIdentity, findCandidateExport } from './lib.mjs';

const checks = [];
const add = (name, ok, detail = '') => checks.push({ name, ok, detail });

const node = requireCommand('node');
add('node', node.ok, node.stdout || node.stderr);
const npm = requireCommand('npm');
add('npm', npm.ok, npm.stdout || npm.stderr);
const git = requireCommand('git');
add('git', git.ok, git.stdout || git.stderr);
const aws = requireCommand('aws');
add('aws-cli', aws.ok, aws.stdout || aws.stderr);

const root = gitRoot();
add('git-root', root === ROOT, root || 'not a git repository');
add('package-json', fs.existsSync(path.join(ROOT, 'package.json')), 'root package.json required');
add('runtime-library', fs.existsSync(path.join(ROOT, 'tools/runtime/lib.mjs')), 'shared runtime library');

const identity = aws.ok ? awsIdentity() : { ok: false, error: 'aws cli unavailable' };
add('aws-identity', identity.ok, identity.ok ? `${identity.Account} ${identity.Arn}` : identity.error);

const candidate = findCandidateExport();
add('candidate-output', Boolean(candidate), candidate || 'no deployment output found yet; bringup may create or recover it');

const hardFailures = checks.filter(c => !c.ok && !['candidate-output'].includes(c.name));
const status = hardFailures.length ? 'BLOCKED' : candidate ? 'REAL' : 'PARTIAL';
const receipt = emitReceipt('doctor', {
  classification: status,
  checks,
  git_status: gitStatus(),
  candidate_output: candidate,
  next_stage: hardFailures.length ? null : 'bringup'
});

if (hardFailures.length) process.exit(1);
