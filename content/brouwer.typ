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

  _Brouwer's fixed point theorem is a corollary of the fact that any directed graph has an even number of odd-degree vertices._

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
  ] <fig:sperner-coloring>
]

For the lemma to apply, the rules are simple. Each point is colored with one of three colors: red, blue, or yellow. The coloring must, however, satisfy the following _boundary_ conditions:

#[
  #set enum(numbering: "(i)")
  + The left column cannot contain any blue;
  + The bottom row cannot contain any red;
  + The right column and top row cannot contain any yellow.
]

Any coloring that satisfies these conditions is called a _Sperner coloring_. An example of a coloring satisfying these rules is shown in @fig:sperner-coloring.

Given any Sperner coloring, we are interested in finding a trichromatic triangle, that is, a triangular cell whose vertices are colored red, blue, and yellow. Sperner's lemma guarantees that such a cell is guaranteed to exist, no matter the Sperner coloring.

#theorem[Sperner's lemma #citep(<sperner1928neuer>)][
  Consider a Sperner coloring of a triangulated grid of any size. There must exist at least _one_ trichromatic triangle.

  In fact, there must exist an _odd_ number of trichromatic triangles.
] <thm-sperner>

We illustrate the previous theorem in the colored grid of @fig:sperner-coloring.

#example[
  #wrapped-figure(side: right, text-width: 60%)[
    In the coloring of @fig:sperner-coloring, there are a total of _five_ trichromatic triangles, as highlighted in green on the right.

    Indeed, five is an odd number, validating the statement of @thm-sperner.
  ][
    #image("figures/brouwer/sperner_triangulation.svg")
  ]
]

== The connection between Brouwer and Sperner <sec-brouwer-sperner>

What does Sperner's lemma have to do with Brouwer's fixed point theorem? The connection is not immediate, but upon second thought, several glimpses of connections emerge. For one, both results are existence results. Furthermore, both results are trivially false if the “boundary conditions” in their statements are violated. In the case of Brouwer's fixed point theorem,
the boundary conditions are that the continuous function must map the compact set to itself, i.e.~the boundary points must be mapped to somewhere inside the set. In the case of Sperner's lemma, the boundary conditions are the coloring rules on the boundary.

#wrapped-figure(side: left, text-width: 75%)[
  As it turns out, Sperner's lemma can be viewed as a “discretized version” of Brouwer's fixed point theorem. To see the connection, consider a continuous function mapping $[0,1]^2$ to itself and, depending on the direction of $f(vz) - vz$, assign red, yellow, or blue to the vertices of a fine, triangulated grid, whose boundary matches that of $[0,1]^2$, according to the rules shown on the left.
][
  #image("figures/brouwer/color_wheel.svg", width: 92.774pt)
]
(This coloring is a more boring version of the #lecture-link("nfgs_nash", <sec-nash-improvement>)[coloring of the Nash improvement function], but it will work for our purposes.)

If the direction of $f(vz) - vz$ lies in the yellow-blue, blue-red, or yellow-red boundary, we can assign any one of the two compatible colors, but we will make sure that, for grid points lying on the boundary of $[0,1]^2$, we will break ties in favor of the color that does not violate the Sperner coloring conditions. Because $f$ maps $[0,1]^2$ to itself, there should always be at least one such option! Thus, the coloring we will obtain will be a valid Sperner coloring, and it will have at least one trichromatic~triangle.

In turn, it should be intuitively clear why trichromatic triangles have value vis-à-vis the fixed point behavior of $f$: they are triangles where $f(vz) - vz$ changes direction within a small distance and, due to continuity, $f(vz) - vz$ can't be too large.

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

The only real-analysis input for the next theorem is a standard compactness argument: by the Heine-Cantor theorem #citep(<rudin1976principles>, [Thm.~4.19]), continuity of $f$ on the compact square $[0,1]^2$ implies _uniform_ continuity. Thus one choice of $delta(epsilon.alt)$ works throughout the square:

#math.equation(
  block: true,
  numbering: "(1)",
  $forall epsilon.alt > 0, exists delta(epsilon.alt) & > 0 :\
  & norm(vz - vw)_oo < delta(epsilon.alt) quad ==> quad norm(f(vz) - f(vw))_oo < epsilon.alt.$.body,
) <eq:uniform-continuity>

