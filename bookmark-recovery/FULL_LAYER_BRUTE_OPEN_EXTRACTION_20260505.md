# Full-Layer Brute Opening + Data Extraction Protocol

Date: 2026-05-05
Owner: COAX / Pen / Bridge
Status: PARTIAL until runtime execution receipts exist

## Correction

The bookmark recovery job must not be narrowed to only LLM/workspace URLs. The LLM/workspace layer is high value, but all layers require brute opening and data extraction.

Known audit counts from prior occurrence-level pass:

| Metric | Count |
|---|---:|
| Total URL occurrences | 3,967 |
| Unique URLs | 708 |
| Repeated URL/context groups | ~708 |
| LLM/workspace occurrences | ~1,738 |
| Auth/session-required occurrences | ~2,226 |
| Owned business asset occurrences | 46 |

## Non-negotiable rule

Every occurrence is a separate work unit.

Same URL does not mean same content. A repeated URL may represent a different title, folder, export date, chat state, business context, deployment state, or unfinished task.

No URL-only dedupe is allowed before extraction.

## Required occurrence identity

Each occurrence must preserve:

```json
{
  "occurrence_id": "BM-000000",
  "url": "",
  "canonical_url": "",
  "source_file": "",
  "source_folder": "",
  "bookmark_title": "",
  "add_date": "",
  "last_modified": "",
  "export_batch": "",
  "context_hash": "",
  "url_group_id": "",
  "occurrence_hash": ""
}
```

## Required extraction schema

Each occurrence must produce:

```json
{
  "occurrence_id": "",
  "layer": "llm_workspace | owned_asset | research | tool | infra | docs_drive | social_content | vendor_market | noise_unknown",
  "execution_mode": "static_fetch | browser_render | authenticated_session | connector_fetch | pdf_extract | repo_fetch | manual_blocked",
  "requires_auth": false,
  "open_attempted": false,
  "open_result": "success | fail | blocked | auth_required | unsupported",
  "http_status": null,
  "page_title": "",
  "visible_text_excerpt": "",
  "raw_text_location": "",
  "structured_payload_location": "",
  "screenshots_location": "",
  "files_downloaded": [],
  "code_blocks_found": [],
  "ideas_found": [],
  "actions_found": [],
  "unfinished_work_found": [],
  "products_found": [],
  "pricing_found": [],
  "cta_found": false,
  "business_links": [],
  "agent_owner": "",
  "state_current": "RAW | TRIAGE | PARTIAL | VALIDATED | REAL | MONETISED | AUTOMATED | ARCHIVED | BLOCKED",
  "state_target": "",
  "next_action_type": "extract | repair | monetise | route_to_bridge | archive | escalate_auth | rebuild",
  "next_action_payload": {},
  "reality_status": "PARTIAL",
  "evidence": [],
  "gaps": [],
  "pressure_flags": [],
  "score": 0
}
```

## Layer lanes

### Lane 1 — LLM / workspace

Includes ChatGPT, Claude, Gemini, Perplexity, NotebookLM, Google Docs/Sheets/Drive, Notion-like workspace links, MCP/agent session links.

Extract:
- conversation title
- visible user intent
- unfinished tasks
- code blocks
- prompts/system instructions
- bridge or Pen claims
- receipts or missing receipts
- assets referenced
- business/product mapping
- reusable patterns

Status target: REAL if content is extracted and stored; BLOCKED if auth prevents access after attempted connector/session path.

### Lane 2 — Owned business assets

Includes Tech4Humanity, Augmented Humanity Coach, Outcome Ready, WorkFamilyAI, AquaMe, AI4Tradies, Synal, DRA, other owned/controlled domains and Vercel/Lovable deployments.

Extract:
- live status
- product presence
- pricing presence
- CTA presence
- funnel state
- evidence/customer promise
- missing monetisation
- platform/repo clues
- repair tasks

Status target: VALIDATED or REAL only after open evidence exists.

### Lane 3 — Research and evidence

Includes arXiv, papers, studies, datasets, articles, policy reports, scientific references, AISS2, DRA, AI Sweet Spots, neuro/BCI research.

Extract:
- title
- authors/source
- date
- topic
- methods
- sample size
- geography
- findings
- reusable evidence rows
- business/application links

Status target: REAL if citation/evidence payload is captured and routed to research registry.

### Lane 4 — Tools and vendor systems

