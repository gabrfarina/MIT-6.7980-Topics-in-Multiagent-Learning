#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Lecture 11, Task 10(a)-(d). Prepared by Andrew Wen.

= A second Lagrangian: thresholding and binary search <sec-l11-binary-search>

In Solution 1 from the lecture, we maximize the mediator's payoff and penalize
profitable deviations. The difficulty is choosing a large enough penalty
without making the game's rewards too large. Solution 2 starts with a
different question: can an equilibrium give the mediator payoff at least
$tau$? If we can answer this for each target $tau$, we can binary search for
the optimal payoff.

We follow Solution 2 on slides 38--41 #citep(<Zhang2026MechanismDesignSlides>)
and keep the notation from Solution 1. Let $Gamma$ be the reduced
communication game with $n$ players. Let $cX_M$ and $cX_i$ be the sequence-form
strategy polytopes of the mediator and player $i$.
The fixed profile $vx^* = (vx_1^*, ..., vx_n^*)$ means
that players report their information truthfully and follow the mediator's
recommendations. We optimize the mediator's strategy $vmu$, holding this
direct behavior fixed.

Write $u_j (vmu, vx)$ for the expected payoff of agent $j$. Define
$
  f(vmu) := u_M (vmu, vx^*), quad
  V_i (vmu) := max_(vx_i in cX_i)
  [u_i (vmu, vx_i, vx^*_(-i)) - u_i (vmu, vx^*)],
$
and $V(vmu) := max_i V_i (vmu)$. Here $f$ is the mediator's payoff under
direct play, $V_i$ is the largest deviation gain for player $i$, and $V$ is the
largest gain available to any player. Note $V_i (vmu) >= 0$, since the player
can always choose $vx_i = vx_i^*$. Thus, $V(vmu) = 0$ means direct play is a
communication equilibrium. More generally, $V(vmu) <= epsilon$ means it is an
$epsilon$-equilibrium: no player gains more than $epsilon$ by deviating.

Let
$ v^* := max_(vmu in cX_M: V(vmu) = 0) f(vmu) $
be the best mediator payoff at an exact direct communication equilibrium.

As in the lecture, assume a finite game with perfect-recall players and
normalize every agent's terminal utilities to
$[0, 1]$. This preserves exact best responses and fixes the units for our
additive errors. An exact direct communication equilibrium exists by the
revelation principle applied to an equilibrium of the original game.
In particular, $v^* in [0, 1]$.

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
Both must be nonnegative to pass the test, so we take their minimum.
The mediator tries to make this worst test result as large as possible.

To write the alternative Lagrangian explicitly, let
$lambda in Delta({0, ..., n})$ be a probability vector over the tests:
$lambda_i >= 0$ and $sum_(i=0)^n lambda_i = 1$. The probability $lambda_0$ selects
the payoff test; each $lambda_i$ selects a deviation test for player $i$.
Let $vx = (vx_1, ..., vx_n)$ specify a deviation strategy for each player.
Then
$
  g(tau) = max_(vmu in cX_M)
  min_(lambda in Delta({0, ..., n}), vx in product_(i=1)^n cX_i)
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
For fixed $vmu$, minimizing over $vx_i$ gives $-V_i (vmu)$ on test $i$.
Minimizing over $lambda$ then puts all the weight on the smallest test value:
$
  min{f(vmu) - tau, -V_1 (vmu), ..., -V_n (vmu)}
  = min{f(vmu) - tau, -V(vmu)}.
$
This is exactly $h_tau (vmu)$. The weights are probabilities; we do not need
to choose a large penalty multiplier.

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

#block(breakable: false)[
We can realize these tests as an extensive-form zero-sum game
#citep(<ZhangEtAl2023OptimalLearning>, [Proposition 3.6]). The two players are
the mediator, who maximizes, and a deviator, who minimizes. The deviator first
chooses a test index $i in {0, 1, ..., n}$. Write $u_j (z)$ for the utility of
agent $j$ at terminal node $z$ of $Gamma$.
]

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
Within $Gamma$, the deviator receives only the observations available to the
player it controls. Other information sets are inherited from the communication game.
This information restriction matters: if the mediator could observe the test,
it could use a different strategy for each constraint, instead of finding one
strategy that satisfies them all.

