create index if not exists ix_ccp_receipts_actor    on public.ccp_receipts (actor_id, finished_at desc);
create index if not exists ix_ccp_receipts_state    on public.ccp_receipts (state, finished_at desc);
create index if not exists ix_ccp_receipts_intent   on public.ccp_receipts (intent, finished_at desc);
create index if not exists ix_ccp_receipts_evidence on public.ccp_receipts using gin (evidence);
create index if not exists ix_ccp_health_connector  on public.ccp_health_snapshots (connector_id, observed_at desc);
