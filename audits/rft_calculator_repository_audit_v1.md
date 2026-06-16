# Repository Audit Report v1 — RFT Calculator Family / TenderOS

Date: 2026-06-17
Status: PARTIAL, evidence-based audit completed from uploaded artefacts only.

## Receipt Summary

This audit inspected the uploaded archives and CSVs supplied in chat:

- `holo-org-plus-main.zip`
- `holoorg-agent-factory-main.zip`
- `holo_org_complete_product_audit(1).csv`
- `holoorg_agents_10k_rows_exploded_wave10(2).csv`
- `T4H_50_automated_products_via_agents_only(3).csv`

No deployment or build validation has been run in this pass. This is a repository and asset audit, not a production implementation receipt.

## Executive Finding

The strongest implementation base is `holoorg-agent-factory-main`, not `holo-org-plus-main`.

`holo-org-plus-main` is a lighter marketing / matching site. It has pricing pages and matching logic, but no visible RFT/Tender implementation in the inspected file paths.

`holoorg-agent-factory-main` already contains the core of TenderOS:

- RFT routes
- RFT analyzers
- tender explorer
- CV/RFT integration
- RFT matcher
- Supabase table references
- cost comparison calculators
- agent reuse calculator
- agent ROI calculator
- quoting flow
- agent matching and governance UI components

The correct move is to use Agent Factory as the canonical implementation base and harvest Holo-Org Plus for lighter UX, copy, and pricing/packaging patterns.

## Repo Inventory

| Repo | Code/doc files inspected | RFT files | Tender files | Calculator files | Pricing files | Agent files | Supabase files |
|---|---:|---:|---:|---:|---:|---:|---:|
| Holo-Org Plus | 95 | 0 | 0 | 0 | 3 | 7 | 1 |
| HoloOrg Agent Factory | 848 | 51 | 5 | 61 | 134 | 289 | 47 |

## Confirmed Routes in Agent Factory

Routes found in `src/routes.tsx`:

```text
- /
- home
- holoorg
- team
- agents
- agent/:id
- agent-matching
- rft
- rft-analyzer
- huge-rft-analyzer
- tender-explorer
- integrated-analysis
- *
```

Relevant existing Tender/RFT routes:

- `/rft`
- `/rft-analyzer`
- `/huge-rft-analyzer`
- `/tender-explorer`
- `/integrated-analysis`

These should become the initial TenderOS MVP surface rather than creating a new separate app.

## Calculator Inventory

High-value calculator files found in Agent Factory include:

```text
- src/components/AgentReuseCalculator.tsx
- src/components/Calculator.tsx
- src/components/CostComparisonCalculator.tsx
- src/components/agent-roi/CalculatorInputs.tsx
- src/components/agent-roi/CalculatorResults.tsx
- src/components/calculators/index.tsx
- src/components/calculators/capacity/CapacityPlanner.tsx
- src/components/calculators/comparison/ComparisonCalculator.tsx
- src/components/calculators/comparison/ModelComparison.tsx
- src/components/calculators/costs/AICoverageSlider.tsx
- src/components/calculators/costs/AgentsList.tsx
- src/components/calculators/costs/CostComparisonChart.tsx
- src/components/calculators/costs/CostComparisonTable.tsx
- src/components/calculators/costs/CostEstimator.tsx
- src/components/calculators/costs/EstimateResults.tsx
- src/components/calculators/costs/InputArea.tsx
- src/components/calculators/costs/InputSelector.tsx
- src/components/calculators/costs/RFTOutput.tsx
- src/components/calculators/costs/RFTResultsView.tsx
- src/components/calculators/costs/ResultsArea.tsx
- src/components/calculators/costs/RoleSelector.tsx
- src/components/calculators/roi/AgentRoiCalculator.tsx
- src/components/calculators/roi/CalculatorResults.tsx
- src/components/pricing/CalculatorsSection.tsx
- src/components/pricing/CostComparisonCalculator.tsx
- src/components/pricing/EnhancedPricingCalculator.tsx
- src/components/pricing/PricingCalculator.tsx
- src/components/pricing/PricingUsageCalculator.tsx
- src/lib/calculator/useCalculatorState.ts
- src/pages/AgentCalculator.tsx
- src/pages/CalculatorPage.tsx
- src/pages/CalculatorResultsPage.tsx
- src/pages/CalculatorsListPage.tsx
- src/pages/UnifiedCalculator.tsx
```

Important existing calculator modules:

