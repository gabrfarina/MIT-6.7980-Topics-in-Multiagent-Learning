#import "meta/gabri_notes.typ": *
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
]

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
#citet(<Anagnostides22:Last-Iterate>) showed that when both players use optimistic gradient ascent, the _best_ iterate converges to the Nash equilibrium in two-player zero-sum games at the rate of $O_T (1\/sqrt(T))$. The proof has two steps, and both are elementary calculations.

*Setting.* Both players run optimistic gradient ascent with $eta <= 1\/(4 norm(mU)_"op")$, so that the RVU bounds of the accelerated-convergence theorem hold with constants $Omega_1, Omega_2$. Throughout, $norm(dot.c)$ is the Euclidean norm, so that $norm(dot.c)_* = norm(dot.c)$ and $norm(mU^top)_"op" = norm(mU)_"op"$. The players receive the gradients $vg_x^((t)) = mU vy^((t))$ and $vg_y^((t)) = -mU^top vx^((t))$, and $vz^((t)), vw^((t))$ denote their intermediate iterates, as in the update rule of the optimistic gradient ascent example. Shifting the index in the second update of @eq-ogda, we have the identities
$
  vz^((t+1)) = Pi_cX (vz^((t)) + eta vg_x^((t))), qquad vx^((t)) = Pi_cX (vz^((t)) + eta vg_x^((t-1))),
$
and, analogously for Player 2, $vw^((t+1)) = Pi_cY (vw^((t)) + eta vg_y^((t)))$ and $vy^((t)) = Pi_cY (vw^((t)) + eta vg_y^((t-1)))$. Let $D$ be the largest diameter of $cX$ and $cY$, and $G$ a bound on the gradient norms. We use the RVU bounds with the sums of squared movements starting at $t = 2$. The prediction-error term at $t = 1$ is at most $eta G^2$ (taking $vm^((1)) = 0$), and we absorb it into the constants $Omega_1, Omega_2$.

#theorem[Best-iterate convergence, #citep(<Anagnostides22:Last-Iterate>)][
  For any $epsilon > 0$ and $T >= 2 + 32 (Omega_1 + Omega_2) \/ epsilon^2$, there is a $t in {3, dots, T}$ such that neither player can gain more than $epsilon (2 D \/ eta + G)$ by deviating from $(vx^((t)), vy^((t)))$. In particular, the best iterate among the first $T$ is an $O_T (1\/sqrt(T))$-approximate Nash equilibrium.
]

#proof[
  First, the RVU bound implies that the sum of the squared distances between consecutive iterates is bounded by a constant, so some iterate barely moves. Second, small movement implies proximity to a Nash equilibrium.
  
  *Step 1: The sum of squared distances between consecutive iterates is bounded.* We claim that
  $
    sum_(t=2)^T ( norm(vx^((t)) - vx^((t-1)))^2 + norm(vy^((t)) - vy^((t-1)))^2 ) <= 16 (Omega_1 + Omega_2).
  $
  Adding up the two RVU bounds and using $norm(mU (vy^((t)) - vy^((t-1))))_* <= norm(mU)_"op" norm(vy^((t)) - vy^((t-1)))$ (and similarly for $mU^top$), as in the proof of the accelerated-convergence theorem, we get
  $
    "Reg"_1^((T)) + "Reg"_2^((T)) <= (Omega_1 + Omega_2) / eta + (eta norm(mU)_"op"^2 - 1 / (8 eta)) sum_(t=2)^T ( norm(vx^((t)) - vx^((t-1)))^2 + norm(vy^((t)) - vy^((t-1)))^2 ).
  $
  Since $eta norm(mU)_"op" <= 1\/4$, we have $eta norm(mU)_"op"^2 = (eta norm(mU)_"op")^2 \/ eta <= 1\/(16 eta)$, so the coefficient is at most $1\/(16 eta) - 1\/(8 eta) = -1\/(16 eta)$. By the regret-to-saddle-point-gap identity, $"Reg"_1^((T)) + "Reg"_2^((T)) >= 0$ in a zero-sum game, so $0 <= (Omega_1 + Omega_2)\/eta - 1\/(16 eta) sum_(t=2)^T (dots)$, which rearranges to the claim.

  *Step 2: Small movement implies proximity to a Nash equilibrium.* Suppose that for _every_ $t in {3, dots, T}$,
  $
    norm(vx^((t)) - vx^((t-1)))^2 + norm(vy^((t)) - vy^((t-1)))^2 + norm(vx^((t-1)) - vx^((t-2)))^2 + norm(vy^((t-1)) - vy^((t-2)))^2 > epsilon^2.
  $
  Summing over $t$, every squared distance appears at most twice, so Step 1 gives $(T - 2) epsilon^2 < 32 (Omega_1 + Omega_2)$, contradicting the choice of $T$. Hence there is a $t in {3, dots, T}$ for which all four distances above are at most $epsilon$. We fix such a $t$.

  _The intermediate iterates are close._ Since $vz^((t+1)) = Pi_cX (vz^((t)) + eta vg_x^((t)))$ and $vx^((t)) = Pi_cX (vz^((t)) + eta vg_x^((t-1)))$, nonexpansiveness of the projection gives
  $
    norm(vz^((t+1)) - vx^((t))) <= eta norm(vg_x^((t)) - vg_x^((t-1))) <= eta norm(mU)_"op" norm(vy^((t)) - vy^((t-1))) <= epsilon / 4.
  $
  In the same way, $norm(vx^((t-1)) - vz^((t))) <= epsilon\/4$. By the triangle inequality,
  $ norm(vz^((t+1)) - vz^((t))) <= norm(vz^((t+1)) - vx^((t))) + norm(vx^((t)) - vx^((t-1))) + norm(vx^((t-1)) - vz^((t))) <= (3 epsilon) / 2. $

  _Approximate best response._ The optimality condition of the projection defining $vz^((t+1))$ states that $ip(vz^((t)) + eta vg_x^((t)) - vz^((t+1)), vx' - vz^((t+1))) <= 0$ for every $vx' in cX$. Rearranging and using Cauchy--Schwarz,
  $
    ip(vg_x^((t)), vx' - vz^((t+1))) <= 1 / eta norm(vz^((t+1)) - vz^((t))) norm(vx' - vz^((t+1))) <= (3 epsilon D) / (2 eta).
  $
  Moreover, $ip(vg_x^((t)), vz^((t+1)) - vx^((t))) <= G norm(vz^((t+1)) - vx^((t))) <= G epsilon \/ 4$. Adding the two,
  $
    ip(mU vy^((t)), vx' - vx^((t))) <= epsilon ((3 D) / (2 eta) + G / 4) <= epsilon (2 D / eta + G) quad "for all" vx' in cX.
  $
  The left-hand side is the gain of Player 1 from deviating from $vx^((t))$ against $vy^((t))$. The same argument, with $(vw, vy, vg_y)$ in place of $(vz, vx, vg_x)$, bounds the gain of Player 2. Choosing $epsilon = sqrt(32 (Omega_1 + Omega_2) \/ (T - 2))$ gives the $O_T (1\/sqrt(T))$ rate.
]

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

#lec_bibliography("meta/refs.bib")
