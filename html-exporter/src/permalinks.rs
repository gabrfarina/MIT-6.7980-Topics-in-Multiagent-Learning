//! Add shareable URLs without replacing Typst's native cross-reference targets.

use scraper::{ElementRef, Html, Node, Selector};
use std::collections::HashMap;

use crate::{element_text, escape_attr, heading_text_from_html, heading_title_html, slugify};

pub fn add_permalinks(body: &str) -> (String, HashMap<String, String>) {
    let mut dom = Html::parse_fragment(body);
    let targets = Selector::parse(
        ".notes-heading, section.env.statement, section.env.proof, section.changelog, figure.rendered-figure, .equation-line:has(> .eqno)",
    )
    .unwrap();
    let all_ids = Selector::parse("[id]").unwrap();
    let mut ids: HashMap<_, _> = dom
        .select(&all_ids)
        .map(|element| (element.value().id().unwrap().to_owned(), element.id()))
        .collect();
    // Reserve authored labels before assigning fallbacks, regardless of order.
    let labels: HashMap<_, _> = dom
        .select(&targets)
        .filter_map(|element| {
            element
                .value()
                .attr("data-label")
                .map(|label| (label_id(label), element.id()))
        })
        .collect();
    let mut heading_ids = HashMap::new();
    let mut changes = Vec::new();
    let mut counts: HashMap<String, usize> = HashMap::new();
    let permalink_selector = Selector::parse(".permalink").unwrap();

    for target in dom.select(&targets) {
        // A link owned by a nested statement or proof does not decorate its
        // enclosing proof. Only skip targets that already have their own link.
        if target.select(&permalink_selector).any(|link| {
            link.ancestors()
                .filter_map(ElementRef::wrap)
                .find(|ancestor| targets.matches(ancestor))
                .is_some_and(|owner| owner.id() == target.id())
        }) {
            continue;
        }
        if target
            .value()
            .has_class("equation-line", scraper::CaseSensitivity::CaseSensitive)
            && target
                .ancestors()
                .filter_map(ElementRef::wrap)
                .any(|element| {
                    element
                        .value()
                        .has_class("equation-block", scraper::CaseSensitivity::CaseSensitive)
                })
        {
            continue;
        }
        let (kind, description, fallback, host) = if target
            .value()
            .has_class("notes-heading", scraper::CaseSensitivity::CaseSensitive)
        {
            let title = heading_text_from_html(&heading_title_html(&target));
            let description = format!("section: {title}");
            ("section".to_owned(), description, slugify(&title), target)
        } else if target
            .value()
            .has_class("changelog", scraper::CaseSensitivity::CaseSensitive)
        {
            (
                "changelog".to_owned(),
                "changelog".to_owned(),
                "changelog".to_owned(),
                child(&target, ".changelog-title").unwrap_or(target),
            )
        } else if target
            .value()
            .has_class("proof", scraper::CaseSensitivity::CaseSensitive)
        {
            let name = target.value().attr("data-proof-kind").unwrap_or("Proof");
            let kind = slugify(name);
            let count = counts.entry(kind.clone()).or_default();
            *count += 1;
            let description = format!("{name} {count}");
            (kind, description.clone(), slugify(&description), target)
        } else if target.value().name() == "section" {
            let kind = child(&target, ".env-kind")
                .map(|el| element_text(&el))
                .unwrap_or_else(|| "Statement".to_owned());
            let number = child(&target, ".env-number")
                .map(|el| el.text().collect::<String>())
                .unwrap_or_default();
            let description = format!("{kind} {number}").trim().to_owned();
            (
                slugify(&kind),
                description.clone(),
                slugify(&description),
                target,
            )
        } else if target.value().name() == "figure" {
            let kind = target
                .value()
                .attr("data-figure-kind")
                .unwrap_or("figure")
                .to_owned();
            let count = counts.entry(kind.clone()).or_default();
            *count += 1;
            let number = target
                .value()
                .attr("data-figure-number")
                .filter(|number| !number.is_empty())
                .map(str::to_owned)
                .unwrap_or_else(|| count.to_string());
            let description = format!("{kind} {number}");
            let host = target
                .child_elements()
                .find(|element| element.value().name() == "figcaption")
                .or_else(|| child(&target, ".algorithm .env-title"))
                .unwrap_or(target);
            (kind, description.clone(), slugify(&description), host)
        } else {
            let host = child(&target, ".eqno").unwrap();
            let description = format!("equation {}", element_text(&host));
            (
                "equation".to_owned(),
                description.clone(),
                slugify(&description),
                host,
            )
        };

        let base = target
            .value()
            .attr("data-label")
            .filter(|label| !label.is_empty())
            .map(label_id)
            .unwrap_or(fallback);
        let mut id = base.clone();
        let mut suffix = 2;
        loop {
            let existing_here = ids.get(&id).is_none_or(|existing| {
                target.descendants().any(|node| node.id() == *existing)
                    || target.ancestors().any(|node| node.id() == *existing)
            });
            let reserved_here = labels.get(&id).is_none_or(|owner| *owner == target.id());
            if existing_here && reserved_here {
                break;
            }
            id = format!("{base}-{suffix}");
            suffix += 1;
        }

        if kind == "section" {
            if let Some(old_id) = target.value().id() {
                heading_ids.insert(old_id.to_owned(), id.clone());
            }
        }
        // Aligned equation rows use display:contents. Their number provides a
        // real box for scrolling; other aliases sit at the top of the block.
        let anchor_host = if kind == "equation" || kind == "changelog" {
            host
        } else {
            target
        };
        // Native line anchors are hidden metadata spans. Relocate them to a
        // visible box too, so both old and new URLs work without JavaScript.
        let native_anchors: Vec<_> = if kind == "equation" {
            target
                .select(&Selector::parse(".equation-anchor[id]").unwrap())
                .map(|anchor| (anchor.id(), anchor_element(anchor.value().id().unwrap())))
                .collect()
        } else {
            Vec::new()
        };
        let alias = if ids.contains_key(&id) {
            None
        } else {
            ids.insert(id.clone(), target.id());
            Some(anchor_element(&id))
        };
        let in_caption = host.value().name() == "figcaption";
        let equation = if kind == "equation" {
            target
                .ancestors()
                .filter_map(ElementRef::wrap)
                .find(|element| {
                    element
                        .value()
                        .has_class("equation", scraper::CaseSensitivity::CaseSensitive)
                })
                .map(|element| element.id())
        } else {
            None
        };
        let class = if in_caption {
            "permalink permalink-caption"
        } else if kind == "equation" {
            "permalink permalink-equation"
        } else if kind == "section" || kind == "algorithm" || target.value().name() == "section" {
            "permalink permalink-gutter"
        } else if host.id() == target.id() {
            "permalink permalink-corner"
        } else {
            "permalink"
        };
        let link = empty_element(&format!(
            "<a class=\"{class}\" href=\"#{}\" aria-label=\"Permalink to {}\" title=\"Permalink to {}\"></a>",
            fragment_id(&id), escape_attr(&description), escape_attr(&description)
        ));
        changes.push((
            host.id(),
            anchor_host.id(),
            native_anchors,
            alias,
            link,
            in_caption,
            equation,
        ));
    }

    // Add these after collecting the enclosing blocks, so a nested footnote
    // never makes its enclosing theorem look as though it already has a link.
    for note in dom.select(&Selector::parse(".footnote[id]").unwrap()) {
        if child(&note, ".permalink-note").is_some() {
            continue;
        }
        let Some(seq) = note
            .value()
            .id()
            .and_then(|id| id.strip_prefix("fn-side-"))
            .and_then(|seq| seq.parse::<usize>().ok())
        else {
            continue;
        };
        let number = child(&note, ".footnote-num")
            .map(|number| element_text(&number))
            .unwrap_or_else(|| seq.to_string());
        changes.push((
            note.id(),
            note.id(),
            Vec::new(),
            None,
            empty_element(&footnote_link(seq, &number)),
            true,
            None,
        ));
    }

    let mut equation_blocks = HashMap::new();
    for (host, anchor_host, native_anchors, alias, link, in_caption, equation) in changes {
        for (node_id, element) in native_anchors {
            *dom.tree.get_mut(node_id).unwrap().value() = element;
            dom.tree.get_mut(anchor_host).unwrap().prepend_id(node_id);
        }
        if let Some(alias) = alias {
            dom.tree.get_mut(anchor_host).unwrap().prepend(alias);
        }
        if let Some(equation) = equation {
            // Keep the controls outside the formula's horizontal scroll area.
            let block = *equation_blocks.entry(equation).or_insert_with(|| {
                let block = dom
                    .tree
                    .get_mut(equation)
                    .unwrap()
                    .insert_before(empty_element("<div class=\"equation-block\"></div>"))
                    .id();
                dom.tree.get_mut(block).unwrap().append_id(equation);
                block
            });
            dom.tree.get_mut(block).unwrap().append(link);
        } else if in_caption {
            dom.tree.get_mut(host).unwrap().prepend(link);
        } else {
            dom.tree.get_mut(host).unwrap().append(link);
        }
    }
    (dom.root_element().inner_html(), heading_ids)
}

