#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

#note-status[Draft introduction for L15 - work in progress.]

// TODO: Hook

= Calibrated Forecasting

== The weather forecaster

== From calibration to online learning

== Forecasting and no-regret learning

#figure(
  image("figures/calibration_intro/forecasting_regret_overview.svg", width: 100%,
    alt: "Two side-by-side panels. The left panel, Forecasting route, shows an external-regret learner over H above an H-multicalibrated forecaster over U, linked by an expected variational inequality step. The right panel, Gordon-Greenwald-Marks (2008), shows an external-regret learner over Phi above a Phi-regret learner on X with utilities in U, linked by a fixed-point step. A band across the bottom row connects the forecaster to the Phi-regret learner by best response."),
  caption: [Two routes to $Phi$-regret minimization. Each pairs an external-regret learner with a nonlinear optimization step. An expected variational inequality for the forecasting route, and a fixed point for the Gordon--Greenwald--Marks route. Best responding to the forecasts connects the two bottom boxes.],
) <fig-calibration-intro-overview>