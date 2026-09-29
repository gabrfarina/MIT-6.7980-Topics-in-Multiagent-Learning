#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 2,
  date: [Thu, Sep 17, 2026],
  title: "Brouwer and Sperner",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

In this lecture, we will do a deep dive into the proof of Brouwer's fixed point theorem #citep(<brouwer1911abbildung>), the main theorem that we invoked in the #lecture-link("nfgs_nash", <sec-nash-existence>)[proof of Nash equilibrium existence] #citep(<Nash51:NonCooperative>). We will provide an elementary proof of Brouwer's theorem #citep(<knaster1929beweis>), one of several in the literature, with the goal of distilling Brouwer's existence-of-fixed-points result into a pure, combinatorial form. In particular, we seek to provide an answer to the following question:

#align(center)[

  _What is the combinatorial essence of Brouwer's fixed point existence theorem?_

]

Towards an answer, we will provide a proof of Brouwer's theorem via another existence theorem, known as Sperner's lemma. This pertains to a combinatorial structure, namely colorings of a triangulated grid, and it certifies the guaranteed existence of certain colorful triangles in this grid, if the coloring of the grid's boundary meets certain conditions. Given that Sperner's lemma pertains to combinatorial structures, by showing Brouwer's theorem through Sperner's lemma we come closer to a satisfying answer to the above question. Distilling even further, we will provide a proof of Sperner's lemma as a corollary of an elementary existence result, namely a parity argument in directed graphs. All in all, at the end of this lecture, we will have a surprisingly crisp answer to our question:

#align(center)[

  _Brouwer's fixed point theorem is a corollary of the fact that any directed graph has an even number of odd-degree vertices._ #citep(<euler1741solutio>)

]

And why are we interested in this pursuit? One reason is that we want to de-mystify what makes Nash equilibria exist in every game, and what makes fixed points exist in every continuous function from a convex compact set to itself.

Another reason is that designing algorithms for computing Nash equilibria can benefit from understanding the nature of the combinatorial argument underlying the existence of Nash equilibria. Indeed, the #lecture-link("nash_algorithms", <sec-lemke-howson>)[Lemke–Howson algorithm] #citep(<LemkeHowson64>) uses the directed-parity principle developed here.

And, in the reverse direction, understanding whether there are complexity barriers in the computation of Nash equilibria might benefit from known barriers for computing Brouwer fixed points, and colorful triangles in colored grids. Indeed, we will develop these ideas to study the computational complexity of Nash equilibria.

Relating the last two points, in _this_ lecture we will lay the foundations for proving that: computing Nash equilibria can be polynomial-time reduced to computing fixed points of Lipschitz continuous functions; that the latter can be  polynomial-time reduced to finding colorful triangles, guaranteed to exist in some large, colored grid by Sperner's lemma; and that the latter can be polynomial-time reduced to finding odd degree vertices in some large, directed graph given another odd degree vertex in that graph #citep(<papadimitriou1994parity>). So, informally, Nash will reduce to Brouwer which will reduce to Sperner which will reduce to a computational problem capturing the parity argument in directed graphs. This direction of reductions will give us ideas for Nash equilibrium computation algorithms.

Surprisingly, reductions also hold in the _reverse_ direction, from directed parity through fixed points to Nash equilibria #citep(<dgp09>, <chen2009settling>). The lecture on #lecture-link("ppad_completeness", <sec-generalized-circuits>)[_PPAD-hardness_] discusses this direction, focusing on how to encode fixed-point constraints as equilibrium incentives. These reductions explain the computational difficulty of Nash equilibrium computation.

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

#theorem[Sperner's lemma #citep(<sperner1928neuer>)][
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

