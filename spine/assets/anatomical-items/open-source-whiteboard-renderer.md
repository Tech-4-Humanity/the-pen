# Anatomical Asset: Open-Source Whiteboard / Doodle Renderer

## Status
PARTIAL

## Result
Registered a reusable anatomical asset for an open-source whiteboard/doodle animation capability that can be reused across projects, brands, research assets, education explainers, social campaigns, dossiers, product pages, and automated video generation workflows.

## Asset Identity
- Asset name: Open-Source Whiteboard Renderer
- Asset type: anatomical reusable item
- Spine category: visual-generation / explainer-video / research-translation
- Canonical implementation preference: Remotion + SVG stroke animation
- Secondary/reference option: OpenDoodler for desktop/manual whiteboard-style editing inspiration
- Alternative specialist option: Manim for education, maths, systems, and formal explainer animation

## Intended Reuse
This asset is available across:
- AI Sweet Spots
- Drug Resilience Atlas
- GC-BAT
- MyNeuralSignal
- Outcome Ready
- Reading Buddy
- WorkFamilyAI
- Augmented Humanity Coach
- Tech4Humanity
- Holo-Org / Command Centre
- portfolio dossiers and brand pages
- research asset register outputs
- automated LinkedIn/social/video pipelines

## Standard Pipeline
```text
Research / script / claim / asset register item
  -> storyboard JSON
  -> scene plan
  -> SVG asset generation
  -> Remotion render template
  -> MP4 / GIF / PNG frames / LinkedIn cutdown
  -> receipt + evidence record
```

## Reuse Contract
Every project may call this anatomical item when it needs to convert structured content into a whiteboard, doodle, explainer, teaching, walkthrough, or presentation video.

Minimum reusable interfaces:
- `script_text`
- `brand_id`
- `project_id`
- `audience`
- `duration_seconds`
- `scene_count`
- `visual_style`
- `voiceover_required`
- `output_format`
- `evidence_links`

## Spine Binding
This item should be indexed as a cross-project anatomical asset, not a one-off tool. It belongs in the shared asset spine and can be referenced by any brand or delivery workflow requiring visual explanation, education, training, research translation, or automated video output.

## Evidence
- api_response: GitHub create_file commit receipt for this registry record.
- repository: TML-4PM/the-pen
- path: spine/assets/anatomical-items/open-source-whiteboard-renderer.md

## Gaps
- Runtime renderer not yet deployed.
- No Remotion template committed yet.
- No storyboard JSON schema committed yet.
- No Command Centre asset registry row confirmed.
- No Bridge receipt yet for downstream runtime execution.

## Next Action
1. Add storyboard JSON schema.
2. Add Remotion whiteboard starter template.
3. Add asset registry seed row.
4. Attach to Command Centre asset inventory.
5. Route to Bridge for runtime receipt and implementation tracking.

## Elevation
This moves the whiteboard/doodle concept from tool shopping into reusable production anatomy. The important asset is not a Doodly clone; it is a reusable rendering capability that turns research, claims, diagrams, curriculum, dossiers, and product concepts into consistent video assets across the whole portfolio.

## Pressure Flags
- manual_dependency: OpenDoodler is not enough by itself because it is not API-first.
- execution_gap: renderer still needs implementation.
- reuse_priority: high, because it can convert many existing written assets into video.

## Score
0.71

## Ledger
- task_id: anatomical-asset-open-source-whiteboard-renderer
- intent: make open-source whiteboard/doodle renderer available as reusable anatomical asset across projects and brands
- execution: GitHub spine registry file created
- output: reusable anatomical asset record
- status: PARTIAL
- evidence: GitHub commit receipt from create_file response
- score: 0.71
