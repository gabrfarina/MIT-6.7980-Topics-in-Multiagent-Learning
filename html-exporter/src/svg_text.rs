//! Keep Typst's exact vector artwork and add selectable Unicode text over it.
//!
//! Typst's SVG exporter outlines every glyph. Replacing those outlines with
//! browser-shaped text changes mathematical variants, ligatures, and spacing.
//! A transparent text layer preserves the artwork while providing the original
//! characters and matching text boxes for selection, copying, and browser find.

use std::fmt::Write as _;
use typst::layout::{Frame, FrameItem, FrameKind, GroupItem, Point, Size, Transform};
use typst::model::Destination;
use typst::text::{FontStyle, TextItem};
use typst::visualize::{Curve, CurveItem};
use typst_layout::Page;

pub fn render(page: &Page) -> String {
    let mut svg = typst_svg::svg(page, &typst_svg::SvgOptions::default());
    let mut layer = TextLayer::default();
    layer.collect_links(&page.frame, Transform::identity());
    // typst-svg 0.15.1 writes URL attributes without XML escaping. Repair both
    // href forms before embedding the SVG (query-string '&' otherwise breaks it).
    for link in &layer.links {
        svg = svg.replace(
            &format!("href=\"{}\"", link.url),
            &format!("href=\"{}\"", escape(&link.url)),
        );
    }
    layer.frame(&page.frame, Transform::identity(), Transform::identity());
    svg = svg.replacen("<svg ", "<svg data-selectable-text=\"true\" ", 1);
    let end = svg.rfind("</svg>").expect("Typst exports a complete SVG");
    svg.insert_str(end, &format!(
        "<style>.svg-selectable-text text::selection{{fill:transparent;color:transparent;background:rgba(55,125,230,.3)}}</style><g class=\"svg-selectable-text\" style=\"user-select:text;-webkit-user-select:text\">{}</g>",
        layer.output,
    ));
    svg
}

#[derive(Default)]
struct TextLayer {
    output: String,
    clips: usize,
    links: Vec<LinkRegion>,
}

struct LinkRegion {
    url: String,
    inverse: Transform,
    size: Size,
}

impl TextLayer {
    fn collect_links(&mut self, frame: &Frame, transform: Transform) {
        for (position, item) in frame.items() {
            let transform = transform.pre_concat(Transform::translate(position.x, position.y));
            match item {
                FrameItem::Link(Destination::Url(url), size) => {
                    if let Some(inverse) = transform.invert() {
                        self.links.push(LinkRegion {
                            url: url.as_str().to_owned(),
                            inverse,
                            size: *size,
                        });
                    }
                }
                FrameItem::Group(group) => {
                    self.collect_links(&group.frame, transform.pre_concat(group.transform));
                }
                _ => {}
            }
        }
    }

    fn frame(&mut self, frame: &Frame, transform: Transform, world: Transform) {
        for (position, item) in frame.items() {
            let transform = transform.pre_concat(Transform::translate(position.x, position.y));
            let world = world.pre_concat(Transform::translate(position.x, position.y));
            match item {
                FrameItem::Text(text) => self.text(text, transform, world),
                FrameItem::Group(group) => self.group(group, transform, world),
                _ => {}
            }
        }
    }

    fn group(&mut self, group: &GroupItem, transform: Transform, world: Transform) {
        // Mirror typst-svg's treatment of hard and soft frames. In particular,
        // clip curves are already expressed in the hard frame's coordinates.
        let transform = transform.pre_concat(group.transform);
        self.output.push_str("<g");
        let transform = if group.frame.kind() == FrameKind::Hard {
            write!(self.output, " transform=\"{}\"", matrix(transform)).unwrap();
            Transform::identity()
        } else {
            transform
        };
        if let Some(curve) = &group.clip {
            let id = self.clips;
            self.clips += 1;
            write!(self.output, " clip-path=\"url(#selectable-clip-{id})\"><defs><clipPath id=\"selectable-clip-{id}\" clipPathUnits=\"userSpaceOnUse\"><path d=\"{}\"/></clipPath></defs>",
                curve_path(curve, Point::new(transform.tx, transform.ty))).unwrap();
        } else {
            self.output.push('>');
        }
        self.frame(&group.frame, transform, world.pre_concat(group.transform));
        self.output.push_str("</g>");
    }

