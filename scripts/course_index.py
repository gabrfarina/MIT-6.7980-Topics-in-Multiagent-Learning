"""Course landing page, with the schedule read from the current Typst syllabus."""
from datetime import date
import copy
import json
from html import escape
from pathlib import Path
import re


from course_data import read_course_data, with_course_data, paragraphs, rich_html
from public_files import (copy_public_files, interactive_slide_output, note_outputs,
                          slide_output, validate_inputs)

ROOT = Path(__file__).resolve().parents[1]


def load_course(config_path: Path = ROOT / 'html-export.json') -> tuple[dict, list[dict]]:
    """Resolve the authored configuration once, before creating build artifacts."""
    config = json.loads(config_path.read_text())
    if 'notes' not in config or 'lectures' in config:
        raise ValueError('Use the notes list in html-export.json, not lectures.')
    for note in config['notes']:
        if any(key in note for key in ('number', 'syllabus_numbers', 'date')):
            raise ValueError('Note numbers and dates are generated from syllabus_ids; remove authored number, syllabus_numbers, and date fields.')
    data = read_course_data(ROOT / config['site']['syllabus_source'], ROOT)
    config = with_course_data(config, data)
    modules = schedule_modules(data['schedule'], config['site']['year'])
    config = resolve_readings(config, modules)
    validate_inputs(config, modules, ROOT)
    return config, modules


def read_schedule(syllabus: Path, year: int) -> list[dict]:
    """Read the exact schedule evaluated by Typst, including assigned dates."""
    return schedule_modules(read_course_data(syllabus, ROOT)['schedule'], year)


def schedule_modules(entries: list[dict], year: int) -> list[dict]:
    modules = []
    for entry in entries:
        if entry['kind'] == 'module':
            modules.append({'title': entry['title'], 'rows': []})
            continue
        if date.fromisoformat(entry['iso_date']).year != year:
            raise ValueError('Schedule date is outside the configured academic year.')
        if not modules or entry['standalone']:
            modules.append({'title': '', 'rows': []})
        modules[-1]['rows'].append(entry)
    return modules


def resolve_readings(config: dict, modules: list[dict]) -> dict:
    """Resolve stable IDs to syllabus titles, numbers, dates, and reading points."""
    resolved = copy.deepcopy(config)
    rows = {r['id']: r for m in modules for r in m['rows'] if r['kind'] == 'lecture'}
    supplements = config['course']['info']['supplementary_readings']
    supplement_ids = [s['id'] for s in supplements]
    if len(supplement_ids) != len(set(supplement_ids)):
        raise ValueError('Supplementary reading IDs must be unique.')
    mapped_supplements = set()
    for chapter in resolved['notes']:
        ids = chapter.get('syllabus_ids', [])
        if chapter.get('supplementary'):
            if ids:
                raise ValueError('Supplementary notes cannot claim syllabus lectures.')
            id = chapter.get('supplementary_id')
            if id not in supplement_ids or id in mapped_supplements:
                raise ValueError(f'Invalid or duplicate supplementary_id: {id!r}')
            mapped_supplements.add(id)
            index = supplement_ids.index(id)
            reading = supplements[index]
            if reading['after'] not in rows:
                raise ValueError(f"Invalid suggested lecture: {reading['after']}")
            after = rows[reading['after']]
            chapter['number'] = f'S{index + 1}'
            chapter['syllabus_numbers'] = []
            chapter['date'] = config['site']['term']
            chapter['title'] = chapter['short_title'] = reading['title']
            chapter['suggested_after'] = {key: after[key] for key in ('id', 'number', 'title')}
            continue
        if not ids or len(ids) != len(set(ids)) or not set(ids) <= rows.keys():
            raise ValueError(f"Invalid syllabus_ids for {chapter['source']}: {ids}")
        sessions = sorted((rows[id] for id in ids), key=lambda r: r['number'])
        chapter['title'] = sessions[0]['title']
        chapter['short_title'] = chapter['title']
        chapter['syllabus_numbers'] = [r['number'] for r in sessions]
        chapter['number'] = sessions[0]['number']
        day = date.fromisoformat(sessions[0]['iso_date'])
        chapter['date'] = f'{day:%a, %b} {day.day}, {day.year}'
    if mapped_supplements != set(supplement_ids):
        raise ValueError('Every supplementary reading must have a mapped note source.')
    resolved['notes'].sort(key=lambda c: (bool(c.get('supplementary')),
        int(str(c['number'])[1:]) if c.get('supplementary') else c['number']))
    validate_readings(resolved, modules)
    return resolved


