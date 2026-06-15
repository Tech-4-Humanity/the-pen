# Rhythm Method x AICS Site Package

Status: READY FOR SITE INTEGRATION
Reality Ledger: PARTIAL until deployed and verified
Source issue: #197

## Purpose

This package harvests the reusable value from the Rhythm Method recovery thread and converts it into a site-ready product layer.

The recovery problem was simple: the Rhythm Method site needed to be live, and a suspected 50k / 100k artist seed file could not be found in Supabase Storage.

The product discovery was larger: AICS already has the shape of an artist intelligence and event prediction system. Rhythm Method should operate as the public-facing AICS music and cultural signal surface.

## Core Positioning

Rhythm Method is not only a Hottest 100 predictor.

Rhythm Method is a live cultural signal engine for music events, artist momentum, ranking confidence, and prediction accuracy.

It should support:

- triple j Hottest 100
- Tamworth Country Music Festival
- Golden Guitars
- ARIAs
- festival lineups
- Spotify and streaming momentum
- future local music/culture events

## Architecture

```text
AICS
├── Artists
├── Features
├── Scores
├── Runs
├── Artifacts
├── Signal Events
├── Artist Signals
├── Leaderboards
└── Reality Ledger

Rhythm Method
├── Home
├── Live Events
├── Predictions
├── Results
├── Artists
├── Signals
├── Leaderboards
├── Accuracy
├── Archive
└── Dataset Health
```

## Reusable Modules

### 1. Live Event Engine

Reusable event flow:

```text
Event
  ↓
Signal Collection
  ↓
Prediction / Ranking
  ↓
Live Results
  ↓
Accuracy Score
  ↓
Archive
```

Site sections:

- `/events`
- `/events/triple-j-hottest-100`
- `/events/tamworth-country-music-festival`
- `/events/golden-guitars`
- `/archive`

Minimum live event card fields:

- event name
- status: upcoming / live / completed / archived
- date window
- source links
- number of artists/tracks monitored
- prediction confidence
- latest refresh timestamp

### 2. AICS Scoring Layer

Use existing AICS data shape:

- `aics_artists`
- `aics_artist_features`
- `aics_artist_features_hot`
- `aics_artist_scores`
- `aics_runs`
- `aics_run_artifacts`
- `aics_leaderboard_cache`
- `aics_feature_registry`
- `aics_pillar_recipes`
- `aics_weights_profiles`

Rhythm Method should show outputs from AICS, not duplicate AICS logic in frontend-only code.

### 3. Signal Registry

Signal sources should be formalised rather than hard-coded.

Core signal categories:

- Spotify signals
- Triple J / Unearthed signals
- Tamworth / Golden Guitar signals
- Reddit/community signals
- YouTube/social signals
- festival and lineup signals
- historical placement signals

Suggested signal fields:

- `signal_key`
- `source`
- `source_uri`
- `value`
- `value_text`
- `confidence`
- `measured_at_utc`
- `run_id`

### 4. Event Registry

Add event/artist linkage so the same engine can power many events.

```sql
create table if not exists public.aics_signal_events (
  event_id text primary key,
  event_type text not null,
  title text not null,
  starts_at_utc timestamptz,
  ends_at_utc timestamptz,
  source_uri text,
  status text not null default 'planned',
  created_at_utc timestamptz not null default now(),
  updated_at_utc timestamptz not null default now()
);

create table if not exists public.aics_artist_signals (
  event_id text not null references public.aics_signal_events(event_id),
  artist_id text not null,
  signal_key text not null,
  signal_weight numeric not null default 1,
  evidence jsonb,
  created_at_utc timestamptz not null default now(),
  primary key (event_id, artist_id, signal_key)
);
```

Seed examples:

```sql
insert into public.aics_signal_events(event_id, event_type, title, starts_at_utc, source_uri, status)
values
  ('triplej_h100_2025', 'triplej_hottest100', 'triple j Hottest 100 of 2025', '2026-01-24T01:00:00Z', 'https://www.abc.net.au/triplej/countdown/hottest100/1-100', 'completed')
on conflict (event_id) do nothing;

insert into public.aics_signal_events(event_id, event_type, title, starts_at_utc, ends_at_utc, source_uri, status)
values
  ('tamworth_2026', 'festival', 'Tamworth Country Music Festival 2026', '2026-01-15T13:00:00Z', '2026-01-25T13:00:00Z', 'https://www.tcmf.com.au/', 'completed')
on conflict (event_id) do nothing;
```

### 5. Spotify Cache

Do not call Spotify live on every page render. Cache and write features back into AICS.

```sql
create table if not exists public.aics_spotify_cache (
  cache_key text primary key,
  payload jsonb not null,
  fetched_at_utc timestamptz not null default now()
);

create index if not exists aics_spotify_cache_fetched_at on public.aics_spotify_cache (fetched_at_utc desc);

alter table public.aics_artists
add column if not exists spotify_artist_id text;

create index if not exists idx_aics_artists_spotify_artist_id on public.aics_artists(spotify_artist_id);
```

