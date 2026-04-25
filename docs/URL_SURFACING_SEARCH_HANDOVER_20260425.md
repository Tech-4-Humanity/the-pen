# URL Surfacing Search Coverage — Handover

Date: 2026-04-25
Actor: ChatGPT
Status: HANDOVER COMPLETE / EXECUTION PENDING PEN-SYMBIO

## Purpose

This handover captures the agreed definition, notes, assets, observed evidence, source matrix, search terms, schema shape, and execution payload for the read-only URL Surfacing Search Coverage Census.

This is not a product definition, not a website redesign, not a business grouping exercise, and not a final architecture.

The job is search-first discovery.

## Locked definition

A URL Surfacing Census is a read-only search system that discovers every URL-producing or URL-containing surface across connected systems before inspection, classification, product decisions, or website changes.

The unit is not a website. The unit is `url_evidence`.

A `url_evidence` record is any discovered mention, generator, config, redirect, link, route, deployment, webhook, email action, checkout, sitemap, HTML file, JSX link, API response, env var, partner link, or external dependency that can create or point to a surface.

## Hard rules

- Search first; do not assume known sources are complete.
- Do not start from Vercel-only inspection.
- Do not treat every website as a product, project, or business.
- No deploy, delete, rename, redirect, payment, IAM, credential, RLS, or destructive action.
- Every discovered URL or URL generator must retain source evidence.
- Coverage gaps must be reported as gaps, not treated as zero findings.
- No final product naming or business grouping in this pass.
- Archive is a recommendation only in this job; no archive/write action except receipts and handover docs.
- No claim of done without GitHub receipt.

## End in mind

Find every URL-producing or URL-containing surface across the estate, then classify what it is, where it came from, what it points to, and whether it later needs surfacing, lifting, unplugging, parking, merging, archiving, or watching.

## Included source classes

| Source | Required | Purpose |
|---|---:|---|
| GitHub | yes | Search code, docs, configs, README, snapshots, env examples, routes, API handlers, email/payment/auth/webhook emitters. |
| Vercel | yes | List teams, projects, deployments, domains, preview URLs. |
| Google Drive | yes | Search docs/sheets/slides for URL/domain/project evidence. |
| Gmail | yes | Search emails for partner links, generated links, old launches, demo URLs, Resend/contact-form references. |
| Supabase | if available | Search functions/config/table values through bridge/read-only credentials. |
| Stripe | if available | Read-only list/search products, payment links, checkout URLs. Do not create/change/refund. |
| Lovable | if available | List/search generated project surfaces if supported; otherwise mark unavailable. |
| Notion | if available | Search workspace and connected sources for URL evidence. |
| S3/static | if available | Search configured buckets/static exports if credentials exist. |

## Search matrix

### URL literals
- http
- https
- www.
- .com
- .app
- .ai
- .org
- .net
- .io

### Vercel
- vercel.app
- VERCEL_URL
- deployment
- preview
- domain

### Lovable
- lovable.app
- lovableproject.com
- Lovable

### Links
- href
- src
- canonical
- og:url
- sitemap
- robots

### Routing
- redirect
- rewrite
- router.push
- window.location
- Link to=

### Forms
- action=
- callback
- returnUrl
- success_url
- cancel_url

### Email
- resend
- send-email
- email template
- magic link
- unsubscribe

### Payments
- stripe
- checkout
- payment_link
- price
- invoice

### Supabase
- SITE_URL
- redirect_to
- auth.callback
- functions

### Webhooks
- webhook
- callbackUrl
- endpoint
- POST https

### Partner / commercial surfaces
- demo
- portal
- intake
- lead
- apply
- referral

## Evidence types

- literal_url
- url_generator
- route
- config
- email_emitter
- payment_emitter
- auth_redirect
- webhook
- deployment
- domain
- html_surface
- sitemap
- snapshot
- partner_reference
- unknown

## Observed evidence from this handover session

### Vercel

- Team observed: `team_IKIr2Kcs38KGo8Zs60yNtm7Y`
- Team slug/name observed: `troys-projects-t4h-machine` / `troy's projects`
- Projects returned by list call: 50
- Duplicates/variants were visible but not adjudicated.

Example clusters observed, not final decisions:

| Cluster | Observed names |
|---|---|
| ConsentX | consent-x, consentx, consentx-westpac-demo1 |
| AI4Tradies | ai4tradies, ai4tradies-i94t, ai4tradies-u3y9, ai4tradies-rlt5 |
| Rhythm | the-rhythm-method, rhythm-method |
| Holo | holo-org, holoorg, holo-org-plus, plus.holo-org.com |
| AHC | augmented-humanity-coach, ahc-lead-bridge, chatter-by-ahc |
| T4H control | symbio-dev-control-plane, synapse-prod-control-plane, mcp-command-centre, t4h-remote-mcp-server |
| Neural | neural-ennead-dashboard, neural-evolution-apps, neural-ennead-family |
| Apps shell | t4h-apps, t4h-apps-ntgz, t4h-site-monitor |