- `src/components/AgentReuseCalculator.tsx`
- `src/components/CostComparisonCalculator.tsx`
- `src/components/Calculator.tsx`
- `src/components/pricing/CostComparisonCalculator.tsx`
- `src/components/pricing/EnhancedPricingCalculator.tsx`
- `src/components/pricing/PricingCalculator.tsx`
- `src/components/pricing/PricingUsageCalculator.tsx`
- `src/components/calculators/capacity/CapacityPlanner.tsx`
- `src/components/calculators/comparison/ComparisonCalculator.tsx`
- `src/components/calculators/costs/CostEstimator.tsx`
- `src/pages/UnifiedCalculator.tsx`
- `src/pages/AgentCalculator.tsx`
- `src/pages/AgentROI.tsx`

Assessment:

- There are multiple calculator implementations.
- Pricing, ROI, cost comparison and RFT output are duplicated across component families.
- These should be merged into one shared `calculator-engine` service and then exposed through configurable calculators.

## RFT / Tender Inventory

Important existing RFT modules:

- `src/components/rft/RFTAnalyzer.tsx`
- `src/components/rft/RFTAnalyzerEnhanced.tsx`
- `src/components/rft/HugeRFTAnalyzer.tsx`
- `src/components/rft/RFTAnalysisResults.tsx`
- `src/components/rft/RFTScorecard.tsx`
- `src/components/rft/RFTResponseDraft.tsx`
- `src/components/rft/TenderDataViewer.tsx`
- `src/components/quoting/RFTQuoteFlow.tsx`
- `src/components/integrated/CVRFTIntegration.tsx`
- `src/lib/rftMatcher/index.ts`
- `src/lib/rftMatcher/fallbackMatcher.ts`
- `src/utils/rftResponseGenerator.ts`
- `src/hooks/useRFTAnalysis.ts`
- `src/hooks/useRFTAnalyzer.ts`
- `src/hooks/useHugeRFTAnalysis.ts`
- `src/hooks/useCVRFTIntegration.ts`
- `src/hooks/useTenderData.ts`
- `supabase/functions/tender-data/index.ts`

Assessment:

- The RFT capability is real but fragmented.
- The current matcher already attempts Supabase-backed matching and falls back gracefully.
- The RFT logic references tables such as `RFT Metrics Final`, `Skills Metrics`, and `Function Metrics`.
- This is enough to build TenderOS v0 without starting again.

## Existing Pricing Engine Evidence

`src/lib/agent-core/pricing.ts` already defines:

- `HUMAN_RATE_HOURLY = 80`
- `AI_DISCOUNT = 0.3`
- `HOURS_PER_MONTH = 160`
- `PricingContext`
- `PricingStrategy`
- `BasePricingStrategy`
- `ComprehensivePricingStrategy`
- `calculateTotalAICost`
- `agentsToPricingItems`
- `computePricing`

Current `computePricing` already returns:

- `allHumanCost`
- `augmentedCost`
- `allAICost`
- `totalAgents`
- `totalAgentCost`

Assessment:

This is the seed of the Human / Augmented / Automated pricing model. It needs to be upgraded for RFT reality by adding assurance load, bid complexity load, reuse gain, risk premium, confidence penalty, margin target and government/commercial buyer multipliers.

## Existing ROI Evidence

`src/lib/roiCalculator.ts` already calculates hours saved, savings, ROI, human/augment/automate percentages and ESG-style impacts.

Assessment: this is a good base for Agent Pack ROI and WorkforceOS, but should not be the RFT pricing source of truth.

## Supabase / Schema Inventory

Supabase table references discovered through `.from(...)` calls include:

```text
- Function Metrics
- RFT Metrics Final
- Skills Metrics
- agents
- calculator_results
- calculator_types
- products
- runs
- team_members
- templates
```

Assessment:

There is already a calculator results model: `calculator_types` and `calculator_results`.

The RFT matcher references: `RFT Metrics Final`, `Skills Metrics`, and `Function Metrics`.

Required canonical tables:

- `calculator_templates`
- `calculator_runs`
- `calculator_outputs`
- `agent_registry`
- `product_catalogue`
- `rft_inputs`
- `rft_scores`
- `rft_price_outputs`
- `rft_assurance_flags`
- `rft_agent_matches`
- `rft_generated_outputs`
- `runtime_receipts`

## CSV Asset Inventory

### Product Audit CSV

Rows: 40

Product type counts:

```json
{
  "Workshop": 8,
  "Template Pack": 7,
  "Training Pack": 6,
  "Agent Pack": 6,
  "Audit": 5,
  "Dashboard": 4,
  "Tool": 4
}
```

### 10K Agent Registry CSV

Rows: 10000

Commercial flags:

```yaml
sellable_true: 10000
callable_true: 10000
```

