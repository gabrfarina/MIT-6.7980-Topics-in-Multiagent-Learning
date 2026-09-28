#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 2,
  date: [Thu, Sep 17, 2026],
  title: "Brouwer and Sperner",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

In this lecture, we will do a deep dive into the proof of Brouwer's fixed point theorem, the main theorem that we invoked in the #lecture-link("nfgs_nash", <sec-nash-existence>)[proof of Nash equilibrium existence]. We will provide an elementary proof of Brouwer's theorem, one of several in the literature, with the goal of distilling Brouwer's existence-of-fixed-points result into a pure, combinatorial form. In particular, we seek to provide an answer to the following question:

#align(center)[

  _What is the combinatorial essence of Brouwer's fixed point existence theorem?_

]

Towards an answer, we will provide a proof of Brouwer's theorem via another existence theorem, known as Sperner's lemma. This pertains to a combinatorial structure, namely colorings of a triangulated grid, and it certifies the guaranteed existence of certain colorful triangles in this grid, if the coloring of the grid's boundary meets certain conditions. Given that Sperner's lemma pertains to combinatorial structures, by showing Brouwer's theorem through Sperner's lemma we come closer to a satisfying answer to the above question. Distilling even further, we will provide a proof of Sperner's lemma as a corollary of an elementary existence result, namely a parity argument in directed graphs. All in all, at the end of this lecture, we will have a surprisingly crisp answer to our question:

#align(center)[

  _Brouwer's fixed point theorem is a corollary of the fact that any directed graph has an even number of odd-degree vertices._

]

And why are we interested in this pursuit? One reason is that we want to de-mystify what makes Nash equilibria exist in every game, and what makes fixed points exist in every continuous function from a convex compact set to itself.

Another reason is that designing algorithms for computing Nash equilibria can benefit from understanding the nature of the combinatorial argument underlying the existence of Nash equilibria. Indeed, the #lecture-link("nash_algorithms", <sec-lemke-howson>)[Lemke–Howson algorithm] uses the directed-parity principle developed here.

And, in the reverse direction, understanding whether there are complexity barriers in the computation of Nash equilibria might benefit from known barriers for computing Brouwer fixed points, and colorful triangles in colored grids. Indeed, we will develop these ideas to study the computational complexity of Nash equilibria.

Relating the last two points, in _this_ lecture we will lay the foundations for proving that: computing Nash equilibria can be polynomial-time reduced to computing fixed points of Lipschitz continuous functions; that the latter can be  polynomial-time reduced to finding colorful triangles, guaranteed to exist in some large, colored grid by Sperner's lemma; and that the latter can be polynomial-time reduced to finding odd degree vertices in some large, directed graph given another odd degree vertex in that graph. So, informally, Nash will reduce to Brouwer which will reduce to Sperner which will reduce to a computational problem capturing the parity argument in directed graphs. This direction of reductions will give us ideas for Nash equilibrium computation algorithms.

Surprisingly, reductions also hold in the _reverse_ direction, from directed parity through fixed points to Nash equilibria. The lecture on #lecture-link("ppad_completeness", <sec-generalized-circuits>)[_PPAD-hardness_] discusses this direction, focusing on how to encode fixed-point constraints as equilibrium incentives. These reductions explain the computational difficulty of Nash equilibrium computation.

= Sperner's lemma <sec-sperner>

#wrapped-figure(side: right, text-width: 60%)[
  Key to distilling the combinatorial essence of why Nash equilibria exist in every game and why fixed points exists in every continuous function mapping a convex compact set to itself is a theorem that, at first glance, has little to do with fixed points nor equilibria: Sperner's lemma.

  Sperner's lemma applies to a $3$-colored $N times N$ grids of points. There are high-dimensional analogues of the lemma, but we will stick to $2$ dimensions in this lectures.
][
  #figure(caption: [A Sperner coloring.])[
    #image("figures/brouwer/sperner_example.svg", width: 100%)
  ]#label("fig:sperner coloring")
]