Now, given $f$ and $epsilon.alt$, consider a triangulation of $[0,1]^2$ in which the diameter of every triangle is $delta$ in $ell_oo$. Assign colors to the vertices of the triangulation according to the direction of $f(vz) - vz$, using the coloring scheme discussed above, and breaking ties in an arbitrary way but respecting the Sperner coloring conditions. Let us call the resulting coloring a _Sperner discretization of $f$ of diameter $delta$_. Then, the following approximation bound can be established.

#theorem[
  Suppose that $vz_Y$ is the yellow corner of a trichromatic triangle in a Sperner discretization of some continuous function $f : [0,1]^2 -> [0,1]^2$ of diameter $delta <= delta(epsilon.alt)$, where $delta(epsilon.alt)$ satisfies~(@eq:uniform-continuity) for some $epsilon.alt$. Then

  $ norm(f(vz_Y) - vz_Y)_oo < epsilon.alt + delta. $
] <thm-sperner-approximation>

#proof[
  Let $vz_R, vz_B,$ and $vz_Y$ be the red, blue, and yellow vertices of the trichromatic triangle. The key observation is that, by the coloring rule:

  - $(f(vz_Y) - vz_Y)_x$ and $(f(vz_B) - vz_B)_x$ have opposite signs if they are nonzero
  - $(f(vz_Y) - vz_Y)_y$ and $(f(vz_R) - vz_R)_y$ have opposite signs if they are nonzero

  Thus, we can write

  $
    abs((f(vz_Y) - vz_Y)_x) & <= abs((f(vz_Y) - vz_Y)_x - (f(vz_B) - vz_B)_x) \
                            & <= abs((f(vz_Y) - f(vz_B))_x - (vz_Y - vz_B)_x) \
                            & <= norm(f(vz_Y) - f(vz_B))_oo + norm(vz_Y - vz_B)_oo < epsilon.alt + delta.
  $

  and similarly

  $
    abs((f(vz_Y) - vz_Y)_y) & <= abs((f(vz_Y) - vz_Y)_y - (f(vz_R) - vz_R)_y) \
                            & <= abs((f(vz_Y) - f(vz_R))_y - (vz_Y - vz_R)_y) \
                            & <= norm(f(vz_Y) - f(vz_R))_oo + norm(vz_Y - vz_R)_oo < epsilon.alt + delta.
  $

  From here, we can just use the definition of infinity norm:

  $ norm(f(vz_Y) - vz_Y)_oo = max {abs((f(vz_Y) - vz_Y)_x), abs((f(vz_Y) - vz_Y)_y)} < epsilon.alt + delta. $
]

#corollary[
  Consider the same setup as before, but now choose $delta := min {delta(epsilon.alt), epsilon.alt}$ for a given $epsilon.alt > 0$. Then $vz_Y$ is a $2 epsilon.alt$-approximate fixed point of $f$, i.e.~

  $ norm(f(vz_Y) - vz_Y)_oo < 2 epsilon.alt. $
] <cor:sperner>

In turn, using a standard compactness argument, @cor:sperner implies Brouwer's fixed point theorem for continuous functions from $[0,1]^2$ to itself.

#corollary[Brouwer's fixed point theorem, unit square #citep(<brouwer1911abbildung>)][
  Any continuous function from $[0 \, 1]^2$ to itself has a fixed point.
]

#proof[
  The function $d(vz) := norm(f(vz) - vz)_oo$ is continuous on the compact square $[0,1]^2$. By Weierstrass's extreme value theorem, it attains a minimum $m >= 0$ at some point $vz^*$. For every $epsilon.alt > 0$, @cor:sperner gives a point $vz$ with $d(vz) < 2 epsilon.alt$, so $m < 2 epsilon.alt$ for every $epsilon.alt > 0$. Therefore $m = 0$, and $f(vz^*) = vz^*$.
]

