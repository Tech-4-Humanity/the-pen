# Architecture

## Flow
User -> Extension/Widget -> Supabase Event -> Agent Queue -> Execution -> Evidence Receipt -> Dashboard -> Billing

## Components
- Chrome Extension (capture + intent)
- Supabase (registry + events + receipts)
- Agent Queue (execution trigger)
- Lambda / workflows (actions)
- Command Centre (visibility)

## Tables
- synal_store_products
- synal_store_events
- synal_store_evidence_receipts
- synal_store_installations

## Evidence model
intent, execution, output, classification, evidence

## Classification
REAL, PARTIAL, PRETEND
