"""Exercise paths and removed compiler modes at the style boundary."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from check_site import Page

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required')
class NoteStyleTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which('pdftotext'), 'Poppler is required for citation text')
    def test_pdf_citations_preserve_explicit_supplements(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'references.bib').write_text(
                '@book{probe, author={Example, Alice}, title={Citation probe}, year={2024}}\n')
            source = folder / 'probe.typ'
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta/gabri_notes.typ"))}: *\n'
                '#show: gabri_notes.with(lec_num: 15, title: [Citation probe])\n'
                'Plain #citep(<probe>).\n\n'
                'Definition #citep(<probe>, [Definition 1]).\n\n'
                'Section #citep(<probe>, [Section 2.1]).\n\n'
                '#lec_bibliography("references.bib")\n')
            output = source.with_suffix('.pdf')
            result = subprocess.run(
                ['typst', 'compile', '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            text = subprocess.check_output(['pdftotext', str(output), '-'], text=True)
            text = ' '.join(text.split())
            plain = re.search(r'Plain \[([^\]]+)\]\.', text)
            self.assertIsNotNone(plain, text)
            label = plain[1]
            # Exact matching catches dropped locators and unwanted `p.` prefixes
            # on supplements that already name their own section/definition.
            self.assertIn(f'Definition [{label}, Definition 1].', text)
            self.assertIn(f'Section [{label}, Section 2.1].', text)

    @unittest.skipUnless(shutil.which('pdftoppm'), 'Poppler is required for image bounds')
    def test_pdf_figures_honor_requested_widths_and_fit_their_column(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'diagram.svg').write_text(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100pt" height="50pt" '
                'viewBox="0 0 100 50"><rect width="100" height="50" fill="blue"/></svg>')
            cases = [('340pt', 114), ('150%', 114), ('60%', 68.4),
                     ('40% + 10pt', 55.6), ('50pt', 50), ('100%', 114), ('auto', 100)]
            widths = ', '.join(f'({value}, {expected}pt)' for value, expected in cases)
            source = folder / 'probe.typ'
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta/gabri_notes.typ"))}: *\n'
                '#set page(width: 240pt, height: auto, margin: 0pt)\n'
                '#set block(spacing: 0pt)\n'
                '#for side in (left, right) {\n'
                f'  for (width, expected) in ({widths}) {{\n'
                '    let panel = wrapped-figure(side: side, text-width: 50%)[Text][\n'
                '      #image("diagram.svg", width: width, alt: "Blue diagram")\n'
                '    ]\n'
                '    context {\n'
                '      let size = measure(panel, width: 240pt)\n'
                '      assert(calc.abs(size.width - 240pt) < .1pt)\n'
                '      assert(calc.abs(size.height - expected / 2) < .1pt,\n'
                '        message: "Image width " + repr(width) + " must resolve to " + repr(expected))\n'
                '    }\n'
                '    block(height: 60pt, panel)\n'
                '  }\n'
                '}\n')
            result = subprocess.run(
                ['typst', 'compile', '--root', ROOT.anchor, str(source),
                 str(source.with_suffix('.pdf'))], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            # Check the artwork's size and centering, not only layout boxes:
            # a frame can be correctly sized while its artwork overflows.
            ppm = subprocess.check_output(
                ['pdftoppm', '-r', '72', '-singlefile', str(source.with_suffix('.pdf'))])
            header = re.match(rb'P6\s+(\d+)\s+(\d+)\s+255\s', ppm)
            self.assertIsNotNone(header)
            width, height = map(int, header.groups())
            self.assertEqual((width, height), (240, 2 * len(cases) * 60))
            pixels = ppm[header.end():]
            self.assertEqual(len(pixels), width * height * 3)
            for side, column_start in enumerate((0, 126)):
                for index, (value, expected) in enumerate(cases):
                    with self.subTest(side=side, width=value):
                        y = (side * len(cases) + index) * 60 + 10
                        row = pixels[y * width * 3:(y + 1) * width * 3]
                        blue_x = [x for x in range(width) if row[x * 3 + 2] > 200
                                  and row[x * 3] < 80 and row[x * 3 + 1] < 80]
                        self.assertTrue(blue_x)
                        self.assertAlmostEqual(len(blue_x), expected, delta=1)
                        self.assertAlmostEqual((min(blue_x) + max(blue_x) + 1) / 2,
                                               column_start + 57, delta=1)
                        self.assertGreaterEqual(min(blue_x), column_start)
                        self.assertLess(max(blue_x), column_start + 114)

    def test_html_resizes_relative_images_without_reloading_from_the_style_folder(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'diagram.svg').write_text(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="50">'
                '<rect width="100" height="50" fill="blue"/></svg>')
            source = folder / 'probe.typ'
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta/gabri_notes_html.typ"))}: *\n'
                '#show: gabri_notes.with(lec_num: 1, title: [Image probe])\n'
                '#image("diagram.svg", width: 100%, alt: "Full width")\n'
                '#image("diagram.svg", width: 60%, alt: "Partial width")\n')
            output = source.with_suffix('.html')
            result = subprocess.run(
                ['typst', 'compile', '--root', ROOT.anchor, '--features', 'html',
                 '--format', 'html', str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            html = output.read_text()
            page = Page(html)
            self.assertEqual(len(page.image_sources), 2)
            self.assertEqual(page.image_rendering_issues, [])
            dimensions = [list(map(float, value.split())) for value in
                          re.findall(r'<svg\b[^>]*\bviewBox="([^"]+)"', html)]
            self.assertEqual(dimensions, [[0, 0, 585, 292.5], [0, 0, 351, 175.5]])
            self.assertIn('aria-label="Full width"', html)
            self.assertIn('aria-label="Partial width"', html)

    def test_styles_reject_removed_compiler_inputs(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'probe.typ'
            for style in ('gabri_notes', 'gabri_notes_html'):
                source.write_text(
                    f'#import {json.dumps(str(ROOT / "content/meta" / (style + ".typ")))}: *\n')
                for option in ('web', 'html', 'combined'):
                    with self.subTest(style=style, option=option):
                        result = subprocess.run(
                            ['typst', 'compile', '--root', ROOT.anchor,
                             '--input', f'{option}=false', str(source),
                             str(source.with_suffix('.pdf'))],
                            capture_output=True, text=True)
                        self.assertNotEqual(result.returncode, 0)
                        self.assertIn('inputs are unsupported', result.stderr)

    @unittest.skipUnless(shutil.which('pdftoppm'), 'Poppler is required for image bounds')
    def test_html_image_artwork_stays_inside_its_frame_under_alignment(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            (folder / 'diagram.svg').write_text(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="50">'
                '<rect width="100" height="50" fill="blue"/></svg>')
            source = folder / 'probe.typ'
            source.write_text(
                f'#import {json.dumps(str(ROOT / "content/meta/gabri_notes_html.typ"))}: *\n'
                '#show: gabri_notes.with(lec_num: 16, title: [Image alignment probe])\n'
                '#for alignment in (auto, left, center, right) {\n'
                '  for width in (100pt, 60%, 100%, 40% + 10pt, auto) {\n'
                '    let diagram = image("diagram.svg", width: width)\n'
                '    if alignment == auto { figure(diagram) }\n'
                '    else { align(alignment, diagram) }\n'
                '  }\n'
                '}\n')
            output = source.with_suffix('.html')
            result = subprocess.run(
                ['typst', 'compile', '--root', ROOT.anchor, '--features', 'html',
                 '--format', 'html', str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            html = output.read_text()
            frames = re.findall(r'<svg\b.*?</svg>', html, re.S)
            self.assertEqual(len(frames), 20)
            # Rasterize the exported SVGs: checking only their viewBoxes misses
            # artwork translated outside an otherwise correctly sized frame.
            for index, svg in enumerate(frames):
                (folder / f'frame-{index}.svg').write_text(svg)
            source.write_text(
                '#set page(width: 200pt, height: auto, margin: 0pt)\n'
                '#set block(spacing: 0pt)\n'
                + '\n'.join(f'#block(image("frame-{index}.svg", width: 200pt))'
                            for index in range(len(frames))))
            result = subprocess.run(
                ['typst', 'compile', str(source), str(source.with_suffix('.pdf'))],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            ppm = subprocess.check_output(
                ['pdftoppm', '-r', '72', '-singlefile', str(source.with_suffix('.pdf'))])
            header = re.match(rb'P6\s+(\d+)\s+(\d+)\s+255\s', ppm)
            self.assertIsNotNone(header)
            width, height = map(int, header.groups())
            self.assertEqual((width, height), (200, 2000))
            pixels = ppm[header.end():]
            for index in range(len(frames)):
                with self.subTest(frame=index):
                    row = pixels[(index * 100 + 50) * width * 3:
                                 (index * 100 + 51) * width * 3]
                    blue_x = [x for x in range(width) if row[x * 3 + 2] > 200
                              and row[x * 3] < 80 and row[x * 3 + 1] < 80]
                    self.assertEqual(blue_x, list(range(width)),
                                     'The artwork must fill its SVG frame without an alignment offset.')
            # Relative lengths need CSS syntax, not Typst's `60% + 0pt` repr.
            images = re.findall(r'<span\b[^>]*class="lecture-image"[^>]*>', html)
            widths = [match[1] if (match := re.search(r'style="([^"]*)"', image))
                      else '' for image in images]
            self.assertEqual(len(widths), 20)
            for index in range(0, len(widths), 5):
                self.assertEqual(widths[index:index + 3],
                                 ['', 'width: calc(60% + 0em);', 'width: calc(100% + 0em);'])
                mixed = re.fullmatch(r'width: calc\(40% \+ ([\d.]+)em\);', widths[index + 3])
                self.assertIsNotNone(mixed)
                self.assertAlmostEqual(float(mixed[1]) * 9.5, 10)
                self.assertEqual(widths[index + 4], '')


if __name__ == '__main__':
    unittest.main()
