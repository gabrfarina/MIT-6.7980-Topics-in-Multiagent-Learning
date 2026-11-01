#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: "S4",
  date: [Fall 2026],
  title: "Learning algorithms (II)",
)

#let darkblue = blue.darken(20%)

#v(-4mm)
In recent years, there has been a lot of interest in the idea of _optimism_ in
learning algorithms. We build on the #lecture-link("learning1", <ftrl-omd-general-case>)[FTRL and OMD updates and regret bounds]. The fundamental idea behind optimism is the following:

#v(-1mm)
#h(1mm)#box(
  width: 99%,
  stroke: (left: .4mm + gray),
  inset: (left: 3mm, top: 0mm, bottom: 1mm),
)[_When all players learn at the same time, the environment is nonstationary but not necessarily adversarial. Can one then take advantage of this to design learning algorithms with better regret guarantees and convergence properties?_]

= Predictivity, optimism, and acceleration <sec-predictivity>

The idea of predictive is to _anticipate_ the next utility gradient $vg^((t+1))$ by
having a _prediction_ $vm^((t+1))$.

At least three variants can be defined.

#table(
  columns: (22%, 78%),
  align: (horizon + left, horizon + left),
  inset: (y: 2.2mm, x: 2mm),
  fill: (j, i) => if j == 1 and i in (2, 4, 5) {
    blue.lighten(95%)
  } else {
    none
  },
  stroke: (j, i) => (
    top: if i == 0 { black + .4mm } else { none },
    bottom: if i == 0 or i == 5 { black + .4mm } else { gray + .2mm },
    left: if j == 1 { gray + .2mm } else { none },
  ),
  table.header()[*Algorithm / variant*][*Update*],
  [*FTRL* \ Non-predictive],
  $
    vx^((t+1)) := argmax_(vx in X) {ip(sum_(tau = 1)^t vg^((tau)), vx) - 1 / eta psi(vx)}
  $,

  [*FTRL* \ Predictive],
  $
    vx^((t+1)) := argmax_(vx in X) { ip(#html-math-color(darkblue, $vm^((t+1))$) + sum_(tau = 1)^t vg^((tau)), vx) - 1 / eta psi(vx) }
  $,

  [*OMD* \ Non-predictive],
  $
    vx^((t+1)) := argmax_(vx in X) {ip(vg^((t)), vx) - 1 / eta upright("D")_psi (vx || vx^((t)))}
  $,

  [*OMD* \ Predictive / non-reflected],
  $
    vz^((t+1)) &:= argmax_(vz in X) {ip(vg^((t)), vz) - 1 / eta upright("D")_psi (vz || vz^((t)))} \
    vx^((t+1)) &:= argmax_(vx in X) { ip(#html-math-color(darkblue, $vm^((t+1))$), vx) - 1 / eta upright("D")_psi (vx || vz^((t+1))) }
  $,

  [*OMD* \ Predictive / reflected],
  $
    vx^((t+1)) := argmax_(vx in X) { ip(vg^((t)) + #html-math-color(darkblue)[$vm^((t+1)) - vm^((t))$], vx) - 1 / eta upright("D")_psi (vx || vx^((t))) }
  $,
)

While the three predictive algorithms are in general different, they coincide in the special case of _Legendre regularizers_ (see also the #lecture-link("learning1", <ftrl-omd-general-case>)[discussion of when FTRL and OMD agree]).

#remark[
  For Legendre regularizers (i.e., when $psi$'s gradients go to infinity at the boundary of $cX$), the three predictive algorithms (FTRL, non-reflected OMD, reflected OMD) coincide.
]
It is also worth noting that the predictive versions of the algorithms subsume the non-predictive versions as a special case, as we point out in the next remark.

#remark[
  The standard (non-predictive) FTRL and OMD algorithms correspond to the case where the prediction is set
  to zero, i.e., $vm^((t)) = 0$ at all times $t$.
]

== Optimism <sec-optimism>

The idea of optimism is to use predictivity with the specific guess $vm^((t+1)) = vg^((t))$ at
all times $t$. This corresponds to predicting that the feedback is slow-changing.

#example[Optimistic online gradient ascent][
  The non-reflected OMD algorithm instantiated with squared Euclidean norm $psi(vx) = 1/2 norm(vx)_2^2$ gives rise to the (non-reflected) _optimistic online gradient ascent_ algorithm, whose update rule is
  #set math.equation(numbering: "(1)")
  $
    vz^((t+1)) & := #text(size: 14pt, $Pi$) _(cX)(vz^((t)) + eta vg^((t))), qquad qquad
                 vx^((t+1)) & := #text(size: 14pt, $Pi$) _(cX)(vz^((t+1)) + eta vg^((t))).
  $ <eq-ogda>
  #set math.equation(numbering: none)
]

#example[Optimistic MWU][
  For the MWU algorithm, the optimistic version of FTRL, non-reflected OMD, and reflected OMD all coincide, and give rise to the following update rule:
  $
    vx^((t+1)) prop exp(eta vr^((t)) + eta (#html-math-color(black, $vr^((t)) - vr^((t-1))$))).
  $
]

In two-player games, optimism serves as a form of _negative_ momentum that pushes the iterates towards the equilibrium. We illustrate this in the following example. We will give a quantitative analysis of the effect of optimism in the convergence of learning algorithms in @sec-iterate-convergence.

#example[
  The following plots show the dynamics of the optimistic and non-optimistic versions of MWU and OGD in the #lecture-link("learning1", <sec-ogd>)[two-player zero-sum example used to compare OGD and MWU], whose utility matrix is
  $ U_1 := mat(2, 1; 0, 2). $
  The multiplicative weights update algorithm was set up with constant learning rate $eta = 0.25$, while the online gradient descent algorithm was set up with learning rate $eta = 0.1$.
  #wrapped-figure(
    [
      The optimistic version of online projected gradient descent (OGD) was non-reflected. The purple dot indicates the starting strategy. The gray dotted line tracks the profile of _average_ strategies.

      As mentioned, the optimistic dynamics exhibit a "push" towards equilibrium, due to the negative momentum effect, which results in convergence towards the unique Nash equilibrium
      $
        vx^* & = (2/3, 1/3), \
        vy^* & = (1/3, 2/3).
      $
    ],
    [
      #image(
        "figures/learning2/optimistic.svg",
        width: 100%,
        alt: "Comparison of optimistic and non-optimistic MWU and OGD trajectories.",
      )
    ],
    side: left,
    text-width: 36%,
  )
]

== Predictive regret bounds (RVU) <sec-rvu>

Intuitively, one would expect that predictions _help_ in reducing the regret of the learning algorithm.
At one extreme, one would presumably hope that if the prediction is perfect, then the regret would be very small.
This is indeed the case, as shown by #citet(<syrgkanis2015fast>).

#theorem[RVU bound, #citep(<syrgkanis2015fast>)][
  Predictive FTRL and Predictive OMD satisfy the following regret bound, which is often called _RVU bound_ (regret bounded by variation in utilities):
  $
    "Reg"^((
      T
    )) <= max_(xhat in cX)( psi(xhat) - psi(vx^((1))) ) / ( eta ) + eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2,
  $
  where $norm(dot.c)_*$ is the dual norm of $norm(dot.c)$.
] <thm-rvu-bound>

#remark[
  A consequence of the previous regret bound is the fact that---assuming $vm^((t)) = vg^((t))$ is _omniscent_---the regret of the learning algorithm _does not grow with time_.]

