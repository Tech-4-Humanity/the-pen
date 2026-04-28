"""
CW_THEME_FACTORY_OBSIDIAN_v1 - Naming Engine
Generates SEO long-tail name combinations for Chrome Web Store discovery.
Pattern: BASE + MODIFIER + ACCENT + SUFFIX
"""
import json
import os

BASE = ["Obsidian", "Dark", "AMOLED", "Void", "Eclipse"]
MODIFIER = ["Pro", "Edge", "Ultra", "Minimal", "Focus"]
ACCENT = ["Blue", "Purple", "Red", "Green", "Orange", "Cyan", "Magenta"]
SUFFIX = ["Tabs", "Theme", "OLED", "Minimal", "Quiet"]


def generate_names():
    names = []
    for b in BASE:
        for m in MODIFIER:
            for a in ACCENT:
                for s in SUFFIX:
                    names.append(f"{b} {m} {a} {s}")
    return names


def main():
    out = os.environ.get("OUT", "themes/obsidian/batch_001/name_grid.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    names = generate_names()
    with open(out, "w") as fp:
        json.dump({"count": len(names), "patterns": {
            "base": BASE, "modifier": MODIFIER,
            "accent": ACCENT, "suffix": SUFFIX
        }, "names": names}, fp, indent=2)
    print(f"Generated {len(names)} SEO names -> {out}")


if __name__ == "__main__":
    main()
