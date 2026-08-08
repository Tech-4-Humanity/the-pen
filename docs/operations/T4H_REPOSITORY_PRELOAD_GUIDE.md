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

`t4h-research-hub` is explicitly out of scope for this preload model and is not a missing repository or operational gap.

## Worker clarification

`monitoring-repair-worker` and `estate-sweep-worker` are **not standalone repositories**.

- `monitoring-repair-worker` → `WKR-RECOVER-001` in `TML-4PM/t4h-engineering-control-plane`
- `estate-sweep-worker` → `WKR-SWEEP-001` in `TML-4PM/t4h-engineering-control-plane`

They are worker definitions/specifications and must not be represented as separate repository preload entries unless a canonical repository is subsequently created and receipted.

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

### Mac entry points

```text
ec2
```

Connects by SSH to the configured EC2 host and opens the normal `ubuntu` runtime shell at `~/my-project`.

```text
ec2b
```

Is the **QM/backup one-word entry point**. It automatically:

1. starts the SSM port-forward from local `localhost:18081` to the EC2 QM service on port `18081`;
2. opens the QM URL in the Mac browser when available;
3. connects by AWS SSM to the same EC2 instance;
4. switches to `ssm-user`; and
5. opens `~/qm-docker`.

The expected operator experience is therefore simply:

```text
ec2b
```

Then use:

```text
http://localhost:18081/
```

The tunnel remains alive for the duration of the `ec2b` session and is cleaned up when that session exits. If a tunnel is already listening on port `18081`, `ec2b` reuses the existing tunnel rather than creating a duplicate.

```text
qmtunnel
```

Is retained as the **low-level tunnel-only command** for cases where the browser tunnel is wanted without opening the QM SSM shell. It checks whether local port `18081` is already listening before creating another tunnel.

The normal operator surface is therefore:

```text
ec2       → normal engineering shell
ec2b      → QM / backup shell + browser tunnel
qmtunnel  → tunnel only, when explicitly needed
```

### EC2 navigation

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

### Mac — RECEIPTED 2026-08-09

Verified Mac `repo status` receipt:

```text
REAL     runtime-real
REAL     the-pen
REAL     control-plane
REAL     mcp
REAL     bridge
REAL     command-centre
```

All required Mac preload repositories are **REAL**. `t4h-research-hub` is out of scope and is not counted as a gap.

### EC2 — RECEIPTED 2026-08-08

Verified EC2 preload receipt:

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

### QM / backup access — RECEIPTED 2026-08-09

Verified Mac `ec2b` landing:

```text
ssm-user@ip-172-31-44-249:~/qm-docker$
```

Verified direct SSM port-forward:

```text
Port 18081 opened for session
Connection accepted
```

Browser endpoint:

```text
http://localhost:18081/
```

The canonical `ec2b` helper now combines these into one operator action: QM SSM shell + tunnel. The low-level `qmtunnel` command remains available separately.

## Truth and recovery rule

Repository presence and shortcut operation are validated from machine runtime, not from memory. A shortcut is useful only when its target is verified. If a checkout is missing, stale, corrupted or otherwise unresolved, classify it as PARTIAL or BLOCKED and recover by clone, pull, repair or reroute as appropriate.

A shell helper update in GitHub is not automatically installed on Mac or EC2. Each machine must pull/source the canonical helper before the new command becomes REAL there.

## Shell navigation standard

The preferred operator experience is deliberately minimal:

```text
Mac:
ec2
ec2b

EC2:
repo runtime-real
repo the-pen
repo control-plane
repo mcp
repo bridge
repo synal-core
```

Do not require operators to remember EC2 IP addresses, SSH syntax, SSM syntax, repository filesystem paths or long `cd` commands for normal navigation.

The `ec2`, `ec2b` and `qmtunnel` shortcuts are convenience entry points only; they do not themselves prove application health, deployment state, worker readiness or QM health. Those states require their own runtime receipts and telemetry.
