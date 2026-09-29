//! Expose selectable text in SVG figures that Typst wraps in data images.
//!
//! Unmarked illustrations remain images. Marked SVGs keep their vector artwork,
//! viewport, and text layer, but join the page's DOM so browsers can select text.

use base64::{engine::general_purpose::STANDARD, Engine as _};
use regex::{Captures, Regex};
use roxmltree::{Document, Node};
use std::collections::HashMap;
use std::ops::Range;
use std::sync::OnceLock;

const XLINK: &str = "http://www.w3.org/1999/xlink";
const MARKER: &str = "data-selectable-text";

pub fn inline_selectable_svgs(html: &str) -> Result<String, String> {
    // Reserve a namespace absent from the host page, including its existing IDs.
    let mut namespace = 0;
    while html.contains(&format!("selectable-svg-{namespace}-")) {
        namespace += 1;
    }
    let mut state = InlineState {
        prefix: format!("selectable-svg-{namespace}-"),
        occurrence: 0,
    };
    state.expand_images(html, 0)
}

struct InlineState {
    prefix: String,
    occurrence: usize,
}

impl InlineState {
    fn expand_images(&mut self, source: &str, depth: usize) -> Result<String, String> {
        let mut output = String::with_capacity(source.len());
        let mut end = 0;
        for captures in image_tokens().captures_iter(source) {
            let token = captures.get(0).unwrap();
            output.push_str(&source[end..token.start()]);
            if captures.name("image").is_some() {
                output.push_str(&self.expand_image(token.as_str(), depth)?);
            } else {
                // Comments and raw-text elements must not become active SVGs.
                output.push_str(token.as_str());
            }
            end = token.end();
        }
        output.push_str(&source[end..]);
        Ok(output)
    }

    fn expand_image(&mut self, image: &str, depth: usize) -> Result<String, String> {
        let wrapped = format!(
            r#"<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="{XLINK}">{image}</svg>"#
        );
        let Ok(image_doc) = Document::parse(&wrapped) else {
            return Ok(image.to_owned());
        };
        let image_node = image_doc.root_element().first_element_child().unwrap();
        let Some(uri) = image_node
            .attribute("href")
            .or_else(|| image_node.attribute((XLINK, "href")))
        else {
            return Ok(image.to_owned());
        };
        let Some(encoded) = uri.strip_prefix("data:image/svg+xml;base64,") else {
            return Ok(image.to_owned());
        };
        let Ok(bytes) = STANDARD.decode(encoded) else {
            return Ok(image.to_owned());
        };
        let Ok(decoded) = String::from_utf8(bytes) else {
            return Ok(image.to_owned());
        };
        let Ok(document) = Document::parse(&decoded) else {
            return Ok(image.to_owned());
        };
        let root = document.root_element();
        if root.tag_name().name() != "svg" {
            return Ok(image.to_owned());
        }
        if depth >= 16 {
            return Err("selectable SVG nesting exceeds 16 image layers".to_owned());
        }
        let svg = &decoded[root.range()];
        let expanded = self.expand_images(svg, depth + 1)?;
        if root.attribute(MARKER) != Some("true") && expanded == svg {
            return Ok(image.to_owned());
        }

        self.occurrence += 1;
        let prefix = format!("{}{}-", self.prefix, self.occurrence);
        let svg = prepare_svg(&expanded, image_node, &prefix)?;

        // The image's transform and presentation properties apply outside the
        // source SVG. A group preserves those independently of source properties.
        let mut group = String::from("<g");
        for attr in image_node.attributes() {
            if matches!(
                attr.name(),
                "href" | "x" | "y" | "width" | "height" | "preserveAspectRatio"
            ) {
                continue;
            }
            let name = &wrapped[attr.range_qname()];
            group.push_str(&format!(" {name}=\"{}\"", escape_attribute(attr.value())));
        }
        group.push('>');
        group.push_str(&svg);
        group.push_str("</g>");
        Ok(group)
    }
}