We formalize these ideas in the next sections, arriving at two results. First, we will show a complete proof of Brouwer's fixed point theorem, using Sperner's lemma and a compactness argument. Second, we will establish the following computational reduction. Suppose we are given access to an algorithm that takes as input a Sperner coloring of a triangulated grid and computes a trichromatic triangle guaranteed by Sperner's lemma. Then, we can use this algorithm to compute approximate Brouwer fixed points of a Lipschitz continuous function, $f$, from $[0 \, 1]^2$ to itself, by discretizing the domain into a grid whose cells have small enough diameter, as a function of the Lipschitz constant and the desired approximation, coloring the vertices of this grid according to the scheme presented above, and finding a trichromatic triangle #citep(<papadimitriou1994parity>, <hirsch1989exponential>). We illustrate how this reduction would work with an example.

#example[
  The following plots illustrate the Sperner discretization of the Nash improvement function in the #lecture-link("nfgs_nash", <sec-nash-improvement>)[three running examples for the Nash improvement function].

  #align(center)[
    #image("figures/brouwer/example_games.svg", width: 100.0%)
  ]
]

It is worth noting that the trichromatic triangles obtained via the above reduction are not always in the proximity of exact fixed points of the function. Unless the discretization is fine enough and $f$ has extra properties, we will only guarantee that the trichromatic triangles are in the proximity of approximate fixed points. While this is not the case in the examples above, it can be the case.

== Formalizing the connection <sec-brouwer-approximation>

To make the argument formal, we need to establish a formal connection between a trichromatic triangle and an approximate Brouwer fixed point, and connect that to a choice of discretization parameter.

By the Heine-Cantor theorem #citep(<rudin1976principles>, [Thm.~4.19]), any continuous function $f$ on a compact set is _uniformly_ continuous, which implies that:

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

#corollary[Brouwer's fixed point theorem, unit square #citep(<brouwer1911abbildung>)][
  Any continuous function from $[0 \, 1]^2$ to itself has a fixed point.
]

#proof[
  Consider the sequence of approximation parameters $epsilon.alt_i := 2^(- i)$ for $i in bb(N)_(>= 1)$, and the corresponding discretization parameters $delta_i := min {delta (epsilon.alt_i) \, epsilon.alt_i}$, as in @cor:sperner. For each $i$, we color the vertices of the resulting triangulation as above, so that they satisfy the conditions of Sperner's lemma, and identify a trichromatic triangle which is then guaranteed to exist. Let us denote by $vz_(Y \, i)$ the yellow vertex of that triangle, which satisfies $∥f (vz_(Y \, i)) - vz_(Y \, i)∥_oo < 2 epsilon.alt_i$. Now consider the sequence of points $\( vz_(Y \, i) \)_i$. Since $vz_(Y \, i) in [0 \, 1]^2$ for all $i$, and $[0 \, 1]^2$ is a compact set, there exists a convergent subsequence $\( vz_(Y \, n_j) \)_j$; let $vz_Y^(*)$ denote the limit of this subsequence. By the continuity of $f$, the function $d \( vz \) := ∥f \( vz \) - vz∥_oo$ is also continuous. Hence,

  $ d (vz_Y^(*)) = lim_(j -> oo) d (vz_(Y \, n_j)) . $

  Since $d (vz_(Y \, n_j)) in [0 \, 2 dot.op 2^(- j)]$, we conclude $d (vz_Y^(*)) = 0$, which is equivalent to $f (vz_Y^(*)) = vz_Y^(*)$. This proves that a fixed point exists.
]

= Proof of Sperner's lemma <sec-sperner-proof>

Now we turn to proving Sperner's lemma. As it turns out, the lemma can be obtained as a corollary of a very basic parity argument on directed graphs #citep(<cohen1967sperner>, <papadimitriou1994parity>).

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

= Beyond the unit square <sec-brouwer-general>

