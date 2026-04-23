# Augmented Memory Program

## Canonical Build Pack for The Pen

Status: READY FOR BUILD  
Owner: Tech 4 Humanity  
Stream: Emerging Tech / Augmented Humanity / Legacy / Place Graph  
Scope: Front-end customer products, experience layer, memory infrastructure, partner motions, physical/location interactions, rollout logic

---

## 1. Program Summary

Augmented Memory is not one product.

It is a shared memory engine plus multiple front-end customer products that let people:

- capture memories now
- enrich past memories where possible
- attach memories to people, places, time, events, emotions, and relationships
- experience memories privately, in groups, publicly, or contextually
- discover memories in the world, not only in their own house, family, or workplace
- create legacy, memorial, travel, work, learning, care, and public-place experiences from the same core infrastructure

This build must produce:

1. a clear product family for customers
2. a memory experience layer with optional modes
3. a memory infrastructure layer that is reusable
4. a physical/location-aware layer for public and memorial use cases
5. partner models and go-to-market hooks
6. a front-end narrative that is understandable, premium, emotionally sane, and not morbid
7. a system that does not depend on one device type

Core principle:

> Any input, any output, one memory graph, many controlled experiences.

---

## 2. What This Is Not

This is not:

- just a family photo archive
- just a cemetery product
- just an AI memorial chatbot
- just a phone app
- just a story recorder
- just a work notes app

This is:

- a memory infrastructure
- a place-aware experience layer
- a family and public memory network
- a product family with multiple entry points

---

## 3. Front-End Customer Products

These are the customer-facing products to build around.

### 3.1 Augmented Memories Life

For individuals and families while people are alive.

Core promise: capture, organise, revisit, and share the moments, stories, and meaning that shape a life.

Use cases:

- family stories
- daily life memories
- milestones
- parenting memories
- older family history
- life-story capture
- travel journaling
- personal archives

Product modules:

- private memory timeline
- family vault
- story prompts
- media upload and auto-grouping
- legacy preparation
- optional public or semi-public place attachment
- annual memory books and keepsakes

### 3.2 Augmented Memories Legacy

For end-of-life, memorial, funeral, cemetery, and family remembrance.

Core promise: preserve a real person’s voice, values, stories, and presence in a respectful way.

Use cases:

- tribute pages
- family memorial collections
- life stories
- anniversary remembrance
- funeral-linked digital memory pages
- cemetery-linked memories
- milestone messages left before death

Product modules:

- tribute page builder
- memorial timeline
- voice and video archive
- remembrance prompts
- family sharing controls
- public memorial mode
- cemetery / QR / NFC linked access
- kids visit mode / family-safe mode

### 3.3 Augmented Memories Work

For small businesses, teams, founders, consultants, and enterprise.

Core promise: stop losing decisions, context, relationships, and knowledge.

Use cases:

- meeting memory
- decision history
- handover continuity
- client memory
- founder recall
- project chronology
- searchable context

Product modules:

- meeting capture
- decision log
- project timeline
- client relationship memory
- searchable work history
- executive recall assistant
- handover packs

### 3.4 Augmented Memories Care

For ageing, disability support, family carers, and identity continuity.

Core promise: support dignity, routine, identity, and continuity for people who need memory support.

Use cases:

- ageing parents
- daily reminders
- routines and care continuity
- family carer support
- identity prompts
- story preservation for dignity
- memory support in the home

Product modules:

- daily support view
- routine and reminder engine
- family/caregiver portal
- identity cards and life story prompts
- familiar people / familiar place cues
- voice-first or display-first experience options

### 3.5 Augmented Memories Learning

For students, parents, tutors, specialists, and schools.

Core promise: create continuity of learning, confidence, and support over time.

Use cases:

- reading and literacy
- student progress memory
- intervention history
- neurodivergent support
- parent/teacher alignment
- tutoring memory and momentum

Product modules:

- student memory timeline
- learning snapshots
- teacher notes and intervention history
- strengths and support patterns
- confidence and wins archive
- family-friendly summaries

### 3.6 Augmented Memories Places

For public memory, travel, businesses, tourism, memorial discovery, museums, and place-based stories.

Core promise: places remember too.

Use cases:

- travel journaling by location
- public memories on streets, corners, cafes, venues
- cemetery discovery and memorial proximity
- museums and heritage storytelling
- city trails
- partner-triggered memory moments
- what happened here discovery

Product modules:

- map and location memory layer
- place page
- public memory discovery
- private memory attachment to place
- semi-public or public memory posting
- density/ambient signal indicators
- QR/NFC trigger support
- GPS proximity support
- audio walking mode
- trails and themed routes

---

## 4. Memory Experience Layer

This optional front-end layer changes how users experience the same underlying data. Do not lead with every mode at once. Build the architecture so these modes can be enabled per product, user type, culture, age group, or partner.

### Reflection Mode

Calm, simple, story-led, minimal noise.

Best for family, legacy, older users, and care.

### Discovery Mode

Explore nearby memories, stories, and meaning tied to place.

Best for places, travel, youth markets, and city experiences.

### Story Mode

Turn collections of memories into a narrative.

Best for family, legacy, public history, and travel summaries.

### Timeline Mode

Chronological view of events and memory objects.

Best for work, learning, care, and legacy.

### Perspective Mode

Show multiple valid memories about the same place, event, or person without resolving conflict.

Best for public place memories, family differences, community archives, and heritage.

### Emotional Mode

Cluster or surface memories by feeling, mood, or emotional theme.

Best for later therapy, care, personal reflection, and rhythm/cycles.

### Ritual Mode

Triggered on birthdays, anniversaries, memorial dates, and recurring moments.

Best for legacy, family, remembrance, faith, and culture-aware experiences.

### Companion Mode

AI surfaces relevant memory, context, or prompts at the right time.

Best for work, care, family, and executive support.

### Discovery Trails Mode

Users move through a sequence of place memories.

Best for tourism, museums, city walks, and family hometown routes.

### Kids Visit Mode

Simple, safer, emotionally lighter experience for children.

Best for cemetery visits, remembrance, and family storytelling.

### Anonymous / Light Public Mode

Allow public memories without forcing identity.

Best for public places, younger users, community storytelling, and selective memorial settings.

### Verified / Curated Mode

Partner-controlled or institutionally validated memory layer.

Best for museums, councils, cemeteries, heritage, and enterprise.

---

## 5. Handling Conflicting Memories

Do not try to solve conflicts. Structure them.

Rules:

- no single memory owns a place
- memories can coexist
- each memory has visibility and trust state
- each place can show multiple perspectives
- content ownership remains with uploader, not with family or location owner by default
- partner/curated layers can exist alongside personal layers

Views:

- timeline view
- perspective view
- layer view
- consensus vs outlier
- public vs private vs curated filters

Trust and visibility states:

- private
- shared circle
- public
- anonymous public
- curated
- verified
- partner-owned
- archived

---

## 6. Input / Output / Interface Strategy

Do not lock to phones. Do not lock to hardware. Build device-agnostic ingestion and multi-channel delivery.

### Input Channels

Easy / must support:

- mobile phone upload
- web upload
- desktop/laptop upload
- digital camera import
- audio recorder import
- manual text entry
- cloud photo library import
- document upload

Medium / staged:

- calendar import
- email import
- work meeting imports
- CRM/work tools
- smart speaker voice capture
- wearable signals

Hard / selective:

- healthcare system imports
- enterprise stack depth
- CCTV/IoT
- smart glasses

### Output Channels

Easy / must support:

- mobile web/app
- desktop/web app
- shared links
- printable outputs
- PDF/book/export
- timeline/list/card views

Medium / staged:

- smart displays
- smart speakers
- car/voice modes
- earbud audio mode
- API embedding

Hard / selective:

- AR/VR overlays
- ambient smart environments