For the lemma to apply, the rules are simple. Each point is colored with one of three colors: red, blue, or yellow. The coloring must, however, satisfy the following _boundary_ conditions:

#[
  #set enum(numbering: "(i)")
  + The left column cannot contain any blue;
  + The bottom row cannot contain any red;
  + The right column and top row cannot contain any yellow.
]

Any coloring that satisfies these conditions is called a _Sperner coloring_. An example of a coloring satisfying these rules is shown in #ref(label("fig:sperner coloring")).

Given any Sperner coloring, we are interested in finding a trichromatic triangle, that is, a triangular cell whose vertices are colored red, blue, and yellow. Sperner's lemma guarantees that such a cell is guaranteed  to exist, no matter the Sperner coloring.

#theorem[Sperner's lemma][
  Consider a Sperner coloring of a triangulated grid of any size. There must exist at least _one_ trichromatic triangle.

  In fact, there must exist an _odd_ number  of trichromatic triangles.
] <thm-sperner>

We illustrate the previous theorem in the colored grid of #ref(label("fig:sperner coloring")).

#example[
  #wrapped-figure(side: right, text-width: 60%)[
    In the coloring of #ref(label("fig:sperner coloring")), there are a total of _five_ trichromatic triangles, as highlighted in green on the right.

    Indeed, five is an odd number, validating the statement of @thm-sperner.
  ][
    #image("figures/brouwer/sperner_triangulation.svg")
  ]
]

== The connection between Brouwer and Sperner <sec-brouwer-sperner>

What does Sperner's lemma have to do with Brouwer's fixed point theorem? The connection is not immediate, but upon second thought, several glimpses of connections emerge.  For one, both results are existence results. Furthermore, both results are trivially false if the “boundary conditions” in their statements are violated. In the case of Brouwer's fixed point theorem,
the boundary conditions are that the continuous function must map the compact set to itself, i.e.~the boundary points must be mapped to somewhere inside the set. In the case of Sperner's lemma, the boundary conditions are the coloring rules on the boundary.

#wrapped-figure(side: left, text-width: 75%)[
  As it turns out, Sperner's lemma can be viewed as a “discretized version” of Brouwer's fixed point theorem. To see the connection, consider a continuous function mapping $[0 \, 1]^2$ to itself and, depending on the direction of $f \( vz \) - vz$, assign red, yellow, or blue to the vertices of a fine, triangulated grid, whose boundary matches that of $[0 \, 1]^2$, according to the rules shown on the left.
][
  #image("figures/brouwer/color_wheel.svg", width: 92.774pt)
]
(This coloring is a more boring version of the #lecture-link("nfgs_nash", <sec-nash-improvement>)[coloring of the Nash improvement function], but it will work for our purposes.)

If the direction of $f \( vz \) - vz$ lies in the yellow-blue, blue-red, or yellow-red boundary, we can assign any one of the two compatible colors, but we will make sure that, for grid points lying on the boundary of $[0 \, 1]^2$, we will break ties in favor of the color that does not violate the Sperner coloring conditions. Because $f$ maps $[0 \, 1]^2$ to itself, there should always be at least one such option! Thus, the coloring we will obtain will be a valid Sperner coloring, and it will have at least one trichromatic~triangle.

In turn, it should be intuitively clear why trichromatic triangles have value vis-à-vis the fixed point behavior of $f$: they are triangles where $f \( vz \) - vz$ changes direction within a small distance and, due to continuity, $f \( vz \) - vz$ can't be too large.

We formalize these ideas in the next sections, arriving at two results. First, we will show a complete proof of Brouwer's fixed point theorem, using Sperner's lemma and a compactness argument. Second, we will establish the following computational reduction. Suppose we are given access to an algorithm that takes as input a Sperner coloring of a triangulated grid and computes a trichromatic triangle guaranteed by Sperner's lemma. Then, we can use this algorithm to compute approximate Brouwer fixed points of a Lipschitz continuous function, $f$, from $[0 \, 1]^2$ to itself, by discretizing the domain into a grid whose cells have small enough diameter, as a function of the Lipschitz constant and the desired approximation, coloring the vertices of this grid according to the scheme presented above, and finding a trichromatic triangle. We illustrate how this reduction would work with an example.

#example[
  The following plots illustrate the Sperner discretization of the Nash improvement function in the #lecture-link("nfgs_nash", <sec-nash-improvement>)[three running examples for the Nash improvement function].

  #align(center)[
    #image("figures/brouwer/example_games.svg", width: 100.0%)
  ]
] <ex-sperner-toy-games>