    fn text(&mut self, text: &TextItem, transform: Transform, world: Transform) {
        if text.text.is_empty() || text.glyphs.is_empty() {
            return;
        }
        let info = text.font.font().info();
        let family = if info.family == "Source Sans 3" {
            "'Source Sans 3', sans-serif"
        } else {
            &info.family
        };
        let style = match info.variant.style {
            FontStyle::Normal => "normal",
            FontStyle::Italic => "italic",
            FontStyle::Oblique => "oblique",
        };
        // Emit one Unicode run, not one node per glyph: a ligature or a glyph
        // assembled from multiple pieces must not duplicate the copied text.
        let first = &text.glyphs[0];
        // The vector SVG's link rectangles sit below this overlay. Give the
        // selectable run the same destination, so it doesn't intercept clicks.
        // Hit-test in each link's local coordinates, including nested transforms.
        let center = Point::new(text.width() / 2.0, -text.size / 4.0).transform(world);
        let link = self.links.iter().rev().find(|link| {
            let point = center.transform(link.inverse);
            point.x.to_pt() >= 0.0
                && point.y.to_pt() >= 0.0
                && point.x <= link.size.x
                && point.y <= link.size.y
        });
        let cursor = if let Some(link) = link {
            write!(self.output, "<a href=\"{}\">", escape(&link.url)).unwrap();
            "pointer"
        } else {
            "text"
        };
        write!(self.output,
            "<text transform=\"{}\" x=\"{}\" y=\"{}\" font-family=\"{}\" font-size=\"{}\" font-weight=\"{}\" font-style=\"{style}\" xml:space=\"preserve\" style=\"fill:transparent;stroke:none;white-space:pre;user-select:text;-webkit-user-select:text;pointer-events:all;cursor:{cursor}\"",
            matrix(transform), first.x_offset.at(text.size).to_pt(),
            -first.y_offset.at(text.size).to_pt(), escape(family),
            text.size.to_pt(), info.variant.weight.to_number(),
        ).unwrap();
        let width = text.width().to_pt();
        if width > 0.0 {
            write!(
                self.output,
                " textLength=\"{width}\" lengthAdjust=\"spacingAndGlyphs\""
            )
            .unwrap();
        }
        write!(self.output, ">{}</text>", escape(&text.text)).unwrap();
        if link.is_some() {
            self.output.push_str("</a>");
        }
    }
}

fn matrix(transform: Transform) -> String {
    format!(
        "matrix({} {} {} {} {} {})",
        transform.sx.get(),
        transform.ky.get(),
        transform.kx.get(),
        transform.sy.get(),
        transform.tx.to_pt(),
        transform.ty.to_pt()
    )
}

fn curve_path(curve: &Curve, offset: Point) -> String {
    let mut path = String::new();
    for item in &curve.0 {
        match *item {
            CurveItem::Move(point) | CurveItem::Line(point) => {
                let command = if matches!(item, CurveItem::Move(_)) {
                    'M'
                } else {
                    'L'
                };
                write!(
                    path,
                    "{command} {} {} ",
                    (point.x + offset.x).to_pt(),
                    (point.y + offset.y).to_pt()
                )
                .unwrap();
            }
            CurveItem::Cubic(a, b, c) => {
                write!(
                    path,
                    "C {} {} {} {} {} {} ",
                    (a.x + offset.x).to_pt(),
                    (a.y + offset.y).to_pt(),
                    (b.x + offset.x).to_pt(),
                    (b.y + offset.y).to_pt(),
                    (c.x + offset.x).to_pt(),
                    (c.y + offset.y).to_pt()
                )
                .unwrap();
            }
            CurveItem::Close => path.push_str("Z "),
        }
    }
    path
}

fn escape(value: &str) -> String {
    // XML 1.0 forbids most C0 controls and the two noncharacters below.
    // Preserve legitimate whitespace and Unicode math/formatting characters.
    let value: String = value
        .chars()
        .filter(|&c| {
            matches!(c, '\t' | '\n' | '\r') || (c >= ' ' && c != '\u{fffe}' && c != '\u{ffff}')
        })
        .collect();
    value
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
}

#[cfg(test)]
mod tests {
    use super::*;
    use typst::foundations::{Bytes, Content, Smart};
    use typst::layout::{Abs, Em, Ratio, Sides, Size};
    use typst::syntax::Span;
    use typst::text::{Font, Glyph, Lang};
    use typst::visualize::Color;

