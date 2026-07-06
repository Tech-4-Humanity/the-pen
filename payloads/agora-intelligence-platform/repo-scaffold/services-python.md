# services scaffold

## Purpose

Python FastAPI services for Agora runtime. This is a scaffold map, not a live runtime receipt.

## Target files

```text
services/
├── api-gateway/
│   ├── app/main.py
│   ├── app/routes.py
│   ├── app/settings.py
│   ├── pyproject.toml
│   └── README.md
├── media-service/
├── transcription/
├── graph-rag/
├── debate-engine/
├── evidence/
├── moderation/
└── wallet-service/
```

## Common service contract

Every service must expose:

| Endpoint | Purpose |
|---|---|
| `GET /health` | service health |
| `GET /version` | build/version metadata |
| `POST /receipts` or receipt envelope | state-change evidence |

## Service requirements

- Config from environment only.
- No hardcoded API keys.
- CPU-safe default for AI/embedding work.
- Provider abstraction for LLM/transcription/vector store.
- Receipt emitted for every state mutation.
- Failure response must include recovery route.

## P0 service order

1. evidence service
2. media service
3. transcription service
4. graph-rag service
5. debate engine
6. api gateway
7. frontend integration

## Done criteria before REAL

- local service starts
- health endpoint returns
- request schema validates
- persistence writes to target database
- receipt is generated and retrievable
- logs/telemetry observed