After proving Sperner's lemma, we will return to these three games in @sec-sperner-toy-paths and see which trichromatic triangle the proof finds, and how the remaining ones are paired.

It is worth noting that the trichromatic triangles obtained via the above reduction are not always in the proximity of exact fixed points of the function. Unless the discretization is fine enough and $f$ has extra properties, we will only guarantee that the trichromatic triangles are in the proximity of approximate fixed points. While this is not the case in the examples above, it can be the case.

== Formalizing the connection <sec-brouwer-approximation>

To make the argument formal, we need to establish a formal connection between a trichromatic triangle and an approximate Brouwer fixed point, and connect that to a choice of discretization parameter.

By the Heine-Cantor theorem, any continuous function $f$ on a compact set is _uniformly_ continuous, which implies that:

#math.equation(
  block: true,
  numbering: "(1)",
  $forall epsilon.alt > 0 \, exists delta (epsilon.alt) & > 0 :\
  & ∥vz - vw∥_oo < delta (epsilon.alt) quad ==> quad ∥f \( vz \) - f \( vw \)∥_oo < epsilon.alt .$.body,
)#label("eq: uniform continuity")

Now, given $f$ and $epsilon.alt$, consider a triangulation of $\[ 0 \, 1 \]^2$ in which the diameter of every triangle is $delta$ in $ell_oo$. Assign colors to the vertices of the triangulation according to the direction of $f \( vz \) - vz$, using the coloring scheme discussed above, and breaking ties in an arbitrary way but respecting the Sperner coloring conditions. Let us call the resulting coloring a _Sperner discretization of $f$ of diameter $delta$_. Then, the following approximation bound can be established.

#theorem[
  Suppose that $vz_Y$ is the yellow corner of a trichromatic triangle in a Sperner discretization of some continuous function $f : \[ 0 \, 1 \]^2 -> \[ 0 \, 1 \]^2$ of diameter $delta <= delta (epsilon.alt)$, where $delta \( epsilon.alt \)$ satisfies~#ref(label("eq: uniform continuity")) for some $epsilon.alt$. Then

  $ ∥f (vz_Y) - vz_Y∥_oo < epsilon.alt + delta . $
] <thm-sperner-approximation>

#proof[
  Let $vz_R \, vz_B \,$ and $vz_Y$ be the red, blue, and yellow vertices of the trichromatic triangle. The key observation is that, by the coloring rule:

  - $(f (vz_Y) - vz_Y)_x$ and $(f (vz_B) - vz_B)_x$ have opposite signs if they are  nonzero
  - $(f (vz_Y) - vz_Y)_y$ and $(f (vz_R) - vz_R)_y$ have opposite signs if they are  non-zero

  Thus, we can write

  $
    \| (f (vz_Y) - vz_Y)_x \| & <= \| (f (vz_Y) - vz_Y)_x - (f (vz_B) - vz_B)_x \| \
                            & <= \| (f (vz_Y) - f (vz_B))_x - (vz_Y - vz_B)_x \| \
                            & <= ∥f (vz_Y) - f (vz_B)∥_oo + ∥vz_Y - vz_B∥_oo < epsilon.alt + delta .
  $

  and similarly

  $
    \| (f (vz_Y) - vz_Y)_y \| & <= \| (f (vz_Y) - vz_Y)_y - (f (vz_R) - vz_R)_y \| \
                            & <= \| (f (vz_Y) - f (vz_R))_y - (vz_Y - vz_R)_y \| \
                            & <= ∥f (vz_Y) - f (vz_R)∥_oo + ∥vz_Y - vz_R∥_oo < epsilon.alt + delta .
  $

  From here, we can just use the definition of infinity norm:

  $ ∥f (vz_Y) - vz_Y∥_oo = max {\| (f (vz_Y) - vz_Y)_x \| \, \| (f (vz_Y) - vz_Y)_y \|} < epsilon.alt + delta . med med med $
]

