# First Deployable Product — Accento Memory Places MVP

## Definition

Accento Memory Places is the first deployable product built on the shared memory graph. It enables:

- creation of memory objects
- attachment of memories to places
- visibility control (private / circle / public)
- discovery of nearby public memories
- optional partner triggers (QR / NFC) layered later

## Core flows

### 1. Capture
User creates a memory:
- title
- description
- optional media
- optional people
- optional place (auto from GPS or manual selection)

### 2. Structure
Memory is stored in `accento_memory_object` and linked to:
- `accento_place_entity`
- `accento_person_entity`
- `accento_memory_asset`

### 3. Visibility
User sets:
- private (default)
- circle (shared group)
- public (eligible for place discovery)

### 4. Discovery
Clients query `v_accento_public_memory_nearby` or `v_accento_place_density`:
- show memory density per place
- show memory list on demand

### 5. Interaction
All views and actions logged via `accento_log_interaction`.

## Experience modes (Phase 1)

- Reflection (default timeline)
- Discovery (map/list of nearby memories)

## Experience modes (Phase 2)

- Story mode (aggregate memories into narratives)
- Emotional mode (group by emotion_vector)
- Trails (ordered place sequences)

## Devices

- mobile app (primary)
- web app (secondary)
- optional audio layer via earbuds

## Out-of-scope for MVP

- full partner marketplace
- enterprise integrations
- advanced moderation tooling

## Success criteria

- create memory → appears in personal timeline
- set public → appears in nearby view for other users
- location density visible via view
- RLS enforces ownership and visibility

## Monetisation hooks

- subscription (storage + advanced features)
- place network upgrade (business accounts)
- memorial upgrade (one-off packs)

## Next steps

- build minimal client
- execute SQL via MCP Bridge
- run smoke tests
- connect Supabase to frontend

