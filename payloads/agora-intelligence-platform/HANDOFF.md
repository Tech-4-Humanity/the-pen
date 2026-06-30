# Agora Intelligence Platform — Handoff

## Status

PARTIAL.

This handoff captures the current build direction and integration decision for combining:

- Platform War GraphRAG / multi-agent debate capability.
- DTube-style decentralised media, video, IPFS, and creator interaction concepts.
- T4H evidence, receipt, wallet, and enterprise operating model.

## Key decision

Do **not** merge `platform-war-public` and `dtube` directly.

Use them as reference sources and build a modern Agora platform with separate services:

- media frontend and upload flow
- transcription service
- graph extraction service
- GraphRAG retrieval service
- debate engine
- evidence and receipt service
- admin and enterprise portals

## Why

`platform-war-public` is useful as a Python GraphRAG/debate reference but needs hardening:

- environment-based config
- CPU-safe defaults
- FastAPI wrapping
- provider abstraction
- validation before paid LLM calls
- runtime receipts

`dtube` is useful as a decentralised media reference but should not be adopted as-is:

- archived repo
- old React/Truffle patterns
- deprecated testnets referenced
- unsafe mnemonic handling pattern
- no GraphRAG runtime

## Target architecture

```text
agora/
├── apps/
│   ├── web/
│   ├── admin/
│   ├── creator-studio/
│   └── enterprise-portal/
├── services/
│   ├── api-gateway/
│   ├── media-service/
│   ├── transcription/
│   ├── graph-rag/
│   ├── debate-engine/
│   ├── moderation/
│   └── evidence/
├── packages/
│   ├── ui/
│   ├── shared/
│   ├── analytics/
│   └── wallet/
├── infrastructure/
│   ├── docker/
│   ├── supabase/
│   ├── aws/
│   └── vercel/
└── receipts/
```

## MVP workflow

```text
Upload media
→ store in S3/IPFS
→ transcribe
→ ingest transcript/comments
→ extract entities and relations
→ build/search graph
→ generate multi-perspective debate
→ create evidence receipt
→ expose through web/admin/export APIs
```

## P0 build backlog

1. Create writable T4H repo or expand into `TML-4PM/the-pen`.
2. Commit full service scaffold as text tree.
3. Wrap Platform War into FastAPI.
4. Add provider-agnostic LLM config.
5. Add Supabase schema and migration runner.
6. Add API gateway routing.
7. Add Docker Compose local runtime.
8. Add basic Next.js frontend shell.
9. Add receipt generation for every pipeline step.
10. Add runtime validation script.

## HITL required only for

- GitHub repo creation or write access outside `TML-4PM/the-pen`.
- Supabase service role / migration target.
- Vercel project/token.
- AWS/S3 deployment credentials.
- Any legal/compliance/public claims approval.

## Current receipt

GitHub receipt committed in:

`receipts/agora/agora-intelligence-platform-cycle-receipt-20260630.md`
