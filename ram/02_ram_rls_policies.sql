-- 02_ram_rls_policies.sql
-- Row-level security for RAM tables. Default deny, service_role full, anon read-none.
-- Aligned with T4H standing rules: writes only via service_role through the bridge.

alter table public.ram_assets               enable row level security;
alter table public.ram_asset_locations      enable row level security;
alter table public.ram_asset_hashes         enable row level security;
alter table public.ram_asset_lineage        enable row level security;
alter table public.ram_asset_validation    enable row level security;
alter table public.ram_asset_evidence      enable row level security;
alter table public.ram_packages            enable row level security;
alter table public.ram_portfolio_cards     enable row level security;
alter table public.ram_reuse_components    enable row level security;
alter table public.ram_watch_events        enable row level security;
alter table public.ram_dev_inspections     enable row level security;
alter table public.ram_prod_promotions     enable row level security;

-- service_role: full access (bridge writers, workers, validators)
do $$
declare t text;
begin
  for t in select unnest(array[
    'ram_assets','ram_asset_locations','ram_asset_hashes','ram_asset_lineage',
    'ram_asset_validation','ram_asset_evidence','ram_packages','ram_portfolio_cards',
    'ram_reuse_components','ram_watch_events','ram_dev_inspections','ram_prod_promotions'
  ])
  loop
    execute format('drop policy if exists %I_service_all on public.%I;', t||'_srv', t);
    execute format(
      'create policy %I_service_all on public.%I as permissive for all to service_role using (true) with check (true);',
      t||'_srv', t
    );
  end loop;
end$$;

-- authenticated: read-only on portfolio and watch surfaces only (for CC UI)
drop policy if exists ram_portfolio_cards_auth_read on public.ram_portfolio_cards;
create policy ram_portfolio_cards_auth_read
  on public.ram_portfolio_cards
  as permissive for select to authenticated
  using (evidence_state in ('REAL','PARTIAL'));

drop policy if exists ram_watch_events_auth_read on public.ram_watch_events;
create policy ram_watch_events_auth_read
  on public.ram_watch_events
  as permissive for select to authenticated
  using (severity in ('info','warning','critical'));

-- anon: deny everything (no policy = no access under RLS)

-- Optional: portfolio public view (gated by explicit evidence_state)
create or replace view public.v_ram_portfolio_real as
  select id, brand, capability, audience, summary, commercial_value, created_at
  from public.ram_portfolio_cards
  where evidence_state = 'REAL';

comment on view public.v_ram_portfolio_real is
  'Only portfolio cards with REAL evidence_state. Drives external portfolio surfaces.';
