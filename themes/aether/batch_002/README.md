# CW_THEME_FACTORY_AETHER_v1

Bundle: `theme-factory-aether-2026-04-29-002`
Cluster: **AETHER** (gradient engine)
Status: **REAL**

## Contents

| Path | Type | Count |
|---|---|---|
| `scripts/generate_themes.py` | gradient generator (linear + radial) | 1 |
| `scripts/pack_themes.py` | mv3 manifest packager | 1 |
| `scripts/naming_engine.py` | SEO long-tail engine (1,750 names) | 1 |
| `images/aether_*.png` | 1920×1080 gradient backgrounds | 25 |
| `manifests/manifest_*.json` | Chrome mv3 theme manifests | 25 |
| `catalog.json` | batch index | 1 |
| `name_grid.json` | 1,750 SEO names | 1 |

## Cluster: AETHER

5 colour pairs × 5 directions = 25 variants:

**Pairs**
- `violet_cobalt`: purple → blue (88,28,135 → 29,78,216)
- `rose_amber`: pink → orange (190,24,93 → 245,158,11)
- `ocean_cyan`: navy → cyan (15,23,42 → 6,182,212)
- `synthwave`: neon magenta → cyan (236,72,153 → 34,211,238)
- `plasma_void`: red → purple (127,29,29 → 76,29,149)

**Directions**: vertical, horizontal, diag_down, diag_up, radial

**Modifier rotation**: Aurora / Mist / Glow / Drift / Bloom

## Reproduce

```bash
pip install Pillow
OUTPUT_DIR=images python3 scripts/generate_themes.py
THEME_DIR=. python3 scripts/pack_themes.py
OUT=name_grid.json python3 scripts/naming_engine.py
```

Deterministic. Idempotent. Re-runnable.

## Naming pattern

`{Aether|Gradient|Aurora|Nebula|Prism} {Modifier} {Pair} {Theme|Chrome|Aesthetic|Smooth|HD}`

1,750 unique long-tail captures.

## Sibling clusters

- OBSIDIAN — dark dominance (batch_001) — REAL
- AETHER — gradient engine (this batch_002) — REAL
- NEURAL — mesh / network visuals (batch_003) — queued
- PRIME — executive neutral (batch_004) — queued
- VOID — distraction-free minimal (batch_005) — queued
