"""Exercise attachment validation and the build/deployment file contract."""
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import public_files
from public_files import (COURSE_FIGURES, copy_font_assets, copy_public_files, note_outputs,
                          POKER_ASSETS, required_files, validate_inputs, validate_public_path)

ROOT = Path(__file__).resolve().parents[1]


class PublicFilesTests(unittest.TestCase):
    def test_poker_assets_required_with_the_host_lecture(self):
        config = {'notes': [{'source': 'content/learning_efg.typ'}]}
        self.assertTrue(POKER_ASSETS <= required_files(config))
        self.assertTrue(POKER_ASSETS.isdisjoint(required_files({'notes': []})))
        for name in POKER_ASSETS:
            validate_public_path(name, required_files(config))

    @unittest.skipUnless(shutil.which('typst'), 'Typst CLI is required')
    def test_poker_mount_fallback_and_ordered_assets_survive_export(self):
        with tempfile.TemporaryDirectory() as folder:
            source = Path(folder) / 'probe.typ'
            output = source.with_suffix('.html')
            helper = json.dumps(str(ROOT / 'content/meta/cfr-poker.typ'))
            source.write_text(f'#import {helper}: cfr-poker\n#cfr-poker()')
            subprocess.run(['typst', 'compile', '--root', ROOT.anchor, '--features', 'html',
                            '--format', 'html', str(source), str(output)],
                           check=True, capture_output=True)
            markup = output.read_text()
        self.assertIn('id="cfr-poker"', markup)
        self.assertIn('href="assets/cfr-poker/poker.css"', markup)
        scripts = [markup.index('src="assets/cfr-poker/' + name + '"')
                   for name in ('poker-data.js', 'leduc.js', 'poker.js')]
        self.assertEqual(scripts, sorted(scripts))
        self.assertIn('Enable JavaScript', markup)

    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.config = {'notes': [{'source': 'notes/topic.typ'}],
                       'slides': {'overview': 'slides/intro.pdf'}}
        self.modules = [{'rows': [{'kind': 'lecture', 'id': 'overview'},
                                  {'kind': 'lecture', 'id': 'nash'},
                                  {'kind': 'no-class', 'id': None}]}]
        for source in [*COURSE_FIGURES.values(), 'notes/topic.typ']:
            path = self.root / source
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('fixture')
        path = self.root / 'slides/intro.pdf'
        path.parent.mkdir()
        path.write_bytes((ROOT / 'slides/L00_course_intro.pdf').read_bytes())

    def validate(self):
        validate_inputs(self.config, self.modules, self.root)

    def test_font_update_removes_retired_assets_and_keeps_license(self):
        source = self.root / 'html-exporter/assets/fonts'
        source.mkdir(parents=True)
        (source / 'SourceSans3-Bold.ttf').write_bytes(b'new font')
        (source / 'OFL.txt').write_text('font license')
        target = self.root / 'output/assets/fonts'
        target.mkdir(parents=True)
        (target / 'retired-font.ttf').write_bytes(b'old font')
        copy_font_assets(self.root, self.root / 'output')
        self.assertEqual({p.name for p in target.iterdir()}, {'SourceSans3-Bold.ttf', 'OFL.txt'})
        self.assertEqual((target / 'OFL.txt').read_text(), 'font license')
        for name in ('assets/fonts/OFL.txt', 'assets/fonts/README.md'):
            validate_public_path(name, set())

    def test_unknown_lecture_id_fails_before_copying(self):
        self.config['slides'] = {'typo': 'slides/intro.pdf'}
        with self.assertRaisesRegex(ValueError, 'Unknown slide lecture IDs: typo'):
            self.validate()

    def test_missing_and_corrupt_pdfs_fail(self):
        path = self.root / 'slides/intro.pdf'
        path.unlink()
        with self.assertRaisesRegex(ValueError, 'Missing course source'):
            self.validate()
        path.write_bytes(b'%PDF-1.7\nNot actually a PDF')
        with self.assertRaisesRegex(ValueError, 'Invalid slide PDF'):
            self.validate()

    def test_wrong_extension_and_wrong_shape_fail(self):
        for slides in [{'overview': 'slides/intro.pptx'}, ['slides/intro.pdf']]:
            with self.subTest(slides=slides), self.assertRaises(ValueError):
                required_files({**self.config, 'slides': slides})

    def test_distinct_files_cannot_overwrite_same_output(self):
        self.config['slides']['nash'] = 'other/INTRO.pdf'
        with self.assertRaisesRegex(ValueError, 'Colliding slide output'):
            self.validate()
        self.config['slides']['nash'] = 'slides/intro.pdf'
        self.validate()  # Reusing exactly the same deck is intentional and safe.

    def test_source_cannot_escape_course_directory(self):
        self.config['slides']['overview'] = '../intro.pdf'
        with self.assertRaisesRegex(ValueError, 'inside the course directory'):
            self.validate()

    def interactive(self, markup='<html><head><style>body { color: black }</style></head>'
                                '<body><script>const slide = 1;</script></body></html>'):
        self.config['interactive_slides'] = {'overview': 'slides/intro.html'}
        path = self.root / 'slides/intro.html'
        path.write_text(markup)
        return path

    def test_interactive_decks_copy_once_and_preserve_pdf_slides(self):
        source = self.interactive('<html><head><style>@font-face { src: url(data:font/woff2;base64,AA) }</style>'
                                  '</head><body><a href="https://example.com/notes">Notes</a>'
                                  '<img src="data:image/png;base64,AA"></body></html>')
        self.config['interactive_slides']['nash'] = 'slides/intro.html'
        self.validate()
        destination = self.root / 'output'
        copy_public_files(self.config, self.root, destination)
        required = required_files(self.config)
        self.assertTrue({'slides/intro.html', 'slides/intro.pdf'} <= required)
        self.assertEqual((destination / 'slides/intro.html').read_bytes(), source.read_bytes())
        validate_public_path('slides/intro.html', required)

    def test_interactive_schema_ids_paths_and_collisions_fail_before_copying(self):
        self.interactive()
        cases = [
            (['slides/intro.html'], 'must map'),
            ({'overview': 'slides/intro.js'}, 'standalone HTML'),
            ({'missing': 'slides/intro.html'}, 'Unknown slide lecture IDs'),
            ({'overview': '../intro.html'}, 'inside the course directory'),
            ({'overview': str(self.root / 'slides/intro.html')}, 'inside the course directory'),
            ({'overview': 'slides/missing.html'}, 'Missing course source'),
            ({'overview': 'slides/intro.html', 'nash': 'other/INTRO.html'}, 'Colliding slide output'),
        ]
        for mapping, message in cases:
            with self.subTest(mapping=mapping), self.assertRaisesRegex(ValueError, message):
                self.config['interactive_slides'] = mapping
                self.validate()

    def test_interactive_source_symlink_cannot_escape_course_directory(self):
        path = self.interactive()
        path.unlink()
        path.symlink_to(ROOT / 'html-export.json')
        with self.assertRaisesRegex(ValueError, 'inside the course directory'):
            self.validate()

    def test_interactive_assets_must_be_embedded(self):
        for resource in ('<script src="deck.js"></script>', '<link rel="stylesheet" href="deck.css">',
                         '<img src="https://example.com/image.png">',
                         '<style>body { background: url(../image.png) }</style>',
                         '<style>@import "deck.css";</style>'):
            with self.subTest(resource=resource), self.assertRaisesRegex(ValueError, 'Interactive slides must'):
                self.interactive('<html><body>' + resource + '</body></html>')
                self.validate()
        self.interactive('<h1>Just a fragment</h1>')
        with self.assertRaisesRegex(ValueError, 'complete HTML document'):
            self.validate()

    def test_speaker_notes_cannot_enter_the_public_slide_build(self):
        for leak in ('<aside class="notes">Private cue</aside>',
                     '<section data-notes="Private cue"></section>',
                     '<script id="slide-data" type="application/json">'
                     '[{"id":"one","notes":"Private cue"}]</script>',
                     '<script id="slide-data" type="application/json">'
                     '[{"id":"one","source":"Private outline"}]</script>'):
            with self.subTest(leak=leak), self.assertRaisesRegex(ValueError, 'speaker notes'):
                self.interactive('<html><body>' + leak + '</body></html>')
                self.validate()
        self.interactive('<html><body><aside class="notes">Private cue</aside></body></html>')
        destination = self.root / 'output'
        with self.assertRaisesRegex(ValueError, 'speaker notes'):
            copy_public_files(self.config, self.root, destination)
        self.assertFalse(destination.exists())

    def page(self, markup='<html><body><a href="../index.html">Course</a><script>run();</script></body></html>'):
        self.config['interactive_pages'] = {'zero-sum-2xn': 'interactive/zero_sum_2xn.html'}
        path = self.root / 'interactive/zero_sum_2xn.html'
        path.parent.mkdir(exist_ok=True)
        path.write_text(markup)
        return path

    def test_interactive_pages_copy_to_their_own_directory(self):
        source = self.page()
        self.validate()
        destination = self.root / 'output'
        copy_public_files(self.config, self.root, destination)
        required = required_files(self.config)
        self.assertIn('interactive/zero_sum_2xn.html', required)
        self.assertEqual((destination / 'interactive/zero_sum_2xn.html').read_bytes(), source.read_bytes())
        validate_public_path('interactive/zero_sum_2xn.html', required)

    def test_interactive_page_schema_ids_and_paths_fail_before_copying(self):
        self.page()
        cases = [
            (['interactive/zero_sum_2xn.html'], 'must map'),
            ({'zero-sum-2xn': 'interactive/zero_sum_2xn.js'}, 'standalone interactive'),
            ({'zero-sum-2xn': 'slides/zero_sum_2xn.html'}, 'standalone interactive'),
            ({'Zero Sum': 'interactive/zero_sum_2xn.html'}, 'Invalid interactive page IDs'),
            ({'zero-sum-2xn': 'interactive/missing.html'}, 'Missing course source'),
        ]
        for mapping, message in cases:
            with self.subTest(mapping=mapping), self.assertRaisesRegex(ValueError, message):
                self.config['interactive_pages'] = mapping
                self.validate()

    def test_interactive_page_assets_must_be_embedded(self):
        for resource in ('<script src="https://cdn.example.com/lib.js"></script>',
                         '<link rel="stylesheet" href="https://fonts.example.com/css">',
                         '<style>@font-face { src: url(font.woff) }</style>'):
            with self.subTest(resource=resource), self.assertRaisesRegex(ValueError, 'must'):
                self.page('<html><body>' + resource + '</body></html>')
                self.validate()

    def test_interactive_pages_reuse_only_the_shared_course_fonts(self):
        markup = '<html><style>@font-face {src: url("../assets/fonts/SourceSans3-Regular-web.woff?v=123")}</style></html>'
        source = self.page(markup)
        self.validate()
        destination = self.root / 'output'
        copy_public_files(self.config, self.root, destination)
        self.assertEqual((destination / 'interactive/zero_sum_2xn.html').read_text(), markup)
        with self.assertRaisesRegex(ValueError, 'must embed'):
            public_files.validate_standalone_slide(source)
        for url in ('../assets/fonts/other.woff', 'https://example.com/font.woff',
                    '../assets/fonts/../../private.woff'):
            self.page(markup.replace('../assets/fonts/SourceSans3-Regular-web.woff?v=123', url))
            with self.assertRaisesRegex(ValueError, 'must embed'):
                self.validate()

    def test_published_zero_sum_2xn_page_is_standalone(self):
        config = {'interactive_pages': {'zero-sum-2xn': 'interactive/zero_sum_2xn.html'}}
        copied = public_files.copied_files(config)
        self.assertEqual(copied, {**{'assets/course/' + k: v for k, v in COURSE_FIGURES.items()},
                                  'interactive/zero_sum_2xn.html': 'interactive/zero_sum_2xn.html'})
        public_files.validate_standalone_slide(ROOT / 'interactive/zero_sum_2xn.html', shared_fonts=True)

    def test_note_filename_collision_fails_before_compilation(self):
        self.config['notes'].append({'source': 'other/TOPIC.typ'})
        with self.assertRaisesRegex(ValueError, 'Colliding note output'):
            self.validate()

    def test_build_copy_and_deployment_use_the_same_output_names(self):
        self.validate()
        destination = self.root / 'output'
        copy_public_files(self.config, self.root, destination)
        required = required_files(self.config)
        self.assertEqual(note_outputs(self.config['notes'][0]), {
            'html': 'topic.html', 'pdf': 'pdf/topic.pdf'})
        for path in destination.rglob('*'):
            if path.is_file():
                name = path.relative_to(destination).as_posix()
                self.assertIn(name, required)
                validate_public_path(name, required)
        for name in ('slides/private.pdf', 'assets/.env', '../index.html', 'fow/private.py',
                     'source/topic.typ'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                validate_public_path(name, required)


if __name__ == '__main__':
    unittest.main()