We stated and proved Sperner's lemma for the two-dimensional grid, and used that to prove Brouwer's fixed point theorem for continuous functions mapping the unit square to itself. There is a $d$-dimensional generalization of Sperner's lemma, which can be used to prove Brouwer's fixed point theorem for continuous functions mapping $\[ 0 \, 1 \]^d$ to itself. In the high-dimensional  case, a $d$-dimensional grid is partitioned into simplices, the $d$-dimensional analog of triangles, without introducing any more vertices other than those in the grid #citep(<kuhn1960combinatorial>). The vertices of the grid are now colored with $d + 1$ colors, $0 \, 1 \, ... \, d$. Now, a coloring is valid if color $i$ is not present in facet $x_i = 0$, for all $i = 1 \, ... \, d$, and color $0$ is not present in all facets $x_i = 1$, for all $i = 1 \, ... \, d$. Sperner's lemma guarantees the existence of a simplex that has all $d + 1$ colors on its $d + 1$ vertices. Using the $d$-dimensional version of Sperner's lemma to prove Brouwer's fixed point theorem for continuous functions mapping the $d$-dimensional hypercube to itself is analogous to the $d = 2$ case. Finally, given Brouwer's fixed point theorem for the hypercube it is not hard to prove it for other convex and compact sets. Given a function defined on an arbitrary convex and compact set, one can first affinely transform the coordinate system so the set lies inside the unit hypercube. Then the function can be extended outside of the set by first projecting points of the hypercube to the set and then applying the function. This will not introduce any spurious fixed points.

= A query lower bound for Sperner's lemma <sec-sperner-query-lower-bound>

Our proof of Sperner's lemma is constructive: starting from the entry door at the bottom-left cell and following the edges of the Sperner graph, we are bound to reach a trichromatic triangle. The walk, however, may visit a large fraction of the $2 N^2$ triangles of the grid. This matters when the grid is huge but its coloring is described succinctly, for example by a circuit that computes the color of a point from its coordinates written in binary, as in the reductions outlined at the start of this lecture. With $b$-bit coordinates, the grid has $2^b$ points per side, so the walk can take time exponential in $b$. Is there a cleverer algorithm? In this section, we show that there is not, as long as the algorithm learns about the coloring only by asking for the colors of individual points.

#definition[Query algorithms for Sperner][
  Fix $N$ and the grid of points $(i, j)$ with $0 <= i, j <= N$, triangulated as before. A _query algorithm_ has access to an unknown standard Sperner coloring $chi$ of the grid (@sec-sperner-proof) only through _queries_: at each step, it picks a point $p$, which may depend on the answers it received so far, and learns $chi(p)$. When it stops, it outputs a triangle of the grid. The algorithm is _correct_ if, for every standard Sperner coloring, the triangle it outputs is trichromatic.
] <def-sperner-query-model>

#theorem[Query lower bound for Sperner][
  Let $N >= 16$ and $K := floor((N - 4) \/ 12)$. Every correct deterministic query algorithm makes at least $ceil((K - 1) \/ 2)$ queries on some standard Sperner coloring of the grid.

  In particular, if $N = 2^b - 1$, so that each coordinate of a point is a $b$-bit number, the algorithm makes at least $(2^b - 28) \/ 24$ queries on some coloring, which is exponential in $b$.
] <thm-sperner-query-lower-bound>

For instance, with $b = 40$ bits per coordinate, every correct query algorithm needs more than $4.5 dot 10^(10)$ queries on some coloring. Lower bounds of this kind go back to Hirsch, Papadimitriou, and Vavasis #citep(<hirsch1989exponential>), who proved them for algorithms that search for an approximate fixed point of a Lipschitz continuous function by evaluating it, and to Crescenzi and Silvestri #citep(<crescenzi1998sperner>) for Sperner's lemma itself. We give a self-contained proof. It is an _adversary argument_: we describe an adversary that answers the algorithm's queries on the fly, always consistently with some standard Sperner coloring, but that avoids committing to the location of a trichromatic triangle for as long as possible. You can play against this adversary in @sec-sperner-adversary-game.

== Tunnel colorings <sec-sperner-tunnels>

