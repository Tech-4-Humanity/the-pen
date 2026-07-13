# ATO and Research — Canonical Source of Truth

**Owner:** Troy Latter / Tech 4 Humanity  
**Control repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL  
**Last established:** 2026-07-14 Australia/Sydney

## Decision

This directory is the canonical control surface for ATO, RDTI and research evidence.

- **GitHub (`TML-4PM/the-pen`) owns:** versioned manifests, schemas, publication source, deployment automation, change history and receipts.
- **Supabase owns:** live structured records and queryable evidence data.
- **S3 owns:** immutable published evidence packs and public/private distribution objects.
- **Google Drive owns:** working copies and human collaboration only.
- **Chat/Claude/ChatGPT threads own nothing:** they are intake and discussion sources until material is committed and receipted.

## Truth hierarchy

1. Successful runtime execution receipt
2. S3 object metadata and checksum
3. Git commit and deployment workflow result
4. Supabase query result captured with timestamp
5. Signed or authoritative external document
6. Google Drive working copy
7. Thread narrative or memory

No item is REAL merely because a chat response says it was created.

## Claimed but not yet verified from the Claude thread

The following identifiers were reported but have not been independently observed in this execution context:

- `core.ato_review_manifest`
- `core.refresh_ato_review_manifest()`
- `public.v_ato_review_manifest`
- `public.v_truth_index`
- `public.v_doc_canonical_registry`
- `core.v_study_ip_rdti_chain`
- ledger id `ac6d9586-0141-4d30-8acf-28c04247b247`
- ledger id `5a3f0f47-bda4-431f-b3d8-76803e0d89bf`
- PDF SHA-256 `a947fc27998826e1b40fcbdaed9f0da8e86d8b28d8eb3610a48eb645e6125ce5`

Until queried or matched against real artifacts, these remain **UNVERIFIED / PARTIAL**, not REAL.

## Required canonical files

- `manifest.json` — all evidence items, locations, owners, dates, checksums and classification
- `public/index.html` — evidence library landing page
- `public/T4H_ATO_Evidence_Pack_v1.pdf` — canonical published pack
- `receipts/` — deployment and validation receipts
- `.github/workflows/deploy-ato-evidence-pack-s3.yml` — controlled publication path

## Publication contract

A release becomes REAL only when all are present:

1. PDF exists in this repository or is supplied as a workflow artifact.
2. Local SHA-256 equals the manifest checksum.
3. GitHub Actions deployment succeeds.
4. S3 `head-object` returns the expected key, content type and checksum metadata.
5. The published URL returns HTTP 200.
6. A receipt records commit SHA, workflow run, bucket, object key, ETag/checksum and verification timestamp.

## Current gaps

- The PDF referenced in the Claude thread is not available in this conversation or repository.
- AWS bucket, role and CloudFront configuration have not been observed here.
- Supabase objects and counts have not been queried here.
- Therefore the evidence pack is **not proven live on S3**.

## Next executable action

Place the canonical PDF at:

`ato-research/public/T4H_ATO_Evidence_Pack_v1.pdf`

Then commit it. The deployment workflow will publish and verify it when the required GitHub secrets/variables are configured.
