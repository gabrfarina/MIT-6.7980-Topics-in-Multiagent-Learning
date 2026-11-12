#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

#note-status[Draft of the "Using forecasting to learn" section (Task 6) - work in progress.]

// Task 6 (MD): Using forecasting to learn.
// Slides 20-26 of slides/L15_calibration_gordon.pdf (on the `live` branch).
// Useful resource: https://ec26-phi-regret-tutorial.github.io/P4-multicalibration.html
//
// Builds on earlier sections (separate files/PRs for now; turn these comments into
// @-references once everything is in one lecture file):
//   - Task 3 Multicalibration: protocol, test h, MC_T(h), goal sup_h MC_T(h) = o(T).
//   - Task 4 GGM recap: Phi-regret definition, #lecture-link("phi_regret", <thm-ggm>).
//   - Task 5 No-regret learning for multicalibration:
//       MC_T(h) <= Reg_{H,T}(h) + sum_t eps_t   (label suggestion: <thm-mc-from-regret>).
// Notation follows content/phi_regret.typ: $cX$, $vx^((t))$, $phi.alt$, $Phi$, $cH$.

= Using forecasting to learn <sec-calibration-to-phi>

// Motivation (slide 20): if the forecast of the next utility is good, we might as
// well best respond to it. Point back to the overview figure (forecasting route,
// bottom arrow "Best response").

If we can predict the future well, we can use that prediction to guide the best action. Forecasting is simpler than decision-making, because in decision-making, we also need to think of an action that is robust against every future. Forecasting is simpler than decision-making.

The fact that we can reach an equilibrium in many games might be a result from the fact that we can predict the future well.

== Best responding to forecasts <sec-calibration-best-response>

#definition[Best-response map][
  For the forecast utility vector $p in cU$, the best response can be chosen by $ sigma(p) in argmax_(vx in cX) ip(vx, p) $with a fixed tie-breaking rule.
] <def-calibration-best-response>

The intuition behind this is that we are building a forecaster for future utility. We forecast the future utility $p tilde D_t$. Then, we select the best action $x = sigma(p)$. Lastly, we observed the real $u_t$ of the world. It turns out that this simple "choose the best action" strategy is very powerful. 

#pseudocode-list(numbered-title: [Forecast-then-best-respond learner])[
  - *Data:* an $cH$-multicalibrated forecaster $cal(F)$; best-response map $sigma$.
  + *function* `NextStrategy()`
    + TODO: obtain $D^((t))$ from $cal(F)$.
    + TODO: announce $mu^((t))$, the distribution of $sigma(p)$ for $p ~ D^((t))$.
    + TODO: sample $p ~ D^((t))$ privately, play $sigma(p)$.
  + *function* `ObserveUtility`$(vu^((t)))$
    + TODO: pass $vu^((t))$ to $cal(F)$ as the realized outcome.
] <algo:calibration-best-response>

#remark[
  TODO: why $mu^((t))$ is announced but the sampled action stays hidden; why playing the
  mean action $EE[sigma(p)]$ can change regret for nonlinear deviations $phi.alt$.
] <rem-calibration-hidden-action>

== Choosing the tests <sec-calibration-tests>

#definition[Deviation tests][
  TODO: for each $phi.alt in Phi$, $h_phi.alt (p) := phi.alt(sigma(p)) - sigma(p)$;
  $cH_Phi := {h_phi.alt : phi.alt in Phi}$. Context-dependent version:
  $h_phi.alt (c, p) = phi.alt(c, sigma(p)) - sigma(p)$.
] <def-calibration-deviation-tests>

// Interpretation: the test measures the direction in which deviation phi would move
// our action; multicalibration w.r.t. h_phi says the forecast error is uncorrelated
// with that direction. Parallel: set of tests <=> set of deviations (GGM).
TODO: interpretation.

== Bounding $Phi$-regret by calibration error <sec-calibration-phi-bound>

#lemma[
  TODO: for every $phi.alt in Phi$, $R_T^Phi (phi.alt) <= "MC"_T (h_phi.alt)$.
] <lem-calibration-phi-by-mc>
#proof[
  TODO: write $R_T^Phi (phi.alt) = sum_t EE_(p ~ D^((t))) ip(h_phi.alt (p), vu^((t)))$,
  add and subtract $p$; the term $ip(h_phi.alt (p), p) =
  ip(phi.alt(sigma(p)), p) - ip(sigma(p), p) <= 0$
  because $sigma(p)$ is a best response and $phi.alt(sigma(p)) in cX$.
]

#theorem[
  TODO: combine with the multicalibration algorithm (Task 5):
  $R_T^Phi (phi.alt) <= "MC"_T (h_phi.alt) <= "Reg"_(cH, T)(h_phi.alt) + sum_t epsilon_t$.
  State conditions under which this is $o(T)$.
] <thm-calibration-phi-regret>
#proof[
  TODO.
]

== Comparison with Gordon-Greenwald-Marks <sec-calibration-vs-ggm>

// Slide 25 table.
#figure(
  table(
    columns: 3,
    align: left,
    table.header[*Ingredient*][*Gordon-Greenwald-Marks*][*Forecasting route*],
    [Learn over], [Deviations $Phi$], [Tests $cH supset.eq cH_Phi$],
    [Optimization step], [Fixed point of $phi.alt^((t))$], [EVI for $h^((t))$],
    [Play], [The fixed point $vx^((t))$], [Best response $sigma(p)$],
    [Regret bound], [Exact identity], [Upper bound + EVI error],
  ),
  caption: [Two routes from external regret to $Phi$-regret.],
) <tab-calibration-vs-ggm>

TODO: discussion (forecasting route needs no geometry of the maps $cX -> cX$).

== Example: swap regret via forecasting (NTH) <sec-calibration-swap-example>

// Nice-to-have. On the simplex $Delta(A)$, phi(x) = Q x for column-stochastic Q.
TODO: write $sigma$ explicitly (best pure action w.r.t. $p$, fixed tie-breaking).
TODO: write $h_Q (p) = Q sigma(p) - sigma(p)$ explicitly; size of $cH$.
TODO: compare with GGM / Blum-Mansour (#lecture-link("phi_regret", <sec-ggm>)[]).

== Summary <sec-calibration-summary>

// Recap of the main ideas of the lecture; reuse the overview figure from the intro
// (content/figures/calibration_intro/forecasting_regret_overview.svg, PR #188).
TODO: recap.

#lec_bibliography("meta/refs.bib")
