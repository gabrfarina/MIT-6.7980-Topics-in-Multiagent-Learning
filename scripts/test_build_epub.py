"""Guard the EPUB packaging of the built lecture pages."""
import unittest

try:
    import build_epub
except ImportError:  # beautifulsoup4 and lxml are only needed for the EPUB build.
    build_epub = None


@unittest.skipIf(build_epub is None, 'requires beautifulsoup4 and lxml')
class EpubBuildTests(unittest.TestCase):
    def test_reading_groups_follow_the_lecture_rail(self):
        config = {'lectures': [
            {'source': 'content/content/nfgs_nash.typ', 'number': 1, 'syllabus_numbers': [1, 2],
             'short_title': 'Nash'},
            {'source': 'content/content/eah.typ', 'number': 'S1', 'supplementary': True,
             'syllabus_numbers': [], 'short_title': 'Minimax'},
        ]}
        self.assertEqual(build_epub.reading_groups(config), [
            {'label': 'Lectures', 'lectures': [{'slug': 'nfgs_nash', 'number': '1–2', 'title': 'Nash'}]},
            {'label': 'Supplementary readings', 'lectures': [{'slug': 'eah', 'number': 'S1', 'title': 'Minimax'}]},
        ])

    def test_lecture_links_math_and_figures_are_packaged(self):
        page = b'''<html><body><article class="lecture-content">
<nav class="compact-course-nav"><a href="index.html">Course home</a></nav>
<nav class="toc"><ol><li class="toc-l1"><a href="#sec-a"><span class="toc-no">1</span>
<span class="toc-title">Regret</span></a></li></ol></nav>
<h1 id="sec-a">Regret</h1>
<p>See <a href="eah.html#thm-1">S1</a>, the <a href="pdf/bandit.pdf">PDF</a>,
and <span class="math-katex-source" data-typst-math="x">\\(x^2\\)</span>.</p>
<span aria-label="A plot." class="lecture-image" role="img" style="width: 100% + 0pt;"><svg width="95pt"
style="width: 10em"><image xlink:href="data:image/png;base64,iVBORw0K"/></svg></span>
</article></body></html>'''
        math, images = build_epub.MathQueue(), {}
        body, sections = build_epub.convert_lecture(
            {'slug': 'bandit'}, page, {'bandit', 'eah'}, math, images, 'https://example.edu/course/')
        self.assertEqual(sections, [(1, '1 Regret', 'bandit.xhtml#sec-a')])
        self.assertIn('href="eah.xhtml#thm-1"', body)
        self.assertIn('href="https://example.edu/course/pdf/bandit.pdf"', body)
        self.assertNotIn('compact-course-nav', body)
        self.assertNotIn('data-typst-math', body)
        self.assertEqual(math.jobs, [{'tex': 'x^2', 'display': False}])
        self.assertIn('src="images/bandit-1.png"', body)
        self.assertIn('style="width: 10.00em"', body)
        self.assertEqual(images['images/bandit-1.png'], (b'\x89PNG\r\n', 'image/png'))

    def test_unconverted_site_markup_is_reported(self):
        self.assertEqual(build_epub.leftovers('<p>Plain <code>\\(x\\) <svg></svg></code> text.</p>'), [])
        self.assertEqual(len(build_epub.leftovers(
            '<p>\\(x\\)</p><span class="math"><svg></svg></span><image href="embedded:3"/>')), 3)

    def test_unsupported_image_type_stops_the_build(self):
        page = b'''<article class="lecture-content"><span class="lecture-image"><svg width="95pt">
<image xlink:href="data:image/gif;base64,R0lG"/></svg></span></article>'''
        with self.assertRaisesRegex(ValueError, 'bandit.html: unsupported embedded image type image/gif'):
            build_epub.convert_lecture({'slug': 'bandit'}, page, set(), build_epub.MathQueue(), {}, '')

    def test_mathml_is_flattened_for_epub_validators(self):
        namespace = 'xmlns="http://www.w3.org/1998/Math/MathML"'
        markup = (f'<math {namespace}><mtable width="100%"><mtr><mtd width="50%">'
                  '<mo><mi mathvariant="normal">≔</mi></mo></mtd></mtr></mtable></math>')
        self.assertEqual(build_epub.clean_mathml(markup),
                         f'<math {namespace}><mtable><mtr><mtd><mo mathvariant="normal">≔</mo>'
                         '</mtd></mtr></mtable></math>')


if __name__ == '__main__':
    unittest.main()