== Accelerated learning of Nash equilibria in two-player zero-sum games <sec-fast-zero-sum>

As noted by #citep(<syrgkanis2015fast>), the RVU bound implies accelerated convergence to Nash equilibria in two-player zero-sum games. The proof is quite elementary, and we present it next.

#theorem[Accelerated convergence to Nash equilibria in two-player zero-sum games, #citep(<syrgkanis2015fast>)][
  Consider any two-player zero-sum game; let $mU in RR^(m times n)$ be the utility matrix for Player 1. If the players employ regret minimizers that guarantee RVU regret bounds of the form
  $
    "Reg"_1^((
      T
    )) &<= (Omega_1) / eta + eta sum_(t=1)^T norm(mU (vy^((t)) - vy^((t-1))))_*^2 - 1 / (8 eta) sum_(t=1)^T norm(vx^((t)) - vx^((t-1)))^2 \
    "Reg"_2^((
      T
    )) &<= (Omega_2) / eta + eta sum_(t=1)^T norm(mU^top (vx^((t)) - vx^((t-1))))_*^2 - 1 / (8 eta) sum_(t=1)^T norm(vy^((t)) - vy^((t-1)))^2,
  $
  and $eta <= 1\/(4 norm(mU)_"op")$, where
  $norm(mU)_"op" := max_(vz in RR^n) norm(mU vz)_* \/ norm(vz)$
  is the operator norm of $mU$, then, at any time $T$, the sum of the regrets of the players satisfies the bound
  $ "Reg"_1^((T)) + "Reg"_2^((T)) <= (Omega_1 + Omega_2) / eta $
  which is _constant_ with respect to time. The #lecture-link("learning_intro", <thm-regret-gap>)[regret-to-saddle-point-gap identity] then implies convergence to the set of Nash equilibria in two-player zero-sum games at the rate of $O_T (1\/T)$.
]
#proof[
  The statement follows from summing up the RVU bounds, and observing that the middle terms cancel out with the right-most terms. More precisely, we have
  $
    "Reg"_1^((
      T
    )) &<= (Omega_1) / eta + eta norm(mU)_"op" sum_(t=1)^T norm(vy^((t)) - vy^((t-1)))_*^2 - 1 / (8 eta) sum_(t=1)^T norm(vx^((t)) - vx^((t-1)))^2 \
    "Reg"_2^((
      T
    )) &<= (Omega_2) / eta + eta norm(mU)_"op" sum_(t=1)^T norm(vx^((t)) - vx^((t-1)))_*^2 - 1 / (8 eta) sum_(t=1)^T norm(vy^((t)) - vy^((t-1)))^2
  $
  #v(-1mm)
  Summing the inequalities and using the fact that $eta <= 1\/4 norm(mU)_"op"$ by assumption, we obtain the statement.
]

