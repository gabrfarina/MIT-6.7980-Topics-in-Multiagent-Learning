(() => {
  const article = document.querySelector(".lecture-content");
  if (!article) return;
  const desktop = window.matchMedia("(min-width: 1280px)");
  const notes = Array.from(article.querySelectorAll(
    ".lecture-citation-sidenote, .citation-note, .footnote, .rendered-figure > figcaption"
  ));
  const properties = ["position", "float", "clear", "margin", "width", "left", "top"];
  const originalStyles = new Map(notes.map(note => [note,
    properties.map(property => [property, note.style.getPropertyValue(property)])
  ]));
  const anchorFor = note => {
    if (note.matches("figcaption")) return note.parentElement;
    if (note.matches(".lecture-citation-sidenote")) return article;
    if (note.matches(".footnote")) {
      return document.getElementById(note.id.replace("fn-side-", "fnref-"));
    }
    return note.closest(".citation-wrap");
  };

  function layout() {
    if (!desktop.matches) {
      for (const note of notes) {
        for (const [property, value] of originalStyles.get(note)) {
          if (value) note.style.setProperty(property, value);
          else note.style.removeProperty(property);
        }
      }
      return;
    }

    // Remove every note from text flow before measuring. In particular, a
    // caption's nested citations must not create a second margin column or
    // contribute their heights to the caption's own box.
    for (const note of notes) {
      Object.assign(note.style, {
        position: "absolute", float: "none", clear: "none", margin: "0px",
        width: "var(--sidenote-width)", left: "0px", top: "0px"
      });
    }
    const style = getComputedStyle(article);
    const railLeft = article.getBoundingClientRect().right
      + parseFloat(style.getPropertyValue("--sidenote-gap"));
    const gap = .7 * parseFloat(getComputedStyle(document.documentElement).fontSize);
    let bottom = -Infinity;

    // DOM order puts a caption before its nested citations. Measure each anchor
    // after placing its parent, so those references follow the caption on the
    // same rail. Local offsets also work inside proofs, quotes and figure grids.
    for (const note of notes) {
      if (!note.getClientRects().length) continue;
      const anchor = anchorFor(note);
      if (!anchor) continue;
      const origin = note.getBoundingClientRect();
      const top = Math.max(anchor.getBoundingClientRect().top, bottom + gap);
      note.style.left = `${railLeft - origin.left}px`;
      note.style.top = `${top - origin.top}px`;
      bottom = top + origin.height;
    }
  }

  let scheduled = false;
  function schedule() {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => {
      scheduled = false;
      layout();
    });
  }
  const observer = new ResizeObserver(schedule);
  observer.observe(article);
  notes.forEach(note => observer.observe(note));
  window.addEventListener("resize", schedule);
  window.addEventListener("load", schedule);
  desktop.addEventListener("change", schedule);
  document.fonts.ready.then(schedule);
  document.fonts.addEventListener("loadingdone", schedule);
  layout();
})();
