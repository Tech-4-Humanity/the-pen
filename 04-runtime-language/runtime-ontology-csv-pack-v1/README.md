# Runtime Ontology CSV Pack V1

Status: PARTIAL -> repository-bound schema pack created; Bridge/runtime ingestion pending.

This folder materialises the runtime language ontology into concrete CSV headers and seed rows. It supports the LANGUAGE_AND_ONTOLOGY_CONTRACT_V1 implementation backlog.

## Files

01_NOUNS.csv
02_VERBS.csv
03_STATES.csv
04_CLOSURE.csv
05_EVIDENCE.csv
06_AUTHORITY.csv
07_ESCALATION.csv
08_OFFBOARDING.csv
09_PERSONAL_VOCABULARY.csv
10_RELATIONSHIPS.csv
11_STATE_TRANSITIONS.csv
12_RUNTIME_SURFACES.csv
13_INTENTS.csv
14_OBLIGATIONS.csv
15_RECEIPTS.csv
16_FAILURE_PATTERNS.csv
17_HUMAN_SIGNAL.csv
18_EXECUTION_GRAMMAR.csv
19_EXECUTIVE_SURFACES.csv
20_TRANSLATION_MAP.csv
21_WORKFLOW_PATTERNS.csv
22_OWNERSHIP_GRAPH.csv
23_CLOSURE_CHAIN.csv
24_RUNTIME_OBJECTS.csv
25_LANGUAGE_DRIFT.csv
26_ASSERTIONS.csv
27_TEST_CASES.csv
28_CONNECTORS.csv
29_REVIEWERS.csv
30_RECEIPT_LEDGER.csv

## Rule

These CSVs are not documentation-only assets. Bridge must treat them as seedable runtime schema inputs.

No task may claim simple `closed`; it must claim one of:

- closed_for_operator
- closed_for_bridge
- closed_for_runtime
- closed_for_human

## Next

Bridge should ingest this folder, validate all headers, seed runtime ontology tables, create a Bridge receipt, and assign connector tests to independent reviewers.
