# Receipt: workfamilyai.org Contact & Footer Audit

**Date:** 2026-05-16T15:12:00+10:00  
**Agent:** Perplexity (autonomous audit via live HTTP inspection)  
**Status:** AUDIT COMPLETE — fix spec raised, awaiting execution  

---

## What was audited

| Check | Method | Result |
|---|---|---|
| Live homepage reachability | HTTP GET workfamilyai.org | ✅ 200 OK |
| Contact form behaviour | Screenshot + user-reported error banner | ❌ "Send failed" on submit |
| Footer link targets | Parsed `<a>` tags from live HTML | ❌ Partner Program → holoorg.vercel.app/wholesale |
| API / endpoint in HTML | Regex scan of served HTML | ⚠️ No plain endpoint — logic is inside JS bundle |
| External scaffold URLs | Regex scan | ⚠️ Lovable project URL in JSON-LD contactPoint |
| Other CTA links (nav, hero) | Parsed `<a>` tags | ⚠️ Only 1 link extracted (footer) — rest are JS-rendered |

---

## Findings

1. **Contact form is broken in production.** Red error banner visible to all users attempting to submit. Exact failure mode is inside compiled JS bundle — source access required to trace root cause.
2. **Footer "Partner Program" link is wrong.** Target: `https://holoorg.vercel.app/wholesale`. Legacy placeholder URL from prior build, likely GPT-assisted, never corrected before deployment.
3. **JSON-LD contactPoint.url** references a Lovable project URL, not workfamilyai.org. Not user-visible but bad for SEO and brand credibility.
4. **Site is a bundled React SPA** (`/assets/index.GNR2GRT-.js`) with Supabase vendor bundle. All interactive logic including form submit is in the bundle — no plain HTML form action, no visible endpoint in the HTML shell.

---

## Fix spec location

`receipts/2026-05-16_WFAI_CONTACT_FOOTER_FIX_SPEC.md`

---

## Next actions

1. Assign fix spec to dev with workfamilyai.org repo/deploy access.
2. Once fix is applied and smoke-tested, close this receipt with a ✅ completion note.
3. If the correct Partner Program destination URL is known before dev picks this up — add it as a comment on the fix spec.

---

## Closed by
_Pending — to be updated when fix is confirmed in production._