#corollary[
  Consider the same setup as before, but now choose $delta := min {delta (epsilon.alt) \, epsilon.alt}$ for a given $epsilon.alt > 0$. Then $vz_Y$ is a $2 epsilon.alt$-approximate fixed point of $f$, i.e.~

  $ ∥f (vz_Y) - vz_Y∥_oo < 2 epsilon.alt . $
] <cor:sperner>

In turn, using a standard compactness argument, @cor:sperner implies Brouwer's fixed point theorem for continuous functions from $\[ 0 \, 1 \]^2$ to itself.

#corollary[Brouwer's fixed point theorem, unit square][
  Any continuous function from $[0 \, 1]^2$ to itself has a fixed point.
]

#proof[
  Consider the sequence of approximation parameters $epsilon.alt_i := 2^(- i)$ for $i in bb(N)_(>= 1)$, and the corresponding discretization parameters $delta_i := min {delta (epsilon.alt_i) \, epsilon.alt_i}$, as in @cor:sperner. For each $i$, we color the vertices of the resulting triangulation as above, so that they satisfy the conditions of Sperner's lemma, and identify a trichromatic triangle which is then guaranteed to exist. Let us denote by $vz_(Y \, i)$ the yellow vertex of that triangle, which satisfies $∥f (vz_(Y \, i)) - vz_(Y \, i)∥_oo < 2 epsilon.alt_i$. Now consider the sequence of points $\( vz_(Y \, i) \)_i$. Since $vz_(Y \, i) in [0 \, 1]^2$ for all $i$, and $[0 \, 1]^2$ is a compact set, there exists a convergent subsequence $\( vz_(Y \, n_j) \)_j$; let $vz_Y^(*)$ denote the limit of this subsequence. By the continuity of $f$, the function $d \( vz \) := ∥f \( vz \) - vz∥_oo$ is also continuous. Hence,

  $ d (vz_Y^(*)) = lim_(j -> oo) d (vz_(Y \, n_j)) . $

  Since $d (vz_(Y \, n_j)) in [0 \, 2 dot.op 2^(- j)]$, we conclude $d (vz_Y^(*)) = 0$, which is equivalent to $f (vz_Y^(*)) = vz_Y^(*)$. This proves that a fixed point exists.
]

= Proof of Sperner's lemma <sec-sperner-proof>

Now we turn to proving Sperner's lemma. As it turns out, the lemma can be obtained as a corollary of a very basic parity argument on directed graphs.

#wrapped-figure(side: right, text-width: 60%)[
  Before jumping into the proof, let us make our life simpler. Without loss of generality, we will assume that, at the boundary of the grid, the Sperner coloring is as in the figure on the right: red on the left (except for the bottom-left corner), yellow on the bottom (except for the bottom-right corner), and blue everywhere else. We will call this boundary coloring the _standard boundary coloring_ and we will call a Sperner coloring satisfying this a _standard Sperner coloring_.
][
  #image("figures/brouwer/sperner_padded.svg", width: 100%)
]

