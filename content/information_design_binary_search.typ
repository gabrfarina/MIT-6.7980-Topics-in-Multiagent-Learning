#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// L11 Task 10. Draft prepared by Eli Park with assistance from ChatGPT.
// Standalone contribution for later integration with the other L11 sections.

= An alternative Lagrangian: thresholding and binary search <sec-l11-binary-search>

The previous section chose a large multiplier $lambda$ to discourage profitable
deviations. This lets us solve a single zero-sum game, but it also magnifies the
game's rewards and the precision needed from the solver. We can avoid choosing
this multiplier by changing the question we ask:

#block(inset: (left: 10pt), stroke: (left: 1pt))[
  *Can the mediator achieve value at least $tau$, while keeping every player
  willing to follow the recommendations?*
]

For a fixed target $tau$, we will construct a zero-sum game that tests these two
requirements. We then use binary search to find a nearly optimal target. This
is the alternative Lagrangian of Zhang et al.
#citep(<ZhangEtAl2024OptimalLearning>), Section 3.2.

== Testing a target value

Keep the notation from the preceding section: $vmu$ is the mediator's strategy,
$vx^*$ is the profile of direct strategies, and $V(vmu)$ is the largest gain
any player can obtain by deviating. Write $f(vmu):=u_M (vmu,vx^*)$ for the
mediator's value when all players are direct. Recall that $V(vmu)>=0$, with
$V(vmu)=0$ exactly at a direct communication equilibrium.

Assume the finite communication game has an equilibrium and terminal rewards
normalized to $[0,1]$. Let $v^*$ be the best mediator value over exact
equilibria. A target $tau in [0,1]$ is feasible when some $vmu$ satisfies
$f(vmu)>=tau$ and $V(vmu)=0$.

To test both requirements at once, take the smaller of their two margins:
#set math.equation(numbering: "(1)")
$
  F_tau (vmu) := min { underbrace(f(vmu)-tau, "objective margin"),
    underbrace(-V(vmu), "incentive margin") },
$ <eq-l11-threshold-slack>
#set math.equation(numbering: none)
and let $W(tau):=max_(vmu in cX_M) F_tau (vmu)$ be the best margin the mediator
can guarantee. The objective margin is nonnegative if the target is reached.
The incentive margin is nonnegative if no deviation is profitable. A negative
value of either margin identifies a failed requirement.

Because $-V(vmu)<=0$, the best possible test value is zero. Consequently,
$
  W(tau)=0 quad <=> quad tau<=v^*,
  quad "and" quad W(tau)<0 quad <=> quad tau>v^*.
$
For the forward direction, a strategy attaining zero must satisfy both
requirements. For the reverse direction, an equilibrium with value at least
$tau$ makes the smaller margin zero. The maximum is attained because the
strategy sets are compact and the payoffs are continuous.

== The test as a zero-sum game

Give the minimizing player, called the *deviator*, a choice of what to test:

- *The objective:* choose index $0$; the mediator's payoff is $f(vmu)-tau$.
- *An incentive:* choose player $i$ and a deviation $vx_i$. The mediator's
  payoff is the negative of that player's gain:
  $u_i (vmu,vx^*)-u_i (vmu,vx_i,vx^*_(-i))$.

The mediator maximizes its payoff; the deviator minimizes it and receives the
opposite payoff. For any fixed $vmu$, the deviator can select the most violated
requirement. Thus the mediator's guaranteed payoff is precisely
$F_tau (vmu)$.

Allowing the deviator to mix over its choice of index gives the alternative
Lagrangian explicitly:
#set math.equation(numbering: "(1)")
$
  W(tau) = max_(vmu in cX_M)
    min_(vp in Delta_(n+1), vx_i in cX_i: i in [n])
    [ p_0 (f(vmu)-tau) \
    + sum_(i=1)^n p_i (u_i (vmu,vx^*)-u_i (vmu,vx_i,vx^*_(-i))) ].
$ <eq-l11-threshold-game>
#set math.equation(numbering: none)
Here $Delta_(n+1)$ is the probability simplex on indices $0,1,...,n$.
Minimizing over these probabilities selects the smallest margin, as required.
The weights $p_i$ replace the fixed penalty multiplier: they sum to one rather
than making any payoff arbitrarily large.

#figure(
  image("information_design_binary_search/threshold_game.svg", width: 85%),
  placement: auto,
  caption: [The threshold game. One representative player branch $i$ is shown;
    every other player has an analogous branch. Labels give the mediator's
    auxiliary payoff; the deviator receives its negative.],
) <fig-l11-threshold-game>

To realize the incentive test as an extensive-form game, use the same
fair-coin construction as in Solution #1. After the deviator selects $i>0$,
nature chooses with equal probability whether everyone must remain direct or
the deviator may control player $i$. At a terminal history $z$, give the
mediator payoff $+2u_i (z)$ in the direct branch and $-2u_i (z)$ in the deviation
branch. Their expected payoff is
$
  1/2 (2u_i (vmu,vx^*)) - 1/2 (2u_i (vmu,vx_i,vx^*_(-i)))
  = u_i (vmu,vx^*)-u_i (vmu,vx_i,vx^*_(-i)).
$
The factors of two cancel the coin's probabilities. If the deviator instead
chooses index $0$, skip the coin, keep every player direct, and use terminal
payoff $u_M (z)-tau$.