== Accelerated learning of coarse correlated equilibria in general games

Rates of $tilde(O)(1\/T)$ for coarse correlated and correlated equilibria (CCE)
via learning in normal-form games (and beyond) are also known for the multiplayer case, but
they are significantly harder to prove. One of the main obstacles is due to the fact that
convergence to CCE is driven by the _maximum_ of the regrets of the players, and not the sum as in two-player zero-sum Nash equilibria.

We mention some of the results in this direction.

- #citet(<syrgkanis2015fast>) showed $O(n log |A| T^(-3/4))$ for OMWU using RVU bounds.

- This result was later improved by #citet(<chen2020hedging>) to $O(n log^(5/6) |A| T^(-5/6))$ for _two-player_ general-sum games only.

- #citet(<daskalakis2021near>) showed $O(n log |A| (log^4 T) / T)$ convergence for OMWU using a very complicated analysis based on the idea of high-order stability.

- #citet(<farina2022near>) showed $O(n |A| (log T)/T)$ convergence rates using RVU bounds paired with a special regularizer.

= Convergence in iterates <sec-iterate-convergence>

The convergence results we have seen so far pertain to the _average_ strategies (either individual, or the average of the product) produced by learning dynamics.
One might then wonder what is known about the _iterate_ convergence to equilibrium.

Complexity-theoretic considerations regarding the hardness of approximating Nash equilibria preclude this phenomenon beyond two-player zero-sum games. As we now argue, in two-player zero-sum games the phenomenon is indeed possible.

#paragraph-marker() *Best-iterate convergence.*~~
#citet(<Anagnostides22:Last-Iterate>) showed that when both players use optimistic gradient ascent, the _best_ iterate converges to the Nash equilibrium in two-player zero-sum games at the rate of $O_T (1\/sqrt(T))$. At a high level, the proof of this result is in two steps. First, the authors show that the sum of the squared distances between consecutive iterates is bounded by a constant. This implies that at least one iterate is close to the previous one. Second, they show that small simultaneous movements imply proximity to a Nash equilibrium. Both of these steps require only elementary calculations; feel free to try to reproduce the result yourself or check the details in the original paper.

#paragraph-marker() *Last-iterate convergence.*~~
#citet(<Cai22:Finite>) improved the best-iterate result mentioned above by showing _last_ iterate converges to the Nash equilibrium at the rate of $O_T (1\/sqrt(T))$ for optimistic OGD. Their analysis is significantly more involved, and revolves around studying a Lyapunov potential function that was discovered via semidefinite programming.

Both of the results mentioned above pertain to optimistic OGD.

Arguably, it was believed for a while in the community that good
last-iterate convergence of OMWU were in the air, just "one good trick" away. After all, OMWU had always spoiled us with its good properties. Furthermore, the paper by #citet(<hsieh2021adaptive>) showed _asymptotic_ (i.e., in the limit, but without any concrete rates) convergence of optimistic MWU to the set of equilibria in two-player zero-sum games. So, it seemed pretty likely that good, concrete rates of convergence could be established beyon optimistic gradient ascent. However, in a recent twist, it was shown that the sitution is less rosy than expected. We illustrate this with an example.

#example[Poor last-iterate convergence of FTRL, #citep(<Cai2024Jun>)][
  Consider the two-player zero-sum game with utility matrix for Player 1 given by
  $ mU(delta) := mat(1/2 + delta, 1/2; 0, 1). $
  The game admits the unique Nash equilibrium $(vx^*, vy^*)$, where $ vx^* = (1/(1+delta), delta/(1+delta)) qquad "and" qquad vy^* = (1/(2(1+delta)), (1+2delta)/(2(1+delta))). $
  In particular, when $delta$ is small, the equilibrium strategy for Player 1 is approximately $vx^* = (1 - delta, delta)$ and thus very close to the boundary of the strategy polytope of the player. This proximity to the boundary affects the performance of all known instantiations of the the optimistic FTRL algorithm. To see this numerically, the next four plots show the evolution of three optimistic FTRL variants (entropic, Euclidean, and logarithmic) and the optimistic gradient ascent algorithm, in the game defined by $delta = 10^(-2).$

  #align(center, image(
    "figures/learning2/plots.svg",
    width: 100%,
    alt: "Entropic, Euclidean and logarithmic optimistic FTRL compared with optimistic gradient ascent near a boundary equilibrium.",
  ))

  The dynamics for the the first two algorithms get _extremely_ close to the boundary---for example, when using OMWU, iterates reached strategies with $1 - e^(-50) < x_1 < 1$.
]

