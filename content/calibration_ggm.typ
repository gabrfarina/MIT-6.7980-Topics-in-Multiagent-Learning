#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
)

// [L15] Section 4 (MD): Recap of Gordon-Greenwald-Marks.
// The header and the bibliography call make this file compile on its own.
// When the sections are merged, keep only the body. Labels are prefixed with
// `ggm-recap` to avoid collisions with the other sections.
// After merging: the "two routes" paragraph can point to the overview figure
// of the introduction (@fig-calibration-intro-overview, PR #188), and "the next
// section" can become a reference to the label of Section 5.

= Recap of Gordon-Greenwald-Marks <sec-ggm-recap>

So far, calibration has been a property of a forecaster. In this section we return to a problem from earlier in the course, $Phi$-regret minimization, because it is solved by the same recipe that we will use for multicalibration:
$
  "external regret minimization" + "a nonlinear optimization primitive".
$
For $Phi$-regret, the primitive is a fixed-point computation, and the resulting algorithm is the reduction of #citet(<gordon2008no>). We recall it below; the full treatment, including the Blum-Mansour algorithm for swap regret, is in #lecture-link("phi_regret", <sec-ggm>)[]. For multicalibration, the primitive will be the solution of an expected variational inequality.

== $Phi$-regret <sec-ggm-recap-phi>

Recall the setting of #lecture-link("learning_intro", <defphirm>)[]. At each time $t$, the learner outputs a strategy $vx^((t))$ in a convex and compact set $cX$ and then observes a linear utility function $u^((t)) : cX -> RR$. Given a set $Phi$ of transformations $phi.alt : cX -> cX$, the learner's $Phi$-regret compares its realized utility with what it would have obtained by applying one fixed transformation to every strategy it played:
$
  Phi"-Reg"^((T)) := max_(hat(phi.alt) in Phi) sum_(t=1)^T (u^((t))(hat(phi.alt)(vx^((t)))) - u^((t))(vx^((t)))).
$
The goal is $Phi"-Reg"^((T)) = o(T)$ for every sequence of utilities. The set $Phi$ determines which counterfactuals the learner is held to, and a larger $Phi$ gives a stronger guarantee. Two choices from #lecture-link("learning_intro", <sec-regret-transformations>)[] will matter in this lecture.

#example[External regret][
  Let $Phi^"const"$ be the set of constant transformations $phi.alt_(hat(vx))(vx) := hat(vx)$, for $hat(vx) in cX$. Then
  $
    Phi"-Reg"^((T)) = max_(hat(vx) in cX) sum_(t=1)^T (u^((t))(hat(vx)) - u^((t))(vx^((t)))),
  $
  which is the external regret $"Reg"^((T))$: every strategy played is compared with the same alternative $hat(vx)$, whatever it was.
] <ex-ggm-recap-external>

#example[Swap regret][
  Let $cX = Delta^n$ and let
  $
    Phi^"swap" := {vx |-> Q vx : Q >= 0, thin vone^top Q = vone^top}
  $
  be the set of column-stochastic matrices. Column $a$ of $Q$ is the distribution onto which the probability mass on action $a$ is rerouted, so different actions can be replaced in different ways. Since $u^((t))$ is linear, the maximum over $Q$ in the definition of $Phi"-Reg"^((T))$ is attained at a matrix whose columns are unit vectors, that is, at a deterministic map $s : {1, ..., n} -> {1, ..., n}$ that replaces each action $a$ with $s(a)$.

  Constant transformations are a special case: for any $hat(vx) in Delta^n$, the matrix $Q = hat(vx) vone^top$ is column-stochastic and sends every $vx in Delta^n$ to $hat(vx)$. Hence $Phi^"const" subset.eq Phi^"swap"$ on the simplex, and swap regret is always at least external regret.
] <ex-ggm-recap-swap>

== The reduction <sec-ggm-recap-reduction>

Competing with every transformation in $Phi$ looks harder than competing with every fixed strategy. #citet(<gordon2008no>) showed that it is not, provided that we can compute fixed points. Their reduction has two ingredients:
+ an external regret minimizer $cR$ whose decision set is $Phi$ itself, which requires $Phi$ to be convex and compact (see #lecture-link("phi_regret", <sec-ggm>)[] for the standing assumptions); and
+ a _fixed-point oracle_ that, given $phi.alt in Phi$, returns some $vx in cX$ with $phi.alt(vx) = vx$.

The $Phi$-regret minimizer operates as follows.
- `NextStrategy()`: ask $cR$ for a transformation $phi.alt^((t)) in Phi$, use the oracle to compute a fixed point $vx^((t)) = phi.alt^((t))(vx^((t)))$, and output $vx^((t))$.
- `ObserveUtility`$(u^((t)))$: pass to $cR$ the utility function
  $
    U^((t))(phi.alt) := u^((t))(phi.alt(vx^((t)))), qquad phi.alt in Phi,
  $
  which scores each transformation by the utility it would have obtained had it been applied to the strategy just played. $U^((t))$ is linear in $phi.alt$, because $u^((t))$ is linear and so is the evaluation map $phi.alt |-> phi.alt(vx^((t)))$.

In words, $cR$ decides which transformation to guard against, and the oracle turns that transformation into a strategy that the transformation cannot improve. This is what makes the two regrets coincide.

#theorem[#citep(<gordon2008no>)][
  If the oracle returns exact fixed points, then for every $T$ the $Phi$-regret of the algorithm above equals the external regret $"Reg"_Phi^((T))$ of $cR$ on the utilities $U^((1)), ..., U^((T))$:
  $
    Phi"-Reg"^((T)) = "Reg"_Phi^((T)).
  $
  In particular, the algorithm is a $Phi$-regret minimizer whenever $cR$ is an external regret minimizer.
] <thm-ggm-recap>

