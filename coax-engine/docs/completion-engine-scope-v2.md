# COAX Completion Engine v2

## Scope correction

This is not an assignment engine. It is a completion engine.

The job is to complete work, not move work between agents.

## Core loop

Discover unfinished work -> assign executor -> execute next action -> prove output -> recover if proof fails -> create handover if recovery fails -> force pickup -> repeat until proven complete.

## Business model rule

No hard-coded business count.

Use a table-driven business registry. The registry may contain any number of businesses, brands, products, groups, or operating units.

Work items may bind to a biz_key, or remain platform/research/personal/unbound.

## Done rule

A work item is complete only when it has produced outputs, a completion receipt, evidence, and a REAL classification.

Assignment alone is not completion.

## Handover rule

Every incomplete item must carry context, last action, blocker, artefacts, next executable payload, recommended executor, acceptance gates, and timeout.

No item may sit half-finished without a handover packet.
