mod chapters;
mod math;
mod options;
mod permalinks;
mod svg_images;
mod svg_text;

use chapters::{ChapterNav, ExportConfig};
use math::MathMode;
use options::Config;
use regex::{Captures, Regex};
use scraper::{ElementRef, Html, Selector};
use std::collections::{BTreeSet, HashMap};
use std::env;
use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::{Mutex, OnceLock};
use typst::diag::{FileError, FileResult, SourceDiagnostic};
use typst::foundations::{Bytes, Datetime, Dict, Duration, IntoValue};
use typst::syntax::{FileId, RootedPath, Source, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook};
use typst::utils::LazyHash;
use typst::{Feature, Library, LibraryExt, World};
use typst_html::HtmlDocument;
use typst_kit::datetime::Time;
use typst_kit::downloader::SystemDownloader;
use typst_kit::files::{FsRoot, SystemFiles};
use typst_kit::fonts::{self, FontStore};
use typst_kit::packages::SystemPackages;

const PAGE_CSS: &str = include_str!("gabri-notes.css");
const DEFAULT_EVENT_NAME: &str = "MIT 6.7980";

fn main() {
    if let Err(err) = run() {
        eprintln!("error: {err}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let config = options::parse()?;
    if config.figure_svg {
        return compile_figure_svg(&config);
    }
    let export_config = load_export_config(&config)?;
    let raw_html = if let Some(path) = &config.from_html {
        fs::read_to_string(path)
            .map_err(|err| format!("could not read native HTML {}: {err}", path.display()))?
    } else {
        compile_typst_html(&config)?
    };
    let raw_html = svg_images::inline_selectable_svgs(&raw_html)?;
    let mut document = HtmlParts::parse(&raw_html);
    let title = config
        .title
        .clone()
        .or_else(|| document.meta.title.clone())
        .unwrap_or_else(|| title_from_path(&config.input));

    document.rewrite_heading_ids();
    document.rewrite_statement_ids();
    let (body_html, rendered_endnotes) =
        postprocess_body(document.body_html, &document.endnotes, config.math_mode)?;
    let (body_html, heading_ids) = permalinks::add_permalinks(&body_html);
    document.body_html = body_html;
    for heading in &mut document.headings {
        if let Some(id) = heading_ids.get(&heading.id) {
            heading.id = id.clone();
        }
    }
    document.rendered_endnotes = rendered_endnotes;

    let html = render_document(&config, &title, &document, export_config.as_ref());
    copy_referenced_assets(&config, &html)?;
    write_output(&config, html)?;
    Ok(())
}

fn load_export_config(config: &Config) -> Result<Option<ExportConfig>, String> {
    let Some(path) = &config.export_config else {
        return Ok(None);
    };
    let path = if path.is_absolute() {
        path.clone()
    } else {
        config.root.join(path)
    };
    ExportConfig::load(&path).map(Some)
}

fn compile_typst_html(config: &Config) -> Result<String, String> {
    let world = LocalWorld::new(&config.input, &config.root, config.math_mode, None)?;
    let warned = typst::compile::<HtmlDocument>(&world);
    for warning in &warned.warnings {
        eprintln!("typst warning: {}", format_diagnostic(warning));
    }
    let document = warned
        .output
        .map_err(|errors| format_diagnostics("Typst HTML compilation failed", &errors))?;
    typst_html::html(&document, &typst_html::HtmlOptions { pretty: true })
        .map_err(|errors| format_diagnostics("Typst HTML encoding failed", &errors))
}

fn compile_figure_svg(config: &Config) -> Result<(), String> {
    let world = LocalWorld::new(
        &config.input, &config.root, config.math_mode, Some(&config.figure_inputs),
    )?;
    let warned = typst::compile::<typst_layout::PagedDocument>(&world);
    for warning in &warned.warnings {
        eprintln!("typst warning: {}", format_diagnostic(warning));
    }
    let document = warned.output
        .map_err(|errors| format_diagnostics("Figure compilation failed", &errors))?;
    if document.pages().len() != 1 {
        return Err("a standalone SVG figure must contain exactly one page".into());
    }
    write_output(config, svg_text::render(&document.pages()[0]))?;
    if let Some(path) = &config.figure_deps {
        let inputs = world.dependencies.lock().unwrap();
        let json = serde_json::json!({"inputs": *inputs});
        fs::write(path, json.to_string())
            .map_err(|err| format!("could not write figure dependencies: {err}"))?;
    }
    Ok(())
}

struct LocalWorld {
    main: FileId,
    root: PathBuf,
    library: LazyHash<Library>,
    fonts: FontStore,
    files: SystemFiles,
    time: Time,
    html_notes: bool,
    dependencies: Mutex<BTreeSet<PathBuf>>,
}

impl LocalWorld {
    fn new(input: &Path, root: &Path, math_mode: MathMode, figure_inputs: Option<&[String]>) -> Result<Self, String> {
        let root = root
            .canonicalize()
            .map_err(|err| format!("could not canonicalize root {}: {err}", root.display()))?;
        let input = if input.is_absolute() {
            input.to_path_buf()
        } else {
            env::current_dir()
                .map_err(|err| format!("could not read current directory: {err}"))?
                .join(input)
        };
        let input = input
            .canonicalize()
            .map_err(|err| format!("could not canonicalize input {}: {err}", input.display()))?;
        let main_path = VirtualPath::virtualize(&root, &input).map_err(|_| {
            format!(
                "input {} is outside root {}",
                input.display(),
                root.display()
            )
        })?;
        let main = RootedPath::new(VirtualRoot::Project, main_path).intern();

        let mut inputs = Dict::new();
        inputs.insert("html-math".into(), math_mode.as_typst_input().into_value());
        if let Some(figure_inputs) = figure_inputs {
            for input in figure_inputs {
                let (key, value) = input.split_once('=')
                    .ok_or_else(|| format!("expected figure input key=value, got {input:?}"))?;
                inputs.insert(key.into(), value.into_value());
            }
            inputs.insert("figure-format".into(), "html".into_value());
        }
        let features = [Feature::Html].into_iter().collect();
        let library = Library::builder()
            .with_inputs(inputs)
            .with_features(features)
            .build();

        let mut fonts = FontStore::new();
        fonts.extend(fonts::system());
        fonts.extend(fonts::scan(&root.join("html-exporter/assets/fonts")));
        if let Some(paths) = env::var_os("TYPST_FONT_PATHS") {
            for path in env::split_paths(&paths) {
                fonts.extend(fonts::scan(&path));
            }
        }
        fonts.extend(fonts::embedded());
        let packages = SystemPackages::new(SystemDownloader::new("notes-html-exporter/0.1"));
        let files = SystemFiles::new(FsRoot::new(root.clone()), packages);
        let time = match env::var("SOURCE_DATE_EPOCH") {
            Ok(value) => {
                Time::fixed_timestamp(value.parse().map_err(|_| "invalid SOURCE_DATE_EPOCH")?)
                    .map_err(|err| err.to_string())?
            }
            Err(_) => Time::system(),
        };

        Ok(Self {
            main,
            root,
            library: LazyHash::new(library),
            fonts,
            files,
            time,
            html_notes: figure_inputs.is_none(),
            dependencies: Mutex::new(BTreeSet::new()),
        })
    }

    fn system_path(&self, id: FileId) -> FileResult<PathBuf> {
        self.files.resolve(id)
    }

    fn read_bytes(&self, id: FileId) -> FileResult<Vec<u8>> {
        let path = self.system_path(id)?;
        self.dependencies.lock().unwrap().insert(path.clone());
        Self::read_path_bytes(&path)
    }

    fn read_path_bytes(path: &Path) -> FileResult<Vec<u8>> {
        let file_error = |err| FileError::from_io(err, &path);
        if fs::metadata(&path).map_err(file_error)?.is_dir() {
            Err(FileError::IsDirectory)
        } else {
            fs::read(&path).map_err(file_error)
        }
    }
}

impl World for LocalWorld {
    fn library(&self) -> &LazyHash<Library> {
        &self.library
    }

    fn book(&self) -> &LazyHash<FontBook> {
        self.fonts.book()
    }

    fn main(&self) -> FileId {
        self.main
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        let bytes = self.read_bytes(id)?;
        let bytes = bytes.strip_prefix(b"\xef\xbb\xbf").unwrap_or(&bytes);
        let text = std::str::from_utf8(bytes)?;
        let text = if self.html_notes && matches!(id.root(), VirtualRoot::Project) {
            use_html_notes_style(text)
        } else {
            text.to_owned()
        };
        Ok(Source::new(id, text.into()))
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        if self.html_notes && matches!(id.root(), VirtualRoot::Project) {
            let source = self.system_path(id)?;
            if let Some(variant) = html_figure_path(&self.root, &source) {
                // Keep the authored FileId so image.source and figure markers
                // retain their stable source paths while the glyphs match HTML.
                let bytes = Self::read_path_bytes(&variant).map_err(|err| match err {
                    FileError::NotFound(_) => FileError::Other(Some(
                        format!(
                            "missing HTML figure {}; run `make figures` before exporting HTML",
                            variant.display()
                        )
                        .into(),
                    )),
                    err => err,
                })?;
                return Ok(Bytes::new(bytes));
            }
        }
        Ok(Bytes::new(self.read_bytes(id)?))
    }

    fn font(&self, index: usize) -> Option<Font> {
        if let Some(source) = self.fonts.source(index) {
            if let Some(path) = (source as &dyn std::any::Any).downcast_ref::<fonts::FontPath>() {
                self.dependencies.lock().unwrap().insert(path.path.clone());
            }
        }
        self.fonts.font(index)
    }

    fn today(&self, offset: Option<Duration>) -> Option<Datetime> {
        self.time.today(offset)
    }
}

fn html_figure_path(root: &Path, source: &Path) -> Option<PathBuf> {
    let relative = source.strip_prefix(root.join("content/figures")).ok()?;
    if source.extension().and_then(|extension| extension.to_str()) != Some("svg") {
        return None;
    }
    let has_source = source.with_extension("typ").is_file()
        || (source
            .file_stem()
            .and_then(|stem| stem.to_str())
            .is_some_and(|stem| stem.starts_with("gate_"))
            && source.with_file_name("gate.typ").is_file());
    has_source.then(|| root.join(".build/html-figures").join(relative))
}

fn format_diagnostics(prefix: &str, diagnostics: &[SourceDiagnostic]) -> String {
    let mut out = String::from(prefix);
    for diagnostic in diagnostics {
        out.push('\n');
        out.push_str(&format_diagnostic(diagnostic));
    }
    out
}

fn format_diagnostic(diagnostic: &SourceDiagnostic) -> String {
    let mut out = diagnostic.message.to_string();
    for hint in &diagnostic.hints {
        write!(out, "\n  hint: {}", hint.v).unwrap();
    }
    out
}

fn use_html_notes_style(source: &str) -> String {
    source
        .replace(
            r#"#import "meta/gabri_notes.typ": *"#,
            r#"#import "meta/gabri_notes_html.typ": *"#,
        )
        .replace(
            r#"#import "/content/meta/gabri_notes.typ": *"#,
            r#"#import "/content/meta/gabri_notes_html.typ": *"#,
        )
}

#[derive(Clone, Debug)]
struct Heading {
    level: u8,
    raw_id: Option<String>,
    #[allow(dead_code)]
    text: String,
    title_html: String,
    id: String,
    number: String,
}

#[derive(Clone, Debug)]
struct StatementAnchor {
    raw_id: Option<String>,
    id: String,
}

struct HtmlParts {
    meta: DocumentMeta,
    header_html: String,
    body_html: String,
    headings: Vec<Heading>,
    endnotes: Vec<Endnote>,
    rendered_endnotes: Vec<RenderedEndnote>,
}

impl HtmlParts {
    fn parse(raw_html: &str) -> Self {
        let dom = Html::parse_document(raw_html);
        let body_html = select_first(&dom, "body")
            .map(|body| body.inner_html())
            .unwrap_or_else(|| raw_html.to_owned());
        let cleaned_dom = Html::parse_document(&format!("<html><body>{body_html}</body></html>"));
        let meta = extract_document_meta(&cleaned_dom);
        let header_html = select_first(&cleaned_dom, ".lecture-metadata")
            .map(|header| header.html())
            .unwrap_or_default();
        let body_html = if header_html.is_empty() {
            body_html
        } else {
            body_html.replacen(&header_html, "", 1)
        };
        let headings = extract_headings(&cleaned_dom);
        let endnotes = extract_endnotes(&cleaned_dom);
        Self {
            meta,
            header_html,
            body_html,
            headings,
            endnotes,
            rendered_endnotes: Vec::new(),
        }
    }

    fn rewrite_heading_ids(&mut self) {
        let mut heading_idx = 0usize;
        let mut link_targets = HashMap::new();
        self.body_html = re_html_heading()
            .replace_all(&self.body_html, |captures: &Captures| {
                let whole = captures.get(0).map_or("", |m| m.as_str());
                let level = captures.name("level").map_or("1", |m| m.as_str());
                let attrs = captures.name("attrs").map_or("", |m| m.as_str());
                let inner = captures.name("inner").map_or("", |m| m.as_str());
                if !attrs_has_class(attrs, "notes-heading")
                    || attrs_has_class(attrs, "notes-heading-unnumbered")
                {
                    return whole.to_owned();
                }
                let Some(heading) = self.headings.get(heading_idx) else {
                    return whole.to_owned();
                };
                heading_idx += 1;
                if let Some(raw_id) = &heading.raw_id {
                    if raw_id != &heading.id {
                        link_targets.insert(raw_id.clone(), format!("#{}", heading.id));
                    }
                }
                format!(
                    "<h{level}{}>{inner}</h{level}>",
                    set_id_attr(attrs, &heading.id)
                )
            })
            .to_string();
        self.rewrite_local_links(&link_targets);
    }

    fn rewrite_statement_ids(&mut self) {
        let anchors = collect_statement_anchors(&self.body_html);
        let mut statement_idx = 0usize;
        self.body_html = re_html_section()
            .replace_all(&self.body_html, |captures: &Captures| {
                let whole = captures.get(0).map_or("", |m| m.as_str());
                let attrs = captures.name("attrs").map_or("", |m| m.as_str());
                if !attrs_has_class(attrs, "env") || !attrs_has_class(attrs, "statement") {
                    return whole.to_owned();
                }
                let Some(anchor) = anchors.get(statement_idx) else {
                    return whole.to_owned();
                };
                statement_idx += 1;
                // Native bundle links in other pages already point at raw_id.
                // Preserve it; retain the old numbered URL as a local alias.
                let id = anchor.raw_id.as_ref().unwrap_or(&anchor.id);
                let mut start = format!("<section{}>", set_id_attr(attrs, id));
                if id != &anchor.id {
                    write!(start, "<span id=\"{}\"></span>", escape_attr(&anchor.id)).unwrap();
                }
                start
            })
            .to_string();
    }

    fn rewrite_local_links(&mut self, targets: &HashMap<String, String>) {
        self.body_html = rewrite_href_targets(self.body_html.clone(), targets);
        // Footnotes are extracted before heading/statement IDs become stable.
        for note in &mut self.endnotes {
            note.body_html = rewrite_href_targets(note.body_html.clone(), targets);
        }
    }
}

#[derive(Clone, Default)]
struct DocumentMeta {
    lecture_number: Option<String>,
    title: Option<String>,
}

#[derive(Clone)]
struct Endnote {
    id: String,
    label: String,
    body_html: String,
}

#[derive(Clone)]
struct RenderedEndnote {
    number: String,
    body_html: String,
}

fn extract_document_meta(dom: &Html) -> DocumentMeta {
    let selector = Selector::parse(".notes-meta").unwrap();
    let Some(element) = dom.select(&selector).next() else {
        return DocumentMeta::default();
    };
    DocumentMeta {
        lecture_number: non_empty_attr(&element, "data-lecture-number"),
        title: non_empty_attr(&element, "data-title"),
    }
}

fn extract_headings(dom: &Html) -> Vec<Heading> {
    let selector = Selector::parse("body h1, body h2, body h3, body h4, body h5, body h6").unwrap();
    let secno_selector = Selector::parse(".secno").unwrap();
    let mut headings = Vec::new();

    for element in dom.select(&selector) {
        let class = element.value().attr("class").unwrap_or_default();
        if !class.split_whitespace().any(|name| name == "notes-heading")
            || class
                .split_whitespace()
                .any(|name| name == "notes-heading-unnumbered")
        {
            continue;
        }
        let raw_id = element.value().attr("id").map(str::to_owned);
        let level = element
            .value()
            .attr("data-level")
            .and_then(|level| level.parse::<u8>().ok())
            .or_else(|| {
                element
                    .value()
                    .name()
                    .strip_prefix('h')
                    .and_then(|level| level.parse::<u8>().ok())
            })
            .unwrap_or(1);
        let number = element
            .value()
            .attr("data-number")
            .map(normalize_ws)
            .filter(|number| !number.is_empty())
            .or_else(|| {
                element
                    .select(&secno_selector)
                    .next()
                    .map(|secno| normalize_ws(&secno.text().collect::<Vec<_>>().join(" ")))
            })
            .unwrap_or_default();
        let title_html = heading_title_html(&element);
        let text = heading_text_from_html(&title_html);
        let id = raw_id
            .clone()
            .unwrap_or_else(|| slugify(&format!("{number}-{text}")));
        headings.push(Heading {
            level,
            raw_id,
            id,
            number,
            text,
            title_html,
        });
    }

    headings
}

fn heading_title_html(element: &ElementRef) -> String {
    let title = re_heading_secno_span()
        .replace(&element.inner_html(), "")
        .trim()
        .to_owned();
    // The TOC wraps this title in its own link. Keep formatting and math,
    // but remove inner links to avoid invalid nested anchors and stale loc-IDs.
    static ANCHOR_TAG: OnceLock<Regex> = OnceLock::new();
    ANCHOR_TAG
        .get_or_init(|| Regex::new(r"</?a\b[^>]*>").unwrap())
        .replace_all(&title, "")
        .to_string()
}

fn heading_text_from_html(html: &str) -> String {
    let fragment = Html::parse_fragment(&html);
    normalize_ws(&fragment.root_element().text().collect::<Vec<_>>().join(" "))
}

fn non_empty_attr(element: &ElementRef, name: &str) -> Option<String> {
    element
        .value()
        .attr(name)
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(str::to_owned)
}

fn current_chapter(config: &Config, chapters: &ExportConfig) -> Option<usize> {
    chapters.current_index_for_input(&config.input)
}

fn extract_endnotes(dom: &Html) -> Vec<Endnote> {
    let item_selector = Selector::parse("section[role=\"doc-endnotes\"] li").unwrap();
    let template_selector = Selector::parse("template.notes-html-footnote-body").unwrap();
    let sup_selector = Selector::parse("sup").unwrap();
    let mut notes = Vec::new();

    for item in dom.select(&item_selector) {
        let Some(id) = item.value().attr("id") else {
            continue;
        };
        let label = item
            .select(&sup_selector)
            .next()
            .map(|sup| normalize_ws(&sup.text().collect::<Vec<_>>().join(" ")))
            .unwrap_or_else(|| (notes.len() + 1).to_string());
        let body_html = re_endnote_backlink()
            .replace(&item.inner_html(), "")
            .trim()
            .to_owned();
        notes.push(Endnote {
            id: id.to_owned(),
            label,
            body_html,
        });
    }

    for template in dom.select(&template_selector) {
        let Some(id) = template.value().attr("id") else {
            continue;
        };
        let label = template
            .value()
            .attr("data-note-label")
            .map(str::trim)
            .filter(|label| !label.is_empty())
            .map(str::to_owned)
            .unwrap_or_else(|| (notes.len() + 1).to_string());
        notes.push(Endnote {
            id: id.to_owned(),
            label,
            body_html: template.inner_html().trim().to_owned(),
        });
    }

    notes
}

fn select_first<'a>(dom: &'a Html, selector: &str) -> Option<ElementRef<'a>> {
    let selector = Selector::parse(selector).ok()?;
    dom.select(&selector).next()
}

