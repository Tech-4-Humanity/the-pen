# Agent Cost + Pricing Seed Report

## Evidence from uploaded files

- `10k_agents_full(3).csv`: 10,000 rows, 23 columns.
- `HoloOrg_1000_Global_Named_Agents(9).csv`: 1,000 rows, 9 columns.

## 10K agent grid financial base

- Total setup cost basis: $11,112,850.00 USD.
- Total monthly cost basis: $797,850.00 USD.
- Average setup cost: $1,111.29 USD.
- Average monthly cost: $106.38 USD.

Default pricing applied:
- Wholesale = cost x 1.35.
- Retail = cost x 2.5.
- Service run limits vary by monthly cost band: 250 / 500 / 1000 included runs per month.

## Holo-ORG 1000 financial base

- Total agents: 1,000.
- Pillars: Product, Marketing, People, Finance & Ops, Support, Innovation, Sales & RevOps, Governance, Community, Execution Engine.
- Complexity mix: {'Low': 361, 'High': 341, 'Medium': 298}.
- Average value score: 6.58.

Default cost basis:
- Low: $750 setup / $75 monthly.
- Medium: $1,500 setup / $150 monthly.
- High: $3,000 setup / $300 monthly.

Retail pricing is adjusted by value score multiplier.

## Generated files

- `agent_pricebook_10k_seed.csv`
- `agent_pricebook_holoorg_1000_seed.csv`
- `01_cost_price_service_limits_schema.sql`

## Reality status

PARTIAL. The CSVs were parsed and transformed locally. Supabase/Drive/S3/laptop live inventory is not yet executed in this environment.
