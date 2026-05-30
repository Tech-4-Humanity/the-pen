# Portfolio Dossier Factory v1.1

Status: PARTIAL

This file locks the one-business-per-page standard for Troy Latter's live and under-development business portfolio.

## Thread-derived correction

The baseline is not architecture.

The user intent is a searchable one-page visual business overview for every live or under-development website/business. The dossier must let a reader understand what the business is, who it serves, what value it creates, how it makes money, and where to go next.

Architecture, agent maps, signal chains, governance diagrams, and ecosystem dependency explanations belong in a separate portfolio map, not the individual business dossier.

## Operating rule

One business equals one dossier page. No five-up sheets as master assets.

Each dossier must use the same structure, same visual grammar, same maturity model, and same quality bar.

The page must behave like a company tear sheet, investment teaser, Gartner-style vendor snapshot, or startup one-pager.

## Primary audience

Each page must work for:

- a customer
- a partner
- an investor
- a government executive
- a future employee
- an internal portfolio reviewer

If they cannot answer the following in 20 to 30 seconds, the page fails:

1. What is it?
2. Who is it for?
3. Why should I care?
4. How does it make money?
5. What stage is it at?
6. How do I learn more?

## Canonical page structure v1.1

1. Business name
2. Domain or primary URL
3. Short tagline in plain customer language
4. Status or stage
5. Category
6. Hero screenshot from the actual website where possible
7. Business snapshot
   - Website
   - Category
   - Customers
   - Revenue model
   - Stage
   - Geography
8. What is it?
9. Who buys it?
10. Problem solved
11. Customer outcomes
12. Typical result / measurable promise
13. Revenue streams
14. Why it is different
15. 12-month target
16. Portfolio tags for search
17. Contact / QR / learn-more link
18. Small footer only: Part of the Tech 4 Humanity Portfolio

## Explicitly de-emphasised

The following must not dominate an individual dossier:

- ecosystem architecture
- Holo-Org agent structures
- NeuroPak orchestration
- signal chains
- governance operating models
- internal system diagrams
- connected-brand dependency maps
- detailed feature matrices

One small portfolio/footer reference is acceptable. Anything more belongs in the portfolio map, not the business tear sheet.

## Visual weighting

The page should roughly follow this weighting:

- 40 percent visual: screenshot, product image, or website view
- 20 percent customers and market
- 20 percent problem plus outcomes
- 10 percent revenue model
- 10 percent stage, contact, tags and footer

## Language rule

Use buyer-readable language. Avoid internal architecture labels unless the business itself is selling architecture.

Bad:

- Commercial Delivery Engine
- Workforce Intelligence Engine
- Signal Orchestration Layer
- 1000-Agent Organisation Framework

Better:

- Helping people and organisations work better with AI
- AI-powered employee wellbeing, engagement and productivity
- Turn any organisation chart into an AI-ready operating model
- Trusted consent and records for digital services

## Outcome over feature rule

Nobody buys capabilities. They buy outcomes.

Capability-heavy blocks must be reduced and translated into customer value.

Examples:

Instead of:

- AI wellbeing assistant
- engagement insights
- productivity optimiser

Use:

- reduce burnout
- improve retention
- increase productivity
- support managers
- improve culture

Instead of:

- document analysis
- tax assistant
- research assistant

Use:

- save 10+ hours per week
- deliver work faster
- reduce compliance risk
- increase client capacity
- grow revenue without hiring

## Mandatory metadata for search

Every dossier record must store:

- business_name
- domain
- category
- tagline
- primary_customer
- secondary_customer
- future_customer
- problem_keywords
- outcome_keywords
- revenue_model
- stage
- geography
- portfolio_tags
- screenshot_source
- last_updated
- quality_score

## Quality standard per individual page

A page passes only if it scores at least 8/10 against each of these:

- Clarity: reader understands business in 20 to 30 seconds
- Customer focus: buyer and user are obvious
- Commerciality: revenue path is explicit
- Value: why the buyer should care is obvious
- Outcome strength: customer results are tangible
- Stage honesty: status is not overstated
- Visual consistency: same grid, same hierarchy, same density
- Screenshot quality: real website screenshot preferred; generated UI only allowed as placeholder
- Searchability: metadata is stored as structured text

## Production scoring

REAL requires:

- individual page generated
- page follows v1.1 structure
- metadata captured
- screenshot source declared
- quality score recorded
- artifact posted or hosted

PARTIAL when:

- design exists but no real screenshot
- content is inferred but not validated
- page is generated but metadata is missing
- portfolio item exists only as a composite sheet

BLOCKED when:

- no domain or source material exists
- access is unavailable
- business name cannot be resolved

## Wave 1 dossiers to finish first

1. Tech 4 Humanity
2. Augmented Humanity Coach
3. Outcome Ready
4. WorkFamilyAI
5. Reading Buddy
6. ConsentX
7. LifeGraph Plus
8. GC-BAT
9. MyNeuralSignal
10. AI Sweet Spots

## Wave 2 candidates

11. Holo-Org
12. NeuroPak
13. Learning Ledger
14. AI for Tradies
15. AI for Small Business Professionals / Accountants
16. AI for Lawyers
17. AI for Dentists
18. Thriving Kids
19. Thriving Biz
20. Enter Australia
21. Drug Resilience Atlas

## Current production state

Individually useful visual examples:

- AI for Small Business Professionals / Accountants
- WorkFamilyAI
- Tech 4 Humanity

Partial visual examples:

- ConsentX
- LifeGraph Plus
- Reading Buddy
- AI for Dentists
- AI for Lawyers
- Holo-Org
- Augmented Humanity Coach

Composite examples:

- Holo-Org / Augmented Humanity Coach / WorkFamilyAI three-up visual exists but is not production master format because one business must equal one page.

Remaining required production:

- Generate final individual pages for Wave 1 using the v1.1 business tear-sheet standard.
- Capture real website screenshots where possible.
- Validate and normalise the full 53-domain inventory.
- Build searchable metadata registry.
- Generate HTML-first dossier library with PDF export.

## Correct architecture for the dossier system

HTML is the source of truth. PDF is an export.

Data registry -> HTML dossier template -> searchable web view -> PDF export.

Do not create 53 independent PDFs as the master asset. That creates maintenance drag.

## Reality Ledger

status: PARTIAL
result: Dossier baseline corrected from architecture-heavy portfolio maps to customer-facing one-page business tear sheets.
evidence:
  - type: github_commit
    value: updated canonical standard in TML-4PM/the-pen
  - type: thread_analysis
    value: user repeatedly corrected that the intent is one-page business overview, not architecture
  - type: visual_artifact
    value: AI for Accountants, WorkFamilyAI and Tech 4 Humanity individual examples exist in chat assets
  - type: visual_artifact_partial
    value: five-concept and three-concept composites exist but are not production master format
gaps:
  - full 10 Wave 1 pages not complete
  - full 20 pages not complete
  - full 53 portfolio not complete
  - real website screenshots not captured for all businesses
  - searchable registry not yet created
  - hosted HTML dossier library not yet deployed
next_action:
  - create metadata registry for Wave 1
  - generate individual HTML dossier pages for Wave 1
  - export PDFs from HTML as secondary artifacts
  - expand to Wave 2 and then full 53-business estate
pressure_flags:
  - drift_detected: architecture discussion displaced original business overview intent
  - correction_applied: v1.1 standard now prioritises customer-facing tear sheet
score:
  execution: 0.55
  evidence: 0.62
  economic: 0.70
  reuse: 0.85
  delta: 0.80
  overall: 0.68
ledger:
  task_id: portfolio-dossier-factory-v1.1
  intent: one-page searchable visual business dossier per website/business
  execution: canonical standard updated in GitHub
  output: portfolio-dossiers/00_portfolio-dossier-factory.md
  status: PARTIAL
  evidence: commit receipt returned by GitHub
