#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

#note-status[Draft introduction for L15 - work in progress.]

In this lecture, we study _forecasting_, predicting uncertain outcomes one round at a time. If a player could predict what every other player is about to do, the natural thing to do would be to best respond to that prediction. This idea is made precise through the notion of _calibration_, and it gives us another route to no-regret learning.

= Calibrated forecasting <sec-calibration-intro>

Every day, a weather forecaster announces a probability of rain, and every day it either rains or it does not. A forecast of 70% does not claim that it will rain, so no single day can prove it wrong. So, we judge the forecaster over many days. In particular, we chose the following metric. Among the days on which the forecaster announced a 70% chance of rain, it should have rained on 70% of them, and the same should hold for every other probability the forecaster announces. A forecaster with this property is said to be _calibrated_.

Calibration was first studied as a way to evaluate forecasters. #cite(<murphy1977reliability>, form: "prose") checked whether the probabilities issued by weather forecasters agreed with the observed frequencies of rain, and #cite(<dawid1982well>, form: "prose") proposed calibration as a general criterion for probability forecasts. In general, can calibration always be achieved? #cite(<Oakes1985SelfCalibrating>, form: "prose") and #cite(<Dawid1985CalibrationComment>, form: "prose") showed that no deterministic forecasting rule can guarantee calibration. For every such rule, there is a sequence of outcomes on which the rule is not calibrated.#footnote[Consider the following: on each day, make it rain if the forecast is below 50%, and keep the day dry otherwise. In this case, every forecast the rule uses is off by at least 50%.] #cite(<FosterVohra1998Calibration>, form: "prose") showed that randomization overcomes this obstacle, by constructing a forecaster that randomizes its forecasts and is approximately calibrated on every sequence of outcomes. This result turned calibration into an online learning problem. A calibrated forecaster must perform well against any sequence of outcomes with no model of how the sequence is generated---much like how a regret minimizer must guarantee low regret against any sequence of utilities, with no assumptions about where they come from.

Calibration alone is enough to guide decisions. #cite(<foster1997calibrated>, form: "prose") showed that if every player in a game best responds to calibrated forecasts of the other players' actions, the empirical distribution of play converges to the set of #lecture-link("correlated", <def-ce>)[correlated equilibria]. In this lecture, we develop this idea into a general forecasting route to $Phi$-regret minimization, and compare it with the reduction of #cite(<gordon2008no>, form: "prose") seen in #lecture-link("phi_regret", <sec-ggm>)[].

#figure(
  image("figures/calibration_intro/forecasting_regret_overview.svg", width: 100%,
    alt: "Two side-by-side panels. The left panel, Forecasting route, shows an external-regret learner over H above an H-multicalibrated forecaster over U, linked by an expected variational inequality step. The right panel, Gordon-Greenwald-Marks (2008), shows an external-regret learner over Phi above a Phi-regret learner on X with utilities in U, linked by a fixed-point step. A band across the bottom row connects the forecaster to the Phi-regret learner by best response."),
  caption: [Two routes to $Phi$-regret minimization. Each arrow turns the algorithm in its starting box into the algorithm in its ending box using the optimization primitive written on the arrow.],
) <fig-calibration-intro-overview>

The route of Gordon, Greenwald, and Marks runs an external-regret learner over the set $Phi$ of transformations, and turns it into a $Phi$-regret learner by computing a fixed point of the learner's current transformation at each round. The forecasting route takes two steps. First, an external-regret learner over a set $cH$ of _tests_, combined with a solver for an _expected variational inequality_ at each round, yields a forecaster of the utilities that is _multicalibrated_ with respect to $cH$. That is, the errors of its forecasts are small as measured by every test in $cH$. Second, a player who best responds to these forecasts has small $Phi$-regret, as long as the tests are chosen to match the transformations in $Phi$.

#lec_bibliography("meta/refs.bib")

