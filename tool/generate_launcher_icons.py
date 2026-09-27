"""Generate launcher assets from the approved 1024px opaque Luma master.

Run from any directory with Python and Pillow installed.
The source medical symbol used inside the app is intentionally unchanged.
"""

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NAVY = (8, 26, 51)
MASTER = ROOT / "assets/branding/luma_icon.png"
master = Image.open(MASTER).convert("RGB")
assert master.size == (1024, 1024)
assert master.getpixel((0, 0)) == NAVY
generated = {}


def save_png(path, size, inset=False):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    if inset:
        # Keep the whole wordmark inside circular and squircle launcher masks.
        result = Image.new("RGB", (size, size), NAVY)
        side = round(size * 0.70)
        result.paste(master.resize((side, side), Image.Resampling.LANCZOS),
                     ((size - side) // 2, (size - side) // 2))
    else:
        result = master.resize((size, size), Image.Resampling.LANCZOS)
    result.save(path, optimize=True)
    generated[path] = size


for platform in ("ios", "macos"):
    folder = ROOT / platform / "Runner/Assets.xcassets/AppIcon.appiconset"
    manifest = json.loads((folder / "Contents.json").read_text())
    for item in manifest["images"]:
        size = round(float(item["size"].split("x")[0])
                     * float(item["scale"].rstrip("x")))
        save_png(folder / item["filename"], size)

for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96,
                      "xxhdpi": 144, "xxxhdpi": 192}.items():
    save_png(f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)

# Adaptive-icon layer is full-size navy with safely inset gold artwork.
save_png("android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png",
         432, inset=True)

for size in (192, 512):
    save_png(f"web/icons/Icon-{size}.png", size)
    save_png(f"web/icons/Icon-maskable-{size}.png", size, inset=True)
save_png("web/favicon.png", 32)

master.save(ROOT / "windows/runner/resources/app_icon.ico",
            sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])
save_png("assets/branding/luma_google_play_icon_512.png", 512)

for path, size in generated.items():
    result = Image.open(path)
    assert result.size == (size, size), path
    assert result.mode == "RGB", path
    assert result.getpixel((0, 0)) == NAVY, path
print(f"Validated {len(generated)} PNG launcher/store assets and Windows ICO.")