By studying the dynamics produced by instantiations of the FTRL algorithm in the previous game, the following result can be established.

#theorem[Informal, #citep(<Cai2024Jun>)][
  Under standard assumptions about the regularizer, there is no function $f$ such
  that optimistic FTRL produces a last-iterate convergence rate of $f(|A_1|, |A_2|, T) -> 0$ when
  all payoffs of the game are in [0, 1], and $|A_1|$ and $|A_2|$ are the number
  of actions of the players. In other words, the last-iterate convergence rate must depend on _some form of condition number_ of the game.
]

= Exercise: best-iterate convergence of OGDA <sec-ogda-exercise>

// Start each part on a new page in the PDF; HTML has no pages.
#let part-break = context if target() != "html" { pagebreak(weak: true) }

#paragraph-marker() *OGDA.*~~
This exercise proves the best-iterate result for optimistic gradient methods mentioned in @sec-iterate-convergence, in the bilinear setting. For the saddle-point problem $max_(vx in cX) min_(vy in cY) vx^top A vy$ over convex compact sets $cX, cY subset.eq RR^n$, _optimistic gradient descent ascent_ (OGDA) runs
#set math.equation(numbering: "(1)")
$
  cases(
    vx^((t)) <- Pi_cX (vx^((t-1)) + 2 eta A vy^((t-1)) - eta A vy^((t-2))),
    vy^((t)) <- Pi_cY (vy^((t-1)) - 2 eta A^top vx^((t-1)) + eta A^top vx^((t-2))),
  )
$ <eq-ogda-bilinear>
#set math.equation(numbering: none)
where $Pi_cX$ and $Pi_cY$ are Euclidean projections. We start at $vx^((1)) = 0 in cX$ and $vy^((1)) = 0 in cY$ (@rem-ogda-arbitrary-start handles other starting points), and set $vx^((0)) := vx^((1))$, $vy^((0)) := vy^((1))$. Finally, $norm(cX)_2 := max_(vx in cX) norm(vx)_2$ and $norm(cY)_2 := max_(vy in cY) norm(vy)_2$ are the radii of the feasible sets, and $norm(A)_2 := max_(vy != 0) norm(A vy)_2 \/ norm(vy)_2$ is the operator norm of $A$.

#paragraph-marker() *RVU bound.*~~
Part 1 uses the RVU bound of @thm-rvu-bound. As stated in the course materials, it assumes $nabla psi(vx^((1))) = 0$ and applies to all variants of Predictive FTRL and Predictive OMD in @sec-predictivity, including reflected Predictive OMD.

#remark[Arbitrary initial points][
  The requirement $nabla psi(vx^((1))) = 0$ is the only reason for starting at $0$. For an arbitrary $vx^((1)) in cX$, use instead $psi(vx) := 1/2 norm(vx - vx^((1)))_2^2$. Its Bregman divergence is again $1/2 norm(vx - vx')_2^2$, so the algorithm is unchanged, and now $nabla psi(vx^((1))) = 0$. The initial term becomes $max_(xhat in cX) norm(xhat - vx^((1)))_2^2 \/ (2 eta) <= (2 norm(cX)_2)^2 \/ (2 eta) = 2 norm(cX)_2^2 \/ eta$. So Part 1's bounds hold with $norm(cX)_2^2$ and $norm(cY)_2^2$ replaced by $4 norm(cX)_2^2$ and $4 norm(cY)_2^2$, and the constant $4$ in Part 2 becomes $8$.
] <rem-ogda-arbitrary-start>

#part-break
#exercise[OGDA, Part 1: RVU bounds for both players][
The cumulative regret of the max player is
$
  "Reg"_1^((T)) := max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)).
$
Using @thm-rvu-bound, show that when both players run OGDA,
$
  "Reg"_1^((T)) <= norm(cX)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2.
$
Then argue that the min player enjoys a similar regret bound.

_Hint._ Gradient ascent can be captured by OMD with the Euclidean regularizer $psi(vx) = 1/2 norm(vx)_2^2$. Which variant of Predictive OMD is OGDA, and what are its gradients $vg^((t))$ and predictions $vm^((t))$?
] <ex-ogda-part1>