def validate_readings(config: dict, modules: list[dict]) -> None:
    scheduled = {r['number'] for m in modules for r in m['rows'] if r['number'] is not None}
    primary = []
    seen_supplement = False
    supplement_number = 0
    for chapter in config['notes']:
        numbers = chapter.get('syllabus_numbers', [])
        if chapter.get('supplementary'):
            seen_supplement = True
            supplement_number += 1
            if chapter['number'] != f'S{supplement_number}':
                raise ValueError('Supplementary readings must be numbered S1, S2, and so on.')
            if numbers:
                raise ValueError('Supplementary notes cannot claim a syllabus session.')
        else:
            if seen_supplement or not numbers or not set(numbers) <= scheduled:
                raise ValueError('Readings must follow the syllabus before supplementary notes.')
            primary.append(min(numbers))
            if chapter['number'] not in numbers:
                raise ValueError('Lecture note numbers must match a linked syllabus session.')
    if primary != sorted(primary):
        raise ValueError('Readings are out of syllabus order.')


def render_index(config: dict, modules: list[dict], *, stylesheet_version: str = '') -> str:
    config = resolve_readings(config, modules)
    site = config['site']
    course = config['course']['info']
    prose = config['course']['text']
    instructors = ''.join(
        f'<li><a class="person-name" href="{escape(p["url"], quote=True)}">{escape(p["name"])}</a>'
        f'<a href="mailto:{escape(p["email"], quote=True)}">{escape(p["email"])}</a>'
        f'<span>Office {escape(p["office"])}</span></li>' for p in course['instructors'])
    tas = ''.join(
        f'<li><span class="person-name">{escape(p["name"])}</span>'
        f'<a href="mailto:{escape(p["email"], quote=True)}">{escape(p["email"])}</a>'
        f'<span>Office hours: {escape(p["office_hours"].replace(", room ", ", "))}</span></li>' for p in course['tas'])
    grading = ''.join(f'<li><strong>{label} {course["grading"][key]}%</strong></li>'
        for key, label in [('attendance', 'Attendance and participation'),
                           ('material', 'Improving material'), ('project', 'Project')])
    sections = []
    for index, module in enumerate(modules):
        rows = []
        for row in module['rows']:
            number = row['number']
            badge = row.get('badge', '')
            badge_html = (f'<span class="schedule-badge" data-badge="{escape(badge.lower(), quote=True)}">'
                          f'{escape(badge)}</span>') if badge else ''
            if number is None:
                rows.append(f'<tr class="schedule-break"><td class="session-number"></td>'
                            f'<td class="session-date"><time datetime="{row["iso_date"]}">{escape(row["date"])}</time>{badge_html}</td>'
                            f'<td class="break-topic" colspan="2"><strong>{escape(row["title"])}</strong>'
                            f'<span>{escape(row["description"])}</span></td></tr>')
                continue
            notes = [c for c in config['notes'] if number in c.get('syllabus_numbers', [])]
            title_html = escape(row['title'])
            if notes:
                title_href = escape(note_outputs(notes[0])['html'], quote=True)
                title_html = f'<a class="lecture-title-link" href="{title_href}">{title_html}</a>'
            links = ''.join(
                (f'<span class="reading-kind">{escape(c["reading_label"])}</span>' if c.get('reading_label') else '') +
                f'<a class="reading-link" href="{note_outputs(c)["html"]}" '
                f'aria-label="Read notes: {escape(c["short_title"], quote=True)}">HTML</a>'
                f'<a class="pdf-link" href="{note_outputs(c)["pdf"]}" '
                f'aria-label="PDF: {escape(c["short_title"], quote=True)}">PDF</a>' for c in notes)
            interactive = config.get('interactive_slides', {}).get(row['id'])
            if interactive:
                slides_href = escape(interactive_slide_output(interactive) + '?overview=1', quote=True)
                links += (f'<a class="pdf-link slides-link" href="{slides_href}" '
                          f'aria-label="Slides: {escape(row["title"], quote=True)}">Slides</a>')
            else:
                slides = config.get('slides', {}).get(row['id'])
                if slides:
                    slides_href = escape(slide_output(slides), quote=True)
                    links += (f'<a class="pdf-link slides-link" href="{slides_href}" '
                              f'aria-label="Slides (PDF): {escape(row["title"], quote=True)}">Slides (PDF)</a>')
            if not links:
                links = ('<span class="notes-pending">Not yet posted</span>'
                         if number != 0 and module['title'] != 'Project work and presentations' else '')
            rows.append(f'''<tr class="schedule-row" id="lecture-{escape(row['id'], quote=True)}">
  <th scope="row" class="session-number">{number:02}</th>
  <td class="session-date"><time datetime="{row['iso_date']}">{escape(row['date'])}</time>{badge_html}</td>
  <td class="session-topic"><h4>{title_html}</h4><p>{escape(row['description'])}</p></td>
  <td class="materials-cell"><div class="session-links">{links}</div></td>
</tr>''')
        title = re.sub(r' \(\d+ lectures\)$', '', module['title'])
        if title:
            opening = (f'<section class="schedule-module" aria-labelledby="module-{index}">'
                       f'<h3 id="module-{index}">{escape(title)}</h3>')
            table_label = f'aria-labelledby="module-{index}"'
        else:
            label = escape(module['rows'][0]['title'], quote=True)
            opening = f'<section class="schedule-standalone" aria-label="{label}">'
            table_label = f'aria-label="{label}"'
        sections.append(opening + f'<table class="schedule-table" {table_label}>'
                        '<colgroup><col class="number-column"><col class="date-column">'
                        '<col><col class="materials-column"></colgroup>'
                        '<thead><tr><th scope="col">#</th><th scope="col">Date</th>'
                        '<th scope="col">Topic</th><th scope="col">Notes</th></tr></thead>'
                        f'<tbody>{"".join(rows)}</tbody></table></section>')
    supplementary = ''.join(
        f'<tr><th scope="row" class="session-number">{escape(str(c["number"]))}</th>'
        f'<td class="session-topic"><h4><a class="lecture-title-link" href="{note_outputs(c)["html"]}">{escape(c["short_title"])}</a></h4></td>'
        f'<td class="suggested-after">'
        f'<a href="#lecture-{escape(c["suggested_after"]["id"], quote=True)}" '
        f'title="{escape(c["suggested_after"]["title"], quote=True)}">L{c["suggested_after"]["number"]:02}</a></td>'
        f'<td class="materials-cell"><div class="session-links">'
        f'<a class="reading-link" href="{note_outputs(c)["html"]}" '
        f'aria-label="Read notes: {escape(c["short_title"], quote=True)}">HTML</a>'
        f'<a class="pdf-link" href="{note_outputs(c)["pdf"]}" '
        f'aria-label="PDF: {escape(c["short_title"], quote=True)}">PDF</a></div></td></tr>'
        for c in config['notes'] if c.get('supplementary'))
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="{escape(site['event'])}, {escape(site['term'])}. {escape(site['title'])}. Course schedule, lecture notes, and syllabus.">
<title>{escape(site['event'])} · {escape(site['title'])} · {escape(site['term'])}</title>
<link rel="stylesheet" href="assets/notes.css">
<link rel="stylesheet" href="assets/course.css{('?v=' + escape(stylesheet_version, quote=True)) if stylesheet_version else ''}">
</head>
<body class="course-home">
<a class="skip-link" href="#main">Skip to content</a>
<header class="course-header home-width">
  <p class="course-term">{escape(site['event'])} · {escape(site['term'])}</p>
  <h1>{escape(site['title'])}</h1>
