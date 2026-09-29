#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 5,
  date: [Tue, Sep 29, 2026],
  title: "Learning in games: Algorithms",
)

The #lecture-link("learning_intro", <sec-learning-applications>)[applications of regret minimization] show how no-external-regret dynamics recover several solution concepts of interest, including Nash equilibria in two-player zero-sum games, normal-form coarse-correlated equilibria in multiplayer general-sum games, and more generally convex-concave saddle point problems.

In this lecture, we begin exploring how no-external-regret dynamics can be constructed, starting from normal-form games.

= No-regret algorithms for normal-form games

For a player in normal-form games the strategy space corresponds to the probability simplex $Delta(A)$ of all distributions over the actions available to the player.
As a reminder, constructing a regret minimizer for $Delta(A)$ means that we need to build a mathematical object that supports two operations:
- `NextStrategy()` asks the regret minimizer to output the next strategy, which is a point $vx^((t)) in Delta(A)$;
- `ObserveUtility`$(u^((t)))$ provides the environment's feedback to the regret minimizer, in the form of a utility function $u^((t))$. For today, we will focus on a case of particular relevance for normal-form games: the case of _linear_ utilities (as such are the utilities in a normal-form game). In particular, to fix notation, we will let
  $
    u^((t)) : vx |-> ip(vg^((t)), vx),
  $
  where $vg^((t)) in RR^n$ is the vector that defines the linear function (called with the letter $vg$ to suggest the idea of it being the "_gradient vector_") and $ip(dot, dot)$ denotes the standard _dot_ product. Since the utility in the game cannot be unbounded, we assume that the $vg^((t))$ can be arbitrary but _bounded in norm_.
In this notation, the (external) _regret_ is defined as the quantity
$
  "Reg"^((T)) := max_(xhat in Delta(A)) {sum_(t=1)^T (ip(vg^((t)), xhat) - ip(vg^((t)), vx^((t))))}.
$
Our goal is to make sure that the regret grows sublinearly in $T$ no matter the utility vectors $vg^((t))$ chosen by the environment.

#box(
  fill: luma(94%),
  inset: 3mm,
  radius: 1.5mm,
)[
  *General principle*. Most algorithms known today for the task operate by _prioritizing actions based on how much regret they have incurred_. In particular, a key quantity to define modern algorithms is the vector of cumulated actions regrets
  $
    vr^((t)) := sum_(tau=1)^t lr(size: #150%, (vg^((tau)) - ip(vg^((tau)), vx^((tau))) vone)).
  $
  (Note that $"Reg"^((t)) = max_(a in A) r^((t))_a$.)
  The natural question is: _how to prioritize?_
]

== Follow-the-leader

Perhaps the most natural idea would be to always play the action with the highest cumulated regret (breaking ties, say, lexicograpsically). After all, this is the action we wish the most we had played in the past. This algorithm is called _follow-the-leader (FTL)_. Unfortunately, this idea is known not to work. To see that, consider the following sequence of gradient vectors:

$
  vg^((1)) = vec(0, 1\/2), quad vg^((2)) = vec(1, 0), quad vg^((3)) = vec(0, 1), quad vg^((4)) = vec(1, 0), quad vg^((
    5
  )) = vec(0, 1), quad #text(font: "New Computer Modern", style: "italic")[etc.]
$

In this case, at time $1$, we pick the first action and score a utility of 0. We then compute
$vr^((1)) = (0, 1\/2)$
and at time $t=2$ pick the second action since it has the highest regret. This results in a score of 0 and an updated regret vector
$vr^((2)) = (1, 1\/2)$
So, at time $t=3$, we will pick the first action, resulting again in a score of 0 and an updated regret
$vr^((3)) = (1, 3\/2)$
and so on...
Overall, it's easy to see that in all this jumping around, the regrets grow linearly.

Where to go from here? A few ideas seem natural:
- We can replace picking the action with the highest regret with picking actions _proportionally_ to their regret; this leads to the algorithm called _Regret Matching_, which we will discuss in @sec-rm.
- We can _smooth out_ the maximum operator by using the _softmax_ function. This leads to the _multiplicative weights update_ algorithm, which we will discuss in @sec-mwu.
- We can _regularize_ the maximum operator by adding a term that penalizes large jumps in the strategy space. This leads to a very flexible algorithm called _follow-the-regularized-leader_ algorithm, which we will discuss in @sec-ftrl as well as in the supplementary reading on #lecture-link("learning2", <sec-predictivity>)[predictive learning algorithms].

All these ideas work. Before we move on, though, it is worth knowing that---while flawed---the follow-the-leader algorithm is not completely hopeless.

#remark[Fictitious play][
  In the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], the use of follow-the-leader by all players goes under the name of _fictitious play_ #citep(<brown1949some>) #citep(<brown1951iterative>). In certain classes of games, including two-player zero-sum games, fictitious play is able to recover a Nash equilibrium, albeit with a potentially exponentially slow convergence rate #citep(<Robinson1951>).
]