fn collect_statement_anchors(body: &str) -> Vec<StatementAnchor> {
    let dom = Html::parse_fragment(body);
    let selector = Selector::parse("section.env.statement").unwrap();
    let mut anchors = Vec::new();

    for element in dom.select(&selector) {
        let Some(anchor) = stable_statement_id(&element) else {
            continue;
        };
        anchors.push(StatementAnchor {
            raw_id: element.value().attr("id").map(str::to_owned),
            id: anchor,
        });
    }

    anchors
}

fn stable_statement_id(element: &ElementRef<'_>) -> Option<String> {
    let kind_selector = Selector::parse(".env-kind").unwrap();
    let number_selector = Selector::parse(".env-number").unwrap();
    let kind = element
        .select(&kind_selector)
        .next()
        .map(|kind| element_text(&kind))
        .filter(|kind| !kind.is_empty())?;
    let number = element
        .select(&number_selector)
        .next()
        .map(|number| element_text(&number))
        .filter(|number| !number.is_empty())?;
    Some(slugify(&format!("{kind} {number}")))
}

fn attrs_has_class(attrs: &str, class_name: &str) -> bool {
    re_class_attr()
        .captures(attrs)
        .and_then(|captures| captures.get(1))
        .is_some_and(|classes| {
            classes
                .as_str()
                .split_whitespace()
                .any(|class| class == class_name)
        })
}

fn element_text(element: &ElementRef<'_>) -> String {
    normalize_ws(&element.text().collect::<Vec<_>>().join(" "))
}

