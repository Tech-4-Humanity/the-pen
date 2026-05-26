# T4H Data Pod Runtime v1.1

## Purpose

This pack establishes a persistent pod system for processing Troy/T4H data surfaces:

- LLM chat exports, including GPT, Claude, Grok, Perplexity, NotebookLM and Takeout-style JSON exports
- Google Drive, including documents, slides, spreadsheets, images, videos and evidence packs
- GitHub, Supabase, S3 and downstream execution systems

The operating shift is from archive search to compounding cognition.

The system must convert large unstructured archives into reusable business inventory, evidence objects, product genome records, recovery queues, narrative memory and monetisation opportunities.

## Non-negotiable operating rules

1. Do not fix documents one-by-one.
2. Do not create third, fourth or fifth duplicate versions of the same evidence pack.
3. Compile into canonical object stores.
4. Future downloads are incremental deltas only.
5. Every run emits telemetry.
6. Every meaningful claim receives evidence.
7. Every pod reports through POD-00 Chief of Staff.
8. Human escalation is blocked except for legal, financial, destructive or authority-bound actions.

## POD-00 Chief of Staff

POD-00 is the permanent leader.

Responsibilities:

- Orchestrate all other pods
- Assign work
- Prioritise queues
- Suppress duplicates
- Maintain canonical truth
- Resolve conflicts
- Emit daily executive briefs
- Identify new business opportunities
- Turn recovered work into downstream tasks
- Report only meaningful deltas

Escalation policy:

```yaml
interrupt_only_if:
  - legal_boundary
  - financial_threshold
  - destructive_action
  - missing_authority
otherwise:
  continue_execution: true
```

## Memory spine

All pods write to a shared memory object model.

```yaml
MemoryObject:
  object_id:
  type:
  source:
  source_uri:
  created_at:
  updated_at:
  source_hash:
  embedding_hash:
  entity_hash:
  entities:
    products: []
    projects: []
    people: []
    ideas: []
    evidence: []
  signals:
    value:
    confidence:
    economic_score:
    reuse_score:
    urgency_score:
  relationships: []
  status: REAL|PARTIAL|PRETEND
  next_actions: []
```

## Universal pod workflow

```text
DISCOVER
→ EXTRACT
→ NORMALISE
→ ENTITY DETECTION
→ LINK
→ SCORE
→ STORE
→ GRAPH UPDATE
→ EXECUTIVE OUTPUT
```

## Delta-first processing

Never rescan full 10GB or 100GB stores unless hashes are missing or integrity is suspect.

Only process:

```yaml
new_files
modified_files
signal_changes
new_downloads
new_exports
```

Skip unchanged material using:

```yaml
sha256
modified_date
embedding_hash
entity_hash
```

## Core pod sequence

1. POD-00 Chief of Staff
2. LLP-01 Digest / Ingest
3. GDP-01 Drive Discovery
4. LLP-02 Lost Work Recovery
5. LLP-03 Research / Tax / Audit
6. GDP-02 Portfolio Health
7. GDP-03 Evidence / Receipt
8. LLP-04 Product Genome
9. GDP-04 Knowledge Graph
10. LLP-05 Strategic Drift
11. GDP-05 Narrative Memory
12. LLP-06 Opportunity / Revenue

## LLM pods

### LLP-01 Digest / Ingest

Normalises GPT, Claude, Grok, Perplexity, NotebookLM and Takeout exports.

Outputs:

- normalised NDJSON
- daily digest
- conversation objects
- source hashes
- embedding queue
- entity candidates

### LLP-02 Lost Work Recovery

Scans for abandoned value.

Signals:

- "send to bridge"
- "continue"
- "later"
- "come back to"
- "TODO"
- "FIXME"
- unfinished outputs
- unclosed promises
- truncated artifacts

Scores each recovery item by:

- completion
- revenue
- difficulty
- strategic value
- urgency

### LLP-03 Research / Tax / Audit

Extracts R&D, grant and audit evidence from conversations and associated files.

Maps:

- experiments
- technical uncertainty
- decisions
- chronology
- labour allocation
- source evidence
- gaps
- audit grade

### LLP-04 Product Genome

Extracts product DNA across the portfolio.

Entities:

- Product
- Agent
- Role
- Widget
- Signal
- Offer
- Problem
- Customer
- Revenue
- Evidence

### LLP-05 Strategic Drift

Detects change over time.

Signals:

- new obsessions
- direction changes
- intensity increase
- emerging businesses
- disappearing ideas
- abandoned high-value concepts

### LLP-06 Opportunity / Revenue

Continuously hunts for economic conversion.

Finds:

- grants
- tenders
- monetisation paths
- partnerships
- licensing
- speaking
- consulting
- product packaging
- unfinished revenue

## GDrive pods

### GDP-01 Discovery

Maps the Drive estate without trying to fix it.

Clusters:

- old frameworks
- diagrams
- images
- slide decks
- PDFs
- duplicate strategy docs
- evidence packs
- finance packs
- grant material

### GDP-02 Portfolio Health

Scores portfolio entities.

Labels:

- REAL
- PARTIAL
- AT_RISK
- STOP_SHIP

Checks for missing:

- one-pager
- pricing
- deck
- product page
- GTM plan
- video
- legal/privacy copy
- evidence

### GDP-03 Evidence / Receipt

Creates Reality Ledger attachments for Drive artifacts.

Each evidence record includes:

```yaml
intent:
execution:
evidence:
artifact:
hash:
audit_grade:
confidence:
```

### GDP-04 Knowledge Graph

Turns search into cognition.

Node types:

- people
- projects
- products
- ideas
- evidence
- revenue
- signals
- files
- agents

### GDP-05 Narrative Memory

Recovers story assets.

Sources:

- photos
- voice notes
- travel notes
- AWS/Oracle/Gartner history
- personal writings
- humanitarian work
- old consulting records

Outputs:

- article material
- keynote stories
- podcast arcs
- book fragments
- founder narrative evidence

## Daily executive report

POD-00 emits:

```yaml
date:
completed:
new_evidence:
new_products:
portfolio_changes:
high_value_recoveries:
revenue_opportunities:
emerging_patterns:
risks:
recommended_actions:
```

## First run priority

1. Create tables.
2. Seed pod registry.
3. Load first LLM manifest.
4. Load first Drive manifest.
5. Run delta hash inventory.
6. Create recovery queue.
7. Create RDTI evidence queue.
8. Emit first POD-00 executive brief.

## Reality state

Current state: PARTIAL

Reason:

- architecture compiled
- GitHub target available
- runtime not yet deployed
- Supabase/S3/Bridge execution not yet proven
- no scheduler proof
- no telemetry receipts yet
