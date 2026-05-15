# Atlas Heatmap Widget Reuse Rule

Status: REAL once committed to `TML-4PM/the-pen`.
Owner: The Pen / Command Centre / Service Catalog.
Applies to: HoloOrg, WorkFamilyAI, AHC, Outcome Ready, AI4Tradies, GC-BAT, MyNeuralSignal, ConsentX, service catalog work, decision propagation simulator, and future organisational cognition views.

## Rule

Before creating any new heatmap, matrix, map, Atlas, grid, evidence board, decision-ripple view, cohort-risk view, product/service impact map, or organisational propagation view, the system must ask and answer:

1. Do we already have a map/heatmap/widget pattern?
2. Is the existing Atlas pattern suitable as-is?
3. Should the existing pattern be altered instead of creating a new asset?
4. Am I allowed to alter the canonical pattern?
5. If alteration is required, should this be a versioned extension rather than a fork?
6. If no suitable asset exists, create one and register it immediately.
7. Once created, add it to the asset registry/service catalog so the next user or agent can reuse it.
8. Log every reuse, fork, failed reuse, and retirement decision.

## Canonical Asset

Name: Atlas-style Organisational Heatmap Widget
Canonical slug: `atlas_org_heatmap_widget`
Pattern family: `atlas_heatmap`
Asset type: reusable UI/widget/template
Primary use: heatmap-style grid showing relationships between rows and measurable states.

Canonical visual grammar:

- rows = cohort / role / team / agent / business / product / service / decision source
- columns = issue / state / intervention / evidence / heard / understood / translated / started / executed / verified / closed / cost / delay / morale / risk
- cells = status, score, evidence, confidence, owner, last updated, action required
- colours or states:
  - green = intact / healthy / validated
  - yellow = drift / watch
  - orange = duplication / mutation / partial failure
  - red = lost / failed / blocked
  - blue = agent stronger than human
  - purple = human stronger than agent

## Reuse Requirement

Default behaviour is reuse, not new creation.

Create a new asset only when:

- the canonical Atlas pattern cannot support the required domain,
- the new domain requires materially different interaction behaviour,
- evidence fields are incompatible,
- the asset would be unsafe or misleading if reused,
- or the new version is explicitly registered as an extension.

## Registration Requirement

Every Atlas-style widget must be registered with:

```yaml
asset_id:
name:
slug:
pattern_family: atlas_heatmap
version:
owner:
businesses_supported:
products_supported:
use_cases:
status: draft | active | deprecated | retired
created_at:
updated_at:
source_repo:
source_path:
service_catalog_ref:
command_centre_ref:
reuse_count:
fork_count:
failed_reuse_count:
last_used_at:
retirement_review_date:
```

## Reuse Measurement

Every reuse must create a ledger row:

```yaml
reuse_event_id:
asset_slug:
asset_version:
used_by_business:
used_by_product:
used_by_agent_or_chat:
use_case:
outcome: reused | adapted | forked | rejected | retired
reason:
time_saved_estimate_minutes:
quality_score:
conversion_to_runtime: true | false
created_at:
```

## Template Health Rules

- If `reuse_count = 0` after 30 days, review discoverability and usefulness.
- If `failed_reuse_count > reuse_count`, review the pattern or split into clearer variants.
- If forks exceed 3, consolidate variants or create a formal sub-pattern.
- If an asset is reused more than 10 times, promote it into the service catalog as a standard component.
- If reused more than 25 times, create documentation, examples, and a command-centre launcher.
- If unused for 90 days and not strategically important, mark deprecated.

## House Rule

Do not create endless new assets when an existing reusable pattern is available.

Any agent, LLM, chat, worker, or bridge process creating a heatmap-like interface must first search for `atlas_heatmap`, `atlas_org_heatmap_widget`, and related registered asset slugs.

If no registered asset is found, create the asset, register it, and log the creation as a reusable pattern.

## Reality Ledger Binding

A claim that an Atlas widget exists is only REAL when at least one of these exists:

- registered asset row,
- committed source file,
- Command Centre snippet entry,
- service catalog item,
- deployment URL,
- or Bridge receipt.

Otherwise status is PARTIAL.
