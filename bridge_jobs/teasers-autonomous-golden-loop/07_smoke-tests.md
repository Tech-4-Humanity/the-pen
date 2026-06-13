# Teasers Smoke Tests

## ST-01 Schema
Verify all Teasers tables exist.
Expected: PASS.

## ST-02 Prompt Seed
Verify at least four starter prompts exist.
Expected: PASS.

## ST-03 Delivery Event
Create one teaser_delivery event.
Expected: delivery id returned.

## ST-04 Response Event
Create one teaser_response event.
Expected: response id returned.

## ST-05 Score Event
Create one teaser_signal_score event.
Expected: score id returned.

## ST-06 Synal Widget
Verify widget slug teasers-human-effectiveness is visible.
Expected: PASS.

## ST-07 Command Centre
Verify Teasers appears in human signals feed.
Expected: PASS.

## ST-08 Runtime Receipt
Verify teaser_runtime_receipt row exists.
Expected: PASS.