#reference-solutions(title: [Show / hide solution to Part 1])[
#solution[Part 1][
*OGDA as Predictive OMD.* Reflected Predictive OMD with regularizer $psi$ updates
$
  vx^((t+1)) := argmax_(vx in cX) {ip(vg^((t)) + vm^((t+1)) - vm^((t)), vx) - 1 / eta div(vx, vx^((t)), dgf: psi)}.
$
For $psi(vx) := 1/2 norm(vx)_2^2$, the Bregman divergence is $div(vx, vx', dgf: psi) = 1/2 norm(vx - vx')_2^2$, and completing the square turns the update into a projection:
$
  vx^((t+1)) = Pi_cX (vx^((t)) + eta (vg^((t)) + vm^((t+1)) - vm^((t)))).
$
Substituting the max player's utility gradient $vg^((t)) := A vy^((t))$ and the optimistic prediction $vm^((t)) := vg^((t-1)) = A vy^((t-1))$ gives $vx^((t+1)) = Pi_cX (vx^((t)) + 2 eta A vy^((t)) - eta A vy^((t-1)))$, which is the OGDA update (@eq-ogda-bilinear).

*Applying @thm-rvu-bound.* With the norm $norm(dot.c)_2$, the bound of @thm-rvu-bound has three terms:
$
  "Reg"^((T)) <= underbrace(max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta, "initial term") + underbrace(eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_2^2, "prediction error") - underbrace(1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2, "movement").
$
We check the hypotheses and the left-hand side, then evaluate the three terms.
- _Regularizer._ $psi$ is $1$-strongly convex with respect to $norm(dot.c)_2$, whose dual norm is again $norm(dot.c)_2$, and
  $
    nabla psi(vx^((1))) = vx^((1)) = 0.
  $
- _Regret._ With $vg^((t)) = A vy^((t))$, the regret in @thm-rvu-bound is the max player's regret:
  $
    "Reg"^((T)) & = max_(vx^* in cX) sum_(t=1)^T ip(A vy^((t)), vx^* - vx^((t))) \
                & = max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)) = "Reg"_1^((T)).
  $
- _Initial term._ Since $vx^((1)) = 0$,
  $
    max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta = max_(xhat in cX) norm(xhat)_2^2 / (2 eta) = norm(cX)_2^2 / (2 eta).
  $
- _Prediction error._ Since $vy^((0)) = vy^((1))$, the $t = 1$ term vanishes:
  $
    eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_2^2 = eta sum_(t=1)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 = eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2.
  $
- _Movement._ The term $-1/(8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2$ involves only the iterates, so it is unchanged.

*Result.* Substituting these into @thm-rvu-bound, the max player's regret satisfies
$
  "Reg"_1^((T)) <= norm(cX)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2,
$

*The min player.* The min player maximizes the utility $vy |-> -(vx^((t)))^top A vy$. Substituting its gradient $-A^top vx^((t))$ and prediction $-A^top vx^((t-1))$ into the same update gives $vy^((t+1)) = Pi_cY (vy^((t)) - 2 eta A^top vx^((t)) + eta A^top vx^((t-1)))$, the OGDA update for $vy$. Its regret is
$
  "Reg"_2^((T)) := max_(vy^* in cY) sum_(t=1)^T ip(-A^top vx^((t)), vy^* - vy^((t))) = sum_(t=1)^T (vx^((t)))^top A vy^((t)) - min_(vy^* in cY) sum_(t=1)^T (vx^((t)))^top A vy^*,
$
and the same checks, with $vy^((1)) = 0$ and $vx^((0)) = vx^((1))$, give the similar bound
$
  "Reg"_2^((T)) <= norm(cY)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A^top vx^((t)) - A^top vx^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vy^((t)) - vy^((t-1)))_2^2.
$
]
]

#part-break
#exercise[OGDA, Part 2: total movement is sublinear][
Show that when the learning rate is sufficiently small, namely $eta <= 1 \/ (4 norm(A)_2)$, the total distance of policy changes is sublinear:
$
  sum_(t=2)^T (norm(vx^((t)) - vx^((t-1)))_2 + norm(vy^((t)) - vy^((t-1)))_2) <= 4 sqrt(T) (norm(cX)_2 + norm(cY)_2).
$

_Hint._ The sum of the cumulative regrets of both players is nonnegative, since it is the sum of Nash gaps. Then apply the Cauchy--Schwarz inequality to convert the upper bound on $sum norm(dot.c)_2^2$ into an upper bound on $sum norm(dot.c)_2$.
] <ex-ogda-part2>

