# Teasers Ideation and Outcome Change Note

Status: REAL for GitHub documentation receipt. PARTIAL for runtime until bridge execution and system proof are returned.

## Original ideation

The original Teasers concept was framed as a browser activity that asks one or two random questions during the day. It could appear when a user first opens the laptop or browser, with pause and reappearance behaviour. The surface looked like a daily question, topical check-in, or lightweight survey.

Example early prompts:
- Are you feeling busier than last week?
- Did this article match your experience?
- Are you feeling in control today?

The early value hypothesis was simple: capture more data about how people are thinking, doing, acting, and working behind the scenes.

## Problem with the original framing

That framing was too small.

If Teasers is only a survey or popup engine, it risks becoming noisy, annoying, and low trust. It would create response fatigue and weak data. It would also underuse the stronger browser runtime, MCP Bridge, Supabase, Command Centre, AHC, WorkFamilyAI, HoloOrg, wearable, robotics, and personalisation pathways already in the family architecture.

## Changed ideation

Teasers is now reframed as a Human Effectiveness Signal System.

It is not trying to ask questions for their own sake. It is trying to answer:

> When is a human actually effective?

And then:

> What conditions repeatedly create, reduce, or distort that effectiveness?

This moves Teasers from survey collection into autonomous signal intelligence.

## Changed outcome

The required outcome is no longer a question widget.

The required outcome is the Teasers Autonomous Golden Loop:

1. Trigger from browser open, meaningful tab, cadence window, or behavioural signal.
2. Select one pulse, context, topical, reflection, or recovery prompt.
3. Deliver a low-friction one-tap card.
4. Capture answer, latency, snooze, dismiss, session context, and device context.
5. Enrich with browser/session/context signals.
6. Optionally enrich later with phone, wearable, robotics, home, and precision-health adjacent signals.
7. Score Focus, Reactivity, Load, Control, Recovery, Movement, and Effectiveness.
8. Produce a Human Effectiveness Vector.
9. Store canonical evidence in Supabase and Reality Ledger-compatible records.
10. Activate insights through Command Centre, AHC, WorkFamilyAI, HoloOrg, and downstream agents.
11. Evolve cadence, prompt quality, suppression, fatigue controls, and intervention logic.

## Wearable integration map

Wearables are not the first dependency. They are an enrichment layer.

Layer 1: Browser and declared signals
- prompt answer
- response latency
- snooze or dismiss
- tab churn
- dwell time
- session timing

Layer 2: Phone and mobility signals
- movement state
- location mode where consented
- device-open cadence
- mobility proxies

Layer 3: Wearable signals
- steps
- movement bursts
- sleep proxy
- heart rate variability where available
- recovery proxy

Layer 4: Robotics and home/personalisation signals
- assistive robotics context
- home sensor context where consented
- environmental routines
- personalised medicine / precision-health adjacency

Rule: Teasers must not overclaim medical or clinical meaning from weak signals. Use stated, observed, correlated, inferred, and validated evidence tiers.

## Silent failure guard

Teasers must not be allowed to look complete when it is only designed.

REAL classification requires:
- GitHub receipt exists.
- MCP Bridge execution receipt exists.
- Supabase schema proof exists.
- First teaser_delivery row exists.
- First teaser_response row exists.
- First teaser_signal_score row exists.
- Command Centre visibility proof exists.

If any of those are missing, status remains PARTIAL.

## Runtime family fit

Teasers belongs to the browser-agent runtime / Snaps family shell.

Rules:
- do not build a snowflake extension;
- keep browser runtime thin;
- route heavy orchestration through MCP Bridge and backend services;
- bind every execution to receipts;
- surface status through Command Centre;
- preserve user trust by keeping interaction lightweight and useful.

## Reality Ledger

intent: Record the Teasers ideation shift and outcome change in GitHub.
execution: Create this change note under bridge_jobs/teasers-autonomous-golden-loop/.
output: Documentation receipt for the revised Teasers direction.
status: REAL for documentation write once GitHub commit is returned. PARTIAL for runtime deployment.
evidence_required_for_runtime_REAL: bridge receipt, database proof, first delivery event, first response event, first signal score, command centre visibility.
