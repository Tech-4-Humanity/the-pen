# CalmBound Phase 1 Threat Model v1.0

**Status:** architecture published; runtime not deployed or security-tested.

## Protected assets

- Household membership and authority
- Child and teenager identity data
- Mode and agreement state
- Permission and consent records
- Event ledger and evidence integrity
- Integration credentials
- Billing entitlement state
- Emergency and carer information

## Trust boundaries

1. Consumer clients to runtime API
2. Runtime API to PostgreSQL/Supabase
3. Runtime to router/device integrations
4. Runtime to Stripe and other partners
5. Runtime to telemetry and evidence stores
6. One household to another household
7. Adults to children and carers within one household

## Principal threats and controls

| Threat | Impact | Required control | Verification |
|---|---|---|---|
| Forged household authority | Unauthorised control or disclosure | Contextual permission service, signed identity, deny by default | Negative authority tests |
| Cross-household data access | Privacy and safety breach | Household-scoped queries, RLS defence in depth, tenant identifiers in traces | Isolation tests |
| Permission that fails to expire | Excess authority | Scheduled expiry worker, database status transition, alert and receipt | Time-travel expiry test |
| Replayed or altered event | False evidence | UUID idempotency, canonical SHA-256 integrity hash, immutable ledger policy | Replay and drift tests |
| Compromised service credential | Full database access | Secrets manager, rotation, no browser service key, least privilege | Secret scanning and rotation exercise |
| Covert child monitoring | Rights and trust harm | Prohibited telemetry fields, no browsing history, visible policy | Data-flow review |
| Unsafe multi-home merge | Disclosure or coercive control | Separate household domains, explicit bilateral agreement, contested-access freeze | Multi-home abuse scenarios |
| Stripe webhook forgery | Incorrect entitlement | Signature verification and idempotent lifecycle processing | Signed/unsigned webhook tests |
| Router action reported as successful when failed | False enforcement claim | Device acknowledgement, timeout, degraded state, recovery event | Disconnect and timeout tests |
| AI creates hidden judgement | Child or parent harm | Advisory-only policy, model logging, prohibited output tests | Governance evaluation suite |
| Destructive deletion without evidence | Irrecoverable data loss | Scoped deletion plan, retention checks, deletion receipt, recovery boundary | Deletion rehearsal |
| Sensitive data in logs | Privacy breach | Structured allowlist, prohibited field scanner, redaction | Log inspection |

## Abuse cases requiring human-authority review

- Contested guardianship or household authority
- Family violence or coercive-control indicators
- Requests to export another household's records
- School or organisation access beyond its context
- Emergency access extensions
- Legal demands and preservation orders

## Required release gates

- Authentication and authorisation penetration test
- Cross-household isolation test
- RLS review
- Dependency and secret scan
- Event-integrity and replay test
- Permission-expiry recovery test
- Privacy and child-impact assessment
- Accessibility validation
- Incident and rollback exercise

No runtime may be classified REAL until these gates produce stored evidence and a read-back receipt.