*The mediator must use one policy across all these tests.* Its information
sets hide the added index and coin outcome while preserving its ordinary
observations. If it knew which test was being run, it could optimize the
objective in one copy and satisfy incentives in another. The deviator retains
only the original information of the player it controls, in addition to knowing
the added index and coin outcome.

Since the original rewards lie in $[0,1]$, all terminal payoffs of this
auxiliary game lie in $[-2,2]$. This bound holds regardless of the desired
accuracy; there is no large $lambda$.

== Searching with an approximate solver

With an exact solver, binary search would simply ask whether $W(tau)$ is zero
or negative. An approximate solver needs a little more care near zero. It
should maintain a guaranteed lower bound from its candidate mediator strategy
and a guaranteed upper bound from its deviator strategy:
$
  L := F_tau (vmu) <= W(tau) <= U.
$
The upper bound $U$ is the largest payoff any mediator could obtain against
that fixed deviator strategy. Both bounds can be computed through best
responses in the auxiliary zero-sum game. They justify two different updates:

- If $L>=-eps$, *keep the candidate and raise the target*. Equation
  (@eq-l11-threshold-slack) gives $f(vmu)>=tau-eps$ and $V(vmu)<=eps$:
  the candidate nearly reaches the target and no player can gain more than
  $eps$ by deviating.
- If $U<0$, *lower the target*. Even the best mediator cannot pass this test
  exactly, so $tau>v^*$.

A negative lower bound is not enough to reject a target: it might only show
that the current candidate is poor. Keep solving until one of the two updates
is justified. A certified gap $U-L<=eps/2$ suffices, because either $U<0$ or
$L>=-eps/2$. If both updates are justified, either is valid; the pseudocode
below prioritizes keeping the candidate.

#block(stroke: 0.5pt, inset: 9pt, breakable: false)[
  *Algorithm: threshold search*

  Input: $0<eps<1$ and a zero-sum solver providing the bounds above.

  + Set $ell:=0$ and $r:=1$.
  + Solve the test at $tau=0$ until $L>=-eps$; store its strategy as $vmu_"keep"$.
  + While $r-ell>eps$:
    + Set $tau:=(ell+r)/2$ and solve its test until $L>=-eps$ or $U<0$.
    + If $L>=-eps$, set $ell:=tau$ and $vmu_"keep":=vmu$.
    + Otherwise, set $r:=tau$.
  + Return $vmu_"keep"$.
]

The initial test at zero is feasible and ensures that a stored strategy exists
even when $v^*=0$. The remaining loop is Algorithm 1 of
#citep(<ZhangEtAl2024OptimalLearning>), with its stopping conditions made
explicit. When using a no-regret solver, the candidate can be its averaged
realization plan; this is not generally obtained by averaging behavioral
action probabilities separately.

== What does the returned strategy guarantee?

*Guarantee.* The returned strategy is an $eps$-communication equilibrium and
achieves mediator value at least $v^*-2eps$. It requires
$O(log(1/eps))$ zero-sum game solves, each to $O(eps)$ accuracy. This is the
guarantee of Theorem 3.7 in #citep(<ZhangEtAl2024OptimalLearning>).

*Proof.* Every stored candidate has deviation gain at most $eps$ and mediator
value at least $ell-eps$. The upper endpoint $r$ starts at or above $v^*$ and can
only move to a threshold proved to exceed $v^*$, so it remains an upper bound.
At termination, $r-ell<=eps$, giving $ell>=v^*-eps$. Combining the two losses,
$
  f(vmu_"keep") >= ell-eps >= v^*-2eps.
$
Each iteration halves an interval initially of length one, so there are at
most $ceil(log_2(1/eps))$ iterations, plus the initial test. #h(1fr) $square$

The lower endpoint $ell$ need not be below the exact optimum: we allow small
incentive violations when accepting a candidate. For example, in the
car-selling game the optimal exact sale probability is $2/3$. A target of
$3/4$ must therefore fail the exact test, but a target just above $2/3$ may be
accepted approximately. The proof accommodates this: it uses the upper
endpoint to bound the exact optimum and the stored candidate to bound what
we actually achieve.

== Comparison with Solution #1

#block(breakable: false)[
#table(
  columns: (0.9fr, 1.25fr, 1.25fr),
  inset: 5pt,
  align: left,
  table.header([*Property*], [*Direct Lagrangian*], [*Threshold search*]),
  [Game solves], [One, for a chosen $lambda$.], [$O(log(1/eps))$ targets.],
  [Terminal rewards], [Their scale depends on $lambda$.], [Bounded by $[-2,2]$.],
  [Solver accuracy], [Must account for the penalty's scale.], [$O(eps)$ accuracy per test.],
  [Last iterates], [Can be studied in one fixed game.], [Return the stored candidate from a sequence of games.],
)
]

The lecture's OMWU comparison #citep(<Zhang2026L11Slides>), suppressing
game-dependent factors, gives $O(1/eps^2)$ iterations for the averaged direct
approach and $tilde(O)(1/eps)$ for threshold search. The latter hides the
logarithmic search overhead. These rates concern that particular solver,
rather than arbitrary methods for solving zero-sum games.

The practical tradeoff is repeated solves versus reward scale. Threshold
search can be useful when the solver struggles with large rewards or high
precision, as in deep reinforcement learning. It is not always faster: the
paper's tabular experiments in Appendix H often favor the direct method.
The approximation guarantee above assumes the stated solver bounds; it does
not automatically follow from using a heuristic learner.

= Bibliography

#lec_bibliography("meta/refs.bib", title: none)
