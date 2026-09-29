use crate::math::MathMode;
use std::path::{Path, PathBuf};

const DEFAULT_SITE_TITLE: &str = "Topics in Multiagent Learning";
const DEFAULT_AUTHORS: &str = "Constantinos Daskalakis and Gabriele Farina";
const DEFAULT_INDEX_HREF: &str = "index.html";

#[derive(Debug)]
pub(crate) struct Config {
    pub(crate) input: PathBuf,
    pub(crate) output: PathBuf,
    pub(crate) root: PathBuf,
    pub(crate) title: Option<String>,
    pub(crate) site_title: String,
    pub(crate) authors: String,
    pub(crate) index_href: Option<String>,
    pub(crate) pdf_href: Option<String>,
    pub(crate) export_config: Option<PathBuf>,
    pub(crate) from_html: Option<PathBuf>,
    pub(crate) math_mode: MathMode,
    pub(crate) figure_svg: bool,
    pub(crate) figure_inputs: Vec<String>,
    pub(crate) figure_deps: Option<PathBuf>,
}

/// Export the MIT 6.7980 Typst notes through Typst HTML plus postprocessing.
#[argopt::cmd]
#[opt(author, version, about, long_about = None)]
pub(crate) fn parse(
    /// Project root for includes, packages, fonts, and bibliography.
    #[opt(long)]
    root: Option<PathBuf>,
    /// Page title override.
    #[opt(long)]
    title: Option<String>,
    /// Header site title.
    #[opt(long = "site-title")]
    site_title: Option<String>,
    /// Header author line.
    #[opt(long)]
    authors: Option<String>,
    /// Header index link.
    #[opt(long)]
    index: Option<String>,
    /// Hide the index link.
    #[opt(long = "no-index")]
    no_index: bool,
    /// Header PDF link.
    #[opt(long)]
    pdf: Option<String>,
    /// YAML file containing lecture and citation metadata.
    #[opt(long = "config")]
    export_config: Option<PathBuf>,
    /// Postprocess this HTML from a native Typst bundle instead of compiling input.
    #[opt(long = "from-html")]
    from_html: Option<PathBuf>,
    /// Math rendering backend: svg or katex. Defaults to katex.
    #[opt(long)]
    math: Option<String>,
    /// Render a standalone figure SVG with a selectable text layer.
    #[opt(long = "figure-svg")]
    figure_svg: bool,
    /// Compiler input for a figure, e.g. gate=addition. May be repeated.
    #[opt(long = "figure-input")]
    figure_inputs: Vec<String>,
    /// Write figure dependency paths as JSON for incremental builds.
    #[opt(long = "figure-deps")]
    figure_deps: Option<PathBuf>,
    /// Input Typst file.
    input: PathBuf,
    /// Output HTML file. Defaults to the input path with .html extension.
    output: Option<PathBuf>,
) -> Result<Config, String> {
    let math_mode = if let Some(math) = math {
        MathMode::parse(&math)?
    } else {
        MathMode::Katex
    };

    let output = output.unwrap_or_else(|| input.with_extension(if figure_svg { "svg" } else { "html" }));
    let root = root.unwrap_or_else(|| default_root_for_input(&input));
    let index_href = if no_index {
        None
    } else {
        Some(index.unwrap_or_else(|| DEFAULT_INDEX_HREF.to_owned()))
    };

    Ok(Config {
        input,
        output,
        root,
        title,
        site_title: site_title.unwrap_or_else(|| DEFAULT_SITE_TITLE.to_owned()),
        authors: authors.unwrap_or_else(|| DEFAULT_AUTHORS.to_owned()),
        index_href,
        pdf_href: pdf,
        export_config,
        from_html,
        math_mode,
        figure_svg,
        figure_inputs,
        figure_deps,
    })
}

fn default_root_for_input(input: &Path) -> PathBuf {
    input
        .parent()
        .filter(|path| !path.as_os_str().is_empty())
        .unwrap_or_else(|| Path::new("."))
        .to_path_buf()
}
