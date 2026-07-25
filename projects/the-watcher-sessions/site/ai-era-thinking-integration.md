# AI Era Thinking integration contract

## Canonical destination

https://ai-era-thinking.lovable.app/

## Content source

The GitHub workspace under `projects/the-watcher-sessions/` is the canonical editorial source. The public site must not publish unfinished source fragments as if they are final chapters.

## Required site surfaces

- `/books/the-watcher-sessions` — book landing page
- `/books/the-watcher-sessions/read` — chapter index and reading interface
- `/books/the-watcher-sessions/read/:chapter` — individual chapter route
- `/books/the-watcher-sessions/world` — characters, terms, timeline, and motifs
- `/books/the-watcher-sessions/about` — premise, author note, and source inspiration
- `/books/the-watcher-sessions/download` — generated editions after validation

## Publication states

- `draft`: repository only, not visible publicly
- `preview`: selected chapters visibly labelled preview
- `published`: complete validated manuscript and editions available

## Payload fields per chapter

- number
- title
- slug
- act
- epigraph
- body_markdown
- status
- revision
- word_count
- sha256
- published_at

## Design direction

Cloak-and-dagger near-present thriller rather than utopian futurism. Use dark editorial typography, restrained motion, maps, redacted receipts, session traces, airport thresholds, and notebook imagery. Accessibility and long-form reading comfort take priority over visual spectacle.

## Deployment truth

No deployment is proven until the Lovable project has been updated, published, and re-read at the canonical URL. GitHub commits alone do not constitute site delivery.