#proof[
  By the definitions of $"Reg"_Phi^((T))$ and $U^((t))$,
  $
    "Reg"_Phi^((T))
      &= max_(hat(phi.alt) in Phi) sum_(t=1)^T (U^((t))(hat(phi.alt)) - U^((t))(phi.alt^((t)))) \
      &= max_(hat(phi.alt) in Phi) sum_(t=1)^T (u^((t))(hat(phi.alt)(vx^((t)))) - u^((t))(phi.alt^((t))(vx^((t))))).
  $
  Since $phi.alt^((t))(vx^((t))) = vx^((t))$, the right-hand side is the definition of $Phi"-Reg"^((T))$.
]

The proof also shows why the fixed point is needed. If $vx^((t))$ were not fixed by $phi.alt^((t))$, then $Phi"-Reg"^((T))$ would exceed $"Reg"_Phi^((T))$ by
$
  sum_(t=1)^T (u^((t))(phi.alt^((t))(vx^((t)))) - u^((t))(vx^((t)))),
$
a term that $cR$ never observes and therefore cannot control. The fixed-point computation is the only nonlinear step of the reduction, and it carries all of its computational difficulty.

#block(breakable: false)[
#remark[Instances and approximate fixed points][
  The reduction specializes as follows, and it degrades gracefully when fixed points are only approximate.
  - For $Phi^"const"$, the fixed point of $phi.alt_(hat(vx))$ is $hat(vx)$ itself. The oracle is trivial, and the reduction plays the strategies of an external regret minimizer over $cX$, as it should.
  - For $Phi^"swap"$, a fixed point of $vx |-> Q vx$ is a stationary distribution of the Markov chain on actions with transition matrix $Q$. It always exists and can be found by solving a linear system. Implementing $cR$ as $n$ independent external regret minimizers, one per column of $Q$, recovers the algorithm of #citet(<blum2007external>), described in #lecture-link("phi_regret").
  - For a general $Phi$ of continuous maps, a fixed point exists by #lecture-link("brouwer")[Brouwer's theorem], but finding one can be hard. This difficulty cannot be avoided: no-$Phi$-regret learning is in general as hard as computing approximate fixed points #citep(<hazan2007computational>). If the oracle only guarantees $norm(phi.alt^((t))(vx^((t))) - vx^((t)))_1 <= epsilon_t$, and the utilities are $u^((t))(vx) = ip(vg^((t)), vx)$ with $norm(vg^((t)))_oo <= C$, the identity of @thm-ggm-recap weakens to
    $
      Phi"-Reg"^((T)) <= "Reg"_Phi^((T)) + C sum_(t=1)^T epsilon_t
    $
    (#lecture-link("phi_regret", <ex-approx-fixed-point>)[]).
]
]

== Looking ahead: two routes to $Phi$-regret <sec-ggm-recap-routes>

The reduction is one instance of a general pattern: an external regret minimizer selects the comparison that currently threatens the learner the most, and a nonlinear primitive neutralizes that comparison in the current round. The multicalibration algorithm of the next section follows the same pattern with different objects. Its external regret minimizer runs over a set of tests $cH$ rather than a set of deviations $Phi$; its primitive is an expected variational inequality rather than a fixed-point computation; and it outputs a distribution over forecasts rather than a strategy. Later in this lecture, best responding to these forecasts gives a second route to $Phi$-regret minimization.

Two differences between the routes are worth keeping in mind. First, the fixed point turns the regret of $cR$ into $Phi$-regret through an exact identity, whereas the expected variational inequality only guarantees an inequality in each round, up to the accuracy of the solver; the forecasting route therefore gives an upper bound with an additive error term, much like the approximate fixed points in the remark above. Second, the forecasting route never computes a fixed point of a map from $cX$ to itself, so it does not need $Phi$ to consist of self-maps whose fixed points we can compute.

// Bibliography: remove when merging into the combined L15 source.
#lec_bibliography("meta/refs.bib")
