#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
)

// [L15] Section 5 (MD): No-regret learning for multicalibration.
// The header and the bibliography call make this file compile on its own.
// When the sections are merged, keep only the body. Labels are prefixed with
// `noregret-mc`. After merging, the prose references below can become labels:
// "the multicalibration section" (protocol, MC error, symmetric families)
//   -> @sec-multicalibration, @sec-multicalibration-protocol (PR #192);
// "the previous section" / Gordon-Greenwald-Marks -> @sec-ggm-recap,
//   @thm-ggm-recap (PR #193);
// "the ECE section" -> @sec-l15-ece-adaptive (PR #181).

= No-regret learning for multicalibration <sec-noregret-mc>

We now build a multicalibrated forecaster with the recipe of #citet(<gordon2008no>) from the previous section, following #citet(<farina2026multicalibration>). An external regret minimizer over the tests $cH$ names the test that currently exposes the forecaster, and an _expected variational inequality_, in the role of the fixed point, neutralizes it in the current round. Throughout, we use the protocol and the multicalibration error $"MC"^((T))(h)$ of the multicalibration section.

== Expected variational inequalities <sec-noregret-mc-evi>

#definition[Expected variational inequality][
  Let $S : cU -> RR^d$ be a bounded, measurable operator and let $epsilon >= 0$. An _$epsilon$-solution to the expected variational inequality (EVI)_ induced by $S$ is a probability distribution $D$ over $cU$ such that
  $
    EE_(vp ~ D)[ip(S(vp), vu - vp)] <= epsilon quad forall vu in cU.
  $
] <def-noregret-mc-evi>

The name and the general theory are due to #citet(<zhang2025expected>). Three features matter here.
- *It holds for every outcome.* The forecaster can solve the EVI before Nature moves and use the guarantee at whichever $vu^((t))$ Nature reveals.
- *It asks for a distribution.* For a point mass, the EVI becomes a classical variational inequality, which a fixed-point argument solves only when $S$ is continuous, and tests usually are not. Against the sign test $S(p) = 1$ if $p < 1\/2$ and $-1$ otherwise, every point mass has value at least $1\/2$, while mass $1\/2$ on each of $1\/2 - delta$ and $1\/2$ has value $delta\/2$. This is the forecast hedging of #citet(<FosterHart2021Hedging>) from the ECE section.
- *We treat the solver as a black box.* Approximate solutions always exist. Run an external regret minimizer over $cU$ for $K$ iterations, feeding it the utility $vp |-> ip(S(vp^((k))), vp)$ after its iterate $vp^((k))$. Then $D$ uniform over $vp^((1)), ..., vp^((K))$ is a $"Reg"^((K))\/K$-solution, by the averaging argument that #lecture-link("learning_intro", <sec-learning-correlated>)[yields coarse correlated equilibria]. It evaluates $S$ only at the iterates, so $S$ need not be continuous.

== The algorithm <sec-noregret-mc-algorithm>

The reduction runs an external regret minimizer $cR_(cH)$ over the tests themselves: the #lecture-link("learning_intro", <def-external-regret>)[definition of a regret minimizer] with $cH$ in place of $cX$, or with its convex hull if $cH$ is not convex.#footnote[Nothing is lost on $conv(cH)$: the utilities fed to $cR_(cH)$ and the error $"MC"^((T))(h)$ are linear in $h$, so their maxima are attained in $cH$.]

#pseudocode-list(numbered-title: [Multicalibration from external regret])[
  + *function* `NextForecast`$(c^((t)))$
    + $h^((t)) <- cR_(cH)$.`NextStrategy()`
    + $S^((t))(vp) := h^((t))(c^((t)), vp)$
    + $D^((t)) <-$ an $epsilon^((t))$-solution to the EVI induced by $S^((t))$
    + *return* $D^((t))$
  + *function* `ObserveUtility`$(vu^((t)))$
    + $cR_(cH)$.`ObserveUtility`$(g^((t)))$, where
      $ g^((t))(h) := EE_(vp ~ D^((t)))[ip(h(c^((t)), vp), vu^((t)) - vp)] $
] <algo-noregret-mc>

#figure(
  caption: [The multicalibration reduction, drawn to mirror the #lecture-link("phi_regret", <fig-ggm>)[Gordon-Greenwald-Marks diagram]: the regret minimizer works over the tests $cH$, and an EVI solver, which also sees the context, turns its output into a distribution over forecasts.],
)[
  #image(
    "figures/calibration_noregret/loop.svg",
    width: 100%,
    alt: "Block diagram of the multicalibration reduction. The outcome u in U enters a utility construction block, which produces a utility g from H to the reals. An external regret minimizer over the tests H outputs a test h, and an EVI solver for the operator S equal to h of c and dot, which also receives the context c, outputs a distribution D over forecasts. The dashed box enclosing the three blocks is the H-multicalibrated forecaster.",
  )
] <fig-noregret-mc-loop>

The utility $g^((t))(h)$ is exactly what round $t$ contributes to $"MC"^((T))(h)$, so the regret minimizer drifts toward the tests that are accumulating error. The EVI then bounds the score of the test it selected: $D^((t))$ is computed before $vu^((t))$ is revealed, but the EVI holds for every outcome, so $g^((t))(h^((t))) <= epsilon^((t))$ for the realized one.

== Sublinear multicalibration error <sec-noregret-mc-analysis>

Let $"Reg"_(cH)^((T))(h) := sum_(t=1)^T (g^((t))(h) - g^((t))(h^((t))))$ be the regret of $cR_(cH)$ against the test $h$.

#theorem[#citep(<farina2026multicalibration>)][
  For every $h in cH$, the forecasts produced by @algo-noregret-mc satisfy
  $
    "MC"^((T))(h) <= "Reg"_(cH)^((T))(h) + sum_(t=1)^T epsilon^((t)).
  $
] <thm-noregret-mc>

#proof[
  Fix $h in cH$. Add and subtract the regret minimizer's own utility, and use $g^((t))(h^((t))) <= epsilon^((t))$ in every round:
  $
    "MC"^((T))(h) = sum_(t=1)^T g^((t))(h)
    = sum_(t=1)^T (g^((t))(h) - g^((t))(h^((t)))) + sum_(t=1)^T g^((t))(h^((t)))
    <= "Reg"_(cH)^((T))(h) + sum_(t=1)^T epsilon^((t)).
  $
]

This is the Gordon-Greenwald-Marks proof, except that the EVI only bounds the leftover term by $epsilon^((t))$ instead of zeroing it, so their identity becomes an inequality.

#corollary[
  If $cR_(cH)$ is an external regret minimizer, so that $max_(h in cH) "Reg"_(cH)^((T))(h) = o(T)$, and the EVIs are solved with $sum_(t=1)^T epsilon^((t)) = o(T)$ (for example $epsilon^((t)) = 1\/sqrt(t)$), then $sup_(h in cH) "MC"^((T))(h) = o(T)$, and hence $sup_(h in cH) |"MC"^((T))(h)| = o(T)$ for the symmetric test families of the multicalibration section.
] <cor-noregret-mc>

The next section best responds to these forecasts and chooses the tests so that $Phi$-regret is at most the multicalibration error. With @thm-noregret-mc, this bounds $Phi$-regret by external regret plus $sum_t epsilon^((t))$, with no fixed point anywhere.

// Bibliography: remove when merging into the combined L15 source.
#lec_bibliography("meta/refs.bib")