== The Regret Matching (RM) algorithm <sec-rm>

The Regret Matching algorithm #citep(<Hart00:Simple>) picks probabilities proportional to the "ReLU" of the cumulated regrets, that is,

#set math.equation(numbering: "(1)")
$
  vx^((t+1)) prop \[vr^((t))\]^+
$ <eq-rm>
#set math.equation(numbering: none)
whenever $\[vr^((t))\]^+ != 0$, and an arbitrary point otherwise.

The algorithm is presented in pseudocode in @algo-rm.

#wrapped-figure(
  [
    #pseudocode-list(numbered-title: [Regret Matching])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *if* $[vr^((t-1))]^+ != 0$
          + *return* $vx^((t)) <- display(([vr^((t-1))]^+) / norm([vr^((t-1))]^+)_1)$
        + *else*
          + *return* $vx^((t)) <-$ any point in $Delta(A)$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone$
    ] <algo-rm>
  ],
  [
    #pseudocode-list(numbered-title: [Regret Matching#super[+]])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *if* $[vr^((t-1))]^+ != 0$
          + *return* $vx^((t)) <- display(([vr^((t-1))]^+) / norm([vr^((t-1))]^+)_1)$
        + *else*
          + *return* $vx^((t)) <-$ any point in $Delta(A)$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- [vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone]^+$
    ] <algo-rmp>
  ],
  side: right,
  text-width: 50%,
)

#theorem[Regret bound for RM][
  The Regret Matching algorithm (@algo-rm) is an external regret minimizer, and satisfies the regret bound $"Reg"^((T)) <= Omega sqrt(T)$, where $Omega$ is the maximum norm of $norm(vg^((t)) - ip(vg^((t)), vx^((t))) vone)_2$ up to time $T$.

  In particular, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ then the regret satisfies $ "Reg"^((T)) <= 2 sqrt(T dot |A|). $
]
#proof[
  We start by observing that, at all times $t$,
  $
    (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)^top vx^((t+1)) = 0
  $
  (this is always true, not just for Regret Matching). Plugging in the definition (@eq-rm) of how $vx^((t+1))$ is constructed, we therefore conclude that
  #set math.equation(numbering: "(1)")
  $
    (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)^top \[vr^((t))\]^+ = 0.
  $ <eqx>
  #set math.equation(numbering: none)
  (Note that the above equation holds trivially when $\[vr^((t))\]^+=0$ and therefore $vx^((t+1))$ is picked arbitrarily.)

  Now, we use the inequality
  $
    norm([va + vb]^+)_2^2 <= norm([va]^+ + vb)_2^2,
  $
  applied to $va = vr^((t))$ and $vb = vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone$. In particular, since by definition $va + vb = vr^((t+1))$, we have
  $
    norm(\[vr^((t+1))\]^+)_2^2 &<= norm(\[vr^((t))\]^+ + (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone))_2^2 \
    &= norm(\[vr^((t))\]^+)_2^2 + norm(vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)_2^2 + 2 (
      vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone
    )^top \[vr^((t))\]^+ \
    &= norm(\[vr^((t))\]^+)_2^2 + norm(vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)_2^2 #h(4.5cm) ("from" (#[@eqx]))\
    &<= norm(\[vr^((t))\]^+)_2^2 + Omega^2.
  $
  Hence, by induction we have
  $
    norm(\[vr^((T))\]^+)_2^2 <= T Omega^2,
  $
  which implies
  $
    "Reg"^((T)) = max_(a in A) r^((T))_a <= max_(a in A) #[~]\[ r^((T))_a \]^+ <= norm(\[vr^((T))\]^+)_2 <= Omega sqrt(T).
  $
  The proof of the first part is then complete. The second part then just follows from using the inequality
  $ Omega = max_(t<=T) norm(vg^((t)) - ip(vg^((t)), vx^((t)))vone)_2 <= 2 sqrt(|A|) max_(t<=T) norm(vg^((t)))_oo. $
  #v(-6mm)
]

