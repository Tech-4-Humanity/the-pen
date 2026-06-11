# Lumify password protection requirement

Status: BLOCKING / NON-NEGOTIABLE

All `/lumify/*` routes must require password access before content is served.

Password:

`1Lumify2Win!`

Required behaviour:

1. `/lumify/` shows only the password landing page until unlocked.
2. Direct page access, for example `/lumify/RPT_Lumify_2030Poster_StageCards_20260603.html`, must redirect to `/lumify/` or block until authenticated.
3. Refresh must preserve access only after successful unlock.
4. Opening a protected page in a new browser/session must require the password again.
5. No HTML page should be treated as public unless explicitly moved outside `/lumify/`.

Implementation note:

Client-side guards are not sufficient for board-safe protection. The correct implementation is route-level protection through Vercel Deployment Protection, Vercel Authentication, middleware, or a separate protected project/domain.

Validation checklist:

- Logged-out `/lumify/`: password landing only.
- Logged-out direct poster route: blocked/redirected.
- Logged-out direct truth-table route: blocked/redirected.
- Logged-out direct top-20 route: blocked/redirected.
- Logged-in route navigation: pages open normally.
- New private window: password required again.

Reality Ledger:

status: PARTIAL until Vercel route-level protection is proven.
result: Requirement documented and committed.
evidence: This file.
gaps: Vercel route-level enforcement not yet proven.
next_action: Implement Vercel-level project/domain protection or middleware for `/lumify/*` and validate with direct URL tests.
elevation: Moves access control requirement from page-level convention to deployment gate.
pressure_flags: Do not share the site externally until direct-route protection is proven.
score: 0.62
