#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Lecture 11, Task 10(a)-(d). Prepared by Andrew Wen.

= A second Lagrangian: thresholding and binary search <sec-l11-binary-search>

In Solution #1 from the lecture, the direct Lagrangian puts a penalty on deviations. Its difficulty is choosing
a large enough penalty without making the rewards too large. We can avoid this
choice by fixing a target payoff first. Instead of asking for the largest
mediator payoff, we ask whether an equilibrium can achieve at least $tau$.
Then, we use binary search to find the largest achievable target.

We follow Solution #2 on slides 38--41 #citep(<Zhang2026MechanismDesignSlides>)
and use the notation from the preceding Lagrangian section.
Let $vmu in cX_M$ be the mediator's strategy and $vx^*$ the fixed profile of
direct strategies. Write
$
  f(vmu) := u_M (vmu, vx^*), quad
  V_i (vmu) := max_(vx_i in cX_i)
  [u_i (vmu, vx_i, vx^*_(-i)) - u_i (vmu, vx^*)],
$
and $V(vmu) := max_i V_i (vmu)$. Note $V_i (vmu) >= 0$, since the player can
always choose $vx_i = vx_i^*$. Thus, $V(vmu) = 0$ means no player gains by
deviating, and $V(vmu) <= epsilon$ means each player's gain is at most
$epsilon$. Let
$ v^* := max_(vmu in cX_M: V(vmu) = 0) f(vmu) $
be the best mediator payoff at an exact direct communication equilibrium.

Throughout this section, assume a finite communication game with terminal
utilities in $[0, 1]$ for the mediator and every player. Positive affine
rescaling preserves exact best responses; our additive error guarantees are
measured in these normalized units. In particular, $v^* in [0, 1]$.

== Turning a target payoff into a zero-sum game <sec-l11-threshold-game>

Fix $tau in [0, 1]$. We want both
$ f(vmu) >= tau quad "and" quad V(vmu) = 0. $
#block(breakable: false)[
There are two ways for a strategy to fail: its payoff can be below the target,
or some player can gain by deviating. Let the minimizing player choose which
condition to test. The resulting payoff guarantee for the mediator is
#set math.equation(numbering: "(1)")
$
  h_tau (vmu) := min{f(vmu) - tau, -V(vmu)}, quad
  g(tau) := max_(vmu in cX_M) h_tau (vmu).
$ <eq-l11-threshold-value>
#set math.equation(numbering: none)
]
The first term checks the target payoff. The second checks incentives.
The mediator tries to make the smaller of the two as large as possible.

To write the alternative Lagrangian explicitly, let $lambda_0, ..., lambda_n$
be nonnegative weights summing to $1$. The weight $lambda_0$ selects the
payoff test; each $lambda_i$ selects a deviation test for player $i$. We get
$
  g(tau) = max_(vmu in cX_M)
  min_(lambda in Delta({0, ..., n}), vx_i in cX_i)
  L_tau (vmu, lambda, vx),
$
where
#set math.equation(numbering: "(1)")
$
  L_tau (vmu, lambda, vx)
  := lambda_0(f(vmu) - tau)
  - sum_(i=1)^n lambda_i
  [u_i (vmu, vx_i, vx^*_(-i)) - u_i (vmu, vx^*)].
$ <eq-l11-alternative-lagrangian>
#set math.equation(numbering: none)
For fixed $vmu$, the minimizer can put all its weight on the worst test.
On a deviation test, it chooses a best deviation for that player. This gives
exactly the minimum in (@eq-l11-threshold-value). Unlike the direct penalty
parameter, the weights here form a probability distribution.

#claim[The threshold test][
  $g(tau) <= 0$ for every $tau$. Moreover,
  $ g(tau) = 0 <=> tau <= v^*. $
] <cl-l11-threshold-test>

