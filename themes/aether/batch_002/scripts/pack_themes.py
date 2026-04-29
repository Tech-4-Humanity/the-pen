"""
CW_THEME_FACTORY_AETHER_v1 - Packager
Generates Chrome mv3 manifests for each AETHER gradient theme.
"""
import json
import os
import re

THEME_DIR = os.environ.get("THEME_DIR", "themes/aether/batch_002")
IMG_DIR = os.path.join(THEME_DIR, "images")
MANIFEST_DIR = os.path.join(THEME_DIR, "manifests")
os.makedirs(MANIFEST_DIR, exist_ok=True)

# Pretty pair names + dominant tint for theme color blocks
PAIR_LABEL = {
    "violet_cobalt": "Violet Cobalt",
    "rose_amber":    "Rose Amber",
    "ocean_cyan":    "Ocean Cyan",
    "synthwave":     "Synthwave",
    "plasma_void":   "Plasma Void",
}
PAIR_FRAME = {
    "violet_cobalt": [40, 20, 80],
    "rose_amber":    [60, 20, 30],
    "ocean_cyan":    [10, 18, 35],
    "synthwave":     [25, 10, 50],
    "plasma_void":   [40, 10, 30],
}
DIRECTION_LABEL = {
    "vertical": "Vertical",
    "horizontal": "Horizontal",
    "diag_down": "Diagonal",
    "diag_up": "Reverse Diagonal",
    "radial": "Radial",
}
MODIFIERS = ["Aurora", "Mist", "Glow", "Drift", "Bloom"]


def main():
    files = sorted(f for f in os.listdir(IMG_DIR) if f.endswith(".png"))
    catalog = []
    for fn in files:
        m = re.match(r"aether_(\d+)_([a-z_]+?)_(vertical|horizontal|diag_down|diag_up|radial)\.png$", fn)
        if not m:
            continue
        idx_s, pair, direction = m.group(1), m.group(2), m.group(3)
        idx = int(idx_s)
        modifier = MODIFIERS[idx % len(MODIFIERS)]
        full_name = f"Aether {modifier} - {PAIR_LABEL.get(pair, pair)} ({DIRECTION_LABEL.get(direction, direction)})"
        frame_rgb = PAIR_FRAME.get(pair, [20, 20, 30])

        manifest = {
            "manifest_version": 3,
            "name": full_name,
            "version": "1.0.0",
            "description": (
                f"Aether gradient theme. {PAIR_LABEL.get(pair, pair)} colour pair, "
                f"{DIRECTION_LABEL.get(direction, direction).lower()} direction. "
                "Smooth, immersive, focus-friendly aesthetic."
            ),
            "theme": {
                "images": {
                    "theme_frame": f"images/{fn}",
                    "theme_toolbar": f"images/{fn}",
                    "theme_ntp_background": f"images/{fn}",
                },
                "colors": {
                    "frame": frame_rgb,
                    "toolbar": frame_rgb,
                    "tab_text": [255, 255, 255],
                    "tab_background_text": [200, 200, 220],
                    "bookmark_text": [230, 230, 245],
                    "ntp_background": frame_rgb,
                    "ntp_text": [255, 255, 255],
                    "button_background": [255, 255, 255],
                },
                "tints": {
                    "buttons": [-1, -1, 0.05]
                },
                "properties": {
                    "ntp_background_alignment": "center",
                    "ntp_background_repeat": "no-repeat"
                }
            }
        }
        out = os.path.join(MANIFEST_DIR, f"manifest_{idx_s}.json")
        with open(out, "w") as fp:
            json.dump(manifest, fp, indent=2)
        catalog.append({"idx": idx, "manifest": f"manifest_{idx_s}.json",
                        "name": full_name, "image": fn,
                        "pair": pair, "direction": direction})

    cat_path = os.path.join(THEME_DIR, "catalog.json")
    with open(cat_path, "w") as fp:
        json.dump({"batch_id": "aether_002", "count": len(catalog),
                   "themes": catalog}, fp, indent=2)
    print(f"Packaged {len(catalog)} manifests -> {MANIFEST_DIR}")
    return catalog


if __name__ == "__main__":
    main()