fn rewrite_href_targets(body: String, targets: &HashMap<String, String>) -> String {
    if targets.is_empty() {
        return body;
    }
    re_href()
        .replace_all(&body, |captures: &Captures| {
            let whole = captures.get(0).map_or("", |m| m.as_str());
            let id = captures.get(1).map_or("", |m| m.as_str());
            targets
                .get(id)
                .map(|target| format!("href=\"{}\"", escape_attr(target)))
                .unwrap_or_else(|| whole.to_owned())
        })
        .to_string()
}

fn postprocess_body(
    body_html: String,
    endnotes: &[Endnote],
    math_mode: MathMode,
) -> Result<(String, Vec<RenderedEndnote>), String> {
    let mut body = body_html;
    body = re_notes_meta().replace_all(&body, "").to_string();
    body = re_hidden_bibliography().replace_all(&body, "").to_string();
    body = re_endnotes_section().replace_all(&body, "").to_string();
    body = re_html_footnote_template()
        .replace_all(&body, "")
        .to_string();
    body = re_empty_hidden_div().replace_all(&body, "").to_string();
    body = normalize_typst_classes(body);
    body = math::postprocess_html_math(body, math_mode);
    body = render_raw_tex_inline_symbols(body);
    let (body, bibliography_blocks) = protect_visible_bibliographies(body);
    let body = restore_visible_bibliographies(body, bibliography_blocks);
    let body = unwrap_generated_biblioref_links(body);
    Ok(rewrite_footnotes(body, endnotes, math_mode))
}

fn render_raw_tex_inline_symbols(body: String) -> String {
    body.replace(
        r"\Phi-",
        r#"<span class="math-katex-source" data-math-display="inline" data-typst-math="[Φ]" role="math">\(\Phi\)</span>-"#,
    )
}

fn normalize_typst_classes(mut body: String) -> String {
    body = body.replace(
        "<figure role=\"math\"",
        "<figure class=\"equation\" role=\"math\"",
    );
    body = re_typst_figure_class()
        .replace_all(&body, "${prefix}rendered-figure typst${suffix}")
        .to_string();
    body
}

fn protect_visible_bibliographies(body: String) -> (String, Vec<String>) {
    let mut blocks = Vec::new();
    let body = re_visible_bibliography()
        .replace_all(&body, |captures: &Captures| {
            let index = blocks.len();
            let block = captures.get(0).map_or("", |m| m.as_str());
            blocks.push(clean_visible_bibliography(block));
            format!("<!--NOTES_HTML_BIBLIOGRAPHY_{index}-->")
        })
        .to_string();
    (body, blocks)
}

fn restore_visible_bibliographies(mut body: String, blocks: Vec<String>) -> String {
    for (index, block) in blocks.into_iter().enumerate() {
        body = body.replace(&format!("<!--NOTES_HTML_BIBLIOGRAPHY_{index}-->"), &block);
    }
    body
}

fn clean_visible_bibliography(block: &str) -> String {
    math::normalize_bibliography_math(block)
}

fn unwrap_generated_biblioref_links(body: String) -> String {
    static PREFIX: OnceLock<Regex> = OnceLock::new();
    re_doc_biblioref_link()
        .replace_all(&body, |captures: &Captures| {
            let whole = captures.get(0).map_or("", |m| m.as_str());
            let attrs = captures.name("attrs").map_or("", |m| m.as_str());
            if !attrs.contains(r#"role="doc-biblioref""#)
                || attrs.contains("citation")
                || !extract_href_attr(attrs).is_some_and(|href| href.starts_with('#'))
            {
                whole.to_owned()
            } else {
                let inner = captures.name("inner").map_or("", |m| m.as_str());
                // Typst 0.15 full citations repeat the alphanumeric key.
                // Our visible bibliography/sidenote already supplies that key.
                PREFIX
                    .get_or_init(|| Regex::new(r"^\[[^\]\n<]{1,40}\]").unwrap())
                    .replace(inner, "")
                    .to_string()
            }
        })
        .to_string()
}

fn rewrite_footnote_link_labels(body: &str) -> String {
    re_anchor_link()
        .replace_all(body, |captures: &Captures| {
            let whole = captures.get(0).map_or("", |m| m.as_str());
            let attrs = captures.name("attrs").map_or("", |m| m.as_str());
            if attrs.contains("bibliography-link") {
                return whole.to_owned();
            }
            let Some(href) = extract_href_attr(attrs) else {
                return whole.to_owned();
            };
            let Some(label) = site_label_from_href(href) else {
                return whole.to_owned();
            };
            format!("<a{}>{}</a>", attrs, escape_html(&label))
        })
        .to_string()
}

fn inline_footnote_body(body: &str) -> String {
    let without_opening_paragraphs = re_open_paragraph_tag().replace_all(body, "");
    let inline = re_close_paragraph_tag().replace_all(&without_opening_paragraphs, " ");
    inline.trim().to_owned()
}

fn site_label_from_href(href: &str) -> Option<String> {
    let href = href.trim();
    let rest = href
        .strip_prefix("https://")
        .or_else(|| href.strip_prefix("http://"))?;
    let host = rest
        .split(['/', '?', '#'])
        .next()
        .unwrap_or_default()
        .rsplit('@')
        .next()
        .unwrap_or_default()
        .split(':')
        .next()
        .unwrap_or_default()
        .trim_end_matches('.')
        .to_ascii_lowercase();
    if host.is_empty() {
        return None;
    }
    if host.ends_with("wikipedia.org") {
        return Some("wikipedia".to_owned());
    }
    if host.ends_with("nytimes.com") {
        return Some("NY Times".to_owned());
    }
    if host.ends_with("doi.org") {
        return Some("DOI".to_owned());
    }

    let trimmed = strip_common_subdomains(&host);
    let parts = trimmed.split('.').collect::<Vec<_>>();
    let base = match parts.as_slice() {
        [] => return None,
        [only] => *only,
        [.., third_last, second_last, last]
            if last.len() == 2
                && matches!(
                    *second_last,
                    "ac" | "co" | "com" | "edu" | "gov" | "net" | "org"
                ) =>
        {
            *third_last
        }
        [.., second_last, _] => *second_last,
    };
    let label = base.replace('-', " ");
    if label.is_empty() {
        None
    } else {
        Some(label)
    }
}

fn strip_common_subdomains(host: &str) -> &str {
    let mut rest = host;
    for prefix in ["www.", "m.", "mobile.", "en."] {
        if let Some(stripped) = rest.strip_prefix(prefix) {
            rest = stripped;
        }
    }
    rest
}

fn rewrite_footnotes(
    body: String,
    endnotes: &[Endnote],
    math_mode: MathMode,
) -> (String, Vec<RenderedEndnote>) {
    let by_id = endnotes
        .iter()
        .map(|note| (note.id.as_str(), note))
        .collect::<HashMap<_, _>>();
    let mut rendered = Vec::new();
    let mut next = 1usize;

    let body = re_noteref()
        .replace_all(&body, |captures: &Captures| {
            let attrs = captures.get(1).map_or("", |m| m.as_str());
            let fallback_label = captures.get(2).map_or("", |m| m.as_str());
            let Some(href) = extract_href(attrs) else {
                return captures.get(0).unwrap().as_str().to_owned();
            };
            let Some(note) = by_id.get(href) else {
                return captures.get(0).unwrap().as_str().to_owned();
            };
            let number = if note.label.is_empty() {
                next.to_string()
            } else {
                note.label.clone()
            };
            let seq = next;
            next += 1;
            let body_html = math::postprocess_html_math(
                inline_footnote_body(&rewrite_footnote_link_labels(&note.body_html)),
                math_mode,
            );
            let body_html = unwrap_generated_biblioref_links(body_html);
            rendered.push(RenderedEndnote {
                number: number.clone(),
                body_html: body_html.clone(),
            });
            format!(
                "<sup class=\"footnote-ref\" id=\"fnref-{seq}\"><a href=\"#fn-end-{seq}\">{}</a></sup><span class=\"footnote\" id=\"fn-side-{seq}\"><span class=\"footnote-num\">{}</span>{}</span>",
                escape_html(if number.is_empty() { fallback_label } else { &number }),
                escape_html(&number),
                body_html
            )
        })
        .to_string();

    (body, rendered)
}

fn render_document(
    config: &Config,
    title: &str,
    document: &HtmlParts,
    export_config: Option<&ExportConfig>,
) -> String {
    let current = export_config.and_then(|export_config| current_chapter(config, export_config));
    let browser_title = if let (Some(export_config), Some(current)) = (export_config, current) {
        format!(
            "{} · {} · {}",
            export_config
                .site
                .event
                .as_deref()
                .unwrap_or(DEFAULT_EVENT_NAME),
            export_config.chapters[current].course_label(),
            title
        )
    } else if let Some(number) = &document.meta.lecture_number {
        format!("{DEFAULT_EVENT_NAME} · Lecture {number} · {title}")
    } else {
        title.to_owned()
    };
    let mut html = String::new();
    html.push_str("<!doctype html>\n<html lang=\"en\">\n<head>\n");
    html.push_str("  <meta charset=\"utf-8\">\n");
    html.push_str("  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n");
    html.push_str(math::katex_head_assets(config.math_mode));
    write!(html, "  <title>{}</title>\n", escape_html(&browser_title)).unwrap();
    html.push_str("  <style>\n");
    html.push_str(PAGE_CSS);
    html.push_str("\n  </style>\n");
    html.push_str(math::katex_script_assets(config.math_mode));
    html.push_str("</head>\n<body>\n");

    if let (Some(export_config), Some(current)) = (export_config, current) {
        html.push_str(&render_chapter_rail(
            export_config,
            current,
            &document.headings,
            config,
        ));
    } else {
        html.push_str(&render_masthead(config));
    }

    html.push_str("<main class=\"page-shell\">\n<article class=\"lecture-content\"");
    if let Some(number) = &document.meta.lecture_number {
        write!(html, " data-lecture-number=\"{}\"", escape_attr(number)).unwrap();
    }
    html.push_str(">\n");
    if let (Some(export_config), Some(_)) = (export_config, current) {
        if let Some(index) = export_config
            .site
            .index_href
            .as_ref()
            .or(config.index_href.as_ref())
        {
            write!(html,
                "<nav class=\"compact-course-nav\" aria-label=\"Course\"><a href=\"{}\">← Course home · {}</a></nav>\n",
                escape_attr(index), escape_html(export_config.site.event.as_deref().unwrap_or(DEFAULT_EVENT_NAME))).unwrap();
        }
    }
    if let (Some(export_config), Some(current)) = (export_config, current) {
        html.push_str(&render_chapter_citation_sidenote(
            export_config,
            &export_config.chapters[current],
            title,
            &config.site_title,
            config.pdf_href.as_deref(),
        ));
    }
    if let (Some(export_config), Some(current)) = (export_config, current) {
        write!(
            html,
            "<p class=\"lecture-kicker\">{}</p>\n",
            escape_html(&export_config.chapters[current].course_label())
        )
        .unwrap();
    }
    write!(
        html,
        "<h1 class=\"lecture-title\">{}</h1>\n",
        escape_html(title)
    )
    .unwrap();
    html.push_str(&document.header_html);
    if !document.headings.is_empty() {
        html.push_str(&render_toc(&document.headings, config.math_mode));
    }
    html.push_str(&document.body_html);
    html.push_str(&render_endnotes(&document.rendered_endnotes));
    html.push_str("<noscript><style>.endnotes { display: block }</style></noscript>\n");
    html.push_str("</article>\n</main>\n");
    if current.is_some() {
        html.push_str(chapter_nav_script());
        html.push_str(chapter_citation_script());
    }
    html.push_str(equation_width_script());
    html.push_str("<script>\n");
    html.push_str(include_str!("sidenotes.js"));
    html.push_str("</script>\n");
    html.push_str(settled_hash_scroll_script());
    html.push_str("</body>\n</html>\n");
    html
}

fn render_masthead(config: &Config) -> String {
    let mut out = String::from("<header class=\"site-masthead\">\n");
    if let Some(index) = &config.index_href {
        write!(
            out,
            "<a class=\"course-title course-title-link\" href=\"{}\">{}</a>\n",
            escape_attr(index),
            escape_html(&config.site_title)
        )
        .unwrap();
    } else {
        write!(
            out,
            "<div class=\"course-title\">{}</div>\n",
            escape_html(&config.site_title)
        )
        .unwrap();
    }
    write!(
        out,
        "<div class=\"course-authors\">{}</div>\n",
        escape_html(&config.authors)
    )
    .unwrap();
    if config.index_href.is_some() || config.pdf_href.is_some() {
        out.push_str("<div class=\"top-links\">");
        if let Some(index) = &config.index_href {
            write!(out, "<a href=\"{}\">Index</a>", escape_attr(index)).unwrap();
        }
        if let Some(pdf) = &config.pdf_href {
            write!(out, "<a href=\"{}\">PDF</a>", escape_attr(pdf)).unwrap();
        }
        out.push_str("</div>");
    }
    out.push_str("</header>\n");
    out
}

fn render_chapter_citation_sidenote(
    export_config: &ExportConfig,
    chapter: &ChapterNav,
    title: &str,
    _site_title: &str,
    pdf_href: Option<&str>,
) -> String {
    let citation = &export_config.how_to_cite;
    let key = format!("{}-lecture-{}", citation.key_prefix, chapter.number);
    let href = chapter.href().expect("lecture href was validated");
    let citation_url = citation.citation_url(&href);
    let citation_title = citation.citation_title(&chapter.number, title);
    let citation_note = citation
        .citation_note(&chapter.number, title)
        .map(|note| format!("  note = {{{}}},\n", bibtex_escape(&note)))
        .unwrap_or_default();
    let bibtex = format!(
        "@misc{{{key},\n  author = {{{}}},\n  title = {{{}}},\n  booktitle = {{{}}},\n{}  year = {{{}}},\n  url = {{{}}}\n}}",
        citation.authors,
        bibtex_escape(&citation_title),
        bibtex_escape(&citation.booktitle),
        citation_note,
        citation.year,
        citation_url
    );
    let mut out = String::from(
        "<aside class=\"lecture-citation-sidenote\" aria-label=\"Lecture links and citation\">",
    );
    if let Some(pdf) = pdf_href {
        write!(
            out,
            "<a class=\"lecture-citation-link lecture-citation-pdf\" href=\"{}\">Download as PDF</a>",
            escape_attr(pdf)
        )
        .unwrap();
    }
    if let Some(repository) = &export_config.site.github {
        write!(
            out,
            "<a class=\"lecture-citation-link lecture-citation-github\" href=\"{}\" aria-label=\"View Typst source on GitHub\">{}View source</a>",
            escape_attr(&chapter_source_href(repository, chapter)),
            github_icon_svg()
        )
        .unwrap();
    }
    write!(
        out,
        "<details class=\"lecture-citation-details\">\
         <summary class=\"lecture-citation-title\">How to cite</summary>\
         <pre><code>{}</code></pre>\
         </details>\
         </aside>\n",
        escape_html(&bibtex)
    )
    .unwrap();
    out
}

fn chapter_source_href(repository: &str, chapter: &ChapterNav) -> String {
    let mut href = format!("{}/blob/main/", repository.trim_end_matches('/'));
    for byte in chapter.source.bytes() {
        if byte.is_ascii_alphanumeric() || b"-._~/".contains(&byte) {
            href.push(char::from(byte));
        } else {
            write!(href, "%{byte:02X}").unwrap();
        }
    }
    href
}

fn github_icon_svg() -> &'static str {
    r#"<svg aria-hidden="true" viewBox="0 0 16 16" width="16" height="16"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82A7.5 7.5 0 0 1 8 3.86c.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z"></path></svg>"#
}

