"""Protect the syllabus-to-reading mapping and fail closed on lost sessions."""
import copy
import json
import re
import tempfile
from datetime import date, timedelta
from pathlib import Path
import unittest

from check_site import Page
from course_index import load_course, read_schedule, render_index, resolve_readings, validate_readings
from course_data import read_course_data, with_course_data, rich_html

ROOT = Path(__file__).resolve().parents[1]


class CourseIndexTests(unittest.TestCase):
    def setUp(self):
        self.config, self.modules = load_course()
        self.path = ROOT / self.config['site']['syllabus_source']
        self.syllabus = self.path.read_text()

    def evaluate(self, source):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.typ', dir=self.path.parent) as file:
            file.write(source)
            file.flush()
            return read_schedule(Path(file.name), 2026)

    def lecture_block(self, id):
        start = self.syllabus.index(f'  lecture(\n    "{id}",')
        end = self.syllabus.index('\n  ),', start) + len('\n  ),')
        return self.syllabus[start:end]

    def test_full_semester_preserves_both_calendar_exceptions(self):
        rows = [row for module in self.modules for row in module['rows']]
        lectures = [r for r in rows if r['kind'] == 'lecture']
        self.assertEqual([r['number'] for r in lectures], list(range(len(lectures))))
        self.assertEqual(rows[0]['title'], 'Course Overview')
        self.assertEqual(rows[1]['title'], 'Setting and equilibria: the Nash equilibrium')
        self.assertEqual([r['iso_date'] for r in rows if r['title'] == 'No class'],
                         ['2026-10-13', '2026-11-24', '2026-11-26'])
        self.assertTrue(all(r['number'] is None for r in rows if r['kind'] == 'no-class'))
        self.assertEqual(rows[-1]['iso_date'], '2026-12-10')

    def test_calendar_has_every_official_tuesday_thursday_slot(self):
        expected = []
        day = date(2026, 9, 9)
        while day <= date(2026, 12, 10):
            if day.weekday() in (1, 3):
                expected.append(day.isoformat())
            day += timedelta(days=1)
        rows = [r for m in self.modules for r in m['rows']]
        self.assertEqual([r['iso_date'] for r in rows], expected)
        eligible = [r for r in rows if r['iso_date'] not in ('2026-10-13', '2026-11-26')]
        self.assertEqual(sum(date.fromisoformat(r['iso_date']).weekday() == 1 for r in eligible), 12)
        self.assertEqual(sum(date.fromisoformat(r['iso_date']).weekday() == 3 for r in eligible), 13)

    def test_missing_entries_bad_dates_and_duplicate_ids_fail(self):
        variants = [
            self.syllabus.replace(self.lecture_block('brouwer'), ''),
            self.syllabus.replace('schedule(class-dates,',
                'schedule(class-dates + (class-dates.last(),),'),
            self.syllabus.replace('schedule(class-dates,',
                'schedule(class-dates.rev(),'),
            self.syllabus.replace('schedule(class-dates,',
                'schedule(("bad date",) + class-dates.slice(1),'),
            self.syllabus.replace('"brouwer",', '"nash",'),
            self.syllabus.replace('..calendar-exceptions,',
                '..calendar-exceptions, no-class(on: "2026-09-10"),'),
        ]
        for i, source in enumerate(variants):
            with self.subTest(variant=i), self.assertRaises(ValueError):
                self.evaluate(source)

    def test_reordering_reassigns_dates_numbers_and_note_links(self):
        first, second = self.lecture_block('nash'), self.lecture_block('efg-learning')
        source = self.syllabus.replace(first, 'REORDER_MARKER').replace(second, first).replace('REORDER_MARKER', second)
        modules = self.evaluate(source)
        rows = {r['id']: r for m in modules for r in m['rows'] if r['id']}
        self.assertEqual((rows['nash']['number'], rows['nash']['iso_date']), (8, '2026-10-08'))
        self.assertEqual((rows['efg-learning']['number'], rows['efg-learning']['iso_date']), (1, '2026-09-15'))
        self.assertEqual([r['iso_date'] for m in modules for r in m['rows'] if r['title'] == 'No class'],
                         ['2026-10-13', '2026-11-24', '2026-11-26'])
        resolved = resolve_readings(self.config, modules)
        nash = next(c for c in resolved['notes'] if c['syllabus_ids'] == ['nash'])
        self.assertEqual((nash['number'], nash['date']), (8, 'Thu, Oct 8, 2026'))
        page = render_index(self.config, modules)
        row = re.search(r'<tr class="schedule-row"[^>]*>\s*<th[^>]*>08</th>.*?</tr>', page, re.S).group()
        self.assertIn('nfgs_nash.html', row)
        self.assertNotIn('learning_efg.html', row)

    def test_nested_typst_content_preserves_text_and_punctuation(self):
        source = self.syllabus.replace('[Course Overview]',
            '[Course *Overview*: #link("https://example.com/path")[Nash\'s games] (intro)]')
        self.assertEqual(self.evaluate(source)[0]['rows'][0]['title'], "Course Overview: Nash's games (intro)")

    def test_standalone_sessions_do_not_extend_foundations(self):
        standalone = [m for m in self.modules if not m['title']]
        self.assertEqual([[r['id'] for r in m['rows']] for m in standalone], [['overview'], ['taking-stock']])
        foundations = next(m for m in self.modules if 'Foundations' in m['title'])
        self.assertNotIn('taking-stock', [r['id'] for r in foundations['rows']])

    def test_every_note_and_pdf_remains_reachable_with_no_placeholder_links(self):
        html = render_index(self.config, self.modules)
        page = Page(html)
        for chapter in self.config['notes']:
            stem = Path(chapter['source']).stem
            self.assertIn(stem + '.html', page.links)
            self.assertIn('pdf/' + stem + '.pdf', page.links)
        self.assertIn('syllabus.pdf', page.links)
        self.assertNotIn('#', page.links)
        self.assertNotIn('Readings are drawn from the Fall 2025 notes', html)

    def test_note_numbers_match_the_current_syllabus(self):
        resolved = resolve_readings(self.config, self.modules)
        chapters = {Path(c['source']).stem: c for c in resolved['notes']}
        self.assertEqual(chapters['nfgs_nash']['syllabus_numbers'], [1])
        self.assertEqual(chapters['nfgs_nash']['number'], 1)
        self.assertEqual(chapters['bandit']['syllabus_numbers'], [6])
        self.assertEqual(chapters['bandit']['number'], 6)
        self.assertEqual(chapters['learning2']['syllabus_numbers'], [])
        self.assertTrue(chapters['learning2']['supplementary'])
        self.assertEqual(chapters['learning2']['number'], 'S4')
        config = copy.deepcopy(resolved)
        config['notes'][0], config['notes'][1] = config['notes'][1], config['notes'][0]
        with self.assertRaisesRegex(ValueError, 'out of syllabus order'):
            validate_readings(config, self.modules)

    def test_note_mapping_rejects_missing_lecture_ids(self):
        config = copy.deepcopy(self.config)
        config['notes'][0]['syllabus_ids'] = ['missing-topic']
        with self.assertRaisesRegex(ValueError, 'Invalid syllabus_ids'):
            resolve_readings(config, self.modules)

    def test_supplementary_readings_follow_the_suggested_sequence(self):
        readings = [c for c in self.config['notes'] if c.get('supplementary')]
        expected = [
            ('S1', 'nash_algorithms', 'brouwer', 2),
            ('S2', 'eah', 'nash-properties', 3),
            ('S3', 'phi_regret', 'learning-foundations', 4),
            ('S4', 'learning2', 'learning-algorithms', 5),
            ('S5', 'perfection', 'efg-learning', 8),
            ('S6', 'stochastic_games', 'efg-learning', 8),
        ]
        self.assertEqual([(c['number'], Path(c['source']).stem,
                           c['suggested_after']['id'], c['suggested_after']['number'])
                          for c in readings], expected)
        html = render_index(self.config, self.modules)
        for _, _, id, number in expected:
            self.assertIn(f'id="lecture-{id}"', html)
            self.assertRegex(html, f'href="#lecture-{id}"[^>]*>L{number:02}</a>')

    def test_reading_points_follow_topics_when_lectures_move(self):
        first, second = self.lecture_block('brouwer'), self.lecture_block('efg-learning')
        modules = self.evaluate(self.syllabus.replace(first, 'MARKER').replace(second, first).replace('MARKER', second))
        resolved = resolve_readings(self.config, modules)
        after = {c['supplementary_id']: c['suggested_after']['number']
                 for c in resolved['notes'] if c.get('supplementary')}
        self.assertEqual(after['nash-algorithms'], 8)
        self.assertEqual(after['perfection'], 2)
        html = render_index(self.config, modules)
        self.assertRegex(html, r'href="#lecture-brouwer"[^>]*>L08</a>')

    def test_supplementary_order_and_titles_come_from_the_syllabus(self):
        config = copy.deepcopy(self.config)
        # The source-file map can be in any order; the syllabus controls labels.
        config['notes'].reverse()
        readings = config['course']['info']['supplementary_readings']
        readings[0], readings[1] = readings[1], readings[0]
        readings[0]['title'] = 'Updated supplementary title'
        resolved = resolve_readings(config, self.modules)
        first = next(c for c in resolved['notes'] if c.get('supplementary'))
        self.assertEqual((first['number'], first['supplementary_id'], first['title']),
                         ('S1', 'minimax', 'Updated supplementary title'))

    def test_supplementary_mapping_rejects_lost_or_duplicate_readings(self):
        for variant in ('missing-id', 'duplicate-note', 'unmapped-note', 'duplicate-id', 'bad-after'):
            config = copy.deepcopy(self.config)
            readings = config['course']['info']['supplementary_readings']
            supplement = next(c for c in config['notes'] if c.get('supplementary'))
            if variant == 'missing-id':
                supplement['supplementary_id'] = 'missing'
            elif variant == 'duplicate-note':
                config['notes'].append(copy.deepcopy(supplement))
            elif variant == 'unmapped-note':
                config['notes'].remove(supplement)
            elif variant == 'duplicate-id':
                readings[1]['id'] = readings[0]['id']
            else:
                readings[0]['after'] = 'missing-lecture'
            with self.subTest(variant=variant), self.assertRaises(ValueError):
                resolve_readings(config, self.modules)

    def test_syllabus_title_change_requires_explicit_typst_title_edit(self):
        from build_site import chapter_source_text
        source = self.syllabus.replace('[High-dimensional games]',
            '[High-dimensional games: kernels and learning]')
        modules = self.evaluate(source)
        resolved = resolve_readings(self.config, modules)
        note = next(n for n in resolved['notes'] if n['syllabus_ids'] == ['kernelized'])
        title = 'High-dimensional games: kernels and learning'
        self.assertEqual(note['title'], title)
        self.assertEqual(note['short_title'], title)
        self.assertIn('>' + title + '</a>', render_index(resolved, modules))
        with self.assertRaisesRegex(ValueError, 'authored title.*does not match'):
            chapter_source_text(ROOT / note['source'], note)

    def test_all_authored_note_titles_match_syllabus_or_supplementary_list(self):
        from build_site import chapter_source_text
        for note in self.config['notes']:
            with self.subTest(note=note['source']):
                chapter_source_text(ROOT / note['source'], note)

    def test_course_overview_has_slides_but_no_notes_or_pending_label(self):
        html = render_index(self.config, self.modules)
        overview = re.search(r'<tr class="schedule-row"[^>]*>\s*<th[^>]*>00</th>.*?</tr>', html, re.S).group()
        self.assertIn('href="slides/L00_course_intro.pdf"', overview)
        self.assertIn('>Slides (PDF)</a>', overview)
        self.assertNotIn('class="reading-link"', overview)
        self.assertNotIn('class="lecture-title-link"', overview)
        self.assertNotIn('Not yet posted', overview)

    def test_authored_config_contains_no_generated_numbers_or_course_facts(self):
        authored = json.loads((ROOT / 'html-export.json').read_text())
        self.assertNotIn('lectures', authored)
        self.assertNotIn('year', authored['site'])
        for note in authored['notes']:
            self.assertFalse({'number', 'syllabus_numbers', 'date'} & note.keys())
            if note.get('supplementary'):
                self.assertFalse({'short_title', 'suggested_after'} & note.keys())
        ppad = next(n for n in self.config['notes'] if n['syllabus_ids'] == ['ppad'])
        self.assertEqual(ppad['number'], 19)
        self.assertEqual(ppad['date'], 'Thu, Nov 19, 2026')

    def test_syllabus_fact_and_prose_edits_flow_into_the_index_and_citations(self):
        source = self.syllabus.replace('room: "E25-111"', 'room: "TEST-ROOM"')
        source = source.replace('time: "11:00 am–12:30 pm"', 'time: "10:00–11:30"')
        source = source.replace('grading: (attendance: 20, material: 30, project: 50)',
                                'grading: (attendance: 20, material: 35, project: 45)')
        source = source.replace('title: "Topics in Multiagent Learning"', 'title: "Updated course title"')
        source = source.replace('Projects may be completed individually',
                                'Projects showcase *student research* and may be completed individually')
        with tempfile.NamedTemporaryFile(mode='w', suffix='.typ', dir=self.path.parent) as file:
            file.write(source)
            file.flush()
            data = read_course_data(Path(file.name), ROOT)
        config = with_course_data(self.config, data)
        html = render_index(config, self.modules)
        for expected in ('TEST-ROOM', '10:00–11:30', 'Improving material 35%',
                         'accounts for 35%', 'Project 45%', 'accounts for 45%',
                         'Updated course title', '<strong>student research</strong>'):
            self.assertIn(expected, html)
        self.assertEqual(config['how_to_cite']['booktitle'], 'MIT Updated course title Lecture Notes')
        self.assertNotIn('assets/course/html-notes-collage.svg', html)
        self.assertNotIn('assets/course/fog-of-war-challenge.png', html)

    def test_slides_follow_their_stable_id_when_lectures_move(self):
        first, second = self.lecture_block('nash'), self.lecture_block('efg-learning')
        modules = self.evaluate(self.syllabus.replace(first, 'MARKER').replace(second, first).replace('MARKER', second))
        config = copy.deepcopy(self.config)
        config['slides'] = {'nash': 'slides/L00_course_intro.pdf'}
        config['interactive_slides'] = {'nash': 'slides/interactive.html'}
        page = render_index(config, modules)
        row = re.search(r'<tr class="schedule-row"[^>]*>\s*<th[^>]*>08</th>.*?</tr>', page, re.S).group()
        self.assertIn('href="slides/interactive.html?overview=1"', row)
        self.assertIn('class="pdf-link slides-link"', row)
        self.assertIn('>Slides</a>', row)
        self.assertNotIn('slides/L00_course_intro.pdf', row)
        self.assertNotIn('Not yet posted', row)

    def test_only_l04_links_the_new_interactive_deck(self):
        page = render_index(self.config, self.modules)
        l04 = re.search(r'<tr class="schedule-row" id="lecture-learning-foundations">.*?</tr>', page, re.S).group()
        l05 = re.search(r'<tr class="schedule-row" id="lecture-learning-algorithms">.*?</tr>', page, re.S).group()
        self.assertIn('class="pdf-link slides-link" href="slides/L04_learning_in_games.html?overview=1"', l04)
        self.assertIn('>Slides</a>', l04)
        self.assertNotIn('slides/L04_learning_in_games.pdf', l04)
        self.assertNotIn('slides-link', l05)

    def test_new_unsupported_prose_does_not_silently_disappear(self):
        with self.assertRaisesRegex(ValueError, 'Unsupported course prose element'):
            rich_html({'func': 'equation', 'body': {'func': 'text', 'text': 'x'}})


if __name__ == '__main__':
    unittest.main()