= Proof of Sperner's lemma <sec-sperner-proof>

Now we turn to proving Sperner's lemma. As it turns out, the lemma can be obtained as a corollary of a very basic parity argument on directed graphs #citep(<cohen1967sperner>, <papadimitriou1994parity>).

#wrapped-figure(side: right, text-width: 60%)[
  Before jumping into the proof, let us make our life simpler. Without loss of generality, we will assume that, at the boundary of the grid, the Sperner coloring is as in the figure on the right: red on the left (except for the bottom-left corner), yellow on the bottom (except for the bottom-right corner), and blue everywhere else. We will call this boundary coloring the _standard boundary coloring_ and we will call a Sperner coloring satisfying this a _standard Sperner coloring_.
][
  #image("figures/brouwer/sperner_padded.svg", width: 100%)
]

Assuming a standard Sperner coloring is without loss of generality. Indeed, if a given Sperner coloring is not standard (as in~@fig:sperner-coloring), we can always augment the grid with an additional layer of boundary that is colored in the standard way, and embed the given Sperner coloring in the inside. Due to the properties of Sperner colorings and the standard boundary coloring, this operation will not introduce any trichromatic triangles between the extra boundary and the old boundary.

Now that our boundary coloring is standard, we can easily show Sperner's lemma using a graph-theoretic argument. Given a standard Sperner coloring we can define a directed graph, called _Sperner graph_, as follows:

#wrapped-figure(side: left, text-width: 55%)[
  - there are as many nodes in the graph as there are triangular cells in the grid; each cell of the grid is identified with a node of the graph;
  - there is a directed edge $u -> v$ from node $u$ to node $v$ in the graph if their corresponding cells $u$ and $v$ in the grid share a _red-yellow_ edge and, in order to go from cell $u$ to cell $v$, one would have to cross this edge having the red color on the left and the yellow color on the right.
][
  #image("figures/brouwer/sperner_paths.svg", width: 100%)
]

For the standard Sperner coloring of @fig:sperner-coloring, the corresponding graph is shown just above on the left.

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
] <thm:sperner-graph-properties>

#proof[
  #[
    #set enum(numbering: "(1)")
    + follows by noticing that every cell has at most one _red-yellow_ edge that one can use to exit this cell while keeping red on the left, and at most one _red-yellow_ edge that one can use to enter this cell while keeping red on the left.
    + can be shown by contradiction. Take any node with indegree $1$ and outdegree $0$, and assume for contradiction that it is not a trichromatic triangle. Since the indegree is $1$, one of the sides of the cell corresponding to the node is red-yellow and this edge can be crossed to enter into this cell from a neighboring cell. Let us now consider the third vertex of the cell. Since by assumption the cell is not trichromatic, the third vertex is either red or yellow. Either case results in another red-yellow edge that one would be able to cross to exit the cell keeping red on the left. The only reason why this would not mean that the outdegree of the node corresponding to that cell is $1$ is that this edge lies on the boundary of the grid. However, there are no such red-yellow edges on the boundary of the grid in the standard Sperner coloring. There is a unique red-yellow edge in the standard boundary coloring (at the bottom left cell) but this is an entry door, not an exit one.
    + can be shown with a similar argument as (2).
  ]
]

== Completing the proof of Sperner's lemma

At this point, the proof of Sperner's lemma is immediate. A graph in which each node has indegree at most one and outdegree at most one is composed of connected components that can only be singleton nodes, directed paths, or directed simple cycles. Only paths have nodes with outdegree $1$ and indegree $0$, or outdegree $0$ and indegree $1$; each has exactly one of each. Note also that the standard boundary coloring forces the bottom left cell not to be trichromatic, and node corresponding to this cell to have outdegree $1$ and indegree $0$. So this node must be the source of a path. The sink of that path is trichromatic as per~@thm:sperner-graph-properties. If there are other paths, both their source and their sink are trichromatic, as per~@thm:sperner-graph-properties. Hence, there are an odd number of trichromatic triangles in any standard Sperner coloring, and therefore any Sperner coloring.

= Why the proof is not an efficient algorithm <sec-sperner-computation>

