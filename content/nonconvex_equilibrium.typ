#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions
#show: gabri_notes.with(
  instructor: [Weiqiang Zheng],
  lec_num: "17",
  date: [November 12, 2026],
  title: "Nonconvex games",
)

// Integration: these are two contributions, not the complete L17 lecture.
// Place the first after the squared-distance game on slide PDF page 2 and before
// Phi-equilibrium; place the local-deviations section with pages 4--5. Keep the
// labels when integrating other sections.

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

= Local deviations and what gradients can certify <sec-nonconvex-local>

The previous example shows why a pure equilibrium may fail to exist. We now
ask a more limited question: how much could a player gain from changing their
action by at most a small distance $delta$? This section expands the local
deviation and linearization discussion on pages 4--5 of the
#link("https://www.mit.edu/~6.7980/slides/L17_nonconvex_games.pdf#page=4")[lecture slides].

== What counts as a local deviation? <sec-nonconvex-local-maps>

Write the players' joint action as $x=(x_i,x_(-i))$, where $x_(-i)$ lists the
other players' actions. Player $i$'s feasible set is $X_i$. A deviation rule
$phi_i: X_i -> X_i$ replaces their action $x_i$ with $phi_(i)(x_i)$, leaving the
other players' actions fixed. It is *$delta$-local* if
$ norm(phi_(i)(z)-z)_2 <= delta quad "for every" z in X_i. $
The rule must respect both the distance limit and the feasible set everywhere.
Let $Phi_(i)(delta)$ be a chosen family of such measurable rules, including the
identity rule $phi_(i)(z)=z$.

For example, on $[0,1]$, the rule $phi(z)=min{z+0.1,1}$ moves right by at most
$0.1$. It sends $0.50$ to $0.60$ and $0.95$ to $1.00$. Clipping the move at the
boundary keeps the action feasible.

An $epsilon$-approximate $Phi(delta)$-equilibrium is a joint distribution of
actions for which no player gains more than $epsilon$ in expectation by
applying any rule from their family. The distribution may correlate players'
actions. Each rule uses only that player's own action.

== A gradient estimate with an error allowance <sec-nonconvex-linearization>

Assume each $X_i$ is nonempty, convex, and compact. Utilities are differentiable,
and changing player $i$'s action changes their gradient by at most $L$ times the
distance moved, uniformly over fixed opponents' actions:
$
  norm(nabla_(x_i) u_(i)(z,x_(-i))-nabla_(x_i) u_(i)(w,x_(-i)))_2
  <= L norm(z-w)_2.
$
This is *smoothness*. It limits how quickly the slope can change; it does not
require the utility to be concave.

Set $d_i=phi_(i)(x_i)-x_i$ and $g_(i)(x)=nabla_(x_i)u_(i)(x)$. The dot product
$ip(g_(i)(x),d_i)$ estimates the payoff change using the current slope. Smoothness
gives the following upper bound:
$
  u_(i)(phi_(i)(x_i),x_(-i))-u_(i)(x)
  &<= ip(g_(i)(x),d_i) + L/2 norm(d_i)_2^2 \
  &<= ip(g_(i)(x),d_i) + L delta^2/2.
$
In words: *actual gain is at most the gradient's estimate plus a curvature
allowance*. If the expected gradient estimate is at most $epsilon$ for every
allowed rule, expected actual gain is at most $epsilon+L delta^2/2$.

This is the reduction in Lemma 1 of
#link("https://arxiv.org/html/2403.08171v4")[Cai, Daskalakis, Luo, Wei, and Zheng].
See Appendix C there for the proof. The allowance scales quadratically: halving
the permitted move divides it by four.

== From repeated play to an equilibrium guarantee <sec-nonconvex-local-regret>

Suppose the players produce joint actions $x^((1)),...,x^((T))$. For each player,
define the largest cumulative gain predicted by the gradients:
$
  R_i^((T)) := sup_(phi_i in Phi_(i)(delta))
  sum_(t=1)^T ip(g_(i)(x^((t))),phi_(i)(x_i^((t)))-x_i^((t))).
