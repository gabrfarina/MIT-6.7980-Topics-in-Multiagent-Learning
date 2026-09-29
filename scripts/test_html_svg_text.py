"""Exercise selectable figures through native frames and page postprocessing."""
from html.parser import HTMLParser
from pathlib import Path
import subprocess
import tempfile
import unittest
import unicodedata

from build_figures import EXPORTER


class SvgTextPage(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.labels = []
        self.ids = []
        self.current = None
        self.links = []
        self.linked_labels = []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.append(attrs['id'])
        if tag == 'text':
            self.current = []
        if tag == 'a':
            self.links.append(attrs.get('href', attrs.get('xlink:href')))

    def handle_data(self, data):
        if self.current is not None:
            self.current.append(data)

    def handle_endtag(self, tag):
        if tag == 'text' and self.current is not None:
            self.labels.append(''.join(self.current))
            if self.links:
                self.linked_labels.append((self.links[-1], ''.join(self.current)))
            self.current = None
        if tag == 'a':
            self.links.pop()


@unittest.skipUnless(EXPORTER.is_file(), 'Build the HTML exporter with make figures first')
class SelectableSvgTests(unittest.TestCase):
    def test_repeated_scaled_figures_expose_unicode_text_and_unique_ids(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            figure = root / 'content/figures/example/labels.typ'
            figure.parent.mkdir(parents=True)
            figure.write_text('''#set page(width: auto, height: auto, margin: 2pt)
#set text(font: "Georgia")
Alpha & beta\\ $x^2 + alpha$
''')
            svg = root / '.build/html-figures/example/labels.svg'
            self.run_export(root, '--figure-svg', str(figure), str(svg))
            note = root / 'note.typ'
            note.write_text('''#html.frame(image("content/figures/example/labels.svg", width: 180pt))
#html.frame(rotate(15deg, image("content/figures/example/labels.svg", width: 90pt)))
''')
            output = root / 'note.html'
            self.run_export(root, str(note), str(output))
            html = output.read_text()
            page = SvgTextPage(html)
            self.assertEqual(page.labels.count('Alpha & beta'), 2)
            labels = [unicodedata.normalize('NFKC', label) for label in page.labels]
            self.assertEqual(labels.count('α'), 2)
            self.assertIn('x', labels)
            self.assertIn('2', labels)
            self.assertNotIn('data:image/svg+xml;base64,', html)
            ids = [identifier for identifier in page.ids
                   if identifier.startswith('selectable-svg-')]
            self.assertTrue(ids)
            self.assertEqual(len(ids), len(set(ids)))

    def test_transformed_link_text_retains_destination_without_linking_neighbors(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            figure = root / 'content/figures/example/links.typ'
            figure.parent.mkdir(parents=True)
            figure.write_text('''#set page(width: auto, height: auto, margin: 2pt)
#set text(font: "Georgia")
#rotate(17deg, box(inset: 4pt)[
  #link("https://example.org/code?a=1&b=2#L1-L2")[Open code] unlinked
])
''')
            svg = root / '.build/html-figures/example/links.svg'
            self.run_export(root, '--figure-svg', str(figure), str(svg))
            note = root / 'note.typ'
            note.write_text('''#html.frame(image("content/figures/example/links.svg", width: 180pt))
#html.frame(rotate(-25deg, image("content/figures/example/links.svg", width: 90pt)))
''')
            output = root / 'note.html'
            self.run_export(root, str(note), str(output))
            page = SvgTextPage(output.read_text())
            self.assertEqual(page.linked_labels, [
                ('https://example.org/code?a=1&b=2#L1-L2', 'Open code'),
                ('https://example.org/code?a=1&b=2#L1-L2', 'Open code'),
            ])
            self.assertEqual(sum('unlinked' in label for label in page.labels), 2)

    def run_export(self, root, *args):
        result = subprocess.run([str(EXPORTER), '--root', str(root), *args],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