</header>
<main id="main" class="course-layout home-width">
<div class="course-content">
<section id="overview" class="course-overview" aria-label="Course overview">
  <div class="overview-copy">
  {paragraphs(prose['description'])}
  <nav class="course-links" aria-label="Course navigation"><a href="#schedule">Schedule &amp; notes</a><a href="syllabus.pdf">Syllabus (PDF)</a><a href="{escape(course['challenge'], quote=True)}">Fog of War Challenge <span aria-hidden="true">↗</span></a></nav>
  </div>
  <figure class="course-image">
    <img src="assets/course/course-image-transparent.svg" width="200" height="409" alt="Two phase portraits of learning dynamics in two-player games, showing strategy updates and marked equilibria.">
  </figure>
</section>
<section id="schedule" class="course-schedule" aria-labelledby="schedule-title">
  <h2 id="schedule-title">Schedule &amp; lecture notes</h2>
  {''.join(sections)}
  <section class="supplementary-section" aria-labelledby="supplementary-title">
    <h3 id="supplementary-title">Supplementary reading</h3>
    <table class="supplementary-table" aria-labelledby="supplementary-title">
      <colgroup><col class="number-column"><col><col class="suggested-after-column"><col class="materials-column"></colgroup>
      <thead><tr><th scope="col">#</th><th scope="col">Reading</th><th scope="col">Suggested after</th><th scope="col">Notes</th></tr></thead>
      <tbody>{supplementary}</tbody>
    </table>
  </section>
  <section id="improving-material" class="improving-material" aria-labelledby="improving-material-title">
    <h2 id="improving-material-title">Improving Material</h2>
    {paragraphs(prose['improving-intro'])}
    {paragraphs(prose['improving-body'])}
  </section>
  <section id="project" class="course-project" aria-labelledby="project-title">
    <h2 id="project-title">Project</h2>
    {paragraphs(prose['project-intro'])}
    <p id="fog-of-war-challenge">{rich_html(prose['project-fow']).strip()}</p>
    {paragraphs(prose['project-modeling'])}
    {paragraphs(prose['project-theory'])}
    {paragraphs(prose['project-grading'])}
  </section>
