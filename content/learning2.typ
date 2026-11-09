#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: "S4",
  date: [Fall 2026],
  title: "Learning algorithms (II)",
)

#let darkblue = blue.darken(20%)

// Proofs expand on the website; PDFs print their complete contents.
#let collapsible-proof(body) = context {
  if target() == "html" {
    html.elem("details", attrs: (
      style: "border:1px solid #aaa;border-radius:4px;padding:12px;margin:16px 0;",
    ))[
      #html.elem("summary", attrs: (style: "cursor:pointer;font-weight:bold;"))[Proof]
      #html.elem("div")[#body]
    ]
  } else {
    body
  }
}

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

#exercise[OMWU as predictive OMD][
  Let $Delta^n := {vx in RR^n_(>=0) : sum_(i=1)^n x_i = 1}$ be the probability simplex, and consider the predictive OMD algorithms defined above with
  - domain $cX := "ri"(Delta^n) = {vx in Delta^n : x_i > 0 " for all " i}$;
  - regularizer the negative entropy $psi(vx) := sum_(i=1)^n x_i log x_i$;
  - a generic stepsize $eta > 0$;
  - initialization $vz^((1)) = vx^((1)) := argmin_(vx in cX) psi(vx) = vone\/n$, the uniform distribution, and initial prediction $vm^((1)) := 0$.

  Let $vg^((1)), vg^((2)), ...$ be the gradient vectors observed by the algorithm, and write $vs^((t)) := sum_(tau=1)^t vg^((tau))$, with $vs^((0)) := 0$. The gradients may depend on the past iterates, as happens when the algorithm plays a game against other learners.

  Recall that _optimistic MWU (OMWU)_ plays $tilde(vx)^((1)) := vone\/n$ and, for $t >= 1$,
  $
    tilde(vx)^((t+1)) := "softmax"(eta vr^((t)) + eta (vr^((t)) - vr^((t-1)))), quad "where" quad vr^((t)) := sum_(tau=1)^t (vg^((tau)) - ip(vg^((tau)), tilde(vx)^((tau))) vone)
  $
  and $vr^((0)) = vr^((-1)) := 0$.

  Prove that, with the optimistic prediction $vm^((t+1)) := vg^((t))$, both the non-reflected and the reflected variants of predictive OMD produce exactly the OMWU iterates, that is, $vx^((t)) = tilde(vx)^((t))$ for all $t >= 1$.

  _Hint:_ First show that for every $vy in "ri"(Delta^n)$ and $vu in RR^n$, the unique maximizer of $ip(vu, vx) - 1 / eta div(vx, vy, dgf: psi)$ over $vx in "ri"(Delta^n)$ is given by $x_i prop y_i e^(eta u_i)$.
]

