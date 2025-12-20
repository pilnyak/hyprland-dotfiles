#!/usr/bin/env python3
"""
Sort wallpapers into theme folders based on dominant color palette.
Uses LAB color space for perceptually accurate color matching.
"""

import os
import sys
import shutil
from pathlib import Path
from colorthief import ColorThief
from colormath.color_objects import sRGBColor, LabColor
from colormath.color_conversions import convert_color
import numpy as np

# Fix for numpy 2.0+ compatibility with colormath
if not hasattr(np, 'asscalar'):
    np.asscalar = lambda x: x.item()

from colormath.color_diff import delta_e_cie2000

# Reference palettes - key colors for each theme
# Format: (R, G, B) tuples
PALETTES = {
    "Nord": [
        (0x2e, 0x34, 0x40),  # polar night
        (0x3b, 0x42, 0x52),
        (0x43, 0x4c, 0x5e),
        (0x4c, 0x56, 0x6a),
        (0xd8, 0xde, 0xe9),  # snow storm
        (0xe5, 0xe9, 0xf0),
        (0xec, 0xef, 0xf4),
        (0x8f, 0xbc, 0xbb),  # frost
        (0x88, 0xc0, 0xd0),
        (0x81, 0xa1, 0xc1),
        (0x5e, 0x81, 0xac),
    ],
    "Gruvbox": [
        (0x28, 0x28, 0x28),  # bg
        (0x3c, 0x38, 0x36),
        (0x50, 0x49, 0x45),
        (0xeb, 0xdb, 0xb2),  # fg
        (0xfb, 0xf1, 0xc7),
        (0xcc, 0x24, 0x1d),  # red
        (0x98, 0x97, 0x1a),  # green
        (0xd7, 0x99, 0x21),  # yellow
        (0xd6, 0x5d, 0x0e),  # orange
        (0x45, 0x85, 0x88),  # aqua
        (0xb1, 0x62, 0x86),  # purple
    ],
    "Catppuccin": [
        (0x1e, 0x1e, 0x2e),  # base
        (0x31, 0x32, 0x44),  # surface0
        (0x45, 0x47, 0x5a),  # surface1
        (0xcd, 0xd6, 0xf4),  # text
        (0xf5, 0xc2, 0xe7),  # pink
        (0xcb, 0xa6, 0xf7),  # mauve
        (0xf3, 0x8b, 0xa8),  # red
        (0xfa, 0xb3, 0x87),  # peach
        (0xa6, 0xe3, 0xa1),  # green
        (0x89, 0xdc, 0xeb),  # sky
        (0x89, 0xb4, 0xfa),  # blue
    ],
    "Everforest": [
        (0x2d, 0x35, 0x3b),  # bg
        (0x34, 0x3f, 0x44),
        (0x3d, 0x48, 0x4d),
        (0xd3, 0xc6, 0xaa),  # fg
        (0xe6, 0x7e, 0x80),  # red
        (0xa7, 0xc0, 0x80),  # green
        (0xdb, 0xbc, 0x7f),  # yellow
        (0x7f, 0xbf, 0xb2),  # aqua
        (0x83, 0xc0, 0x92),  # teal
        (0xd6, 0x99, 0xb6),  # purple
    ],
    "Black": [
        # Neutral grays - fallback for images that don't match other palettes
        (0x0a, 0x0a, 0x0a),
        (0x1a, 0x1a, 0x1a),
        (0x2a, 0x2a, 0x2a),
        (0x3a, 0x3a, 0x3a),
        (0x4a, 0x4a, 0x4a),
        (0x6a, 0x6a, 0x6a),
        (0x8a, 0x8a, 0x8a),
        (0xaa, 0xaa, 0xaa),
        (0xca, 0xca, 0xca),
        (0xea, 0xea, 0xea),
    ],
}

def rgb_to_lab(rgb: tuple) -> LabColor:
    """Convert RGB tuple to LAB color."""
    r, g, b = [x / 255.0 for x in rgb]
    srgb = sRGBColor(r, g, b)
    return convert_color(srgb, LabColor)