The adversary only ever answers according to colorings of a special form, called _tunnel colorings_. @fig-sperner-bands shows an example.

#paragraph-marker() *Bands and diagonal squares.*~~ Leave a _margin_ of two points along each side of the grid, and cut the remaining coordinates into $K$ _bands_ of width $12$: band $u in {0, ..., K - 1}$ consists of the coordinates $12 u + 2, ..., 12 u + 13$, and its _center line_ is $c_u := 12 u + 8$. Coordinates larger than $12 K + 1$ are also part of the margin. The _block_ $(u, v)$ is the set of points whose first coordinate lies in band $u$ and whose second coordinate lies in band $v$. The $K$ blocks $(u, u)$ are the _diagonal squares_; we refer to block $(u, u)$ simply as square $u$.

#paragraph-marker() *Tunnels and walls.*~~ A _tunnel_ is a sequence $0 = a_0 -> a_1 -> dots.c -> a_k$ of distinct squares. We draw it as an oriented lattice path, the _wall_, made of the following pieces:
- the _door piece_, which starts at the point $(0, 1)$, goes right to $(c_0, 1)$, and then up to the center $(c_0, c_0)$ of square $0$;
- for each _hop_ $u -> v$ of the tunnel, a _sideways leg_ along the center line of row band $u$, from $(c_u, c_u)$ to $(c_v, c_u)$, followed by an _up-or-down leg_ along the center line of column band $v$, from $(c_v, c_u)$ to $(c_v, c_v)$.
The wall ends at the center $e := (c_(a_k), c_(a_k))$ of the last square $a_k$, which we call the _dead end_.

Each square is left at most once and entered at most once. So each row band carries at most one sideways leg, namely that of the hop leaving the square of that band, and each column band carries at most one up-or-down leg, namely that of the hop entering the square of that band. Different legs can therefore meet only where a sideways leg crosses an up-or-down leg, at the center of a block. Wherever this happens, we _rewire_ the wall inside that block so that the two legs do not touch, as in @fig-sperner-walls(e): the incoming sideways leg is joined to the outgoing up-or-down leg, and the incoming up-or-down leg is joined to the outgoing sideways leg, both keeping their direction, using detours at distance $4$ from the center. The rewiring may split off closed loops of wall, which we call _islands_. Every point of the wall other than $(0, 1)$ and $e$ is still entered once and left once, so the wall consists of a single path from $(0, 1)$ to $e$, together with the islands.

#figure(
  caption: [A tunnel coloring with $K = 4$ diagonal squares (shaded; the bands are dashed). The tunnel is $0 -> 2 -> 1 -> 3$. The hop $1 -> 3$ crosses the hop $0 -> 2$ in block $(2, 1)$, where the wall is rewired; this splits off an island through squares $1$ and $2$. The only trichromatic triangle (green, circled) is at the dead end, in square $3$.],
)[
  #image("figures/brouwer/sperner_bands.svg", width: 62%, alt: "A 53 by 53 grid of mostly blue points with four shaded diagonal squares. A red wall with a yellow side runs from the door at the bottom-left corner through squares 0, 2, 1 and 3, and ends at a circled trichromatic triangle in square 3; a separate red-and-yellow loop passes through squares 1 and 2.")
] <fig-sperner-bands>

#paragraph-marker() *Colors.*~~ Walk along the wall in its direction, including the islands. Color every point of the wall red. Color yellow every other point that lies immediately to the right of the wall, as well as the outer corner of every left turn (@fig-sperner-walls(b)). Color every remaining point blue. Finally, impose the standard boundary coloring: red on the left side except for the bottom-left corner, yellow at the bottom except for the bottom-right corner, and blue elsewhere. The result is the _tunnel coloring_ of the tunnel.

Every piece of wall stays at distance at least $4$ from every other piece, except for the piece just before or after it, and every corner of the wall except $(c_0, 1)$ has both coordinates divisible by $4$. Moreover, the wall and its yellow side stay within distance $5$ of the center line of the band that carries them, and therefore inside that band.

