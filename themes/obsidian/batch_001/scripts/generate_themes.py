"""
CW_THEME_FACTORY_OBSIDIAN_v1 - Generator
Generates 25 Chrome theme background images (5 bases x 5 accents).
Idempotent - re-runnable, deterministic output.
"""
import os
from PIL import Image, ImageDraw

OUTPUT_DIR = os.environ.get("OUTPUT_DIR", "themes/obsidian/batch_001/images")
os.makedirs(OUTPUT_DIR, exist_ok=True)

BASE_COLORS = [
    (0, 0, 0),        # true_black
    (18, 18, 18),     # graphite
    (28, 28, 28),     # charcoal
    (40, 40, 40),     # slate
    (10, 10, 10),     # void
]
BASE_NAMES = ["true_black", "graphite", "charcoal", "slate", "void"]

ACCENTS = [
    (0, 122, 255),    # blue
    (88, 86, 214),    # purple
    (255, 45, 85),    # red
    (52, 199, 89),    # green
    (255, 149, 0),    # orange
]
ACCENT_NAMES = ["blue", "purple", "red", "green", "orange"]


def generate(idx, base, accent, base_name, accent_name):
    img = Image.new("RGB", (1920, 1080), base)
    draw = ImageDraw.Draw(img)
    # subtle vertical line grid - low cognitive load aesthetic
    for x in range(0, 1920, 40):
        draw.line((x, 0, x, 1080), fill=accent, width=1)
    filename = f"obsidian_{idx:02d}_{base_name}_{accent_name}.png"
    path = os.path.join(OUTPUT_DIR, filename)
    img.save(path, optimize=True)
    return filename


def main():
    count = 0
    catalog = []
    for bi, (b, bn) in enumerate(zip(BASE_COLORS, BASE_NAMES)):
        for ai, (a, an) in enumerate(zip(ACCENTS, ACCENT_NAMES)):
            fn = generate(count, b, a, bn, an)
            catalog.append({"idx": count, "file": fn, "base": bn, "accent": an,
                            "base_rgb": list(b), "accent_rgb": list(a)})
            count += 1
    print(f"Generated {count} themes -> {OUTPUT_DIR}")
    return catalog


if __name__ == "__main__":
    main()
