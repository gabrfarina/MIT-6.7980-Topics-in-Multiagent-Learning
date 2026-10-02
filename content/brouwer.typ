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

== Lipschitz continuity of the Nash improvement function, and the reduction to Sperner <sec-nash-lipschitz>

#heading(level: 3, numbering: none)[Statement]

Consider a two-player game in which each player has two actions and every payoff lies in $[0, 1]$.

+ The Nash improvement function $f : [0, 1]^2 -> [0, 1]^2$ is $3$-Lipschitz in $ell_oo$:
  $ norm(f(vz) - f(vw))_oo <= 3 norm(vz - vw)_oo quad "for all" vz, vw in [0, 1]^2. $
+ On a Sperner grid with $N = ceil(4 \/ epsilon.alt)$ cells per side, the yellow corner $vz_Y$ of any trichromatic triangle satisfies
  $ norm(f(vz_Y) - vz_Y)_oo <= epsilon.alt, $
  so $vz_Y$ is an $epsilon.alt$-approximate fixed point.
+ The Sperner circuit maps a grid point to the color given by the direction of $f(vz) - vz$ at that point.

#heading(level: 3, numbering: none)[Step 0: Setup]

- *Payoffs.* $A_(a b)$ is player 1’s payoff and $B_(a b)$ is player 2’s payoff when player 1 plays action $a$ and player 2 plays action $b$. Every entry lies in $[0, 1]$.
- *Strategies.* Player 1 plays action 1 with probability $p$. Player 2 plays action 1 with probability $q$.
- *Points.* A pair of strategies is a point $vz = (p, q)$ in the unit square $[0, 1]^2$. Throughout, $vz$ and $tilde(vz) = (tilde(p), tilde(q))$ denote arbitrary points of the square. The corners of a Sperner triangle appear only in Step 6.
- *Distance.* $norm(vz - tilde(vz))_oo = max{abs(p - tilde(p)), abs(q - tilde(q))}$.

*Running example (coordination game).* $A_(11) = 1$, $A_(12) = 0$, $A_(21) = 0$, $A_(22) = 1$.

#heading(level: 3, numbering: none)[Step 1: Payoffs, regrets, and $D$]

*Payoffs.* Player 2 plays action 1 with probability $q$, so
$ u_1(1, q) = q A_(11) + (1 - q) A_(12), qquad u_1(2, q) = q A_(21) + (1 - q) A_(22). $
A mixed strategy gives a blend of the two:
$ u_1(p, q) = p u_1(1, q) + (1 - p) u_1(2, q). $

*Regrets.* A regret is the payoff from switching fully to an action, minus the current payoff:
$ r_(1, 1) = u_1(1, q) - [p u_1(1, q) + (1 - p) u_1(2, q)] = (1 - p) [u_1(1, q) - u_1(2, q)], $
$ r_(1, 2) = u_1(2, q) - [p u_1(1, q) + (1 - p) u_1(2, q)] = -p [u_1(1, q) - u_1(2, q)]. $

The same bracket appears in both regrets, so we name it:
$ D(q) = u_1(1, q) - u_1(2, q). $
This is how much better action 1 is than action 2 for player 1, given player 2’s mix $q$. With this name,
$ r_(1, 1) = (1 - p) D, qquad r_(1, 2) = -p D. $

_Intuition._ Player 1 already plays action 1 a fraction $p$ of the time. Switching fully to action 1 changes only the remaining $1 - p$, and each unit of that gains $D$.

_Example._ In the coordination game, $D(q) = q - (1 - q) = 2 q - 1$. At $q = 0.8$ we get $D = 0.6$, so action 1 is better.

*Player 2.* The same computation gives $r_(2, 1) = (1 - q) E$ and $r_(2, 2) = -q E$, where
$ E(p) = [p B_(11) + (1 - p) B_(21)] - [p B_(12) + (1 - p) B_(22)]. $

#heading(level: 3, numbering: none)[Step 2: The Nash improvement function on the square]

By #lecture-link("nfgs_nash", <def-nash-improvement>)[], for player 1:
$
  phi_(1, 1) = frac(p + [r_(1, 1)]^+, 1 + [r_(1, 1)]^+ + [r_(1, 2)]^+), qquad phi_(1, 2) = frac((1 - p) + [r_(1, 2)]^+, 1 + [r_(1, 1)]^+ + [r_(1, 2)]^+).