### GitHub

A broad search for `vercel.app` found URL-bearing files across multiple evidence classes:

| Evidence class | Example |
|---|---|
| README | TML-4PM/chatter-by-ahc/README.md |
| JSX/TSX app code | TML-4PM/apex-predator-insurance/src/main.tsx |
| API route | TML-4PM/mcp-command-centre/api/agent-feed.ts |
| Next config | TML-4PM/outcome-ready/next.config.js |
| HTML surface | TML-4PM/holo-org/index.html |
| Email/API | TML-4PM/augmented-humanity-coach/api/send-contact-email.ts |
| HTML snapshot | TML-4PM/mcp-command-centre/public/snaps/meeting-followup-fd933479.html |
| Sitemap | TML-4PM/outcome-ready/public/sitemap.xml |

A broad search for `resend` found email/link emitter evidence:

| Evidence class | Example |
|---|---|
| Resend apply emails | TML-4PM/augmented-humanity-coach/api/send-apply-emails.ts |
| Supabase contact email | TML-4PM/enter-australia/supabase/functions/contact-email/index.ts |
| Holo contact email | TML-4PM/holo-org/supabase/functions/send-contact-email/index.ts |
| Early access email | TML-4PM/holo-org/supabase/functions/send-early-access-email/index.ts |
| AHC decision email | TML-4PM/augmented-humanity-coach/api/send-decision-email.ts |
| Supabase decision email | TML-4PM/augmented-humanity-coach/supabase/functions/send-decision-email/index.ts |

This proves the source class is broader than deployed website lists. URLs and surfaces can leak through emails, API handlers, Supabase functions, configs, generated HTML, snapshots, sitemaps, docs, and partner/commercial flows.

## Recommended tables / artefact schema

### url_search_run

| Field | Purpose |
|---|---|
| run_id | Search run ID |
| source_system | GitHub, Vercel, Drive, Gmail, Supabase, Stripe, Lovable, Notion, S3/static |
| query | Search query executed |
| result_count | Number of returned results |
| coverage_status | complete / partial / failed / unavailable |
| error | Error detail if any |
| searched_at | Timestamp |

### url_evidence

| Field | Purpose |
|---|---|
| id | Evidence row ID |
| raw_text | Raw matched URL/string |
| normalised_url | Canonical URL if resolvable |
| source_system | Origin system |
| source_ref | Repo/file/email/doc/deployment ID |
| source_path | Path, subject, URL, or locator |
| evidence_type | literal/generator/config/route/email/payment/auth/webhook/etc |
| context_excerpt | Surrounding context |
| confidence | high/medium/low |
| first_seen_at | First seen timestamp |
| last_seen_at | Last seen timestamp |

### url_surface

| Field | Purpose |
|---|---|
| surface_id | Canonical surface ID |
| domain | Root domain |
| provider | Vercel/Lovable/GitHub/S3/custom/unknown |
| status | unknown/live/broken/preview/internal |
| cluster_key | Probable grouping |
| primary_evidence_id | Main proof source |
| decision | watch/resurface/lift/unplug/park/merge/archive |

## Coverage report must include

- Sources attempted.
- Sources unavailable.
- Queries run.
- Counts by source and query.
- URL evidence count.
- Unique domain count.
- URL generator count.
- Deployment/domain count.
- Unknown surfaces count.
- Duplicate/variant candidates.
- High-risk public surfaces.
- No-write assertion.
- Errors and impact.
- Next safe queue.

## First queued execution payload

File committed:

`inbox/url-surfacing-search-coverage-v1.json`

Commit SHA:

`04efdb6e4b5b0bb39e2247a970216ad8b4d67828`

Expected runtime receipt:

`receipts/runtime/url-surfacing-search-coverage-v1-20260425.json`

## Validation standard

This handover is not complete operationally until Pen/Symbio writes the runtime receipt. The handover itself is complete when both the inbox payload and this doc are committed.

Runtime done means:

- receipt exists,
- source coverage is explicit,
- failures/gaps are explicit,
- no-write assertion is present,
- result counts exist,
- next safe actions are listed.

## Current status

| Item | Status |
|---|---|
| Definition | complete |
| Source matrix | complete |
| Search matrix | complete |
| Schema shape | complete |
| Initial observed evidence | complete |
| Queue payload | committed |
| Handover doc | committed by this file |
| Runtime execution | pending Pen/Symbio |
| Runtime receipt | pending |