#reference-solutions(title: [Show / hide solution to Part 2])[
#solution[Part 2][
Let $L$ be the operator norm of $A$,
$
  L := norm(A)_2 = sup_(vv != 0) norm(A vv)_2 / norm(vv)_2, qquad "so that" qquad norm(A vv)_2 <= L norm(vv)_2 quad "for all" vv.
$
Write $Delta vx^((t)) := vx^((t)) - vx^((t-1))$, $Delta vy^((t)) := vy^((t)) - vy^((t-1))$, and let
$
  S := sum_(t=2)^T (norm(Delta vx^((t)))_2^2 + norm(Delta vy^((t)))_2^2)
$
be the total squared movement. The goal is a bound on $S$ that does not depend on $T$ (Steps 1--3), which Cauchy--Schwarz then turns into the claim (Step 4).

*Step 1: add the two RVU bounds.* The prediction errors in Part 1 are $A vy^((t)) - A vy^((t-1)) = A Delta vy^((t))$ for the max player and $A^top vx^((t)) - A^top vx^((t-1)) = A^top Delta vx^((t))$ for the min player, and the two movement terms add up to $S$. Adding the two bounds of Part 1,
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) + eta sum_(t=2)^T (norm(A Delta vy^((t)))_2^2 + norm(A^top Delta vx^((t)))_2^2) - 1 / (8 eta) S.
$

*Step 2: operator norm and step size.* By definition of the operator norm, and since $norm(A^top)_2 = norm(A)_2$,
$
  sum_(t=2)^T (norm(A Delta vy^((t)))_2^2 + norm(A^top Delta vx^((t)))_2^2) <= L^2 sum_(t=2)^T (norm(Delta vy^((t)))_2^2 + norm(Delta vx^((t)))_2^2) = L^2 S.
$
Substituting into Step 1,
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - (1 / (8 eta) - eta L^2) S.
$
If $eta <= 1 \/ (4 L)$, then $eta L^2 <= 1 \/ (16 eta)$, so $1 \/ (8 eta) - eta L^2 >= 1 \/ (16 eta)$ and
#set math.equation(numbering: "(1)")
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - 1 / (16 eta) S.
$ <eq-ogda-sum-upper>
#set math.equation(numbering: none)

*Step 3: bound $S$.* The right-hand side of (@eq-ogda-sum-upper) decreases in $S$, so any lower bound on $"Reg"_1^((T)) + "Reg"_2^((T))$ caps $S$. We show $"Reg"_1^((T)) + "Reg"_2^((T)) >= 0$. In the sum of the two regrets, the terms $sum_t (vx^((t)))^top A vy^((t))$ cancel. With $overline(vx) := 1/T sum_t vx^((t)) in cX$ and $overline(vy) := 1/T sum_t vy^((t)) in cY$ (by convexity),
$
  "Reg"_1^((T)) + "Reg"_2^((T)) = T (max_(vx^* in cX) (vx^*)^top A overline(vy) - min_(vy^* in cY) overline(vx)^top A vy^*) >= T (overline(vx)^top A overline(vy) - overline(vx)^top A overline(vy)) = 0,
$
where the inequality takes $vx^* = overline(vx)$ and $vy^* = overline(vy)$. (This is $T$ times the #lecture-link("learning_intro", <thm-regret-gap>)[saddle point gap] of $(overline(vx), overline(vy))$.) Chaining with (@eq-ogda-sum-upper),
$
  0 <= "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - 1 / (16 eta) S,
$
that is,
$
  S <= 8 (norm(cX)_2^2 + norm(cY)_2^2).
$

*Step 4: from $S$ to the total movement.* By the Cauchy--Schwarz inequality over the $T - 1$ terms, then $(a + b)^2 <= 2 a^2 + 2 b^2$ (which gives the sum $S$), and finally Step 3,
$
  & sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) \
  & quad <= sqrt(T - 1) (sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2)^2)^(1\/2) <= sqrt(T - 1) sqrt(2 S) \
  & quad <= 4 sqrt(T - 1) sqrt(norm(cX)_2^2 + norm(cY)_2^2) <= 4 sqrt(T) (norm(cX)_2 + norm(cY)_2),
$
where the last step uses $sqrt(a^2 + b^2) <= a + b$ for $a, b >= 0$.
]
]

#part-break
#exercise[OGDA, Part 3: sublinear regret and best-iterate convergence][
For the projection step $vw <- Pi_cX (vv)$, the following inequality holds for any $vx in cX$:
$
  ip(vv - vw, vx - vw) <= 0.
$
Intuitively, the vector $vv - vw$ points outward from the convex set $cX$ at the point $vw$, and any vector $vx - vw$ pointing into $cX$ forms an obtuse angle with it.

Show that when $eta <= 1 \/ (4 norm(A)_2)$, the max player achieves sublinear cumulative regret:
$
  max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)) <= O(sqrt(T) / eta (norm(cX)_2 + norm(cY)_2)^2).
