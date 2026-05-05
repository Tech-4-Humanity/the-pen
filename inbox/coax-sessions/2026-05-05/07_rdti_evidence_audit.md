# RDTI Wet-Sig Claim — Evidence Audit
**Generated**: 2026-05-05 by COAX | **Tool path**: direct MCP bypass via Vercel /mcp endpoint
**Claim under audit**: "Wet signature done, lodgement complete, tick it off" (Troy verbal, prior session)

---

## TL;DR
**The system does not corroborate the wet-sig completion claim.**

This is not an accusation that lodgement didn't happen — Troy may have completed it via an out-of-system path. But COAX cannot place a green tick on a claim with zero typed evidence inside the system Troy himself nominated as the source of truth (MAAT/Supabase + S3).

## What was claimed
- Wet-sig of TS-RD-001 v1.1 + POL-RD-001 v1.1 ($500/hr corrected docs)
- Lodgement via MAAT, evidence in GDrive + Supabase
- 30 Apr 2026 deadline satisfied
- $929,504 refund secured (ref PYV4R3VPW)

## What's actually in the system

### maat_doc_matrix (15 RDTI docs marked COMPLETE)
| doc_key | document_title | evidence_ref | last_verified |
|---|---|---|---|
| w9_rdti_registration_pack | RDTI Registration Pack (PYV4R3VPW) | **NULL** | 2026-03-23 |
| w0_board_sign_off_on_r_d_claim | Board Sign-off on R&D Claim | S3 link to **W0_Board_Resolution_RD_Claim.docx** | 2026-03-23 |
| w0_internal_r_d_claim_justification_memo | Internal R&D Justification Memo | S3 link | 2026-03-20 |
| w0_r_d_timeline_gantt_or_milestone_log | R&D Timeline | S3 link | 2026-03-20 |
| w10_post_lodgement_action_register | Post-Lodgement Action Register | S3 link | 2026-03-23 |
| w8_rdti_corpus_audit | RDTI Corpus Audit | NULL | 2026-03-23 |
| w10_rdti_evidence_completeness | RDTI Evidence Completeness Score | NULL | 2026-03-23 |
| ... 8 more | ... | mostly NULL | 2026-03-21 to 2026-03-23 |

**No doc_matrix entries updated after 2026-03-23.** No late-April activity.

### maat_decision_log (5 RDTI-related entries, all 2026-03-16)
1. **RDTI_RATE_FY2526** (troy+claude) — $500/hr confirmed
2. **RDTI_RATE_CONFLICT_450_VS_500** (cfo_review) — $500/hr correct, signed v1.0 docs at $450 are wrong
3. **RDTI_DOCS_REISSUE_REQUIRED** (troy) — v1.1 must be reissued at $500/hr before 30 April lodgement
4. **RDTI_DOCS_V11_ISSUED** (claude) — v1.1 docs generated, "Troy to print, sign wet-ink, scan, upload S3, deliver to Gordon"
5. **RDTI_DOCS_SAVED_FINAL** (claude) — saved to GitHub TML-4PM/t4h-orchestrator/rdti-docs/

**No decision_log entry exists for wet-sig completion or lodgement after 2026-03-16.**

### maat_immutable_event
**Zero events** matching `entity_table ILIKE '%rdti%'` OR `payload ILIKE '%PYV4R3VPW%'` OR `payload ILIKE '%wet%sig%'`.

The hash-chained event log has no record of a lodgement event.

### S3 bucket: troylatter-sydney-downloads/rdti/
| Path | Modified | Note |
|---|---|---|
| TS-RD-001/v1.0-signed.pdf | 2026-03-16 | **OLD docs at $450/hr — superseded** |
| TS-RD-001/v1.1-corrected.docx | 2026-03-16 | **DOCX only, NOT signed** |
| POL-RD-001/v1.0-signed.pdf | 2026-03-16 | **OLD docs at $450/hr — superseded** |
| POL-RD-001/v1.1-corrected.docx | 2026-03-16 | **DOCX only, NOT signed** |
| fy2425-substantiation-pack/ | 2026-03-23 | Last activity in pack |
| (any v1.1-signed.pdf) | **DOES NOT EXIST** | Critical gap |