pub fn footnote_link(seq: usize, number: &str) -> String {
    let description = escape_attr(&format!("Permalink to footnote {number}"));
    format!("<a class=\"permalink permalink-note\" href=\"#fn-end-{seq}\" aria-label=\"{description}\" title=\"{description}\"></a>")
}

fn child<'a>(element: &ElementRef<'a>, selector: &str) -> Option<ElementRef<'a>> {
    element.select(&Selector::parse(selector).unwrap()).next()
}

fn empty_element(html: &str) -> Node {
    Node::Element(
        Html::parse_fragment(html)
            .root_element()
            .child_elements()
            .next()
            .unwrap()
            .value()
            .clone(),
    )
}

fn anchor_element(id: &str) -> Node {
    empty_element(&format!(
        "<span class=\"permalink-anchor\" id=\"{}\"></span>",
        escape_attr(id)
    ))
}

fn label_id(label: &str) -> String {
    // HTML IDs cannot contain whitespace; all other authored characters stay.
    label.split_whitespace().collect::<Vec<_>>().join("-")
}

// Percent-encode UTF-8 labels for an actual URL fragment, not just HTML attrs.
pub(crate) fn fragment_id(id: &str) -> String {
    let mut fragment = String::new();
    for byte in id.bytes() {
        if byte.is_ascii_alphanumeric() || b"-._~:".contains(&byte) {
            fragment.push(byte as char);
        } else {
            use std::fmt::Write;
            write!(fragment, "%{byte:02X}").unwrap();
        }
    }
    fragment
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn changelog_links_stay_stable_when_entries_change_and_keep_the_dates() {
        let body = r#"<section class="changelog" data-label="changelog"><hr><p class="changelog-title"><strong>Changelog</strong></p><ul><li>2025-10-05: Fixed typos (thanks Eric Yang Yu!).</li></ul></section>"#;
        let (html, headings) = add_permalinks(body);
        let dom = Html::parse_fragment(&html);
        let link = dom
            .select(&Selector::parse(".changelog-title > a.permalink-gutter").unwrap())
            .next()
            .unwrap();
        assert_eq!(link.value().attr("href"), Some("#changelog"));
        assert_eq!(
            link.value().attr("aria-label"),
            Some("Permalink to changelog")
        );
        assert_eq!(
            dom.select(&Selector::parse("#changelog").unwrap()).count(),
            1
        );
        assert!(html.contains("2025-10-05: Fixed typos (thanks Eric Yang Yu!)."));
        assert!(headings.is_empty());
        assert_eq!(add_permalinks(&html).0, html);

        let (updated, _) = add_permalinks(
            &body.replace("</ul>", "<li>2026-09-12: Added a clarification.</li></ul>"),
        );
        assert!(updated.contains(r##"href="#changelog""##));

        let (collision, _) = add_permalinks(&format!(
            r#"<h2 class="notes-heading">Changelog</h2>{body}"#
        ));
        let dom = Html::parse_fragment(&collision);
        let heading_link = dom
            .select(&Selector::parse(".notes-heading > a.permalink").unwrap())
            .next()
            .unwrap();
        assert_eq!(heading_link.value().attr("href"), Some("#changelog-2"));
        let changelog_link = dom
            .select(&Selector::parse(".changelog-title > a.permalink").unwrap())
            .next()
            .unwrap();
        assert_eq!(changelog_link.value().attr("href"), Some("#changelog"));
    }

    #[test]
    fn labeled_targets_keep_native_ids_and_links_and_expose_authored_labels() {
        let body = r##"<h2 class="notes-heading" id="loc-1" data-label="sec:idea" data-number="8.2"><span class="secno">8.2</span>An <em>idea</em> <a href="#loc-2">Theorem 1</a></h2>
<section class="env statement" id="loc-2" data-label="thm:idea"><span id="theorem-l8-1"></span><p class="env-heading"><span class="env-title"><strong class="env-kind">Theorem</strong><strong class="env-number">L8.1</strong></span></p><div class="env-body">Proof.</div></section>
<figure class="rendered-figure" id="loc-3" data-label="tab:notation" data-figure-kind="table" data-figure-number="1"><table><tr><td>A</td></tr></table><figcaption><span class="figcaption-label">Table 1.</span>Notation.</figcaption></figure>
<figure class="rendered-figure" data-label="algo:cfr" data-figure-kind="algorithm" data-figure-number="2"><div class="figure-body"><section class="env algorithm"><p class="env-title">CFR</p></section></div><figcaption><span class="figcaption-label">Algorithm 2.</span>CFR caption.</figcaption></figure>"##;
        let (html, headings) = add_permalinks(body);
        let dom = Html::parse_fragment(&html);
        let links: Vec<_> = dom
            .select(&Selector::parse("a.permalink").unwrap())
            .collect();
        assert_eq!(links.len(), 4);
        assert_eq!(
            dom.select(
                &Selector::parse(
                    ".notes-heading > .permalink-gutter, .env.statement > .permalink-gutter"
                )
                .unwrap()
            )
            .count(),
            2
        );
        assert_eq!(headings["loc-1"], "sec:idea");
        for id in [
            "loc-1",
            "loc-2",
            "loc-3",
            "theorem-l8-1",
            "sec:idea",
            "thm:idea",
            "tab:notation",
            "algo:cfr",
        ] {
            assert_eq!(
                dom.select(&Selector::parse("[id]").unwrap())
                    .filter(|el| el.value().id() == Some(id))
                    .count(),
                1,
                "{id}"
            );
        }
        assert!(html.contains(r##"href="#loc-2">Theorem 1</a>"##));
        assert!(html.contains("<em>idea</em>"));
        assert_eq!(
            dom.select(
                &Selector::parse("figcaption > .permalink-caption:first-child + .figcaption-label")
                    .unwrap()
            )
            .count(),
            2
        );
        assert!(links
            .iter()
            .all(|link| link.value().attr("aria-label").is_some()));
        assert_eq!(add_permalinks(&html).0, html);
    }

    #[test]
    fn captionless_algorithms_keep_a_title_permalink() {
        let (html, _) = add_permalinks(
            r#"<figure class="rendered-figure" data-figure-kind="algorithm"><div class="figure-body"><section class="env algorithm"><div class="env-title">CFR</div></section></div></figure>"#,
        );
        let dom = Html::parse_fragment(&html);
        assert_eq!(
            dom.select(&Selector::parse(".algorithm > .env-title > .permalink-gutter").unwrap())
                .count(),
            1
        );
        assert_eq!(
            dom.select(&Selector::parse("a.permalink").unwrap()).count(),
            1
        );
    }

    #[test]
    fn proofs_sketches_and_solutions_have_unique_labeled_or_numbered_links() {
        let body = r##"<section class="env proof" id="loc-proof" data-proof-kind="Proof" data-label="proof:α"><p class="env-heading">Proof.</p><p>First proof.</p></section>
<section class="env proof" data-proof-kind="Proof"><p>Second proof.</p></section>
<section class="env proof" data-proof-kind="Proof Sketch"><p>A sketch.</p></section>
<section class="env proof" data-proof-kind="Solution" data-label="proof-2"><p>A solution.</p></section>
<section class="env proof" data-proof-kind="Solution"><p>Another solution.</p></section>
<a href="#loc-proof">Original reference</a>"##;
        let (html, headings) = add_permalinks(body);
        let dom = Html::parse_fragment(&html);
        let links: Vec<_> = dom
            .select(&Selector::parse(".proof > .permalink-gutter").unwrap())
            .collect();
        assert_eq!(
            links
                .iter()
                .map(|link| link.value().attr("href").unwrap())
                .collect::<Vec<_>>(),
            [
                "#proof:%CE%B1",
                "#proof-2-2",
                "#proof-sketch-1",
                "#proof-2",
                "#solution-2"
            ]
        );
        assert_eq!(
            links[2].value().attr("aria-label"),
            Some("Permalink to Proof Sketch 1")
        );
        assert!(html.contains(r##"href="#loc-proof">Original reference</a>"##));
        assert!(html.contains("First proof."));
        assert!(headings.is_empty());
        for id in [
            "loc-proof",
            "proof:α",
            "proof-2-2",
            "proof-sketch-1",
            "proof-2",
            "solution-2",
        ] {
            assert_eq!(
                dom.select(&Selector::parse("[id]").unwrap())
                    .filter(|element| element.value().id() == Some(id))
                    .count(),
                1
            );
        }
        assert_eq!(add_permalinks(&html).0, html);
    }

    #[test]
    fn nested_proofs_get_their_own_links_even_with_decorated_statements() {
        let (statement, _) = add_permalinks(
            r#"<section class="env statement"><p class="env-heading"><span class="env-kind">Claim</span><span class="env-number">L5.1</span></p><p>A claim.</p></section>"#,
        );
        let body = format!(
            r#"<section class="env proof" data-proof-kind="Proof"><p class="env-heading">Proof.</p>{statement}<section class="env proof" data-proof-kind="Proof"><p class="env-heading">Proof of the claim.</p><p>Nested argument.</p></section></section>"#
        );
        let (html, _) = add_permalinks(&body);
        let dom = Html::parse_fragment(&html);
        let links: Vec<_> = dom
            .select(&Selector::parse(".proof > .permalink-gutter").unwrap())
            .map(|link| link.value().attr("href").unwrap())
            .collect();
        assert_eq!(links, ["#proof-2", "#proof-1"]);
        assert_eq!(
            dom.select(&Selector::parse(".statement > .permalink-gutter").unwrap())
                .count(),
            1
        );
        assert_eq!(add_permalinks(&html).0, html);
    }

    #[test]
    fn fallback_ids_are_unique_and_do_not_steal_authored_labels() {
        let body = r#"<h2 class="notes-heading">Overview</h2><h2 class="notes-heading">Overview</h2><h2 class="notes-heading" data-label="overview">Other title</h2><figure class="rendered-figure" data-figure-kind="table" data-figure-number="1"></figure><figure class="rendered-figure" data-figure-kind="table" data-figure-number="1"></figure>"#;
        let (html, _) = add_permalinks(body);
        let dom = Html::parse_fragment(&html);
        let links: Vec<_> = dom
            .select(&Selector::parse("a.permalink").unwrap())
            .map(|el| el.value().attr("href").unwrap())
            .collect();
        assert_eq!(
            links,
            [
                "#overview-2",
                "#overview-3",
                "#overview",
                "#table-1",
                "#table-1-2"
            ]
        );
    }

    #[test]
    fn headings_are_stable_when_numbers_change_and_labels_are_url_encoded() {
        let body = r#"<h2 class="notes-heading" id="loc-5" data-number="8.1"><span class="secno">8.1</span>Overview</h2><h2 class="notes-heading" data-label="sec:α&amp;&quot;">Unicode</h2>"#;
        let (html, ids) = add_permalinks(body);
        let (_, renumbered) = add_permalinks(&body.replace("8.1", "9.3"));
        assert_eq!(ids, renumbered);
        assert_eq!(ids["loc-5"], "overview");
        assert!(html.contains("#sec:%CE%B1%26%22"));
        assert!(html.contains("sec:α&amp;&quot;"));
    }

    #[test]
    fn numbered_equations_link_at_the_number_without_altering_math() {
        let body = r#"<figure class="equation equation-aligned"><div class="equation-line" data-label="eq:sum"><span class="equation-align-left" data-typst-math="[a]">a</span><span class="equation-align-right">= b</span><span class="eqno">(1)</span><span class="equation-anchor" id="loc-8" hidden></span></div><div class="equation-line"><span class="eqno">(2)</span></div><div class="equation-line">unnumbered</div></figure>"#;
        let (html, _) = add_permalinks(body);
        let dom = Html::parse_fragment(&html);
        assert_eq!(
            dom.select(&Selector::parse(".equation-block > .permalink").unwrap())
                .count(),
            2
        );
        assert_eq!(
            dom.select(&Selector::parse(".eqno > .permalink-anchor").unwrap())
                .count(),
            3
        );
        assert!(html.contains("#eq:sum"));
        assert!(html.contains("#equation-2"));
        assert!(
            html.contains(r#"<span class="equation-align-left" data-typst-math="[a]">a</span>"#)
        );
        assert!(html.contains("loc-8"));
        assert!(!html.contains("hidden"));
        assert_eq!(add_permalinks(&html).0, html);
        assert_eq!(
            dom.select(&Selector::parse(".equation-block > .permalink-equation").unwrap())
                .count(),
            2
        );
    }

    #[test]
    fn nested_footnotes_get_links_without_suppressing_the_enclosing_statement() {
        let (html, _) = add_permalinks(
            r#"<section class="env statement"><p class="env-heading"><span class="env-kind">Theorem</span><span class="env-number">1</span></p><span class="footnote" id="fn-side-1"><span class="footnote-num">*</span>Some explanation.</span></section>"#,
        );
        let dom = Html::parse_fragment(&html);
        assert_eq!(
            dom.select(&Selector::parse(".statement > .permalink-gutter").unwrap())
                .count(),
            1
        );
        let link = dom
            .select(&Selector::parse(".footnote > .permalink-note:first-child").unwrap())
            .next()
            .unwrap();
        assert_eq!(link.value().attr("href"), Some("#fn-end-1"));
        assert_eq!(
            link.value().attr("aria-label"),
            Some("Permalink to footnote *")
        );
        assert_eq!(add_permalinks(&html).0, html);
    }

    #[test]
    fn whitespace_labels_become_valid_ids_without_colliding() {
        let (html, _) = add_permalinks(
            r#"<h2 class="notes-heading" data-label="sec:an idea">One</h2><h2 class="notes-heading" data-label="sec:an-idea">Two</h2>"#,
        );
        let dom = Html::parse_fragment(&html);
        let ids: Vec<_> = dom
            .select(&Selector::parse("[id]").unwrap())
            .map(|el| el.value().id().unwrap())
            .collect();
        assert_eq!(ids, ["sec:an-idea-2", "sec:an-idea"]);
    }
}
