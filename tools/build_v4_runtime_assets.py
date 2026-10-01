#!/usr/bin/env python3
"""Build safe runtime layers from the EnglishFarm V4 design pack."""
from pathlib import Path
import sys
from PIL import Image

ROOMS = [
    "01-home.png","02-library.png","03-post-office.png","04-workshop.png",
    "05-bank.png","06-garden-shed.png","07-pier-hut.png",
]

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: build_v4_runtime_assets.py <EnglishFarm_Pixel_V4>")
        return 2
    root = Path(sys.argv[1]).resolve()
    if not (root / "Rooms").is_dir() or not (root / "Guides").is_dir():
        raise SystemExit("Invalid V4 root: Rooms/ and Guides/ are required")
    out = Path(__file__).resolve().parents[1] / "game" / "assets" / "v4"
    rooms_out = out / "rooms"
    guides_out = out / "guides"
    rooms_out.mkdir(parents=True, exist_ok=True)
    guides_out.mkdir(parents=True, exist_ok=True)

    # Source/Remotion versions are preferred when present because they are lighter
    # while preserving the same room composition.
    source_rooms = root / "Source" / "Remotion" / "art-preview" / "public" / "v4"
    for name in ROOMS:
        src = source_rooms / name if (source_rooms / name).is_file() else root / "Rooms" / name
        im = Image.open(src).convert("RGB")
        if im.size != (1920, 1080):
            raise SystemExit(f"Unexpected room size for {src}: {im.size}")
        # y < 570 excludes the baked Momo and all fake room controls.
        layer = im.crop((0, 0, 1920, 570)).resize((1280, 380), Image.Resampling.LANCZOS)
        layer.save(rooms_out / f"{Path(name).stem}-upper.webp", "WEBP", quality=88, method=6)

    for src in sorted((root / "Guides").glob("*.png")):
        im = Image.open(src).convert("RGB")
        if src.name == "farming-illustration.png":
            im.thumbnail((1000, 563), Image.Resampling.LANCZOS)
        else:
            if im.size != (1920, 1080):
                raise SystemExit(f"Unexpected guide size for {src}: {im.size}")
            im = im.resize((1280, 720), Image.Resampling.LANCZOS)
        im.save(guides_out / f"{src.stem}.webp", "WEBP", quality=82, method=6)
    print(f"Built V4 runtime assets in {out}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
