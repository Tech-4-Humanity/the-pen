# SNAPS / AGENTSNAPS / SUPERSNAPS — FULL HANDOFF

## Executive summary
This product family is a browser-led unfinished work system.

- Snaps = capture
- AgentSnaps = capture + act
- SuperSnaps = capture + act + close

Core doctrine:
A Snap is a browser-originating unit of unfinished or finishable work.

## Product definitions
### Snaps
Capture, preserve, group, search, and restore browser-originating work.
Promise: Don’t lose browser work.

### AgentSnaps
Interpret captured browser state, generate tasks, attach workers, and produce outputs.
Promise: Move browser work forward.

### SuperSnaps
Enforce closure, recovery, escalation, and proof.
Promise: Work gets finished, recovered, or intentionally closed.

## Boundary rules
- Browser-led only
- No full ecosystem ingest
- No drift into tab manager / generic AI helper / automation blob

## Lifecycle
Snaps: capture → store → restore
AgentSnaps: capture → cluster → task → execute → output
SuperSnaps: capture → cluster → task → execute → recover → prove → resolve

## Completion states
DONE, DELIVERED, PUBLISHED, PARKED, PURGED, BLOCKED, FAILED, DELEGATED

## Worker model
Capture Worker
Cluster Worker
Task Worker
Execution Worker
Recovery Worker

## Core rules
- No limbo
- No fake completion
- Recovery = reinterpretation

## Feature layers
Snaps: capture, restore, group, search
AgentSnaps: clustering, tasks, workers, outputs
SuperSnaps: closure, recovery, escalation, proof, governance

## Pressure gradient
Snaps = low
AgentSnaps = medium
SuperSnaps = high

## Success metrics
Snaps: capture + restore
AgentSnaps: action + output
SuperSnaps: completion + recovery + closure

## Instruction
Extend existing Snaps artefacts. Do not rebuild from zero.
