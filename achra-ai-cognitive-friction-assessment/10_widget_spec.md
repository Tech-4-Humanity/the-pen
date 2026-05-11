# ACHRA Widget Spec

## Component: ACHRAAssessment

### Stack
- React + Tailwind (or plain HTML/CSS/JS)
- Supabase JS client (anon key for session/response writes, service_role for RPC)
- 5-part wizard with progress bar and per-item autosave
- Score computed server-side via `public.achra_compute_scores(session_id)`
- Local JS fallback scoring if Supabase unavailable

### Flow
1. Landing → POST achra.sessions → get session_id
2. Parts 1–5 → batch POST achra.responses after each part
3. Submit → POST /rpc/achra_compute_scores
4. Results → archetype card + 4 score tiles + intervention list
5. Optional: export PDF report

### REST API
```
POST /rest/v1/achra/sessions
POST /rest/v1/achra/responses          (batch array)
POST /rest/v1/rpc/achra_compute_scores {"p_session_id": "<uuid>"}
GET  /rest/v1/achra/scores?session_id=eq.<id>
GET  /rest/v1/achra/interventions?session_id=eq.<id>&order=priority.asc
```

### Archetypes
| Code | Label | Primary signal |
|------|-------|----------------|
| AI_EXPLORER | AI Explorer | High curiosity + velocity |
| VERIFICATION_ANALYST | Verification Analyst | High trust caution |
| COGNITIVE_AMPLIFIER | Cognitive Amplifier | Low friction + high benefit |
| OVERLOADED_OPERATOR | Overloaded Operator | High friction + high fatigue |
| ASSISTED_EXECUTOR | Assisted Executor | High exec function need |
| HUMAN_CENTRIC_STRATEGIST | Human-Centric Strategist | High human pref retention |

### Deployment targets
- Inline Claude artifact (current — interactive HTML widget)
- Standalone Vercel: project `achra-assessment`
- Embed: AI Sweet Spots product page
- Enterprise: white-label with org_id scoping
