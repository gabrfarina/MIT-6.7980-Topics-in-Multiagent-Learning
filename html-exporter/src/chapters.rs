use serde::{Deserialize, Deserializer};
use std::collections::HashSet;
use std::fs;
use std::path::Path;

#[derive(Clone, Debug, Deserialize)]
pub(crate) struct ExportConfig {
    #[serde(default)]
    pub(crate) site: SiteConfig,
    pub(crate) how_to_cite: CitationConfig,
    #[serde(rename = "notes")]
    pub(crate) chapters: Vec<ChapterNav>,
}

#[derive(Clone, Debug, Default, Deserialize)]
pub(crate) struct SiteConfig {
    #[serde(default)]
    pub(crate) event: Option<String>,
    #[serde(default)]
    pub(crate) term: Option<String>,
    #[serde(default)]
    pub(crate) title: Option<String>,
    #[serde(default)]
    pub(crate) authors: Option<String>,
    #[serde(default)]
    pub(crate) index_href: Option<String>,
    #[serde(default)]
    pub(crate) github: Option<String>,
}

#[derive(Clone, Debug, Deserialize)]
pub(crate) struct CitationConfig {
    pub(crate) authors: String,
    pub(crate) key_prefix: String,
    pub(crate) booktitle: String,
    pub(crate) title_template: String,
    #[serde(default)]
    pub(crate) note_template: Option<String>,
    pub(crate) year: u16,
    pub(crate) url_prefix: String,
}

#[derive(Clone, Debug, Deserialize)]
pub(crate) struct ChapterNav {
    // Current course number, or an S-prefixed supplementary reading number.
    #[serde(deserialize_with = "deserialize_chapter_number")]
    pub(crate) number: String,
    pub(crate) source: String,
    pub(crate) short_title: String,
    #[serde(default)]
    pub(crate) syllabus_numbers: Vec<u8>,
    #[serde(default)]
    pub(crate) supplementary: bool,
}

impl ExportConfig {
    pub(crate) fn load(path: &Path) -> Result<Self, String> {
        let json = fs::read_to_string(path)
            .map_err(|err| format!("could not read export config {}: {err}", path.display()))?;
        let book: Self = serde_json::from_str(&json)
            .map_err(|err| format!("could not parse export config {}: {err}", path.display()))?;
        book.validate(path)?;
        Ok(book)
    }

    pub(crate) fn current_index_for_input(&self, input: &Path) -> Option<usize> {
        let input_file = input.file_name()?.to_string_lossy();
        self.chapters.iter().position(|chapter| {
            Path::new(&chapter.source)
                .file_name()
                .is_some_and(|source_file| source_file == input_file.as_ref())
        })
    }

    fn validate(&self, path: &Path) -> Result<(), String> {
        self.site.validate(path)?;
        self.how_to_cite.validate(path)?;

        if self.chapters.is_empty() {
            return Err(format!("export config {} has no lectures", path.display()));
        }

        let mut numbers = HashSet::new();
        let mut sources = HashSet::new();
        let mut hrefs = HashSet::new();
        for chapter in &self.chapters {
            if chapter.number.trim().is_empty() {
                return Err(format!(
                    "export config {} contains an empty lecture number",
                    path.display()
                ));
            }
            if chapter.source.trim().is_empty() {
                return Err(format!(
                    "export config {} contains a lecture with an empty source",
                    path.display()
                ));
            }
            if chapter.short_title.trim().is_empty() {
                return Err(format!(
                    "export config {} contains a lecture with an empty short_title",
                    path.display()
                ));
            }
            if !numbers.insert(chapter.number.as_str()) {
                return Err(format!(
                    "export config {} repeats lecture number {}",
                    path.display(),
                    chapter.number
                ));
            }
            if !sources.insert(chapter.source.as_str()) {
                return Err(format!(
                    "export config {} repeats source {}",
                    path.display(),
                    chapter.source
                ));
            }
            let href = chapter.href()?;
            if !hrefs.insert(href.clone()) {
                return Err(format!(
                    "export config {} repeats derived href {}",
                    path.display(),
                    href
                ));
            }
        }

        Ok(())
    }
}

impl SiteConfig {
    fn validate(&self, path: &Path) -> Result<(), String> {
        validate_optional_nonempty(path, "site.event", &self.event)?;
        validate_optional_nonempty(path, "site.term", &self.term)?;
        validate_optional_nonempty(path, "site.title", &self.title)?;
        validate_optional_nonempty(path, "site.authors", &self.authors)?;
        validate_optional_nonempty(path, "site.index_href", &self.index_href)?;
        validate_optional_nonempty(path, "site.github", &self.github)?;
        Ok(())
    }
}

impl CitationConfig {
    pub(crate) fn citation_title(&self, number: &str, title: &str) -> String {
        apply_chapter_template(&self.title_template, number, title)
    }

    pub(crate) fn citation_note(&self, number: &str, title: &str) -> Option<String> {
        self.note_template
            .as_deref()
            .map(|template| apply_chapter_template(template, number, title))
    }

    pub(crate) fn citation_url(&self, href: &str) -> String {
        format!("{}{}", self.url_prefix, href)
    }

