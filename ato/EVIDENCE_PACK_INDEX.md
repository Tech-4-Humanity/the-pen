# T4H ATO Evidence Pack v1.0

**Status:** REAL · Ledger ID: 5a3f0f47-bda4-431f-b3d8-76803e0d89bf

**Generated:** 2026-05-27 03:22:37 UTC  
**Pages:** 9 | **Documents:** 85 | **Size:** 26,945 bytes  
**SHA-256:** `a947fc27998826e1b40fcbdaed9f0da8e86d8b28d8eb3610a48eb645e6125ce5`  

## Contents

- **§1:** Regulatory basis (Div 355 ITAA 1997, source-of-truth registries)
- **§2:** Executive summary (verified data artifacts, BLOCKED list, PARTIAL list)
- **§3:** 85-document evidence matrix (all sections, priority/source/status/classification)
- **§4:** Director attestation (6-point sworn statement, signature block)
- **§5:** Fingerprint + V6 compliance (SHA-256 replay receipt, constitutional self-check)

## Downloads

**Local path:** `/mnt/user-data/outputs/T4H_ATO_Evidence_Pack_v1.pdf`  
**GitHub release:** [Pending upload as artifact]
**S3 mirror:** `s3://troylatter-sydney-downloads/rdti/substantiation-pack-fy2425/T4H_ATO_Evidence_Pack_v1.pdf` (network access blocked; manual push required)

## Metadata

| Field | Value |
|---|---|
| Entity | Tech 4 Humanity Pty Ltd |
| ABN | 70 666 271 272 |
| FY | FY2024/25 |
| RDTI ID | PYV4R3VPW |
| Review date | 2026-06-10 |
| Director | Troy Michael Latter |
| Accountant | Andrew Douglas (Hales Redden) |
| Classification breakdown | 12 REAL · 46 PARTIAL · 27 BLOCKED |

## Verification

To verify pack integrity:

```bash
sha256sum T4H_ATO_Evidence_Pack_v1.pdf
# Expected: a947fc27998826e1b40fcbdaed9f0da8e86d8b28d8eb3610a48eb645e6125ce5
```

Canonical source: `public.v_doc_canonical_registry` (Supabase lzfgigiyqpuuxslsygjt)  
Replay query: `SELECT * FROM public.v_doc_canonical_registry ORDER BY section, classification, doc_key;`

## Ledger Entry

core.reality_ledger ID: `5a3f0f47-bda4-431f-b3d8-76803e0d89bf`  
Classification: REAL  
Evidence count: 85  
Classified at: 2026-05-27 03:22:37 UTC  
Reason codes: `evidence_pack_generated`, `sha256_fingerprinted`, `single_truth_source`, `andrew_douglas_ready`