$

*One number per player.* The two numerators add up to
$ p + (1 - p) + [r_(1, 1)]^+ + [r_(1, 2)]^+, $
which is exactly the denominator. So $phi_(1, 1) + phi_(1, 2) = 1$, and player 1’s new strategy is determined by $phi_(1, 1)$ alone. The same holds for player 2. Hence
$ f(p, q) = (phi_(1, 1)(p, q), phi_(2, 1)(p, q)). $

_Check._ Take $p = 0.5$ and $D = 0.6$. Then $phi_(1, 1) = 0.8 \/ 1.3$ and $phi_(1, 2) = 0.5 \/ 1.3$, which sum to $1$.

*Two cases.* Since $p >= 0$ and $1 - p >= 0$, at most one of $[r_(1, 1)]^+$ and $[r_(1, 2)]^+$ is nonzero.

- If $D >= 0$: $[r_(1, 1)]^+ = (1 - p) D$ and $[r_(1, 2)]^+ = 0$, so
  $ 1 - phi_(1, 1) = frac(1 - p, 1 + (1 - p) D). $
- If $D < 0$: $[r_(1, 1)]^+ = 0$ and $[r_(1, 2)]^+ = p abs(D)$, so
  $ phi_(1, 1) = frac(p, 1 + p abs(D)). $

*Fixed points are equilibria.* $f(vz) = vz$ exactly when every regret is $<= 0$, that is, when no player can gain by switching. This is a Nash equilibrium.

#heading(level: 3, numbering: none)[Step 3: $D$ changes at most twice as fast as $q$]

Collecting the terms that contain $q$:
$ D(q) = underbrace((A_(12) - A_(22)), "constant") + q underbrace([(A_(11) - A_(21)) - (A_(12) - A_(22))], "slope"). $

This is a straight line in $q$. Each of $A_(11) - A_(21)$ and $A_(12) - A_(22)$ lies in $[-1, 1]$, so the slope lies in $[-2, 2]$. Therefore
$ abs(D(q) - D(tilde(q))) <= 2 abs(q - tilde(q)). $

Also $abs(D) <= 1$. By the same argument, $abs(E(p) - E(tilde(p))) <= 2 abs(p - tilde(p))$.

The coordination game has slope exactly $2$, so this bound is tight.

#heading(level: 3, numbering: none)[Step 4: Slopes of $phi_(1, 1)$]

Both cases of Step 2 have the shape
$ h(X, c) = frac(X, 1 + X c), qquad X in [0, 1], c >= 0. $
- For $D < 0$: $phi_(1, 1) = h(p, abs(D))$.
- For $D >= 0$: $1 - phi_(1, 1) = h(1 - p, D)$.

*Slopes of $h$.* By the quotient rule:
$
  frac(partial h, partial X) = frac((1 + X c) - X c, (1 + X c)^2) = frac(1, (1 + X c)^2) in [0, 1], qquad abs(frac(partial h, partial c)) = frac(X^2, (1 + X c)^2) <= 1.
$
Both bounds hold because the denominator is at least $1$ and $X <= 1$.

*Translating back to $p$ and $phi_(1, 1)$.* Changing $p$ changes $X$ by the same amount. For the case $D >= 0$, where $X = 1 - p$, only the sign flips. Likewise, changing $1 - phi_(1, 1)$ changes $phi_(1, 1)$ by the same amount with the opposite sign. Also, $abs(abs(D) - abs(tilde(D))) <= abs(D - tilde(D))$.

So in both cases, $phi_(1, 1)$ has slope at most $1$ in $p$ and at most $1$ in $D$.

_Direct check for $D >= 0$._ Differentiating $phi_(1, 1) = 1 - display(frac(1 - p, 1 + (1 - p) D))$ directly gives
$
  frac(partial phi_(1, 1), partial p) = frac(1, (1 + (1 - p) D)^2), qquad frac(partial phi_(1, 1), partial D) = frac((1 - p)^2, (1 + (1 - p) D)^2),
$
and both are at most $1$.

