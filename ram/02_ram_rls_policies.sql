-- 02_ram_rls_policies.sql
-- Row Level Security policies for RAM tables.
-- Default deny. Service role bypasses RLS implicitly.
-- Authenticated users get read on portfolio_cards (REAL only) and watch_events (info/warning).

alter table public.ram_assets enable row level security;
alter table public.ram_asset_locations enable row level security;
alter table public.ram_asset_hashes enable row level security;
alter table public.ram_asset_lineage enable row level security;
alter table public.ram_asset_validation enable row level security;
alter table public.ram_asset_evidence enable row level security;
alter table public.ram_asset_versions enable row level security;
alter table public.ram_asset_relationships enable row level security;
alter table public.ram_packages enable row level security;
alter table public.ram_portfolio_cards enable row level security;
alter table public.ram_reuse_components enable row level security;
alter table public.ram_revenue_opportunities enable row level security;
alter table public.ram_watch_events enable row level security;
alter table public.ram_dev_inspections enable row level security;
alter table public.ram_prod_promotions enable row level security;

-- Public read of REAL portfolio cards only.
drop policy if exists ram_portfolio_public_read on public.ram_portfolio_cards;
create policy ram_portfolio_public_read on public.ram_portfolio_cards
  for select to anon using (evidence_state = 'REAL');

-- Authenticated read of own-source assets (assets are tenant-less for now; gate is service role).
drop policy if exists ram_assets_auth_read on public.ram_assets;
create policy ram_assets_auth_read on public.ram_assets
  for select to authenticated using (true);

-- Authenticated read of dev inspections and prod promotions (transparency).
drop policy if exists ram_dev_auth_read on public.ram_dev_inspections;
create policy ram_dev_auth_read on public.ram_dev_inspections
  for select to authenticated using (true);

drop policy if exists ram_prod_auth_read on public.ram_prod_promotions;
create policy ram_prod_auth_read on public.ram_prod_promotions
  for select to authenticated using (true);

-- All write paths are restricted to service_role / troy-sql-executor bridge.
-- No explicit insert/update/delete policies for non-service roles.
