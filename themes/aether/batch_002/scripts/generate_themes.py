"""
CW_THEME_FACTORY_AETHER_v1 - Gradient Generator
5 colour pairs x 5 directions = 25 variants.
Linear + radial gradients, 1920x1080. Deterministic, idempotent.
"""
import os
from PIL import Image, ImageDraw

OUTPUT_DIR = os.environ.get("OUTPUT_DIR", "themes/aether/batch_002/images")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 5 cluster palettes - each is (name, start_rgb, end_rgb)
PAIRS = [
    ("violet_cobalt",  (88, 28, 135),   (29, 78, 216)),    # purple -> blue
    ("rose_amber",     (190, 24, 93),   (245, 158, 11)),   # pink -> orange
    ("ocean_cyan",     (15, 23, 42),    (6, 182, 212)),    # navy -> cyan
    ("synthwave",      (236, 72, 153),  (34, 211, 238)),   # neon magenta -> cyan
    ("plasma_void",    (127, 29, 29),   (76, 29, 149)),    # red -> purple
]

# 5 directions - linear vertical/horizontal/diag, radial centered, radial offset
DIRECTIONS = ["vertical", "horizontal", "diag_down", "diag_up", "radial"]


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def render(idx, pair_name, c1, c2, direction):
    W, H = 1920, 1080
    img = Image.new("RGB", (W, H), c1)
    px = img.load()

    if direction == "vertical":
        for y in range(H):
            t = y / (H - 1)
            row = lerp(c1, c2, t)
            for x in range(W):
                px[x, y] = row
    elif direction == "horizontal":
        for x in range(W):
            t = x / (W - 1)
            col = lerp(c1, c2, t)
            for y in range(H):
                px[x, y] = col
    elif direction == "diag_down":
        # top-left -> bottom-right
        denom = (W - 1) + (H - 1)
        for y in range(H):
            for x in range(W):
                t = (x + y) / denom
                px[x, y] = lerp(c1, c2, t)
    elif direction == "diag_up":
        # bottom-left -> top-right
        denom = (W - 1) + (H - 1)
        for y in range(H):
            for x in range(W):
                t = (x + (H - 1 - y)) / denom
                px[x, y] = lerp(c1, c2, t)
    elif direction == "radial":
        # centre radial, c1 at centre fading to c2 at corner
        cx, cy = W / 2, H / 2
        rmax = ((cx ** 2 + cy ** 2) ** 0.5)
        for y in range(H):
            for x in range(W):
                d = (((x - cx) ** 2) + ((y - cy) ** 2)) ** 0.5
                t = min(1.0, d / rmax)
                px[x, y] = lerp(c1, c2, t)

    fn = f"aether_{idx:02d}_{pair_name}_{direction}.png"
    img.save(os.path.join(OUTPUT_DIR, fn), optimize=True)
    return fn


def main():
    count = 0
    catalog = []
    for pair_name, c1, c2 in PAIRS:
        for direction in DIRECTIONS:
            fn = render(count, pair_name, c1, c2, direction)
            catalog.append({
                "idx": count, "file": fn,
                "pair": pair_name, "direction": direction,
                "start_rgb": list(c1), "end_rgb": list(c2),
            })
            count += 1
    print(f"Generated {count} gradient themes -> {OUTPUT_DIR}")
    return catalog


if __name__ == "__main__":
    main()
