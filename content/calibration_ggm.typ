#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
)

// [L15] Section 4 (MD): Recap of Gordon-Greenwald-Marks.
// The header and the bibliography call make this file compile on its own;
// when the sections are merged, keep only the body. Labels are prefixed with
// `ggm-recap`; Section 5 (PR #194) refers to @sec-ggm-recap and @thm-ggm-recap.
// After merging, "the overview figure of the introduction" can become
// @fig-calibration-intro-overview (calibration_intro.typ).

= Recap of Gordon-Greenwald-Marks <sec-ggm-recap>

Multicalibration has the same structure as a problem we have already solved, $Phi$-regret minimization: both reduce to external regret minimization plus a nonlinear optimization primitive. The reduction of #citet(<gordon2008no>), the right-hand route in the overview figure of the introduction, runs an external regret minimizer over the transformations $Phi$ and plays a fixed point of the transformation it chooses. The multicalibration algorithm of the next section runs an external regret minimizer over the tests $cH$ and solves an expected variational inequality to find a distribution over forecasts. For any outcome, the chosen test's expected score is at most a small tolerance. This section recalls the first reduction at a high level; the full treatment is in #lecture-link("phi_regret", <sec-ggm>)[].

== $Phi$-regret <sec-ggm-recap-phi>

Recall the setting of #lecture-link("learning_intro", <defphirm>)[]. At each time $t$, the learner outputs a strategy $vx^((t))$ in a convex and compact set $cX$ and then observes a linear utility function $u^((t)) : cX -> RR$. Given a set $Phi$ of transformations $phi.alt : cX -> cX$, the $Phi$-regret compares the learner's utility with what it would have obtained by applying one fixed transformation to every strategy it played:
$
  Phi"-Reg"^((T)) := max_(hat(phi.alt) in Phi) sum_(t=1)^T (u^((t))(hat(phi.alt)(vx^((t)))) - u^((t))(vx^((t)))).
$
The goal is $Phi"-Reg"^((T)) = o(T)$. The choice of $Phi$ determines the regret notion, and two choices matter in this lecture.

#example[External regret][
  The constant transformations $phi.alt_(hat(vx))(vx) := hat(vx)$, for $hat(vx) in cX$, form the set $Phi^"const"$. Every strategy played is compared with the same alternative $hat(vx)$, and $Phi"-Reg"^((T))$ is the external regret.
] <ex-ggm-recap-external>

#block(breakable: false)[
#example[Swap regret][
  On the simplex $cX = Delta^n$, let $Phi^"swap"$ be the maps $vx |-> Q vx$ with $Q$ column-stochastic, that is, $Q >= 0$ and $vone^top Q = vone^top$. Column $a$ of $Q$ says where the probability mass on action $a$ is rerouted, so each action can be replaced differently. Since $Q = hat(vx) vone^top$ sends every $vx in Delta^n$ to $hat(vx)$, we have $Phi^"const" subset.eq Phi^"swap"$, and swap regret is at least external regret.
] <ex-ggm-recap-swap>
]

== The reduction <sec-ggm-recap-reduction>

#citet(<gordon2008no>) build a $Phi$-regret minimizer from two ingredients:
+ an external regret minimizer $cR$ whose decisions are transformations $phi.alt in Phi$; and
+ a _fixed-point oracle_ that, given $phi.alt in Phi$, returns some $vx in cX$ with $phi.alt(vx) = vx$. Such a point exists whenever $phi.alt$ is continuous, by #lecture-link("brouwer")[Brouwer's theorem].

At each time $t$, the algorithm asks $cR$ for a transformation $phi.alt^((t))$, plays a fixed point $vx^((t)) = phi.alt^((t))(vx^((t)))$, observes $u^((t))$, and passes to $cR$ the linear utility
$
  U^((t))(phi.alt) := u^((t))(phi.alt(vx^((t)))), qquad phi.alt in Phi,
$
which scores each transformation by what it would have earned had it been applied to $vx^((t))$. We assume that the oracle returns exact fixed points efficiently. In words, $cR$ uses past feedback to choose a transformation, and the fixed point leaves that transformation nothing to gain in the current round, whatever $u^((t))$ turns out to be.

#block(breakable: false)[
#theorem[#citep(<gordon2008no>)][
  For every $T$, the $Phi$-regret of this algorithm equals the external regret $"Reg"_Phi^((T))$ of $cR$ on the utilities $U^((1)), ..., U^((T))$:
  $
    Phi"-Reg"^((T)) = "Reg"_Phi^((T)).
  $
  Hence the algorithm has sublinear $Phi$-regret whenever $cR$ has sublinear external regret.
] <thm-ggm-recap>
]

#proof[
  Fix a comparator $hat(phi.alt) in Phi$. By the definition of $U^((t))$ and the fixed-point condition $phi.alt^((t))(vx^((t))) = vx^((t))$,
  $
    U^((t))(hat(phi.alt)) - U^((t))(phi.alt^((t))) = u^((t))(hat(phi.alt)(vx^((t)))) - u^((t))(vx^((t))).
  $
  Summing over $t$ and maximizing over $hat(phi.alt)$ turns the left-hand side into $"Reg"_Phi^((T))$ and the right-hand side into $Phi"-Reg"^((T))$.
]

The fixed point makes the two regrets equal. Without it, $Phi"-Reg"^((T))$ would differ from $"Reg"_Phi^((T))$ by $sum_t (u^((t))(phi.alt^((t))(vx^((t)))) - u^((t))(vx^((t))))$, a term of either sign that the external regret guarantee of $cR$ does not bound. @fig-ggm-recap-fixed-points shows what the oracle returns for the two examples above.

#figure(
  caption: [Fixed points on the simplex over rock, paper and scissors. Each arrow starts at a strategy $vx$ and points along $phi.alt(vx) - vx$, scaled down; the marked point is the oracle's output, where the displacement vanishes. Left: the constant transformation with $hat(vx) = (3\/5, 1\/5, 1\/5)$. Right: the swap transformation $vx |-> Q vx$ whose matrix has columns $(0.4, 0.5, 0.1)$, $(0.1, 0.8, 0.1)$ and $(0.2, 0.3, 0.5)$; its fixed point is the stationary distribution $vx^star = (1\/6, 2\/3, 1\/6)$.],
)[
  #image(
    "figures/calibration_ggm/fixed_points.svg",
    width: 85%,
    alt: "Two triangles representing the simplex over rock, paper and scissors, filled with arrows. Left: all arrows point toward a marked point near rock, the constant comparator. Right: arrows contract toward a marked point near paper, the stationary distribution of the matrix Q.",
  )
] <fig-ggm-recap-fixed-points>

For $Phi^"const"$ the oracle is trivial and the reduction simply plays the strategies chosen by $cR$. For $Phi^"swap"$ the fixed point is a stationary distribution for the column-stochastic matrix $Q$, meaning a probability vector $vx$ satisfying $Q vx = vx$; with one external regret minimizer per column of $Q$, the reduction is the algorithm of #citet(<blum2007external>).

// Bibliography: remove when merging into the combined L15 source.
#lec_bibliography("meta/refs.bib")
