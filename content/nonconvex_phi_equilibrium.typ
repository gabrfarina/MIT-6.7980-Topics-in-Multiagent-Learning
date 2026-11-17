
#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

In #lecture-link("correlated", <sec-cce>)[Lecture 3], we introduced coarse correlated equilibrium (CCE) and correlated equilibrium (CE), which generalize Nash equilibrium by allowing distributions over joint strategy profiles. We can further generalize these notions by specifying which strategy modifications a player is allowed to make.

Consider a game with players $i in [n]$, convex and compact strategy sets $cX_i$, and utilities $u_i : cX -> RR$, where $cX = product_(i=1)^n cX_i$. For each player $i$, let $Phi_i$ be a family of deviation functions $phi.alt_i : cX_i -> cX_i$. A distribution $r in Delta(cX)$ is a _$Phi$-equilibrium_ if, for every player $i$,
$
  bb(E)_(vx ~ r) [u_i (vx)]
  >= max_(phi.alt_i in Phi_i) bb(E)_(vx ~ r) [
    u_i (phi.alt_i (vx_i), vx_(-i))
  ].
$
In other words, no player can improve their expected utility by applying any permitted deviation to their recommended strategy. Under standard compactness and continuity assumptions, $Phi$-equilibria exist, since every mixed Nash equilibrium is also a $Phi$-equilibrium.

The familiar equilibrium concepts are recovered by choosing particular deviation families. If $Phi_i$ contains only constant deviations $phi.alt_i (x_i) = x'_i$, we recover CCE, since the player must choose a replacement strategy independently of their recommendation. If $Phi_i$ contains all deviation functions $phi.alt_i : cal(X)_i -> cal(X)_i$, we recover CE, since the player can choose a different response for each recommendation. Note that this implies $"Mixed NE" subset.eq "CE" subset.eq "CCE"$.

This framework also connects directly to the _$Phi$-regret_ introduced in #lecture-link("learning_intro", <sec-phi-regret>)[Lecture 4]. Recall that, given a sequence of strategy profiles $vx^((1)), dots, vx^((T))$, player $i$'s cumulative $Phi_i$-regret is
$
  R_i^((T)) = max_(phi.alt_i in Phi_i)
  sum_(t=1)^T (
    u_i (phi.alt_i (vx_i^((t))), vx_(-i)^((t)))
    - u_i (vx^((t)))
  ).
$
If every player has $R_i^((T)) <= epsilon.alt T$, then the empirical distribution $mu_T = 1/T sum_(t=1)^T delta_(vx^((t)))$ is an $epsilon.alt$-$Phi$-equilibrium, since no permitted deviation improves expected utility by more than $epsilon.alt$. In particular, sublinear $Phi$-regret implies convergence to $Phi$-equilibrium.