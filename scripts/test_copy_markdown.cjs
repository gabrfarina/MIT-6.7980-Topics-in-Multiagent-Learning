#!/usr/bin/env node
"use strict";

const assert = require("node:assert/strict");
const LectureCopy = require("../html-exporter/src/copy-markdown.js");

const ELEMENT_NODE = 1;
const TEXT_NODE = 3;
const DOCUMENT_POSITION_PRECEDING = 2;
const DOCUMENT_POSITION_FOLLOWING = 4;
const DOCUMENT_POSITION_CONTAINS = 8;
const DOCUMENT_POSITION_CONTAINED_BY = 16;

function contains(parent, node) {
  let cur = node;
  while (cur) {
    if (cur === parent) return true;
    cur = cur.parentNode;
  }
  return false;
}

function rootOf(node) {
  let cur = node;
  while (cur.parentNode) cur = cur.parentNode;
  return cur;
}

function preorder(node, out = []) {
  out.push(node);
  if (node.childNodes) {
    for (const child of node.childNodes) preorder(child, out);
  }
  return out;
}

function compareDocumentPosition(a, b) {
  if (a === b) return 0;
  if (contains(a, b) && a !== b) return DOCUMENT_POSITION_CONTAINED_BY;
  if (contains(b, a) && a !== b) return DOCUMENT_POSITION_CONTAINS;
  const order = preorder(rootOf(a));
  const ia = order.indexOf(a);
  const ib = order.indexOf(b);
  if (ia < ib) return DOCUMENT_POSITION_FOLLOWING;
  if (ib < ia) return DOCUMENT_POSITION_PRECEDING;
  return 0;
}

function isAncestor(a, b) {
  return contains(a, b) && a !== b;
}

function matchesSimple(el, part) {
  part = part.trim();
  if (!part) return false;
  const tagged = part.match(/^([a-z][\w-]*)(\[.+\])?$/i);
  const attrEq = part.match(/\[([^=\]]+)="([^"]*)"\]/);
  const attrOnly = part.match(/^\[([^\]]+)\]$/);
  if (tagged && tagged[2] && attrEq) {
    return el.tagName.toLowerCase() === tagged[1].toLowerCase()
      && el.getAttribute(attrEq[1]) === attrEq[2];
  }
  if (attrEq && part.startsWith("[")) return el.getAttribute(attrEq[1]) === attrEq[2];
  if (attrOnly) return el.hasAttribute(attrOnly[1]);
  if (part.startsWith(".")) return classList(el).includes(part.slice(1));
  const bits = part.split(".");
  const tag = bits[0];
  if (tag && el.tagName.toLowerCase() !== tag.toLowerCase()) return false;
  return bits.slice(1).every((name) => classList(el).includes(name));
}

function matches(el, selector) {
  return selector.split(",").some((part) => matchesSimple(el, part));
}

function classList(el) {
  return (el.getAttribute("class") || "").split(/\s+/).filter(Boolean);
}

function descendants(root) {
  const out = [];
  function walk(node) {
    for (const child of node.childNodes || []) {
      if (child.nodeType === ELEMENT_NODE) {
        out.push(child);
        walk(child);
      }
    }
  }
  walk(root);
  return out;
}

function makeText(data) {
  const node = {
    nodeType: TEXT_NODE,
    data,
    childNodes: [],
    parentNode: null,
    ownerDocument: null,
    get textContent() {
      return this.data;
    },
    get parentElement() {
      return this.parentNode && this.parentNode.nodeType === ELEMENT_NODE ? this.parentNode : null;
    },
    compareDocumentPosition(other) {
      return compareDocumentPosition(this, other);
    },
  };
  return node;
}

function makeEl(tag, attrs = {}) {
  const el = {
    nodeType: ELEMENT_NODE,
    tagName: tag.toUpperCase(),
    attrs: { ...attrs },
    childNodes: [],
    parentNode: null,
    ownerDocument: null,
    get parentElement() {
      return this.parentNode && this.parentNode.nodeType === ELEMENT_NODE ? this.parentNode : null;
    },
    get firstChild() {
      return this.childNodes[0] || null;
    },
    get className() {
      return this.attrs.class || "";
    },
    set className(value) {
      this.attrs.class = value;
    },
    get textContent() {
      return this.childNodes.map((child) => child.textContent).join("");
    },
    set textContent(value) {
      this.childNodes = [];
      if (value) this.appendChild(makeText(value));
    },
    getAttribute(name) {
      return Object.prototype.hasOwnProperty.call(this.attrs, name) ? this.attrs[name] : null;
    },
    setAttribute(name, value) {
      this.attrs[name] = String(value);
    },
    removeAttribute(name) {
      delete this.attrs[name];
    },
    hasAttribute(name) {
      return Object.prototype.hasOwnProperty.call(this.attrs, name);
    },
    matches(selector) {
      return matches(this, selector);
    },
    closest(selector) {
      let cur = this;
      while (cur) {
        if (cur.nodeType === ELEMENT_NODE && matches(cur, selector)) return cur;
        cur = cur.parentElement;
      }
      return null;
    },
    querySelector(selector) {
      return this.querySelectorAll(selector)[0] || null;
    },
    querySelectorAll(selector) {
      return descendants(this).filter((node) => matches(node, selector));
    },
    insertBefore(node, ref) {
      if (node.parentNode) {
        const siblings = node.parentNode.childNodes;
        const at = siblings.indexOf(node);
        if (at >= 0) siblings.splice(at, 1);
      }
      node.parentNode = this;
      node.ownerDocument = this.ownerDocument;
      if (!ref) {
        this.childNodes.push(node);
        return node;
      }
      const index = this.childNodes.indexOf(ref);
      if (index < 0) this.childNodes.push(node);
      else this.childNodes.splice(index, 0, node);
      return node;
    },
    appendChild(node) {
      return this.insertBefore(node, null);
    },
    removeChild(node) {
      const index = this.childNodes.indexOf(node);
      if (index >= 0) this.childNodes.splice(index, 1);
      node.parentNode = null;
      return node;
    },
    contains(node) {
      return contains(this, node);
    },
    compareDocumentPosition(other) {
      return compareDocumentPosition(this, other);
    },
  };
  return el;
}