Assessment: the 10K file is commercially important because it already carries governance, risk, evidence, pricing, capacity, sellable/callable flags and reality state. It should become the canonical `agent_registry`.

### 50 Automated Products CSV

Rows: 49

Sample products:

```text
- Client Onboarding System
- FB Ad Spy Tool
- SEO Blog Generator
- Tender Response Generator
- Voice Notes to CRM
- Meeting Minutes & Action Tracker
- YouTube Shorts Repurposer
- Website QA Checker
- Invoice Chase Bot
- Local SEO Optimiser
```

Assessment: this is a ready product catalogue seed. It needs normalised metadata fields for buyer, sector, trigger, ROI promise, risk, upsell path and white-label fit.

## KEEP / MERGE / REMOVE Matrix

### KEEP

- Agent Factory routes: `/rft`, `/rft-analyzer`, `/huge-rft-analyzer`, `/tender-explorer`, `/integrated-analysis`
- RFT analyzers and RFT scorecard components
- `src/lib/rftMatcher/*`
- `src/utils/rftResponseGenerator.ts`
- `src/lib/agent-core/pricing.ts` as pricing seed
- `src/lib/roiCalculator.ts` as ROI seed
- `src/services/calculatorService.ts`
- Supabase calculator tables as transition layer
- 10K registry CSV as canonical registry seed
- 50 products CSV as canonical catalogue seed

### MERGE

- All duplicate cost comparison calculators into one shared pricing module
- All pricing calculators into `shared-calculator-engine/pricing`
- Agent ROI and Agent Reuse calculators into `shared-calculator-engine/roi`
- RFT analyzer, Huge RFT analyzer and RFT matcher into `shared-calculator-engine/tenderos`
- CV/RFT integration into `shared-calculator-engine/workforceos` plus TenderOS team model
- Holo-Org Plus pricing/UX into Agent Factory design system where useful

### REMOVE / DEPRECATE

Do not delete yet. Mark for deprecation after tests exist:

- duplicate calculator components with overlapping cost logic
- duplicate pricing UI paths once canonical calculator engine is used
- static/mock RFT matching paths after canonical Supabase registry is in place
- any hard-coded pricing constants not routed through the shared pricing engine

## Shared Calculator Engine Target

Create:

```text
src/lib/calculator-engine/
├── index.ts
├── types.ts
├── parser.ts
├── scoring.ts
├── pricing.ts
├── assurance.ts
├── matching.ts
├── packaging.ts
├── receipts.ts
├── products.ts
└── tenderos.ts
```

Primary exported function:

```ts
runCalculator(templateCode, input, context): CalculatorRunResult
```

Every calculator should become a template/configuration using this engine.

## TenderOS MVP Build Plan

1. Canonicalise pricing: add base delivery effort, assurance load, bid complexity load, risk premium, reuse gain, automation gain, margin target and confidence penalty.
2. Canonicalise scoring: add automation fit, assurance load, opportunity fit and confidence scores.
3. Canonicalise RFT output: BID / REVIEW / NO_BID / PARTNER_BID, recommended model, three prices, scores, agents, accountable humans, evidence gaps, risk flags and generated outputs.
4. Wire existing pages: `RFTAnalyzerPage`, `HugeRFTAnalyzerPage`, `TenderExplorerPage`, `UnifiedCalculator`, `AgentROI`.
5. Create migration and seed scripts for canonical tables, 10K registry, 50 products and receipts.

## Commercial Product Priority

1. RFT Delivery Model Calculator
2. Bid Factory Calculator
3. Government Assurance Calculator
4. CV-to-Team-to-Price Calculator
5. Agent Pack ROI Calculator
6. Tradie AI Quote-to-Delivery Calculator
7. Professional Services Capacity Calculator
8. Extended Professional Life Calculator
9. Proposal Reuse Score Calculator
10. White-label Calculator Factory

## Reality Ledger

```yaml
status: PARTIAL

real_evidence:
  - uploaded repositories unpacked
  - file inventory completed
  - RFT routes confirmed
  - calculator files confirmed
  - pricing engine seed confirmed
  - ROI engine seed confirmed
  - Supabase table references confirmed
  - 10K registry CSV parsed
  - 50 product CSV parsed

not_done:
  - no code committed to application repo
  - no build run
  - no deployment
  - no Supabase migration executed
  - no bridge runtime execution confirmed

classification:
  audit: REAL
  implementation: PARTIAL
  deployment: BLOCKED_NOT_ATTEMPTED

next_action:
  - commit this audit report and machine-readable receipt to GitHub
  - implement shared calculator engine in Agent Factory
  - generate migration and CSV seed scripts
  - wire TenderOS pages to canonical result model
```