    fn text(value: &str) -> TextItem {
        let size = Abs::pt(12.0);
        let font = Font::new(
            Bytes::new(include_bytes!("../assets/fonts/SourceSans3-Regular.ttf").to_vec()),
            0,
        )
        .unwrap()
        .instantiate(Default::default(), size, &Default::default());
        let glyph_id = font.ttf().glyph_index('A').unwrap().0;
        TextItem {
            font,
            size,
            fill: Color::BLACK.into(),
            stroke: None,
            lang: Lang::ENGLISH,
            region: None,
            text: value.into(),
            glyphs: vec![Glyph {
                id: glyph_id,
                x_advance: Em::new(2.0),
                x_offset: Em::zero(),
                y_advance: Em::zero(),
                y_offset: Em::zero(),
                range: 0..value.len() as u16,
                span: (Span::detached(), 0),
            }],
        }
    }

    #[test]
    fn preserves_unicode_and_ligature_source_once_and_escapes_xml() {
        let mut layer = TextLayer::default();
        let mut item = text("ffi < α & β > \"x\"");
        // Two glyphs from the same source cluster still produce one copy.
        item.glyphs.push(item.glyphs[0].clone());
        layer.text(&item, Transform::identity(), Transform::identity());
        assert_eq!(layer.output.matches("ffi").count(), 1);
        assert!(
            layer
                .output
                .contains("ffi &lt; α &amp; β &gt; &quot;x&quot;")
        );
        assert!(layer.output.contains("textLength=\"48\""));
        assert!(
            layer
                .output
                .contains("font-family=\"&apos;Source Sans 3&apos;, sans-serif\"")
        );
        assert!(layer.output.contains("pointer-events:all"));
        assert_eq!(escape("a\u{0}\u{8}\u{fffe}\u{ffff}β\n\t"), "aβ\n\t");
    }

    #[test]
    fn nested_transform_and_clip_match_vector_coordinate_system() {
        let mut inner = Frame::soft(Size::splat(Abs::pt(50.0)));
        inner.push(
            Point::new(Abs::pt(3.0), Abs::pt(4.0)),
            FrameItem::Text(text("x")),
        );
        let mut group = GroupItem::new(inner);
        group.transform = Transform::scale(Ratio::new(2.0), Ratio::new(3.0));
        group.clip = Some(Curve::rect(Size::splat(Abs::pt(40.0))));
        let mut hard = Frame::hard(Size::splat(Abs::pt(100.0)));
        hard.push(
            Point::new(Abs::pt(5.0), Abs::pt(7.0)),
            FrameItem::Group(group),
        );
        let mut layer = TextLayer::default();
        layer.group(
            &GroupItem::new(hard),
            Transform::translate(Abs::pt(11.0), Abs::pt(13.0)),
            Transform::translate(Abs::pt(11.0), Abs::pt(13.0)),
        );
        assert!(
            layer
                .output
                .contains("<g transform=\"matrix(1 0 0 1 11 13)\"")
        );
        assert!(
            layer
                .output
                .contains("<text transform=\"matrix(2 0 0 3 11 19)\"")
        );
        assert!(
            layer
                .output
                .contains("clip-path=\"url(#selectable-clip-0)\"")
        );
        assert!(layer.output.contains("M 5 7 L 45 7 L 45 47 L 5 47 Z"));
    }

    #[test]
    fn keeps_original_vector_artwork_and_adds_selection_layer() {
        let mut frame = Frame::soft(Size::splat(Abs::pt(50.0)));
        frame.push(
            Point::new(Abs::pt(5.0), Abs::pt(20.0)),
            FrameItem::Text(text("α")),
        );
        let page = Page {
            frame,
            bleed: Sides::default(),
            fill: Smart::Custom(None),
            numbering: None,
            supplement: Content::empty(),
            number: 1,
        };
        let original = typst_svg::svg(&page, &typst_svg::SvgOptions::default());
        let result = render(&page);
        let artwork = &original[original.find('>').unwrap() + 1..original.rfind("</svg>").unwrap()];
        assert!(result.contains(artwork));
        assert!(result.contains("data-selectable-text=\"true\""));
        assert!(result.contains(">α</text>"));
        assert!(result.contains("<use "));
    }
}
