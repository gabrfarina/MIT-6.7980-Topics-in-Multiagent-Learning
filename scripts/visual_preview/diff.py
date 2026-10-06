"""Compare rendered content bands across pages, then crop local before/after context.

The course footer is excluded. Text anchors align unchanged material even when an
insertion moves it onto another page. Raster comparison also catches math, style,
and figure changes. This is a review aid, not a semantic equivalence checker.
"""
from __future__ import annotations

from dataclasses import dataclass
from difflib import SequenceMatcher
from itertools import zip_longest
from pathlib import Path
import re

import numpy as np
import pymupdf
from PIL import Image, ImageDraw, ImageFilter, ImageFont


@dataclass
class Band:
    page: int
    top: int
    bottom: int
    image: Image.Image
    key: str
    display: Image.Image | None = None


def content_ink(page, clip, image):
    """Ignore course box/proof rules when finding gaps, not in the rendered crop.

    A vertical rule otherwise joins an entire theorem/proof into one band. Its
    band key then changes whenever a page break splits the box, even though all
    its lines are unchanged. Ignore only the neutral, thin template decorations;
    keep figure strokes and text (including punctuation) available for matching.
    """
    ink = np.min(np.asarray(image), axis=2) < 225

    def erase(rect):
        x0 = max(0, int((rect.x0 - clip.x0) * 2) - 2)
        y0 = max(0, int((rect.y0 - clip.y0) * 2) - 2)
        x1 = min(image.width, int((rect.x1 - clip.x0) * 2) + 3)
        y1 = min(image.height, int((rect.y1 - clip.y0) * 2) + 3)
        if x1 > x0 and y1 > y0:
            ink[y0:y1, x0:x1] = False

    for drawing in page.get_drawings():
        rect = drawing["rect"]
        color = drawing["color"] or drawing["fill"]
        if not color or max(color) - min(color) > .02 or not .45 < min(color) < .99:
            continue
        if (drawing["type"] == "f" and rect.width < 1.5 and rect.height > 12
                and .58 < min(color) < .62 and rect.x0 < page.rect.width * .17):
            erase(rect)  # Proof sidebar.
        elif (drawing["type"] == "f" and rect.height < 1.5
              and rect.width > page.rect.width * .25 and .78 < min(color) < .82
              and rect.x0 < page.rect.width * .17):
            erase(rect)  # Gray separator above the changelog, not a figure.
        elif ("s" in drawing["type"] and drawing["width"] < 1
              and rect.width > page.rect.width * .55 and rect.height > 8):
            # Thin gray outline of a full-width theorem box, including corners.
            for edge in (pymupdf.Rect(rect.x0, rect.y0, rect.x1, rect.y0 + 2),
                         pymupdf.Rect(rect.x0, rect.y1 - 2, rect.x1, rect.y1),
                         pymupdf.Rect(rect.x0, rect.y0, rect.x0 + 2, rect.y1),
                         pymupdf.Rect(rect.x1 - 2, rect.y0, rect.x1, rect.y1)):
                erase(edge)
    return ink


