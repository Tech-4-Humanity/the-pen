# T4H Repository Preload Guide

**Status:** REAL — operational guide

## Purpose

Define the canonical repository preload and navigation model for Mac and EC2. GitHub is the canonical source. Local checkouts are working copies, not independent sources of truth.

## Core repositories

| Command | Repository | Purpose | Preload |
|---|---|---|---|
| `repo runtime-real` | `TML-4PM/runtime-real` | Canonical portable execution kernel: worker lifecycle, claims, retries, receipts and replay | Mac + EC2 |
| `repo the-pen` | `TML-4PM/the-pen` | Governance and control repository: policies, contracts, schemas and evidence rules | Mac + EC2 |
| `repo control-plane` | `TML-4PM/t4h-engineering-control-plane` | Estate-level coordination: event gateway, worker registry, recovery, sweep and executive-worker control | Mac + EC2 |
| `repo mcp` | `TML-4PM/t4h-remote-mcp-server-clean` | Governed connection layer for GitHub, AWS, Supabase, Vercel, Drive and other services | Mac + runtime host |
| `repo bridge` | `TML-4PM/bridge-worker-intake` | Intake and transport bridge between requests, workers and execution systems | Mac + runtime host |

## Conditional repositories

| Command | Repository | Purpose | Preload |
|---|---|---|---|
| `repo command-centre` | `TML-4PM/mcp-command-centre` | Operator interface and command/control application | Mac; EC2 only if hosted there |
| `repo synal-core` | Current Synal Core repository / EC2 checkout | Earlier/broader Synal runtime and integration layer | On demand; EC2 checkout currently at `~/my-project` |
| `repo loop-runtime` | `T4H001/new-account-loop-engineering-runtime` | Alternate-account GitHub Actions runtime experiment | Mac on demand; not EC2 |
| `repo research-hub` | `TML-4PM/t4h-research-hub` | Research, Work Intelligence Estate and Atlas-related engineering | Mac; EC2 only for active workers |

## Worker clarification

`monitoring-repair-worker` and `estate-sweep-worker` are **not standalone repositories**.

- `monitoring-repair-worker` → `WKR-RECOVER-001` in `TML-4PM/t4h-engineering-control-plane`
- `estate-sweep-worker` → `WKR-SWEEP-001` in `TML-4PM/t4h-engineering-control-plane`

They are currently worker definitions/specifications and must not be represented as separate repository preload entries unless a canonical repository is subsequently created and receipted.

## Machine rule

### Mac

Use Mac copies to:

- inspect and edit source;
- create branches and commits;
- run development tests;
- review changes before deployment;
- perform emergency recovery.

The Mac is not automatically production.

### EC2

Use EC2 copies to:

- execute workers;
- run services and scheduled jobs;
- perform runtime validation;
- emit receipts, ledger entries and telemetry;
- recover work blocked by GitHub-hosted Actions.

Do not conduct unrelated product development directly in EC2 runtime checkouts.

## Standard operating sequence

```text
Mac: edit → test → commit → push
GitHub: canonical source and change ledger
EC2: pull approved revision → execute → validate → receipt
```

## Command behaviour

`repo <name>` only navigates to a checkout on the **current machine**. It never connects to another machine.

On the Mac:

```text
ec2
```

connects to the configured EC2 host and opens the normal runtime shell at `~/my-project`.

Once inside EC2:

```text
repo runtime-real
repo the-pen
repo control-plane
repo mcp
repo bridge
repo synal-core
```

navigate locally.

`repo status` reports whether the expected preload checkouts are actually present. `REAL` means the checkout exists and is a Git repository; `MISSING` means it does not. Missing state must not be inferred as ready.

## Preload policy

Preload a repository only when it is:

- actively edited on that machine;
- required by a live runtime;
- necessary for deployment or recovery; or
- part of the canonical control plane.

Everything else should be cloned on demand.

## Current receipted preload

### Mac — RECEIPTED 2026-08-08

Fresh Mac `repo status` receipt:

```text
REAL     runtime-real
REAL     the-pen
REAL     t4h-engineering-control-plane
REAL     t4h-remote-mcp-server-clean
REAL     bridge-worker-intake
REAL     mcp-command-centre
MISSING  t4h-research-hub
```

The five required core repositories are therefore **REAL on Mac**. `mcp-command-centre` is also present. `t4h-research-hub` remains an optional/conditional repository and is not a core preload gap.

### EC2 — RECEIPTED 2026-08-08

Fresh EC2 preload receipt:

```text
REAL     runtime-real
REAL     the-pen
REAL     t4h-engineering-control-plane
REAL     t4h-remote-mcp-server-clean
REAL     bridge-worker-intake
```

Synal Core is also available through the existing EC2 checkout:

```text
~/my-project
```

## Truth and recovery rule

Repository presence is validated from the machine runtime, not from memory. A shortcut is useful only when its target is verified. If a checkout is missing, stale, corrupted or otherwise unresolved, classify it as PARTIAL or BLOCKED and recover by clone, pull, repair or reroute as appropriate.

## Shell navigation standard

The preferred operator experience is deliberately minimal:

```text
Mac:
ec2

EC2:
repo runtime-real
repo the-pen
repo control-plane
repo mcp
repo bridge
repo synal-core
```

Do not require operators to remember EC2 IP addresses, SSH syntax, repository filesystem paths or long `cd` commands for normal navigation.

The `ec2` shortcut is an SSH convenience only; it does not itself prove application health, deployment state or worker readiness. Those states require their own runtime receipts and telemetry.
