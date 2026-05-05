# Strip-Consume Execution Plan — SPEC-003
**Owner**: COAX | **Squad**: P10-B4 (Ryan Taylor) lead, P10-A8 (Maurice Labbé) + P10-G8 (Amy Holland) operators, P08-B1 (Caroline Brown) + P08-I7 (Filomena Pazos) vault writers
**Status**: Plan staged — execution gated on bridge restoration
**Generated**: 2026-05-05

---

## Doctrine Recap (non-negotiable)
- **3 CORE retained**: augmented-humanity-coach, workfamilyai, holoorg
- **20 INVENTORY** to strip-archive
- **4-layer extraction MANDATORY** before any archive: data, logic, intent, identity
- **External-facing identities are write-once, never deleted**
- **HITL on every destructive op** — no exceptions

## Per-Business Strip Protocol (executed in this exact order)

### Layer 1: DATA
- Snapshot Supabase rows belonging to the business (table-by-table dump to `vault.data.<slug>`)
- SHA256 dedup against existing vault to avoid double-write
- Manifest: row counts per table, total bytes, snapshot timestamp
- **Verify**: row count in vault matches source before proceeding

### Layer 2: LOGIC
- Inventory all Lambda functions tagged to slug → export source + env vars (env vars REDACTED and stored separately)
- Inventory Vercel deployments → capture build config, env keys (not values)
- Inventory GitHub repos → mirror to `TML-4PM/vault-<slug>` as read-only archive
- **Verify**: function/deployment/repo count matches discovery scan

### Layer 3: INTENT
- Pull every doc, page, sheet, form referencing slug from GDrive → copy to `GDrive 000V/<slug>/`
- Capture original brief, customer letters, founder voice notes
- Write `INTENT.md` summarising what the business was for, why it spun up, why it's being archived
- **Verify**: intent doc is human-readable, not just a file dump

### Layer 4: IDENTITY (write-once)
- Domain, ABN, social handles, brand IP → `vault.identities` table
- Marked `is_active = false`, `archived_at = now()`, `revival_owner = COAX`
- Domain renewal calendar entry created for 12 months ahead (don't lose names)
- **Verify**: identity row exists, archived flag set, calendar entry confirmed

## INVENTORY Slug Register (placeholder — needs Troy confirm)
The 20 INVENTORY slugs are not enumerated in current memory. **Action required**: pull from `ops.standard_knowledge_register WHERE state IN ('INVENTORY','HOLD')` once bridge is back. Until then, framework stands and runs against any list provided.

## HITL Gate Sequence (per business)
| Gate | Approver | Trigger |
|---|---|---|
| Pre-strip green-light | Troy | After Layer 1 manifest produced, before Layer 2 starts |
| Identity write | Troy | Before vault.identities row inserted (write-once) |
| Final archive | Troy | After all 4 layers verified, before source systems are archived |

## Bridge-Down Posture
- Cannot dump Supabase rows from this session
- Cannot mirror GitHub repos
- Cannot move GDrive files
- **Can do now**: prep slug list, build per-business checklist files, draft INTENT.md scaffolds, draft vault DDL

## DDL Staged for Bridge Return
```sql
-- vault.data.<slug> — created per business at strip time
-- (template; one per slug, not collapsed)

CREATE TABLE IF NOT EXISTS vault.identities (
  identity_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  identity_type text NOT NULL CHECK (identity_type IN ('domain','abn','social','brand_ip','email','phone')),
  identity_value text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  archived_at timestamptz,
  revival_owner text,
  next_renewal_date date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT identities_unique UNIQUE (slug, identity_type, identity_value)
);
-- WRITE-ONCE: deletes blocked by RLS policy + DB role
```

## Definition of Done (per business)
1. All 4 layers extracted with manifests
2. Vault entries verified, SHA256 matches
3. Source systems archived (not deleted) and marked read-only
4. INTENT.md committed to GDrive 000V
5. Identity calendar entry confirmed
6. Strip-receipt logged to ledger with 3 SHA invariants (data, logic, intent)