*The cases agree at $D = 0$.* Both formulas give $phi_(1, 1) = p$ there, so $phi_(1, 1)$ is continuous. A path that crosses $D = 0$ can be split at the crossing, and each piece bounded separately.

*From slopes to a bound (the L-shaped path).* A slope of at most $1$ means the output moves by at most as much as the input (mean value theorem). Go from $(p, D)$ to $(tilde(p), tilde(D))$ in two legs:
$ (p, D) limits(-->)^(med "change only" p med) (tilde(p), D) limits(-->)^(med "change only" D med) (tilde(p), tilde(D)). $
The first leg moves the output by at most $abs(p - tilde(p))$. The second leg moves it by at most $abs(D - tilde(D))$. By the triangle inequality,
$ abs(phi_(1, 1)(p, D) - phi_(1, 1)(tilde(p), tilde(D))) <= abs(p - tilde(p)) + abs(D - tilde(D)). $

#heading(level: 3, numbering: none)[Step 5: The Lipschitz constant is $3$]

Combining Steps 3 and 4:
$
  abs(phi_(1, 1)(vz) - phi_(1, 1)(tilde(vz))) <= underbrace(1 dot.op abs(p - tilde(p)), "direct") + underbrace(2 dot.op abs(q - tilde(q)), "through" D).
$

Each of $abs(p - tilde(p))$ and $abs(q - tilde(q))$ is at most $max{abs(p - tilde(p)), abs(q - tilde(q))} = norm(vz - tilde(vz))_oo$. So
$
  abs(phi_(1, 1)(vz) - phi_(1, 1)(tilde(vz))) <= 1 dot.op norm(vz - tilde(vz))_oo + 2 dot.op norm(vz - tilde(vz))_oo = 3 norm(vz - tilde(vz))_oo.
$

The same argument, using $E$ in place of $D$, bounds $phi_(2, 1)$. Hence
$ norm(f(vz) - f(tilde(vz)))_oo <= 3 norm(vz - tilde(vz))_oo, qquad L = 3. $

_Example._ Take $vz = (0.5, 0.8)$ and $tilde(vz) = (0.6, 0.75)$. Then $norm(vz - tilde(vz))_oo = 0.1$. The bound on the change in $phi_(1, 1)$ is $0.1 + 2 (0.05) = 0.2$, which is at most $3 times 0.1 = 0.3$.

This holds for *every* pair of points. Step 6 applies it to one particular pair, two corners of a Sperner triangle.

#heading(level: 3, numbering: none)[Step 6: The approximation theorem with an explicit Lipschitz constant]

*Setup.* Each grid point is colored by the direction of $f(vz) - vz$, using the rule of @sec-brouwer-sperner. Since $f$ maps the square to itself, this is a valid Sperner coloring, so a trichromatic triangle with corners $vz_Y, vz_B, vz_R$ exists. The coloring rule guarantees:

- the $x$-parts of $f(vz_Y) - vz_Y$ and $f(vz_B) - vz_B$ have opposite signs, or one of them is $0$;
- the $y$-parts of $f(vz_Y) - vz_Y$ and $f(vz_R) - vz_R$ have opposite signs, or one of them is $0$.

*The $x$-coordinate.* Let
$ a = (f(vz_Y) - vz_Y)_x, qquad b = (f(vz_B) - vz_B)_x. $

+ _Opposite signs._ Since $a$ and $b$ have opposite signs, $abs(a) <= abs(a - b)$. For example, $a = 3$ and $b = -2$ give $abs(a - b) = 5 >= 3$.
+ _Regroup._ Write $F_Y = f(vz_Y)_x$, $Y = (vz_Y)_x$, $F_B = f(vz_B)_x$ and $B = (vz_B)_x$. Then
  $ a - b = (F_Y - Y) - (F_B - B) = F_Y - Y - F_B + B = (F_Y - F_B) - (Y - B). $
  The original pairs (each output with its own input) are what we want to bound. The new pairs (outputs together, inputs together) are what we _can_ bound.
+ _Triangle inequality._ $abs(a) <= abs(F_Y - F_B) + abs(Y - B)$.

The corners of a single grid triangle are within $delta$ of each other in $ell_oo$. So:
- $abs(Y - B) <= norm(vz_Y - vz_B)_oo <= delta$;
- $abs(F_Y - F_B) <= norm(f(vz_Y) - f(vz_B))_oo <= L delta$, by Lipschitz.