$
Then conclude that OGDA achieves best-iterate convergence: with a proper choice of $eta$, for every $T$ there exists some $t <= T$ such that
$
  (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* <= O(1 / sqrt(T) (norm(cX)_2 + norm(cY)_2)^2 norm(A)_2).
$

_Hint._ Start by applying the projection inequality to the update $vx^((t)) <- Pi_cX (vx^((t-1)) + 2 eta A vy^((t-1)) - eta A vy^((t-2)))$ with $vx = vx^*$. From this, extract an upper bound on $(vx^*)^top A vy^((t-1)) - (vx^((t-1)))^top A vy^((t-1))$. The additional inner product terms can be bounded individually using the Cauchy--Schwarz inequality.
] <ex-ogda-part3>

#reference-solutions(title: [Show / hide solution to Part 3])[
#solution[Part 3][
Write $L := norm(A)_2$, $Delta vx^((t)) := vx^((t)) - vx^((t-1))$, $Delta vy^((t)) := vy^((t)) - vy^((t-1))$, and $D := norm(cX)_2 + norm(cY)_2$. Fix an alternative strategy $vx^* in cX$, the fixed strategy whose payoff the max player compares its own against in hindsight, and let
$
  r_t := (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^((t)) = ip(A vy^((t)), vx^* - vx^((t)))
$
be the regret of round $t$, so that $"Reg"_1^((T)) = max_(vx^* in cX) sum_(t=1)^T r_t$.

*Decomposition of $r_(t-1)$.* For $t >= 2$, let $vq^((t)) := 2 A vy^((t-1)) - A vy^((t-2))$, so that $vx^((t)) = Pi_cX (vx^((t-1)) + eta vq^((t)))$. Substituting $A vy^((t-1)) = vq^((t)) - A Delta vy^((t-1))$ and $vx^* - vx^((t-1)) = (vx^* - vx^((t))) + Delta vx^((t))$,
#set math.equation(numbering: "(1)")
$
  r_(t-1) & = ip(A vy^((t-1)), vx^* - vx^((t-1))) \
          & = underbrace(ip(vq^((t)), vx^* - vx^((t))), "Step 1") + underbrace(ip(A Delta vy^((t-1)), vx^((t)) - vx^*) + ip(A vy^((t-1)), Delta vx^((t))), "Step 2").
$ <eq-ogda-r-decomp>
#set math.equation(numbering: none)

*Step 1: bound the first term with the projection inequality.* The projection inequality with $vv = vx^((t-1)) + eta vq^((t))$, $vw = vx^((t))$, and $vx = vx^*$ gives
$
  ip(vx^((t-1)) - vx^((t)), vx^* - vx^((t))) + eta ip(vq^((t)), vx^* - vx^((t))) <= 0,
$
that is, $eta ip(vq^((t)), vx^* - vx^((t))) <= ip(Delta vx^((t)), vx^* - vx^((t)))$.
Expanding $norm(vx^* - vx^((t-1)))_2^2 = norm((vx^* - vx^((t))) + Delta vx^((t)))_2^2$ gives the identity
$
  2 ip(Delta vx^((t)), vx^* - vx^((t))) = norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2 - norm(Delta vx^((t)))_2^2.
$
Dropping the last (nonpositive) term,
$
  ip(vq^((t)), vx^* - vx^((t))) <= 1 / (2 eta) (norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2).
$

*Step 2: bound the other two terms with Cauchy--Schwarz.* By Cauchy--Schwarz and the definition of $L$, using $norm(vx^((t)) - vx^*)_2 <= 2 norm(cX)_2$ and $norm(vy^((t-1)))_2 <= norm(cY)_2$,
$
  ip(A Delta vy^((t-1)), vx^((t)) - vx^*) <= 2 L norm(cX)_2 norm(Delta vy^((t-1)))_2, qquad ip(A vy^((t-1)), Delta vx^((t))) <= L norm(cY)_2 norm(Delta vx^((t)))_2.
$
Substituting Steps 1 and 2 into (@eq-ogda-r-decomp), for every $t = 2, ..., T$,
$
  r_(t-1) <= 1 / (2 eta) (norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2) + 2 L norm(cX)_2 norm(Delta vy^((t-1)))_2 + L norm(cY)_2 norm(Delta vx^((t)))_2.
$

*Step 3: sum and invoke Part 2.* Summing over $t = 2, ..., T$, the distances telescope, and $norm(vx^* - vx^((1)))_2^2 <= 4 norm(cX)_2^2$. Since $Delta vy^((1)) = 0$ by the convention $vy^((0)) = vy^((1))$, the sum of $norm(Delta vy^((t-1)))_2$ is at most $sum_(t=2)^T norm(Delta vy^((t)))_2$. Bounding both $norm(cX)_2$ and $norm(cY)_2$ by $D$,
$
  sum_(t=1)^(T-1) r_t & <= (2 norm(cX)_2^2) / eta + 2 L D sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) \
                      & <= (2 D^2) / eta + 2 L D dot.c 4 sqrt(T) D <= (2 D^2) / eta + (2 sqrt(T) D^2) / eta,
