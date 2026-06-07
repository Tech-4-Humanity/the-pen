# Agent Infrastructure Intake Gate — Research Pack

Date: 2026-06-07
Owner: Troy Latter / Tech 4 Humanity
Status: PARTIAL

## Purpose

This pack converts the weekly high-signal GitHub repo scan into a reusable intake gate for AI agent infrastructure, MCP servers, browser execution planes, local runtimes, security scanners, replay tools, and repo-to-tool generation systems.

The key decision is simple:

> Do not build another agent shell. Build the gate that decides which agents, MCP servers, runtimes, and tools are safe enough to use.

## Current execution result

The discovery pass identified five repos worth attention from the week ending 2026-06-07. GitHub connector inspection confirmed the repos are public and accessible. Local sandbox clone/run was attempted and failed because the sandbox could not resolve `github.com`. That means runtime claims remain unproven and this pack is deliberately marked PARTIAL, not REAL.

## Candidate ranking

| Rank | Repo | Decision | Primitive | Current evidence |
|---:|---|---|---|---|
| 1 | `axocoatl/axocoatl` | RUN when networked runner is available | Persistent Rust multi-agent runtime with checkpoint/recovery pattern | README + public GitHub metadata |
| 2 | `PhilipJohnBasile/callsieve` | RUN + PORT proof layer | Local repo retrieval, trace replay, proof reports, evidence packs | README + public GitHub metadata |
| 3 | `nseniak/mcphero` | WRAP / PORT gateway pattern | MCP gateway, RBAC, OAuth, stdio hosting, audit logging | README + public GitHub metadata |
| 4 | `nbosa/mcpguard` | RUN + STRIP proxy | MCP static scanner, runtime probe, stdio guard proxy, SARIF | README + public GitHub metadata |
| 5 | `Li-Bailiang/mcp-safeguard` | RUN + STRIP rule pack | Semgrep-backed MCP security scanner and rule corpus | README + public GitHub metadata |

## Intake gate architecture

```text
Candidate repo / MCP server / agent tool
  -> metadata capture
  -> source inspection
  -> dependency and install check
  -> static scan
  -> MCP-specific rule scan
  -> runtime probe
  -> gateway registration
  -> policy assignment
  -> mediated execution
  -> trace capture
  -> replay / recovery proof
  -> evidence receipt
  -> approved registry entry or rejection
```

## Control-plane stages

### 1. Metadata capture

Capture the facts before running anything:

- repo full name
- clone URL
- default branch
- created / updated timestamp where available
- license
- language stack
- package managers
- install surface
- runtime execution surface
- network dependency
- credential dependency
- destructive capability
- browser / shell / filesystem / API capability
- MCP client capability
- MCP server capability
- proxy / gateway capability
- observability capability
- recovery capability

### 2. Static inspection

Minimum static checks:

- file tree review
- README claim extraction
- install commands
- unsafe shell commands
- package scripts
- Dockerfiles
- GitHub Actions
- secrets patterns
- permission breadth
- subprocess execution
- hidden prompt/tool descriptions
- runtime schema mutation risk
- dependency freshness

### 3. MCP-specific security scan

Run at least two independent scanners where possible:

- `nbosa/mcpguard` for local static scan, runtime probe, SARIF, and proxy behavior
- `Li-Bailiang/mcp-safeguard` for Semgrep rule corpus, SARIF, risk scoring, and CI thresholding

Normalize scanner outputs into one internal finding format:

```json
{
  "tool": "scanner-name",
  "repo": "owner/name",
  "finding_id": "string",
  "severity": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "category": "string",
  "file": "string",
  "line": 0,
  "message": "string",
  "remediation": "string",
  "evidence_ref": "string"
}
```

### 4. Runtime probe

A candidate cannot be trusted from README claims alone. Minimum runtime proof:

- install succeeds in isolated runner
- no unexpected network call during install except declared package retrieval
- health command runs
- test or smoke command runs
- MCP server lists tools if applicable
- MCP client lists upstreams if applicable
- proxy emits JSONL or structured telemetry if applicable
- failure mode is captured cleanly

### 5. Gateway and policy registration

Only after scanning and probing:

- register as candidate tool
- assign policy profile
- classify trust tier
- bind business owner and technical owner
- record model and dependency provenance
- record data access class
- require re-validation on upstream change