#solution[
  Throughout, we use two facts. First, $"softmax"(vv)_i := e^(v_i) \/ sum_j e^(v_j)$ is invariant to adding a constant vector, that is, $"softmax"(vv + c vone) = "softmax"(vv)$ for all $c in RR$. Second, if $y_i prop e^(v_i)$ (meaning that $y_i = c e^(v_i)$ for some $c > 0$ independent of $i$) and $vy in Delta^n$, then $vy = "softmax"(vv)$.

  *Step 1 (one entropic OMD step).* Let $vy in "ri"(Delta^n)$ and $vu in RR^n$. Since $nabla psi(vy) = (1 + log y_i)_(i=1)^n$ and $sum_i x_i = sum_i y_i = 1$, for every $vx in "ri"(Delta^n)$,
  $
    div(vx, vy, dgf: psi) = sum_(i=1)^n x_i log x_i - sum_(i=1)^n y_i log y_i - sum_(i=1)^n (1 + log y_i)(x_i - y_i) = sum_(i=1)^n x_i log(x_i / y_i),
  $
  the Kullback--Leibler divergence $"KL"(vx || vy)$. Let $Z := sum_(j=1)^n y_j e^(eta u_j)$ and let $vp$ be defined by $p_i := y_i e^(eta u_i) \/ Z$, so that $vp in "ri"(Delta^n)$ and $eta u_i = log(p_i \/ y_i) + log Z$. Then, using again $sum_i x_i = 1$,
  $
    ip(vu, vx) - 1 / eta div(vx, vy, dgf: psi)
    = 1 / eta sum_(i=1)^n x_i (log(p_i / y_i) + log Z - log(x_i / y_i))
    = 1 / eta (log Z - "KL"(vx || vp)).
  $
  By Gibbs' inequality, $"KL"(vx || vp) >= 0$, with equality if and only if $vx = vp$. Since $vp in "ri"(Delta^n)$ is feasible, the unique maximizer is $vp$, that is, $x_i prop y_i e^(eta u_i)$.

  *Step 2 (non-reflected variant).* We show that $vz^((t)) = "softmax"(eta vs^((t-1)))$ and $vx^((t)) = "softmax"(eta (vs^((t-1)) + vm^((t))))$ for all $t >= 1$ and any predictions $vm^((t))$. By Step 1, the two steps of non-reflected predictive OMD read
  $
    z_i^((t+1)) prop z_i^((t)) exp(eta g_i^((t))), qquad x_i^((t+1)) prop z_i^((t+1)) exp(eta m_i^((t+1))).
  $
  For $vz$, we proceed by induction. The base case $vz^((1)) = vone\/n = "softmax"(0)$ holds because $vs^((0)) = 0$. If $vz^((t)) = "softmax"(eta vs^((t-1)))$, then $z_i^((t+1)) prop exp(eta s_i^((t-1))) exp(eta g_i^((t))) = exp(eta s_i^((t)))$, so $vz^((t+1)) = "softmax"(eta vs^((t)))$. For $vx$, the case $t = 1$ holds because $vx^((1)) = vone\/n$ and $vs^((0)) + vm^((1)) = 0$. For $t >= 1$, substituting the formula for $vz^((t+1))$ gives $x_i^((t+1)) prop exp(eta (s_i^((t)) + m_i^((t+1))))$, so $vx^((t+1)) = "softmax"(eta (vs^((t)) + vm^((t+1))))$.

  *Step 3 (reflected variant).* We show that $vx^((t)) = "softmax"(eta (vs^((t-1)) + vm^((t))))$ for all $t >= 1$ here as well. By Step 1, the reflected update reads $x_i^((t+1)) prop x_i^((t)) exp(eta (g_i^((t)) + m_i^((t+1)) - m_i^((t))))$. The base case $vx^((1)) = vone\/n = "softmax"(eta (vs^((0)) + vm^((1))))$ holds as in Step 2. If $vx^((t)) = "softmax"(eta (vs^((t-1)) + vm^((t))))$, then the predictions telescope:
  $
    x_i^((t+1)) prop exp(eta (s_i^((t-1)) + m_i^((t)))) exp(eta (g_i^((t)) + m_i^((t+1)) - m_i^((t)))) = exp(eta (s_i^((t)) + m_i^((t+1)))),
  $
  so $vx^((t+1)) = "softmax"(eta (vs^((t)) + vm^((t+1))))$.

  *Step 4 (conclusion).* We show $vx^((t)) = tilde(vx)^((t))$ by induction on $t$. Both algorithms start from the uniform distribution. Suppose the iterates coincide up to time $t$. Then both algorithms observe the same gradients $vg^((1)), ..., vg^((t))$, even if these depend on the past iterates. By Steps 2 and 3, with $vm^((t+1)) = vg^((t))$, both predictive OMD variants play
  $
    vx^((t+1)) = "softmax"(eta (vs^((t)) + vg^((t)))).
  $
  On the other hand, by definition of $vr^((t))$, we have $vr^((t)) = vs^((t)) - c_t vone$ and $vr^((t)) - vr^((t-1)) = vg^((t)) - ip(vg^((t)), tilde(vx)^((t))) vone$ for some $c_t in RR$. So the argument of the softmax in the OMWU update is $eta (vs^((t)) + vg^((t)))$ plus a constant multiple of $vone$. By shift invariance of the softmax, $tilde(vx)^((t+1)) = "softmax"(eta (vs^((t)) + vg^((t)))) = vx^((t+1))$.
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
] <thm-learning2-rvu>

#remark[
  A consequence of the previous regret bound is the fact that---assuming $vm^((t)) = vg^((t))$ is _omniscent_---the regret of the learning algorithm _does not grow with time_.]

A similar phenomenon occurs in continuous time, where the learner reacts to the current gradient instantaneously and there is no discretization error.