#proof[
  Since $V(vmu) >= 0$, we have $h_tau (vmu) <= 0$ for every $vmu$.
  If $tau <= v^*$, an optimal exact equilibrium has $V(vmu) = 0$ and
  $f(vmu) - tau >= 0$, so it achieves $h_tau (vmu) = 0$.

  Conversely, the strategy polytope is compact and $h_tau$ is continuous, so
  its maximum is attained. If $g(tau) = 0$, a maximizing strategy satisfies
  $f(vmu) >= tau$ and $V(vmu) <= 0$. It is therefore an exact equilibrium
  with payoff at least $tau$, giving $tau <= v^*$.
]

=== The extensive-form construction <sec-l11-threshold-tree>

We can realize these tests as an extensive-form zero-sum game
#citep(<ZhangEtAl2023OptimalLearning>, [Proposition 3.6]). The two players are
the mediator, who maximizes, and a deviator, who minimizes. The deviator first
chooses a test index $i in {0, 1, ..., n}$.

- If $i = 0$, play the communication game with all players direct. At a
  terminal node $z$, give the mediator payoff $u_M (z) - tau$.
- If $i >= 1$, flip a fair coin. In the direct branch, all players are direct
  and the mediator receives $2u_i (z)$. In the deviation branch, the deviator
  controls player $i$, the others stay direct, and the mediator receives
  $-2u_i (z)$.

The deviator always receives the negative of the mediator's payoff. The
test index and coin outcome are hidden from the mediator. Corresponding
mediator decisions with the same original observations must remain in the
same information set, so the mediator uses one strategy across all tests.
The deviator receives only the observations available to the player it
controls. Other information sets are inherited from the communication game.

#figure(
  image("figures/information_design_binary_search/threshold_game.svg", width: 100%,
    alt: "The deviator chooses a target-payoff test or a player-deviation test. The latter uses a fair coin to compare direct play with a deviation, while the mediator's corresponding information sets remain joined."),
  caption: [The threshold game, with the original communication game compressed
    into each triangle. The dashed line indicates corresponding mediator
    decisions with the same original observations. Payoffs shown are for the
    mediator; the deviator receives their negatives.],
) <fig-l11-threshold-game>

Fix a mediator strategy $vmu$ and a deviation strategy $vx_i$. On test $i$,
the expected payoff is
$
  1/2 dot 2u_i (vmu, vx^*)
  + 1/2 dot (-2u_i (vmu, vx_i, vx^*_(-i)))
  = -[u_i (vmu, vx_i, vx^*_(-i)) - u_i (vmu, vx^*)].
$
The factors of $2$ cancel the coin's probability $1/2$. Mixing over tests
with probabilities $lambda_i$ now gives (@eq-l11-alternative-lagrangian).
Also, the target-test rewards lie in $[-1, 1]$ and the deviation-test rewards
lie in $[-2, 2]$. Hence the entire game has rewards in $[-2, 2]$, independently
of a large penalty parameter or the desired precision.

== Binary search with approximate solves <sec-l11-binary-search-algorithm>

An exact solve would tell us whether $g(tau) = 0$ or $g(tau) < 0$. In practice,
we solve only to a tolerance $0 < epsilon < 1$. The useful approximate test is:

- *Accept:* find a mediator strategy $hat(vmu)$ satisfying
  $h_tau (hat(vmu)) >= -epsilon$. Then
  $ f(hat(vmu)) >= tau - epsilon quad "and" quad V(hat(vmu)) <= epsilon. $
- *Reject:* certify $g(tau) < 0$. By @cl-l11-threshold-test, this implies
  $tau > v^*$.

Acceptance allows a small error in both conditions. Rejection must rule out
_every_ mediator strategy; finding one unsuccessful strategy is not enough.

The slides say to continue until we find an accepted strategy or prove the
value is negative. To see how this works, a zero-sum solver can maintain a mediator strategy with a lower
bound $L$ on its worst-case payoff, and a deviator strategy with an upper bound
$U$ on the game value. Thus $L <= g(tau) <= U$. Solve until
$U - L <= epsilon/2$. If $L >= -epsilon$, accept. Otherwise,
$U <= L + epsilon/2 < 0$, so reject. This explains why an approximate solver
suffices, even though we cannot reliably test whether a numerical estimate is
exactly zero. The bounds can be computed using best responses, as in the earlier
#lecture-link("learning_intro", <sec-learning-zero-sum>)[zero-sum self-play setup].

