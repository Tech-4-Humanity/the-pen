# Domain Control Cleanup Working State — 2026-04-26

## Current working artifact
A cleaned one-sheet register has been generated locally in ChatGPT:

- `domain_control_cleaned_working_sheet.xlsx`

## What changed
The sheet is no longer just a data capture sheet. It now contains cleanup/reconciliation columns and decisions:

- canonical name
- domain
- called across sites
- decision bucket
- recommended action
- match confidence
- matched sources
- R53 zone ID
- registrar fields
- Vercel project/name/id
- GitHub repo/visibility/archive status
- Lovable project/id/url/visibility/published
- web host current
- mail current
- IP/MX/SPF/DMARC/DKIM/CNAME/A/NS/SOA/TXT placeholder fields
- recordset export command per hosted zone
- recordset details to capture
- storage bucket
- priority
- status
- evidence
- notes

## Counts in generated sheet

| Row type | Count |
|---|---:|
| DOMAIN | 60 |
| VERCEL_SPARE | 29 |
| GITHUB_SPARE | 83 |
| LOVABLE_SPARE | 67 |

## Current logic

### Decision buckets

| Bucket | Meaning | Action |
|---|---|---|
| KEEP / MAP COMPLETE | Domain has enough source matches and registrar ownership | Validate DNS records, then lock row |
| REVIEW OWNERSHIP | R53 hosted zone exists but registrar ownership is missing from Route53Domains list | Confirm external registrar or stale hosted zone |
| SPARE DOMAIN / PARKING REVIEW | R53 domain has no project/repo/app match | Decide park, future brand, or stale zone |
| SPARE PROJECT / MAP OR ARCHIVE | Vercel/GitHub/Lovable object has no R53 domain match | Map to domain/business or move to spare backlog; no delete |

## AWS record-set command added per R53 row

```bash
aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID> > aws/route53-recordsets/<domain>.json
```

## DNS details to capture per hosted zone

- A
- AAAA
- CNAME
- MX
- TXT/SPF
- TXT/DMARC
- TXT/DKIM
- CAA
- NS
- SOA
- TTL
- AliasTarget

## Rules

- Do not delete anything automatically.
- Archive/move only after decision.
- Route53 hosted zone is DNS control evidence, not necessarily ownership.
- Route53Domains proves ownership only for returned domains.
- Lovable is a build/prototype source, not DNS authority.
- Capped Vercel connector result is not full inventory. Use raw Vercel API/CLI for full export.
