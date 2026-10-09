// Let readers try Example L2.3 on a game of their own. The improvement
// function, the coloring rule, and the boundary tie-breaks are ported from the
// figure sources, so the widget agrees with the static plots above it:
// content/figures/libs/nash.typ and content/figures/brouwer/example_games.typ.
(() => {
  // Take 36 samples of the figures' conic gradient from nash_cmap.
  const cmap = ("ffdc00 ebd54b d8cd68 c4c67d b1bd8e 9db59c 8aaca8 76a3b3 6199bd 4c8fc7 3383cf 1177d7 "
    + "3075d2 4c76c8 6276be 7476b4 8575aa 94739f a37095 b26d8a c0697e cd6472 db5d65 e85556 "
    + "f54b46 ff4636 ff5935 ff6934 ff7832 ff8630 ff932e ffa02a ffac27 ffb822 ffc41b ffd011").split(" ");
  const fill = { r: "#ff4136", b: "#0074d9", y: "#ffdc00" };
  const edge = { r: "#b22e26", b: "#005198", y: "#b29a00" };
  const triangle = "#abebb3";
  const rule = "#666666";
  const seed = "#e09ee9";
  const width = 100;
  const height = 78.31; // 0.83 : 0.65, the cell aspect used by the figures.

  const presets = {
    "Theater or football": [[[0, 5], [1, 0]], [[0, 1], [5, 0]]],
    "Prisoner's dilemma": [[[-1, -3], [0, -2]], [[-1, 0], [-3, -2]]],
    "Penalty shot game": [[[-1, 1], [1, -1]], [[1, -1], [-1, 1]]],
  };

  // Port softbr, the Nash improvement function of content/figures/libs/nash.typ.
  const softbr = (x, U, opp) => {
    const grad = U.map(row => row[0] * opp[0] + row[1] * opp[1]);
    const ut = grad[0] * x[0] + grad[1] * x[1];
    const gain = grad.map(g => Math.max(0, g - ut));
    return x.map((xi, i) => (xi + gain[i]) / (1 + gain[0] + gain[1]));
  };

  // Measure the displacement f(z) - z at the profile where P1 plays its second
  // action with probability p and P2 with probability q.
  const displacement = (A1, A2) => {
    const A2T = [[A2[0][0], A2[1][0]], [A2[0][1], A2[1][1]]];
    return (p, q) => [softbr([1 - p, p], A1, [1 - q, q])[1] - p, softbr([1 - q, q], A2T, [1 - p, p])[1] - q];
  };

  // Blend the two nearest samples of nash_cmap.sample(atan2(dp, dq) - 45deg).
  const fieldFill = (dp, dq) => {
    const t = ((((Math.atan2(dq, dp) * 180) / Math.PI - 45) % 360 + 360) % 360) / 10;
    const i = Math.floor(t);
    const [lo, hi] = [i, i + 1].map(k => [0, 2, 4].map(o => parseInt(cmap[k % 36].slice(o, o + 2), 16)));
    return "#" + lo.map((v, k) => Math.round(v + (hi[k] - v) * (t - i)).toString(16).padStart(2, "0")).join("");
  };

  // Color the lattice from the improvement direction, with the boundary
  // tie-breaks of Section L2.1.1.
  const colorGrid = (N, delta) =>
    Array.from({ length: N + 1 }, (_, i) => Array.from({ length: N + 1 }, (_, j) => {
      const [dp, dq] = delta(j / N, (N - i) / N);
      let ch = "b";
      if (dp >= 0 && dq >= 0) ch = "y";
      else if (dp >= dq) ch = "r";
      // Yellow may not sit on the right or top, blue on the left, or red at the bottom.
      if (ch === "y") {
        if (j === N) return "b";
        return i === 0 ? "r" : "y";
      }
      return (ch === "b" && j === 0) || (ch === "r" && i === N) ? "y" : ch;
    }).join(""));

  // Wrap the standard boundary coloring of Section L2.2 around the grid: red
  // down the left except at its foot, yellow along the bottom except at its end.
  const padGrid = rows => ["r" + "b".repeat(rows.length + 1), ...rows.map(r => `r${r}b`), "y".repeat(rows.length + 1) + "b"];

  const corners = (rows, i, j) => [rows[i][j], rows[i][j + 1], rows[i + 1][j], rows[i + 1][j + 1]];

  const trichromatic = (rows, i, j, half) => {
    const [tl, tr, bl, br] = corners(rows, i, j);
    return new Set(half === "upper" ? [tl, tr, br] : [tl, bl, br]).size === 3;
  };

  // Cross the cell's unique red-yellow edge keeping red on the left. This encodes
  // the six cases the path figure draws (content/figures/brouwer/sperner_paths.typ).
  const exit = (rows, i, j, half) => {
    const [tl, tr, bl, br] = corners(rows, i, j);
    if (half === "lower") {
      if (br === "y" && tl === "r") return [i, j, "upper"];
      if (tl === "y" && bl === "r") return [i, j - 1, "upper"];
      if (bl === "y" && br === "r") return [i + 1, j, "upper"];
    } else {
      if (tl === "r" && tr === "y") return [i - 1, j, "lower"];
      if (tr === "r" && br === "y") return [i, j + 1, "lower"];
      if (br === "r" && tl === "y") return [i, j, "lower"];
    }
    return null;
  };

  // Follow the path out of the bottom-left cell, which the standard boundary
  // coloring forces to be a source and, being standard, also keeps the walk
  // inside the grid. Its sink is trichromatic. Padded grids only.
  const walk = rows => {
    const cells = rows.length - 1;
    const path = [];
    for (let node = [cells - 1, 0, "lower"]; node && path.length < 2 * cells * cells; node = exit(rows, ...node)) {
      path.push(node);
    }
    return path;
  };

  const centroid = (i, j, half, n) => half === "lower"
    ? [((j + 1 / 3) * width) / n, ((i + 2 / 3) * height) / n] : [((j + 2 / 3) * width) / n, ((i + 1 / 3) * height) / n];

  // Paint and marker attributes inherit, so a family of shapes shares one <g>.
  const group = (attrs, body) => `<g ${attrs}>${body}</g>`;
  const outline = `<rect x="0" y="0" width="${width}" height="${height}" fill="none" stroke="#000" stroke-width=".7"/>`;

  // Paint the improvement direction as K by K cells over a sub-box.
  const fieldCells = (delta, K, opacity, x0 = 0, y0 = 0, ww = width, hh = height) => {
    const cw = (ww / K + 0.02).toFixed(3);
    const cellH = (hh / K + 0.02).toFixed(3);
    let cells = "";
    for (let a = 0; a < K; a++) {
      for (let b = 0; b < K; b++) {
        cells += `<rect x="${(x0 + (a / K) * ww).toFixed(3)}" y="${(y0 + hh - ((b + 1) / K) * hh).toFixed(3)}" width="${cw}" height="${cellH}" fill="${fieldFill(...delta((a + 0.5) / K, (b + 0.5) / K))}" opacity="${opacity}"/>`;
      }
    }
    return cells;
  };

  const fieldPanel = delta => {
    const N = 16;
    let arrows = "";
    for (let i = 0; i < N; i++) {
      for (let j = 0; j < N; j++) {
        const p = (i + 0.5) / N;
        const q = (j + 0.5) / N;
        let [dp, dq] = delta(p, q).map(d => d / 2);
        const norm = Math.hypot(dp, dq);
        if (norm > 1.2 / N) {
          dp /= N * norm;
          dq /= N * norm;
        }
        arrows += `<line x1="${((p - dp / 2) * width).toFixed(3)}" y1="${(height - (q - dq / 2) * height).toFixed(3)}" x2="${((p + dp / 2) * width).toFixed(3)}" y2="${(height - (q + dq / 2) * height).toFixed(3)}"/>`;
      }
    }
    return fieldCells(delta, 48, ".85") + group(`stroke="#1a1a1a" stroke-width=".28" marker-end="url(#sperner-tip)"`, arrows) + outline;
  };

  const spernerPanel = (rows, padded, delta) => {
    const n = rows.length - 1;
    const w = width / n;
    const h = height / n;
    const rad = Math.min(1.6, 14 / n).toFixed(2);
    // The same coloring, washed out, covers the square the game lives on: once
    // padded, that is the inner square the padding surrounds.
    const x0 = padded ? w : 0;
    const y0 = padded ? h : 0;
    // Each family of shapes emits as a single element, built in one pass over the lattice.
    const dots = { r: "", b: "", y: "" };
    let tris = "";
    let rules = "";
    let diags = "";
    for (let i = 0; i <= n; i++) {
      const y = (i * h).toFixed(3);
      const y2 = ((i + 1) * h).toFixed(3);
      rules += `M0 ${y}H${width}M${(i * w).toFixed(3)} 0V${height}`;
      for (let j = 0; j <= n; j++) {
        const x = (j * w).toFixed(3);
        const x2 = ((j + 1) * w).toFixed(3);
        dots[rows[i][j]] += `<circle cx="${x}" cy="${y}" r="${rad}"/>`;
        if (i === n || j === n) continue;
        diags += `M${x} ${y}L${x2} ${y2}`;
        if (trichromatic(rows, i, j, "upper")) tris += `M${x} ${y}L${x2} ${y}L${x2} ${y2}z`;
        if (trichromatic(rows, i, j, "lower")) tris += `M${x} ${y}L${x} ${y2}L${x2} ${y2}z`;
      }
    }
    const out = [fieldCells(delta, 36, ".3", x0, y0, width - 2 * x0, height - 2 * y0), `<path d="${tris}" fill="${triangle}"/>`];
    if (padded) {
      out.push(`<polygon points="0,${height} 0,${height - h} ${w},${height}" fill="${seed}"/>`);
      const pts = walk(rows).map(node => centroid(...node, n).map(v => v.toFixed(2)));
      if (pts.length > 1) out.push(`<polyline points="${pts.map(p => p.join(",")).join(" ")}" fill="none" stroke="#111" stroke-width=".55" marker-end="url(#sperner-tip)"/>`);
      // The walk starts at the seed cell, so its ends are the marked vertices.
      for (const [x, y] of [pts[0], pts[pts.length - 1]]) {
        out.push(`<circle cx="${x}" cy="${y}" r=".9" fill="#111"/>`);
      }
    }
    out.push(group(`fill="none" stroke="${rule}"`, `<path d="${rules}" stroke-width=".25"/><path d="${diags}" stroke-width=".2"/>`));
    if (padded) out.push(`<rect x="${w}" y="${h}" width="${width - 2 * w}" height="${height - 2 * h}" fill="none" stroke="#111" stroke-width=".5" stroke-dasharray="2 2"/>`);
    // The outline goes under the vertices, so boundary dots stay whole.
    out.push(outline);
    for (const c in dots) {
      out.push(group(`fill="${fill[c]}" stroke="${edge[c]}" stroke-width=".3"`, dots[c]));
    }
    return out.join("");
  };

  const svg = (label, body) => `<svg viewBox="-3 -3 ${width + 6} ${height + 6}" role="img" aria-label="${label}">${body}</svg>`;

  // The two players' names carry the orientation, so per-action labels would only
  // repeat what each field's own label already says.
  const payoff = (m, i, j) => `<input type="number" step="1" name="a${m + 1}-${i}-${j}" value="0" aria-label="Player ${m + 1} payoff at ${"TB"[i]}${"LR"[j]}">`;
  const pair = i => [0, 1].map(j => `<td>${payoff(0, i, j)}<span class="sperner-separator">,</span>${payoff(1, i, j)}</td>`).join("");

  // A button names the preset it loads; the one that names no preset rolls a game.
  const markup = `<div class="sperner-controls">
      <table class="sperner-payoffs"><thead><tr><td></td><th colspan="2" class="sperner-player-2">Player 2</th></tr></thead>
      <tbody><tr><th rowspan="2" class="sperner-player-1">Player 1</th>${pair(0)}</tr><tr>${pair(1)}</tr></tbody></table>
      <div class="sperner-options">
        <label>Grid <input type="range" name="n" min="4" max="24" step="1" value="8"><output name="nout">8</output></label>
        <label><input type="checkbox" name="pad"> Pad to a standard coloring and follow the path</label>
      </div>
      <div class="sperner-presets">${[...Object.keys(presets), "Random game"].map(k => `<button type="button" data-load="${k}">${k}</button>`).join("")}</div>
    </div>
    <svg width="0" height="0"><defs><marker id="sperner-tip" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="3.6" markerHeight="3.6" orient="auto-start-reverse"><path d="M0,1 L10,5 L0,9 z" fill="#111"/></marker></defs></svg>
    <div class="sperner-plots">
      <figure><figcaption>Nash improvement function (Brouwer)</figcaption><div class="sperner-svg" data-panel="field"></div></figure>
      <figure><figcaption>Sperner discretization</figcaption><div class="sperner-svg" data-panel="sperner"></div></figure>
    </div>`;

  // Eight independent payoffs give several equilibria only about a quarter of the
  // time, so 30% of the draws are built to have three: Player 1's two payoff gaps
  // get opposite signs and Player 2's match them, making (T,L) and (B,R) pure
  // equilibria with a mixed one between. That leaves the button at an even split.
  const randomGame = () => {
    const spread = () => Math.round(Math.random() * 8) - 4;
    const gap = () => 1 + Math.floor(Math.random() * 5);
    if (Math.random() >= 0.3) return [0, 1].map(() => [0, 1].map(() => [0, 1].map(spread)));
    const s = Math.random() < 0.5 ? 1 : -1;
    const [p, q, u, v] = [spread(), spread(), spread(), spread()];
    return [[[p + s * gap(), q - s * gap()], [p, q]], [[u + s * gap(), u], [v - s * gap(), v]]];
  };

  for (const mount of document.querySelectorAll(".sperner-explorer")) {
    mount.innerHTML = markup;
    const at = name => mount.querySelector(`[name="${name}"]`);
    // One walk over the eight payoff fields serves both reading and writing them.
    const fields = fn => [0, 1].map(m => [0, 1].map(i => [0, 1].map(j => fn(at(`a${m + 1}-${i}-${j}`), m, i, j))));

    const render = () => {
      const delta = displacement(...fields(el => Number(el.value) || 0));
      const n = Number(at("n").value);
      const padded = at("pad").checked;
      at("nout").value = n;
      const base = colorGrid(n, delta);
      const rows = padded ? padGrid(base) : base;
      mount.querySelector('[data-panel="field"]').innerHTML = svg("Direction of the Nash improvement step on the unit square", fieldPanel(delta));
      mount.querySelector('[data-panel="sperner"]').innerHTML = svg("Sperner coloring of the triangulated grid", spernerPanel(rows, padded, delta));
    };
    let frame = 0;
    const schedule = () => {
      cancelAnimationFrame(frame);
      frame = requestAnimationFrame(render);
    };
    const setGame = game => {
      fields((el, m, i, j) => (el.value = game[m][i][j]));
      schedule();
    };

    mount.addEventListener("input", schedule);
    for (const button of mount.querySelectorAll("[data-load]")) {
      button.addEventListener("click", () => setGame(presets[button.dataset.load] || randomGame()));
    }
    setGame(presets["Theater or football"]);
  }
})();