fn prepare_svg(source: &str, image: Node<'_, '_>, prefix: &str) -> Result<String, String> {
    let document =
        Document::parse(source).map_err(|err| format!("could not inline selectable SVG: {err}"))?;
    let root = document.root_element();
    let ids: HashMap<_, _> = root
        .descendants()
        .filter_map(|node| node.attribute("id"))
        .map(|id| (id.to_owned(), format!("{prefix}{id}")))
        .collect();
    let mut edits: Vec<(Range<usize>, String)> = Vec::new();
    for node in root.descendants().filter(Node::is_element) {
        for attr in node.attributes() {
            let value = if attr.name() == "id" {
                ids.get(attr.value()).cloned().unwrap_or_default()
            } else if attr.name() == "href" && attr.value().starts_with('#') {
                ids.get(&attr.value()[1..])
                    .map(|id| format!("#{id}"))
                    .unwrap_or_else(|| attr.value().to_owned())
            } else if matches!(attr.name(), "aria-labelledby" | "aria-describedby") {
                attr.value()
                    .split_whitespace()
                    .map(|id| ids.get(id).map_or(id, String::as_str))
                    .collect::<Vec<_>>()
                    .join(" ")
            } else {
                rewrite_urls(attr.value(), &ids)
            };
            if value != attr.value() {
                edits.push((attr.range_value(), escape_attribute(&value)));
            }
        }
        // Native Typst figures use presentation attributes. URL references in
        // optional SVG style blocks need the same scope as those attributes.
        if node.tag_name().name() == "style" {
            for child in node.children().filter(Node::is_text) {
                let raw = &source[child.range()];
                let rewritten = rewrite_urls(raw, &ids);
                if rewritten != raw {
                    edits.push((child.range(), rewritten));
                }
            }
        }
    }

    let mut geometry = vec![
        ("x", image.attribute("x").unwrap_or("0").to_owned()),
        ("y", image.attribute("y").unwrap_or("0").to_owned()),
        (
            "preserveAspectRatio",
            image
                .attribute("preserveAspectRatio")
                .unwrap_or("xMidYMid meet")
                .to_owned(),
        ),
        (MARKER, "true".to_owned()),
    ];
    for name in ["width", "height"] {
        if let Some(value) = image.attribute(name) {
            geometry.push((name, value.to_owned()));
        }
    }
    // With no explicit viewBox, an SVG image uses its intrinsic CSS-pixel size
    // as its coordinate system. Preserve that when changing the viewport size.
    if root.attribute("viewBox").is_none() {
        if let (Some(width), Some(height)) = (
            root.attribute("width").and_then(svg_length),
            root.attribute("height").and_then(svg_length),
        ) {
            geometry.push(("viewBox", format!("0 0 {width} {height}")));
        }
    }
    let mut extra = String::new();
    for (name, value) in geometry {
        if let Some(attr) = root.attributes().find(|attr| attr.name() == name) {
            // Geometry cannot also be an ID reference, so these edits are disjoint.
            edits.push((attr.range_value(), escape_attribute(&value)));
        } else {
            extra.push_str(&format!(" {name}=\"{}\"", escape_attribute(&value)));
        }
    }
    // Inserting immediately after the root name works for both <svg> and <svg/>.
    let name_end = source[root.range().start + 1..]
        .find(|ch: char| ch.is_ascii_whitespace() || ch == '>' || ch == '/')
        .map(|offset| root.range().start + 1 + offset)
        .ok_or_else(|| "selectable SVG has no opening tag".to_owned())?;
    edits.push((name_end..name_end, extra));
    edits.sort_by_key(|(range, _)| range.start);
    let mut output = source.to_owned();
    for (range, replacement) in edits.into_iter().rev() {
        output.replace_range(range, &replacement);
    }
    Ok(output)
}