Trust tiers:

| Tier | Meaning | Default action |
|---|---|---|
| A | Local deterministic utility, no external side effects | allow with logging |
| B | Reads local repo/files only | allow with path restrictions |
| C | Writes files, opens network, calls APIs | require explicit policy |
| D | Browser/shell/credential/action capability | proxy + approval gate |
| E | Destructive, financial, legal, identity, or external authority | block unless signed-off |

### 6. Evidence receipt

Every candidate produces a receipt:

```yaml
task_id: agent-infra-intake-<repo-slug>-<date>
intent: evaluate candidate agent infrastructure repo
execution:
  metadata: completed|failed
  source_inspection: completed|failed
  static_scan: completed|failed
  runtime_probe: completed|failed
  gateway_registration: completed|failed
output:
  decision: run|port|strip|wrap|ignore|blocked
  approved_capabilities: []
  blocked_capabilities: []
status: REAL|PARTIAL|BLOCKED
evidence:
  - type: github_metadata
    value: repo URL or connector receipt
  - type: readme_inspection
    value: file ref or hash
  - type: cli_output
    value: command log path
  - type: sarif
    value: report path
  - type: telemetry
    value: trace/log path
score: 0.0
```

## Candidate-specific treatment

### `axocoatl/axocoatl`

Decision: RUN when a networked runner is available.

Why it matters:

- It is the strongest candidate for persistent agent runtime behavior.
- It claims Rust actor-based coordination, dependency-triggered workflows, provider-agnostic operation, checkpointing, MCP, A2A, per-agent token budgets, and local operation.
- The valuable primitive is not the branding; it is survivable execution with checkpoint/restart semantics.

Proof required:

```bash
git clone --depth 1 https://github.com/axocoatl/axocoatl.git
cd axocoatl
cargo test --workspace
cargo build --release
cargo run --bin axocoatl -- doctor
cargo run --bin axocoatl -- validate axocoatl.example.yaml
```

Recovery proof required:

```text
start local daemon
start mock workflow
kill daemon mid-task
restart daemon
verify workflow resumes from checkpoint instead of restarting from zero
capture logs and state file diff
```

System binding:

- GLOBAL_RULE_KERNEL runtime substrate candidate
- deterministic recovery design input
- 72h survivability test candidate

What to ignore:

- Stigmergy language until measured
- roadmap HTN / auction / Firecracker claims until wired and demonstrated

### `PhilipJohnBasile/callsieve`

Decision: RUN + PORT proof layer.

Why it matters:

- Strong candidate for repo-to-agent evidence, local retrieval, trace replay, proof reports, and token-use governance.
- The valuable primitive is compact deterministic context packets before an agent starts blind search.

Proof required:

```bash
git clone --depth 1 https://github.com/PhilipJohnBasile/callsieve.git
cd callsieve
cargo test
cargo build --release
./target/release/callsieve demo . --task "find where CLI commands are defined"
./target/release/callsieve index .
./target/release/callsieve agent-context . "find trace replay implementation" --format json
```

Port targets:

- trace schema
- trace replay
- evidence pack
- policy-check
- enterprise proof report
- compact context packet shape

System binding:

- Reality Ledger
- Command Centre receipts
- repo-to-MCP tool generation pre-filter
- model hygiene / provenance layer

What to ignore:

- broad token-savings claims unless paired transcripts prove them
- commercial positioning except as a useful packaging signal

### `nseniak/mcphero`

Decision: WRAP / PORT gateway pattern.

Why it matters:

- Strong MCP control-plane candidate.
- It aggregates upstream MCP servers behind one endpoint and adds role-based access control, per-user OAuth, encrypted tokens, hosted stdio servers, and audit logs.

Proof required:

```bash
git clone --depth 1 https://github.com/nseniak/mcphero.git
cd mcphero
docker compose --profile standalone up --build
# open localhost:8080
# register one harmless upstream MCP server
# call one tool
# verify audit log emitted
```

Port targets:

- one MCP ingress
- role-to-tool mapping
- upstream credential separation
- encrypted token storage
- stdio sandbox selection
- audit log shape

System binding:

- Approved MCP Registry
- ConsentX
- Command Centre MCP gateway
- business owner / IT owner / policy owner mapping

What to ignore:

- hosted SaaS surface unless partnering
- dev stub auth outside local testing
- local-subprocess stdio execution unless isolated

### `nbosa/mcpguard`

Decision: RUN + STRIP proxy.

Why it matters:

- It combines static scan, runtime probing, output formats, CI behavior, and local stdio proxy mediation.
- The proxy pattern is directly reusable: `agent -> guard proxy -> upstream MCP`.

Proof required:

```bash
git clone --depth 1 https://github.com/nbosa/mcpguard.git
cd mcpguard
go test ./...
go build -o mcpguard ./cmd/mcpguard
./mcpguard scan . --format sarif --output results.sarif --fail-severity HIGH
./mcpguard scan . --format json --output results.json
```

Proxy proof required:

```bash
./mcpguard proxy --upstream-command node --upstream-arg /path/to/harmless/server.js --proxy-report mcpguard-proxy.jsonl
```

Port targets:

- SARIF output gate
- JSON finding model
- schema drift detector
- prompt injection detector
- stdio proxy mediation
- CI failure thresholds

System binding:

- MCP firewall
- Agent Infrastructure Intake Gate
- GitHub code scanning integration

What to ignore:

- Apple Foundation Models classification until false-positive rate is proven

### `Li-Bailiang/mcp-safeguard`

Decision: RUN + STRIP rule pack.

Why it matters:

- Semgrep-backed MCP scanner with a large rule corpus and SARIF output.
- Best used as one scanner inside the gate, not as the whole gate.

Proof required:

```bash
git clone --depth 1 https://github.com/Li-Bailiang/mcp-safeguard.git
cd mcp-safeguard
pnpm install
pnpm build
node packages/cli/dist/index.js scan . --format sarif -o results.sarif
node packages/cli/dist/index.js scan . --format json -o results.json
```

Port targets:

- rule categories
- Semgrep rule corpus
- SARIF normalization
- weighted risk scoring
- CI thresholding

System binding:

- intake-gate scanner ensemble
- MCP security policy baseline
- pre-commit and CI pattern

What to ignore:

- runtime SDK claims until tested under real MCP calls

## Productization path

Offer:

> Agent Infrastructure Intake Gate: before your company lets agents use MCP tools, browser control, repo automation, local runtimes, or third-party execution plugins, every capability is scanned, probed, policy-bound, mediated, logged, and approved.

Commercial packages:

| Package | Buyer | Deliverable | Price signal |
|---|---|---|---|
| Intake Sprint | CTO / CISO | Scan 5-10 MCP/agent tools and produce approval register | fixed-fee audit |
| MCP Gateway Setup | Platform team | one controlled MCP ingress with RBAC and audit | implementation |
| Agent Evidence Pack | Board / risk / regulator | trace, replay, policy, model provenance, receipts | assurance pack |
| Continuous Gate | Enterprise | weekly scan + CI gate + registry + exception handling | monthly recurring |

## Immediate implementation plan

1. Create `agent_infra_candidate` table.
2. Create `agent_infra_receipt` table.
3. Create scanner-normalized finding schema.
4. Add GitHub Action template for repo intake.
5. Add bridge runner workflow for networked clone/run.
6. Add Command Centre widget showing candidate status.
7. Promote approved tools into MCP registry only after evidence receipt.

## Open gaps

- Local runtime clone/run blocked in this environment because `github.com` DNS resolution failed.
- README claims are inspected but not verified by execution.
- No SARIF reports generated yet.
- No proxy JSONL report generated yet.
- No checkpoint/restart proof generated yet.
- No gateway audit log generated yet.
- No Supabase ledger write completed in this run.

## Receipt

```yaml
task_id: agent-infra-intake-gate-20260607
intent: convert weekly high-signal repo scan into reusable AI/MCP infrastructure intake gate
execution:
  github_repo_search: completed
  readme_inspection: completed
  local_clone_run: blocked_dns_resolution
  github_handoff_write: completed
output:
  artifact: docs/research/agent-infrastructure-intake-gate-20260607.md
status: PARTIAL
evidence:
  - type: github_metadata
    value: public repo search confirmed candidate repos
  - type: readme_inspection
    value: GitHub connector README reads for five candidates
  - type: cli_output
    value: sandbox git clone failed with Could not resolve host github.com
score: 0.78
```
