#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions
#show: gabri_notes.with(
  instructor: [Weiqiang Zheng],
  lec_num: "17",
  date: [November 12, 2026],
  title: "Nonconvex games",
)

// Integration: this is the worked-example contribution, not the complete L17
// lecture. Place it after the squared-distance game on slide PDF page 2 and
// before Phi-equilibrium. Keep these labels when integrating other sections.

= A smooth game with no pure equilibrium <sec-nonconvex-distance-game>

This worked example expands the game on page 2 of the
#link("https://www.mit.edu/~6.7980/slides/L17_nonconvex_games.pdf#page=2")[Lecture 17 slides].
Player 1 chooses a number $x in [0,1]$ and player 2 chooses a number $y in [0,1]$.
Their utilities are
$ u_(1)(x,y) = (x-y)^2, quad u_(2)(x,y) = -(x-y)^2. $
Both players maximize their own utility: player 1 wants the numbers to be far
apart, while player 2 wants them to match.

A *pure strategy* means choosing one number with certainty. A *pure Nash
equilibrium* is a pair of numbers at which neither player can improve by changing
their own number while the other player's number stays fixed.

Both action sets are compact and convex, and both utilities are smooth. However,
player 1's utility is convex, rather than concave, in their own action. The
concave-game existence theorem therefore does not apply. For the general
existence result and its proof, see Theorem 1 of
#link("https://ntrs.nasa.gov/api/citations/19650010164/downloads/19650010164.pdf")[Rosen (1965)].
We can check the failure of pure equilibrium in this particular game directly.

#remark[Utility normalization][
  Player 2's utility lies in $[-1,0]$. If utilities must lie in $[0,1]$, replace it
  by $1-(x-y)^2$. This adds the same constant to every payoff and leaves best
  responses and equilibria unchanged. We retain the zero-sum version above to
  match the lecture example.
] <rem-nonconvex-normalization>

== What each player wants to do <sec-nonconvex-best-responses>

A *best response* is an action that gives the highest payoff against the other
player's fixed action. Player 2 can make the squared distance zero by choosing
$y=x$, so their unique best response is
$ op("BR")_(2)(x) = {x}. $

Player 1 wants the endpoint farthest from $y$. Comparing the endpoint payoffs,
$ u_(1)(1,y)-u_(1)(0,y) = (1-y)^2-y^2 = 1-2y. $
Thus
$
  op("BR")_(1)(y) = cases(
    {1} & "if" y < 1/2,
    {0,1} & "if" y = 1/2,
    {0} & "if" y > 1/2.
  )
$
At $y=1/2$, the two endpoints are equally good. Interior actions are worse, so
the best-response set is the two points ${0,1}$, not the whole interval.

#figure(
  image("figures/nonconvex_equilibrium/best_responses.svg", width: 65%),
  caption: [Pure best responses. The blue segments show player 1's best responses;
    the orange diagonal shows player 2's. An intersection would be a pure Nash
    equilibrium. There is no intersection. At $y=1/2$, only the two blue endpoints
    are best responses.],
) <fig-nonconvex-best-responses>

== Why there is no pure equilibrium <sec-nonconvex-no-pure>

At any pure equilibrium, player 2 must be choosing $y=x$. But then player 1
receives zero and can improve by moving to an endpoint:
$ max {x^2,(1-x)^2} >= 1/4 > 0. $
To see the bound, at least one endpoint is at distance at least $1/2$ from $x$.
Therefore player 1 always has a profitable deviation, and no pure equilibrium
exists. Smoothness and a convex action set are not enough to guarantee one.

== Exercise: allow player 1 to randomize <sec-nonconvex-mixed-exercise>

#exercise[Find a mixed equilibrium][
  Suppose player 1 chooses $X=1$ with probability $q$ and $X=0$ with probability
  $1-q$. A mixed strategy specifies these probabilities before play; the other
  player knows the distribution but does not observe the realized draw before
  choosing their action.

  + Find player 2's best response to this distribution.
  + Find a value $q in (0,1)$ at which player 1 is willing to use both endpoints.
  + Verify both players' best-response conditions and calculate their expected
    utilities.

  _Hint._ Player 2 minimizes $(1-q)y^2+q(1-y)^2$. For player 1 to use both
  endpoints with positive probability, they must give the same payoff.
] <ex-nonconvex-mixed>

#reference-solutions(title: [Show / hide the worked solution])[
#solution[An equal mixture of endpoints][
  *Player 2's decision.* Expected squared distance is
  $
    EE[(X-y)^2] &= (1-q)y^2+q(1-y)^2 \
                &= y^2-2 q y+q \
                &= (y-q)^2+q(1-q).
  $
  Only the first term depends on $y$, and it is minimized at $y=q$.

  *Player 1's decision.* If player 1 uses both endpoints, both must be best
  responses. They give equal utility precisely when
  $ y^2=(1-y)^2, quad "that is," quad y=1/2. $
  Combining $y=q$ with $y=1/2$ gives
  $ PP(X=0)=PP(X=1)=1/2, quad Y=1/2. $

  *Check all possible deviations.* Against $Y=1/2$, every $x in [0,1]$ gives
  $(x-1/2)^2 <= 1/4$, and both endpoints attain $1/4$. No different pure action
  or mixture can do better. Against the equal mixture of endpoints,
  $ EE[(X-y)^2]=(y-1/2)^2+1/4. $
  Player 2 uniquely minimizes this expression at $y=1/2$. Randomizing over
  alternative values of $y$ cannot improve on its minimum either. These two
  observations verify a mixed Nash equilibrium. The expected utilities are
  $ EE[u_(1)(X,Y)]=1/4, quad EE[u_(2)(X,Y)]=-1/4. $
] <sol-nonconvex-mixed>
]

== Why randomizing differs from choosing the mean <sec-nonconvex-mean>

The equal mixture has mean $EE[X]=1/2$, but choosing $x=1/2$ with certainty
does not produce the same payoff. Expanding the square and using
$EE[X-EE[X]]=0$ gives
$ EE[(X-y)^2] = (EE[X]-y)^2 + op("Var")(X). $
For the equal mixture, $op("Var")(X)=1/4$. Against $y=1/2$, player 1 therefore
earns $1/4$ by randomizing, but earns zero by choosing the mean with certainty.

#figure(
  image("figures/nonconvex_equilibrium/randomization.svg", width: 52%),
  caption: [Expected squared distance under equal randomization between 0 and 1
    (blue), compared with choosing their mean $1/2$ with certainty (dashed gray).
    The vertical gap is the variance $1/4$. Player 2 minimizes the blue curve at
    $y=1/2$.],
) <fig-nonconvex-randomization>

= Sources and contribution notes <sec-nonconvex-sources>

- *Lecture example:* Weiqiang Zheng, MIT 6.7980, Lecture 17, November 12, 2026,
  #link("https://www.mit.edu/~6.7980/slides/L17_nonconvex_games.pdf#page=2")[slide PDF, page 2].
  This supplies the squared-distance game and the motivation concerning
  nonconcavity.
- *General existence theorem:* J. B. Rosen (1965),
  #link("https://ntrs.nasa.gov/api/citations/19650010164/downloads/19650010164.pdf")[Existence and Uniqueness of Equilibrium Points for Concave N-Person Games],
  Theorem 1. Its hypotheses concern concave games; it is not a source for the
  new exercise above.
- *Worked expansion:* the best-response calculation, mixed-equilibrium exercise
  and solution, and figures develop the lecture's example. Their elementary
  calculations are supplied in this note.

_AI assistance:_ ChatGPT assisted with drafting and revising the explanations,
working through the example, creating the figures, and implementation checks.