fn render_chapter_rail(
    export_config: &ExportConfig,
    current: usize,
    headings: &[Heading],
    config: &Config,
) -> String {
    let mut out = String::from("<nav class=\"lecture-rail\" aria-label=\"Lecture notes\">\n");
    let event = export_config
        .site
        .event
        .as_deref()
        .unwrap_or(DEFAULT_EVENT_NAME);
    let eyebrow = match export_config.site.term.as_deref() {
        Some(term) => format!("{event} · {term}"),
        None => event.to_owned(),
    };
    let title = export_config
        .site
        .title
        .as_deref()
        .unwrap_or(&config.site_title);
    let authors = export_config
        .site
        .authors
        .as_deref()
        .unwrap_or(&config.authors);
    let index_href = export_config
        .site
        .index_href
        .as_deref()
        .or(config.index_href.as_deref());

    out.push_str("<div class=\"lecture-rail-course\">");
    if let Some(index) = index_href {
        write!(
            out,
            "<a class=\"course-event\" href=\"{}\">{}</a>",
            escape_attr(index),
            escape_html(&eyebrow)
        )
        .unwrap();
    } else {
        write!(
            out,
            "<div class=\"course-event\">{}</div>",
            escape_html(&eyebrow)
        )
        .unwrap();
    }
    if let Some(index) = index_href {
        write!(
            out,
            "<a class=\"course-title course-title-link\" href=\"{}\">{}</a>",
            escape_attr(index),
            escape_html(title)
        )
        .unwrap();
    } else {
        write!(
            out,
            "<div class=\"course-title\">{}</div>",
            escape_html(title)
        )
        .unwrap();
    }
    writeln!(
        out,
        "<div class=\"course-authors\">{}</div></div>",
        escape_html(authors)
    )
    .unwrap();
    out.push_str("<div class=\"lecture-browser\">\n");
    if export_config.chapters.iter().any(|chapter| !chapter.supplementary) {
        out.push_str("<div class=\"lecture-rail-heading\">Lectures</div>\n");
    }
    out.push_str("<div class=\"lecture-browser-list\" role=\"region\" aria-label=\"Lectures and supplementary readings\" tabindex=\"0\">\n");
    for (supplementary, label) in [(false, "Lectures"), (true, "Supplementary readings")] {
        if !export_config
            .chapters
            .iter()
            .any(|chapter| chapter.supplementary == supplementary)
        {
            continue;
        }
        if supplementary {
            writeln!(out, "<div class=\"lecture-rail-heading lecture-rail-section-heading\">{label}</div>").unwrap();
        }
        for (idx, chapter) in export_config
            .chapters
            .iter()
            .enumerate()
            .filter(|(_, chapter)| chapter.supplementary == supplementary)
        {
            let class = if idx == current {
                "lecture-rail-link is-current"
            } else {
                "lecture-rail-link"
            };
            let aria = if idx == current {
                " aria-current=\"page\""
            } else {
                ""
            };
            writeln!(
                out,
                "<a class=\"{}\" href=\"{}\"{}><span>{}</span>{}</a>",
                class,
                escape_attr(&chapter.href().expect("lecture href was validated")),
                aria,
                chapter.navigation_number(),
                escape_html(&chapter.short_title)
            )
            .unwrap();
        }
    }
    out.push_str("</div>\n<div class=\"lecture-scroll-hint\" aria-hidden=\"true\" hidden>Scroll for more ↓</div>\n</div>\n");
    if !headings.is_empty() {
        out.push_str("<div class=\"lecture-rail-heading\">In this lecture</div>\n<div class=\"lecture-outline\">\n");
        let mut remaining = headings;
        while let Some((heading, rest)) = remaining.split_first() {
            let child_count = rest
                .iter()
                .take_while(|child| child.level > heading.level)
                .count();
            let (children, rest) = rest.split_at(child_count);
            if children.is_empty() {
                out.push_str(&render_rail_section_link(heading, config.math_mode));
            } else {
                write!(
                    out,
                    "<details class=\"lecture-section-group\" open><summary aria-label=\"{}\">{}</summary>\n<div class=\"lecture-subsections\">\n",
                    escape_attr(&format!("Subsections for {}", heading.text)),
                    render_rail_section_link(heading, config.math_mode)
                )
                .unwrap();
                for child in children {
                    out.push_str(&render_rail_section_link(child, config.math_mode));
                }
                out.push_str("</div></details>\n");
            }
            remaining = rest;
        }
        out.push_str("</div>\n");
    }
    out.push_str("</nav>\n");
    out
}

fn render_rail_section_link(heading: &Heading, math_mode: MathMode) -> String {
    format!(
        "<a class=\"lecture-section-link lecture-section-l{}\" href=\"#{}\" data-section-link=\"{}\"><span class=\"lecture-section-no\">{}</span><span class=\"lecture-section-title\">{}</span></a>\n",
        heading.level,
        permalinks::fragment_id(&heading.id),
        escape_attr(&heading.id),
        escape_html(&heading.number),
        render_heading_title(heading, math_mode)
    )
}

fn render_toc(headings: &[Heading], math_mode: MathMode) -> String {
    let mut out = String::from("<nav class=\"toc\" aria-label=\"Contents\"><ol>\n");
    for heading in headings {
        write!(
            out,
            "<li class=\"toc-l{}\"><a href=\"#{}\"><span class=\"toc-no\">{}</span><span class=\"toc-title\">{}</span></a></li>\n",
            heading.level,
            permalinks::fragment_id(&heading.id),
            escape_html(&heading.number),
            render_heading_title(heading, math_mode)
        )
        .unwrap();
    }
    out.push_str("</ol></nav>\n");
    out
}

fn render_heading_title(heading: &Heading, math_mode: MathMode) -> String {
    math::postprocess_html_math(heading.title_html.clone(), math_mode)
}

