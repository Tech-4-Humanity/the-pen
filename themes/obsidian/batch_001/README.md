# CW_THEME_FACTORY_OBSIDIAN_v1

Bundle: `theme-factory-obsidian-2026-04-29-001`
Status: **REAL** (artefacts) / **PENDING** (GitHub push blocked by bridge regression)

## Contents

| Path | Type | Count |
|---|---|---|
| `scripts/generate_themes.py` | generator | 1 |
| `scripts/pack_themes.py` | packager | 1 |
| `scripts/naming_engine.py` | SEO long-tail engine | 1 |
| `themes/obsidian/batch_001/images/*.png` | Chrome theme backgrounds (1920x1080) | 25 |
| `themes/obsidian/batch_001/manifests/*.json` | manifest_version 3, Chrome-compliant | 25 |
| `themes/obsidian/batch_001/catalog.json` | batch index | 1 |
| `themes/obsidian/batch_001/name_grid.json` | 875 SEO names | 1 |
| `jobs/themes_batch_001.json` | bridge job envelope | 1 |
| `receipts/themes_batch_001.receipt.json` | runtime receipt | 1 |

## Reproduce

```bash
pip install Pillow
cd theme-factory
OUTPUT_DIR=themes/obsidian/batch_001/images python3 scripts/generate_themes.py
THEME_DIR=themes/obsidian/batch_001 python3 scripts/pack_themes.py
OUT=themes/obsidian/batch_001/name_grid.json python3 scripts/naming_engine.py
```

Output is deterministic. Re-runnable. Idempotent.

## Cluster: OBSIDIAN

- 5 bases: true_black, graphite, charcoal, slate, void
- 5 accents: blue, purple, red, green, orange
- 25 combinations (5 x 5)
- Modifier rotation: Pro / Edge / Ultra / Minimal / AMOLED

## Naming pattern

`{Obsidian|Dark|AMOLED|Void|Eclipse} {Pro|Edge|Ultra|Minimal|Focus} {Accent} {Tabs|Theme|OLED|Minimal|Quiet}`

875 unique long-tail captures generated in `name_grid.json`.

## Next clusters (not in this batch)

- AETHER (gradient engine)
- NEURAL (mesh / network visuals)
- PRIME (executive neutral)
- VOID (distraction-free)
