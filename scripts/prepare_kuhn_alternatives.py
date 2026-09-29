#!/usr/bin/env python3
"""Remove the L7.9 diagram's white matte without changing any drawing pixels.

Requires Pillow. Retains the original PNG and the white node interiors.
Compositing the result over white must exactly reproduce the original image.
"""
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'content/figures/efg_intro/kuhn_alternatives.png'
OUTPUT = ROOT / 'content/figures/efg_intro/kuhn_alternatives-transparent.png'

# Inclusive interior bounds of observation nodes and terminal nodes, including
# their legend symbols. The surrounding page and large legend remain transparent.
WHITE_INTERIORS = (
    (392, 49, 411, 68), (57, 243, 76, 262),
    (319, 243, 337, 262), (580, 243, 598, 262),
    (1182, 34, 1201, 52), (782, 440, 799, 457),
    (208, 247, 219, 258), (12, 343, 23, 355),
    (77, 440, 88, 452), (142, 440, 154, 452),
    (469, 247, 481, 258), (273, 343, 284, 355),
    (338, 440, 350, 452), (404, 440, 415, 452),
    (730, 247, 742, 258), (534, 343, 546, 355),
    (600, 440, 611, 452), (665, 440, 677, 452),
    (1039, 231, 1050, 243), (908, 328, 919, 340),
    (973, 328, 985, 340), (1235, 231, 1246, 243),
    (1104, 328, 1115, 340), (1169, 328, 1181, 340),
    (1431, 231, 1442, 243), (1300, 328, 1312, 340),
    (1365, 328, 1377, 340), (1161, 393, 1172, 404),
)


def main():
    source = Image.open(SOURCE).convert('RGBA')
    assert source.size == (1468, 496), 'Recheck node masks if the source changes.'
    red, green, blue, alpha = source.split()
    assert alpha.getextrema() == (255, 255)
    assert ImageChops.difference(red, green).getbbox() is None
    assert ImageChops.difference(red, blue).getbbox() is None

    # Exact inverse of black ink antialiased against a white matte.
    result = Image.new('RGBA', source.size, (0, 0, 0, 0))
    result.putalpha(ImageChops.invert(red))
    mask = Image.new('L', source.size, 0)
    draw = ImageDraw.Draw(mask)
    for bounds in WHITE_INTERIORS:
        draw.rectangle(bounds, fill=255)
    result.paste(source, mask=mask)

    composite = Image.alpha_composite(Image.new('RGBA', source.size, 'white'), result)
    assert ImageChops.difference(composite.convert('RGB'), source.convert('RGB')).getbbox() is None
    for x0, y0, x1, y1 in WHITE_INTERIORS:
        assert result.getchannel('A').crop((x0, y0, x1 + 1, y1 + 1)).getextrema() == (255, 255)
    assert result.getpixel((0, 0))[3] == 0
    result.save(OUTPUT)
    print(f'Transparent figure: {OUTPUT.relative_to(ROOT)} (exact white-composite match)')


if __name__ == '__main__':
    main()