This proof of @thm-sperner also gives us an algorithm to find a trichromatic triangle: start at the bottom-left cell and follow the path in the Sperner graph until it stops. Why, then, is finding trichromatic triangles considered a hard computational problem?

It is not if the coloring of the grid is given explicitly as an input. Writing down the colors of an $N times N$ grid already takes $N^2$ space, and the walk visits at most $2 (N - 1)^2$ cells. So following the path takes time linear in the size of the input. That's computationally feasible.

It can break if the coloring is given as a description only. For example, if the colors come from an input Boolean circuit that reads the coordinates of a point and outputs its color, it can describe a grid far larger (exponentially large) than the size of the circuit, so we can no longer afford to walk the path. The only way left is to reason about the circuit and find the triangle from it directly. In our case, the coloring of the grid is not given explicitly. By @sec-brouwer-approximation, we get the coloring from the improvement function and the grid diameter $delta$ chosen in @cor:sperner; the grid then has about $1\/delta$ points per side, and $delta$ itself is given with about $log(1\/delta)$ bits. So if we take $1\/delta = 2^n$ then our grid is of the size $2^n times 2^n$. Thus a walk can take time in the order of $2^(2 n)$, but our input is only the game and about $n$ bits for $delta$. So in this case the algorithm takes exponential time in the input.

The alternative is to inspect the improvement function and work out where the colors must clash, without following the path at all. No general technique for this is known. So a trichromatic triangle is guaranteed to exist, and is easy to check once found, but no polynomial-time algorithm is known for finding one in a grid described this way. This gap is made precise by #lecture-link("tfnp", <sec-end-of-line>)[the End-of-Line problem].


#example[
  The accompanying #link("https://colab.research.google.com/drive/1VyefBluGV8LUO3cj5zc8WJhNmqI9gAoV?usp=sharing")[notebook] puts this proof to work for two-player two-action games: it constructs the Sperner coloring induced by the players' best-response map and uses a trichromatic triangle to recover a Nash equilibrium. This gives a concrete computational view of the existence argument developed above.
]

= Beyond the unit square <sec-brouwer-general>

We stated and proved Sperner's lemma for the two-dimensional grid, and used that to prove Brouwer's fixed point theorem for continuous functions mapping the unit square to itself.

The square is not essential to Sperner's lemma. Suppose we triangulate a triangle whose three corners are colored red, yellow, and blue. On each boundary side, allow only the colors of its two endpoints. Interior vertices may have any of the three colors. This boundary rule also guarantees a trichromatic small triangle. Indeed, the red-yellow side has an odd number of red-yellow edges, since its colors begin red and end yellow, while the other two sides have none. Counting red-yellow edges over all small triangles, interior edges are counted twice. Each trichromatic triangle has exactly one such edge, whereas each nontrichromatic triangle has zero or two. Thus the number of trichromatic triangles is odd, and in particular nonzero.

There is a $d$-dimensional generalization of Sperner's lemma, which can be used to prove Brouwer's fixed point theorem for continuous functions mapping $\[ 0 \, 1 \]^d$ to itself. In the high-dimensional  case, a $d$-dimensional grid is partitioned into simplices, the $d$-dimensional analog of triangles, without introducing any more vertices other than those in the grid. The vertices of the grid are now colored with $d + 1$ colors, $0 \, 1 \, ... \, d$. Now, a coloring is valid if color $i$ is not present in facet $x_i = 0$, for all $i = 1 \, ... \, d$, and color $0$ is not present in all facets $x_i = 1$, for all $i = 1 \, ... \, d$. Sperner's lemma guarantees the existence of a simplex that has all $d + 1$ colors on its $d + 1$ vertices. Using the $d$-dimensional version of Sperner's lemma to prove Brouwer's fixed point theorem for continuous functions mapping the $d$-dimensional hypercube to itself is analogous to the $d = 2$ case. Finally, given Brouwer's fixed point theorem for the hypercube it is not hard to prove it for other convex and compact sets. Given a function defined on an arbitrary convex and compact set, one can first affinely transform the coordinate system so the set lies inside the unit hypercube. Then the function can be extended outside of the set by first projecting points of the hypercube to the set and then applying the function. This will not introduce any spurious fixed points.

