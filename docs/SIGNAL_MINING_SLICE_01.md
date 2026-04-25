# Signal Mining Slice 01 — Research Execution Spec

Status: lodged by ChatGPT
Date: 2026-04-25 Australia/Sydney
Mode: research-first, no new infra
Trace: `signal-mining-slice-01-research-plan-chatgpt-20260425`
Inbox job: `inbox/signal-mining-slice-01-research-plan-chatgpt-20260425.json`
Commit proof: `01f8e21f8af39ea7642551242400d901cb5d6b50`

## Operator Direction

We are not building another memory system yet.

We are researching and planning how to mine existing signal across LLM chats, documents, repo activity, system activity and data. Context, memory, intent, activity, outcomes and data are all part of signalling.

The existing estate likely contains around ten years of useful normal-person and operator signal. The task is to harvest what exists before planting or growing new infrastructure.

## Objective

Produce a tested, evidence-backed plan for mining existing historical signal and running graph tests/simulations over it to find:

- repeated strategic intents
- broken loops
- reusable latent IP
- unfinished high-value work
- actor/context failures
- system surfaces that need repair before expansion

## Hard Constraint

Do not build new infrastructure during Slice 01.

Allowed:

- read
- inspect
- source-map
- normalise samples
- draft schemas
- write docs/specs
- lodge jobs
- generate receipts

Blocked until explicitly approved:

- production DB migrations
- RLS changes
- deploys
- data deletion
- payment/IAM/credential work
- autonomous long-running crawlers

## Source Map — Slice 01

| Source | Priority | Purpose | Access Mode | Notes |
|---|---:|---|---|---|
| `TML-4PM/the-pen/inbox/` | 1 | intents sent to worker | GitHub read | canonical work-entry trace |
| `TML-4PM/the-pen/receipts/runtime/` | 1 | execution proof | GitHub read | canonical done/evidence trace |
| `TML-4PM/the-pen/global/` | 1 | actor rules/context | GitHub read | bootstrap truth |
| `TML-4PM/the-pen/docs/` | 1 | system design/docs | GitHub read | current working memory |
| ChatGPT current/recent threads | 2 | operator intent + LLM behaviour | export/search where available | no runtime URL available from sandbox |
| Claude memory/activity artefacts | 2 | external LLM memory comparison | locate in docs/chats | user asked for recent Claude memory activity |
| Other LLM profiles | 2 | profile/context sharing | locate in docs/chats | already gathered previously |
| Google Drive folder supplied by user | 3 | selected docs/assets | Drive read only | expand after repo slice is stable |
| Notion/Gmail/other data | 4 | later enrichment | read only | not part of first proof unless needed |

## First Slice Bounds

| Dimension | Bound |
|---|---|
| Time | last 6–12 months first |
| Volume | 5k–10k normalised events maximum |
| Sources | GitHub repo first, recent LLM thread artefacts second |
| Goal | prove signal → pattern → value |
| Output | tables and validation traces, not dashboards |

## Full 10-Year Expansion Mode

Only after Slice 01 validates:

| Phase | Expansion |
|---|---|
| 02 | all available LLM chat exports and memory/profile docs |
| 03 | Google Drive docs and folders with source map |
| 04 | repo history across all relevant repos |
| 05 | email/CRM/calendar/activity sources where useful |
| 06 | simulations over the merged graph |

Expansion rule: no source is added until it has an owner, access method, freshness note, and evidence quality rating.

## Universal Event Shape v0

```json
{
  "event_id": "stable hash of source + timestamp + content fingerprint",
  "timestamp": "ISO-8601 if known",
  "source": "chat|github|drive|doc|email|calendar|system|unknown",
  "source_ref": "URL/path/message id/commit sha where available",
  "thread_id": "conversation, issue, PR, job or doc grouping",
  "actor": "troy|chatgpt|claude|gemini|pen|symbio|worker|unknown",
  "intent": "what was meant or requested",
  "actions": ["what happened"],
  "outcome": "none|partial|complete|fail|blocked|unknown",
  "entities": ["systems, repos, docs, people, tools, products"],
  "tags": ["short classifiers"],
  "confidence": 0.0,
  "evidence_ref": "commit, receipt, raw message, doc section or file path"
}
```

## Extraction Rules

| Raw Pattern | Field |
|---|---|
| “need to”, “we need”, “should”, “build”, “fix”, “deploy”, “wrap”, “send” | intent |
| “created”, “committed”, “deployed”, “sent”, “lodged”, “ran” | action |
| “receipt”, “live”, “done”, “closed”, “verified” | outcome=complete candidate |
| “error”, “failed”, “blocked”, “could not”, “no receipt” | outcome=fail/blocked candidate |
| repo names, filenames, URLs, agents, tools, products | entities |
| repeated phrases and canonical system terms | tags |
| no proof, unclear status | confidence <= 0.4 |

## Extraction Query Set v1

Use these first. Keep raw result references.

### GitHub repo queries

| Query | Target |
|---|---|
| `enqueue_job idempotency_key receipts/runtime` | job lifecycle |
| `signal mining memory context intent data` | signal mining artefacts |
| `Claude memory activity profile` | Claude memory/profile capture |
| `ACTOR_BOOTSTRAP GLOBAL_RULE COMMS` | bootstrap/context rules |
| `receipt proof_ref closed_at blocked_reason` | evidence/done records |
| `no MCP GitHub connector inbox worker` | bridge constraints |
| `sweeper scrape LLM chats documents` | sweepers and harvesting |
| `SYSTEM_UP_TO_SCRATCH SOURCE_MAP` | system repair docs |
| `agent profile operator profile memory` | profile context sharing |
| `WIP PEN Symbio Bridge handover` | routing/handoff traces |