#pseudocode-list(
  numbered-title: [Binary search for an optimal communication equilibrium],
  line-gap: .45em,
)[
  - *Input:* a normalized communication game and $0 < epsilon < 1$.
  + $a <- 0$; $b <- 1$.
  + Run the threshold test at $tau = 0$; save its accepted strategy as $hat(vmu)$.
  + *while* $b - a > epsilon$:
    + $tau <- (a + b)/2$.
    + Run the approximate threshold test at $tau$.
    + *if* it accepts a strategy $vmu$:
      + $a <- tau$; $hat(vmu) <- vmu$.
    + *else*:
      + $b <- tau$.
  + *return* $hat(vmu)$.
] <algo-l11-binary-search>

The initialization at $tau = 0$ always accepts, since an exact communication
equilibrium exists and its mediator payoff is nonnegative. This also gives
us a strategy to return if every later test rejects, including when $v^* = 0$.
The variable $a$ records an approximately achievable target; it need not be
a lower bound on the best _exact_ equilibrium payoff.

== Approximation guarantee <sec-l11-binary-search-guarantee>

#theorem[Binary-search guarantee][
  The strategy returned by @algo-l11-binary-search satisfies
  $ V(hat(vmu)) <= epsilon quad "and" quad
    f(hat(vmu)) >= v^* - 2epsilon. $
  There are at most $ceil(log_2 (1/epsilon))$ midpoint tests, in addition
  to the initialization. If each threshold test costs $T(epsilon)$, the
  total cost is $O(T(epsilon) (1 + log(1/epsilon)))$.
] <thm-l11-binary-search>

This is Theorem 3.7 of Zhang et al.~#citep(<ZhangEtAl2023OptimalLearning>),
with an explicit initialization for the saved strategy.

#proof[
  Initially, $b = 1 >= v^*$. A rejection sets $b$ to a target $tau > v^*$,
  so $b >= v^*$ throughout.

  Each accepted strategy satisfies $V(hat(vmu)) <= epsilon$ and
  $f(hat(vmu)) >= a - epsilon$, including the initialization at $a = 0$.
  A rejection leaves $a$ and the saved strategy unchanged.

  Each midpoint test halves the interval. At termination, $b - a <= epsilon$,
  so $a >= b - epsilon >= v^* - epsilon$. Hence
  $f(hat(vmu)) >= a - epsilon >= v^* - 2epsilon$.
  The two errors come from the interval width and the accepted test.
  The number of halvings gives the cost.
]

== Comparing the two methods <sec-l11-lagrangian-comparison>

Both methods let us use a zero-sum game solver to find an optimal
communication equilibrium. The difference is how they handle incentives.

- *Direct Lagrangian.* Solve one game with payoff $f(vmu) - lambda V(vmu)$.
  This avoids an outer search and supports the last-iterate guarantees
  discussed in the preceding section. However, its terminal rewards grow
  with $lambda$. Solving to a fixed relative precision can therefore leave
  a large additive error when $lambda$ is large.
- *Threshold Lagrangian.* Solve a sequence of games, each with a different
  target $tau$. The terminal rewards stay in $[-2, 2]$, and an
  $epsilon$-accurate threshold test suffices at every step. The cost is an
  extra logarithmic number of solves. The outer procedure returns a saved
  strategy from one of these games, rather than following a single
  last-iterate learning trajectory.

For average strategies, the lecture gives $O(1/epsilon^2)$ iterations for
the direct method with optimistic multiplicative weights (OMWU), compared
with $tilde(O)(1/epsilon)$ total iterations for the binary-search method.
Here game-dependent factors are suppressed, and $tilde(O)$ also suppresses
logarithmic factors. These rates assume the corresponding optimistic
solvers; see Zhang et al.~#citep(<ZhangEtAl2023OptimalLearning>),
Corollary 3.4 and Section 3.2.

Thus, solving one direct-penalty game can be convenient when the solver
handles its reward scale accurately. The bounded rewards of the threshold
method can be useful with approximate solvers, including deep reinforcement
learning. To apply the theorem above, the solver must provide the threshold
certificates described earlier.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
