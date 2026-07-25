# Contributing to the Hakuna Matata Harvest

## Add a source

Append one row to `HARVEST_SOURCE_LEDGER_v4.csv` before adding extracted objects.

Required fields:

- stable `harvest_id`
- source system
- exact source title
- source type
- exact Drive URL/file ID or GitHub repository path
- source version, revision or commit
- domain
- reported counts, clearly labelled as reported
- reality state
- preservation and duplicate policy
- evidence summary
- next extraction action
- verification date

## Extract a source

An extraction is complete only when it records:

1. source `harvest_id`
2. exact version or commit
3. extraction date
4. source row/sheet/path identity
5. raw value preserved
6. proposed object class
7. proposed canonical identity
8. alias/duplicate state
9. output path
10. row count and validation receipt

## Prohibited changes

- deleting a source because it appears duplicated
- replacing a historical price with a newer price
- collapsing products, capabilities, workers, agents, dossiers, research objects or runtime components into one generic class
- promoting a source-reported claim to verified without extraction evidence
- marking an implementation REAL without runtime and receipt evidence

## Reconciliation states

- `UNREVIEWED`
- `POSSIBLE_ALIAS`
- `CONFIRMED_ALIAS`
- `DUPLICATE_SNAPSHOT`
- `SUPERSEDES`
- `CONFLICT`
- `CANONICAL_CANDIDATE`
- `CANONICAL`
- `REJECTED_WITH_EVIDENCE`

Every decision must preserve the original record and add the decision as a new record or mapped field.