#figure(
  caption: [Close-ups of the walls of a tunnel coloring, triangulated as in the rest of the lecture. Each wall is walked in the direction of the arrow and has its yellow side on the right. In (a)–(c), and around every corner of the rewired crossing (e), no triangle has both a yellow and a blue vertex next to a red point. Only the dead end (d) creates a trichromatic triangle.],
)[
  #image("figures/brouwer/sperner_walls.svg", width: 72%, alt: "Five small colored grids: a straight wall, a left turn, a right turn, a dead end with one green trichromatic triangle, and a crossing block in which two walls are rewired so that they do not touch.")
] <fig-sperner-walls>

#lemma[Tunnel colorings][
  Every tunnel coloring is a standard Sperner coloring, and each of its trichromatic triangles has the dead end $e$ as a vertex. In particular, all of its trichromatic triangles lie in the last square $a_k$ of the tunnel.
] <lem-sperner-tunnel-coloring>

#proof[
  The boundary coloring is standard by construction. The three vertices of a triangle are within $ell_oo$ distance $1$ of each other, and a trichromatic triangle has exactly one red vertex $r$. So it suffices to show that when $r != e$, every yellow point and every blue point within distance $1$ of $r$ are at distance $2$ from each other.

  If $r$ lies on the left side of the grid, its only yellow neighbors are $(0, 0)$ and $(1, 0)$, when $r = (0, 1)$, and they are at distance $2$ from the only blue neighbor $(1, 2)$ of that point. Otherwise, $r$ lies on the wall. The colors of the points within distance $1$ of $r$ depend only on the wall within distance $2$ of $r$. Since pieces of wall that do not follow each other are at distance at least $4$, and corners are at least $4$ apart, this is the piece of wall through $r$, possibly with a corner. Hence, up to rotation, the points within distance $1$ of $r$ are colored as in @fig-sperner-walls(a)–(c): the wall runs straight past $r$, or it turns left or right at $r$ or at a neighbor of $r$, or it ends at $r = e$. (A corner at distance $2$ from $r$ does not change these colors; near the bottom of the grid, the yellow side of the door piece is the bottom row.) In each of the first cases, the yellow neighbors of $r$ lie on the right of the wall and its blue neighbors on the left, at distance $2$ from each other. Hence $r = e$.

  Finally, the wall reaches $e$ from below or from above. @fig-sperner-walls(d), rotated by $180 degree$ in the second case (which preserves the triangulation), shows that exactly one triangle at $e$ is trichromatic. It lies in square $a_k$, because $e$ is at distance at least $5$ from the sides of that square.
]

We also verified @lem-sperner-tunnel-coloring by computer for every tunnel with at most $9$ diagonal squares: each tunnel coloring is a standard Sperner coloring with exactly one trichromatic triangle, at the dead end.

== The adversary <sec-sperner-adversary>

For a tunnel $0 = a_0 -> dots.c -> a_k$, we write $S(v) := a_(i + 1)$ if $v = a_i$ with $i < k$, and $P(u) := a_(i - 1)$ if $u = a_i$ with $i >= 1$; in words, $S(v)$ is the square after $v$ on the tunnel and $P(u)$ the square before $u$. We leave $S(v)$ undefined if $v$ is the dead end or not on the tunnel, and $P(u)$ undefined if $u = 0$ or $u$ is not on the tunnel.

#lemma[Locality][
  The points of the margin have the same color in every tunnel coloring. The color of a point in block $(u, v)$ depends only on $u$, $v$, $S(v)$, and $P(u)$.
] <lem-sperner-locality>

