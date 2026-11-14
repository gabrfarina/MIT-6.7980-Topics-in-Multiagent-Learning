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

In this section, we want to connect forecasting and decision-making together. The idea is simple: if we can predict the future well, we can use that prediction to decide what to do. If we knew the future exactly, we would simply play the best action against it. We do not know the future, but we can forecast it, and it turns out that best responding to a good forecast is already enough to guarantee low $Phi$-regret.

Both problems involve an unknown future, but forecasting is the simpler of the two. A forecaster only has to report a prediction and is judged on how well that prediction matches what happens. A decision maker must also commit to an action, and that action has to perform well no matter which future arrives. The reduction in this section shows that, as far as $Phi$-regret is concerned, the harder problem can be solved by solving the easier one.

This suggests a different way to read the results of earlier lectures. Learning dynamics converge to equilibria in many games, and one explanation is that the forecasting problems the players face are tractable. On this view, players can make good decisions because they can make good forecasts.

== Best responding to forecasts <sec-calibration-best-response>

What should the forecaster predict? For a decision maker, the unknown part of the future is the utility vector $vu^((t)) in cU$ that will determine how good each action turns out to be. We therefore forecast utilities: the forecasts live in the same set $cU$ as the utilities themselves, which is why we use the same letter for the forecasting domain and the utility set. Given a forecast, the decision maker plays an action that is optimal for it.

#definition[Best-response map][
  The _best-response map_ $sigma: cU -> cX$ assigns to each forecast utility vector $p in cU$ an action
  $
    sigma(p) in argmax_(vx in cX) ip(vx, p),
  $
  where ties are broken by a fixed rule#footnote[For example, if rock and paper are both
  best responses to $p$, the rule "pick the first action in a fixed order" always returns
  rock. Any rule works, as long as it depends only on $p$: the tests
  $h_phi.alt (p) = phi.alt(sigma(p)) - sigma(p)$ in @sec-calibration-tests are built from
  $sigma$, so $sigma$ must give the same action every time it sees the same forecast.],
  so that $sigma$ is a well-defined function.
] <def-calibration-best-response>

Each round then has three steps. First, the forecaster announces a distribution $D^((t))$ over forecasts of the next utility, and we draw a forecast $p ~ D^((t))$. Second, we play the best response $vx^((t)) = sigma(p)$. Third, we observe the realized utility $vu^((t))$ and pass it to the forecaster as the outcome. 

#figure(
  image("figures/calibration_forecasting_to_learn/best_response_flow.svg", width: 85%,
    alt: "Three boxes connected left to right by arrows: draw a forecast p from D superscript t; play the best response x superscript t equals sigma of p; observe the utility u superscript t."),
  caption: [One round of best responding to a forecast. The forecast distribution $D^((t))$ determines the action distribution $mu^((t))$, the distribution of $sigma(p)$ for $p ~ D^((t))$.],
) <fig-calibration-best-response-flow>

One might expect that acting on a forecast requires some hedging, such as spreading weight over several actions in case the forecast is wrong. It turns out that this is unnecessary: playing the best response to the sampled forecast directly is enough, provided the forecaster is multicalibrated with respect to the right tests (@sec-calibration-tests).

#pseudocode-list(numbered-title: [Forecast-then-best-respond learner])[
  - *Data:* $cal(F)$, a forecaster over $cU$ that is multicalibrated with respect to a set of tests $cH supset.eq cH_Phi$ (@def-calibration-deviation-tests); $sigma$, the best-response map of @def-calibration-best-response.
  + *function* `NextStrategy()`
    - Step 1: ask the forecaster for a distribution over forecasts of the next utility.
    + $D^((t)) <- cal(F)$.`NextForecast()`
    - Step 2: the forecasts determine the action distribution. This is the strategy we announce; Nature may know $mu^((t))$ before choosing $vu^((t))$.
    + $mu^((t)) <-$ distribution of $sigma(p)$ for $p ~ D^((t))$
    - Step 3: draw a forecast privately and best respond to it.
    + sample $p^((t)) ~ D^((t))$
    + *return* $vx^((t)) <- sigma(p^((t)))$
  + *function* `ObserveUtility`$(vu^((t)))$
    - The realized utility is the outcome that the forecaster was trying to predict.
    + $cal(F)$.`ObserveOutcome`$(vu^((t)))$
] <algo:calibration-best-response>

#remark[
 The world may choose $vu^((t))$ adversarially, and it may know $mu^((t))$ when it does so. It does not see the sampled forecast $p^((t))$, and therefore it does not see the action $sigma(p^((t)))$ that we play. Both parts of this protocol matter.

  - _Why the sample stays hidden._ If the world could see $p^((t))$ before choosing $vu^((t))$, it could play against the forecast itself, as in the impossibility example for expected calibration error, and no forecaster could stay calibrated. Keeping the draw private is what avoids that example.
] <rem-calibration-hidden-action>

== Choosing the tests <sec-calibration-tests>

// Check against Task 3 that "MC"_T (h) matches the notation used there.
Best responding is only as good as the forecasts it acts on, and a forecaster is only as good as the tests it is calibrated against. Recall that the multicalibration error of a test $h$ is
$
  "MC"_T (h) = sum_(t=1)^T EE_(p ~ D^((t))) [ip(h(p), vu^((t)) - p)],
$
where the outcome being forecast is now the utility vector $vu^((t))$. The forecaster is $cH$-multicalibrated if $"MC"_T (h) = o(T)$ for every $h in cH$.

Which tests should we ask the forecaster to pass? Since we care about the $Phi$-regret of the actions $sigma(p)$, the natural choice is one test for each deviation $phi.alt in Phi$, measuring how $phi.alt$ would change the action we play.

#definition[Deviation tests][
  For each deviation $phi.alt in Phi$, the _deviation test_ $h_phi.alt : cU -> RR^d$ is
  $
    h_phi.alt (p) := phi.alt(sigma(p)) - sigma(p),
  $
  and the set of deviation tests is $cH_Phi := {h_phi.alt : phi.alt in Phi}$.
] <def-calibration-deviation-tests>

The vector $h_phi.alt (p)$ is the displacement that $phi.alt$ applies to the action we would play on forecast $p$. Its inner product with a utility vector is the gain from deviating: under the realized utility $vu^((t))$, deviation $phi.alt$ would have gained $ip(h_phi.alt (p), vu^((t)))$ over our action. Splitting $vu^((t)) = p + (vu^((t)) - p)$ divides this gain into two parts:
$
  ip(h_phi.alt (p), vu^((t)))
    &= ip(h_phi.alt (p), p + (vu^((t)) - p)) \
    &= underbrace(ip(h_phi.alt (p), p), "predicted gain") + underbrace(ip(h_phi.alt (p), vu^((t)) - p), "forecast error") \
    &= underbrace(ip(phi.alt(sigma(p)), p) - ip(sigma(p), p), <= 0 "by best response") + ip(h_phi.alt (p), vu^((t)) - p)
$
The predicted gain is never positive, because $sigma(p)$ is a best response to $p$ and $phi.alt(sigma(p))$ is just another point of $cX$. Only the error part remains. Calibration against $h_phi.alt$ controls the error part: averaged over time, the forecast errors $vu^((t)) - p$ are not correlated with the direction in which $phi.alt$ would move our action. This is by the definition of multicalibration $"MC"_T (h) = o(T)$. Calibration means that these surprises cancel out over time, playing according to deviation $phi.alt$ may win in some rounds, but its total gain over all $T$ rounds is at most $o(T)$.

#lec_bibliography("meta/refs.bib")
