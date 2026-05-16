# Fix Spec: workfamilyai.org — Contact Form + Footer CTA

**Date:** 2026-05-16  
**Raised by:** Perplexity (autonomous audit)  
**Status:** OPEN — awaiting dev assignment  
**Priority:** High — user-facing production breakage  
**Project:** workfamilyai.org  
**Source repo:** Unknown at time of writing — requires access to Lovable export or deployment repo  

---

## Evidence of breakage

1. **Contact form** — Production shows red error banner: _"Send failed. Please try again or email us directly."_ on form submission.
2. **Footer "Partner Program" button** — Points to `https://holoorg.vercel.app/wholesale`. Legacy/wrong destination.
3. **Structured data** — `contactPoint.url` in JSON-LD schema points to a Lovable project URL, not workfamilyai.org.

---

## Root cause hypotheses

### Contact form
- Submit handler calling a dev/staging endpoint that no longer exists or is misconfigured in production.
- API key / Supabase project ID missing or wrong for the `workfamilyai.org` deployment.
- CORS rejection between the live domain and the backend service.
- Validation rule mismatch causing silent failure before the network request.

### Footer CTA
- Built by GPT or a prior AI-assisted session; link was never updated from placeholder before deploy.
- `holoorg.vercel.app/wholesale` was a dev-time reference, never replaced.

---

## Scope of work

### 1. Contact form
- [ ] Locate the contact form React component and its submit handler.
- [ ] Identify the endpoint / service being called (Supabase function, Resend, Formspree, etc.).
- [ ] Confirm the endpoint is reachable from the `workfamilyai.org` production domain.
- [ ] Verify API keys / env vars are correct for production (not leaking dev values).
- [ ] Check CORS config on the receiving service allows `workfamilyai.org`.
- [ ] Fix the root cause — endpoint, key, or CORS.
- [ ] Add hard fallback: visible `mailto:` link that appears when submission fails.
- [ ] Smoke test: submit from mobile Safari + desktop Chrome, confirm message arrives at destination inbox.
- [ ] Confirm error banner only fires on genuine failure.

### 2. Footer CTA
- [ ] Find the footer component rendering the "Partner Program" `<a>` tag.
- [ ] Replace `https://holoorg.vercel.app/wholesale` with the correct WorkFamilyAI partner destination, OR remove/comment until confirmed.
- [ ] Search codebase for any other references to `holoorg.vercel.app` or foreign/legacy domains — remove all user-visible ones.

### 3. Metadata cleanup
- [ ] Update JSON-LD `contactPoint.url` to a valid workfamilyai.org page.
- [ ] Remove/update any Lovable project URLs from structured data, OG tags, and `<meta>` content.

### 4. CTA/button audit
- [ ] Audit all header nav links, primary CTAs, and footer links.
- [ ] Confirm every link goes to the correct intended destination.
- [ ] Flag anything pointing to Vercel preview URLs, Lovable project URLs, or other non-production domains.

---

## Acceptance criteria

- [ ] Contact form submits successfully from a fresh browser session on `https://workfamilyai.org/`.
- [ ] Successful submission shows clear success state; message arrives at intended inbox.
- [ ] On network failure, user sees graceful error + direct email fallback link.
- [ ] Footer no longer contains any reference to `holoorg.vercel.app`.
- [ ] No user-visible links point to foreign, staging, or prototype domains.
- [ ] JSON-LD structured data is accurate and self-referential to workfamilyai.org.

---

## Blocker

Source repo / Lovable export path required to execute. Assign to dev with access to the workfamilyai.org deployment.