= Necessity of the hypotheses <sec-brouwer-hypotheses>

_Continuity_, _compactness_, and _convexity_ are each necessary in Brouwer's theorem, as the following one- and two-dimensional counterexamples show. Since compactness in $RR^d$ means closed _and_ bounded, we treat those halves separately.

// Keep the picture with the text it explains.
#block(breakable: false)[
  #example[dropping continuity][
    #wrapped-figure(side: right, text-width: 66%)[
      On $K = [0,1]$, which is nonempty, compact, and convex, define
      $ f(x) := cases(1 & "if" x < 1\/2, 0 & "if" x >= 1\/2). $
      This maps $K$ into itself, but it has no fixed point: every $x < 1\/2$ is sent to $1 != x$, and every $x >= 1\/2$ is sent to $0 != x$. Rather than crossing the diagonal (where $f(x)=x$), the function jumps over it at $x = 1\/2$.
      
      The Sperner discretization behind @thm-sperner-approximation needed a modulus $delta(epsilon.alt)$ of uniform continuity, and a discontinuous $f$ admits no such modulus.
    ][
      #image("figures/brouwer/hyp_continuity.svg", width: 82pt)
    ]
  ]
]

// Keep the picture with the text it explains.
#block(breakable: false)[
  #example[dropping boundedness][
    #wrapped-figure(side: right, text-width: 66%)[
      Take $K = RR$, which is nonempty, closed, and convex, but unbounded, and let $f(x) := x + 1$. This is continuous and maps $K$ into itself, yet $f(x) = x$ would force $1 = 0$. Informally, the fixed point has escaped to infinity. The same happens in the plane under any nonzero translation $f(vz) := vz + vu$.
    ][
      #image("figures/brouwer/hyp_bounded.svg", width: 109pt)
    ]
  ]
]

// Keep the picture with the text it explains.
#block(breakable: false)[
  #example[dropping closedness][
    #wrapped-figure(side: right, text-width: 66%)[
      Take $K = (0,1]$, which is nonempty, bounded, and convex, but not closed ($x=0 in.not K$), and let $f(x) := x\/2$. Then $f$ is continuous and maps $K$ into itself, since $x\/2 in (0,1\/2]$ whenever $x in (0,1]$. A fixed point would satisfy $x = x\/2$, that is $x = 0$, the point that $K$ is missing.
    ][
      #image("figures/brouwer/hyp_closed.svg", width: 82pt)
    ]
  ]
]

// Keep the picture with the text it explains.
#block(breakable: false)[
  #example[dropping convexity][
    #wrapped-figure(side: right, text-width: 66%)[
      Take $K = {vz in RR^2 : norm(vz)_2 = 1}$, the unit circle, which is nonempty and compact. It is not convex: convexity asks that the segment joining any two points of $K$ stay inside $K$, and the segment from $(1,0)$ to $(-1,0)$ passes through the origin, which has norm $0$ rather than $1$. The disk $norm(vz)_2 <= 1$ is convex, but it is exactly the center that $K$ omits. Let $f$ be the quarter-turn rotation
      $ f(x, y) := (-y, x). $
      This is continuous and maps $K$ onto itself, and it displaces every point of the circle, so it has no fixed point.
    ][
      #image("figures/brouwer/rotation_circle.svg", width: 67pt)
    ]
  ]
]

// Keep the picture with the text it explains.
#block(breakable: false)[
  #remark[
    Fun fact! Convexity is more than the theorem needs. Brouwer's theorem holds on any set homeomorphic to a closed ball, and the passage at the end of @sec-brouwer-general carries it from the hypercube to any compact convex set. What defeats the circle is not non-convexity but the hole.

    The blob on the left below is not convex --- the dashed chord between two of its points leaves the set --- yet it is a deformed disk, so every continuous self-map of it still has a fixed point. The annulus on the right is the opposite case: its hole is what gives a rotation room to move every point.

    #v(1mm)
    #align(center)[#image("figures/brouwer/convexity_relaxed.svg", width: 198pt)]
  ]
]

