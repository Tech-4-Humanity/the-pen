# GitHub Actions Runner Allocation — Self-Hosted Alternative

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL — implementation published; runner registration/execution pending

## Decision

GitHub-hosted runner allocation is no longer the sole execution dependency. CalmBound CI has been routed to a dedicated repository-level self-hosted runner on the existing T4H bridge host.

## Published

- Bootstrap: `ops/github-actions/bootstrap_t4h_bridge_runner.sh`
- Workflow: `.github/workflows/calmbound-runtime-ci.yml`
- Active queue job: `inbox/bootstrap-the-pen-self-hosted-runner-20260717.json`

## Workflow change

Both CalmBound jobs now target:

```yaml
runs-on: [self-hosted, linux, x64, t4h-bridge]
```

The workflow runs only on trusted `main` pushes affecting CalmBound files and manual dispatch. Pull-request execution was removed from the self-hosted path to reduce the risk of untrusted branch code running on the persistent bridge host.

## Bootstrap behaviour

The bootstrap script:

1. checks required Linux tooling and Docker;
2. obtains the current GitHub Actions runner release;
3. configures a repository-level runner with the `t4h-bridge` label;
4. installs and starts the runner as a systemd service;
5. writes a local machine-readable bootstrap receipt.

GitHub supports repository or organisation self-hosted runners, custom labels, and service installation through the runner's `svc.sh` script.

## Truth state

### REAL

- Bootstrap implementation published.
- CalmBound workflow changed from `ubuntu-latest` to the bridge runner labels.
- Active bridge queue job published.
- No production application or database was changed.

### PARTIAL

- Bridge runner registration has not yet produced a committed receipt.
- GitHub has not yet been observed listing the runner online.
- CalmBound CI has not yet started its `Runner receipt` step on the self-hosted runner.

### REAL requires

- runner systemd service active;
- runner visible online in GitHub;
- required labels present;
- at least one named workflow step started;
- CalmBound source and PostgreSQL results committed with usable logs.

## Commits

- Bootstrap: `23a7f5ff21046cd2e82271f95f4669d2fe759442`
- Workflow reroute: `c8b14306bef6e65f55668057efc9b34b23f07865`
- Active job: `391db79a3bcaff53b1b983acae4422d683536305`