Assuming a standard Sperner coloring is without loss of generality. Indeed, if a given Sperner coloring is not standard  (as in~#ref(label("fig:sperner coloring"))), we can always augment the grid with an additional layer of boundary that is colored in the standard way, and embed the given Sperner coloring in the inside. Due to the properties of Sperner colorings and the standard boundary coloring, this operation will not introduce any trichromatic triangles between the extra boundary  and the old boundary.

Now that our boundary coloring is standard, we can easily show Sperner's lemma using a graph-theoretic argument. Given a standard Sperner coloring we can define a directed graph, called _Sperner graph_, as follows:

#wrapped-figure(side: left, text-width: 55%)[
  - there are as many nodes in the graph as there are triangular cells in the grid; each cell of the grid is identified with a node of the graph;
  - there is a directed edge $u -> v$ from node $u$ to node $v$ in the graph if their corresponding cells $u$ and  $v$ in the grid share a _red-yellow_ edge and, in order to go from cell $u$ to cell $v$, one would have to cross this edge having the red color on the left and the yellow color on the right.
][
  #image("figures/brouwer/sperner_paths.svg", width: 100%)
]

For the standard Sperner coloring of #ref(label("fig:sperner coloring")), the corresponding graph is shown just above on the left.

== Properties of the Sperner graph <sec-sperner-graph>

As you might have guessed from the picture, the following key properties hold.

#theorem[
  In any Sperner graph, the following properties hold:

  #[
    #set enum(numbering: "(1)")
    + every node has outdegree and indegree at most $1$;
    + any node with indegree $1$ and outdegree $0$ is a trichromatic triangle (marked green in the figure above);
    + any node with outdegree $1$ and indegree $0$ is a trichromatic triangle (marked green), with the only exception of the bottom-left node (marked purple).
  ]
]#label("thm:sperner graph properties")

#proof[
  #[
    #set enum(numbering: "(1)")
    + follows by noticing that every cell has at most one _red-yellow_ edge that one can use to exit this cell while keeping red on the left, and at most one _red-yellow_ edge that one can use to enter this cell while keeping red on the left.
    + can be shown by contradiction. Take any node with indegree $1$ and outdegree $0$, and assume for contradiction that it is not a trichromatic triangle. Since the indegree is $1$, one of the sides of the cell corresponding to the node is red-yellow and this edge can be crossed to enter into this cell from a neighboring cell. Let us now consider the third vertex of the cell. Since by assumption the cell is not trichromatic, the third vertex is either red or yellow. Either case results in another red-yellow edge that one would be able to cross to exit the cell keeping red on the left. The only reason why this would not mean that the outdegree of the node corresponding to that cell is $1$ is that this edge lies on the boundary of the grid. However, there are no such red-yellow edges on the boundary of the grid in the standard Sperner coloring. There is a unique red-yellow edge in the standard boundary coloring (at the bottom left cell) but this is an entry door, not an exit one.
    + can be shown with a similar argument as (2).
  ]
]

== Completing the proof of Sperner's lemma

At this point, the proof of Sperner's lemma is immediate. A graph in which each node has indegree at most one and outdegree at most one is composed of connected components that can only be singleton nodes, directed paths, or directed simple cycles. Only paths have nodes with outdegree $1$ and indegree $0$, or outdegree $0$ and indegree $1$; each has exactly one of each. Note also that the standard boundary coloring forces the bottom left cell not to be trichromatic, and node corresponding to this cell to have outdegree $1$ and indegree $0$. So this node must be the source of a path. The sink of that path is trichromatic as per~#ref(label("thm:sperner graph properties")). If there are other paths, both their source and their sink are trichromatic, as per~#ref(label("thm:sperner graph properties")). Hence, there are an odd number of trichromatic triangles in any standard Sperner coloring, and therefore any Sperner coloring.

== Following the paths in the toy games <sec-sperner-toy-paths>

We can now follow the proof on the three Sperner discretizations in @ex-sperner-toy-games. Let $p$ and $q$ be the probabilities with which Players 1 and 2 choose their second action, so their mixed strategies are $(1 - p, p)$ and $(1 - q, q)$. In @fig-sperner-toy-paths we keep the same grid and coloring, add the standard outer boundary, and draw the directed paths through red-yellow doors.