fn render_endnotes(notes: &[RenderedEndnote]) -> String {
    if notes.is_empty() {
        return String::new();
    }
    let mut out = String::from("<section class=\"endnotes\" id=\"endnotes\">\n<h1>Notes</h1>\n");
    for (idx, note) in notes.iter().enumerate() {
        let seq = idx + 1;
        write!(
            out,
            "<p id=\"fn-end-{seq}\">{}<a class=\"footnote-backref\" href=\"#fnref-{seq}\">{}</a><span class=\"footnote-body\">{}</span></p>\n",
            permalinks::footnote_link(seq, &note.number),
            escape_html(&note.number),
            note.body_html
        )
        .unwrap();
    }
    out.push_str("</section>\n");
    out
}

fn chapter_nav_script() -> &'static str {
    r##"<script>
(() => {
  const storagePrefix = `lecture-rail:v1:${new URL(".", window.location.href).href}:`;
  const remember = (details, key) => {
    if (!details) return;
    key = storagePrefix + key;
    try {
      const saved = window.localStorage.getItem(key);
      if (saved === "open" || saved === "closed") details.open = saved === "open";
    } catch {
      // Native disclosures still work when browser storage is unavailable.
    }
    let lastOpen = details.open;
    details.addEventListener("toggle", () => {
      if (details.open === lastOpen) return;
      lastOpen = details.open;
      try {
        window.localStorage.setItem(key, details.open ? "open" : "closed");
      } catch {
        // Storage restrictions must not interrupt navigation.
      }
    });
  };
  const lectureList = document.querySelector(".lecture-browser-list");
  const scrollHint = document.querySelector(".lecture-scroll-hint");
  if (lectureList) {
    const currentLecture = lectureList.querySelector('[aria-current="page"]');
    const updateScrollHint = () => {
      if (!scrollHint) return;
      const overflowing = lectureList.scrollHeight > lectureList.clientHeight + 1;
      const moreBelow = lectureList.scrollTop + lectureList.clientHeight < lectureList.scrollHeight - 1;
      scrollHint.hidden = !overflowing;
      scrollHint.textContent = moreBelow ? "Scroll for more ↓" : "Scroll for earlier ↑";
    };
    const updateLectureList = () => {
      if (currentLecture && lectureList.clientHeight) {
        const listBounds = lectureList.getBoundingClientRect();
        const currentBounds = currentLecture.getBoundingClientRect();
        const centered = lectureList.scrollTop + currentBounds.top - listBounds.top
          - lectureList.clientTop + (currentBounds.height - lectureList.clientHeight) / 2;
        lectureList.scrollTop = Math.max(0, Math.min(centered,
          lectureList.scrollHeight - lectureList.clientHeight));
      }
      updateScrollHint();
    };
    updateLectureList();
    lectureList.addEventListener("scroll", updateScrollHint, { passive: true });
    window.addEventListener("resize", updateLectureList);
    new ResizeObserver(updateLectureList).observe(lectureList);
    document.fonts.ready.then(updateLectureList);
  }
  for (const group of document.querySelectorAll(".lecture-section-group")) {
    const id = group.querySelector("summary [data-section-link]")?.getAttribute("data-section-link");
    if (id) remember(group, `section:${window.location.pathname}:${id}`);
  }

  const links = Array.from(document.querySelectorAll("[data-section-link]"));
  if (!links.length) return;
  const byId = new Map(links.map((link) => [link.getAttribute("data-section-link"), link]));
  const sections = Array.from(byId.keys()).map((id) => document.getElementById(id)).filter(Boolean);
  const setActive = (id) => {
    const current = byId.get(id);
    const group = current?.closest(".lecture-section-group");
    const visible = group && !group.open ? group.querySelector("summary [data-section-link]") : current;
    for (const link of links) {
      const active = link === visible;
      link.classList.toggle("is-active", active);
      if (active) link.setAttribute("aria-current", "location");
      else link.removeAttribute("aria-current");
    }
  };
  const update = () => {
    const y = window.scrollY + 130;
    let current = sections[0]?.id;
    for (const section of sections) {
      if (section.getBoundingClientRect().top + window.scrollY <= y) current = section.id;
      else break;
    }
    if (current) setActive(current);
  };
  update();
  window.setTimeout(update, 0);
  window.setTimeout(update, 150);
  document.addEventListener("scroll", update, { passive: true });
  window.addEventListener("resize", update);
  window.addEventListener("hashchange", update);
  for (const group of document.querySelectorAll(".lecture-section-group")) {
    group.addEventListener("toggle", update);
  }
})();
</script>
"##
}

fn chapter_citation_script() -> &'static str {
    r#"<script>
(() => {
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  for (const details of document.querySelectorAll(".lecture-citation-details")) {
    const summary = details.querySelector("summary");
    const panel = details.querySelector("pre");
    if (!summary || !panel) continue;

    const finish = () => {
      details.classList.remove("is-animating");
      panel.style.height = "";
      panel.style.opacity = "";
      panel.style.marginTop = "";
      panel.style.paddingTop = "";
      panel.style.paddingBottom = "";
      panel.style.overflow = "";
    };

    const afterHeight = (callback) => {
      const done = (event) => {
        if (event.propertyName !== "height") return;
        panel.removeEventListener("transitionend", done);
        window.clearTimeout(fallback);
        callback();
      };
      const fallback = window.setTimeout(() => {
        panel.removeEventListener("transitionend", done);
        callback();
      }, 360);
      panel.addEventListener("transitionend", done);
    };

    summary.addEventListener("click", (event) => {
      event.preventDefault();
      if (reduceMotion) {
        details.open = !details.open;
        return;
      }

      panel.getAnimations().forEach((animation) => animation.cancel());
      details.classList.add("is-animating");

      if (!details.open) {
        details.open = true;
        const endHeight = panel.scrollHeight;
        panel.style.height = "0px";
        panel.style.opacity = "0";
        panel.style.marginTop = "0px";
        panel.style.paddingTop = "0px";
        panel.style.paddingBottom = "0px";
        panel.style.overflow = "hidden";
        panel.offsetHeight;
        panel.style.height = `${endHeight}px`;
        panel.style.opacity = "1";
        panel.style.marginTop = "";
        panel.style.paddingTop = "";
        panel.style.paddingBottom = "";
        afterHeight(finish);
      } else {
        panel.style.height = `${panel.scrollHeight}px`;
        panel.style.opacity = "1";
        panel.style.overflow = "hidden";
        panel.offsetHeight;
        panel.style.height = "0px";
        panel.style.opacity = "0";
        panel.style.marginTop = "0px";
        panel.style.paddingTop = "0px";
        panel.style.paddingBottom = "0px";
        afterHeight(() => {
          details.open = false;
          finish();
        });
      }
    });
  }
})();
</script>
"#
}

fn equation_width_script() -> &'static str {
    r#"<script>
(() => {
  function boxWidth(el){
    if (!el) return 0;
    var rect = el.getBoundingClientRect();
    return Math.max(el.scrollWidth || 0, rect.width || 0);
  }
  function maxWidth(nodes){
    return nodes.reduce(function(max, node){ return Math.max(max, boxWidth(node)); }, 0);
  }
  function equationNeededWidth(eq){
    var style = window.getComputedStyle(eq);
    var columnGap = parseFloat(style.columnGap) || 0;
    var gap = 12;
    if (eq.classList.contains("equation-aligned")) {
      var columns = [];
      eq.querySelectorAll(".equation-align-cell").forEach(function(cell){
        var column = Number(cell.dataset.alignColumn);
        columns[column] = Math.max(columns[column] || 0, boxWidth(cell));
      });
      var full = maxWidth(Array.from(eq.querySelectorAll(".equation-align-full")));
      var eqno = maxWidth(Array.from(eq.querySelectorAll(".eqno")));
      var aligned = columns.reduce(function(total, width){ return total + width; }, 0)
        + Math.max(0, columns.length - 1) * columnGap + (eqno ? eqno + columnGap : 0);
      return Math.max(full, aligned, eq.scrollWidth || 0);
    }
    var rows = Array.from(eq.querySelectorAll(".equation-line"));
    if (!rows.length) rows = Array.from(eq.querySelectorAll(".typst-frame"));
    var rowWidth = maxWidth(rows);
    var math = maxWidth(Array.from(eq.querySelectorAll(".equation-math, .equation-align-full, .typst-frame")));
    var eqno = maxWidth(Array.from(eq.querySelectorAll(".eqno")));
    return Math.max(rowWidth, math + (eqno ? eqno + gap : 0), eq.scrollWidth || 0);
  }
  function sizeTableColumns(){
    // Browsers ignore mixed length/percentage calc() widths on native columns.
    // Resolve Typst tracks against their container, retaining semantic tables.
    // Reset to the authored CSS first so auto columns can shrink after a resize.
    document.querySelectorAll("table[data-table-columns]").forEach(function(table){
      var group = table.querySelector(":scope > colgroup");
      var wrapper = table.closest(".lecture-table");
      if (!group || !wrapper) return;
      var cols = Array.from(group.children);
      var available = wrapper.clientWidth;
      var explicitWidth = function(col){
        return Math.max(0, available * Number(col.dataset.tableRatio) + Number(col.dataset.tablePt) * 96 / 72);
      };
      table.style.minWidth = "";
      var totalFraction = cols.reduce(function(sum, col){ return sum + Number(col.dataset.tableFraction || 0); }, 0);
      if (table.style.tableLayout === "fixed" && totalFraction > 0) {
        // Keep fractional columns readable on narrow screens. Measure their
        // intrinsic minimums using native layout, then retain their proportions
        // in the fixed layout and let the surrounding wrapper scroll.
        var authoredWidth = table.style.width;
        table.style.tableLayout = "auto";
        table.style.width = "min-content";
        var explicitTotal = 0;
        cols.forEach(function(col){
          if (col.dataset.tableTrack === "fraction") col.style.width = "auto";
          else { var width = explicitWidth(col); explicitTotal += width; col.style.width = width + "px"; }
        });
        var minimumFractionSpace = 0;
        cols.forEach(function(col){
          var fraction = Number(col.dataset.tableFraction || 0);
          if (fraction > 0) minimumFractionSpace = Math.max(minimumFractionSpace, col.getBoundingClientRect().width * totalFraction / fraction);
        });
        var borderWidth = table.getBoundingClientRect().width - group.getBoundingClientRect().width;
        table.style.tableLayout = "fixed";
        table.style.width = authoredWidth;
        table.style.minWidth = Math.ceil(explicitTotal + minimumFractionSpace + borderWidth) + "px";
      }
      cols.forEach(function(col){ col.style.width = col.dataset.tableWidth; });
      var gridWidth = group.getBoundingClientRect().width;
      var fractions = 0;
      var used = 0;
      var widths = cols.map(function(col){
        if (col.dataset.tableTrack === "fraction") {
          fractions += Number(col.dataset.tableFraction);
          return null;
        }
        var width = col.dataset.tableTrack === "auto"
          ? col.getBoundingClientRect().width
          : explicitWidth(col);
        used += width;
        return width;
      });
      var remaining = Math.max(0, gridWidth - used);
      cols.forEach(function(col, index){
        if (col.dataset.tableTrack === "auto") return;
        var width = widths[index];
        if (width === null) width = fractions > 0 ? remaining * Number(col.dataset.tableFraction) / fractions : 0;
        col.style.width = width + "px";
      });
    });
  }
  function markOverwideEquations(){
    sizeTableColumns();
    document.querySelectorAll(".equation").forEach(function(eq){
      eq.classList.remove("is-overwide");
      var available = eq.clientWidth;
      var needed = equationNeededWidth(eq);
      if (needed > available + 2) eq.classList.add("is-overwide");
    });
    document.querySelectorAll(".equation-block").forEach(function(block){
      var box = block.getBoundingClientRect();
      var equation = block.querySelector(":scope > .equation");
      block.style.setProperty("--equation-right", `${equation.getBoundingClientRect().right - box.left}px`);
      block.querySelectorAll(":scope > .permalink-equation").forEach(function(link){
        var target = document.getElementById(decodeURIComponent(link.hash.slice(1)));
        var number = target?.closest(".eqno") || block.querySelector(".eqno");
        if (!number) return;
        var rect = number.getBoundingClientRect();
        link.style.top = `${rect.top + rect.height / 2 - box.top}px`;
      });
    });
    document.querySelectorAll(".lecture-table").forEach(function(wrapper){
      var table = wrapper.querySelector("table");
      wrapper.classList.toggle("has-overflow", !!table && Math.max(table.scrollWidth, table.getBoundingClientRect().width) > wrapper.clientWidth + 2);
    });
  }
  window.markOverwideEquations = markOverwideEquations;
  window.addEventListener("resize", markOverwideEquations);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(markOverwideEquations);
  window.setTimeout(markOverwideEquations, 0);
  window.setTimeout(markOverwideEquations, 80);
  window.setTimeout(markOverwideEquations, 300);
})();
</script>
"#
}

