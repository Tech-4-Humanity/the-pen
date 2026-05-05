# T4H Browser Companion v1

Status: PARTIAL runtime package, REAL GitHub handoff.

This package turns the Synal / Places / Browser Companion concept into a runnable MVP:

- Chrome extension with real side panel
- active tab context extraction
- Intent-to-Agent draft contract builder
- local backend deploy endpoint
- deterministic deploy receipt
- test script and acceptance criteria

It implements the first usable loop:

```text
Current page + user intent -> draft agent contract -> preview -> deploy endpoint -> receipt
```

## Folder structure

```text
products/t4h-browser-companion-v1/
├── extension/
│   ├── manifest.json
│   ├── background.js
│   ├── panel.html
│   ├── panel.js
│   └── styles.css
├── backend/
│   ├── package.json
│   ├── server.js
│   └── contracts/.gitkeep
├── contracts/
│   ├── canonical-agent-contract.schema.json
│   ├── test-leadgen-outreach.json
│   └── test-automated-sales-agent.json
├── docs/
│   ├── TEST_PLAN.md
│   ├── BRIDGE_HANDOFF.md
│   └── NEXT_BUILD_SPEC.md
└── README.md
```

## Quick start

### 1. Run backend

```bash
cd products/t4h-browser-companion-v1/backend
npm install
npm start
```

Expected output:

```text
T4H Companion backend running on http://localhost:3000
```

### 2. Load extension

1. Open Chrome.
2. Go to `chrome://extensions`.
3. Enable Developer Mode.
4. Select **Load unpacked**.
5. Choose `products/t4h-browser-companion-v1/extension`.

### 3. Test

1. Open any website.
2. Click the T4H Companion extension icon.
3. Type: `generate leads from this website`.
4. Click **Build Contract**.
5. Confirm the preview includes page context.
6. Click **Deploy Draft**.
7. Check backend console and `backend/contracts/` for receipt JSON.

## What is real

- The Chrome side panel is real.
- The extension reads the active page using Chrome extension APIs.
- The contract preview is generated client-side.
- The backend receives the contract and writes a JSON receipt.
- Test contracts are included.

## What is not yet real

- LLM interpretation is not yet connected.
- Supabase contract storage is not yet connected.
- Stripe checkout is not yet connected.
- MCP Bridge execution is not yet connected.
- Production deployment state transitions are represented but not enforced.

## Reality Ledger

| Field | Value |
|---|---|
| status | PARTIAL |
| result | Runnable GitHub package created for browser companion MVP |
| evidence | GitHub commit receipt from file creation in `TML-4PM/the-pen` |
| gaps | No live Supabase, Stripe, LLM interpreter, or MCP execution binding yet |
| next_action | Run locally, then wire `/interpret`, `/validate`, `/deploy` to Supabase + Bridge |
| elevation | Converts browser concept into reusable product package and bridge-ready build spec |
| pressure_flags | tool-limited execution, no local Chrome execution from assistant |
| score | 0.72 |

## Task ledger

| task_id | intent | execution | output | status | evidence | score |
|---|---|---|---|---|---|---|
| T4H-BC-V1-001 | Package browser companion MVP | GitHub file creation | Extension + backend + schema + tests | PARTIAL | GitHub commit | 0.72 |
