# Execution Doctrine — Bundles Only

Status: REAL for instruction capture.  
Date: 2026-07-06 Australia/Sydney.

## Rule

All future execution will be commissioned, tracked, receipted, and reported as bundles, not sprints.

## Bundle definition

A bundle is a coherent execution package with objective, scope, owner, dependencies, artefacts, receipts, validation status, gaps, recovery actions, and next bundle.

## Required bundle fields

- bundle_id
- title
- objective
- source inputs
- target repository or location
- artefacts to create or update
- validation expected
- blockers
- receipt path
- status classification

## Tracking artefacts

- bundle ledger
- file manifest
- receipt index
- blocker register
- recovery register
- decision log
- validation record

## Reporting format

- status
- result
- evidence
- gaps
- next action
- confidence

## Status classes

- REAL: executed with receipt and observable evidence
- PARTIAL: artefact exists but runtime or complete validation is missing
- BLOCKED: required dependency is missing
- ASPIRATIONAL: design intent only

## Receipt rule

No receipt means not REAL.

## Reporting rules

- Do not report future work as complete.
- Do not describe unexecuted design as runtime.
- Do not call an artefact REAL without receipt.
- Do not hide blockers.
- Do not frame future execution as sprints.

## Canonical wording

Use bundle commissioned, bundle executing, bundle receipted, bundle PARTIAL, bundle REAL, bundle BLOCKED, and next bundle.

## Application

This doctrine applies immediately to Agora Intelligence Platform and all future T4H execution streams handled through this lane.
