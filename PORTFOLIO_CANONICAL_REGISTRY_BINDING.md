# Portfolio Canonical Registry Binding Contract

Status: PARTIAL
Created: 2026-05-19
Owner: Portfolio Control / Gatekeeper
Canonical repo: TML-4PM/the-pen

## Result

The old canonical portfolio registry has been recovered as a two-layer truth model:

1. `portfolio_business_registry` is the canonical business identity map.
2. `portfolio_social_lock_operating_matrix_bridge_ready.xlsx` is the current bridge-ready operating lock sheet for domains, repos, Vercel projects, Lovable projects, public URLs, evidence state, lock state, owner/agent, downstream dependencies, and next action.
3. `org.atom` / `org.atom_event` is the universal binding layer for long-term organisational atoms, state transitions, and evidence.
4. `cap_store` is not structural truth. It remains credential, metadata, contact, key, brand, and operational access surface only.

## Source-of-truth hierarchy

1. Business identity: `portfolio_business_registry`
2. Organisational atom: `org.atom`
3. Transition/event evidence: `org.atom_event` and Reality Ledger
4. Domain and site intelligence: `sites_registry`, `v_domain_map_full`, and the bridge-ready lock sheet
5. Deployment truth: Vercel project/deployment registry, bound by canonical entity ID
6. Code truth: GitHub repository registry, bound by canonical entity ID
7. Folder truth: Google Drive folder registry, bound by canonical entity ID
8. Receipt truth: receipt ledger, GitHub issue/commit URL, Bridge receipt ID, deployment ID, workflow run ID, and hash
9. Secrets/access truth: `cap_store` / `cap_secrets`, never used as structural source

## Binding rule

Every folder, repo, Vercel deployment, domain, Lovable project, Stripe product, receipt, and dashboard row must carry or resolve to one stable `canonical_entity_id`.

No resource is REAL unless it has:

- canonical_entity_id
- resource_type
- provider
- provider_resource_id or URL
- ownership state
- lifecycle state
- evidence class
- last_verified_at
- receipt_ref or proof_ref
- source_of_truth_table

## Minimum resource binding table

Recommended table: `portfolio_resource_binding`

```sql
create table if not exists portfolio_resource_binding (
  id uuid primary key default gen_random_uuid(),
  canonical_entity_id text not null,
  canonical_entity_name text,
  resource_type text not null check (resource_type in (
    'folder','repo','vercel_project','vercel_deployment','domain','lovable_project','stripe_product','stripe_price','receipt','dashboard','secret_ref','document','asset'
  )),
  provider text not null,
  provider_resource_id text,
  resource_url text,
  resource_name text,
  source_of_truth_table text not null,
  source_record_ref text,
  lifecycle_state text not null default 'PARTIAL',
  evidence_class text not null default 'PARTIAL',
  lock_state text default 'UNLOCKED - PRE LOCK',
  owner_agent text default 'Portfolio Control / Gatekeeper',
  last_verified_at timestamptz,
  receipt_ref text,
  proof_hash text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (canonical_entity_id, resource_type, provider, coalesce(provider_resource_id, resource_url))
);
```

## Import sources

Primary import source:

- Google Drive file: `portfolio_social_lock_operating_matrix_bridge_ready.xlsx`

Additional historical sources:

- `portfolio_domain_operating_lock_sheet_updated.xlsx`
- `portfolio_domain_operating_lock_sheet.xlsx`
- `site-url-registry-full.html`
- Supabase tables: `portfolio_business_registry`, `sites_registry`, `v_domain_map_full`, `mcp_business_registry`, `cap_store`, `cap_secrets`

## Field mapping from bridge-ready lock sheet

- Canonical Entity -> canonical_entity_name
- Canonical Name / Slug -> canonical_entity_id fallback
- Domain -> resource_type `domain`, provider `R53/Registrar` where known
- Vercel Project -> resource_type `vercel_project`, provider `Vercel`
- GitHub Repo -> resource_type `repo`, provider `GitHub`
- Lovable Project -> resource_type `lovable_project`, provider `Lovable`
- Public URL / Domain -> resource_url
- Evidence Class -> evidence_class
- Lock State -> lock_state
- Owner / Agent -> owner_agent
- Downstream Dependencies -> notes/dependencies
- Fix Schedule / Next Action -> notes/next_action

## Execution order

1. Snapshot `portfolio_business_registry`.
2. Load the bridge-ready lock sheet.
3. Normalize canonical entity names and slugs.
4. Insert one resource row per non-empty domain, Vercel project, GitHub repo, Lovable project, and public URL.
5. Join against Drive folder registry and receipt ledger when available.
6. Mark bindings without verification as PARTIAL.
7. Promote only rows with runtime proof to REAL.
8. Emit receipt pack: row counts, missing bindings, duplicate domains, orphan repos, orphan Vercel projects, unbound folders, unbound receipts.
9. Write Reality Ledger event.
10. Surface Command Centre CCQ: `portfolio_resource_binding_health`.

## Required CCQs

- `portfolio_resource_binding_health`
- `portfolio_orphan_domains`
- `portfolio_orphan_repos`
- `portfolio_orphan_vercel_projects`
- `portfolio_unbound_drive_folders`
- `portfolio_unbound_receipts`
- `portfolio_duplicate_canonical_bindings`
- `portfolio_ready_to_lock`
- `portfolio_blocked_by_missing_runtime_proof`

## Runtime status

PARTIAL because the binding contract is now committed to the canonical Pen repo, but Supabase/Bridge execution has not been run from this session.

## Gaps

- Supabase mutation not executed from this session.
- Bridge receipt not available from this session.
- Vercel project enumeration not fully fetched because team ID needs runtime selection.
- Drive folder registry not exhaustively enumerated.
- Receipt ledger table name not verified.
- Runtime smoke proof still needed for each domain/deployment.

## Next action

Bridge/Synapse should execute the SQL binding table, import the bridge-ready lock sheet, bind all known resources to canonical_entity_id, run orphan/duplicate checks, write the Reality Ledger event, and return a receipt pack.

## Elevation

This promotes portfolio governance from scattered sheets and memory into one binding contract: one entity ID, many resources, one evidence path, one receipt ledger.

## Pressure flags

- no_new_value risk if more sheets are created without runtime import
- drift risk if cap_store is reused as structural source
- orphan risk across Vercel/GitHub/Drive unless binding checks run weekly
- fake completion risk unless REAL promotion requires runtime proof

## Score

0.72 PARTIAL

Reason: strong source recovery and canonical repo binding completed; runtime binding and Bridge receipt still pending.
