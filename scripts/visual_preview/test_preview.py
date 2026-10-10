import json
from pathlib import Path
import tempfile
import unittest

import numpy as np
import pymupdf
from PIL import Image

from diff import Band, compare, contextual_chunks
from publish import validate_report


def pdf(path, lines, per_page=20, bold=False, figure=False):
    doc = pymupdf.open()
    for start in range(0, len(lines), per_page):
        page = doc.new_page(width=595, height=842)
        for row, text in enumerate(lines[start:start + per_page]):
            page.insert_text((95, 130 + row * 24), text, fontsize=12, fontname="hebo" if bold else "helv")
        if figure:
            page.draw_rect((120, 620, 250 if figure == 1 else 320, 680), color=(0, 0, 0))
        page.insert_text((95, 800), f"Footer {start + len(lines)}")
    doc.save(path)
    doc.close()


def framed_pdf(path, lines, per_page, proof=False):
    doc = pymupdf.open()
    for start in range(0, len(lines), per_page):
        page = doc.new_page(width=595, height=842)
        count = min(per_page, len(lines) - start)
        if proof:
            page.draw_rect((95, 110, 95.85, 132 + (count - 1) * 24),
                           color=None, fill=(.6, .6, .6))
        else:
            page.draw_rect((95, 110, 505, 140 + (count - 1) * 24),
                           color=(.8, .8, .8), fill=(.95, .95, .95), width=.425)
        for row, text in enumerate(lines[start:start + per_page]):
            page.insert_text((107, 130 + row * 24), text, fontsize=12)
    doc.save(path)
    doc.close()


class PreviewTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.a, self.b = self.root / "a.pdf", self.root / "b.pdf"

    def tearDown(self):
        self.tmp.cleanup()

    def compare(self):
        return compare(self.a, self.b, self.root / "out", "test")

    def test_identical(self):
        pdf(self.a, ["Identical content"])
        pdf(self.b, ["Identical content"])
        self.assertEqual(self.compare(), [])

    def test_insertion_with_repagination_is_one_crop(self):
        original = [f"Paragraph line number {i}." for i in range(55)]
        pdf(self.a, original)
        pdf(self.b, original[:4] + ["New explanation of the minimax theorem."] + original[4:])
        result = self.compare()
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["before_pages"], "1")
        self.assertEqual(result[0]["after_pages"], "1")

    def test_same_text_font_change(self):
        pdf(self.a, ["Matrix A and vector x"])
        pdf(self.b, ["Matrix A and vector x"], bold=True)
        self.assertEqual(len(self.compare()), 1)

    def test_theorem_and_proof_repagination_has_no_changes(self):
        lines = [f"Theorem or proof line {i}." for i in range(12)]
        for proof in (False, True):
            with self.subTest(proof=proof):
                framed_pdf(self.a, lines, 3, proof=proof)
                framed_pdf(self.b, lines, 8, proof=proof)
                self.assertEqual(self.compare(), [])

    def test_repagination_still_detects_edit_inside_frame(self):
        lines = [f"Unchanged property {i}." for i in range(12)]
        changed = lines[:5] + ["A genuinely new property."] + lines[6:]
        framed_pdf(self.a, lines, 3)
        framed_pdf(self.b, changed, 8)
        result = self.compare()
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["before_pages"], "2,3")
        self.assertEqual(result[0]["after_pages"], "1")

    def test_bibliography_capitalization_is_a_real_change(self):
        pdf(self.a, ["Journal of the Society for industrial and Applied Mathematics"])
        pdf(self.b, ["Journal of the Society for Industrial and Applied Mathematics"])
        self.assertEqual(len(self.compare()), 1)

    def test_shifted_gray_separator_is_not_content(self):
        for path, y in ((self.a, 190), (self.b, 190.4)):
            doc = pymupdf.open()
            page = doc.new_page(width=595, height=842)
            page.insert_text((95, 130), "Unchanged text", fontsize=12)
            page.draw_rect((95, y, 328, y + .425), color=None, fill=(.8, .8, .8))
            page.insert_text((95, 215), "Changelog", fontsize=12)
            doc.save(path)
            doc.close()
        self.assertEqual(self.compare(), [])

    def test_display_preserves_continuous_theorem_background(self):
        lines = [f"Theorem property {i}." for i in range(6)]
        framed_pdf(self.a, lines, 6)
        framed_pdf(self.b, lines[:3] + ["Updated property."] + lines[4:], 6)
        result = self.compare()
        self.assertEqual(len(result), 1)
        with Image.open(self.root / "out" / result[0]["file"]) as image:
            # Inside the box's left padding, three consecutive lines must share
            # an uninterrupted gray background, without white inter-line strips.
            strip = np.asarray(image)[60:, image.width // 2 + 150, :]
            gray = (strip.min(axis=1) > 230) & (strip.max(axis=1) < 250)
            longest = current = 0
            for present in gray:
                current = current + 1 if present else 0
                longest = max(longest, current)
            self.assertGreater(longest, 100)

    def test_figure_only_change(self):
        pdf(self.a, ["An unchanged caption"], figure=1)
        pdf(self.b, ["An unchanged caption"], figure=2)
        self.assertEqual(len(self.compare()), 1)

    def test_deletion(self):
        pdf(self.a, ["Before", "Remove this line", "After"])
        pdf(self.b, ["Before", "After"])
        self.assertEqual(len(self.compare()), 1)

    def test_new_document(self):
        pdf(self.b, ["A new note"])
        self.assertEqual(len(compare(None, self.b, self.root / "out", "new")), 1)

    def test_long_change_splits_at_band_boundaries(self):
        items = [Band(1, i * 100, (i + 1) * 100, Image.new("RGB", (400, 100), "white"), str(i))
                 for i in range(15)]
        group = (0, 15, 0, 15, set(range(15)), set(range(15)))
        chunks, images, height = contextual_chunks(items, items, group)
        self.assertEqual(len(chunks), 2)
        self.assertEqual(sum(len(chunk) for chunk in chunks), len(items))

    def test_long_addition_keeps_context_only_at_the_ends(self):
        pdf(self.a, ["Opening", "Closing"])
        pdf(self.b, ["Opening"] + [f"Inserted explanatory line {i}" for i in range(65)] + ["Closing"])
        result = self.compare()
        self.assertGreater(len(result), 1)
        self.assertEqual(result[0]["before_pages"], "1")
        self.assertEqual(result[-1]["before_pages"], "1")
        self.assertTrue(all(region["before_pages"] == "none" for region in result[1:-1]))
        self.assertEqual(result[-1]["part"], result[-1]["parts"])
        with Image.open(self.root / "out" / result[-1]["file"]) as image:
            # The last old-side pane retains the following context.
            colors = image.crop((20, 60, image.width // 2 - 30, image.height - 20)).getcolors(100000)
            self.assertGreater(len(colors), 2)
        if len(result) > 2:
            with Image.open(self.root / "out" / result[0]["file"]) as first:
                with Image.open(self.root / "out" / result[1]["file"]) as middle:
                    self.assertLess(middle.width, first.width * .6)

    def test_publisher_rejects_path_and_stale_report(self):
        report = {"version": 1, "pr": 3, "base": "a", "head": "b", "notes": [
            {"source": "content/eah.typ", "errors": [], "regions": [
                {"file": "../secret.png", "before_pages": "1", "after_pages": "1"}]}]}
        (self.root / "report.json").write_text(json.dumps(report))
        with self.assertRaises(ValueError):
            validate_report(self.root, 3, "a", "b")
        report["notes"][0]["regions"][0]["file"] = "safe.png"
        (self.root / "report.json").write_text(json.dumps(report))
        Image.new("RGB", (50, 50)).save(self.root / "safe.png")
        self.assertEqual(len(validate_report(self.root, 3, "a", "b")[1]), 1)
        with self.assertRaises(ValueError):
            validate_report(self.root, 3, "a", "new-head")


if __name__ == "__main__":
    unittest.main()
