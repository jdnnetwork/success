#!/usr/bin/env python3
"""Produce the app's bundled Noto Sans KR faces from the upstream variable font.

The app declares a font family rather than borrowing the phone's, because the
uploaded design is drawn in Noto Sans KR and a launcher whose whole promise is
legibility should not look different on every handset.

Two problems have to be solved before that font can ship:

* **Flutter does not read a weight off a variable font.** `pubspec.yaml`'s
  `weight:` selects between *files*; the `wght` axis is only moved by
  `TextStyle.fontVariations`, which no screen sets. Registering the variable
  file once would render every 700/800/900 label at Thin — the axis default is
  100. So the axis is frozen here into static faces instead.
* **The full face is 10 MB per weight.** Noto Sans KR carries 24,964 glyphs,
  most of them hanja this app never draws. Subsetting to the ranges Korean UI
  and Korean typing actually produce takes it to roughly a fifth of that.
  Anything outside the subset — hanja, emoji — still draws, through the
  system font fallback Flutter applies for missing glyphs.

Run it only when the bundled faces need regenerating — the faces themselves are
committed, so neither a fresh clone nor CI needs any of this:

    pip install fonttools
    mkdir -p test/fonts && curl -fsSL -o test/fonts/NotoSansKR.ttf \\
      'https://raw.githubusercontent.com/google/fonts/main/ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf'
    python3 tool/build_fonts.py

Licence: SIL Open Font License 1.1 (assets/fonts/OFL.txt).
"""

import pathlib
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCE = ROOT / "test/fonts/NotoSansKR.ttf"
OUT = ROOT / "assets/fonts"

# 400 and 700 are what the app asks for; 800 and 900 fall back to 700 rather
# than earning a third 2 MB file for a difference nobody reads at a glance.
WEIGHTS = {400: "Regular", 700: "Bold"}

# What a Korean phone can put on this screen: the UI's own strings, plus names
# and messages typed by a family. Hangul is the whole point; hanja is dropped
# because Android types Hangul and the system font covers the rest.
UNICODES = ",".join(
    [
        "U+0020-007E",  # basic latin
        "U+00A0-00FF",  # latin-1 supplement
        "U+2010-2027",  # dashes, quotes, ellipsis
        "U+2030-205E",  # ‰ ′ ‹ › ※ …
        "U+20A9",  # ₩
        "U+20AC",  # €
        "U+2190-21FF",  # arrows
        "U+2460-24FF",  # circled numbers
        "U+25A0-25FF",  # geometric shapes
        "U+2600-26FF",  # misc symbols (☎ ★ ☀)
        "U+3000-303F",  # CJK punctuation
        "U+1100-11FF",  # hangul jamo
        "U+3130-318F",  # hangul compatibility jamo
        "U+A960-A97F",  # jamo extended-A
        "U+AC00-D7A3",  # hangul syllables
        "U+D7B0-D7FF",  # jamo extended-B
        "U+FF01-FF60",  # fullwidth forms
        "U+FFE0-FFE6",  # fullwidth currency
    ]
)


def build(weight: int, style: str) -> pathlib.Path:
    font = TTFont(SOURCE)
    instancer.instantiateVariableFont(font, {"wght": weight}, inplace=True)

    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.notdef_outline = True
    options.recalc_bounds = True
    options.drop_tables = []
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=subset.parse_unicodes(UNICODES))
    subsetter.subset(font)

    name = f"Noto Sans KR {style}" if style != "Regular" else "Noto Sans KR"
    font["name"].setName("Noto Sans KR", 1, 3, 1, 0x409)
    font["name"].setName(style, 2, 3, 1, 0x409)
    font["name"].setName(name, 4, 3, 1, 0x409)

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"NotoSansKR-{style}.ttf"
    font.save(path)
    font.close()
    return path


def main() -> int:
    if not SOURCE.exists():
        print(f"{SOURCE} is missing — see this file's docstring.", file=sys.stderr)
        return 1
    for weight, style in WEIGHTS.items():
        path = build(weight, style)
        size = path.stat().st_size / 1024 / 1024
        print(f"{path.relative_to(ROOT)}  {size:.1f} MB  (wght {weight})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