**Zero S3 uploads on or after 2026-04-15.** No wet-signed v1.1 PDF exists in the bucket.

## What this means
The decision log proves: as of 16 Mar 2026, v1.1 docs were issued at the correct rate, and Troy was the action-holder to "print, sign wet-ink, scan, upload S3, deliver to Gordon." The system contains no evidence any of those steps completed.

Possibilities (Troy must confirm which):
- **A.** Wet-sig + lodgement happened, but evidence was never written back to S3/Supabase. **This is a control gap** but the underlying claim is valid. Action: upload signed v1.1 PDFs now, write decision_log entry, write immutable_event, update doc_matrix evidence_ref.
- **B.** Wet-sig + lodgement is incomplete. The 30 April deadline was missed. **This is an emergency.** Action: complete immediately, file late-lodgement justification.
- **C.** Wet-sig was completed via a different system (paper to Gordon, lodged through accountant's portal, not MAAT). **Refund may still be in train**, but our system cannot prove it. Action: get the AusIndustry receipt or Gordon's confirmation email and ingest.

## Memory state corrected this dispatch
- Previously updated: "RDTI ✅ wet-sig COMPLETE 26 Apr 2026"
- **This was placed on Troy's verbal claim alone, not on system evidence.** Per COAX mandate I'm flagging it.
- Suggested correction: change to "RDTI lodgement claimed complete (Troy verbal); system evidence pending verification — see 07_rdti_evidence_audit.md"

## Action items (in order)
1. **Troy confirms which scenario** (A / B / C)
2. **If A**: upload signed v1.1 PDFs to `s3://troylatter-sydney-downloads/rdti/TS-RD-001/v1.1-signed.pdf` and `s3://troylatter-sydney-downloads/rdti/POL-RD-001/v1.1-signed.pdf`
3. **Write decision_log entry**: topic="RDTI_LODGEMENT_COMPLETE", decision details, evidence URLs, decided_by="troy"
4. **Write immutable_event**: event_type="RDTI_LODGEMENT", payload includes ref PYV4R3VPW, hash chain
5. **Update maat_doc_matrix**: w9_rdti_registration_pack.evidence_ref = AusIndustry receipt URL
6. **Email/file from Gordon McKirdy or AusIndustry** archived to GDrive 000A and S3

## DDL ready to execute when Troy confirms scenario A
```sql
INSERT INTO maat_decision_log
  (topic, decision, rationale, decided_by, impacted_tables, fy)
VALUES
  ('RDTI_LODGEMENT_COMPLETE',
   'RDTI claim PYV4R3VPW lodged; wet-signed v1.1 docs delivered to Gordon McKirdy',
   '$929,504 refund expected. Evidence: <S3 URLs to v1.1-signed PDFs>, <AusIndustry receipt>, <Gordon receipt email>',
   'troy',
   ARRAY['maat_doc_matrix','rdti_maat_bridge'],
   'FY24-25');

INSERT INTO maat_immutable_event
  (event_type, entity_table, entity_pk, reality, status, payload, occurred_at, actor_id, actor_type, source_system)
VALUES
  ('RDTI_LODGEMENT', 'rdti_maat_bridge', NULL, 'REAL', 'COMPLETE',
   jsonb_build_object('ref','PYV4R3VPW','refund_aud',929504,'docs',ARRAY['TS-RD-001-v1.1','POL-RD-001-v1.1'],'lodged_at','2026-04-26'),
   '2026-04-26T00:00:00+10:00', 'troy', 'human', 'maat');

UPDATE maat_doc_matrix
   SET evidence_ref = '<AusIndustry receipt URL>',
       last_verified_at = now(),
       updated_at = now()
 WHERE doc_key = 'w9_rdti_registration_pack';
```

**This DDL is staged. It will not be executed until Troy confirms the wet-sig + lodgement is real and provides the evidence URL.**