The second bound is where the Lipschitz constant enters. It replaces the $epsilon.alt$ of @thm-sperner-approximation (which comes from uniform continuity) with the explicit quantity $L delta$.

Therefore $abs(a) <= (L + 1) delta$.

*The $y$-coordinate.* The same argument with $vz_R$ in place of $vz_B$ gives the same bound. Taking the larger coordinate,
$ norm(f(vz_Y) - vz_Y)_oo <= (L + 1) delta = 4 delta. $

#heading(level: 3, numbering: none)[Step 7: Grid size]

With $N$ cells per side, each cell has side $delta = 1 \/ N$. The corners of any triangle, for example $(i, j)$, $(i + 1, j)$ and $(i + 1, j + 1)$, differ by at most one cell in each coordinate. So they are within $delta$ of each other in $ell_oo$.

Requiring $4 delta <= epsilon.alt$ gives
$ N = ceil(4 / epsilon.alt), $
that is, an $(N + 1) times (N + 1)$ grid of points. Add one more ring if the grid is embedded in a standard boundary as in @sec-sperner-proof.

*From approximate fixed point to approximate equilibrium (optional).* Suppose $D >= 0$, and let player 1’s regret be $R = (1 - p) D$. Then
$ phi_(1, 1) - p = frac((1 - p)^2 D, 1 + (1 - p) D) >= R^2 / 2, $
because the denominator is at most $2$ and $1 - p >= R$ (as $abs(D) <= 1$). The case $D < 0$ is symmetric.

So an $eta$-approximate fixed point is a $sqrt(2 eta)$-Nash equilibrium. For an $epsilon.alt$-Nash equilibrium, take $eta = epsilon.alt^2 \/ 2$, which gives $N = ceil(8 \/ epsilon.alt^2)$.

#heading(level: 3, numbering: none)[Step 8: The Sperner circuit]

*Input.* A grid point $(i, j)$. Each coordinate is a number from $0$ to $N$. Since $n$ bits can write $2^n$ numbers, each coordinate takes about
$ log_2 N approx 2 + log_2(1 \/ epsilon.alt) = O(log(1 \/ epsilon.alt)) $
bits.

*Computation.*
+ Convert to strategies: $vz = (p, q) = (display(i / N), display(j / N))$.
+ Compute $D(q)$ and $E(p)$, then the regrets, then $f(vz) = (phi_(1, 1), phi_(2, 1))$. This uses only $+$, $-$, $times$, $÷$ and $max$.
+ Compute the displacement $f(vz) - vz$.
+ Output the color given by the direction of $f(vz) - vz$. On the outer boundary, output the standard boundary colors.

*Why the reduction is polynomial.* Take $epsilon.alt = 0.001$, for example. The grid has $N = 4000$ cells per side, about $1.6 times 10^7$ points in total. Yet each coordinate fits in $12$ bits, since $2^(12) = 4096$.

The circuit works only with $O(log(1 \/ epsilon.alt))$-bit coordinates and the payoff entries, so its size is polynomial in the input. The grid itself is exponentially large in the number of bits, which is exactly the setting of @sec-sperner-query-lower-bound.

#heading(level: 3, numbering: none)[Summary]

#table(
  columns: 2,
  align: (left, left),
  table.header([Quantity], [Result]),
  [Regrets], [$r_(1, 1) = (1 - p) D$, $r_(1, 2) = -p D$, where $D(q) = u_1(1, q) - u_1(2, q)$],
  [Slope of $D$ in $q$], [at most $2$],
  [Slopes of $phi_(1, 1)$], [at most $1$ in $p$, at most $1$ in $D$],
  [Lipschitz constant], [$L = 1 + 2 = 3$ in $ell_oo$],
  [@thm-sperner-approximation], [$norm(f(vz_Y) - vz_Y)_oo <= (L + 1) delta = 4 delta$],
  [Grid size], [$N = ceil(4 \/ epsilon.alt)$; for an $epsilon.alt$-Nash equilibrium, $N = ceil(8 \/ epsilon.alt^2)$],
  [Circuit], [$(i, j) |-> (p, q) |-> f(p, q) |->$ direction of $f(vz) - vz |->$ color],
)