### Physical Trigger Layers

Default:

- virtual place graph
- GPS
- place-based triggers
- QR codes

Premium:

- NFC tags
- printed keepsake cards
- memorial cards
- framed display markers

Partner-grade:

- cemetery plaques
- museum placards
- permanent site markers

---

## 7. Place-Aware Memory Network

This is the public/world layer and one of the strongest differentiators.

Principle:

> Places can carry private memories, shared group memories, public memories, memorial memories, curated stories, and partner stories.

Place discovery states:

- no visible memory
- your memories only
- network memory presence
- curated stories
- public memory density
- memorial nearby indicators

Ambient discovery model:

- subtle map indicators
- this place has stories
- you have memories here
- people remember this place
- optional haptic/notification signals

Place memory actions:

- attach a memory to a place
- keep it private
- share it to a circle
- make it public
- make it anonymous
- add media and text
- revisit memories by map
- follow trails
- browse nearby memorials where allowed

---

## 8. Memorial / Cemetery Model

Cemeteries are not the same as hospitals or enterprise systems. They are structured, place-based, emotionally aligned, and commercially viable once access is secured.

### Model A: Partner-First

- cemetery or funeral home onboarded
- plot or place linked
- QR/NFC/plaque installed where appropriate
- official memorial experience

### Model B: Family-Direct

- family creates memorial
- links to place manually or semi-precisely
- mailed or downloadable QR/NFC options
- no operator dependency

### Model C: Virtual-First

- cemetery geofenced
- public or family memory layer available at cemetery-level
- specific plot precision added later

Precision reality:

- cemetery-level geofencing is easy
- grave-level precision needs partner data, user pinning, or physical marker
- do not overpromise exactness without verification

Cemetery experiences:

- tribute page
- nearby memorial browse where permitted
- remembrance mode
- child-friendly mode
- story snippets
- public or private memorial settings
- family disagreement handled by uploader ownership and permissions, not emotional arbitration

---

## 9. Optional Extras / Future Markets

These are not lead wedges, but the architecture should leave room for them.

- therapy / guided reflection
- museums / heritage
- tourism / city trails
- events / festivals
- community / migration / culture
- sport / performance memory
- work-adjacent public memory

---

## 10. Partner Types

### Family / Life

- photographers
- biographers
- celebrants
- retirement villages
- estate planners
- family history services

### Legacy / Memorial

- funeral homes
- cemeteries
- churches
- memorial parks
- councils
- monument/plaque providers

### Work

- MSPs
- Microsoft/Google ecosystem partners
- transformation consultancies
- HR / knowledge / ops providers

### Care

- aged care providers
- disability providers
- home care orgs
- clinics
- carer networks

### Learning

- schools
- tutoring networks
- literacy providers
- support specialists

### Places

- cafes
- restaurants
- gyms
- tourism operators
- museums
- councils
- heritage organisations
- venue networks

---

## 11. Front-End Information Architecture

The site/program content must help a customer immediately understand:

1. what Augmented Memories is
2. who it is for
3. what mode/product applies to them
4. what makes it different
5. how it works
6. what the place-aware/public layer means
7. how privacy and control work

Core pages:

- Home
- Products
- How It Works
- Memory Modes
- Places
- Legacy
- Work
- Care
- Learning
- Pricing
- Partners
- Privacy & Consent
- FAQ
- Contact / Demo / Register Interest

Home page blocks:

- hero: Places remember too
- parallel value prop: family, legacy, work, care, learning, places
- how it works in 3 steps
- memory modes overview
- public/place layer explanation
- memorial example
- travel/public discovery example
- privacy/consent block
- partner block
- CTA paths by user type

Product page blocks for each product:

- who it is for
- core promise
- where capture happens
- where it is used
- what outputs it gives
- optional modes
- partner fit
- likely pricing motion
- sample scenarios

Places page blocks:

