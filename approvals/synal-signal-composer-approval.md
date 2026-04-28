# APPROVAL PACKAGE: Synal Signal Composer Control Layer

## Approval request

Approve build of the Synal Signal Composer control layer.

This PR exists so approval can happen using GitHub's native review button.

## Decision

Approve this PR to allow the next stage:

1. Generate implementation bundle
2. Commit bundle to GitHub
3. Send handoff back to Bridge/Pen
4. Wait for runtime receipt
5. Close only after evidence

## Scope

### Signal Core
- Taxonomy: `[TYPE][VALUE][ACTION][TIME][DOMAIN]`
- Parser
- Validator
- Router
- Weighting profiles
- Policy rules
- Audit/events
- Control tower config

### Synal Placement Layer
- Place registry
- Browser overlay
- Sticky Signal Card
- Context capture
- Place-aware defaults
- Synal route queue
- Control tower roll-up

## Reuse-first rule

This is not greenfield.

Reuse parent Pen jobs:

| Job | Commit |
|---|---|
| `signal-composer-control-layer-2026-04-27-001` | `5158cd90683faa61517d40b67107681fe87febfb` |
| `synal-signal-composer-placement-extension-2026-04-27-002` | `89d3db29e9896e7b80995db5fb928bb2b42d617a` |

## Controls

| Tier | Rule |
|---|---|
| AUTO | inspect, enqueue, generate assets |
| LOG | write logs/receipts |
| GATED | deploy, RLS, extension publication |
| BLOCKED | payments, IAM, credentials, legal |

## Acceptance criteria

- No duplicate standalone product
- Synal grouping preserved
- Signal Core and Synal Placement linked
- All writes idempotent
- Browser/overlay starts suggest-only
- Signals include owner/org/place/evidence metadata
- Control tower filters by type/value/action/time/domain/owner/org/place
- Runtime receipt required before closure

## Approval signal

A GitHub PR review with **Approve** is the required approval signal.