fn rewrite_urls(value: &str, ids: &HashMap<String, String>) -> String {
    static URL: OnceLock<Regex> = OnceLock::new();
    URL.get_or_init(|| Regex::new(r##"url\(\s*["']?#([^\s)"']+)["']?\s*\)"##).unwrap())
        .replace_all(value, |capture: &Captures| {
            ids.get(&capture[1])
                .map(|id| format!("url(#{id})"))
                .unwrap_or_else(|| capture[0].to_owned())
        })
        .into_owned()
}

fn svg_length(value: &str) -> Option<f64> {
    let value = value.trim();
    let (number, multiplier) = [
        ("px", 1.0),
        ("pt", 96.0 / 72.0),
        ("pc", 16.0),
        ("in", 96.0),
        ("cm", 96.0 / 2.54),
        ("mm", 96.0 / 25.4),
    ]
    .into_iter()
    .find_map(|(unit, scale)| value.strip_suffix(unit).map(|number| (number, scale)))
    .unwrap_or((value, 1.0));
    let length = number.trim().parse::<f64>().ok()? * multiplier;
    (length.is_finite() && length > 0.0).then_some(length)
}

fn escape_attribute(value: &str) -> String {
    value
        .replace('&', "&amp;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
        .replace('<', "&lt;")
}

fn image_tokens() -> &'static Regex {
    static TOKENS: OnceLock<Regex> = OnceLock::new();
    TOKENS.get_or_init(|| {
        Regex::new(
            r#"(?s)<!--.*?-->|<!\[CDATA\[.*?\]\]>|<script\b[^>]*>.*?</script\s*>|<style\b[^>]*>.*?</style\s*>|(?P<image><image\b(?:[^<>"']|"[^"]*"|'[^']*')*(?:/\s*>|>\s*</image\s*>))"#,
        )
        .unwrap()
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn data_image(svg: &str, attrs: &str) -> String {
        format!(
            r#"<image {attrs} xlink:href="data:image/svg+xml;base64,{}"/>"#,
            STANDARD.encode(svg)
        )
    }

    fn figure(svg: &str) -> String {
        format!(
            r#"<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="{XLINK}"><g>{}</g></svg>"#,
            data_image(svg, r#"width="200" height="80" preserveAspectRatio="none""#)
        )
    }

    const SELECTABLE: &str = r##"<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" data-selectable-text="true" width="100pt" height="50pt" viewBox="0 0 100 50"><defs><path id="glyph" d="M0 0"/><clipPath id="clip"><use xlink:href="#glyph"/></clipPath></defs><g clip-path="url(#clip)"><use href="#glyph"/><text fill-opacity="0">A &amp; B &lt; C</text></g></svg>"##;

    #[test]
    fn exposes_text_and_preserves_viewport() {
        let output = inline_selectable_svgs(&figure(SELECTABLE)).unwrap();
        let document = Document::parse(&output).unwrap();
        assert!(!output.contains("data:image/"));
        let svg = document
            .descendants()
            .find(|node| node.attribute(MARKER) == Some("true"))
            .unwrap();
        assert_eq!(svg.attribute("viewBox"), Some("0 0 100 50"));
        assert_eq!(svg.attribute("width"), Some("200"));
        assert_eq!(svg.attribute("height"), Some("80"));
        assert_eq!(svg.attribute("preserveAspectRatio"), Some("none"));
        let text = svg
            .descendants()
            .find(|node| node.has_tag_name("text"))
            .unwrap();
        assert_eq!(text.text(), Some("A & B < C"));
    }

    #[test]
    fn separates_ids_and_their_fragment_references_per_occurrence() {
        let output =
            inline_selectable_svgs(&format!("{}{}", figure(SELECTABLE), figure(SELECTABLE)))
                .unwrap();
        let wrapped = format!("<div>{output}</div>");
        let document = Document::parse(&wrapped).unwrap();
        let ids: Vec<_> = document
            .descendants()
            .filter_map(|node| node.attribute("id"))
            .collect();
        assert_eq!(ids.len(), 4);
        assert!(ids.contains(&"selectable-svg-0-1-glyph"));
        assert!(ids.contains(&"selectable-svg-0-2-glyph"));
        for node in document.descendants() {
            if let Some(href) = node
                .attribute("href")
                .or_else(|| node.attribute((XLINK, "href")))
            {
                assert!(ids.contains(&href.trim_start_matches('#')));
            }
        }
        assert!(output.contains("url(#selectable-svg-0-1-clip)"));
        assert!(output.contains("url(#selectable-svg-0-2-clip)"));
    }

    #[test]
    fn keeps_external_raster_unmarked_and_commented_images_unchanged() {
        let unmarked =
            figure(r#"<svg xmlns="http://www.w3.org/2000/svg"><text>Keep as image</text></svg>"#);
        let marked = figure(SELECTABLE);
        let input = format!(
            r#"{unmarked}<image href="figure.svg"/><image href="data:image/png;base64,AAAA"/><!-- {marked} --><script>const source = '{marked}';</script>"#
        );
        assert_eq!(inline_selectable_svgs(&input).unwrap(), input);
    }

    #[test]
    fn preserves_image_and_source_transforms_and_escaped_attributes() {
        let svg = r#"<svg data-selectable-text="true" viewBox="0 0 10 10" transform="rotate(5)" aria-label="A &amp; B"><text>Hi</text></svg>"#;
        let image = data_image(
            svg,
            r#"x="3" y="4" width="40" height="60" transform="translate(2 8)" opacity=".5" aria-label="C &quot;D&quot;""#,
        );
        let output = inline_selectable_svgs(&image).unwrap();
        let document = Document::parse(&output).unwrap();
        let group = document.root_element();
        let svg = group.first_element_child().unwrap();
        assert_eq!(group.attribute("transform"), Some("translate(2 8)"));
        assert_eq!(group.attribute("opacity"), Some(".5"));
        assert_eq!(group.attribute("aria-label"), Some("C \"D\""));
        assert_eq!(svg.attribute("transform"), Some("rotate(5)"));
        assert_eq!(svg.attribute("aria-label"), Some("A & B"));
        assert_eq!(svg.attribute("x"), Some("3"));
        assert_eq!(svg.attribute("y"), Some("4"));
    }

    #[test]
    fn unwraps_nested_images_only_when_needed() {
        let inner = figure(SELECTABLE);
        let output = inline_selectable_svgs(&figure(&inner)).unwrap();
        assert!(!output.contains("data:image/"));
        assert_eq!(output.matches("<text").count(), 1);
        Document::parse(&output).unwrap();
    }

    #[test]
    fn handles_explicit_image_closing_tag_and_existing_page_ids() {
        let input = format!(
            r#"<div id="selectable-svg-0-existing">{}</div>"#,
            figure(SELECTABLE).replace("/></g></svg>", "></image></g></svg>")
        );
        let output = inline_selectable_svgs(&input).unwrap();
        assert!(output.contains(r#"id="selectable-svg-1-1-glyph""#));
        assert!(!output.contains("<image"));
    }

    #[test]
    fn synthesizes_intrinsic_viewbox_for_svg_without_one() {
        let svg =
            r#"<svg width="72pt" height="36pt" data-selectable-text="true"><text>Hi</text></svg>"#;
        let output = inline_selectable_svgs(&figure(svg)).unwrap();
        assert!(output.contains(r#"viewBox="0 0 96 48""#));
    }
}