- virtual-first place graph
- private vs public vs curated place memories
- GPS + QR + NFC model
- city/tourism/business/cemetery/museum examples
- ambient discovery explanation
- public memory network story

Privacy page blocks:

- you control your uploads
- private by default
- visibility levels
- partner/verified vs public content
- memorial sensitivity
- consent model
- export/delete/archive policy

---

## 12. Required Build Artifacts

The pen must create:

### Strategy Docs

- docs/augmented-memories/00_program-overview.md
- docs/augmented-memories/01_product-family.md
- docs/augmented-memories/02_memory-experience-layer.md
- docs/augmented-memories/03_place-memory-network.md
- docs/augmented-memories/04_memorial-cemetery-model.md
- docs/augmented-memories/05_partner-models.md
- docs/augmented-memories/06_privacy-consent-lifecycle.md
- docs/augmented-memories/07_frontend-ia-and-copy.md

### Front-End Copy Packs

- hero copy
- page copy for each product family
- CTA copy
- FAQ copy
- onboarding prompts
- place discovery copy
- memorial language pack
- child-safe / family-safe wording pack

### UX / Feature Pack

- customer journeys
- memory object model for UI
- visibility states
- mode toggles
- place discovery flows
- funeral/cemetery flows
- public place memory posting flows

### Build Backlog / Implementation Pack

- MVP1
- MVP2
- premium / partner layer
- future extras
- dependencies
- easy / medium / hard classification

### Brand and Positioning Pack

- umbrella narrative
- product naming system
- tonal rules
- what language not to use
- no creepy resurrection framing
- preserve what was real, do not manufacture false intimacy

---

## 13. MVP Priorities

### MVP1

- Life
- Legacy
- Places
- basic place graph
- private/public/circle visibility
- timeline
- story cards
- place attachment
- memorial flows
- GPS-based discovery
- QR support
- partner-ready memorial and venue hooks

### MVP2

- Work
- Care
- Learning
- companion mode
- trails
- smart display / voice outputs
- NFC layer
- verified/curated partner mode

### MVP3

- advanced public network
- emotional mode
- therapy / reflection
- museum/city products
- richer ambient experiences

---

## 14. Language Rules

Use:

- memory
- story
- place
- voice
- values
- continuity
- legacy
- family archive
- living memory
- remembrance
- stories tied to place
- discover what happened here

Avoid:

- resurrection
- deadbot
- immortal AI
- digital ghost as default positioning
- creepy chatbot language
- replace grief
- bring them back

For public place discovery, use language like:

- this place has stories
- people remember this place
- leave a memory here
- explore nearby memories
- places remember too

---

## 15. Commercial Shape

Do not overlock pricing yet, but front end should support these motions.

Consumer:

- monthly subscription
- one-off legacy/memorial pack
- premium archive package

Partner:

- revenue share
- annual licence
- per memorial/per venue/per team pricing

Enterprise / provider:

- annual contracts
- onboarding/setup
- premium support

---

## 16. Lifecycle Rules

The system must account for:

- active
- archived
- exported
- deleted
- read-only after lapse
- perpetual memorial options
- partner-owned vs user-owned records

Memorial data should not follow aggressive deletion defaults.
Consumer data can follow grace to archive to delete.
Enterprise/provider data follows policy.

---

## 17. What The Pen Should Build First

First deliverable:

- complete content and product pack that can power website, investor/product explanation, internal build alignment, and partner conversations

Second deliverable:

- front-end structure and copy for home, products, places, legacy, privacy, and partners

Third deliverable:

- feature / mode / experience matrix and implementation roadmap

---

## 18. Final Positioning

Augmented Memories is:

- a shared memory infrastructure
- a family and legacy product family
- a work and care continuity layer
- a place-aware public memory network
- a respectful system for preserving what mattered
- a discovery layer for the stories already embedded in the world

The simplest expression:

> Capture life. Attach meaning. Let places remember too.

The guiding doctrine:

> Preserve what was real. Surface it at the right moment. Let people choose how visible it becomes.
