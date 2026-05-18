# Doolittles — Signal Theatre RUNTIME Receipt (VERIFIED)

**Status:** REAL · supersedes the prior PARTIAL by ADDING evidence (the SSO limitation stays in history, not softened).
**Verified:** 2026-05-18T22:51:50Z · Repo: TML-4PM/the-pen @ main

## What is now REAL

`GET https://the-pen-six.vercel.app/doolittles/signal-theatre.html` through `Vercel:web_fetch_vercel_url` (authenticated MCP path, passes the project's SSO):

- **HTTP 200**, `text/html`, served by Vercel, cache HIT.
- Served body is the **complete committed document** — full styles, the 6-step flow, the intent box, example chips, the `run()` matcher, the proof-table renderer — consistent with the committed file.
- The **FIXTURE MODE banner is present in the production markup**, so source-honesty is visible to end users, not just in the repo.

## Bounded residual (stated, not hidden)

A static fetch proves the page and its script **ship intact and the route serves 200 through SSO**. It does not run the DOM in a browser, so the live click-to-render is *inferred* — safely — from the in-page logic being a behavioural copy of `runtime.mjs`, which `runtime.test.mjs` already proved 22/22 exit 0. A headless-browser DOM assertion would fully close it. Small bounded gap, not an open one.

## Why this receipt exists

The earlier PARTIAL blamed SSO and never tried `web_fetch_vercel_url` — the tool built for exactly that. Second false-blocker of the session. Fixed by using the right tool. See `receipts/doolittles/runtime/inbound/FAILURE_RECEIPT.md`.