#proof[
  Since walls and their yellow sides stay inside the bands that carry them, the only parts of the drawing that reach block $(u, v)$ are the sideways leg in row band $v$, which belongs to the hop $v -> S(v)$; the up-or-down leg in column band $u$, which belongs to the hop $P(u) -> u$; and, if $u = v = 0$, the door piece. Whether these legs exist, whether they pass through block $(u, v)$, and how they are rewired if they cross there are determined by $u$, $v$, $S(v)$, and $P(u)$. The only part of the drawing that reaches the margin is the door piece, which is the same for every tunnel.
]

We can now describe the adversary. It keeps a tunnel, which only ever grows, and a set $T$ of _touched_ squares, containing every square that one of its answers depended on.

#pseudocode-list(
  numbered-title: [Sperner adversary],
  caption: [The adversary answers every query according to the tunnel coloring of its current tunnel. Squares in $T$ that are not on the tunnel will never join it.],
)[
  + Start with the tunnel $a_0 = 0$ (so $k = 0$) and $T = {0}$.
  + *On a query* at a point $p$:
    + *If* $p$ lies in a block $(u, v)$, rather than in the margin:
      + *If* $v = a_k$ and some square $w in.not T$ exists, extend the tunnel by the hop $a_k -> w$.
      + Add $u$ and $v$, as well as $S(v)$ and $P(u)$ if they are defined, to $T$.
    + Answer the color of $p$ in the tunnel coloring of the current tunnel.
] <algo-sperner-adversary>

#lemma[The adversary never contradicts itself][
  At any time, every answer given so far agrees with the tunnel coloring of the current tunnel $0 -> dots.c -> a_k$, and also with the tunnel coloring of the longer tunnel $0 -> dots.c -> a_k -> w$, for every square $w in.not T$.
] <lem-sperner-adversary-consistency>

#proof[
  Every answer is correct for the tunnel at the time it is given, and the tunnel only changes by hops $a_k -> w$ with $w in.not T$. So it suffices to show that such a hop does not change the color of any point queried so far.

  The new hop changes the drawing only in row band $a_k$, which holds its sideways leg, the new crossings along it, and the old dead end, and in column band $w$, which holds its up-or-down leg and the new crossings along it. No point in column band $w$ has been queried, because every query in a block $(u, v)$ adds $u$ and $v$ to $T$. No point in row band $a_k$ has been queried either: before $a_k$ joined the tunnel, it was not in $T$; after it became the dead end, a query in row band $a_k$ would have extended the tunnel beyond $a_k$, since $w$ was already outside $T$ at that time.
]

== Counting the queries

#proof[of @thm-sperner-query-lower-bound][
  Let $A$ be a correct deterministic query algorithm, and run it against the adversary. Each query adds at most two new squares to $T$. Indeed, every square on the tunnel is in $T$: square $0$ from the start, and every other square $w$ since the query that added it to the tunnel as $S(v)$. So $P(u)$, when defined, is already in $T$. If $v in.not T$, then $v$ is not on the tunnel and $S(v)$ is undefined. If $v in T$, then $S(v)$ is new only if the tunnel was just extended. Hence, after $c$ queries, $|T| <= 1 + 2 c$.

  Suppose that $A$ stops after $c$ queries and outputs a triangle $t$ while some square $w$ is still outside $T$. By @lem-sperner-adversary-consistency, the tunnel colorings of $0 -> dots.c -> a_k$ and of $0 -> dots.c -> a_k -> w$ both agree with all the answers that $A$ received, and by @lem-sperner-tunnel-coloring both are standard Sperner colorings. Since $A$ is deterministic, it makes the same queries and outputs the same triangle $t$ on both colorings. However, $t$ cannot be trichromatic in both: by @lem-sperner-tunnel-coloring, that would require $t$ to have both $(c_(a_k), c_(a_k))$ and $(c_w, c_w)$ as vertices, and these points are at distance at least $12$. This contradicts the correctness of $A$.

  Hence, $T$ contains all $K$ squares when $A$ stops, and so $1 + 2 c >= K$. Running $A$ on the tunnel coloring of the final tunnel produces exactly the same run, so $A$ makes $c >= ceil((K - 1) \/ 2)$ queries on that standard Sperner coloring. Finally, if $N = 2^b - 1$, then $K >= (N - 15) \/ 12$, so $(K - 1) \/ 2 >= (N - 27) \/ 24 = (2^b - 28) \/ 24$.
]

