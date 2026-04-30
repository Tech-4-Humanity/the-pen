# Synal Signal Composer - Wave 10 Build Pack

Status: PARTIAL until runtime receipt exists.
Route: Pen.
SSS: A3-B2-C5-D5-E3.

## Purpose
Build the Synal Signal Composer as a universal intent and routing layer for humans, AI agents, and systems. This is not a greenfield product. It extends the existing Signal Composer, SSS, FMC, Synal Place, Control Tower, Pen, Bridge, and Reality Ledger concepts.

## Final enhancement pass

1. Dual-mode composer: power users type codes, guided users use a stepper with human labels.
2. AI suggestion: messy text becomes a proposed signal tag and structured object.
3. Place-aware behaviour: inbox, browser, boardroom, war room, mobile, meeting, support, and control tower each get different default behaviours.
4. Personal and role weighting: CEO, COO, CFO, sales, ops, support, engineering, and compliance can weight value differently.
5. Decision rail: critical decisions are separated from general communication.
6. Noise sink: low-value items are batched or suppressed without losing auditability.
7. Drift detection: catch overuse of critical urgency, stale decisions, and bad tagging patterns.
8. Ambient capture: voice notes, meetings, screenshots, whiteboards, browser fields, mobile share sheets.
9. Cross-org routing: partner, vendor, regulator, contractor, customer, and internal team lanes.
10. White-label console: industry packs, tenant-specific taxonomy, and commercial packaging.

## Architecture

Layer 1: Human input
- SSS string
- FMC signal tags
- Voice, tap, stepper, text, AI suggestions

Layer 2: Signal core
- Parser
- Validator
- Classifier
- Policy engine
- Weighting engine
- Context enrichment
- Audit events

Layer 3: Synal Places
- Browser overlay
- Email
- Chat
- Calendar
- Docs
- Meetings
- Mobile
- Control Tower
- Agent runtime

## Required tables

- synal_signal_registry
- synal_signal_events
- synal_signal_queue
- synal_place_registry
- synal_signal_policy
- synal_weight_profiles
- synal_route_matrix
- synal_signal_receipts

## Minimum routing rules

- [D][V1][E][T0] = escalate, create decision task, optional calendar block, log to control tower.
- [A][V2][T][T1] = create task, assign owner, log to control tower.
- [I][V3][X][T4] = log, summarise, do not interrupt.
- [N][V5][X][T4] = batch or suppress, learn filter.

## Approval model

Correct approval path: native GitHub PR review approval.
Incorrect approval path: free-text comment treated as approval.

No runtime state is REAL until there is a receipt and evidence.

## Definition of done

1. Build pack committed to Pen.
2. Implementation bundle generated or queued.
3. Approval gate available via PR where needed.
4. Runtime handoff envelope present.
5. No pretend receipt language used.
6. Status remains PARTIAL until runtime receipt exists.
