# Organisational Evolution Canon — Dev Intake Bundle v1.0

Status: **DEPLOY-READY INTAKE**

This bundle formalises the relationship between the Organisational Evolution Theory, Framework and Canon and includes a self-contained static explainer suitable for S3, CloudFront, GitHub Pages or any static host.

## Canonical hierarchy

1. **Organisational Evolution Theory** — explains why organisations evolve.
2. **Organisational Evolution Framework** — explains how that evolution unfolds across observable stages.
3. **Organisational Evolution Canon** — contains the complete body of philosophy, models, evidence, implementation doctrine and applications.

## Evolutionary engine

`Purpose → Pressure → Adaptation → Selection → Capability → Learning → Memory → Evolution → Flourishing`

The surrounding ecosystem includes people, AI, organisations, communities, governments and nature.

## Included assets

- `index.html` — responsive one-page explainer and centrepiece diagram.
- `assets/styles.css` — self-contained visual system.
- `assets/app.js` — minimal progressive enhancement.
- `docs/canonical-spec.md` — lossless conceptual specification.
- `docs/dev-intake.md` — implementation and acceptance handover.
- `manifest.json` — machine-readable bundle manifest.

## Local run

```bash
cd inbox/organisational-evolution-canon-v1
python3 -m http.server 8080
```

Open `http://localhost:8080`.

## Static deployment

```bash
aws s3 sync . s3://YOUR_BUCKET/organisational-evolution-canon/v1/ \
  --exclude '.DS_Store' \
  --cache-control 'public,max-age=300'
```

For production, apply long-lived caching to versioned assets and short caching to `index.html`.

## Evidence status

- Conceptual model: compiled from the supplied thread and source text.
- Runtime deployment: not claimed.
- External empirical validation: required before numerical impact claims are published.
- Precise multipliers were intentionally removed from the canonical public model unless supported by evidence.
