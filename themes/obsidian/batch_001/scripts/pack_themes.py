"""
CW_THEME_FACTORY_OBSIDIAN_v1 - Packager
Creates one manifest.json per generated theme image.
Chrome theme manifest_version: 3 compliant.
"""
import json
import os
import re

THEME_DIR = os.environ.get("THEME_DIR", "themes/obsidian/batch_001")
IMG_DIR = os.path.join(THEME_DIR, "images")
MANIFEST_DIR = os.path.join(THEME_DIR, "manifests")
os.makedirs(MANIFEST_DIR, exist_ok=True)

# Map base/accent names back to RGB for theme colour blocks
BASE_RGB = {
    "true_black": [0, 0, 0],
    "graphite": [18, 18, 18],
    "charcoal": [28, 28, 28],
    "slate": [40, 40, 40],
    "void": [10, 10, 10],
}
ACCENT_RGB = {
    "blue": [0, 122, 255],
    "purple": [88, 86, 214],
    "red": [255, 45, 85],
    "green": [52, 199, 89],
    "orange": [255, 149, 0],
}

# Naming engine - SEO long-tail capture
NAME_PATTERN = "Obsidian {modifier} {accent_pretty}"
MODIFIERS = ["Pro", "Edge", "Ultra", "Minimal", "AMOLED"]


def pretty(name):
    return name.replace("_", " ").title()


def main():
    files = sorted(f for f in os.listdir(IMG_DIR) if f.endswith(".png"))
    catalog = []
    for i, fn in enumerate(files):
        m = re.match(r"obsidian_(\d+)_([a-z_]+?)_([a-z]+)\.png$", fn)
        if not m:
            continue
        idx, base, accent = m.group(1), m.group(2), m.group(3)
        base_rgb = BASE_RGB.get(base, [0, 0, 0])
        accent_rgb = ACCENT_RGB.get(accent, [255, 255, 255])
        modifier = MODIFIERS[int(idx) % len(MODIFIERS)]
        theme_name = NAME_PATTERN.format(
            modifier=modifier, accent_pretty=accent.capitalize()
        )
        # Append disambiguator for store uniqueness
        full_name = f"{theme_name} - {pretty(base)}"

        manifest = {
            "manifest_version": 3,
            "name": full_name,
            "version": "1.0.0",
            "description": f"Obsidian dark theme. {pretty(base)} base with {accent} accent. AMOLED-friendly, minimal, focus-grade.",
            "theme": {
                "images": {
                    "theme_frame": f"images/{fn}",
                    "theme_toolbar": f"images/{fn}",
                },
                "colors": {
                    "frame": base_rgb,
                    "toolbar": base_rgb,
                    "tab_text": [255, 255, 255],
                    "tab_background_text": [180, 180, 180],
                    "bookmark_text": [220, 220, 220],
                    "ntp_background": base_rgb,
                    "ntp_text": [255, 255, 255],
                    "button_background": accent_rgb,
                },
                "tints": {
                    "buttons": [-1, -1, 0.05]
                },
                "properties": {
                    "ntp_background_alignment": "bottom"
                }
            }
        }
        out = os.path.join(MANIFEST_DIR, f"manifest_{idx}.json")
        with open(out, "w") as fp:
            json.dump(manifest, fp, indent=2)
        catalog.append({"idx": int(idx), "manifest": f"manifest_{idx}.json",
                        "name": full_name, "image": fn})

    cat_path = os.path.join(THEME_DIR, "catalog.json")
    with open(cat_path, "w") as fp:
        json.dump({"batch_id": "obsidian_001", "count": len(catalog),
                   "themes": catalog}, fp, indent=2)
    print(f"Packaged {len(catalog)} manifests -> {MANIFEST_DIR}")
    print(f"Catalog -> {cat_path}")
    return catalog


if __name__ == "__main__":
    main()