def bands(path: Path) -> list[Band]:
    result = []
    with pymupdf.open(path) as document:
        for p, page in enumerate(document):
            # The course template puts running footers below this body region.
            clip = pymupdf.Rect(32, 90, page.rect.width - 32, page.rect.height - 96)
            pix = page.get_pixmap(matrix=pymupdf.Matrix(2, 2), clip=clip, alpha=False)
            image = Image.frombytes("RGB", (pix.width, pix.height), pix.samples)
            ink = content_ink(page, clip, image)
            rows = np.any(ink, axis=1)
            # Keep every text line (including detached accents) in a single band.
            lines = []
            for block in page.get_text("dict")["blocks"]:
                for line in block.get("lines", []):
                    x0, y0, x1, y1 = line["bbox"]
                    if y0 < clip.y0 or y1 > clip.y1:
                        continue
                    start = max(0, int((y0 - clip.y0) * 2) - 1)
                    stop = min(image.height, int((y1 - clip.y0) * 2) + 2)
                    rows[start:stop] = True
                    text = "".join(s["text"] for s in line["spans"])
                    lines.append((start, stop, x0, text))
            intervals = []
            start = None
            for y, present in enumerate(np.r_[rows, False]):
                if present and start is None:
                    start = y
                elif not present and start is not None:
                    if intervals and start - intervals[-1][1] <= 2:
                        intervals[-1] = (intervals[-1][0], y)
                    else:
                        intervals.append((start, y))
                    start = None
            for index, (top, bottom) in enumerate(intervals):
                text = " ".join(t for a, b, x, t in sorted(lines) if a < bottom and b > top)
                text = re.sub(r"\s+", " ", text).strip()
                crop = image.crop((0, max(0, top - 2), image.width, min(image.height, bottom + 2)))
                # Matching uses tightly cropped lines, but display uses the
                # original gaps/backgrounds. Share each small gap between its
                # neighboring lines instead of inserting white strips into boxes.
                previous = intervals[index - 1][1] if index else 0
                following = intervals[index + 1][0] if index + 1 < len(intervals) else image.height
                display_top = top - min(12, (top - previous) // 2)
                display_bottom = bottom + min(12, (following - bottom + 1) // 2)
                display = image.crop((0, display_top, image.width, display_bottom))
                # Identical generic figure keys pair figures in sequence; pixels
                # determine whether a paired graphic changed.
                result.append(Band(p + 1, top, bottom, crop, text or "<graphic>", display))
    return result


def appearance_equal(a: Image.Image, b: Image.Image) -> bool:
    if abs(a.height - b.height) > 3 or a.width != b.width:
        return False
    size = (a.width, max(a.height, b.height))
    masks = []
    for image in (a, b):
        canvas = Image.new("RGB", size, "white")
        canvas.paste(image, (0, (size[1] - image.height) // 2))
        masks.append(np.min(np.asarray(canvas), axis=2) < 200)
    x, y = masks
    area = max(x.sum(), y.sum(), 1)
    if abs(int(x.sum()) - int(y.sum())) / area > .10:
        return False
    # Tolerate subpixel rasterization when a line moves vertically.
    dilated = [np.asarray(Image.fromarray(m).filter(ImageFilter.MaxFilter(3))) for m in masks]
    mismatch = (x & ~dilated[1]) | (y & ~dilated[0])
    if mismatch.sum() / area > .018:
        return False
    # Detect color-only changes too, without treating antialiasing as a change.
    colors = []
    for image in (a, b):
        rgb = np.asarray(image)
        dark = np.min(rgb, axis=2) < 100
        colors.append(np.median(rgb[dark], axis=0) if dark.any() else np.array([0, 0, 0]))
    return bool(np.max(np.abs(colors[0] - colors[1])) < 25)


def change_groups(before: list[Band], after: list[Band], context: int = 1):
    matcher = SequenceMatcher(None, [b.key for b in before], [b.key for b in after], autojunk=False)
    changes = []
    for tag, a, b, c, d in matcher.get_opcodes():
        if tag == "equal":
            for i, j in zip(range(a, b), range(c, d)):
                if not appearance_equal(before[i].image, after[j].image):
                    changes.append((i, i + 1, j, j + 1))
        else:
            changes.append((a, b, c, d))
    groups = []
    for a, b, c, d in changes:
        group = [max(0, a - context), min(len(before), b + context),
                 max(0, c - context), min(len(after), d + context),
                 set(range(a, b)), set(range(c, d))]
        if groups and group[0] <= groups[-1][1] and group[2] <= groups[-1][3]:
            old = groups[-1]
            old[1] = max(old[1], group[1])
            old[3] = max(old[3], group[3])
            old[4].update(group[4])
            old[5].update(group[5])
        else:
            groups.append(group)
    return groups


def empty_panel(width, height, side):
    canvas = Image.new("RGB", (width, height), "#f6f8fa")
    draw = ImageDraw.Draw(canvas)
    title = "No corresponding content"
    subtitle = f"This change has no {side.lower()} content."
    font = ImageFont.load_default(size=25)
    small = ImageFont.load_default(size=21)
    y = max(15, height // 2 - 32)
    draw.text((width // 2, y), title, anchor="mt", font=font, fill="#57606a")
    draw.text((width // 2, y + 36), subtitle, anchor="mt", font=small, fill="#57606a")
    return canvas


def context_crop(image, edge, limit=180):
    """Keep nearby context, cutting only at a clear horizontal gap if possible."""
    if image.height <= limit:
        return image
    ink = np.any(np.min(np.asarray(image), axis=2) < 150, axis=1)
    if edge == "tail":
        cut = image.height - limit
        candidates = [y for y in range(max(0, cut - 35), min(image.height, cut + 35)) if not ink[y]]
        cut = min(candidates, key=lambda y: abs(y - cut)) if candidates else cut
        return image.crop((0, cut, image.width, image.height))
    cut = limit
    candidates = [y for y in range(max(0, cut - 35), min(image.height, cut + 35)) if not ink[y]]
    cut = min(candidates, key=lambda y: abs(y - cut)) if candidates else cut
    return image.crop((0, 0, image.width, cut))


def contextual_chunks(before, after, group):
    """Align anchors, keeping context only at the ends of a continuous change."""
    a, b, c, d, left_changes, right_changes = group
    matcher = SequenceMatcher(None, [x.key for x in before[a:b]], [x.key for x in after[c:d]], autojunk=False)
    rows = []
    for tag, i, j, k, l in matcher.get_opcodes():
        rows.extend(zip_longest(range(a + i, a + j), range(c + k, c + l)))
    first, last = 0, len(rows)
    def changed(row):
        return row[0] in left_changes or row[1] in right_changes
    while first < last and not changed(rows[first]):
        first += 1
    while last > first and not changed(rows[last - 1]):
        last -= 1
    prefix = [(i, j, "tail") for i, j in rows[max(0, first - 1):first]]
    suffix = [(i, j, "head") for i, j in rows[last:last + 1]]

    def images(row):
        i, j, context = row
        left = (before[i].display or before[i].image) if i is not None else None
        right = (after[j].display or after[j].image) if j is not None else None
        if context:
            left = context_crop(left, context) if left else None
            right = context_crop(right, context) if right else None
        return left, right

    def height(row):
        return max(im.height for im in images(row) if im is not None)

    budget = 1200 - sum(height(row) for row in prefix + suffix)
    chunks, current, used = [], [], 0
    for i, j in rows[first:last]:
        row = (i, j, None)
        size = height(row)
        if current and used + size > budget:
            chunks.append(current)
            current, used = [], 0
        current.append(row)
        used += size
    if current:
        chunks.append(current)
    if chunks:
        chunks[0] = prefix + chunks[0]
        chunks[-1] = chunks[-1] + suffix
    return chunks, images, height


def compare(before_pdf: Path | None, after_pdf: Path | None, out: Path, name: str):
    before = bands(before_pdf) if before_pdf else []
    after = bands(after_pdf) if after_pdf else []
    regions = []
    out.mkdir(parents=True, exist_ok=True)
    for n, group in enumerate(change_groups(before, after), 1):
        chunks, row_images, row_height = contextual_chunks(before, after, group)
        count = len(chunks)
        width = (before or after)[0].image.width + 16
        for index, rows in enumerate(chunks):
            h = max(100, sum(row_height(row) for row in rows) + 12)
            left, right = [Image.new("RGB", (width, h), "white") for _ in range(2)]
            y = 6
            for row in rows:
                for im, target, changed, color, item in zip(row_images(row), (left, right), group[4:6],
                                                            ("#cf222e", "#1a7f37"), row[:2]):
                    if im is not None:
                        target.paste(im, (10, y))
                        if item in changed and row[2] is None:
                            ImageDraw.Draw(target).rectangle((1, y, 5, y + im.height), fill=color)
                y += row_height(row)
            lp = ",".join(map(str, sorted({before[i].page for i, j, _ in rows if i is not None}))) or "none"
            rp = ",".join(map(str, sorted({after[j].page for i, j, _ in rows if j is not None}))) or "none"
            if lp == "none":
                left = empty_panel(width, h, "Before")
            if rp == "none":
                right = empty_panel(width, h, "After")
            continuation = count > 2 and 0 < index < count - 1
            single_side = continuation and (lp == "none" or rp == "none")
            result = Image.new("RGB", (width + 16 if single_side else left.width + right.width + 24, h + 60), "#eaeef2")
            draw = ImageDraw.Draw(result)
            font = ImageFont.load_default(size=22)
            suffix = f"  |  part {index + 1}/{count}" if count > 1 else ""
            left_label = f"page {lp}" if lp != "none" else "no corresponding content"
            right_label = f"page {rp}" if rp != "none" else "no corresponding content"
            if single_side:
                added = lp == "none"
                label = f"ADDED  |  page {rp}" if added else f"DELETED  |  page {lp}"
                draw.text((12, 16), label + suffix, font=font, fill="#116329" if added else "#9a1e2b")
                result.paste(right if added else left, (8, 54))
            else:
                draw.text((12, 16), f"BEFORE  |  {left_label}{suffix}", font=font, fill="#9a1e2b")
                draw.text((left.width + 24, 16), f"AFTER  |  {right_label}{suffix}", font=font, fill="#116329")
                for x, im in ((8, left), (left.width + 16, right)):
                    result.paste(im, (x, 54))
            filename = f"{name}-{n:02d}-{index + 1:02d}.png"
            result.save(out / filename)
            regions.append({"file": filename, "before_pages": lp, "after_pages": rp,
                            "part": index + 1, "parts": count})
    return regions