Our interest for the regret bound under the specific condition that $norm(vg^((t)))_oo <= 1$ is as follows.
#remark[Within the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], the entries of $vg^((t))$ are the expected payoffs of all actions of the players. Thus, the condition $norm(vg^((t)))_oo <= 1$ corresponds to the condition that the game's payoffs lie in $[-1,1]$.]

As of today, Regret Matching and its variants are still often some of the most practical algorithms for learning in games.

#remark[
  One very appealing property of the Regret Matching algorithm is its _lack of hyperparameters_. It just works "out of the box".
]

== The Regret Matching#super[+] (RM#super[+]) algorithm <sec-rmp>

The Regret Matching#super[+] algorithm #citep(<Tammelin14:Solving>)#citep(<Tammelin15:Solving>) is given in @algo-rmp. It differs from RM only on the last line, where a further thresholding is added. That small change has the effect that actions with negative cumulated regret (that is, "bad" actions) are treated as actions with $0$ regret. Hence, intuitively, if a bad action were to become good over time, it would take less time for RM#super[+] to notice and act on that change.
Because of that, Regret Matching#super[+] has stronger practical performance and is often preferred over Regret Matching in the game solving literature.

With a simple modification to the analysis of RM, the same bound as RM can be proven.
#theorem[Regret bound for RM#super[+]][
  The RM#super[+] algorithm (@algo-rmp) is an external regret minimizer, and satisfies the regret bound $"Reg"^((T)) <= Omega sqrt(T)$, where $Omega$ is the maximum norm $norm(vg^((t)) - ip(vg^((t)), vx^((t))) vone)_2$ up to time $T$.

  So again, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ then the regret satisfies $ "Reg"^((T)) <= 2 sqrt(T dot |A|). $

]

== Multiplicative weights update (MWU) <sec-mwu>

#wrapped-figure(
  [
    If we replace the "hard" maximum of follow-the-leader with the "soft" maximum given by

    $
      x_a^((t+1)) & = "softmax"_(a)(eta vr^((t))) \
                  & := exp(eta r_a^((t))) / (sum_(j=1)^m exp(eta vr^((t))[j])),
    $
    where $eta > 0$ is an inverse temperature parameter, then we obtain the _multiplicative weights update_ algorithm #citep(<freund1997decision>).

    This algorithm is presented in @algo-mwu.
  ],
  [
    #pseudocode-list(numbered-title: [Multiplicative Weights Update])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *return* $vx^((t)) <-$ `softmax`$(eta vr^((t-1)))$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone$
    ] <algo-mwu>
  ],
  side: right,
  text-width: 47%,
)

Compared to RM, MWU has a different flavor: it uses _softmax_ instead of ReLU. This change in prioritization function has a pretty significant impact on the regret bound that multiplicative weights guarantees. In particular, the following can be shown:

#theorem[Regret bound for MWU][
  The regret cumulated by the MWU algorithm can be upper bounded as
  $
    "Reg"^((
      T
    )) <= (log |A|) / eta + eta sum_(t=1)^T norm(vg^((t)))_oo^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_1^2,
  $
  no matter the sequence of gradient vectors $vg^((t))$ chosen by the environment. In particular, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ and $eta = sqrt(log |A|\/ T)$, the regret satisfies

  $ "Reg"^((T)) <= 2 sqrt(T log |A|). $
]<mwu-regret-bound>
The general FTRL/OMD bound in @ftrl-omd-regret-bound implies @mwu-regret-bound; @sec-omd-mwu gives the entropy specialization.

For now, we remark a crucial aspect of MWU. Compared with the regret bound of RM and RM#super[+], the regret bound of MWU has only a _logarithmic_ dependence on the number of actions $|A|$. Despite in practice RM/RM#super[+] tend to outperform MWU (all while getting rid of any hyperparameter tuning), this property has profound _theoretical_ implications, especially in combinatorial games where the effective number of actions is exponential. The gist of it is that several important classes of games can be converted into _exponentially large_ normal-form games (this is the case of sequential games, for example). Since MWU only has logarithmic dependence on the number of actions of the resulting normal-form games, this shows that---at least ignoring computation---external regret minimization is possible with polynomial dependence on the game size even in these classes of complex, structured games.

= More general approaches: FTRL and OMD <sec-ftrl>

Finally, we turn our attention to the third way of obtaining no-regret algorithms, that is, by considering a regularized (i.e., smoothed) version of the follow-the-leader algorithm discussed above. The idea is that, instead of playing by always putting 100% of the probability mass on the action with highest cumulated regret, we look for the distribution that maximizes the expected cumulated regret, _minus_ some regularization term that prevents us from putting all the mass on a single action.

#definition[Distance-generating function for a set][
  A function $psi : cX -> RR$, differentiable on the relative interior, is a _distance-generating function_ if it is $1$-strongly convex with respect to a specified norm. At points where the gradients exist, this means
  $ (nabla psi(vx) - nabla psi(vx'))^top (vx - vx') >= norm(vx - vx')^2 qquad forall vx,vx' in "ri"(cX) $
  with respect to some norm $norm(dot.c)$. Bregman divergences below are evaluated where their second argument is differentiable. Initialize the algorithms at a minimizer of $psi$; for entropy on the simplex this is the uniform distribution.
]

== FTRL in the normal-form case

#definition[FTRL, simplex case][
  Let $psi$ be a distance-generating function for the strategy set $Delta(A)$.
  The follow-the-_regularized_-leader algorithm (FTRL; sometimes also called "regularized follow-the-leader") defines the choice of strategy#footnote[In particular, $vx^((1)) := argmin_(xhat in Delta(A)) psi(xhat)$ since the regrets of all actions are $0$ at the beginning.]
  $
    vx^((t)) & := argmax_(xhat in Delta(A)) {ip(vr^((t-1)), xhat) - 1 / eta psi(xhat)}.
  $]
The regularization term $-psi(xhat)$ _limits the amount of variation between consecutive strategies_. This makes intuitive sense: if $eta -> 0$, $vx^((t))$ is constant (and equal to $argmin_(xhat in Delta(A)) psi(xhat)$). When $eta = oo$, we recover the follow-the-leader algorithm, where strategies can jump arbitrarily. For intermediate $eta$, as you might expect, the amount of variation between strategies at consecutive times is bounded above by a quantity proportional to $eta$:
$
  norm(vx^((t+1)) - vx^((t))) <= eta norm(vg^((t)))_*,
$
where $norm(dot.c)_*$ is the _dual_ norm of $norm(dot.c)$.

We will see the regret bound for FTRL in the general case in @ftrl-omd-general-case.

== OMD in the normal-form case

The last general method that we mention today is the _online mirror descent (OMD)_ algorithm. This is the online generalization of the mirror descent optimization method, one of the workhorses of modern optimization theory. A good way to think about OMD is as a generalization of gradient ascent.