*General $m times n$ games.* The same method applies. Each regret is linear in the opponent's strategy with bounded slope, and the denominator in #lecture-link("nfgs_nash", <def-nash-improvement>)[] is at least $1$. The Lipschitz constant grows with $m$ and $n$. The domain becomes $Delta_m times Delta_n$, of dimension $m + n - 2$, and the $d$-dimensional Sperner lemma of @sec-brouwer-general replaces the planar one.

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

= Finding a Sperner triangle needs exponentially many queries <sec-sperner-query-lower-bound>

== Setting <sec-sperner-query-setting>

- *Grid.* The points are $(i, j)$ with $0 <= i, j <= N$, where $N = 2^m - 1$, so each coordinate is an $m$-bit number. Each unit square is cut into two triangles by its diagonal from $(i, j)$ to $(i+1, j+1)$.
- *Circuit.* The Sperner circuit takes a point as two $m$-bit numbers and outputs its color. So each side has $2^m approx N$ points.
- *Standard boundary.* $chi(0, j) = "red"$ for $j >= 1$ (the left side, except the bottom-left corner). $chi(i, 0) = "yellow"$ for $i < N$ (the bottom, except the bottom-right corner). Every other boundary point is blue. The *door* is the red–yellow boundary edge from $(0,0)$ to $(0,1)$.
- *Calls.* A _query_, or _call_, is one use of the Sperner circuit (@fig-sperner-query-setting). An algorithm learns colors only by calls: it names a point and receives its color. It may choose each call based on earlier answers, and it must output a trichromatic triangle. We count calls. The algorithm is deterministic.

#figure(
  caption: [The setting for $m = 3$, so $N = 7$ and each coordinate is a 3-bit number. Each unit square is cut by its diagonal from $(i, j)$ to $(i+1, j+1)$. The boundary has the standard coloring, and the door is the red–yellow edge from $(0, 0)$ to $(0, 1)$. Interior points (hollow) are unknown until they are queried: here one call sends the point $(101, 011)$ to the Sperner circuit, which answers with its color.],
)[
  #image("figures/brouwer/sperner_setting.svg", width: 78%, alt: "An 8 by 8 grid of points labeled with 3-bit coordinates, triangulated by diagonals from bottom left to top right. The left side is red except the bottom-left corner, the bottom is yellow except the bottom-right corner, the rest of the boundary is blue, and the door edge at the bottom left is highlighted. Interior points are hollow, except one queried point whose coordinates are sent to a box labeled Sperner circuit, which answers blue.")
] <fig-sperner-query-setting>

#theorem[
  Fix a band width $w$ ($w = 12$ works). Let $K = floor((N-4) \/ w) approx N \/ w$.

  For every deterministic algorithm there is a standard coloring on which the algorithm makes at least $(K-2) \/ 4 approx N \/ (4 w)$ calls before it outputs a trichromatic triangle.

  Since $N approx 2^m$, this is about $2^m \/ (4 w)$ calls, which is exponential in $m$.
] <thm-sperner-query-lower-bound>

Where $N - 4$ comes from: the bands (defined below) leave a margin 2 points wide on each side of the grid, so they start at coordinate $2$ and must end by coordinate $N - 2$. That leaves a stretch of length $(N - 2) - 2 = N - 4$, and $K = floor((N-4) \/ w)$ bands of width $w$ fit in it. For example, the game's small grid has $53 times 53$ points, so $N = 52$; its bands run from $2$ to $50$, a length of $48$, and $K = 48 \/ 12 = 4$. For large $N$ the $4$ does not matter, which is why $K approx N \/ w$.

== Definitions

- *Band.* Leave a margin 2 points wide around the edge. Cut the rest into $K$ horizontal strips $w$ points tall and $K$ vertical strips $w$ points wide. Any leftover strip at the top or right is blue margin. A *block* $(x, y)$ is where vertical band $x$ meets horizontal band $y$.
- *Diagonal square $k$.* This is block $(k, k)$. There are exactly $K approx N \/ w$ diagonal squares, one per band. That is one side's worth, not $K^2$. Square 0 is next to the door.
- *Tunnel.* A tunnel has a red wall with a yellow wall right beside it, and every other point is blue. It enters from the door, visits diagonal squares $0 -> a_1 -> dots.c -> a_k$, and stops. The last square $a_k$ is the *dead end*.
- *Hop.* A hop is the piece of tunnel from one diagonal square $a$ to the next one, $b$. It has two legs:
  - a sideways leg along horizontal band $a$ to vertical band $b$;
  - then an up-or-down leg along vertical band $b$ into square $b$.