#remark[The bound is tight][
  Linearly many queries in $N$ suffice to find a trichromatic triangle #citep(<friedl2009blackbox>). The parity argument used to prove Sperner's lemma shows that, for any rectangle of the grid, the number of trichromatic triangles inside it has the same parity as the number of _red-yellow_ edges on its boundary. Initially, the whole grid has exactly one such boundary edge, the door. Cut the current rectangle in half along a line of grid points, query the points on that line, and keep a half whose boundary has an odd number of _red-yellow_ edges. After about $2 log_2 N$ rounds, the rectangle is a single square cell, which contains a trichromatic triangle. The lines have lengths about $N, N \/ 2, N \/ 2, N \/ 4, N \/ 4, ...$, so the algorithm makes about $3 N$ queries. The query complexity is therefore $Theta(N) = Theta(2^b)$: exponential in the number of bits $b$, but far smaller than the number of points in the grid.
] <rem-sperner-query-tight>

#remark[Randomization and circuits][
  Randomized query algorithms also need a number of queries that is polynomial in $N$, and therefore exponential in $b$ #citep(<friedl2009blackbox>, <chen2007paths>). @thm-sperner-query-lower-bound says nothing about algorithms that can read the circuit computing the coloring, rather than merely evaluate it: the adversary needs to leave the coloring undetermined, which a circuit given as input does not allow. For such algorithms, the difficulty of finding a trichromatic triangle is captured by the complexity class #lecture-link("tfnp", <sec-ppad>)[PPAD]: finding a trichromatic triangle in a two-dimensional Sperner coloring given by a circuit is PPAD-complete #citep(<chen2009discrete>). Proving that no polynomial-time algorithm exists for it would, in particular, prove that $"P" != "NP"$.
]

#remark[Connection to End-of-Line][
  The adversary hides a path from vertex $0$ in a graph whose vertices are the diagonal squares, and $S$ and $P$ play the roles of the successor and predecessor functions of the #lecture-link("tfnp", <sec-end-of-line>)[End-of-Line problem]. By @lem-sperner-locality, one color query reveals no more than four such values, namely $S(v)$, $P(S(v))$, $P(u)$, and $S(P(u))$, which is why the lower bound for Sperner mirrors the lower bound for finding the end of a line with oracle access to $S$ and $P$. Embedding the lines of an End-of-Line instance in the plane in this way, with crossings resolved locally, is also the main step in the proof that two-dimensional Sperner is PPAD-complete #citep(<chen2009discrete>).
]

== Playing against the adversary <sec-sperner-adversary-game>

The game below runs the adversary of @algo-sperner-adversary, choosing the square $w$ at random. Click a point to query its color, or drag along a row or a column to query all of its points; you win once you have queried the three vertices of a trichromatic triangle. The button “Show hidden coloring” reveals the tunnel coloring that the adversary is currently committed to, and “Run divide & conquer” runs the algorithm of @rem-sperner-query-tight. On grids that fit on a screen, $K$ is small and the guarantee of @thm-sperner-query-lower-bound is weak; the bound becomes large only because it doubles with every additional bit of $b$. The game also offers a “free mode” with a looser adversary whose tunnel can end anywhere in the grid. It is harder to beat by hand, but it is not the adversary analyzed above.

#interactive-demo("sperner-adversary", title: "Find the trichromatic triangle", height: 720)

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - Sep 24, 2025: fixed two typos (thanks Eric Yang Yu!)
  - Sep 29, 2026: added a query lower bound for finding trichromatic triangles, with an interactive demo.
]