#figure(
  image("figures/information_design_binary_search/threshold_game.svg", width: 100%,
    alt: "The deviator chooses a target-payoff test or a player-deviation test. The latter uses a fair coin to compare direct play with a deviation, while the mediator's corresponding information sets remain joined."),
  caption: [The threshold game, with the original communication game compressed
    into each triangle. The dashed line indicates corresponding mediator
    decisions with the same original observations. Payoffs shown are for the
    mediator; the deviator receives their negatives.],
) <fig-l11-threshold-game>

#block(breakable: false)[
The direct and deviation branches may reach different terminal nodes.
Fix $vmu$ and $vx_i$. Taking expectations within each branch gives
$
  1/2 dot 2u_i (vmu, vx^*)
  + 1/2 dot (-2u_i (vmu, vx_i, vx^*_(-i)))
  = -[u_i (vmu, vx_i, vx^*_(-i)) - u_i (vmu, vx^*)].
$
]
The factors of $2$ cancel the coin's probability $1/2$. Mixing over tests
with probabilities $lambda_i$ now gives (@eq-l11-alternative-lagrangian).
Also, the target-test rewards lie in $[-1, 1]$ and the deviation-test rewards
lie in $[-2, 2]$. Hence the entire game has rewards in $[-2, 2]$, independently
of a large penalty parameter or the desired precision.

== Binary search with approximate solves <sec-l11-binary-search-algorithm>

An exact solve would tell us whether $g(tau) = 0$ or $g(tau) < 0$. In practice,
we solve only to a tolerance $0 < epsilon < 1$. At each target, we need one
of the following outcomes:

- *Accept:* find a mediator strategy $hat(vmu)$ satisfying
  $h_tau (hat(vmu)) >= -epsilon$. Then
  $ f(hat(vmu)) >= tau - epsilon quad "and" quad V(hat(vmu)) <= epsilon. $
- *Reject:* certify $g(tau) < 0$. By @cl-l11-threshold-test, this implies
  $tau > v^*$.

Acceptance allows a small error in both conditions. Rejection must rule out
_every_ mediator strategy; finding one unsuccessful strategy is not enough.
For example, at $tau = 0.60$ and $epsilon = 0.01$, acceptance guarantees
payoff at least $0.59$ and deviation gain at most $0.01$. It does not prove
that an _exact_ equilibrium achieves $0.60$.
Near the boundary, both outcomes may be valid; the search only needs the
guarantees stated above.

A candidate mediator gives a lower bound on the game value; a candidate
deviator gives an upper bound. For candidate strategies $overline(vmu)$ and
$(overline(lambda), overline(vx))$, best responses give
$
  L := min_(lambda, vx) L_tau (overline(vmu), lambda, vx)
     = h_tau (overline(vmu)), quad
  U := max_(vmu) L_tau (vmu, overline(lambda), overline(vx)).
$
Note $L <= g(tau) <= U$: $L$ is what the candidate mediator guarantees
against any deviator, and $U$ bounds what any mediator can achieve against
the candidate deviator. These are the same best-response bounds used in
the earlier #lecture-link("learning_intro", <sec-learning-zero-sum>)[zero-sum self-play setup].

Run the solver until $U - L <= epsilon/2$. If $L >= -epsilon$, accept
$overline(vmu)$. Otherwise,
$ U <= L + epsilon/2 < -epsilon + epsilon/2 < 0, $
so reject. Thus an approximate solve always supplies one of the two outcomes;
we never need to check whether a numerical value is exactly zero.

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

The initialization at $tau = 0$ always accepts: $g(0) = 0$, so a valid upper
bound cannot be negative. This gives us a strategy to return even if every
midpoint test rejects, including when $v^* = 0$.

The two search bounds play different roles. A rejection proves the target
is above $v^*$, so $b$ stays an upper bound on $v^*$. An acceptance only proves
approximate feasibility, so $a$ records an approximately achievable target.
We do not assume $a <= v^*$.

== Approximation guarantee <sec-l11-binary-search-guarantee>