#definition[OMD, simplex case][
  Let $psi : Delta(A) -> RR$ be a distance-generating function. The online mirror descent algorithm (OMD) defines the choice of strategy
  $
    vx^((t)) & := argmax_(xhat in Delta(A)) {ip(vg^((t-1)), xhat) - 1 / eta div(xhat, vx^((t-1)), dgf: psi)},
  $
  where
  $
    div(xhat, vx, dgf: psi) := psi(xhat) - psi(vx) - ip(nabla psi(vx), xhat - vx)
  $
  is called the _Bregman divergence_ associated with $psi$.
]

Two choices of regularizer are standard for the probability simplex:
- The _negative entropy_ function $H(vx) := sum_(a in A) x_a log x_a$. This is 1-strongly convex with respect to the $ell_1$ norm $norm(dot.c)_1$ (and therefore also with respect to $norm(dot.c)_2$). OMD instantiated with this regularizer leads to the multiplicative weights update algorithm seen in @sec-mwu; see also @sec-omd-mwu.

- The _squared Euclidean norm_ $psi(vx) := 1/2 norm(vx)_2^2$, which is 1-strongly convex with respect to the $ell_2$ norm $norm(dot.c)_2$. OMD instantiated with this regularizer leads to the online projected gradient descent algorithm, which we will discuss in @sec-ogd.

== The general case <ftrl-omd-general-case>

FTRL and OMD apply well beyond the case of probability simplices. In fact, they can be applied to any convex and compact domain $cX$. In this case, the vector of regrets $vr^((t))$ must be replaced with the cumulative gradient vector $sum_(tau=1)^t vg^((tau))$, as follows:
#definition[FTRL, general version][
  For a generic convex and compact domain $cX$, the FTRL algorithm produces strategies $vx^((t))$ by solving the optimization problem
  $ vx^((t)) := argmax_(xhat in cX) {ip(sum_(tau=1)^(t-1) vg^((tau)), xhat) - 1 / eta psi(xhat)}. $
]
#definition[OMD, general version][
  For $t>=2$, after initializing $vx^((1))$ as above, the OMD algorithm produces strategies $vx^((t))$ by solving the optimization problem
  $ vx^((t)) := argmax_(xhat in cX) {ip(vg^((t-1)), xhat) - 1 / eta div(xhat, vx^((t-1)), dgf: psi)}. $
]

We also remark the following connection between the two algorithms.

#remark[For linear utilities and a fixed learning rate, FTRL and OMD agree when the mirror updates stay in the interior of the regularizer's domain without additional active constraints. Their dual-coordinate updates then telescope. Entropy on the simplex is an example (working within its affine hull). With additional constraints, the required projections can make the two algorithms different.]

We mention the following regret bound for the general case. The supplementary reading on #lecture-link("learning2", <sec-rvu>)[predictive regret bounds] gives a stronger result when feedback is predictable.

#theorem[Regret bound for FTRL and OMD][
  The regret cumulated by the FTRL and OMD algorithms is upper bounded by
  $
    "Reg"^((
      T
    )) <= B / eta + eta sum_(t=1)^T norm(vg^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2,
  $
  where $B=max_(vx in cX) psi(vx)-min_(vx in cX) psi(vx)$ for FTRL, and $B=max_(vx in cX) div(vx, vx^((1)), dgf: psi)$ for OMD. The latter reduces to the former when the initial minimizer lies in the relative interior. We assume these quantities are finite. As above, $norm(dot.c)_*$ is the dual norm.
  In particular, if the norm of the gradient vectors is bounded, then by picking learning rate $eta = 1/sqrt(T)$, we obtain that $"Reg"^((T))$ is bounded as roughly $sqrt(T)$ (a sublinear function!) at all times $T$.
] <ftrl-omd-regret-bound>

== Multiplicative weights update (MWU) as a special case <sec-omd-mwu>