- *Passes through.* A leg occupies the blocks it runs through. A hop passes through a point if the point lies in one of those blocks.
- *Involved.* A call at a point in block $(x, y)$ involves up to four squares: $x$, $y$, the square after $y$ on the tunnel, and the square before $x$ on the tunnel.

#figure(
  caption: [An adversary coloring with $K = 4$. The diagonal squares are outlined and the bands are dashed. The tunnel is built as $0 -> 2 -> 1 -> 3$. The hop $1 -> 3$ crosses the hop $0 -> 2$ in block $(2, 1)$, and the rewiring there splits off an island (the loop through squares 1 and 2). The walk from the door then goes straight through the rewired crossing to the dead end, square 3. The circled black triangle is the only trichromatic triangle. Labels mark the vertical bands $x$ and horizontal bands $y$, the block $(2, 1)$, the two legs of the hop $0 -> 2$, and the island.],
)[
  #image("figures/brouwer/sperner_bands.svg", width: 85%, alt: "An adversary coloring with four diagonal squares: a red wall with a yellow wall beside it runs from the door at the bottom-left corner to a circled trichromatic triangle in square 3, and a separate loop passes through squares 1 and 2.")
] <fig-sperner-bands>

== Step 1: The colorings the adversary uses

Every coloring the adversary ever commits to is a tunnel coloring as above.

- *Crossings.* A sideways leg and an up-or-down leg can meet in one block. There the walls are rewired inside the block so the two tunnels don't touch: the incoming sideways leg connects to the outgoing up-or-down leg and the other way round, and both keep their direction. This can split off a closed loop (an _island_). A loop has no ends, so it holds no trichromatic triangle. The walk from the door still ends at the dead end.
- *Drawing lemma.* Every tunnel coloring is a legal standard Sperner coloring. Its only trichromatic triangle lies in the dead end's square.
  - Along a wall, red and yellow sit side by side, and the blue on each side of the wall touches only one of the two. So a triangle can see all three colors only where a wall stops, which is the dead end.
  - Checking straight pieces, turns, crossings and the dead end is a finite check over local pictures.
  - It was also verified by computer on 3,000 random tunnels with crossings. Each had exactly one trichromatic triangle, in the dead end's square.

== Step 2: One call involves at most 4 diagonal squares

Take a point in block $(x, y)$.

- Horizontal band $y$ carries at most one sideways leg: the one belonging to the hop leaving square $y$. This is because each square is left at most once.
- Vertical band $x$ carries at most one up-or-down leg: the one belonging to the hop entering square $x$. This is because each square is entered at most once.

So at most two hops pass through the point, and they determine its color. Each hop is named by its two end squares. So the color depends only on $x$, $y$, the square after $y$, and the square before $x$: at most 4 diagonal squares.

A crossing block is just the case where both hops pass through. The rewiring changes how the walls connect inside the block, not which hops are there.

== Step 3: The adversary

The adversary keeps the tunnel $0 -> a_1 -> dots.c -> a_k$ built so far and a set $T$ of touched squares. At the start, $T = {0}$.

On a call at a point in block $(x, y)$:

+ If $y = a_k$ (the dead end's horizontal band) and some square is untouched, pick an untouched square $b$ and extend the tunnel $a_k -> b$.
+ Add every square the call involves to $T$. Any of them that is not on the tunnel is thereby declared never visited: the tunnel will never enter or leave it.
+ Answer the point's color in the current tunnel coloring.

*Consistency.* Every answer stays true in every later coloring. A later extension $a_k -> b$ adds one hop, and that hop only runs through horizontal band $a_k$ and vertical band $b$.

- _Vertical band $b$ has no calls._ Every call touches its own $x$ and $y$, and $b$ was untouched. So no call was ever in band $b$.
- _Horizontal band $a_k$ has no calls._ A call there while $a_k$ was the dead end would have triggered rule 1. Before $a_k$ became the dead end it was untouched, so there were no calls there either.

So the new hop, including any rewired crossing on it, only changes blocks nobody has called. Squares declared never visited are touched, so they are never chosen as $b$. Hops already drawn never change.

== Step 4: Counting, for every algorithm

At the start, one of the $K$ squares (square 0) is touched. Each call touches at most 4 new squares (Step 2). The square added in rule 1 is one of those four: it is the square after $y$.

Suppose the algorithm stops after $c$ calls and names a triangle $t$, while at least 2 squares are still untouched.

- The adversary picks an untouched square $b$ whose block does not contain $t$, and extends the tunnel $a_k -> b$.
- By consistency, every answer is still true.
- The only trichromatic triangle is now in square $b$, so $t$ is wrong.

This final coloring is a fixed standard coloring. The algorithm is deterministic and gets exactly the same answers on it, so it really does fail on that coloring.

So a correct algorithm can only stop once at most 1 square is untouched. That means
$ K - 1 - 4 c <= 1, quad "so" quad c >= (K-2) / 4 approx N / (4 w). $

== Step 5: Exponential, and the right size

The bound is $(K-2) \/ 4 approx N \/ (4 w) approx 2^m \/ (4 w)$. With $w = 12$ that is about $2^m \/ 48$. Every extra bit per coordinate doubles it.

The grid has about $N^2 = 2^(2 m)$ points, but the bound is about $N$, not $N^2$. That is the truth, not a weakness.

- Divide and conquer finds a trichromatic triangle in about $3 N$ calls. It repeatedly keeps a sub-square whose boundary has a nonzero count of red→yellow minus yellow→red edges.
- So the query complexity is $Theta(N) = Theta(2^m)$, and this bound is tight up to the constant.

== Recap

+ Each coordinate is $m$ bits, so each side has about $N = 2^m$ points.
+ Cutting the grid into bands $w$ wide gives $K approx N \/ w$ diagonal squares. With the 2-point margin it is exactly $floor((N-4) \/ w)$. That is one side's worth, not $(N \/ w)^2$.
+ The adversary hides the dead end, and with it the only trichromatic triangle, among those $K$ squares.
+ Each call involves at most 4 of them, so any algorithm needs at least $(K-2) \/ 4 approx N \/ (4 w)$ calls.
+ That is about $2^m \/ 48$: exponential in $m$, and within a constant factor of the roughly $3 N$ calls divide and conquer uses.

== Numbers ($w = 12$)

#table(
  columns: 4,
  align: (left, right, right, right),
  table.header([], [$N$], [diagonal squares $K$], [lower bound $ceil((K-2) \/ 4)$]),
  [Game, medium grid (77 × 77 points)], [76], [6], [1 (trivial)],
  [$m = 20$], [1,048,575], [87,380], [21,845],
  [$m = 40$], [≈ 1.1 trillion], [91,625,968,980], [22,906,492,245],
)

On a screen-sized grid the bound says almost nothing. It only grows large because it doubles with every bit.

== Choices vs. what matters

*Choices:* the band width $w$, placing squares on the diagonal, "sideways first, then up or down", and which untouched square to jump to. We only need one adversary that works.

*What matters:*
- The coloring is a legal standard Sperner coloring.
- Its only trichromatic triangle is at the dead end.
- Each diagonal square has a private row band and a private column band, so each call involves at most 4 squares.

The diagonal is simply the easiest way to give every square its own row and column. Putting square $k$ at row $k$ and column $pi(k)$, for any permutation $pi$, would work the same way.

== References

- M. Hirsch, C. Papadimitriou, S. Vavasis. Exponential lower bounds for finding Brouwer fixed points #citep(<hirsch1989exponential>).
- C. Papadimitriou. On the complexity of the parity argument and other inefficient proofs of existence #citep(<papadimitriou1994parity>).
- X. Chen, X. Deng. On the complexity of 2D discrete fixed point problem #citep(<chen2009discrete>).

== Interactive game <sec-sperner-adversary-game>

The interactive version below: its proof mode runs exactly the adversary described above.

#interactive-demo("sperner-adversary", title: "Find the rainbow triangle", height: 720)

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - Sep 24, 2025: fixed two typos (thanks Eric Yang Yu!)
]
