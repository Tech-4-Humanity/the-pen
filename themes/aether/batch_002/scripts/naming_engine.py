"""
CW_THEME_FACTORY_AETHER_v1 - Naming Engine
SEO long-tail names for gradient/aesthetic searches on Chrome Web Store.
"""
import json
import os

BASE = ["Aether", "Gradient", "Aurora", "Nebula", "Prism"]
MODIFIER = ["Aurora", "Mist", "Glow", "Drift", "Bloom", "Halo", "Veil"]
PAIR = ["Violet Cobalt", "Rose Amber", "Ocean Cyan", "Synthwave", "Plasma Void",
        "Pastel", "Galaxy", "Sunset", "Twilight", "Neon"]
SUFFIX = ["Theme", "Chrome", "Aesthetic", "Smooth", "HD"]


def generate_names():
    names = []
    for b in BASE:
        for m in MODIFIER:
            for p in PAIR:
                for s in SUFFIX:
                    names.append(f"{b} {m} {p} {s}")
    return names


def main():
    out = os.environ.get("OUT", "themes/aether/batch_002/name_grid.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    names = generate_names()
    with open(out, "w") as fp:
        json.dump({"count": len(names),
                   "patterns": {"base": BASE, "modifier": MODIFIER,
                                "pair": PAIR, "suffix": SUFFIX},
                   "names": names}, fp, indent=2)
    print(f"Generated {len(names)} SEO names -> {out}")


if __name__ == "__main__":
    main()
