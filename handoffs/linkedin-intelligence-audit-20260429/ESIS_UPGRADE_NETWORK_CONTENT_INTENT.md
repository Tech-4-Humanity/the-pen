# ESIS Upgrade: LinkedIn Network + Content + Intent Intelligence

## Core Shift
The LinkedIn archive is not a content dump. It is three separate but joinable strategic assets:

1. Network asset
2. Content asset
3. Intent signal asset

Each asset has a different job, output, and monetisation path. The system must keep them separate at ingestion, then join them through a Strategic Context Engine.

---

## 1. Asset Classes

### A. Network Asset
Source files may include connections, followers, profile metadata, company, role, geography, connection date, and profile URL.

Primary jobs:
- identify warm contacts
- map influence clusters
- find pilots, advisory board candidates, introductions, research collaborators, investors, partners, press, and enterprise buyers
- identify role/company/country concentrations

Required outputs:
- must-nurture contact list
- founder/C-suite/researcher/government/adviser segmentation
- company and industry concentration map
- reactivation campaign candidates
- roundtable invite list

### B. Content Asset
Source files may include posts, articles, reactions, comments, shares, click-through, impressions, follower analytics, demographics, and posting history.

Primary jobs:
- identify themes that actually land
- detect reusable article structures
- rank content by engagement rate, not vanity views
- map posts/articles to books, courses, offers, and businesses
- extract Troy voice, patterns, hooks, and calls-to-action

Required outputs:
- article index by topic, date, and link
- top content archetypes
- book candidates
- course candidates
- lead magnet candidates
- article-to-business mapping
- prediction tracker

### C. Intent Signal Asset
Source files may include DMs, comments, replies, inbound asks, account history, and inferred info.

Primary jobs:
- detect demand
- identify repeated asks
- recover lost opportunities
- convert messages/comments into pipeline
- map emerging market needs before they become explicit opportunities

Required outputs:
- advisory opportunities
- collaboration opportunities
- grant/R&D opportunities
- speaking opportunities
- hiring/recruiting opportunities
- pilot and partner opportunities
- lost action backlog

---

## 2. New Strategic Context Engine

Every row from every LinkedIn source must be processed through the following scoring layers:

### Project Fit Score
Map to current T4H ecosystem businesses:
- Tech for Humanity
- WorkFamilyAI
- Augmented Humanity Coach
- HoloOrg
- GC-BAT Core
- ConsentX
- Far-Cage
- MyNeuralSignal
- NEUROPAK
- RATPAK
- LifeGraph Plus
- AI Olympics
- Mission Critical
- Outcome Ready
- SmartPark
- MedLedger
- AquaMe
- Enter Australia
- APAC Just Walk Out
- Vuon Troi
- JustPoint
- XCES
- House of Biscuits
- Apex Predator Insurance
- Extreme Spotto
- AI Oopsies
- Rhythm Method
- GirlMath

### Audience Reality Score
Compare assumed audience versus actual audience using:
- role seniority
- company type
- geography
- industry
- engagement patterns
- message/comment signal quality

### Momentum Score
Measure whether a theme, audience, project, or relationship cluster is:
- rising
- falling
- dormant
- resurfacing
- over-served
- under-served

### Opportunity Score
Prioritise based on:
- relevance to current projects
- engagement strength
- warm relationship depth
- market timing
- monetisation potential
- execution readiness

### Strategic Action Class
Every insight becomes one of:
- ignore
- monitor
- nurture
- publish
- package
- monetise
- partner
- invite
- build
- escalate

---

## 3. Metadata Expansion

The audit must use metadata aggressively. Required fields to preserve or infer:

### Content Metadata
- source type
- original date
- source URL
- author/persona
- topic
- subtopic
- format
- hook style
- CTA style
- engagement rate
- comment quality
- inferred audience
- lifecycle state

### Network Metadata
- name
- role
- company
- seniority
- sector
- country/region
- connection date
- last interaction date
- relationship strength
- opportunity class

### Intent Metadata
- ask type
- urgency
- business relevance
- project fit
- follow-up status
- revenue potential
- evidence text
- source thread/comment/post

---

## 4. Command Centre Outputs

The engine must write dashboard-ready output tables/views for:

1. Who actually cares
2. Which posts actually drive meaningful conversations
3. Which articles can become books
4. Which themes can become courses
5. Which businesses are over/under-supported by existing content
6. Which predictions should be revisited
7. Which actions fell away
8. Which people need reactivation
9. Which new business ideas have enough demand signal
10. Which assets should be published next

---

## 5. First Deep-Dive Default

Do not ask whether to start with audience or content. Run both:

### Pass 1: Real Audience Map
- top engaged roles
- top companies
- top sectors
- top geographies
- high-value people
- dormant high-value people
- warm intro candidates

### Pass 2: Meaningful Conversation Map
- top posts/articles by engagement quality
- posts that produced comments/messages/offers
- repeated asks
- article archetypes
- business/product/course/book implications

---

## 6. Enhanced Supabase Tables Required

Add:
- linkedin_network_people
- linkedin_network_clusters
- linkedin_content_archetypes
- linkedin_intent_signals
- linkedin_opportunity_board
- linkedin_audience_segments
- linkedin_project_fit_scores
- linkedin_strategic_actions

---

## 7. Final System State

This is an External Strategic Intelligence System. It must live outside Troy as an always-on memory and decision layer.

It should answer:
- who matters now
- what ideas are maturing
- what we are ignoring
- what deserves monetisation
- what should become a book/course/product
- who should be contacted
- what the organisation should do next

Reality classification remains PARTIAL until linked to real S3 data, Supabase tables, run logs, and ledger evidence.