### Chat/thread queries

| Query | Target |
|---|---|
| `Claude memories activity` | recent Claude memory discussion |
| `other LLM info update profiles share context` | cross-LLM profile update work |
| `you did one on me profile` | ChatGPT-generated operator profile |
| `context memory intent data signalling` | framing and design intent |
| `10 years normal person signal LLM chats documents data` | long-horizon signal concept |
| `graph tests sims harvesting mining` | mining/simulation concept |
| `not building again research plan` | no-build constraint |
| `system up to scratch` | system fitness framing |

### Drive queries

Run only after repo slice is stable.

| Query | Target |
|---|---|
| `Claude memory activity` | LLM memory docs |
| `operator profile` | Troy profile docs |
| `LLM profile` | model profile docs |
| `context operating layer` | system context docs |
| `signal spine` | prior naming/architecture |
| `actor bootstrap` | onboarding/control docs |

## Graph Nodes

| Node | Meaning |
|---|---|
| Intent | requested or implied objective |
| Action | actual performed step |
| Outcome | complete/fail/blocked/partial |
| Entity | system, file, repo, product, agent, doc |
| Actor | person, LLM, worker, queue |
| Constraint | rule, blocked dependency, policy |
| Asset | reusable artefact or IP |
| Signal | observed pattern extracted from events |

## Graph Edges

| Edge | Meaning |
|---|---|
| `leads_to` | intent → action |
| `results_in` | action → outcome |
| `mentions` | event → entity |
| `blocked_by` | intent/action → constraint |
| `reused_as` | asset → later action |
| `similar_to` | intent/entity cluster relation |
| `contradicts` | doc/rule conflict |
| `requires_bootstrap` | actor/action depends on global context |

## Graph Tests v1

| Test | Query | Output |
|---|---|---|
| Repeat Intent Test | same/similar intent > 3 times | stuck loop or strategic anchor |
| Fail Cluster Test | failures grouped by entity | broken system surface |
| Partial Loop Test | intent/action with no verified outcome | unfinished leverage |
| Asset Emergence Test | entity reused across work | latent IP |
| Execution Gap Test | intent without action | thinking-to-doing leakage |
| Context Drift Test | conflicting rules/docs | actor confusion |
| Actor Confusion Test | repeated “where is X” / “what exists” | missing source map/bootstrap |
| HITL Friction Test | human asked to paste/run/check repeatedly | automation candidate |
| Evidence Gap Test | claimed done without receipt/proof | trust failure |
| Archive Risk Test | deletion requested where archive should happen | safety/system hygiene issue |

## Simulations v1

| Simulation | Question | Output |
|---|---|---|
| Completion Sim | What if top partial loops were finished? | ranked ROI list |
| No-HITL Sim | What could run without Troy? | automation queue |
| Asset Reuse Sim | What if each asset was reused once? | product/IP candidates |
| Focus Sim | What if only top 10% signals were kept? | operating focus list |
| Kill Sim | What repeated loops should stop? | kill/stand-down list |
| Bootstrap Sim | What if every actor read global first? | reduced confusion estimate |
| Evidence Sim | What work lacks proof? | verification backlog |

## Output Tables Required

### Table 1 — Top Loops

| Intent | Count | Outcome Pattern | Evidence | Call |
|---|---:|---|---|---|

### Table 2 — Broken Systems

| Entity | Fail Count | Impact | Evidence | Call |
|---|---:|---|---|---|

### Table 3 — Hidden Assets

| Asset | Reuse Count | Where | Value | Evidence |
|---|---:|---|---|---|

### Table 4 — High ROI Fixes

| Fix | Why | Effort | Impact | Evidence |
|---|---|---:|---:|---|

### Table 5 — Do Not Build Yet

| Candidate | Why Not Yet | Needed Evidence |
|---|---|---|

## Validation Method

For every top finding:

1. Link to at least one raw source reference.
2. Link to at least one confirming source reference where possible.
3. Mark confidence.
4. Mark evidence type: REAL, PARTIAL, or PRETEND.
5. Reject findings with no traceable evidence.

## Acceptance Criteria

Slice 01 is done only when:

- source inventory exists
- first 5–10 extraction queries have been run
- at least 100 sample events are normalised or sampled manually
- first graph test results are produced
- at least 5 findings trace back to raw evidence
- receipts exist for lodged jobs
- no new infrastructure was created without approval

## Rollback / Stand-down Rules

| Condition | Action |
|---|---|
| no receipt after job lodged | inspect worker and action mapping |
| source unavailable | mark unavailable, do not invent |
| data too noisy | reduce slice, tighten extraction rules |
| findings not evidence-backed | reject as PRETEND |
| build pressure appears | stand down and return to research plan |

## Next Jobs To Lodge

1. `research.signal_mining_receipt_check`
2. `research.signal_mining_extract_queries_v1`
3. `research.signal_mining_worker_mapping`
4. `research.signal_mining_source_inventory`
5. `research.system_up_to_scratch_plan`