function attach(parent, child) {
  parent.appendChild(child);
  return child;
}

function h(tag, attrs, ...kids) {
  const el = makeEl(tag, attrs);
  for (const kid of kids) {
    if (kid == null) continue;
    if (typeof kid === "string") el.appendChild(makeText(kid));
    else el.appendChild(kid);
  }
  return el;
}

function makeDocument(article) {
  const doc = {
    nodeType: 9,
    parentNode: null,
    childNodes: [],
    documentElement: null,
    body: null,
    createElement(tag) {
      const el = makeEl(tag);
      el.ownerDocument = doc;
      return el;
    },
    querySelector(selector) {
      return this.querySelectorAll(selector)[0] || null;
    },
    querySelectorAll(selector) {
      return descendants(this.documentElement || this).filter((node) => matches(node, selector));
    },
  };
  const html = makeEl("html");
  const body = makeEl("body");
  html.ownerDocument = doc;
  body.ownerDocument = doc;
  article.ownerDocument = doc;
  doc.documentElement = html;
  doc.body = body;
  html.appendChild(body);
  body.appendChild(article);
  function stamp(node) {
    node.ownerDocument = doc;
    for (const child of node.childNodes || []) stamp(child);
  }
  stamp(html);
  return doc;
}

function intersectsNode(range, node) {
  if (node === range.startContainer || node === range.endContainer) return true;
  if (isAncestor(node, range.startContainer) || isAncestor(node, range.endContainer)) return true;
  const startPos = compareDocumentPosition(range.startContainer, node);
  const endPos = compareDocumentPosition(range.endContainer, node);
  const followsStart = Boolean(startPos & DOCUMENT_POSITION_FOLLOWING);
  const precedesEnd = Boolean(endPos & DOCUMENT_POSITION_PRECEDING);
  return followsStart && precedesEnd;
}

function commonAncestor(a, b) {
  const seen = new Set();
  let cur = a;
  while (cur) {
    seen.add(cur);
    cur = cur.parentNode;
  }
  cur = b;
  while (cur) {
    if (seen.has(cur)) return cur;
    cur = cur.parentNode;
  }
  return a;
}

function makeRange(startNode, startOffset, endNode, endOffset) {
  const range = {
    startContainer: startNode,
    startOffset,
    endContainer: endNode,
    endOffset,
    collapsed: startNode === endNode && startOffset === endOffset,
    get commonAncestorContainer() {
      return commonAncestor(this.startContainer, this.endContainer);
    },
    intersectsNode(node) {
      return intersectsNode(this, node);
    },
  };
  return {
    rangeCount: 1,
    isCollapsed: range.collapsed,
    getRangeAt() {
      return range;
    },
  };
}

function findText(root, snippet) {
  return preorder(root).find((node) => node.nodeType === TEXT_NODE && node.data.includes(snippet));
}

function renderedMath(attrs, glyph) {
  return h(
    "span",
    {
      class: "math-katex-source katex-display",
      role: "math",
      style: "font-size: 48px",
      "data-typst-math": "sequence([x], [≤], [y])",
      ...attrs,
    },
    glyph
  );
}

function annotationMath(display, tex, glyph) {
  const annotation = h("annotation", { encoding: "application/x-tex" }, tex);
  const katex = h("span", { class: "katex" }, h("span", { class: "katex-html" }, glyph), annotation);
  return h(
    "span",
    {
      class: "math-katex-source",
      role: "math",
      "data-math-display": display,
      "data-typst-math": "sequence([x])",
    },
    katex
  );
}

let failed = 0;
function check(name, fn) {
  try {
    fn();
    console.log("ok", name);
  } catch (err) {
    failed += 1;
    console.error("FAIL", name);
    console.error(err && err.stack ? err.stack : err);
  }
}

check("native KaTeX glyphs are not the copied math", () => {
  const glyph = "𝑥≤𝑦";
  const el = renderedMath({ "data-math-display": "inline", "data-tex": "x\\le y" }, glyph);
  const md = LectureCopy.mathToMarkdown(el);
  assert.equal(md, "$x\\le y$");
  assert.notEqual(md, glyph);
  assert.ok(!md.includes("sequence("));
  assert.ok(!md.includes("𝑥"));
});