fn settled_hash_scroll_script() -> &'static str {
    r#"<script>
(() => {
  let version = 0;

  function hashTarget(){
    const raw = window.location.hash ? window.location.hash.slice(1) : "";
    if (!raw) return null;
    let target;
    try {
      target = document.getElementById(decodeURIComponent(raw));
    } catch (_) {
      target = document.getElementById(raw);
    }
    // Footnotes have a margin copy on desktop and an endnote on narrow pages.
    // Share one URL while selecting whichever copy is currently visible.
    if (target?.id.startsWith("fn-end-")) {
      const side = document.getElementById(target.id.replace("fn-end-", "fn-side-"));
      if (side?.getClientRects().length) return side;
    } else if (target?.id.startsWith("fn-side-") && !target.getClientRects().length) {
      return document.getElementById(target.id.replace("fn-side-", "fn-end-"));
    }
    // Native equate line labels live on hidden metadata spans. Scroll to the
    // visible equation number, including rows laid out with display:contents.
    if (target?.matches(".equation-anchor[hidden]")) {
      return target.closest(".equation-line")?.querySelector(".eqno") || target.closest(".equation");
    }
    return target;
  }

  function anchorOffset(){
    const value = window.getComputedStyle(document.documentElement).getPropertyValue("--anchor-offset");
    return parseFloat(value) || 0;
  }

  function targetDistance(target){
    return target.getBoundingClientRect().top - anchorOffset();
  }

  function scrollToTarget(target, behavior){
    const top = target.getBoundingClientRect().top + window.pageYOffset - anchorOffset();
    const y = Math.max(0, top);
    try {
      window.scrollTo({ top: y, left: 0, behavior });
    } catch (_) {
      window.scrollTo(0, y);
    }
  }

  function afterLoad(){
    if (document.readyState === "complete") return Promise.resolve();
    return new Promise(function(resolve){
      window.addEventListener("load", resolve, { once: true });
    });
  }

  function afterFonts(){
    if (document.fonts && document.fonts.ready) {
      return document.fonts.ready.catch(function(){});
    }
    return Promise.resolve();
  }

  function afterStableLayout(callback){
    let lastHeight = -1;
    let stableFrames = 0;
    let frames = 0;
    function tick(){
      const height = document.documentElement.scrollHeight;
      if (height === lastHeight) stableFrames += 1;
      else {
        stableFrames = 0;
        lastHeight = height;
      }
      frames += 1;
      if (stableFrames >= 2 || frames >= 24) callback();
      else window.requestAnimationFrame(tick);
    }
    window.requestAnimationFrame(tick);
  }

  function scheduleHashScroll(behavior = "smooth"){
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) behavior = "instant";
    const target = hashTarget();
    if (!target) return;
    const current = ++version;
    Promise.all([afterLoad(), afterFonts()]).then(function(){
      afterStableLayout(function(){
        if (current !== version) return;
        const target = hashTarget();
        if (!target) return;
        scrollToTarget(target, behavior);
        window.setTimeout(function(){
          if (current === version) {
            const target = hashTarget();
            if (target && Math.abs(targetDistance(target)) > 1) scrollToTarget(target, "instant");
          }
        }, behavior === "instant" ? 160 : 1500);
      });
    });
  }

  scheduleHashScroll("instant");
  window.addEventListener("hashchange", () => scheduleHashScroll());
})();
</script>
"#
}

fn write_output(config: &Config, html: String) -> Result<(), String> {
    if let Some(parent) = config.output.parent() {
        if !parent.as_os_str().is_empty() {
            fs::create_dir_all(parent).map_err(|err| {
                format!(
                    "could not create output directory {}: {err}",
                    parent.display()
                )
            })?;
        }
    }
    fs::write(&config.output, html)
        .map_err(|err| format!("could not write {}: {err}", config.output.display()))
}

fn copy_referenced_assets(config: &Config, html: &str) -> Result<(), String> {
    let Some(output_dir) = config.output.parent() else {
        return Ok(());
    };
    for captures in re_img_src().captures_iter(html) {
        let Some(src) = captures.get(1).map(|m| m.as_str().trim()) else {
            continue;
        };
        if src.is_empty()
            || src.starts_with('/')
            || src.starts_with('#')
            || src.starts_with("data:")
            || src.contains("://")
        {
            continue;
        }
        let clean_src = src.split(['?', '#']).next().unwrap_or_default();
        if clean_src.is_empty() || clean_src.split('/').any(|part| part == "..") {
            continue;
        }
        let root_candidate = config.root.join(clean_src);
        let input_candidate = config
            .input
            .parent()
            .map(|parent| parent.join(clean_src))
            .unwrap_or_else(|| PathBuf::from(clean_src));
        let source = if root_candidate.is_file() {
            root_candidate
        } else if input_candidate.is_file() {
            input_candidate
        } else {
            continue;
        };
        let dest = output_dir.join(clean_src);
        if let Some(parent) = dest.parent() {
            fs::create_dir_all(parent).map_err(|err| {
                format!(
                    "could not create asset directory {}: {err}",
                    parent.display()
                )
            })?;
        }
        fs::copy(&source, &dest).map_err(|err| {
            format!(
                "could not copy asset {} to {}: {err}",
                source.display(),
                dest.display()
            )
        })?;
    }
    Ok(())
}

fn title_from_path(path: &Path) -> String {
    path.file_stem()
        .and_then(|name| name.to_str())
        .unwrap_or("Notes")
        .replace(['-', '_'], " ")
}

fn slugify(text: &str) -> String {
    let mut out = String::new();
    let mut dash = false;
    for ch in text.chars().flat_map(|ch| ch.to_lowercase()) {
        if ch.is_ascii_alphanumeric() {
            out.push(ch);
            dash = false;
        } else if !dash {
            out.push('-');
            dash = true;
        }
    }
    let out = out.trim_matches('-').to_owned();
    if out.is_empty() {
        "section".to_owned()
    } else {
        out
    }
}

fn normalize_ws(input: &str) -> String {
    input.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn extract_href(attrs: &str) -> Option<&str> {
    re_href().captures(attrs)?.get(1).map(|m| m.as_str())
}

fn extract_href_attr(attrs: &str) -> Option<&str> {
    let captures = re_href_attr().captures(attrs)?;
    captures
        .get(1)
        .or_else(|| captures.get(2))
        .or_else(|| captures.get(3))
        .map(|m| m.as_str())
}

fn set_id_attr(attrs: &str, id: &str) -> String {
    if re_id_attr().is_match(attrs) {
        re_id_attr()
            .replace(attrs, format!("id=\"{}\"", escape_attr(id)))
            .to_string()
    } else {
        format!(" id=\"{}\"{}", escape_attr(id), attrs)
    }
}

fn bibtex_escape(input: &str) -> String {
    input.replace('&', "\\&")
}

fn escape_html(input: &str) -> String {
    input
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

fn escape_attr(input: &str) -> String {
    escape_html(input).replace('\'', "&#39;")
}

fn re_endnote_backlink() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)\s*<a[^>]*role="doc-backlink"[^>]*>.*?</a>\s*"#).unwrap())
}

fn re_notes_meta() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)\s*<div\b[^>]*\bclass="[^"]*\bnotes-meta\b[^"]*"[^>]*>.*?</div>\s*"#)
            .unwrap()
    })
}

fn re_hidden_bibliography() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(
            r#"(?s)\s*<div\s+hidden(?:="")?>\s*(?P<section><section role="doc-bibliography">.*?</section>)\s*</div>\s*"#,
        )
        .unwrap()
    })
}

fn re_empty_hidden_div() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)\s*<div\s+hidden(?:="")?>\s*</div>\s*"#).unwrap())
}

fn re_visible_bibliography() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)<section\b[^>]*\bclass="[^"]*\bbibliography\b[^"]*"[^>]*>.*?</section>"#)
            .unwrap()
    })
}

fn re_doc_biblioref_link() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)<a\b(?P<attrs>[^>]*)>(?P<inner>.*?)</a>"#).unwrap())
}

fn re_anchor_link() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)<a\b(?P<attrs>[^>]*)>(?P<inner>.*?)</a>"#).unwrap())
}

fn re_img_src() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"<img\b[^>]*\bsrc="([^"]+)""#).unwrap())
}

fn re_open_paragraph_tag() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)\s*<p\b[^>]*>\s*"#).unwrap())
}

fn re_close_paragraph_tag() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(?s)\s*</p>\s*"#).unwrap())
}

fn re_endnotes_section() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)\s*<section role="doc-endnotes">.*?</section>\s*"#).unwrap()
    })
}

fn re_html_footnote_template() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)\s*<template\b[^>]*\bclass="[^"]*\bnotes-html-footnote-body\b[^"]*"[^>]*>.*?</template>\s*"#)
            .unwrap()
    })
}

fn re_typst_figure_class() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?P<prefix><figure\b[^>]*\bclass=")typst(?P<suffix>"[^>]*>)"#).unwrap()
    })
}

fn re_noteref() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)<a\s+([^>]*\brole="doc-noteref"[^>]*)><sup>(.*?)</sup></a>"#).unwrap()
    })
}

