"""Exercise attachment validation and the build/deployment file contract."""
from pathlib import Path
import tempfile
import unittest

from public_files import (COURSE_FIGURES, copy_public_files, note_outputs,
                          required_files, validate_inputs, validate_public_path)

ROOT = Path(__file__).resolve().parents[1]


class PublicFilesTests(unittest.TestCase):
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