$
where we used Part 2 and then $L <= 1 \/ (4 eta)$.

*Step 4: the last round.* Step 3 covers $r_1, ..., r_(T-1)$. For $r_T$, by Cauchy--Schwarz, $r_T <= L norm(cY)_2 dot.c 2 norm(cX)_2 <= L D^2 \/ 2 <= D^2 \/ (8 eta)$, using $norm(cX)_2 norm(cY)_2 <= D^2 \/ 4$.

Adding Steps 3 and 4 and using $1 <= sqrt(T)$,
$
  sum_(t=1)^T r_t <= (2 + 1 / 8 + 2 sqrt(T)) D^2 / eta <= (5 sqrt(T) D^2) / eta.
$
The bound holds for every $vx^* in cX$, so $"Reg"_1^((T)) <= 5 sqrt(T) D^2 \/ eta = O(sqrt(T) D^2 \/ eta)$. The symmetric argument for the min player, with gradient $-A^top vx^((t))$, gives $"Reg"_2^((T)) <= 5 sqrt(T) D^2 \/ eta$.

*Step 5: from cumulative regret to the best iterate.* A saddle point $(vx^*, vy^*)$ exists by the minimax theorem, since $cX$ and $cY$ are convex and compact. Define the gap of round $t$,
$
  G_t := (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^*.
$
Adding and subtracting $(vx^((t)))^top A vy^((t))$ splits it into one round of regret for each player:
$
  G_t = underbrace((vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^((t)), "max player vs." vx^*) + underbrace((vx^((t)))^top A vy^((t)) - (vx^((t)))^top A vy^*, "min player vs." vy^*).
$
Summing over $t$, the first bracket sums to at most $"Reg"_1^((T))$ (with $vx^*$ as the max player's alternative strategy) and the second to at most $"Reg"_2^((T))$ (with $vy^*$ as the min player's), so
$
  sum_(t=1)^T G_t <= "Reg"_1^((T)) + "Reg"_2^((T)) <= (10 sqrt(T) D^2) / eta.
$
Each $G_t$ is nonnegative. With $v := (vx^*)^top A vy^*$, the saddle-point property gives $(vx^*)^top A vy >= v$ for all $vy in cY$ and $vx^top A vy^* <= v$ for all $vx in cX$, so
$
  G_t = (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* >= v - v = 0.
$
Hence
$
  min_(1 <= t <= T) G_t <= 1 / T sum_(t=1)^T G_t <= (10 D^2) / (eta sqrt(T)).
$

*Step 6: choose the step size.* Take $eta := 1 \/ (4 L)$ (if $L = 0$, every $G_t$ is $0$). Then $1 \/ eta = 4 L$, and some $t <= T$ satisfies
$
  (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* <= (40 norm(A)_2 (norm(cX)_2 + norm(cY)_2)^2) / sqrt(T) = O(1 / sqrt(T) (norm(cX)_2 + norm(cY)_2)^2 norm(A)_2).
$
]

]

#reference-solutions(title: [Show / hide solution outlines])[
#block(breakable: false)[
*Solution outlines*

Here $L := norm(A)_2$, $D := norm(cX)_2 + norm(cY)_2$, and the step size satisfies $eta <= 1 \/ (4 L)$ in Parts 2 and 3.

#align(center)[
#table(
  columns: (auto, 1fr, 1fr),
  align: left,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Part*], [*Result*], [*Main tools*]),

  [1], [RVU bound for each player, with initial term $norm(cX)_2^2 \/ (2 eta)$ (resp. $norm(cY)_2^2 \/ (2 eta)$)], [OGDA is reflected Predictive OMD with $psi = 1/2 norm(dot.c)_2^2$ and $vm^((t)) = vg^((t-1))$],

  [2], [$sum_t (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) <= 4 sqrt(T) D$], [Sum of RVU bounds; operator norm; nonnegative combined regret; Cauchy--Schwarz],

  [3], [$"Reg"_1^((T)), "Reg"_2^((T)) <= 5 sqrt(T) D^2 \/ eta$; some $t <= T$ has gap $<= 40 L D^2 \/ sqrt(T)$], [Projection inequality; telescoping; Part 2; nonnegative gaps; minimum $<=$ average],
)
]
]
]

#lec_bibliography("meta/refs.bib")
