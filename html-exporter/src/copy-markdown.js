(() => {
  const MATH_HOLE = "[math not available as TeX]";
  const LINE_SELECTOR =
    "p, li, h1, h2, h3, h4, h5, h6, figcaption, pre, blockquote, dt, dd, tr, .equation, .equation-line";
  const SKIP_SELECTOR =
    ".lecture-rail, .permalink, .lecture-citation-sidenote, .compact-course-nav, .agentic-tools-control, .agentic-tools-hint, .toc, .line-id-label";
  const ELEMENT_NODE = 1;
  const TEXT_NODE = 3;

  function isElement(node) {
    return Boolean(node) && node.nodeType === ELEMENT_NODE;
  }

  function isText(node) {
    return Boolean(node) && node.nodeType === TEXT_NODE;
  }

  function classAttr(el) {
    if (!isElement(el)) return "";
    const value = el.getAttribute && el.getAttribute("class");
    if (typeof value === "string") return value;
    return typeof el.className === "string" ? el.className : "";
  }

  function classListOf(el) {
    return classAttr(el).split(/\s+/).filter(Boolean);
  }

  function closest(node, selector) {
    let el = isElement(node) ? node : node && node.parentElement;
    while (el) {
      if (el.matches && el.matches(selector)) return el;
      el = el.parentElement;
    }
    return null;
  }

  function ownerDoc(node) {
    if (!node) return null;
    if (node.nodeType === 9) return node;
    return node.ownerDocument || ownerDoc(node.parentNode);
  }

  function skipped(node) {
    const el = isElement(node) ? node : node && node.parentElement;
    return Boolean(el && el.closest && el.closest(SKIP_SELECTOR));
  }

  function isMath(el) {
    if (!isElement(el)) return false;
    if (el.getAttribute("role") === "math") return true;
    if (classListOf(el).includes("math-katex-source")) return true;
    if (el.hasAttribute && el.hasAttribute("data-tex")) return true;
    return Boolean(
      el.hasAttribute &&
        el.hasAttribute("data-math-display") &&
        el.hasAttribute("data-typst-math")
    );
  }

  function isDisplayMath(el) {
    return el.getAttribute("data-math-display") === "block";
  }

  function texFromMath(el) {
    const dataTex = el.getAttribute("data-tex");
    if (dataTex && dataTex.trim()) return dataTex;
    const annotation =
      el.querySelector && el.querySelector('annotation[encoding="application/x-tex"]');
    if (annotation && annotation.textContent && annotation.textContent.trim()) {
      return annotation.textContent;
    }
    const raw = (el.textContent || "").trim();
    const inline = raw.match(/^\\\((.*)\\\)$/s);
    if (inline) return inline[1];
    const block = raw.match(/^\\\[(.*)\\\]$/s);
    if (block) return block[1];
    return null;
  }

  function wrapTex(tex, display) {
    const trimmed = String(tex).replace(/^\s+|\s+$/g, "");
    if (display) return "$$" + trimmed + "$$";
    return "$" + trimmed + "$";
  }

  function mathToMarkdown(el) {
    const display = isDisplayMath(el);
    const tex = texFromMath(el);
    if (tex != null && tex.trim() !== "") return wrapTex(tex, display);
    const emptyKatex =
      classListOf(el).includes("math-katex-source") &&
      !(el.textContent || "").trim() &&
      !(el.querySelector && el.querySelector("svg"));
    if (emptyKatex) return "";
    return MATH_HOLE;
  }

  function rangeIntersects(range, node) {
    if (!range || !node) return false;
    if (typeof range.intersectsNode === "function") {
      try {
        return range.intersectsNode(node);
      } catch {
        return false;
      }
    }
    return true;
  }

  function sliceText(node, range) {
    if (!isText(node) || !rangeIntersects(range, node)) return "";
    let start = 0;
    let end = node.data.length;
    if (node === range.startContainer) start = range.startOffset;
    if (node === range.endContainer) end = range.endOffset;
    if (start < 0) start = 0;
    if (end > node.data.length) end = node.data.length;
    if (start >= end) return "";
    return node.data.slice(start, end);
  }

  function headingPrefix(el) {
    const level = parseInt(el.getAttribute("data-level") || "", 10);
    if (level >= 1 && level <= 6) return "#".repeat(level) + " ";
    const match = /^H([1-6])$/.exec(el.tagName || "");
    if (match) return "#".repeat(Number(match[1])) + " ";
    return "";
  }

  function listMarker(li) {
    const parent = li.parentElement;
    if (parent && (parent.tagName || "").toUpperCase() === "OL") {
      const items = Array.from(parent.children).filter(
        (child) => (child.tagName || "").toUpperCase() === "LI"
      );
      return items.indexOf(li) + 1 + ". ";
    }
    return "- ";
  }

  function listPrefix(el) {
    if ((el.tagName || "").toUpperCase() === "LI") return listMarker(el);
    const li = closest(el, "li");
    if (li && el.parentElement === li && (el.tagName || "").toUpperCase() === "P") {
      return listMarker(li);
    }
    return "";
  }

  function walkInner(node, range) {
    const parts = [];
    for (const child of Array.from(node.childNodes || [])) walk(child, range, parts);
    return parts.join("");
  }

  function walk(node, range, parts) {
    if (!node) return;
    if (isText(node)) {
      const slice = sliceText(node, range);
      if (slice) parts.push(slice);
      return;
    }
    if (!isElement(node)) return;
    if (skipped(node)) return;
    if (!rangeIntersects(range, node)) return;
    if (isMath(node)) {
      const math = mathToMarkdown(node);
      if (math) parts.push(math);
      return;
    }
    const tag = (node.tagName || "").toLowerCase();
    if (tag === "br") {
      parts.push("\n");
      return;
    }
    if (tag === "em" || tag === "i") {
      const inner = walkInner(node, range);
      if (inner) parts.push("*" + inner + "*");
      return;
    }
    if (tag === "strong" || tag === "b") {
      const inner = walkInner(node, range);
      if (inner) parts.push("**" + inner + "**");
      return;
    }
    if (tag === "code" && node.parentElement && (node.parentElement.tagName || "").toUpperCase() !== "PRE") {
      const inner = walkInner(node, range);
      if (inner) parts.push("`" + inner + "`");
      return;
    }
    if (tag === "a") {
      const inner = walkInner(node, range);
      const href = node.getAttribute("href") || "";
      if (!inner) return;
      parts.push(href ? "[" + inner + "](" + href + ")" : inner);
      return;
    }
    if (tag === "tr") {
      const cells = [];
      for (const child of Array.from(node.childNodes)) {
        if (!isElement(child)) continue;
        const childTag = (child.tagName || "").toLowerCase();
        if (childTag !== "td" && childTag !== "th") continue;
        if (!rangeIntersects(range, child)) continue;
        cells.push(walkInner(child, range).trim());
      }
      if (cells.length) parts.push(cells.join(" | "));
      return;
    }
    for (const child of Array.from(node.childNodes)) walk(child, range, parts);
  }

  function collapseText(text) {
    return text
      .replace(/\u00a0/g, " ")
      .replace(/[ \t]+\n/g, "\n")
      .replace(/\n[ \t]+/g, "\n")
      .replace(/[ \t]{2,}/g, " ")
      .replace(/\n{3,}/g, "\n\n");
  }

  function normalizeInline(text) {
    const re = /(\$\$[\s\S]*?\$\$|\$[^$]*\$|\[math not available as TeX\])/g;
    let last = 0;
    let out = "";
    let match;
    while ((match = re.exec(text))) {
      out += collapseText(text.slice(last, match.index));
      out += match[0];
      last = match.index + match[0].length;
    }
    out += collapseText(text.slice(last));
    return out;
  }

  function serializeLineBlock(block, range) {
    const parts = [];
    walk(block, range, parts);
    let text = parts.join("");
    if ((block.tagName || "").toUpperCase() !== "PRE") text = normalizeInline(text);
    text = text.replace(/^\s+|\s+$/g, "");
    if (!text) return "";
    const prefix = headingPrefix(block) || listPrefix(block);
    return prefix ? prefix + text : text;
  }

  function isNumberable(el) {
    if (!isElement(el) || !el.matches || !el.matches(LINE_SELECTOR)) return false;
    if (
      el.closest &&
      el.closest(".agentic-tools-control, .agentic-tools-hint, .lecture-citation-sidenote, .compact-course-nav, .toc")
    ) {
      return false;
    }
    if (classListOf(el).includes("lecture-kicker")) return false;
    if (classListOf(el).includes("equation") && el.querySelector && el.querySelector(".equation-line")) {
      return false;
    }
    if (el.querySelector && el.querySelector(LINE_SELECTOR)) return false;
    return true;
  }

  function lineBlocks(article) {
    if (!article || !article.querySelectorAll) return [];
    return Array.from(article.querySelectorAll(LINE_SELECTOR)).filter(isNumberable);
  }

  function clearLineIds(article) {
    if (!article || !article.querySelectorAll) return;
    for (const label of Array.from(article.querySelectorAll(".line-id-label"))) {
      if (label.parentNode) label.parentNode.removeChild(label);
    }
    for (const el of Array.from(article.querySelectorAll("[data-line-id]"))) {
      el.removeAttribute("data-line-id");
    }
  }

  function labelParent(el) {
    if ((el.tagName || "").toUpperCase() === "TR") {
      return (el.querySelector && (el.querySelector("th, td") || el)) || el;
    }
    return el;
  }

  function assignLineIds(article) {
    if (!article) return [];
    const doc = article.ownerDocument || (article.nodeType === 9 ? article : null);
    clearLineIds(article);
    const assigned = [];
    let n = 0;
    for (const el of lineBlocks(article)) {
      n += 1;
      const id = "L" + n;
      el.setAttribute("data-line-id", id);
      if (doc && doc.createElement) {
        const label = doc.createElement("span");
        label.className = "line-id-label";
        label.setAttribute("data-line-label", id);
        label.textContent = id;
        const host = labelParent(el);
        host.insertBefore(label, host.firstChild);
      }
      assigned.push(id);
    }
    return assigned;
  }

  function lineBlockFor(node) {
    let el = isElement(node) ? node : node && node.parentElement;
    while (el) {
      if (el.hasAttribute && el.hasAttribute("data-line-id")) return el;
      if (isNumberable(el)) return el;
      el = el.parentElement;
    }
    return null;
  }

  function lectureArticle(range) {
    const nested = closest(range.commonAncestorContainer, ".lecture-content");
    if (nested) return nested;
    const doc = ownerDoc(range.commonAncestorContainer);
    const article = doc && doc.querySelector && doc.querySelector(".lecture-content");
    if (article && rangeIntersects(range, article)) return article;
    return null;
  }

  function intersectingLineBlocks(range, article) {
    const blocks = lineBlocks(article);
    const hit = [];
    for (const block of blocks) {
      if (rangeIntersects(range, block)) hit.push(block);
    }
    if (hit.length) return hit;
    const fallback = lineBlockFor(range.commonAncestorContainer);
    return fallback ? [fallback] : [];
  }

  function selectionToMarkdown(selection, options) {
    options = options || {};
    if (!selection || !selection.rangeCount) return null;
    const range = selection.getRangeAt(0);
    if (!range || range.collapsed) return null;
    const article = lectureArticle(range);
    if (!article) return null;
    if (options.agentic) assignLineIds(article);
    const blocks = intersectingLineBlocks(range, article);
    const chunks = [];
    for (const block of blocks) {
      const inner = serializeLineBlock(block, range);
      if (!inner) continue;
      if (options.agentic) {
        const id = block.getAttribute("data-line-id");
        chunks.push(id ? "[" + id + "] " + inner : inner);
      } else {
        chunks.push(inner);
      }
    }
    if (!chunks.length) return null;
    return chunks.join("\n\n");
  }

  function isAgentic(doc) {
    return Boolean(doc && doc.documentElement && doc.documentElement.getAttribute("data-agentic-tools") === "on");
  }

  function setHint(doc, on) {
    const hint = doc.querySelector && doc.querySelector(".agentic-tools-hint");
    if (!hint) return;
    hint.hidden = !on;
  }

  function setAgentic(doc, on) {
    if (!doc || !doc.documentElement) return;
    const article = doc.querySelector && doc.querySelector(".lecture-content");
    const toggle = doc.querySelector && doc.querySelector("[data-agentic-tools-toggle]");
    if (on) {
      doc.documentElement.setAttribute("data-agentic-tools", "on");
      if (article) assignLineIds(article);
    } else {
      doc.documentElement.removeAttribute("data-agentic-tools");
      if (article) clearLineIds(article);
    }
    if (toggle && toggle.checked !== Boolean(on)) toggle.checked = Boolean(on);
    setHint(doc, on);
  }

  function install(doc) {
    if (!doc || doc.documentElement.getAttribute("data-lecture-copy") === "ready") return;
    doc.documentElement.setAttribute("data-lecture-copy", "ready");
    const toggle = doc.querySelector && doc.querySelector("[data-agentic-tools-toggle]");
    if (toggle) {
      toggle.checked = false;
      toggle.addEventListener("change", () => setAgentic(doc, Boolean(toggle.checked)));
    }
    setAgentic(doc, false);
    if (doc.defaultView) {
      doc.defaultView.addEventListener("pageshow", () => {
        if (!isAgentic(doc) && toggle) {
          toggle.checked = false;
          setAgentic(doc, false);
        }
      });
    }
    doc.addEventListener(
      "copy",
      (event) => {
        const md = selectionToMarkdown(doc.getSelection(), { agentic: isAgentic(doc) });
        if (md == null || !event.clipboardData) return;
        event.preventDefault();
        event.clipboardData.setData("text/plain", md);
        try {
          event.clipboardData.setData("text/markdown", md);
        } catch {
          // text/markdown is optional; plain text is the contract.
        }
      },
      true
    );
  }

  const api = {
    MATH_HOLE,
    LINE_SELECTOR,
    mathToMarkdown,
    selectionToMarkdown,
    assignLineIds,
    clearLineIds,
    setAgentic,
    isAgentic,
    lineBlockFor,
    install,
  };

  const global = typeof globalThis !== "undefined" ? globalThis : this;
  global.LectureCopy = api;
  if (typeof module === "object" && module.exports) module.exports = api;
  if (typeof document !== "undefined") install(document);
})();
