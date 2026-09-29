#!/usr/bin/env python3
"""Remove the Kuhn TFDP diagram's white matte, preserving its white nodes.

Requires Pillow. The original PNG is retained; no drawing or resampling occurs.
The result must reproduce the original pixel-for-pixel when placed over white.
"""
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'content/figures/learning_efg/kuhn_tfdp.png'
OUTPUT = SOURCE.with_name('kuhn_tfdp-transparent.png')

# Inclusive interior bounds of the four crossed nodes and twelve leaf nodes.
WHITE_INTERIORS = (
    (474, 46, 492, 65), (79, 267, 97, 285),
    (387, 267, 406, 285), (696, 267, 714, 285),
    (257, 271, 266, 281), (565, 271, 575, 281), (874, 271, 883, 281),
    (26, 382, 35, 391), (334, 382, 343, 391), (642, 382, 652, 391),
    (103, 492, 112, 501), (180, 492, 189, 501),
    (411, 492, 420, 501), (488, 492, 497, 501),
    (720, 492, 729, 501), (797, 492, 806, 501),
)


def main():
    source = Image.open(SOURCE).convert('RGBA')
    assert source.size == (908, 522), 'Recheck the node masks if the source changes.'
    red, green, blue, alpha = source.split()
    assert alpha.getextrema() == (255, 255)
    assert ImageChops.difference(red, green).getbbox() is None
    assert ImageChops.difference(red, blue).getbbox() is None

    # Exact inverse of compositing black ink over white; retains antialiasing.
    result = Image.new('RGBA', source.size, (0, 0, 0, 0))
    result.putalpha(ImageChops.invert(red))
    mask = Image.new('L', source.size, 0)
    draw = ImageDraw.Draw(mask)
    for bounds in WHITE_INTERIORS:
        draw.rectangle(bounds, fill=255)
    result.paste(source, mask=mask)

    white = Image.new('RGBA', source.size, 'white')
    composite = Image.alpha_composite(white, result).convert('RGB')
    assert ImageChops.difference(composite, source.convert('RGB')).getbbox() is None
    for bounds in WHITE_INTERIORS:
        x0, y0, x1, y1 = bounds
        assert result.getchannel('A').crop((x0, y0, x1 + 1, y1 + 1)).getextrema() == (255, 255)
    assert result.getpixel((0, 0))[3] == 0

    result.save(OUTPUT)
    print(f'Transparent figure: {OUTPUT.relative_to(ROOT)} (exact white-composite match)')


if __name__ == '__main__':
    main()