#theorem[Binary-search guarantee][
  The strategy returned by @algo-l11-binary-search satisfies
  $ V(hat(vmu)) <= epsilon quad "and" quad
    f(hat(vmu)) >= v^* - 2epsilon. $
  There are at most $ceil(log_2 (1/epsilon))$ midpoint tests, in addition
  to the initialization. If each threshold test costs at most $T(epsilon)$, the
  total cost is $O(T(epsilon) (1 + log(1/epsilon)))$.
] <thm-l11-binary-search>

This is Theorem 3.7 of Zhang et al.~#citep(<ZhangEtAl2023OptimalLearning>),
with an explicit initialization for the saved strategy.

#proof[
  We track the following bounds throughout the search:
  $ b >= v^*, quad
    V(hat(vmu)) <= epsilon, quad f(hat(vmu)) >= a - epsilon. $

  Initially, $b = 1 >= v^*$. The test at $tau = 0$ supplies the saved strategy
  with the stated bounds at $a = 0$.

  On acceptance, we set $a = tau$ and save a strategy with
  $V(hat(vmu)) <= epsilon$ and $f(hat(vmu)) >= tau - epsilon = a - epsilon$.
  On rejection, $tau > v^*$, so setting $b = tau$ preserves $b >= v^*$.
  The saved strategy and $a$ stay unchanged. Thus the bounds are preserved.

  Each midpoint test halves the interval. At termination, $b - a <= epsilon$,
  so $a >= b - epsilon >= v^* - epsilon$. Hence
  $f(hat(vmu)) >= a - epsilon >= v^* - 2epsilon$.
  One $epsilon$ comes from the interval width, and the other from the
  accepted test. After $k$ midpoint tests the width is $2^(-k)$, so
  $k = ceil(log_2 (1/epsilon))$ tests suffice. Including initialization
  gives the stated cost.
]

== Comparing the two methods <sec-l11-lagrangian-comparison>

#block(breakable: false)[
Both methods let us use a zero-sum game solver to find an optimal
communication equilibrium. The difference is how they handle incentives.
In the direct method below, $lambda$ is again a scalar penalty, rather than
the probability vector over tests.

- *Direct Lagrangian.* Solve one game with payoff $f(vmu) - lambda V(vmu)$.
  This avoids an outer search. With the appropriate optimistic algorithm and
  penalty choice, the mediator's current strategy converges without averaging
  all previous strategies. This is last-iterate convergence. However, its
  terminal rewards grow with $lambda$.
- *Threshold Lagrangian.* Solve a sequence of games, each with a different
  target $tau$. The terminal rewards stay in $[-2, 2]$, and an
  $epsilon$-accurate threshold test suffices at every step. The cost is an
  extra logarithmic number of solves. We return the last accepted strategy;
  the intermediate games have different targets.
]

To see why the reward scale matters, suppose we divide rewards by a scale
$C$ before giving them to a solver. An error of $delta$ in the scaled game is
an error of $C delta$ in the original game. Thus, to get additive error
$epsilon$, we need $delta <= epsilon/C$. For the direct method,
$C$ grows with $lambda$; Solution 1 uses $lambda = 1/epsilon$. For the
threshold method, $C$ is a constant, so an error of order $epsilon$ in the
scaled game is enough.

For average strategies, slides 37 and 41 give $O(1/epsilon^2)$ iterations for
the direct method with optimistic multiplicative weights updates (OMWU),
compared with $tilde(O)(1/epsilon)$ total iterations for the binary-search
method #citep(<Zhang2026MechanismDesignSlides>). Game-dependent factors are
suppressed; $tilde(O)$ also suppresses logarithmic factors, including the
outer search. These are guarantees for the corresponding optimistic solvers,
not for an arbitrary approximate solver. See also Zhang et al.,
Corollary 3.4 and Section 3.2 #citep(<ZhangEtAl2023OptimalLearning>).

The direct method is useful when we can solve its single game accurately
and want last-iterate convergence. The threshold method trades extra solves
for bounded rewards and a lower precision requirement, which is useful for
approximate solvers such as deep reinforcement learning. To obtain the
proved guarantee, we still need the acceptance or rejection bounds above;
a learned strategy alone does not certify them.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