#exercise[Continuous-time FTRL incurs constant regret][
  Let $cX subset.eq RR^d$ be convex and compact, let $psi : cX -> RR$ be a distance-generating function, $1$-strongly convex with respect to a norm $norm(dot.c)$, and let $eta > 0$. For every $vs in RR^d$, let
  $
    F(vs) := max_(xhat in cX) {ip(vs, xhat) - 1 / eta psi(xhat)}, qquad vx^* (vs) := argmax_(xhat in cX) {ip(vs, xhat) - 1 / eta psi(xhat)},
  $
  where the maximizer is unique by strong convexity of $psi$. Let $vg : [0, oo) -> RR^d$ be a continuous gradient signal, and let $vs(t) := integral_0^t vg(tau) dif tau$. _Continuous-time FTRL_ plays $vx(t) := vx^* (vs(t))$ at every time $t >= 0$, and its regret up to time $T >= 0$ is
  $
    "Reg"(T) := max_(xhat in cX) integral_0^T ip(vg(t), xhat - vx(t)) dif t.
  $
  Prove that, for every $T >= 0$ and every continuous signal $vg$,
  $
    "Reg"(T) <= (max_(xhat in cX) psi(xhat) - min_(xhat in cX) psi(xhat)) / eta.
  $

  _Hint:_ Show that $dif / (dif t) F(vs(t)) = ip(vg(t), vx(t))$. You may use that the maximizer map is continuous; in fact, the stability of FTRL gives $norm(vx^* (vs) - vx^* (vs')) <= eta norm(vs - vs')_*$.
]

#solution[
  *Step 1 (the derivative of the potential).* For any $vs, vs' in RR^d$, the point $vx^* (vs)$ is feasible in the problem defining $F(vs')$, so
  $
    F(vs') >= ip(vs', vx^* (vs)) - 1 / eta psi(vx^* (vs)) = F(vs) + ip(vs' - vs, vx^* (vs)).
  $
  Exchanging the roles of $vs$ and $vs'$ gives $F(vs) >= F(vs') + ip(vs - vs', vx^* (vs'))$. Together,
  $
    ip(vs' - vs, vx^* (vs)) <= F(vs') - F(vs) <= ip(vs' - vs, vx^* (vs')).
  $
  Fix $t >= 0$, apply this with $vs = vs(t)$ and $vs' = vs(t + h)$, and divide by $h != 0$ (the inequalities flip when $h < 0$). As $h -> 0$, the difference quotient $(vs(t + h) - vs(t)) \/ h$ tends to $vg(t)$ by the fundamental theorem of calculus, since $vg$ is continuous, and $vx^* (vs(t + h)) -> vx(t)$ by continuity of $vx^*$ and $vs$. Both bounds therefore tend to $ip(vg(t), vx(t))$, so
  $
    dif / (dif t) F(vs(t)) = ip(vg(t), vx(t)).
  $
  The right-hand side is continuous in $t$, so integrating from $0$ to $T$ gives
  $
    integral_0^T ip(vg(t), vx(t)) dif t = F(vs(T)) - F(vs(0)) = F(vs(T)) + 1 / eta min_(xhat in cX) psi(xhat),
  $
  where we used $vs(0) = 0$ and $F(0) = max_(xhat in cX) {-psi(xhat) \/ eta} = -min_(xhat in cX) psi(xhat) \/ eta$.

  *Step 2 (the regret bound).* Fix any comparator $xhat in cX$. Then $integral_0^T ip(vg(t), xhat) dif t = ip(vs(T), xhat) <= F(vs(T)) + psi(xhat) \/ eta$ by definition of $F$. Subtracting the identity of Step 1,
  $
    integral_0^T ip(vg(t), xhat - vx(t)) dif t <= 1 / eta (psi(xhat) - min_(xhat' in cX) psi(xhat')) <= 1 / eta (max_(xhat' in cX) psi(xhat') - min_(xhat' in cX) psi(xhat')).
  $
  Taking the maximum over $xhat in cX$ proves the claim. For instance, for the negative entropy on the simplex $Delta(A)$, continuous-time FTRL is continuous-time MWU, and the bound reads $"Reg"(T) <= (log |A|) \/ eta$.

  *Proof of the stability bound.* Let $vx := vx^* (vs)$ and $vx' := vx^* (vs')$. The objective $phi_vs (xhat) := ip(vs, xhat) - psi(xhat) \/ eta$ is $(1 \/ eta)$-strongly concave and maximized at $vx$, so $phi_vs (vx) - phi_vs (vx') >= norm(vx - vx')^2 \/ (2 eta)$, and symmetrically $phi_(vs') (vx') - phi_(vs') (vx) >= norm(vx - vx')^2 \/ (2 eta)$. Adding the two inequalities, the $psi$ terms cancel and
  $
    1 / eta norm(vx - vx')^2 <= ip(vs - vs', vx - vx') <= norm(vs - vs')_* norm(vx - vx'),
  $
  which gives $norm(vx - vx') <= eta norm(vs - vs')_*$.

  _Remark._ After dropping its last term, which is nonpositive, the #lecture-link("learning1", <ftrl-omd-regret-bound>)[regret bound for discrete-time FTRL] reads
  $
    "Reg"^((T)) <= B / eta + eta sum_(t=1)^T norm(vg^((t)))_*^2, quad "where" B := max_(xhat in cX) psi(xhat) - min_(xhat in cX) psi(xhat).
  $
  Our bound on $"Reg"(T)$ contains the first term but not the second. The second term arises because the discrete-time learner picks $vx^((t))$ before observing $vg^((t))$, so each decision lags one step behind the gradient it is evaluated on. The continuous-time iterate $vx(t)$ depends on all gradients up to time $t$, so there is no such lag. In particular, $eta$ no longer needs to be tuned to $T$. With bounded gradients, the best choice for discrete-time FTRL is $eta approx 1 \/ sqrt(T)$, which balances the two terms and gives regret of order $sqrt(T)$. The regret of continuous-time FTRL is at most $B \/ eta$ for any $eta > 0$ and all $T$.
]

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