$
The *same deviation rule* is used across all rounds in this comparison. It can
respond to the player's action, but we do not select a separate rule for each
round after seeing the other players' actions.

Choose a round uniformly from $1,...,T$ and return the entire joint action from
that round. This defines the empirical distribution of play. Applying the bound
above round by round gives its approximation guarantee:
$ epsilon_T = max_i R_i^((T))/T + L delta^2/2. $
This is the repeated-play statement of Lemma 1. It concerns a distribution over
joint actions, rather than the average action or the last action. For a fixed
$delta$, reducing the regret term alone leaves the curvature allowance in this
bound. The bound also presumes control of regret for the *chosen family* of
rules; it does not itself provide an efficient algorithm for every family.

== Worked example: zero slope, positive gain <sec-nonconvex-stationary-example>

Return to $u_(1)(x,y)=(x-y)^2$ and $u_(2)(x,y)=-(x-y)^2$. At
$(x,y)=(1/2,1/2)$, both own-action derivatives are zero:
$ partial_x u_(1)=2(x-y)=0, quad partial_y u_(2)=2(x-y)=0. $
Nevertheless, if player 1 moves from $1/2$ to $1/2+s$, their gain is $s^2$.
For $0<delta<=1/2$, the largest gain among moves with $abs(s)<=delta$ is exactly
$delta^2$. Player 2 is already best responding and has no positive gain.

Both utilities have own-action smoothness constant $L=2$. Therefore the
curvature allowance is $L delta^2/2=delta^2$: the bound is attained exactly by
player 1. For instance, at $delta=0.2$, moving to $x=0.7$ gains $0.04$, although
the gradient estimate is zero. The globally feasible rule
$phi(z)=min{z+delta,1}$ realizes this deviation at the midpoint.

#figure(
  image("figures/nonconvex_local/stationary_gain.svg", width: 52%),
  caption: [Player 1's utility with $y=1/2$ fixed. The tangent at $x=1/2$ is
    flat, but the actual utility rises in either direction. The shaded interval
    permits moves of at most $delta=0.2$; its endpoints give gain $0.04$.],
) <fig-nonconvex-stationary-gain>

Thus a zero gradient need not mean that every nearby change is unprofitable.
Here it identifies the bottom of player 1's utility curve. The example also
shows why a general guarantee based on first-order information retains a
quadratic error allowance.

== Exercise: budget the approximation error <sec-nonconvex-error-budget>

#exercise[Choose the deviation radius][
  Suppose $L=2$ and every player's average linearized regret is at most $0.02$.
  + What equilibrium error does the bound certify when $delta=0.1$?
  + What does it certify when $delta=0.2$?
  + What is the largest radius this bound permits if the target error is $0.03$?
] <ex-nonconvex-error-budget>

#reference-solutions(title: [Show / hide the error-budget solution])[
#solution[Separate learning error from curvature][
  The bound is $epsilon_T<=0.02+delta^2$. Hence the first two certified errors
  are $0.03$ and $0.06$. For the target $0.03$, solve
  $ 0.02+delta^2<=0.03, quad "so" quad delta<=0.1. $
  These are upper bounds, not predictions of the actual deviation gain. A
  smaller radius gives a tighter bound while restricting which deviations are
  being tested. A larger radius tests more substantial changes.
] <sol-nonconvex-error-budget>
]

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
- *Local deviations and linearization:* Yang Cai, Constantinos Daskalakis,
  Haipeng Luo, Chen-Yu Wei, and Weiqiang Zheng,
  #link("https://arxiv.org/html/2403.08171v4")[On Tractable Phi-Equilibria in Non-Concave Games],
  arXiv:2403.08171v4 (April 20, 2025; preliminary version NeurIPS 2024),
  Section 4, Assumption 1, Definition 3, and Lemma 1; proof in Appendix C.
  The clipped-shift illustration, stationary-point calculation, figure, and
  numerical error-budget exercise are worked expansions provided here.

_AI assistance:_ ChatGPT assisted with drafting and revising the explanations,
working through the example, creating the figures, and implementation checks.
