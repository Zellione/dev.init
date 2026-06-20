#!/usr/bin/env python3
"""Generate bright accent colors from wallust palette for waybar.

Reads colors-waybar.css, extracts the 16 palette colors, converts to HSL,
increases lightness to create readable pastel accents, and appends them
to the same colors-waybar.css file.
"""

import colorsys
import re
import sys
from pathlib import Path

WAYBAR_DIR = Path.home() / ".config" / "waybar"
COLORS_CSS = WAYBAR_DIR / "wallust" / "colors-waybar.css"

SWAYNC_DIR = Path.home() / ".config" / "swaync"
SWAYNC_COLORS_CSS = SWAYNC_DIR / "wallust" / "colors-wallust.css"

ACCENT_START = "/* wallust-accents-start */"
ACCENT_END = "/* wallust-accents-end */"

# Each accent gets: (source color index, target hue or None to use source hue,
# target saturation, target lightness)
# Spreading across the color wheel ensures visual diversity
ACCENT_MAP = {
    "accent-pink":     (4,  340, 65, 78),   # warm pink
    "accent-green":    (2,  130, 55, 75),   # fresh green
    "accent-orange":   (12, 25,  70, 78),   # warm orange
    "accent-purple":   (5,  275, 60, 80),   # soft purple
    "accent-blue":     (11, 215, 60, 80),   # sky blue
    "accent-cyan":     (6,  185, 55, 78),   # teal/cyan
    "accent-red":      (3,  5,   65, 78),   # soft red
    "accent-yellow":   (14, 45,  65, 80),   # golden yellow
}


def hex_to_rgb(hex_str):
    """Convert '#RRGGBB' to (r, g, b) with values 0-255."""
    hex_str = hex_str.lstrip("#")
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))


def rgb_to_hsl(r, g, b):
    """Convert RGB (0-255) to HSL (h: 0-360, s: 0-100, l: 0-100)."""
    h, l, s = colorsys.rgb_to_hls(r/255, g/255, b/255)
    return h * 360, s * 100, l * 100


def hsl_to_hex(h, s, l):
    """Convert HSL (h: 0-360, s: 0-100, l: 0-100) to '#RRGGBB'."""
    r, g, b = colorsys.hls_to_rgb(h / 360, l / 100, s / 100)
    return f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}"


def make_accent(source_hex, target_hue, target_sat, target_light):
    """Create a bright pastel accent from a source color.

    Uses the target hue for diversity, but blends with source hue
    if the source is colorful (saturation > 20%).
    """
    r, g, b = hex_to_rgb(source_hex)
    h, s, l = rgb_to_hsl(r, g, b)

    # If source has meaningful color, blend hues (70% target, 30% source)
    if s > 20 and target_hue is not None:
        # Circular hue blending
        diff = (target_hue - h + 180) % 360 - 180
        h = (h + diff * 0.3) % 360

    return hsl_to_hex(h, target_sat, target_light)


def parse_colors(css_path):
    """Parse @define-color declarations from a CSS file."""
    colors = {}
    pattern = re.compile(r"@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6})\s*;")
    with open(css_path) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                colors[m.group(1)] = m.group(2)
    return colors


def generate_accent_css(colors):
    """Generate CSS @define-color lines for bright accents."""
    lines = [f"{ACCENT_START}"]
    lines.append("/* bright accents derived from wallust palette */")

    for accent_name, (color_idx, hue, sat, light) in ACCENT_MAP.items():
        source_key = f"color{color_idx}"
        source_hex = colors.get(source_key, "#888888")
        accent_hex = make_accent(source_hex, hue, sat, light)
        lines.append(f"@define-color {accent_name} {accent_hex};")

    lines.append(f"{ACCENT_END}")
    return "\n".join(lines)


def update_colors_css(colors_path, accent_block):
    """Append accent colors to colors-waybar.css, replacing any existing accent section."""
    with open(colors_path) as f:
        content = f.read()

    pattern = re.compile(
        re.escape(ACCENT_START) + r".*?" + re.escape(ACCENT_END),
        re.DOTALL
    )

    if pattern.search(content):
        new_content = pattern.sub(accent_block, content)
    else:
        new_content = content.rstrip() + "\n\n" + accent_block + "\n"

    with open(colors_path, "w") as f:
        f.write(new_content)


def main():
    if not COLORS_CSS.exists():
        print(f"ERROR: {COLORS_CSS} not found", file=sys.stderr)
        sys.exit(1)

    colors = parse_colors(COLORS_CSS)
    accent_block = generate_accent_css(colors)

    update_colors_css(COLORS_CSS, accent_block)
    print(f"Waybar accents regenerated in {COLORS_CSS}")

    if SWAYNC_COLORS_CSS.parent.exists():
        update_colors_css(SWAYNC_COLORS_CSS, accent_block)
        print(f"Swaync accents regenerated in {SWAYNC_COLORS_CSS}")


if __name__ == "__main__":
    main()
