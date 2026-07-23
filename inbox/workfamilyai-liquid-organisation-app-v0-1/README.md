# WorkFamilyAI Liquid Organisation Engine v0.1

Static, dependency-free implementation of the interactive and predictive layer defined in the Organisational Evolution Canon and WorkFamilyAI 10x10x10 runtime.

## Run
Open `index.html` directly or serve the folder from S3, CloudFront, GitHub Pages or any static web server.

## Implemented
- ten-variable interactive assessment
- ten pressure scenarios
- scenario intensity control
- transparent projected-variable movement
- AI sweet-spot detection
- AI blackspot detection
- recommended organisational adaptations
- prediction readiness, risk and confidence
- downloadable JSON prediction receipt
- constitutional no-human-elimination rule

## Next binding
Replace the in-browser example scores with role-level records from the 1,000-record workbook export. The adapter contract is:

```json
{
  "role_id": "string",
  "pillar": "string",
  "function": "string",
  "role": "string",
  "scores": {
    "purpose_alignment": 0,
    "pressure_load": 0,
    "human_capacity": 0,
    "ai_fit": 0,
    "authority_clarity": 0,
    "artefact_integrity": 0,
    "flow_tempo": 0,
    "dependency_resilience": 0,
    "learning_memory": 0,
    "trust_flourishing": 0
  },
  "evidence": [],
  "dependencies": [],
  "artefacts": []
}
```

## Prediction discipline
The current coefficients are explicit hypotheses, not validated causal claims. Production calibration must compare predicted and observed outcomes while preserving the original receipt and model version.
