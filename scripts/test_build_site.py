"""Guard native bundle failures and the exported lecture downloads."""
from pathlib import Path
import json
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import build_site


class LecturePdfBuildTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.stage = self.root / '.build/site'
        (self.stage / 'pdf').mkdir(parents=True)
        (self.stage / 'assets').mkdir()
        (self.stage / 'assets/notes.css').write_text('body {}')
        (self.root / '.build/logs').mkdir()
        self.source = self.root / 'content/lecture.typ'
        self.source.parent.mkdir(parents=True)
        self.source.write_text('''#import "meta/gabri_notes.typ": *
#image("figures/game.png")
Lecture prose.
''')
        self.chapter = {'source': 'content/lecture.typ', 'number': 3}
        self.original = self.source.read_text()
        (self.root / '.build/native-html').mkdir()
        (self.root / '.build/native-html/lecture.html').write_text('<p>Native lecture</p>')
        (self.root / '.build/html-export.json').write_text('{}')
        for name, value in (('ROOT', self.root), ('STAGE', self.stage)):
            replacement = patch.object(build_site, name, value)
            replacement.start()
            self.addCleanup(replacement.stop)
        replacement = patch.object(build_site, 'RESOLVED_CONFIG', self.root / '.build/html-export.json')
        replacement.start()
        self.addCleanup(replacement.stop)

    def test_pdf_source_preserves_prose_and_resolves_asset_paths(self):
        generated = build_site.prepare_pdf_source(self.source).read_text()
        self.assertIn('#import "/content/meta/gabri_notes.typ": *', generated)
        self.assertIn('#image("/content/figures/game.png")', generated)
        self.assertIn('Lecture prose.', generated)
        self.assertEqual(self.source.read_text(), self.original)

    def test_obsolete_source_layouts_are_rejected(self):
        for obsolete in ('../meta/gabri_notes.typ', 'meta/gabri_notes_bk.typ',
                         'meta/gabri_notes_pdf.typ', 'figures/L12/game.svg'):
            with self.subTest(obsolete=obsolete):
                self.source.write_text(f'#import "{obsolete}": *')
                with self.assertRaisesRegex(ValueError, 'obsolete source layout'):
                    build_site.chapter_source_text(self.source)

    def test_html_uses_figure_variants_and_keeps_raster_images(self):
        self.source.write_text('#image("figures/example/plot.svg")\n'
                               '#image("figures/example/photo.png")')
        html = build_site.prepare_html_source(self.source, self.chapter).read_text()
        pdf = build_site.prepare_pdf_source(self.source).read_text()
        self.assertIn('"/.build/html-figures/example/plot.svg"', html)
        self.assertIn('"/content/figures/example/photo.png"', html)
        self.assertIn('"/content/figures/example/plot.svg"', pdf)
        self.assertNotIn('html-figures', pdf)

    def test_native_output_is_postprocessed_with_its_pdf_download(self):
        calls = []
        (self.stage / 'pdf/lecture.pdf').write_bytes(b'%PDF-1.7\n')

        def export(args, **kwargs):
            calls.append(args)
            output = Path(args[-1])
            self.assertEqual(args[args.index('--pdf') + 1], 'pdf/lecture.pdf')
            self.assertEqual(Path(args[args.index('--from-html') + 1]),
                             self.root / '.build/native-html/lecture.html')
            output.write_text('<style>body {}</style><p>Lecture prose.</p>')
            return subprocess.CompletedProcess(args, 0)

        with patch.object(build_site.subprocess, 'run', side_effect=export):
            build_site.build_chapter(self.chapter)
            first = (self.stage / 'lecture.html').read_text()
            self.assertRegex(first, r'assets/notes\.css\?v=[0-9a-f]{12}')
            build_site.build_chapter(self.chapter)
            self.assertEqual((self.stage / 'lecture.html').read_text(), first)
            (self.stage / 'assets/notes.css').write_text('body { color: black; }')
            build_site.build_chapter(self.chapter)
            self.assertNotEqual((self.stage / 'lecture.html').read_text(), first)
            build_site.build_chapter(self.chapter, force=True)
        self.assertEqual(len(calls), 3)  # initial build, CSS change, forced build
        self.assertFalse((self.stage / 'source').exists())

    def test_bundle_tracks_dependencies_outputs_and_force(self):
        helper = self.root / 'content/helper.typ'
        helper.write_text('first')
        calls = []
        def compile_bundle(args, **kwargs):
            calls.append(args)
            directory = Path(args[-1])
            directory.mkdir(parents=True)
            (directory / 'lecture.pdf').write_text(helper.read_text())
            Path(args[args.index('--deps') + 1]).write_text(json.dumps({'inputs': [str(helper)]}))
            return subprocess.CompletedProcess(args, 0)

        with patch.object(build_site.subprocess, 'run', side_effect=compile_bundle):
            output = build_site.compile_note_bundle('pdf')
            build_site.compile_note_bundle('pdf')
            self.assertEqual(len(calls), 1)
            helper.write_text('second')
            build_site.compile_note_bundle('pdf')
            self.assertEqual((output / 'lecture.pdf').read_text(), 'second')
            (output / 'lecture.pdf').unlink()
            build_site.compile_note_bundle('pdf')
            build_site.compile_note_bundle('pdf', force=True)
            self.assertEqual(len(calls), 4)

    def test_native_html_edit_reprocesses_only_the_changed_lecture(self):
        second = dict(self.chapter, source='content/other.typ', number=4)
        (self.root / second['source']).write_text('Other lecture')
        native = self.root / '.build/native-html'
        (native / 'other.html').write_text('Other native lecture')
        for name in ('lecture', 'other'):
            (self.stage / f'pdf/{name}.pdf').write_bytes(b'%PDF-1.7\n')
        def export(args, **kwargs):
            Path(args[-1]).write_text('<style>body {}</style>' + Path(args[args.index('--from-html') + 1]).read_text())
            return subprocess.CompletedProcess(args, 0)
        with patch.object(build_site.subprocess, 'run', side_effect=export) as run:
            build_site.build_chapter(self.chapter)
            build_site.build_chapter(second)
            (native / 'lecture.html').write_text('Updated lecture')
            build_site.build_chapter(self.chapter)
            build_site.build_chapter(second)
            self.assertEqual(run.call_count, 3)
            self.assertIn('Updated lecture', (self.stage / 'lecture.html').read_text())

    def test_missing_pdf_stops_before_exporting_a_dead_link(self):
        with patch.object(build_site.subprocess, 'run') as run:
            with self.assertRaisesRegex(RuntimeError, 'Native PDF missing'):
                build_site.build_chapter(self.chapter)
        run.assert_not_called()

    def test_bundle_failure_preserves_typst_diagnostics(self):
        def fail(args, **kwargs):
            kwargs['stdout'].write('label <missing-theorem> does not exist\n')
            return subprocess.CompletedProcess(args, 1)

        with patch.object(build_site.subprocess, 'run', side_effect=fail):
            with self.assertRaisesRegex(RuntimeError,
                    'Native pdf bundle failed:.*\nlabel <missing-theorem> does not exist'):
                build_site.compile_note_bundle('pdf')

    def test_schedule_controls_generated_note_headers_without_editing_source(self):
        self.source.write_text('#import "meta/gabri_notes.typ": *\n'
                               '#show: gabri_notes.with(lec_num: 3, date: [Tue, Sep 16, 2025])')
        original = self.source.read_text()
        self.chapter.update(number=8, date='Thu, Oct 8, 2026')
        for generated in (build_site.prepare_pdf_source(self.source, self.chapter),
                          build_site.prepare_html_source(self.source, self.chapter)):
            self.assertIn('lec_num: 8, date: [Thu, Oct 8, 2026]', generated.read_text())
        self.assertEqual(self.source.read_text(), original)
        self.assertIn('#import "/content/meta/gabri_notes_html.typ": *',
                      build_site.prepare_html_source(self.source, self.chapter).read_text())

    def test_supplementary_header_uses_term_instead_of_a_class_date(self):
        self.chapter.update(number='S1', supplementary=True, date='Fall 2026')
        self.source.write_text('#show: gabri_notes.with(lec_num: 5, date: [old term])')
        content = build_site.chapter_source_text(self.source, self.chapter)
        self.assertIn('lec_num: "S1", date: [Fall 2026]', content)

    def test_title_mismatch_fails_both_formats_without_rewriting_source(self):
        title = 'Nash: "exact" and approximate solutions'
        self.chapter['title'] = title
        for authored in ('[Old title]', '"Old title"'):
            self.source.write_text('#import "meta/gabri_notes.typ": *\n'
                f'#show: gabri_notes.with(title: {authored})\n'
                '#lec_bibliography("meta/refs.bib", title: none)')
            original = self.source.read_text()
            for prepare in (build_site.prepare_pdf_source, build_site.prepare_html_source):
                with self.assertRaisesRegex(ValueError, 'Edit the Typst title explicitly'):
                    prepare(self.source, self.chapter)
            self.assertEqual(self.source.read_text(), original)

    def test_matching_authored_title_is_preserved_in_both_formats(self):
        self.chapter['title'] = 'High-dimensional games'
        for authored in ('[High-dimensional games]', '"High-dimensional games"'):
            self.source.write_text('#import "meta/gabri_notes.typ": *\n'
                f'#show: gabri_notes.with(title: {authored})\n'
                '#lec_bibliography("meta/refs.bib", title: none)')
            original = self.source.read_text()
            for generated in (build_site.prepare_pdf_source(self.source, self.chapter),
                              build_site.prepare_html_source(self.source, self.chapter)):
                self.assertIn(f'title: {authored}', generated.read_text())
                self.assertIn('title: none)', generated.read_text())
            self.assertEqual(self.source.read_text(), original)

    def test_missing_note_header_fails_instead_of_silently_using_old_metadata(self):
        self.chapter['date'] = 'Thu, Oct 8, 2026'
        with self.assertRaisesRegex(ValueError, 'expected one lecture number and date'):
            build_site.prepare_pdf_source(self.source, self.chapter)


if __name__ == '__main__':
    unittest.main()