== Accelerated learning of coarse correlated equilibria in general games <sec-fast-cce>

Rates of $tilde(O)(1\/T)$ for coarse correlated and correlated equilibria (CCE)
via learning in normal-form games (and beyond) are also known for the multiplayer case, but
they are significantly harder to prove. One of the main obstacles is due to the fact that
convergence to CCE is driven by the _maximum_ of the regrets of the players, and not the sum as in two-player zero-sum Nash equilibria.

We mention some of the results in this direction.

- #citet(<syrgkanis2015fast>) showed $O(n log |A| T^(-3/4))$ for OMWU using RVU bounds. We prove this bound below.

- This result was later improved by #citet(<chen2020hedging>) to $O(n log^(5/6) |A| T^(-5/6))$ for _two-player_ general-sum games only.

- #citet(<daskalakis2021near>) showed $O(n log |A| (log^4 T) / T)$ convergence for OMWU using a very complicated analysis based on the idea of high-order stability.

- #citet(<farina2022near>) showed $O(n |A| (log T)/T)$ convergence rates using RVU bounds paired with a special regularizer.

#theorem[Accelerated convergence to CCE via OMWU, #citep(<syrgkanis2015fast>)][
  Consider an $n$-player normal-form game with rewards in $[0,1]$ and at most
  $|A|$ actions per player, for $|A| >= 2$. If all players use OMWU with learning rate
  $eta = n^(-1/2) T^(-1/4)$, then the average of the product distributions of
  their strategies over $T$ rounds,
  $
    vmu^((T)) := 1 / T sum_(t=1)^T vx_1^((t)) ⊗ ... ⊗ vx_n^((t)),
  $
  is an $O(n log |A| T^(-3/4))$-CCE.
] <lem-omwu-cce>