Minimum Spotify fields to expose:

- Spotify artist ID
- canonical artist name
- followers
- popularity
- genres
- image URL
- last refreshed timestamp

### 6. Dataset Health Page

The thread exposed a recurring operational problem: important datasets become hard to find.

Add `/dataset-health` or internal admin section.

Show:

- artist count
- distinct artist IDs in feature tables
- feature row count
- score row count
- latest run
- max historical run scope
- latest artifact URI
- biggest storage objects
- last Spotify refresh
- Reality Ledger status

Core queries:

```sql
select 'aics_artists' as table_name, count(*)::bigint as exact_rows from public.aics_artists
union all select 'aics_artist_features', count(*)::bigint from public.aics_artist_features
union all select 'aics_artist_features_hot', count(*)::bigint from public.aics_artist_features_hot
union all select 'aics_artist_scores', count(*)::bigint from public.aics_artist_scores
union all select 'aics_runs', count(*)::bigint from public.aics_runs
union all select 'aics_run_artifacts', count(*)::bigint from public.aics_run_artifacts;
```

```sql
select
  max(scope_artist_count) as max_scope_artist_count,
  min(created_at_utc) as first_run_utc,
  max(created_at_utc) as last_run_utc
from public.aics_runs;
```

```sql
select
  run_id,
  artifact_type,
  artifact_uri,
  sha256,
  created_at_utc
from public.aics_run_artifacts
where artifact_uri ilike any (array[
  '%seed%', '%artist%', '%50k%', '%50000%', '%100k%', '%dump%',
  '%ndjson%', '%jsonl%', '%parquet%', '%csv%', '%spotify%', '%rhythm%', '%hottest%'
])
order by created_at_utc desc
limit 100;
```

### 7. Reality Ledger

Expose simple truth states.

```text
REAL    = verified live with receipts
PARTIAL = exists but missing runtime/deployment/evidence
PRETEND = described but not implemented or not verified
```

Initial state examples:

| Capability | Status | Reason |
|---|---|---|
| AICS table family | REAL | Tables confirmed in Supabase |
| Missing 50k artist seed | PARTIAL | Not found in Storage; AICS audit still required |
| Rhythm Method live site | PARTIAL | User reports fixed; deployment receipt still needed |
| Spotify cache | PARTIAL | SQL spec ready; implementation receipt needed |
| Tamworth signal event | PARTIAL | Event model ready; source ingestion still needed |
| Hottest 100 result mirror | PARTIAL | Pattern ready; production route receipt needed |

## Site Content Blocks

### Homepage Hero

Rhythm Method tracks music culture as it moves.

It combines artist data, streaming momentum, event signals, public rankings, and AICS scoring to turn live music moments into explainable predictions and archived evidence.

### What It Does

- follows live music events
- ranks artist momentum
- compares predictions with final results
- stores signal evidence
- keeps a permanent archive
- shows dataset health instead of hiding the machinery

### Why It Exists

Music prediction sites often disappear, break, or rely on opaque scraping. Rhythm Method is built as a reusable signal system: every event, artist, feature, prediction, and result can be traced.

### AICS Explainer

AICS is the scoring layer behind Rhythm Method. It stores artist records, feature values, scoring runs, artifacts, weight profiles, and leaderboard caches.

Rhythm Method is the public lens over that intelligence.

## Recommended Navigation

```text
Home
Live Events
Predictions
Results
Artists
Signals
Leaderboards
Accuracy
Archive
Dataset Health
About AICS
```

## Implementation Priority

### Phase 1: Public usefulness

- Home
- Live Events
- Results / archive page
- Dataset Health card
- basic AICS counts

### Phase 2: Prediction layer

- scoring run viewer
- prediction leaderboard
- accuracy comparison
- event-specific feature weights

### Phase 3: Signal marketplace

- Spotify cache
- Tamworth / Golden Guitar feeds
- Triple J / Unearthed feeds
- community/social signals
- confidence scoring

## Acceptance Criteria

Move this package from PARTIAL to REAL only when:

- Rhythm Method site includes the new product positioning.
- Site has at least one event page.
- Site has dataset health visibility.
- AICS rowcounts are displayed or available through an admin/API endpoint.
- Spotify/cache status is visible.
- Hottest 100 and Tamworth exist as signal events or documented event records.
- A deployment receipt is posted back to issue #197.

## Builder Note

Do not rebuild the whole site just to use this.

Add this as a thin product layer over the current fixed site:

1. Add pages/navigation.
2. Add AICS status cards.
3. Add event registry model.
4. Add signal source cards.
5. Add Reality Ledger statuses.
6. Wire deeper live data only after the site remains stable.
