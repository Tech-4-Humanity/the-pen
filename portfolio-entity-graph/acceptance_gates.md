# Acceptance Gates — Portfolio Entity Graph v1

## PARTIAL

System remains PARTIAL when:
- schema exists but is not executed
- importers are not run
- entities are not populated
- no graph surface exists
- no bridge receipt exists
- no Reality Ledger runtime evidence exists

## REAL

System becomes REAL only when all conditions are met:

1. Vercel inventory importer executed.
2. GitHub inventory importer executed.
3. At least 50 raw inventory rows inserted.
4. At least 25 entities classified.
5. At least 10 relationships inferred.
6. At least 5 duplicate candidates detected.
7. Sell-readiness scores calculated for at least 10 entities.
8. Whitelabel-readiness scores calculated for at least 10 entities.
9. Command Centre graph surface returns live data.
10. Reality Ledger run entry written.
11. Bridge receipt or equivalent runtime execution evidence returned.

## BLOCKED

System becomes BLOCKED when:
- Supabase access unavailable
- Bridge executor unavailable
- importers fail repeatedly
- evidence chain broken
- schema deployment rejected
