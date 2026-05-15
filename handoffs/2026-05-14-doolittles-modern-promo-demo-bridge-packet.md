# Doolittles / Synal Modern Promo Demo — Bridge Packet

Date: 2026-05-14
Owner: Troy Latter / Tech 4 Humanity
Status: PARTIAL
Priority: HIGH

## Purpose

Turn the attached Doolittles/Synal visual direction into a lighter, brighter, modern promo website and market-entry demo. The current images prove the concept and theatrical hook, but the website needs to feel cleaner, more premium, more current, and easier to buy into.

## Source assets inspected

- Dr Dolittle machine language infographic
- Doctor Dolittle machine/human language poster
- Dr Dolittle office machines visual
- WorkFamily AI conversation visual
- Animals/people/machines visual
- One command / everything changes orchestration visual
- Synal multi-surface command dashboard visual

## Creative decision

Keep:
- Doolittles character/hook
- talking to machines metaphor
- one command, many coordinated outcomes
- Synal as runtime layer
- orchestration across every surface
- proof/ledger language

Change:
- reduce dark steampunk density
- modernise toward bright, glass, soft gradients, cleaner cards
- use fewer labels per image
- make motion and demo proof visible
- make the hero readable in 8 seconds
- avoid overloaded posters as homepage hero

## Site direction

### Primary public front door

Brand hierarchy:
- Doolittles = public experience / translator / demo character
- Synal = runtime / orchestration layer
- Tech4Humanity = parent / trust / purpose

Hero line:

Systems don’t wait anymore.

Subline:

Doolittles turns one instruction into coordinated action across people, agents, tools, devices and systems — with proof you can see.

CTA:
- Watch the demo
- Try a command
- Explore Synal

## Required website pages

1. `/` — public promo front page
2. `/demo` — orchestration demo
3. `/synal` — runtime explanation
4. `/use-cases` — enterprise, education, home/place, community
5. `/proof` — Reality Ledger and replay explanation
6. `/assets` — campaign visuals, HeyGen/ElevenLabs scripts, share cards

## Homepage section order

1. Hero: one command, every surface, every system
2. Animated command example: due to rising fuel costs, we are restructuring
3. What happens next: finance, HR, Slack, TV, meeting room, logistics, smart office, AI agents
4. Why Siri/Alexa/copilots are not enough: they answer, Doolittles coordinates
5. Underneath is Synal: signals, snaps, pulse, focus, flows, memory
6. Proof: every action has status, owner, evidence, ledger state
7. Use cases: enterprise, education, home/place, community
8. CTA: see work move

## Visual system

Preferred mood:
- lighter, brighter, modern, premium
- white / soft navy / cyan / mint / soft gold accents
- glass panels, gradient glow, airy layout
- orchestration lines but fewer and cleaner
- character can stay warm and playful, but not heavy Victorian poster density

Avoid:
- huge text-heavy infographic posters as hero
- too much dark steampunk
- unreadable microcopy
- brand/legal logo clutter
- dense system maps above the fold

## Demo concept

Working title:

Doolittles: One Command Demo

Scenario:

Input command:
"Due to rising fuel costs, we are restructuring. Prepare the organisation."

Demo output panels:

- Command understood
- Finance recalibration
- HR workforce modelling
- Slack/Teams announcements
- Executive briefing scheduled
- TV/HoloWall update broadcast
- Logistics routes adjusted
- AI agent tasks created
- Smart office mode adjusted
- Reality Ledger updated

The demo should animate from one central command to 8-10 system cards. Each card moves through: queued → executing → complete → evidence attached.

## HeyGen / ElevenLabs video direction

Create a 60-90 second explainer.

Tone:
- playful, confident, premium
- not cartoon childish
- not corporate beige

Opening:
"Dr Doolittle could talk to animals. Doolittles talks to the machines — and the people, teams and systems around them."

Core message:
"Most assistants answer questions. Doolittles coordinates outcomes. One instruction becomes work packets, system updates, communications, evidence and replay."

Close:
"You talk once. Work moves everywhere. Proof stays visible."

## Required build outputs

1. Modern front-page copy and route structure
2. Visual design brief for lighter Doolittles/Synal brand
3. Demo storyboard
4. HeyGen/ElevenLabs script
5. Reusable campaign asset prompts
6. Runtime demo schema alignment
7. Bridge/dev execution checklist

## Implementation target

Use existing assets and repos where sensible:
- `TML-4PM/holo-org` has Synal-adjacent file intelligence/control-surface work
- `TML-4PM/augmented-humanity-coach` has broader runtime substrate patterns
- `TML-4PM/the-pen` remains canonical handoff and instruction layer

No dedicated Synal repo was visible from installed GitHub repo search. If a Synal repo exists elsewhere, executor should discover and prefer it. Otherwise create a dedicated Synal/Doolittles web surface or route under the appropriate active repo.

## Acceptance tests

- A modern homepage spec exists.
- Demo route design exists.
- Video script exists.
- Visual prompt pack exists.
- Runtime demo card states are defined.
- Bridge returns commit/deploy/demo receipt.
- If live deploy is not possible, a static preview and implementation packet must be returned.

## Reality Ledger

status: PARTIAL
result: Modern promo/demo execution packet created.
evidence:
- uploaded visual assets inspected
- GitHub repo search completed
- existing Synal-adjacent Holo-Org control surface located
- this handoff persisted to canonical repo
gaps:
- no dedicated Synal repo found in installed repository search
- live website not deployed in this session
- bridge/dev executor receipt still required
next_action:
- build modern Doolittles front page
- build demo route/storyboard
- generate lighter campaign prompts
- produce HeyGen/ElevenLabs script
- deploy or return preview receipt
elevation: Moves Doolittles from visual concept into market-entry website and promo demo execution.
pressure_flags:
- visual_overdensity
- brand_fragmentation
- runtime_demo_gap
- deployment_unproven
score: 0.84
