#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  title: "Forecasting and calibration",
)

= Multicalibration <sec-multicalibration>

Sometimes regular calibration is insufficient. Checking how a prediction performs overall may neglect the higher error within specific conditions or tests. For example, say a forecaster predicts a 70% chance of rain on 70 days, 50 weekdays and 20 weekend days. If it rains on 49 days, 40 weekdays and 9 weekend days, it rains on 70% of the days, making the forecaster perfectly calibrated overall. However, the forecaster consistently underpredicts rain on weekdays (80%) and overpredicts it on weekends (45%).

Multicalibration provides a more general framework for evaluating forecasts.#footnote[Multicalibration was introduced by #cite(<pmlr-v80-hebert-johnson18a>, form: "prose").] Rather than examining only the discrepancy between predicted probabilities and observed frequencies, we consider a family of *tests* that can depend on both the forecast and the information available when it was made. Our objective is to ensure that no test in this family detects persistent forecasting errors.

== Multicalibration Protocol <sec-multicalibration-protocol>

Let $cC$ denote the set of possible contexts (information available before making a prediction), and let $cU subset.eq RR^d$ be a compact, convex set containing both forecasts and outcomes. The multicalibration protocol proceeds over rounds $t = 1, 2, ..., T$.

In each round, the following sequence of events occurs:
+ *Observe the context:* observe $c_t in cC$, the information available before forecasting.
+ *Announce a forecast distribution:* announce a probability distribution $D_t$ over forecasts $vp in cU$.
+ *Nature selects an outcome:* Nature chooses the outcome $vu_t in cU$.
+ *Update the forecaster:* observe $vu_t$ and update the learner.

Nature sees $D_t$, but chooses $vu_t$ before seeing the privately sampled forecast. This randomization is important because an adversary that observes the exact forecast can force a deterministic forecaster to be miscalibrated.

== Tests and Multicalibration Error <sec-multicalibration-tests>

#definition[Multicalibration test][
  A _test_ is a bounded, measurable function
  $
    h : cC times cU -> RR^d
  $
  that assigns a vector to each context–forecast pair $(c, vp)$. We denote by $cH$ the family of tests against which we wish to evaluate the forecaster. We can assume that if $cH$ contains $h$, it also contains $-h$.
] <def-multicalibration-test>

A test measures the forecasting error $vu_t - vp$ by assigning a weight or direction $h(c_t, vp)$ to this error. Building on the previous example, a test might assign weight 1 to forecasts made on weekends and weight 0 to forecasts made on weekdays. This would allow us to examine whether the forecaster systematically overpredicts or underpredicts rain on weekends specifically.

#definition[Multicalibration error][
  Given a test $h in cH$, the cumulative multicalibration error over $T$ rounds is
  $
    "MC"_(T)(h) = sum_(t=1)^T EE_(vp ~ D_t)[ip(h(c_t, vp), vu_t - vp)].
  $
] <def-multicalibration-error>

Here, $ip(dot, dot)$ denotes the inner product, and the expectation is over the forecast distribution $D_t$. Less formally, the test selects which errors to measure, while the sum accumulates the expected errors over all rounds.

The goal is to ensure that no test detects a persistent forecasting error. Formally, we want:
$
  sup_(h in cH) "MC"_(T)(h) = o(T).
$
Or that the worst-case cumulative multicalibration error grows sublinearly in $T$, so the maximum average error approaches zero as $T$ increases.

$"MC"_(T)(h)$ is signed, so positive and negative errors can cancel within a test. However, because we assumed that $cH$ also contains $-h$ whenever it contains $h$, bounding the maximum error also bounds $|"MC"_(T)(h)|$ for every test, controlling both overprediction and underprediction.

#example[ECE as a special case of multicalibration][

  Expected calibration error (ECE), introduced in the previous section, is a special case of multicalibration. To see this, consider scalar forecasts from a finite grid $Q subset.eq [0, 1]$, and ignore the context $c$.

  For each forecast value $q in Q$, we can choose a sign $s_q in {-1, 1}$. Define the test
  $
  h_(s)(c, p) = sum_(q in Q) s_q bb(1){p = q}, quad s in {-1, 1}^Q,
  $
  where $bb(1){p = q}$ is 1 when the forecast equals $q$ and 0 otherwise.

  For the observed forecasts, maximizing over these sign tests gives
  $
  1/T max_s sum_(t=1)^T h_(s)(c_t, p_t)(y_t - p_t)
  &= sum_(q in Q) N_q/T |overline(y)_q - q| \
  &= "ECE"_T.
  $

  This works because we can choose each sign to make its forecast bucket's accumulated error nonnegative. Therefore, maximizing over the sign tests recovers exactly the absolute errors used in ECE.

  The key difference is that ECE only considers errors grouped by forecast value, while multicalibration allows more general tests that also depend on context. This lets us detect errors such as the weekday and weekend discrepancies from our earlier example.
] <sec-multicalibration-ece>

#lec_bibliography("meta/refs.bib")