#wrapped-figure(
  [
    Multiplicative weights update is the special case of _both FTRL and OMD_ in which the regularizer $psi$ is set to the _negative entropy_ function
    $ H(vx) := sum_(a in A) x_a log x_a. $

    #example[
      The adjacent plot displays the negative entropy function in the case of $|A|=2$ actions.
    ]
  ],
  [
    #image(
      "figures/learning1/entropy.svg",
      width: 100%,
      alt: "Negative entropy on a two-action simplex, minimized at the uniform distribution.",
    )
  ],
  side: right,
  text-width: 65%,
)

The negative entropy function has the following properties:
- it is $1$-strongly convex with respect to the $ell_1$ norm $norm(dot.c)_1$;
- the maximum of the function is $0$, attained at any deterministic strategy;
- the minimum is attained at the uniformly random strategy $ overline(vx) = ( 1\/m, ..., 1\/m), $
  at which $H(overline(vx)) = m dot 1/m log 1/m = -log m$.

Plugging the bound above into the general analysis of FTRL and OMD algorithms (@ftrl-omd-regret-bound) yields @mwu-regret-bound.

== Online Projected Gradient Ascent <sec-ogd>

In the special case in which $psi(vx) := 1/2 norm(vx)_2^2$, then the OMD algorithm reduces to _online projected gradient ascent_.

#definition[Online projected gradient ascent][
  The online projected gradient ascent algorithm is the special case of OMD in which the regularizer is (half) the squared Euclidean norm, that is, $psi(vx) = 1/2 norm(vx)_2^2$. The choice of strategy is given by
  $
    vx^((t)) = argmax_(xhat in cX) {
      ip(vg^((t-1)), xhat) - 1 / (2 eta) norm(xhat - vx^((t-1)))_2^2
    } = #text(size: 14pt, $Pi$) _(cX)(vx^((t-1)) + eta vg^((t-1))).
  $
] <def-online-gradient-ascent>

Since the squared Euclidean norm is $1$-strongly convex with respect to the $ell_2$ norm, the regret bound for OGD can be derived from the general bound for OMD (@ftrl-omd-regret-bound) and is as follows.

#theorem[Regret bound for OGD][
  Let $D$ be the Euclidean diameter of $cX$. With any initial point in $cX$, projected gradient ascent satisfies
  $ "Reg"^((T)) <= D^2/(2 eta) + eta/2 sum_(t=1)^T norm(vg^((t)))_2^2. $
  On the simplex, $D <= sqrt(2)$. If $norm(vg^((t)))_oo <= 1$, then $norm(vg^((t)))_2^2 <= |A|$. Choosing $eta=sqrt(2/(T|A|))$ therefore gives
  $ "Reg"^((T)) <= sqrt(2T|A|). $
]<ogd-regret-bound>

The next plots illustrate the behavior of OGD and MWU in a simple $2 times 2$ game.

#example[
  The adjacent plots show the behavior of the online projected gradient ascent (OGD) and multiplicative weights update (MWU) algorithms in the $2 times 2$ game given by
  #wrapped-figure(
    [
      $ U_1 = mat(2, 1; 0, 2). $
      The unique Nash equilibrium of the game is in
      $
        vx^* & = (2/3, 1/3), \
        vy^* & = (1/3, 2/3).
      $
      The purple dot indicates the starting strategy. The gray dotted line tracks the profile of _average_ strategies, which converges to an approximate Nash equilibrium as proved by the #lecture-link("learning_intro", <thm-regret-gap>)[regret-to-equilibrium argument].
    ],
    [
      #image(
        "figures/learning1/ogd_mwu.svg",
        width: 100%,
        alt: "OGD and MWU trajectories in the two-by-two zero-sum game; averages converge to equilibrium.",
      )
    ],
    side: right,
    text-width: 36%,
  )
]

#lec_bibliography("meta/refs.bib")

#changelog[
  - 2025-10-05: Fixed typos (thanks George Cao!).
  - 2025-11-30: Fixed typo in summation $t -> tau$ (thanks Sophie Wang!).
]
