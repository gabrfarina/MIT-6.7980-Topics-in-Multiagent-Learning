"""Compile table probes and inspect their resolved cell and column styling."""
from html.parser import HTMLParser
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / 'content/meta/gabri_notes_html.typ'
SIDES = ('top', 'right', 'bottom', 'left')


def styles(attrs):
    return {key.strip(): value.strip() for key, value in
            (part.split(':', 1) for part in attrs.get('style', '').split(';') if ':' in part)}


class TablePage(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.cells = []
        self.tables = []
        self.colgroups = []
        self.feed(html)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if tag in ('td', 'th'):
            self.cells.append((tag, attrs, styles(attrs)))
        elif tag == 'table':
            self.tables.append(attrs)
        elif tag == 'colgroup':
            self.colgroups.append([])
        elif tag == 'col':
            self.colgroups[-1].append(styles(attrs)['width'])


@unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required for table probes')
class HtmlTableTests(unittest.TestCase):
    def compile(self, body, *, page=False):
        with tempfile.TemporaryDirectory(prefix='notes-table-test-') as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.html')
            source.write_text(f'#import {json.dumps(str(HELPER))}: *\n'
                              '#show: gabri_notes.with(lec_num: 1, title: [Tables])\n' + body)
            result = subprocess.run(
                ['typst', 'compile', '--features', 'html', '--format', 'html',
                 '--root', ROOT.anchor, str(source), str(output)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn('was ignored', result.stderr)
            self.assertNotIn('did not converge', result.stderr)
            result = TablePage(output.read_text())
            return result if page else result.cells

    def assert_borders(self, cell, value):
        self.assertEqual(self.borders(cell), {f'border-{side}': value for side in SIDES})

    def borders(self, cell):
        return {key: value for key, value in cell[2].items() if key.startswith('border-')}

    def test_authored_width_reaches_header_and_body_cells(self):
        cells = self.compile('''
#table(columns: 2, stroke: .2mm, table.header[A][B], [C], [D])
''')
        self.assertEqual([cell[0] for cell in cells], ['th', 'th', 'td', 'td'])
        for cell in cells:
            for side in SIDES:
                width, pattern, color = cell[2][f'border-{side}'].split()
                self.assertAlmostEqual(float(width.removesuffix('pt')), .2 * 72 / 25.4)
                self.assertEqual((pattern, color), ('solid', '#000000'))

    def test_default_and_inherited_strokes_and_borderless_headers(self):
        cells = self.compile('''
#table([Default])
#set table(stroke: 2pt + rgb("#123456"))
#table([Inherited])
#table(stroke: none, table.header[Borderless header], [Borderless body])
''')
        self.assertEqual(len(cells), 4)
        self.assert_borders(cells[0], '1pt solid #000000')
        self.assert_borders(cells[1], '2pt solid #123456')
        for cell in cells[2:]:
            self.assert_borders(cell, 'none')

    def test_function_column_array_and_cell_side_overrides(self):
        cells = self.compile('''
#table(columns: 2, stroke: (x, y) => if x == y { 2pt + rgb("#123456") } else { none },
  [A], [B], [C], table.cell(stroke: (left: 3pt, top: none))[D])
#table(columns: 2, stroke: (none, 2pt), [E], [F])
''')
        self.assertEqual(len(cells), 6)
        self.assert_borders(cells[0], '2pt solid #123456')
        for cell in (cells[1], cells[2], cells[4]):
            self.assert_borders(cell, 'none')
        self.assertEqual(self.borders(cells[3]), {
            'border-top': 'none', 'border-right': '2pt solid #123456',
            'border-bottom': '2pt solid #123456', 'border-left': '3pt solid #123456'})
        self.assert_borders(cells[5], '2pt solid #000000')

    def test_dash_families_and_transparent_colors(self):
        cells = self.compile('''
#table(stroke: (paint: rgb("#12345680"), thickness: 1pt, dash: "dashed"), [Dashed])
#table(stroke: (dash: "dotted"), [Dotted])
#table(stroke: (dash: ()), [Solid])
''')
        self.assertEqual(len(cells), 3)
        self.assert_borders(cells[0], '1pt dashed #12345680')
        self.assert_borders(cells[1], '1pt dotted #000000')
        self.assert_borders(cells[2], '1pt solid #000000')

    def test_spans_nested_tables_and_plain_html_cells_keep_their_structure(self):
        cells = self.compile('''
#table(columns: 3, stroke: 2pt,
  table.cell(colspan: 2)[Wide], table.cell(rowspan: 2)[Tall],
  [#table(stroke: none, [Nested])], [Last])
#html.elem("table")[#html.elem("tr")[#html.elem("td", attrs: (style: "color: red;"))[Plain]]]
''')
        self.assertEqual(len(cells), 6)
        self.assertEqual(cells[0][1]['colspan'], '2')
        self.assertEqual(cells[1][1]['rowspan'], '2')
        for index in (0, 1, 2, 4):
            self.assert_borders(cells[index], '2pt solid #000000')
        self.assert_borders(cells[3], 'none')
        self.assertEqual(cells[5][2], {'color': 'red'})
        self.assertNotIn('data-table-cell', cells[5][1])

    def test_alignment_functions_arrays_and_cell_overrides(self):
        cells = self.compile('''
#table(columns: 2, align: (x, y) => if x == 0 { center + top } else { right + horizon },
  [A], [B], [C], table.cell(align: bottom)[D])
#table(columns: 3, align: (left, center, right), [E], [F], [G])
''')
        self.assertEqual([(c[2]['text-align'], c[2]['vertical-align']) for c in cells], [
            ('center', 'top'), ('right', 'middle'), ('center', 'top'), ('right', 'bottom'),
            ('left', 'top'), ('center', 'top'), ('right', 'top')])

    def test_outer_alignment_is_inherited_and_separate_from_cell_alignment(self):
        page = self.compile('''
#align(right + horizon)[#table(columns: (30pt, 40pt), [A], [B])]
#align(center)[#table(columns: (30pt,), align: left + bottom, [C])]
#table(align: center, [D])
''', page=True)
        self.assertEqual([(c[2]['text-align'], c[2]['vertical-align']) for c in page.cells], [
            ('right', 'middle'), ('right', 'middle'), ('left', 'bottom'), ('center', 'top')])
        self.assertEqual(styles(page.tables[0])['margin-left'], 'auto')
        self.assertEqual(styles(page.tables[0])['margin-right'], '0')
        self.assertEqual(styles(page.tables[1])['margin-inline'], 'auto')
        self.assertEqual(styles(page.tables[2])['margin-inline-start'], '0')

    def test_fill_functions_arrays_transparency_and_overrides(self):
        cells = self.compile('''
#set table(fill: rgb("#112233"))
#table(columns: 2, fill: (x, y) => if y == 0 { rgb("#12345680") } else { none },
  table.header[A][B], [C], table.cell(fill: rgb("#abcdef"))[D])
#table(columns: 2, fill: (rgb("#f0f0f0"), none), [E], [F])
#table([Inherited])
''')
        self.assertEqual([c[2]['background'] for c in cells], [
            '#12345680', '#12345680', 'transparent', '#abcdef', '#f0f0f0', 'transparent', '#112233'])

    def test_linear_gradient_fill_retains_direction_colors_and_stops(self):
        cells = self.compile('''
#table(fill: gradient.linear((rgb("#112233"), 0%), (rgb("#aabbcc"), 100%), angle: 0deg), [A])
''')
        self.assertEqual(cells[0][2]['background'], 'linear-gradient(90deg, #112233 0%, #aabbcc 100%)')

    def test_columns_preserve_fixed_relative_auto_and_fractional_tracks(self):
        page = self.compile('''
#table(columns: (72pt, 144pt), [A], [B])
#table(columns: (25%, 25%), [C], [D])
#table(columns: (72pt, 1fr, 2fr), [E], [F], [G])
#table(columns: (auto, 1fr), [H], [I])
#table(columns: 3, [J], [K], [L])
''', page=True)
        self.assertEqual([styles(t)['width'] for t in page.tables], [
            '216pt', '50%', '100%', '100%', 'auto'])
        self.assertEqual([styles(t)['table-layout'] for t in page.tables], ['fixed'] * 3 + ['auto'] * 2)
        self.assertEqual(page.colgroups[0], ['72pt', '144pt'])
        self.assertEqual(page.colgroups[1], ['50%', '50%'])
        self.assertEqual(page.colgroups[2][0], '72pt')
        for actual, share, offset in zip(page.colgroups[2][1:], [100 / 3, 200 / 3], [-24, -48]):
            percent, points = actual.removeprefix('calc(').removesuffix(')').split(' + ')
            self.assertAlmostEqual(float(percent.removesuffix('%')), share)
            self.assertEqual(float(points.removesuffix('pt')), offset)
        self.assertEqual(page.colgroups[3], ['auto', '100%'])
        self.assertEqual(page.colgroups[4], ['auto'] * 3)

    def test_nested_tables_get_their_own_columns_and_plain_html_is_untouched(self):
        page = self.compile('''
#table(columns: (72pt, 1fr), [A], [
  #table(columns: (1fr, 2fr, 3fr), [B], [C], [D])
  #html.elem("table")[#html.elem("tr")[#html.elem("td")[Plain #table(columns: (1fr,), [Inner])]]]
])
''', page=True)
        self.assertEqual(len(page.tables), 4)
        self.assertEqual([len(cols) for cols in page.colgroups], [2, 3, 1])
        self.assertNotIn('data-table-columns', page.tables[2])


if __name__ == '__main__':
    unittest.main()
