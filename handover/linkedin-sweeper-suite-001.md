# LinkedIn Sweeper Suite — Bridge Handover

Status: packaged for bridge execution
Idempotency key: `linkedin-sweeper-suite-wireup-001`
Source job: `inbox/linkedin-sweeper-suite-001.json`

## Objective
Wire the LinkedIn sweeper suite into the PEN/Bridge flow so LinkedIn exports or connector data can be read, classified, routed, and converted into queued work for T4H businesses.

## Execution mode
- Read / inspect / enqueue only.
- No LinkedIn posting.
- No deletion.
- No messaging.
- No paid actions.
- Archive is allowed only if already supported by downstream policy.

## Inputs
1. LinkedIn connector data, if available.
2. LinkedIn export bundle, if connector is unavailable.
3. Prior source job payload: `linkedin-sweeper-suite-001`.

## Required components

### 1. Registry
Register these sweepers:
- `linkedin.signal.miner`
- `linkedin.opportunity.detector`
- `linkedin.content.deconstructor`
- `linkedin.idea.extractor`
- `linkedin.network.mapper`
- `linkedin.intent.parser`
- `linkedin.gap.finder`
- `linkedin.recycler`
- `linkedin.angle.generator`
- `linkedin.knowledge.sync`
- `linkedin.business.router`

### 2. Runtime route map
| Record | Destination |
|---|---|
| lead / buyer intent | CRM + PEN |
| product / IP idea | WIP + KB |
| content candidate | content_queue |
| relationship signal | CRM + KB |
| uncertain signal | WIP |
| high-confidence executable job | PEN |

### 3. Standard output schema
Every record must include:
- `source`
- `record_type`
- `category`
- `content`
- `source_ref`
- `entities`
- `score`
- `recommended_action`
- `destination`
- `dedupe_key`
- `evidence`

### 4. Child job rules
Every child job must include:
- stable idempotency key
- source provenance
- confidence score
- evidence grade
- rollback/no-op note
- target queue

## Definition of done
- Bridge receives this job.
- Sweeper suite is registered or queued for registration.
- Read-only dry run is attempted if LinkedIn data exists.
- Runtime receipt is written under `receipts/runtime/`.
- Receipt includes:
  - scanned count
  - classified count
  - routed count
  - enqueued child jobs
  - skipped count
  - blocked reason, if any
  - proof refs

## Failure handling
| Failure | Impact | Required receipt |
|---|---|---|
| No LinkedIn connector/export | Cannot run sweep | `blocked: linkedin_source_unavailable` |
| Schema mismatch | No routing | error details + rejected rows count |
| Queue unavailable | Classification can run, enqueue blocked | queue failure + retry recommendation |
| Missing registry table | Job cannot register sweepers | table/function missing + exact bridge action needed |

## Bridge action
Execute via bridge worker using the corresponding inbox payload:

`inbox/linkedin-sweeper-suite-wireup-001.json`

Close only when GitHub commit receipt and runtime receipt exist. If runtime receipt cannot be produced, close as PARTIAL with blocker stated.