fn re_href() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r##"href="#([^"]+)""##).unwrap())
}

fn re_href_attr() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"\bhref=(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#).unwrap())
}

fn re_class_attr() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"class="([^"]*)""#).unwrap())
}

fn re_id_attr() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"id="([^"]*)""#).unwrap())
}

fn re_html_heading() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)<h(?P<level>[1-6])(?P<attrs>[^>]*)>(?P<inner>.*?)</h[1-6]>"#).unwrap()
    })
}

fn re_heading_secno_span() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r#"(?s)^\s*<span\b[^>]*\bclass="[^"]*\bsecno\b[^"]*"[^>]*>.*?</span>\s*"#)
            .unwrap()
    })
}

fn re_html_section() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"<section(?P<attrs>[^>]*)>"#).unwrap())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn source_link_opens_the_repository_file_on_github() {
        let (mut book, _) = rail_fixture();
        book.site.github = Some("https://github.com/example/course/".to_owned());
        book.chapters[0].source = "content/nested/a note #1.typ".to_owned();
        let html = render_chapter_citation_sidenote(
            &book,
            &book.chapters[0],
            "Eight",
            "Course",
            Some("pdf/eight.pdf"),
        );
        assert!(html.contains(
            r#"href="https://github.com/example/course/blob/main/content/nested/a%20note%20%231.typ""#
        ));
        assert!(html.contains("View source</a>"));
        assert!(html.contains(r#"href="pdf/eight.pdf""#));
        assert!(!html.contains(r#"href="source/"#));
    }

    fn rail_fixture() -> (ExportConfig, Config) {
        let book = serde_json::from_value(serde_json::json!({
            "site": {"event": "MIT 6.7980", "term": "Fall 2026", "title": "Full course title",
                     "authors": "Course authors", "index_href": "index.html"},
            "how_to_cite": {"authors": "Course authors", "key_prefix": "notes",
                            "booktitle": "Course", "title_template": "{label}: {title}",
                            "year": 2026, "url_prefix": "https://example.com/"},
            "notes": [
                {"number": 8, "source": "eight.typ", "short_title": "Eight"},
                {"number": 16, "source": "sixteen.typ", "short_title": "Sixteen"},
                {"number": 18, "source": "eighteen.typ", "short_title": "Eighteen"},
                {"number": "S1", "source": "s1.typ", "short_title": "Reading one", "supplementary": true},
                {"number": "S2", "source": "s2.typ", "short_title": "Reading two", "supplementary": true}
            ]
        })).unwrap();
        let config = Config {
            input: PathBuf::from("sixteen.typ"),
            output: PathBuf::from("sixteen.html"),
            root: PathBuf::from("."),
            title: None,
            site_title: "Full course title".to_owned(),
            authors: "Course authors".to_owned(),
            index_href: None,
            pdf_href: None,
            export_config: None,
            from_html: None,
            math_mode: MathMode::Katex,
            figure_svg: false,
            figure_inputs: Vec::new(),
            figure_deps: None,
        };
        (book, config)
    }

    #[test]
    fn rail_preserves_visible_lectures_outline_and_heading_math() {
        let (book, config) = rail_fixture();
        let parts = HtmlParts::parse(
            r#"<html><body>
<h1 id="a" class="notes-heading" data-level="1" data-number="16.1">First section</h1>
<h2 id="b" class="notes-heading" data-level="2" data-number="16.1.1">Child</h2>
<h3 id="c" class="notes-heading" data-level="3" data-number="16.1.1.1">Grandchild</h3>
<h1 id="d" class="notes-heading" data-level="1" data-number="16.2">Leaf section</h1>
<h1 id="e" class="notes-heading" data-level="1" data-number="16.3"><span class="math" data-math-display="inline" data-typst-math="[Φ]" role="math"><svg></svg></span>-regret</h1>
<h2 id="f" class="notes-heading" data-level="2" data-number="16.3.1">Last child</h2>
</body></html>"#,
        );
        let rail = render_chapter_rail(&book, 1, &parts.headings, &config);
        let html = Html::parse_fragment(&rail);
        let select = |selector: &str| Selector::parse(selector).unwrap();
        assert_eq!(html.select(&select("details.lecture-browser")).count(), 0);
        assert_eq!(html.select(&select(".lecture-browser summary")).count(), 0);
        assert_eq!(html.select(&select(".lecture-browser-list[tabindex='0']")).count(), 1);
        assert_eq!(html.select(&select(".lecture-scroll-hint[hidden]")).count(), 1);
        assert_eq!(html.select(&select(".lecture-browser a")).count(), 5);
        let current = html.select(&select("[aria-current=page]")).next().unwrap();
        assert_eq!(current.value().attr("href"), Some("sixteen.html"));
        let home = html.select(&select(".course-event")).next().unwrap();
        assert_eq!(home.value().attr("href"), Some("index.html"));
        assert_eq!(home.text().collect::<String>(), "MIT 6.7980 · Fall 2026");
        let title = html.select(&select(".course-title")).next().unwrap();
        assert_eq!(title.value().attr("href"), Some("index.html"));
        assert_eq!(title.text().collect::<String>(), "Full course title");
        let authors = html.select(&select(".course-authors")).next().unwrap();
        assert_eq!(authors.text().collect::<String>(), "Course authors");
        let destinations: Vec<_> = html
            .select(&select("[data-section-link]"))
            .map(|link| link.value().attr("href").unwrap())
            .collect();
        assert_eq!(destinations, ["#a", "#b", "#c", "#d", "#e", "#f"]);
        let groups: Vec<_> = html.select(&select(".lecture-section-group")).collect();
        assert_eq!(groups.len(), 2);
        assert!(groups.iter().all(|group| group.value().attr("open").is_some()));
        assert_eq!(
            groups[0].select(&select(".lecture-subsections a")).count(),
            2
        );
        assert_eq!(
            groups[1].select(&select(".lecture-subsections a")).count(),
            1
        );
        assert_eq!(html.select(&select(".lecture-outline > a")).count(), 1);
        assert!(rail.contains(r"\(\Phi\)"));
        assert!(!rail.contains("<svg>"));
    }

    #[test]
    fn lecture_metadata_moves_below_title_and_before_toc_once() {
        let raw = r#"<html><body><div class="lecture-metadata">
<div><span>Instructor</span><p>Prof. Constantinos Daskalakis</p></div>
<div><span>Lecture date</span><p>Thu, Sep 11, 2025</p></div>
</div><p>Lecture introduction.</p><h2 class="notes-heading" id="sperner">Sperner</h2>
</body></html>"#;
        let parts = HtmlParts::parse(raw);
        assert!(!parts.body_html.contains("lecture-metadata"));
        assert!(parts.body_html.contains("Lecture introduction."));
        let config = Config {
            input: PathBuf::from("lecture.typ"),
            output: PathBuf::from("lecture.html"),
            root: PathBuf::from("."),
            title: None,
            site_title: "Course".to_owned(),
            authors: String::new(),
            index_href: None,
            pdf_href: None,
            export_config: None,
            from_html: None,
            math_mode: MathMode::Katex,
            figure_svg: false,
            figure_inputs: Vec::new(),
            figure_deps: None,
        };
        let html = render_document(&config, "Existence proofs", &parts, None);
        assert_eq!(html.matches("Prof. Constantinos Daskalakis").count(), 1);
        assert_eq!(html.matches("Thu, Sep 11, 2025").count(), 1);
        let title = html.find("<h1 class=\"lecture-title\"").unwrap();
        let metadata = html.find("<div class=\"lecture-metadata\"").unwrap();
        let toc = html.find("<nav class=\"toc\"").unwrap();
        let introduction = html.find("Lecture introduction.").unwrap();
        assert!(title < metadata && metadata < toc && toc < introduction);
    }

    #[test]
    fn main_source_import_is_swapped_to_html_style() {
        let source = r#"#import "meta/gabri_notes.typ": *

#show: gabri_notes.with(lec_num: 1, title: "Intro")
"#;

        let rewritten = use_html_notes_style(source);

        assert!(rewritten.contains(r#"#import "meta/gabri_notes_html.typ": *"#));
        assert!(!rewritten.contains(r#"#import "meta/gabri_notes.typ": *"#));
    }

    #[test]
    fn relocated_notes_import_is_swapped_to_html_style() {
        let source = r#"#import "/content/meta/gabri_notes.typ": *

#show: gabri_notes.with(lec_num: 1, title: "Intro")
"#;

        let rewritten = use_html_notes_style(source);

        assert!(rewritten.contains(r#"#import "/content/meta/gabri_notes_html.typ": *"#));
        assert!(!rewritten.contains(r#"#import "/content/meta/gabri_notes.typ": *"#));
    }

    #[test]
    fn extracts_metadata_and_headings_from_html_attributes() {
        let raw = r#"
<!doctype html>
<html><body>
<div class="notes-meta" hidden="" data-lecture-number="4" data-title="Phi-Regret"></div>
<h1 id="loc-4" class="notes-heading" data-level="1" data-number="4.1"><span class="secno">4.1</span> First section</h1>
<h2 class="notes-heading" data-level="2" data-number="4.1.1"><span class="secno">4.1.1</span> Real subsection</h2>
<h1 class="notes-heading notes-heading-unnumbered" data-level="1">Bibliography for this lecture</h1>
</body></html>
"#;

        let parts = HtmlParts::parse(raw);

        assert_eq!(parts.meta.lecture_number.as_deref(), Some("4"));
        assert_eq!(parts.meta.title.as_deref(), Some("Phi-Regret"));
        assert_eq!(parts.headings.len(), 2);
        assert_eq!(parts.headings[0].id, "loc-4");
        assert_eq!(parts.headings[0].number, "4.1");
        assert_eq!(parts.headings[0].text, "First section");
        assert_eq!(parts.headings[1].id, "4-1-1-real-subsection");
        assert_eq!(parts.headings[1].number, "4.1.1");
        assert_eq!(parts.headings[1].text, "Real subsection");
    }

    #[test]
    fn statement_ids_preserve_native_links_and_legacy_numbered_urls() {
        let mut parts = HtmlParts::parse(
            r##"<html><body>
<section class="env statement" id="thm-regret-gap"><div class="env-head"><span class="env-kind">Theorem</span> <span class="env-number">L4.9</span></div><p>Statement.</p></section>
<section class="env statement"><div class="env-head"><span class="env-kind">Example</span> <span class="env-number">L4.10</span></div><p>Example.</p></section>
<a href="#thm-regret-gap">Local reference</a>
<a href="other.html#native-label">Cross-document reference</a>
</body></html>"##,
        );
        parts.rewrite_statement_ids();
        let dom = Html::parse_fragment(&parts.body_html);
        for selector in ["section#thm-regret-gap", "#theorem-l4-9", "section#example-l4-10"] {
            assert_eq!(dom.select(&Selector::parse(selector).unwrap()).count(), 1);
        }
        assert!(parts.body_html.contains(r##"href="#thm-regret-gap""##));
        assert!(parts.body_html.contains(r#"href="other.html#native-label""#));
    }

    #[test]
    fn heading_math_is_preserved_in_rendered_toc() {
        let raw = r#"
<!doctype html>
<html><body>
<h1 id="sec-gordon" class="notes-heading" data-level="1" data-number="1.3"><span class="secno">1.3</span> A framework for minimizing <span class="math" data-math-display="inline" data-typst-math="[Φ]" role="math"><svg></svg></span>-regret</h1>
</body></html>
"#;

        let parts = HtmlParts::parse(raw);
        let toc = render_toc(&parts.headings, MathMode::Katex);

        assert!(toc.contains("A framework for minimizing"));
        assert!(toc.contains("math-katex-source"));
        assert!(toc.contains(r"\(\Phi\)"));
        assert!(toc.contains("-regret"));
        assert!(!toc.contains("<svg>"));
    }

    #[test]
    fn postprocess_keeps_visible_bibliography_and_removes_hidden_data() {
        let body = r##"
<p>Body</p>
<div class="notes-meta" hidden="" data-lecture-number="4" data-title="Phi-Regret"></div>
<section class="bibliography" id="bibliography"><table class="bibliography-table"><tr id="bib-a" class="bibliography-row"><td class="bib-key">[A]</td><td class="bib-entry">Entry</td></tr></table></section>
<div hidden=""><section role="doc-bibliography"><ol><li id="loc-1"><span class="prefix">[A]</span> Entry</li></ol></section></div>
<section role="doc-endnotes"><ol><li id="fn-1"><sup>1</sup> Note</li></ol></section>
"##
        .to_owned();

        let (body, _) = postprocess_body(body, &[], MathMode::Svg).unwrap();

        assert!(!body.contains("hidden"));
        assert!(!body.contains("notes-meta"));
        assert!(body.contains("id=\"bibliography\""));
        assert!(body.contains("bibliography-table"));
        assert!(body.contains("<tr id=\"bib-a\" class=\"bibliography-row\">"));
        assert!(body.contains("<td class=\"bib-key\">[A]</td>"));
        assert!(body.contains("<td class=\"bib-entry\">Entry</td>"));
        assert!(!body.contains("role=\"doc-bibliography\""));
        assert!(!body.contains("doc-endnotes"));
    }

    #[test]
    fn postprocess_preserves_reference_links() {
        let body = r##"
<p>See <a href="#loc-1">Section 1.1</a>, <a href="#loc-2">Theorem 1.2</a>, and <a href="#loc-3">(3)</a>.</p>
<p>Generated citation <a href="#bib-old" role="doc-biblioref">[OLD]OLD</a> is unwrapped.</p>
<p>Custom citation <a class="citation" href="#bib-new" role="doc-biblioref">NEW</a> is preserved.</p>
<p>External citation <a href="https://doi.org/10.1/example" role="doc-biblioref">DOI</a> is preserved.</p>
"##
        .to_owned();

        let (body, _) = postprocess_body(body, &[], MathMode::Svg).unwrap();

        assert!(body.contains(r##"<a href="#loc-1">Section 1.1</a>"##));
        assert!(body.contains(r##"<a href="#loc-2">Theorem 1.2</a>"##));
        assert!(body.contains(r##"<a href="#loc-3">(3)</a>"##));
        assert!(body.contains("Generated citation OLD is unwrapped."));
        assert!(!body.contains(r##"<a href="#bib-old" role="doc-biblioref">OLD</a>"##));
        assert!(
            body.contains(r##"<a class="citation" href="#bib-new" role="doc-biblioref">NEW</a>"##)
        );
        assert!(body.contains(r#"<a href="https://doi.org/10.1/example" role="doc-biblioref">DOI</a>"#));
    }

    #[test]
    fn footnote_bibliography_links_keep_their_compact_label() {
        let link = r#"<a class="bibliography-link" href="https://doi.org/10.1126/science.aay2400">link</a>"#;
        assert_eq!(rewrite_footnote_link_labels(link), link);
    }

    #[test]
    fn footnote_links_render_as_site_names() {
        let body =
            r##"<p>Body<a href="#fn-a" role="doc-noteref"><sup>1</sup></a>.</p>"##.to_owned();
        let endnotes = vec![Endnote {
            id: "fn-a".to_owned(),
            label: "1".to_owned(),
            body_html: r##"See <a href="https://en.wikipedia.org/wiki/Variational_principle">https://en.wikipedia.org/wiki/Variational_principle</a> and <a href="https://www.nytimes.com/example">https://www.nytimes.com/example</a>."##.to_owned(),
        }];

        let (body, notes) = rewrite_footnotes(body, &endnotes, MathMode::Svg);

        assert!(body.contains(
            r##"<a href="https://en.wikipedia.org/wiki/Variational_principle">wikipedia</a>"##
        ));
        assert!(body.contains(r##"<a href="https://www.nytimes.com/example">NY Times</a>"##));
        assert!(!body.contains(">https://en.wikipedia.org"));
        assert!(!body.contains(">https://www.nytimes.com"));
        assert_eq!(notes.len(), 1);
        assert!(notes[0].body_html.contains(">wikipedia</a>"));
        assert!(notes[0].body_html.contains(">NY Times</a>"));
    }

    #[test]
    fn footnote_paragraph_fragments_are_inlined() {
        let body =
            r##"<p>Body<a href="#fn-a" role="doc-noteref"><sup>1</sup></a>.</p>"##.to_owned();
        let endnotes = vec![Endnote {
            id: "fn-a".to_owned(),
            label: "1".to_owned(),
            body_html: r##"<p>given for</p><span role="math">Omega</span><p>, <em>not</em></p><span role="math">Omega_t</span><p>. Yet, because</p>"##.to_owned(),
        }];

        let (body, notes) = rewrite_footnotes(body, &endnotes, MathMode::Svg);

        assert!(!body.contains(
            "<span class=\"footnote\" id=\"fn-side-1\"><span class=\"footnote-num\">1</span><p>"
        ));
        assert!(!notes[0].body_html.contains("<p>"));
        assert!(!notes[0].body_html.contains("</p>"));
        assert!(notes[0].body_html.contains(
            r##"given for <span role="math">Omega</span>, <em>not</em> <span role="math">Omega_t</span>. Yet, because"##
        ));
    }

    #[test]
    fn html_footnote_templates_are_collected_and_math_processed() {
        let raw = r##"
<!doctype html>
<html><body>
<p>Text<a id="html-fnref-1" href="#html-fn-1" role="doc-noteref"><sup>1</sup></a>.</p>
<template class="notes-html-footnote-body" id="html-fn-1" data-note-label="1">
  math <span role="math" data-math-display="inline" data-typst-math="attach(base: [Ω], b: [t])"><svg></svg></span>
</template>
</body></html>
"##;
        let document = HtmlParts::parse(raw);

        assert_eq!(document.endnotes.len(), 1);
        let (body, notes) =
            postprocess_body(document.body_html, &document.endnotes, MathMode::Katex).unwrap();

        assert!(!body.contains("notes-html-footnote-body"));
        assert!(body.contains("footnote"));
        assert!(notes[0].body_html.contains("math-katex-source"));
        assert!(notes[0].body_html.contains(r#"\(\Omega_{t}\)"#));
    }

    #[test]
    fn postprocess_renders_raw_tex_phi_in_citation_notes() {
        let body = r##"
<p>Forecasting [<span class="citation-wrap"><a class="citation" href="#bib-fp" role="doc-biblioref">FP26</a><span class="citation-note">A New Route to \Phi-Regret Minimization.</span></span>].</p>
"##
        .to_owned();

        let (body, _) = postprocess_body(body, &[], MathMode::Katex).unwrap();

        assert!(body.contains("math-katex-source"));
        assert!(body.contains(r#"\(\Phi\)</span>-Regret"#));
        assert!(!body.contains(r"\Phi-Regret"));
    }

    #[test]
    fn bibliography_and_appendix_heading_targets_stay_in_sync() {
        let raw = r##"<html><body>
<h1 class="notes-heading" data-number="1">First</h1>
<h1 class="notes-heading notes-heading-unnumbered">Notes</h1>
<h1 class="notes-heading" data-number="2">Bibliography for this lecture</h1>
<h1 class="notes-heading" data-number="A">Proof of <a href="#loc-6"><em>Theorem 1</em></a></h1>
</body></html>"##;
        let mut parts = HtmlParts::parse(raw);
        parts.rewrite_heading_ids();
        for heading in &parts.headings {
            assert!(parts.body_html.contains(&format!("id=\"{}\"", heading.id)));
        }
        let toc = render_toc(&parts.headings, MathMode::Svg);
        assert!(toc.contains("Proof of <em>Theorem 1</em>"));
        assert!(!toc.contains("loc-6"));
        assert_eq!(toc.matches("<a ").count(), parts.headings.len());
    }

    #[test]
    fn footnotes_keep_custom_citations_and_updated_cross_references() {
        let raw = r##"<html><body>
<p>Text<a href="#html-fn-1" role="doc-noteref"><sup>1</sup></a>.</p>
<template class="notes-html-footnote-body" id="html-fn-1" data-note-label="1">
See <a href="#loc-6">Theorem 1</a> and <a class="citation" href="#bib-a" role="doc-biblioref">A</a>.
<a href="#loc-34" role="doc-biblioref">Full citation</a>
</template></body></html>"##;
        let mut parts = HtmlParts::parse(raw);
        parts.rewrite_local_links(&HashMap::from([(
            "loc-6".to_owned(),
            "#theorem-1".to_owned(),
        )]));
        let (body, notes) =
            postprocess_body(parts.body_html, &parts.endnotes, MathMode::Svg).unwrap();
        for html in [&body, &notes[0].body_html] {
            assert!(html.contains("href=\"#theorem-1\""));
            assert!(html.contains("href=\"#bib-a\""));
            assert!(html.contains("Full citation"));
            assert!(!html.contains("loc-34"));
            assert!(!html.contains("loc-6"));
        }
    }

    #[test]
    fn heading_rewrite_adds_missing_ids() {
        let mut parts = HtmlParts {
            meta: DocumentMeta::default(),
            header_html: String::new(),
            body_html:
                r#"<h2 class="notes-heading"><span class="secno">4.2.1</span> Real subsection</h2>"#
                    .to_owned(),
            headings: vec![Heading {
                level: 2,
                raw_id: None,
                text: "Real subsection".to_owned(),
                title_html: "Real subsection".to_owned(),
                id: "4-2-1-real-subsection".to_owned(),
                number: "4.2.1".to_owned(),
            }],
            endnotes: Vec::new(),
            rendered_endnotes: Vec::new(),
        };

        parts.rewrite_heading_ids();

        assert!(parts
            .body_html
            .contains(r#"<h2 id="4-2-1-real-subsection" class="notes-heading">"#));
    }
}