</section>
</div>
<aside class="course-sidebar" aria-label="Course details and teaching team">
<section class="course-details" aria-labelledby="details-title">
  <h2 id="details-title">Course information</h2>
  <dl><div><dt>Lectures</dt><dd>{escape(course['days'])}<br><span class="lecture-time">{escape(course['time'])}</span></dd></div><div><dt>Room</dt><dd>{escape(course['room'])}</dd></div></dl>
</section>
<section id="people" class="course-people" aria-label="Teaching team">
  <h2>Instructors</h2>
  <ul class="instructor-list">{instructors}</ul>
  <p class="office-hours">{escape(course['meetings'])}</p>
  <h2 id="ta-title">Teaching assistants</h2>
  <ul class="ta-list" aria-labelledby="ta-title">{tas}</ul>
</section>
<section class="course-repository" aria-labelledby="repository-title"><h2 id="repository-title"><a href="{escape(course['github'], quote=True)}">GitHub repository <span aria-hidden="true">↗</span></a></h2></section>
<section class="course-prerequisites" aria-labelledby="prerequisites-title"><h2 id="prerequisites-title">Prerequisites</h2>{paragraphs(prose['Prerequisites'])}</section>
<section class="course-work" aria-labelledby="work-title"><h2 id="work-title">Coursework</h2><ul class="grade-components">{grading}</ul>{paragraphs(prose['Coursework'])}{paragraphs(prose['Attendance'])}{paragraphs(prose['Lecture notes'])}<p>See the <a href="syllabus.pdf">syllabus</a> for collaboration and AI use policies.</p></section>
</aside>
</main>
<footer class="course-footer home-width"><p>{escape(site['event'])} · {escape(site['term'])}</p><a href="#main">Back to top ↑</a></footer>
</body></html>'''


if __name__ == '__main__':
    import argparse
    from hashlib import sha256
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resolve-only', action='store_true',
                        help='write .build/html-export.json for the note exporter, without rebuilding pages')
    args = parser.parse_args()
    config, modules = load_course()
    resolved_path = ROOT / '.build/html-export.json'
    resolved_path.parent.mkdir(exist_ok=True)
    resolved_path.write_text(json.dumps(config, indent=2) + '\n')
    if not args.resolve_only:
        stylesheet = ROOT / 'html/assets/course.css'
        stylesheet.parent.mkdir(parents=True, exist_ok=True)
        stylesheet.write_bytes((ROOT / 'html-exporter/src/course.css').read_bytes())
        copy_public_files(config, ROOT, ROOT / 'html')
        version = sha256(stylesheet.read_bytes()).hexdigest()[:12]
        (ROOT / 'html/index.html').write_text(render_index(config, modules, stylesheet_version=version))
        print('Updated html/index.html from the evaluated syllabus.')
    else:
        print('Resolved course configuration: .build/html-export.json')
