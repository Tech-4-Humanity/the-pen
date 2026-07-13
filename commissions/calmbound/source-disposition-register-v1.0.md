# CalmBound Source Disposition Register v1.0

**Date:** 2026-07-13  
**Purpose:** Preserve useful discovery while preventing prototypes from becoming accidental production architecture.

## Disposition states

- **KEEP:** Canonical concept retained.
- **REFACTOR:** Useful implementation pattern, rebuilt under canonical architecture.
- **ARCHIVE:** Preserved as discovery evidence; no further development.
- **DISCARD:** Do not migrate into production.

## Artefact decisions

| Artefact | Decision | Retained value | Excluded from production |
|---|---|---|---|
| `production_portal_html.html` | REFACTOR + ARCHIVE | Plain-language guest boundary, minimal acknowledgement, captive-portal intent, privacy framing | Browser-only logging, user-agent device classification, success-URL guessing, back-button trapping, unsupported enforcement assumptions |
| `kvm_v2_single_build.html` | ARCHIVE | Original wedge, problem framing, setup journey, portal preview, physical-router proposition | Static page architecture, hard-coded pricing, unverified legal alignment, placeholder links, production claims |
| `kvm_v2_single_build (1).html` | REFACTOR + ARCHIVE | CalmBound umbrella, dual consumer/guest views, trust strip, plan comparison, privacy cards, visible overrides | Monolithic HTML/CSS/JS, cosmetic toggles, local demo persistence, hard-coded plans, placeholder checkout, unsupported schools availability |
| `calmbound_backend_stripe_supabase (1).js` | REFACTOR + ARCHIVE | Hosted Stripe Checkout pattern, signed webhook concept, server-side database access, initial subscription reconciliation | Single-file Lambda architecture, minimal schema, public household lookup risk, insufficient validation, incomplete webhook lifecycle, placeholder environment and URLs |
| `Pasted text(233).txt` | KEEP AS RESEARCH | Product expansion history, platform thesis, growth loops, ecosystem and guardrails | Conversation claims treated as execution evidence |
| `Pasted text(234).txt` | KEEP AS RESEARCH | Iteration history and explicit REAL/PARTIAL distinctions | Artefact names or staged integrations treated as live systems |

## Canonical concepts retained

- Kids Visit Mode as the acquisition wedge
- CalmBound as the product umbrella
- Household Coordination Infrastructure as the category
- The house explains the rule
- Guest experience without mandatory application installation
- Quiet Hours and household modes
- Visible, reasoned overrides
- Progressive autonomy
- Fairness across adults and children
- No advertising or sale of child data
- Router and telco distribution
- Ambient rather than attention-maximising use
- Multi-home neutrality as a later high-risk capability

## Concepts requiring qualification

- Under-16 social-media-law claims require current legal review before publication.
- School and community deployment remains roadmap until a validated pilot exists.
- Health, insurance and research integrations require separate governance approval.
- Cross-household social proof is excluded unless privacy and safety risks are resolved.
- Behavioural analytics must never become hidden household or child scoring.

## Production replacement map

| Prototype element | Canonical replacement |
|---|---|
| Static plan cards | Entitlement and pricing registry |
| Checkout modal | Hosted billing flow through billing adapter |
| Local/session storage | Authenticated runtime and persistence adapter |
| Hard-coded rules | Versioned mode and rule schemas |
| Toggle mockups | Permission-checked commands with observed results |
| Console acknowledgement | Event envelope, ledger and evidence receipt |
| Captive redirect guessing | Router-specific adapters with tested fallback |
| Monolithic CSS | Accessible component and token system |
| Page-specific copy | Versioned messaging and content registry |
| One household table | Household ontology, graph and scoped data stores |

## Archive rule

Archived artefacts may be consulted for copy, layout, user journeys and original intent. They must not be deployed, extended or represented as the current system without passing canonical security, policy, data, accessibility and runtime gates.
