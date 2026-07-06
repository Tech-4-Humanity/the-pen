# apps/web scaffold

## Purpose

Next.js frontend for Agora Media Hub, Debate Arena, Community Explorer, Evidence Vault, Creator Studio, and Enterprise Console.

## Target files

```text
apps/web/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── media/page.tsx
│   ├── debates/page.tsx
│   ├── graph/page.tsx
│   ├── evidence/page.tsx
│   ├── studio/page.tsx
│   └── enterprise/page.tsx
├── components/
│   ├── app-shell.tsx
│   ├── runtime-status-badge.tsx
│   ├── receipt-status-badge.tsx
│   ├── media-card.tsx
│   ├── debate-card.tsx
│   ├── entity-card.tsx
│   └── evidence-pack-card.tsx
├── lib/
│   ├── api-client.ts
│   ├── routes.ts
│   └── status.ts
├── package.json
└── README.md
```

## Initial pages

| Page | Function |
|---|---|
| `/` | operational dashboard |
| `/media` | uploaded media assets |
| `/debates` | debates and replay |
| `/graph` | entities, relationships, communities, narratives |
| `/evidence` | receipts and evidence packs |
| `/studio` | creator workflow |
| `/enterprise` | tenant administration |

## Required behaviours

- Show PARTIAL/REAL/BLOCKED status on every major object.
- Never render generated content without evidence state.
- Use tabular fallback for graph visualisations.
- Expose copyable receipt IDs.
- Treat missing runtime as PARTIAL, not success.