#figure(
  context {
    // Keep the diagram editable with this lecture. Use the same payoff matrices,
    // color tie-breaking, grid helper, and drawing style as Example L2.3.
    import "@preview/cetz:0.3.4"
    import "figures/libs/sperner.typ": _sperner_grid, sperner_w, sperner_h
    import "figures/libs/nash.typ": softbr
    import "meta/linalg.typ": transpose
    let for-html = target() == "html"
    set text(font: if for-html { "Georgia" } else { "New Computer Modern" }, size: 9pt)
    // CeTZ positions its own content; omit the lecture's HTML alignment wrapper.
    show align: it => it.body
    // Payoffs and coloring match the existing toy-game discretizations.

    let tof_A1 = ((0, 5), (1, 0))
    let tof_A2 = ((0, 1), (5, 0))
    let psg_A1 = ((-1, 1), (1, -1))
    let psg_A2 = ((1, -1), (-1, 1))
    let pdi_A1 = ((-1, -3), (0, -2))
    let pdi_A2 = ((-1, 0), (-3, -2))

    let improvement(A1, A2) = {
      let A2T = transpose(A2)
      (p, q) => {
        let x = (1 - p, p)
        let y = (1 - q, q)
        (softbr(x, A1, y).at(1), softbr(y, A2T, x).at(1))
      }
    }

    // Rows run from top to bottom, as in libs/sperner.typ.
    // Preserve the tie-breaking of the original Example L2.3 figure.
    let toy-coloring(A1, A2, n: 8) = {
      let f = improvement(A1, A2)
      let rows = ()
      for i in range(n + 1) {
        rows.push("")
        for j in range(n + 1) {
          let p = j / n
          let q = (n - i) / n
          let (pp, qq) = f(p, q)
          let (dp, dq) = (pp - p, qq - q)
          let ch = if dp >= 0 and dq >= 0 { "y" } else if dp >= dq { "r" } else { "b" }
          if j == n and ch == "y" { ch = "b" }
          else if i == 0 and ch == "y" { ch = "r" }
          else if j == 0 and ch == "b" { ch = "y" }
          else if i == n and ch == "r" { ch = "y" }
          rows.at(-1) += ch
        }
      }
      rows
    }

    // Construct the directed graph from the actual red-yellow doors, not drawn paths.
    let sperner-graph(rows) = {
      let n = rows.len() - 1
      assert(rows.all(row => row.len() == n + 1))
      let padded = ("r" + "b" * (n + 2),)
      for row in rows { padded.push("r" + row + "b") }
      padded.push("y" * (n + 2) + "b")
      let color(v) = padded.at(n + 2 - v.at(1)).at(v.at(0))
      let triangles = ()
      let doors = (:)
      for y in range(n + 2) {
        for x in range(n + 2) {
          // Counterclockwise vertices; same falling diagonal as _sperner_grid.
          for vertices in (
            ((x, y), (x + 1, y), (x, y + 1)),
            ((x + 1, y + 1), (x, y + 1), (x + 1, y)),
          ) {
            let id = triangles.len()
            let center = (vertices.map(v => v.at(0)).sum() / 3,
                          vertices.map(v => v.at(1)).sum() / 3)
            triangles.push((vertices: vertices, center: center,
              trichromatic: vertices.map(color).dedup().len() == 3))
            for i in range(3) {
              let a = vertices.at(i)
              let b = vertices.at(calc.rem(i + 1, 3))
              if (color(a), color(b)).sorted() == ("r", "y") {
                let key = repr((a, b).sorted(key: v => v.at(0) + (n + 3) * v.at(1)))
                let entries = doors.at(key, default: ())
                // Crossing a CCW boundary edge outwards keeps its second vertex left.
                entries.push((id: id, outgoing: color(b) == "r"))
                doors.insert(key, entries)
              }
            }
          }
        }
      }
      let next = (none,) * triangles.len()
      let prev = (none,) * triangles.len()
      for entries in doors.values() {
        if entries.len() == 2 {
          let outgoing = entries.find(e => e.outgoing).id
          let incoming = entries.find(e => not e.outgoing).id
          assert(next.at(outgoing) == none and prev.at(incoming) == none)
          next.at(outgoing) = incoming
          prev.at(incoming) = outgoing
        } else {
          // The only unpaired door is the entry on the standard bottom-left boundary.
          assert(entries.len() == 1 and entries.first().id == 0)
        }
      }
      let paths = ()
      for start in range(triangles.len()) {
        if prev.at(start) == none and next.at(start) != none {
          let path = (start,)
          let node = start
          while next.at(node) != none {
            node = next.at(node)
            assert(not path.contains(node), message: "A source path cannot enter a cycle.")
            path.push(node)
          }
          assert(start == 0 or triangles.at(start).trichromatic)
          assert(triangles.at(node).trichromatic)
          paths.push(path)
        }
      }
      let endpoints = paths.map(p => (p.first(), p.last())).flatten().filter(id => id != 0)
      assert(endpoints.sorted() == range(triangles.len()).filter(id => triangles.at(id).trichromatic))
      (rows: padded, triangles: triangles, paths: paths, next: next, prev: prev)
    }

    let panel(title, A1, A2, equilibria, summary) = {
      let graph = sperner-graph(toy-coloring(A1, A2))
      cetz.canvas(length: .5cm, {
        import cetz.draw: *
        let w = sperner_w
        let h = sperner_h
        let pos(v) = (v.at(0) * w, v.at(1) * h)
        let center(id) = pos(graph.triangles.at(id).center)
        _sperner_grid(..graph.rows, radius: .65mm, bottom_left: purple.lighten(60%))
        // The original unit square is one grid step inside the artificial frame.
        rect(pos((1, 1)), pos((9, 9)), stroke: (paint: black, thickness: .3mm, dash: "dashed"))
        for path in graph.paths {
          let main = path.first() == 0
          let paint = if main { black } else { purple }
          let stroke = (paint: paint, thickness: .35mm)
          for (a, b) in path.zip(path.slice(1)) {
            // A white underlay separates the path from the triangulation edges.
            line(center(a), center(b), stroke: .65mm + white)
            line(center(a), center(b), stroke: stroke,
              mark: (end: ">", scale: .38, fill: paint))
          }
          for id in (path.first(), path.last()) {
            circle(center(id), radius: .55mm, fill: paint, stroke: none)
          }
        }
        // Exact fixed points, distinct from the centers of trichromatic cells.
        for (p, q, name, offset) in equilibria {
          let point = pos((1 + 8 * p, 1 + 8 * q))
          circle(point, radius: .85mm, fill: black, stroke: .35mm + white)
          content((point.at(0) + offset.at(0), point.at(1) + offset.at(1)), name)
        }
        content((-0.35, -0.15), emph("S"))
        content(pos((1, -.65)), "0")
        content(pos((9, -.65)), "1")
        content(pos((10, -.65)), emph("p"))
        content(pos((-.65, 1)), "0")
        content(pos((-.65, 9)), "1")
        content(pos((-.65, 10)), emph("q"))
        content(pos((5, 11.1)), emph(title))
        content(pos((5, -1.75)), summary)
      })
    }

    let drawing = grid(columns: 3, column-gutter: 3mm, align: top + center,
      panel("Theater or football", tof_A1, tof_A2,
        ((0, 1, emph("A"), (.35, .3)), (1, 0, emph("B"), (.35, .35)),
         (1 / 6, 1 / 6, emph("C"), (.35, .4))), [S #sym.arrow.r A; #text(purple)[C #sym.arrow.r B]]),
      panel("Prisoner's dilemma", pdi_A1, pdi_A2,
        ((1, 1, emph("D"), (-.4, .35)),), [S #sym.arrow.r D]),
      panel("Penalty shot game", psg_A1, psg_A2,
        ((.5, .5, emph("E"), (.35, -.35)),), [S #sym.arrow.r E]),
    )
    let diagram = context {
      let width = if for-html { 585pt } else { 405pt }
      let factor = width / measure(drawing).width * 100%
      scale(x: factor, y: factor, reflow: true, drawing)
    }
    if for-html {
      html.frame(diagram)
    } else {
      diagram
    }
  },
  caption: [The Sperner paths for @ex-sperner-toy-games. The dashed box bounds the original unit square; the extra layer is only a combinatorial device. The black path starts at the purple bottom-left cell $S$ and ends in a green trichromatic cell. The purple path pairs the two remaining trichromatic cells in theater or football. White-rimmed black dots mark exact Nash equilibria; arrows connect triangle centers, not strategy trajectories.],
) <fig-sperner-toy-paths>

In *theater or football*, the three Nash equilibria are $A = (0, 1)$, $B = (1, 0)$, and $C = (1/6, 1/6)$. Starting at $S$, the proof follows the black path to the triangle with vertices $(0, 7/8)$, $(1/8, 7/8)$, and $(0, 1)$, next to $A$: Player 1 insists and Player 2 accepts. The other path starts at the trichromatic triangle containing the mixed equilibrium $C$ and ends at the one next to $B$, where Player 1 accepts and Player 2 insists. Thus the proof singles out one of the three equilibrium neighborhoods, while the other two are paired by a separate path.

In *prisoner's dilemma*, the path from $S$ ends in the triangle with vertices $(7/8, 7/8)$, $(1, 7/8)$, and $(7/8, 1)$, next to the unique equilibrium $D = (1, 1)$, where both players confess. In the *penalty shot game*, it ends in the triangle with vertices $(1/2, 1/2)$, $(1/2, 5/8)$, and $(3/8, 5/8)$, next to the unique equilibrium $E = (1/2, 1/2)$. These two grids have no other trichromatic cells to pair.

The path-following proof returns a *trichromatic triangle*, not an exact fixed point. Its yellow vertex gives the approximate fixed point from @thm-sperner-approximation; here these vertices are respectively $(0, 7/8)$, $(7/8, 7/8)$, and $(1/2, 1/2)$. The equilibrium labels identify the nearby exact fixed points in these particular games. Which triangle is selected depends on the triangulation and tie-breaking. Nor does a path describe players learning to play an equilibrium: it is a path in the combinatorial Sperner graph. The pairing argument counts trichromatic triangles and does not, by itself, prove an oddness theorem for exact Nash equilibria.

= Beyond the unit square <sec-brouwer-general>

We stated and proved Sperner's lemma for the two-dimensional grid, and used that to prove Brouwer's fixed point theorem for continuous functions mapping the unit square to itself. There is a $d$-dimensional generalization of Sperner's lemma, which can be used to prove Brouwer's fixed point theorem for continuous functions mapping $\[ 0 \, 1 \]^d$ to itself. In the high-dimensional  case, a $d$-dimensional grid is partitioned into simplices, the $d$-dimensional analog of triangles, without introducing any more vertices other than those in the grid. The vertices of the grid are now colored with $d + 1$ colors, $0 \, 1 \, ... \, d$. Now, a coloring is valid if color $i$ is not present in facet $x_i = 0$, for all $i = 1 \, ... \, d$, and color $0$ is not present in all facets $x_i = 1$, for all $i = 1 \, ... \, d$. Sperner's lemma guarantees the existence of a simplex that has all $d + 1$ colors on its $d + 1$ vertices. Using the $d$-dimensional version of Sperner's lemma to prove Brouwer's fixed point theorem for continuous functions mapping the $d$-dimensional hypercube to itself is analogous to the $d = 2$ case. Finally, given Brouwer's fixed point theorem for the hypercube it is not hard to prove it for other convex and compact sets. Given a function defined on an arbitrary convex and compact set, one can first affinely transform the coordinate system so the set lies inside the unit hypercube. Then the function can be extended outside of the set by first projecting points of the hypercube to the set and then applying the function. This will not introduce any spurious fixed points.

#changelog[
  - Sep 24, 2025: fixed two typos (thanks Eric Yang Yu!)
]