check("data-math-display is the inline vs display switch, not rendered size", () => {
  const glyph = "𝑥≤𝑦";
  const inline = renderedMath({ "data-math-display": "inline", "data-tex": "x\\le y" }, glyph);
  const display = renderedMath({ "data-math-display": "block", "data-tex": "x\\le y" }, glyph);
  assert.equal(LectureCopy.mathToMarkdown(inline), "$x\\le y$");
  assert.equal(LectureCopy.mathToMarkdown(display), "$$x\\le y$$");
});

check("KaTeX annotation is used when data-tex is absent", () => {
  const el = annotationMath("inline", "x\\le y", "𝑥≤𝑦");
  assert.equal(LectureCopy.mathToMarkdown(el), "$x\\le y$");
  assert.notEqual(LectureCopy.mathToMarkdown(el), el.textContent);
});

check("SVG-fallback math is an honest hole, not empty $ $ and not Typst AST", () => {
  const el = h(
    "span",
    {
      role: "math",
      "data-math-display": "inline",
      "data-typst-math": "mystery(value: [x])",
    },
    h("svg", {}, "glyph")
  );
  const md = LectureCopy.mathToMarkdown(el);
  assert.equal(md, LectureCopy.MATH_HOLE);
  assert.equal(md.includes("mystery"), false);
  assert.equal(/^\s*\$\s*\$\s*$/.test(md), false);
});

check("a mid-paragraph fragment keeps its line id when agentic tools are on", () => {
  const p = h("p", {}, "Hello world, this is a test of fragments.");
  const article = h("article", { class: "lecture-content" }, p);
  makeDocument(article);
  const text = findText(p, "this is");
  const start = text.data.indexOf("this is");
  const selection = makeRange(text, start, text, start + "this is".length);
  const on = LectureCopy.selectionToMarkdown(selection, { agentic: true });
  const off = LectureCopy.selectionToMarkdown(selection, { agentic: false });
  assert.equal(on, "[L1] this is");
  assert.equal(off, "this is");
  assert.ok(on.startsWith("[L1]"));
  assert.notEqual(on, p.textContent);
});

check("copying a math span in a sentence uses TeX, not rendered KaTeX", () => {
  const math = renderedMath({ "data-math-display": "inline", "data-tex": "x" }, "𝑥");
  const p = h("p", {}, "Payoff ", math, " is 1.");
  const article = h("article", { class: "lecture-content" }, p);
  makeDocument(article);
  const start = findText(p, "Payoff");
  const end = findText(p, "is 1.");
  const md = LectureCopy.selectionToMarkdown(makeRange(start, 0, end, end.data.length), {
    agentic: false,
  });
  assert.equal(md, "Payoff $x$ is 1.");
  assert.notEqual(md, p.textContent);
  assert.equal(md.includes("𝑥"), false);
});

check("headings and emphasis survive; permalinks do not dump", () => {
  const heading = h(
    "h2",
    { class: "notes-heading", "data-level": "2" },
    h("span", { class: "secno" }, "1.2"),
    " ",
    h("em", {}, "Nash"),
    " ",
    h("a", { class: "permalink", href: "#loc-nash" }, "¶")
  );
  const article = h("article", { class: "lecture-content" }, heading);
  makeDocument(article);
  const text = findText(heading, "Nash");
  const md = LectureCopy.selectionToMarkdown(makeRange(heading, 0, text, text.data.length), {
    agentic: false,
  });
  assert.match(md, /^## /);
  assert.match(md, /\*Nash\*/);
  assert.equal(md.includes("¶"), false);
  assert.equal(md.includes("#loc-nash"), false);
});

check("citation sidenotes do not dump into the note", () => {
  const aside = h("aside", { class: "lecture-citation-sidenote" }, "@misc{do-not-copy}");
  const p = h("p", {}, "Body text about equilibria.");
  const article = h("article", { class: "lecture-content" }, aside, p);
  makeDocument(article);
  const start = findText(aside, "@misc");
  const end = findText(p, "Body text");
  const md = LectureCopy.selectionToMarkdown(
    makeRange(start, 0, end, end.data.length),
    { agentic: false }
  );
  assert.equal(md.includes("@misc"), false);
  assert.equal(md.includes("Body text about equilibria."), true);
});

check("line ids are assigned only to lecture blocks, not chrome", () => {
  const nav = h("nav", { class: "compact-course-nav" }, h("p", {}, "Course home"));
  const p = h("p", {}, "Only this paragraph is a line.");
  const article = h("article", { class: "lecture-content" }, nav, p);
  makeDocument(article);
  const ids = LectureCopy.assignLineIds(article);
  assert.deepEqual(ids, ["L1"]);
  assert.equal(p.getAttribute("data-line-id"), "L1");
  assert.equal(nav.querySelector("p").hasAttribute("data-line-id"), false);
});

if (failed) {
  console.error(failed + " test(s) failed");
  process.exit(1);
}
console.log("All copy-markdown contract tests passed.");