def get_palette_distance(image_colors: list, palette_name: str) -> float:
    """
    Calculate average minimum distance from image colors to palette colors.
    Lower = better match.
    """
    palette = PALETTES[palette_name]
    palette_lab = [rgb_to_lab(c) for c in palette]
    image_lab = [rgb_to_lab(c) for c in image_colors]

    total_distance = 0
    for img_color in image_lab:
        # Find minimum distance to any palette color
        min_dist = min(delta_e_cie2000(img_color, pal_color) for pal_color in palette_lab)
        total_distance += min_dist

    return total_distance / len(image_colors)

def classify_image(image_path: str, color_count: int = 6) -> tuple[str, dict]:
    """
    Classify an image into the best matching palette.
    Returns (palette_name, distances_dict).
    """
    try:
        ct = ColorThief(image_path)
        colors = ct.get_palette(color_count=color_count, quality=5)
    except Exception as e:
        return None, {"error": str(e)}

    distances = {}
    for palette_name in PALETTES:
        distances[palette_name] = get_palette_distance(colors, palette_name)

    best_match = min(distances, key=distances.get)
    return best_match, distances

def sort_wallpapers(
    source_dir: str,
    dest_base: str,
    dry_run: bool = True,
    move: bool = False
):
    """
    Sort wallpapers from source_dir into palette-based subdirs under dest_base.
    """
    source = Path(source_dir)
    dest = Path(dest_base)

    # Create destination folders
    for palette_name in PALETTES:
        (dest / palette_name).mkdir(parents=True, exist_ok=True)

    # Supported image extensions
    extensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}

    images = [f for f in source.iterdir() if f.suffix.lower() in extensions]
    total = len(images)

    results = {name: [] for name in PALETTES}
    errors = []

    for i, img_path in enumerate(images, 1):
        print(f"\r[{i}/{total}] Processing {img_path.name[:40]}...", end="", flush=True)

        palette, distances = classify_image(str(img_path))

        if palette is None:
            errors.append((img_path.name, distances.get("error", "Unknown error")))
            continue

        results[palette].append(img_path.name)

        if not dry_run:
            dest_path = dest / palette / img_path.name
            # Skip if source and destination are the same
            if img_path.resolve() == dest_path.resolve():
                continue
            if move:
                shutil.move(str(img_path), str(dest_path))
            else:
                shutil.copy2(str(img_path), str(dest_path))

    print("\n")

    # Print summary
    print("=" * 50)
    print("CLASSIFICATION RESULTS")
    print("=" * 50)
    for palette_name, files in results.items():
        print(f"\n{palette_name}: {len(files)} images")
        if len(files) <= 5:
            for f in files:
                print(f"  - {f}")
        else:
            for f in files[:3]:
                print(f"  - {f}")
            print(f"  ... and {len(files) - 3} more")

    if errors:
        print(f"\nErrors: {len(errors)}")
        for name, err in errors[:5]:
            print(f"  - {name}: {err}")

    if dry_run:
        print("\n[DRY RUN - no files were moved/copied]")
        print("Run with --execute to actually sort files")
        print("Run with --execute --move to move instead of copy")

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Sort wallpapers by color palette")
    parser.add_argument("source", nargs="?", default=os.path.expanduser("~/Pictures/Wallpapers/Black"),
                        help="Source directory with unsorted wallpapers")
    parser.add_argument("dest", nargs="?", default=os.path.expanduser("~/Pictures/Wallpapers"),
                        help="Destination base directory (palettes as subdirs)")
    parser.add_argument("--execute", action="store_true",
                        help="Actually copy files (default is dry run)")
    parser.add_argument("--move", action="store_true",
                        help="Move files instead of copying (requires --execute)")

    args = parser.parse_args()

    if args.move and not args.execute:
        print("Error: --move requires --execute")
        sys.exit(1)

    print(f"Source: {args.source}")
    print(f"Destination: {args.dest}")
    print(f"Mode: {'MOVE' if args.move else 'COPY' if args.execute else 'DRY RUN'}")
    print()

    sort_wallpapers(
        args.source,
        args.dest,
        dry_run=not args.execute,
        move=args.move
    )

if __name__ == "__main__":
    main()