= Problems <sec-brouwer-problems>

#exercise[Splitting the Rent][
  
  Three roomates (Costis, Nathan, and Gabriele) just moved in together to a 3-bedroom apartment. They want to decide who gets which room and how to split the \$3000 rent. Call the rooms $R,Y,B$ (red, yellow, blue) and the roommates $C,N,G$. Rooms are not identical and different roommates may value them differently.
  
  Define a "valid rent split" to be a tuple of three non-negative integers $p_R, p_Y, p_B >= 0$ with $p_R + p_Y + p_B = 3000$. Each roommate $C,N,G$ has a desire function $d_C, d_N, d_G : ZZ_(>=0)^3 -> {R,Y,B}$ respectively that maps a valid rent split to a room they prefer. For example, $d_C (p_R, p_Y, p_B)=R$ means that Costis prefers the red room at these prices. Assume that if some room has price 0, then _every_ roommate prefers it to any room with non-zero price. Specifically,
  - if $p_R = 0$, $d_C (p_R,p_Y,p_B) = d_N (p_R,p_Y,p_B) = d_G (p_R,p_Y,p_B) = R$
  - if $p_Y = 0$ and $p_R>0$, $d_C (p_R,p_Y,p_B) = d_N (p_R,p_Y,p_B) = d_G (p_R,p_Y,p_B) = Y$
  - if $p_B = 0$ and $p_R,p_Y>0$, $d_C (p_R,p_Y,p_B) = d_N (p_R,p_Y,p_B) = d_G (p_R,p_Y,p_B) = B$
  
  #strong[(a) 15 points.] Prove that there exists: (i) an assignment of roommates to rooms $r_C, r_N, r_G in {R, Y, B}$ (a permutation), and (ii) a valid rent split $p_R,p_Y,p_B$ such that everyone is _almost happy_. For every roommate $i in {C,N,G}$ there exists a valid rent split $p'_R,p'_Y,p'_B$ with $|p_R - p'_R| <= 1$ for all $r in {R, Y, B}$ such that $d_i (p'_R,p'_Y,p'_B)=r_i$.

  Hint: The discrete set of valid rent splits triangulate the simplex of non-negative triples summing to 3000. Consider a Sperner-style labeling of this triangulation.

  #solution[
    Consider the set of valid rent splits $ Delta={(p_R,p_Y,p_B) in ZZ_(>=0)^3 : p_R + p_Y + p_B = 3000} $
    This is a triangulation of the simplex of non-negative triples summing to 3000, where neighboring vertices differ by at most 1 in every coordinate. We assign one of the roommates as the owner of each vertex $v=(p_R, p_Y, p_B)$. Namely,
    the owner of vertex $v$ is the $i$th element of ${C, N, G}$ with $i = (p_R + 2 * p_Y) mod 3$. Each triangle then has one vertex owned by each roommate. We color each vertex $(p_R, p_Y, p_B)$ according the preference of the owner $d_i (p_R, p_Y, p_B)$. We override the coloring of the vertex $(0, 3000, 0)$ to be B so the boundary conditions of the Sperner coloring are satisfied. Also note the overridden triangle $(0, 3000, 0), (1, 2999, 0), (0, 2999, 1)$ is not trichromatic. By Sperner's lemma, there exists at least one trichromatic triangle. At this triangle, we have all three roommates, and all three colors. Picking any of the three vertices of this triangle as the prices, we have a valid rent split and an assignment of roommates to rooms that makes everyone almost happy - unhappy roommates would be happy with their rooms at the prices given by an adjacent vertex.
  ]
  
  #strong[(b) 10 points.] Design an algorithm that computes an assignment and prices that make every roommate almost happy (in the sense above). Your algorithm can query the desire functions $d_C,d_N,d_G$ on valid rent splits $(p_R,p_Y,p_B)$. For example, querying $d_C (p_R,p_Y,p_B)$ is asking Costis "Given valid rent split $(p_R,p_Y,p_B)$, which room do you prefer?"

  Hint: Use these queries to implement the proof of Sperner's lemma we saw in class.

  #solution[
    Iterate over all valid rent splits $(p_R,p_Y,p_B)$. At each valid rent split, we consider the triangle above and below it. For each triangle, for each vertex we identify the owner as the $i$th entry of ${C, N, G}$ with $i = (p_R + 2 * p_Y) mod 3 $. We then use the desire function ($d_C,d_N,d_G$) of the owner of that vertex to determine its coloring. If we find a trichromatic triangle, we return the prices corresponding to one of  the vertices of that triangle, and the room assignment given by the owners of each vertex and their desired rooms at those vertices. This algorithm runs in polynomial time with respect to the price of the apartment, $n=3000$, as there are $O(n^2)$ valid rent splits.
  ]
]

