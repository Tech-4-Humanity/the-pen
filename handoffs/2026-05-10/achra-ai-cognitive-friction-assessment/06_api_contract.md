# ACHRA API Contract

## POST /api/achra/submit

Accepts completed assessment payloads.

Request body:

{
  "participant_id": "uuid",
  "assessment_version": "1.0",
  "responses": [
    {
      "question_key": "Q1",
      "value": 5
    }
  ]
}

Response body:

{
  "assessment_id": "uuid",
  "archetype": "Verification Analyst",
  "scores": {
    "ai_cognitive_friction_score": 48,
    "human_agent_symbiosis_index": 74
  },
  "actions": [
    "guided verification workflow",
    "advanced summarisation"
  ]
}

## POST /api/achra/report

Generates a report payload for PDF, HTML or dashboard rendering.

## GET /api/achra/heatmap

Returns aggregated enterprise readiness and friction scores.