Includes SaaS tools, AI platforms, automation tools, design tools, dev tools, monitoring tools, analytics, CRM, calendar, email, Stripe, Vercel, Supabase, GitHub, Canva etc.

Extract:
- tool name
- account/auth implication
- integration mode
- API/doc links
- cost/pricing
- use case
- business linkage
- whether it should enter t4h_tool_registry

Status target: REAL if tool profile and usage decision are captured.

### Lane 5 — Infrastructure / repos / deployment

Includes GitHub, Vercel, AWS, Supabase, MCP Bridge, command centre, Lambdas, runners, queues, deploy links.

Extract:
- repo/project/function name
- deployment status
- commit or version clue
- runtime role
- failure mode
- missing proof
- handoff task

Status target: REAL only with typed evidence such as commit id, deployment id, API response, CLI output, or URL response.

### Lane 6 — Social/content/IP

Includes LinkedIn, articles, YouTube, podcasts, content prompts, brand materials, campaign references.

Extract:
- content topic
- author/source
- intended response or asset
- campaign use
- article/product linkage
- reusable narrative pattern

Status target: VALIDATED if extracted; REAL if converted into reusable asset or campaign task.

### Lane 7 — Low-confidence/noise

Includes stale search pages, generic repeated pages, dead endpoints, accidental links.

Do not delete immediately. Open once, extract enough to classify, then archive with reason and evidence.

## Execution order

1. Normalise all 3,967 occurrences.
2. Preserve repeated URL groups and assign occurrence-level IDs.
3. Run static fetch on all public/static URLs.
4. Run browser-render fetch on dynamic/JS-heavy URLs.
5. Run connector fetch for Google Drive/GitHub/Gmail/Calendar where applicable.
6. Mark auth-required items with session-required evidence, not failure.
7. Extract structured payload for every occurrence.
8. Route outputs into asset registry, task registry, research registry, tool registry, or archive registry.
9. Generate next actions for every PARTIAL/BLOCKED item.
10. Write receipts and Reality Ledger classifications.

## Required proof gates

A run is not REAL unless it includes:

- input occurrence count
- output occurrence count
- count opened successfully
- count blocked by auth
- count failed with error
- count archived with reason
- per-layer counts
- raw extraction location
- structured payload location
- next-action task count
- receipt path or commit id

## Bridge handoff payload

```json
{
  "task_id": "bookmark-full-layer-brute-open-20260505",
  "intent": "Brute open and extract all bookmark occurrence layers, preserving repeated URLs as distinct context-bearing work units.",
  "source": "bookmark_occurrence_audit",
  "input_counts": {
    "total_occurrences": 3967,
    "unique_urls": 708,
    "repeat_groups": 708,
    "llm_workspace_occurrences": 1738,
    "auth_session_required_estimate": 2226,
    "owned_business_asset_occurrences": 46
  },
  "execution_policy": {
    "dedupe_before_extraction": false,
    "preserve_occurrences": true,
    "attempt_all_layers": true,
    "write_reality_ledger": true,
    "receipt_required": true,
    "no_human_loop_unless_credentials_or_destructive_action_required": true
  },
  "outputs_required": [
    "full_occurrence_registry.csv",
    "full_occurrence_extraction.jsonl",
    "url_variant_group_report.csv",
    "layer_summary_report.md",
    "blocked_auth_required_queue.csv",
    "next_action_task_registry.csv",
    "monetisable_asset_register.csv",
    "reusable_code_and_prompt_register.csv",
    "research_evidence_register.csv",
    "tool_registry_seed.csv",
    "reality_ledger_receipts.jsonl"
  ],
  "status": "READY_FOR_BRIDGE_EXECUTION"
}
```

## Reality Ledger classification

Current state: PARTIAL

Reason: The protocol and handoff are now defined, but runtime brute opening and extraction of all 3,967 occurrences has not yet been evidenced in this environment.

Required next evidence:
- bridge run receipt
- output files
- per-layer extraction summary
- error/auth queue
- commit id or storage location

## Ledger

| Field | Value |
|---|---|
| task_id | bookmark-full-layer-brute-open-20260505 |
| intent | Brute open and extract all bookmark occurrence layers |
| execution | Protocol created and lodged to Pen repo |
| output | This markdown handoff/protocol |
| status | PARTIAL |
| evidence | GitHub commit receipt from file creation |
| score | 0.64 |
