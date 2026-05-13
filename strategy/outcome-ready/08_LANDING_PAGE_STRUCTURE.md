# 08 — Landing Page Structure

## Domain & Routing

| Domain / path | Brand | Purpose |
|---------------|-------|---------|
| `outcomeready.com.au` (or similar) | Outcome Ready master | Trust + about + investor narrative |
| `thrivingbiz.com.au` (or similar) | Thriving Biz | All Biz traffic |
| `thrivingkids.com.au` (or similar) | Thriving Kids | All Kids traffic |

Domain names directional — Troy to confirm availability.

## Outcome Ready (Master Site)

**Audience:** anyone wanting the big picture — partners, investors, journalists, sector watchers.

**Pages:**

1. **Home**
   - Hero: "Outcome infrastructure for systems under pressure."
   - Two doors: "Are you a provider/practitioner? → Thriving Biz" / "Are you a parent/school? → Thriving Kids"
   - Strip of credibility (T4H, partners, sector references)

2. **What we do** — Decision + Execution + Evidence; diagram of spine
3. **For partners / channel** — Accountants, allied health networks, schools, advocacy
4. **About / team / contact**

## Thriving Biz Site

**Audience:** providers, practitioners, sole-traders, owners, accountants (channel).

### Page tree

```
/  (home)
/audit-risk-scan
/registration-readiness
/audit-defence-pack
/compliance-os
/evidence-engine
/ai-office
/ai-calls
/practice-os-bundle
/full-stack-bundle
/alerts
/pricing
/about
/contact
/login
```

### Home page structure

1. **Hero** — H1: "Stay compliant. Stay operational. Stay paid." CTA: "Take the 2-minute Readiness Snapshot"
2. **Pressure strip** — "Mandatory registration from 1 July 2026"
3. **Three-door product layout** — Survive / Defend / Operate
4. **Evidence proof points** — sample artefact, dashboard view, three-question framing
5. **Testimonials / case patterns** (anonymised)
6. **Pricing teaser**
7. **Reform Alert sign-up**

### Audience-specific sub-pages

- `/for/sil-providers` — survival positioning, July deadline
- `/for/platform-providers` — registration pressure, evidence
- `/for/therapists` — practitioner-mode, AI Office + reporting
- `/for/sole-traders` — full stack, run a practice solo
- `/for/accountants` — channel partner page

## Thriving Kids Site

**Audience:** parents primarily, with sub-flows for practitioners and schools.

### Page tree

```
/  (home)
/whats-changing
/family-risk-snapshot
/sweet-spots
/parent-action-plan
/parent-os
/reading-buddy
/functional-tracker
/plan-defence
/escalation
/transition-bridge
/2e
/for-schools
/for-practitioners
/for-providers
/pricing
/about
/contact
/login
```

### Home page structure (parent-first)

1. **Hero** — H1: "Understand your child. Support their progress. Prove what is working." CTA: "Free Family Risk Snapshot"
2. **Empathy strip** — "If your child has lost or is losing NDIS support, you are not alone."
3. **Three doors** — Understand / Support / Prove
4. **Pathway preview** visual
5. **Reading Buddy showcase** — age-appropriate UI, parent dashboard preview
6. **2e callout** — "Twice-exceptional kids deserve better systems. Not underperforming. Misaligned."
7. **Sub-audience entry points** — schools / practitioners / providers
8. **Free explainer prompt**

### Critical UX constraints (Thriving Kids)

- **No child-directed sales messaging anywhere.**
- **Reading Buddy child interface** must be:
  - Age-appropriate
  - Free of any commercial messaging or upsell prompts
  - Free of any social or sharing prompts
  - Strictly focused on the reading activity
  - Compliant with critical child-safety requirements
- **Parent-mode UI** is where all commercial activity lives.
- **Consent flows** must clearly explain what is collected, why, and who can see it.
- **Default to private**.
- **Functional language only**. No diagnostic claims.

### Sub-pages

- `/for-schools` — "Support complex students without more staff." Pilot offer (cohort of 20), 2e Toolkit, outcomes dashboard, direct booking
- `/for-practitioners` — "Less admin. More delivery. Defensible reports." Reporting Pack, Reading Buddy view, referral commission
- `/for-providers` — cross-links to Thriving Biz Compliance OS

## Shared Infrastructure

- **Auth:** single sign-on backed by Identity (ConsentX-bound)
- **Billing:** Stripe with brand-specific products
- **Help / docs:** brand-specific knowledge bases
- **Status page:** shared
- **Privacy + terms:** shared

## Compliance / Legal Footer

Both brands must show:
- "Tech 4 Humanity Pty Ltd · ABN 70 666 271 272"
- "Not medical, legal, or financial advice."
- "Outcome Ready does not guarantee NDIS eligibility outcomes."
- Privacy policy + terms link
- Accessibility statement

## Build Order

1. Outcome Ready master site (lean) — 1 page is fine to start
2. Thriving Biz home + Snapshot + Compliance Scan booking — by **31 May 2026**
3. Thriving Biz full ladder + Compliance OS subscription flow — by **30 June 2026**
4. Thriving Kids home + What's Changing + Family Risk Snapshot — by **31 July 2026**
5. Thriving Kids full ladder + Reading Buddy + Parent OS subscription — by **31 August 2026**
6. School + practitioner sub-pages — by **30 September 2026**
7. Window 3 retention + adjacency pages — by **30 November 2026**

## Open Questions For Troy

- [ ] Final domain names
- [ ] Visual identity per brand (colour, type, tone)
- [ ] Whether Reading Buddy keeps a separate landing or fully under Thriving Kids
- [ ] Whether to use Lovable / Vercel / Webflow for each brand