    fn validate(&self, path: &Path) -> Result<(), String> {
        if self.authors.trim().is_empty() {
            return Err(format!(
                "export config {} has empty authors",
                path.display()
            ));
        }
        if self.key_prefix.trim().is_empty() {
            return Err(format!(
                "export config {} has empty key_prefix",
                path.display()
            ));
        }
        if self.booktitle.trim().is_empty() {
            return Err(format!(
                "export config {} has empty booktitle",
                path.display()
            ));
        }
        if self.title_template.trim().is_empty() {
            return Err(format!(
                "export config {} has empty title_template",
                path.display()
            ));
        }
        if self
            .note_template
            .as_ref()
            .is_some_and(|template| template.trim().is_empty())
        {
            return Err(format!(
                "export config {} has empty note_template",
                path.display()
            ));
        }
        if self.url_prefix.trim().is_empty() {
            return Err(format!(
                "export config {} has empty url_prefix",
                path.display()
            ));
        }
        if self.url_prefix.trim() != self.url_prefix {
            return Err(format!(
                "export config {} has url_prefix with surrounding whitespace",
                path.display()
            ));
        }
        Ok(())
    }
}

fn validate_optional_nonempty(
    path: &Path,
    field: &str,
    value: &Option<String>,
) -> Result<(), String> {
    if value.as_ref().is_some_and(|value| value.trim().is_empty()) {
        return Err(format!(
            "export config {} has empty {field}",
            path.display()
        ));
    }
    Ok(())
}

impl ChapterNav {
    pub(crate) fn navigation_number(&self) -> String {
        if self.supplementary {
            return self.number.clone();
        }
        match self.syllabus_numbers.as_slice() {
            [] => self.number.parse::<u8>().map_or_else(
                |_| self.number.clone(),
                |number| format!("{number:02}"),
            ),
            numbers => numbers.iter().map(|number| format!("{number:02}")).collect::<Vec<_>>().join("–"),
        }
    }

    pub(crate) fn course_label(&self) -> String {
        if self.supplementary {
            format!("Supplementary reading {}", self.number)
        } else {
            format!("Lecture {}", self.number)
        }
    }

    pub(crate) fn href(&self) -> Result<String, String> {
        let source = Path::new(&self.source);
        let stem = source
            .file_stem()
            .ok_or_else(|| format!("lecture source {} has no file stem", self.source))?
            .to_string_lossy();
        Ok(format!("{stem}.html"))
    }
}

fn deserialize_chapter_number<'de, D: Deserializer<'de>>(deserializer: D) -> Result<String, D::Error> {
    #[derive(Deserialize)]
    #[serde(untagged)]
    enum Number {
        Integer(u8),
        Label(String),
    }
    Ok(match Number::deserialize(deserializer)? {
        Number::Integer(number) => number.to_string(),
        Number::Label(label) => label,
    })
}

fn apply_chapter_template(template: &str, number: &str, title: &str) -> String {
    let label = if number.starts_with('S') {
        format!("Supplementary reading {number}")
    } else {
        format!("Lecture {number}")
    };
    template
        .replace("{number}", number)
        .replace("{label}", &label)
        .replace("{title}", title)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn finds_current_chapter_by_input_file_name() {
        let book = ExportConfig {
            site: SiteConfig::default(),
            how_to_cite: citation_config(),
            chapters: vec![ChapterNav {
                number: "4".to_owned(),
                source: "notes/P4-multicalibration.typ".to_owned(),
                short_title: "Multicalibration".to_owned(),
                syllabus_numbers: vec![],
                supplementary: false,
            }],
        };

        assert_eq!(
            book.current_index_for_input(Path::new("P4-multicalibration.typ")),
            Some(0)
        );
    }

    #[test]
    fn derives_href_from_source_file() {
        let chapter = ChapterNav {
            number: "4".to_owned(),
            source: "notes/P4-multicalibration.typ".to_owned(),
            short_title: "Multicalibration".to_owned(),
            syllabus_numbers: vec![],
            supplementary: false,
        };

        assert_eq!(chapter.href().as_deref(), Ok("P4-multicalibration.html"));
    }

    #[test]
    fn applies_citation_templates() {
        let config = citation_config();

        assert_eq!(
            config.citation_title("2", "Beyond Normal Form"),
            "Lecture 2: Beyond Normal Form"
        );
        assert_eq!(
            config.citation_note("2", "Beyond Normal Form"),
            Some("Lecture 2 of the ACM EC 2026 tutorial notes".to_owned())
        );
    }

    #[test]
    fn omits_citation_note_when_template_is_absent() {
        let mut config = citation_config();
        config.note_template = None;

        assert_eq!(config.citation_note("2", "Beyond Normal Form"), None);
    }

    #[test]
    fn prefixes_citation_urls() {
        let config = citation_config();
        assert_eq!(
            config.citation_url("P2.html"),
            "https://example.com/notes/P2.html"
        );
    }

    #[test]
    fn supports_zero_and_supplementary_numbers() {
        for (json_number, expected) in [("0", "0"), (r#""S3""#, "S3")] {
            let chapter: ChapterNav = serde_json::from_str(&format!(
                r#"{{"number": {json_number}, "source": "notes.typ", "short_title": "Notes"}}"#
            )).unwrap();
            assert_eq!(chapter.number, expected);
        }
        let mut config = citation_config();
        config.title_template = "{label}: {title}".to_owned();
        assert_eq!(config.citation_title("S3", "Learning algorithms"),
                   "Supplementary reading S3: Learning algorithms");
    }

    fn citation_config() -> CitationConfig {
        CitationConfig {
            authors: "A. Author".to_owned(),
            key_prefix: "notes".to_owned(),
            booktitle: "Example Tutorial".to_owned(),
            title_template: "Lecture {number}: {title}".to_owned(),
            note_template: Some("Lecture {number} of the ACM EC 2026 tutorial notes".to_owned()),
            year: 2026,
            url_prefix: "https://example.com/notes/".to_owned(),
        }
    }
}
