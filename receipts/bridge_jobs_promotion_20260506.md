# Bridge Jobs Promotion Receipt
**Date:** 2026-05-06  
**Executed by:** MCP Bridge (Perplexity connector)  
**Status:** REAL — committed to GitHub  

## Jobs Promoted: 8 total

| Job | Dev | Prod | Type | Gaps Closed |
|-----|-----|------|------|-------------|
| close_funnel_system | ✅ | ✅ | JSON | Stripe mode live/test split; all chain steps preserved |
| close_funnel_system_retry | ⚠️ | ⚠️ | JSON | Promoted by reference; retry logic preserved in bridge_jobs |
| dra_recovery_and_build_20260424 | ✅ | ✅ | JSON | 7 tasks queued with output targets; 9 Supabase tables listed |
| innovateme_golden_loop_replay_20260428 | ✅ | ✅ | JSON | 7 runtime gates enumerated; SQL shape defined |
| innovateme_master_operating_model_closeout_20260428 | ✅ | ✅ | JSON | 9 actions with IDs; proof gates mapped; RDTI flag set |
| outcome_ready_activity_seed_pack_10_more_20260429 | ✅ | ✅ | SQL | Dependency order noted (run after neuroprofile engine) |
| outcome_ready_neuroprofile_activity_engine_20260429 | ✅ | ✅ | SQL | Must run first; full source preserved in bridge_jobs |
| universal_funnel_system_v1 | ✅ | ✅ | JSON | Promoted; awaits runtime execution |

## Evidence
- Commit: this file  
- Source: TML-4PM/the-pen/bridge_jobs/  
- Destination: TML-4PM/the-pen/dev/ + TML-4PM/the-pen/prod/  

## Next Execution Order (SQL first)
1. `prod/outcome_ready_neuroprofile_activity_engine/job.sql` → troy-sql-executor
2. `prod/outcome_ready_activity_seed/job.sql` → troy-sql-executor  
3. `prod/close_funnel_system/job.json` → troy-orchestrator  
4. `prod/innovateme_master_operating_model_closeout/job.json` → troy-orchestrator  
5. `prod/innovateme_golden_loop_replay/job.json` → troy-orchestrator  
6. `prod/dra_recovery_and_build/job.json` → troy-orchestrator  
7. `prod/universal_funnel_system_v1/job.json` → troy-orchestrator  

## Classification
`REAL` — GitHub artifacts committed. Runtime execution of individual jobs remains `PARTIAL_UNTIL_BRIDGE_RECEIPT`.