#exercise[No Retraction onto the Boundary][
  Let $D := {vz in RR^2 : norm(vz)_2 <= 1}$ be the closed unit disk and let $partial D$ be its boundary circle. A _retraction_ of $D$ onto $partial D$ is a continuous function $r : D -> partial D$ with $r(vz) = vz$ for every $vz in partial D$, as drawn below. Without the condition on $partial D$, the constant $vz |-> (1,0)$ would qualify.

  #align(center)[#image("figures/brouwer/retraction_idea.svg", width: 91pt)]

  #strong[(a)] Show that there is no retraction of $D$ onto $partial D$.

  Hint: Brouwer applied to $r$ itself is vacuous, since $r$ already fixes every point of $partial D$. Apply it to a different function built from $r$.

  #solution[
    Suppose $r$ is such a retraction, and set $f(vz) := -r(vz)$. Then $f$ is continuous, and $norm(f(vz))_2 = norm(r(vz))_2 = 1$ for every $vz in D$, so $f$ maps $D$ into $partial D subset.eq D$. Since $D$ is nonempty, compact, and convex, Brouwer's theorem (@sec-brouwer-general) yields $vz^(*) in D$ with $vz^(*) = f(vz^(*)) = -r(vz^(*))$. The left-hand side lies in $partial D$, as $f$ only takes values there, so $r$ fixes it: $r(vz^(*)) = vz^(*)$. Hence $vz^(*) = -vz^(*)$, that is, $vz^(*) = 0$. But $0 in.not partial D$, a contradiction. So no such $r$ exists.

    #align(center)[#image("figures/brouwer/retraction_proof.svg", width: 104pt)]
  ]

  #strong[(b)] Show the converse: if there is no retraction of $D$ onto $partial D$, then every continuous $f : D -> D$ has a fixed point. Together with (a), this says that Brouwer's theorem on the disk and the no-retraction statement are equivalent.

  Hint: If $f$ has no fixed point, then $f(vz) != vz$ for every $vz$, so the ray starting at $f(vz)$ and passing through $vz$ is well defined. Where does it leave the disk?

  #solution[
    Suppose $f : D -> D$ is continuous and has no fixed point. Then $f(vz) != vz$ for every $vz in D$, so the ray from $f(vz)$ through $vz$ is well defined. Let $r(vz)$ be the point where it crosses $partial D$, as in the figure.

    #align(center)[#image("figures/brouwer/retraction_ray.svg", width: 104pt)]

    We check that $r$ is a retraction.
    + $r(vz) in partial D$ by construction.
    + If $vz in partial D$, the ray reaches the circle at $vz$ itself, so $r(vz) = vz$.
    + $r$ is continuous. Write $r(vz) = f(vz) + t (vz - f(vz))$, where $t >= 1$ is the larger root of the quadratic equation $norm(f(vz) + t (vz - f(vz)))_2^2 = 1$ in $t$. Its coefficients depend continuously on $vz$, and its two roots are distinct because the line through $f(vz)$ and $vz$ contains two points of $D$ and so cannot be tangent to the circle. Hence $t$, and with it $r$, depends continuously on $vz$.

    So $r$ is a retraction of $D$ onto $partial D$, which contradicts (a). Therefore $f$ has a fixed point.
  ]
]

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - Sep 24, 2025: fixed two typos (thanks Eric Yang Yu!)
]