#proof[
  We show that the regret of any player, say Player $i$,
  is $O(n^(1/2) log |A| T^(1/4))$, which suffices by
  #lecture-link("learning_intro", <thmce-formal>)[the regret-to-CCE implication].

  Let $vx^((t))$ be the mixed strategy that Player $i$ plays at time $t$,
  which lies in the simplex $cX$. Let $vg^((t))$ be what Player $i$ receives at time $t$,
  which is also the prediction used at time $t+1$ by optimism.
  For each $j != i$, let $vx_j^((t))$ be what Player $j$ plays.
  We assume that for any set of actions from all of the players, Player $i$
  gets a reward in $[0,1]$ (other bounded intervals are analogous).

  We use the $ell_1$ norm for $norm(dot.c)$, and the corresponding dual norm $norm(dot.c)_*$ is the $ell_infinity$ norm. The RVU bounds hold with these norms.

  #lemma[
    For every player we have $norm(vx^((t+1)) - vx^((t))) <= 2 eta$
    for all $t$.
  ] <lem-omwu-stability>

  #collapsible-proof[
    #proof[
      Let $vv$ be $vg^((1)) + vg^((2)) + ... + vg^((t-2)) + 2 vg^((t-1))$
      and let $vv'$ be $vg^((1)) + vg^((2)) + ... + vg^((t-1)) + 2 vg^((t))$.
      Then $vx^((t))$ is a maximizer for
      $F_(vv)(vx) := ip(vv, vx) - psi(vx) / eta$,
      and $vx^((t+1))$ is a maximizer for the similarly defined $F_(vv')(vx)$.

      Since $psi$ is $1$-strongly convex with respect to $norm(dot.c)$
      (see #lecture-link("learning1", <sec-omd-mwu>)[the entropy properties]),
      $F_(vv)$ is $1/eta$-strongly concave.
      Hence
      $
        F_(vv)(vx^((t+1))) &<= F_(vv)(vx^((t)))
        + ip(nabla F_(vv)(vx^((t))), vx^((t+1)) - vx^((t))) \
        &quad - 1/(2 eta) norm(vx^((t+1)) - vx^((t)))^2.
      $
      Since $vx^((t))$ is a maximizer of $F_(vv)$ over the convex set $cX$,
      we have that $ip(nabla F_(vv)(vx^((t))), vx^((t+1)) - vx^((t))) <= 0$.
      Thus we have
      $
        F_(vv)(vx^((t+1))) <= F_(vv)(vx^((t)))
        - 1/(2 eta) norm(vx^((t+1)) - vx^((t)))^2.
      $
      Similarly we have
      $F_(vv')(vx^((t+1))) - F_(vv')(vx^((t))) >= 1/(2 eta) norm(vx^((t+1)) - vx^((t)))^2$.
      Adding these two inequalities and canceling out the $psi(dot.c)$ terms gives
      $
        1/eta norm(vx^((t+1)) - vx^((t)))^2
        &<= ip(vv' - vv, vx^((t+1)) - vx^((t))) \
        &<= norm(vv' - vv)_* norm(vx^((t+1)) - vx^((t))).
      $
      Thus we have
      $
        norm(vx^((t+1)) - vx^((t)))
        &<= eta norm(vv' - vv)_* \
        &= eta norm(2 vg^((t)) - vg^((t-1)))_* <= 2 eta.
      $
    ] <proof-omwu-stability>
  ]

  #lemma[At every time $t$,
    $norm(vg^((t+1)) - vg^((t)))_* <= sum_(j != i) norm(vx_j^((t+1)) - vx_j^((t)))$.
  ] <lem-omwu-utility-variation>
  #collapsible-proof[
    #proof[
      Let $A_(-i)$ be the set of all $(n-1)$-tuples of actions that the players besides Player $i$ can take.
      For a sequence $a_(-i) in A_(-i)$,
      let $p^((t))(a_(-i))$ be the probability of the other players choosing $a_(-i)$ at time $t$.
      Then since the utility from any set of actions is in $[0,1]$,
      $
        norm(vg^((t+1)) - vg^((t)))_*
        <= sum_(a_(-i) in A_(-i)) |p^((t+1))(a_(-i)) - p^((t))(a_(-i))|.
      $
      Note that $p^((t))(a_(-i)) = product_(j != i) x_(j,a_j)^((t))$,
      where $x_(j,a_j)^((t))$ is the probability Player $j$'s mixed strategy
      at time $t$ puts on $a_j$, because the players choose their actions independently.
      It is then a standard fact about total variation that
      $
        sum_(a_(-i) in A_(-i)) lr(|product_(j != i) x_(j,a_j)^((t+1)) - product_(j != i) x_(j,a_j)^((t))|)
        <= sum_(j != i) norm(vx_j^((t+1)) - vx_j^((t))).
      $
      A proof is in, for example, #citet(<kontorovich2024tensorization>), Equation (4).
      It can be proven by induction on $n$ and the triangle inequality.
    ] <proof-omwu-utility-variation>
  ]

  From the
  RVU bound (@thm-learning2-rvu), ignoring the last term because it is always nonpositive, we get
  $
    "Reg"^((T))
    &<= (max_(xhat in cX) (psi(xhat) - psi(vx^((1))))) / eta
      + eta sum_(t=1)^T norm(vg^((t)) - vg^((t-1)))_*^2 \
    &<= (max_(xhat in cX) (psi(xhat) - psi(vx^((1))))) / eta
      + eta sum_(t=1)^T lr((sum_(j != i) norm(vx_j^((t)) - vx_j^((t-1)))))^2 \
    &<= (max_(xhat in cX) (psi(xhat) - psi(vx^((1))))) / eta
      + eta dot T dot ((n-1) dot 2 eta)^2.
  $
  Since $psi$ is negative entropy,
  $max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) <= log |A|$
  (see #lecture-link("learning1", <sec-omd-mwu>)[the entropy properties]).
  Then using $eta = n^(-1/2) T^(-1/4)$ gives
  $"Reg"^((T)) = O(n^(1/2) log |A| T^(1/4))$, as desired.
] <proof-omwu-cce>

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
