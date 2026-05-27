# Chat Project Migration v1.0

## Purpose
Turn scattered ChatGPT threads into a small, durable project operating layer.

## Native boundary
Direct bulk movement of existing ChatGPT chats into ChatGPT Projects is not available through this tool surface. This file defines the operating model, taxonomy, migration rules, evidence model, and first sprint backlog.

## Projects
1. Command Centre / Spine
2. Jobs / CV / Immediate Income
3. GTM + Revenue Engine
4. Tech4Humanity
5. Outcome Ready + Reading Buddy
6. WorkFamilyAI
7. NeuroPAK + GC-BAT + BCI
8. Research Vault
9. Archive / Parking Lot

## Migration rule
Move a thread only if it is one or more of the following:
- active in the last 90 days
- revenue related
- recurring
- unfinished execution
- infrastructure dependent
- audit or governance relevant
- reusable as an asset

Archive everything else.

## Required pinned note per project
- STATUS:
- PURPOSE:
- LAST DECISION:
- ACTIVE ASSETS:
- NEXT 3 MOVES:
- BLOCKERS:
- EVIDENCE:

## Project states
- REAL: moved or captured with evidence and next action
- PARTIAL: classified but not fully moved or evidenced
- BLOCKED: cannot be moved because native capability is unavailable
- ARCHIVED: deliberately parked
- DUPLICATE: merged into stronger thread or state page

## Classifier fields
thread_title, source_id, project, status, confidence, value_score, revenue_relevance, execution_relevance, audit_relevance, next_action, evidence, gaps

## First sprint backlog
1. Create the nine ChatGPT Projects if absent.
2. Add the pinned note to each project.
3. Move Jobs / CV / Immediate Income first.
4. Move Command Centre / Spine second.
5. Move GTM + Revenue Engine third.
6. Archive duplicate and low-value history.
7. Export or copy high-value threads that cannot be moved.
8. Later run classifier against any exported chat corpus.
9. Bind completed project states to the Reality Ledger.

## Reality Ledger
status: PARTIAL
result: v1.0 operating model committed to repository
evidence: GitHub commit receipt required
gaps: no native bulk move, no exported corpus, no runtime classifier, no verified manual moves
next_action: create receipt issue and begin manual project creation/migration sprint
score: 0.78
