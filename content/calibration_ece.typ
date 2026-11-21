#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  extrathanks: [Expected calibration error section prepared by Ziyue Qiu (`ziyueqiu@mit.edu`).],
)

= Expected calibration error <sec-l15-ece-definition>

A calibrated 70% rain forecast should be followed by rain on about 70% of the days given that forecast. Expected calibration error (ECE) measures the disagreement separately for each forecast value.

Suppose five days are forecast at 20% and five at 80%. It rains on two of the first five days and three of the other five:

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    align: center,
    inset: (x: 6pt, y: 3pt),
    table.header([Forecast], [Days], [Observed rain rate], [Absolute gap]),
    [0.2], [5], [2/5 = 0.4], [0.2],
    [0.8], [5], [3/5 = 0.6], [0.2],
  )
]

For $T>=1$ days, let $p_t in Q$ be the forecast and $y_t in {0,1}$ indicate rain. Forecasts belong to a finite set $Q subset.eq [0,1]$. Let $N_q$ count the days forecast at $q$, and let $overline(y)_q$ be their observed rain rate. Only define this mean when $N_q>0$.

#definition[
  The empirical ECE is
  $
    "ECE"_T := sum_(q in Q: N_q>0) frac(N_q,T) abs(overline(y)_q-q).
  $
] <def-l15-ece>

Each day counts equally, so a forecast used more often has more weight. Here ECE is $(5/10)(0.2)+(5/10)(0.2)=0.2$. The average forecast and overall rain rate are both 50%, but both forecast groups are wrong. Absolute values prevent their opposite errors from cancelling.

= Why deterministic forecasts can fail <sec-ece-impossibility>

#block(breakable: false)[
Let Nature control the outcomes. It knows the forecasting rule and public history, but cannot see the current private random draw. A deterministic forecaster using that history is predictable: Nature can calculate $p_t$ before choosing $y_t$. It can therefore make it rain below 50% and keep the day dry otherwise #citep(<Oakes1985SelfCalibrating>, <Dawid1985CalibrationComment>):
$
  y_t=cases(1 & "if " p_t<1/2, 0 & "if " p_t>=1/2).
$
]

Every occurrence of a forecast $q<1/2$ is followed by rain, so that group's rain rate is 1 and its gap is $1-q>1/2$. Every group with $q>=1/2$ has rain rate 0 and gap $q>=1/2$. Averaging these gaps gives $"ECE"_T>=1/2$ for every $T$. Thus cumulative calibration error $T "ECE"_T>=T/2$ cannot grow sublinearly. Forecasting exactly 50% also fails: Nature keeps it dry, giving gap $1/2$.

Under the same information restriction, instead announce a distribution $D_t$ over forecasts, let Nature choose $y_t$, and privately sample $p_t$ without learning $y_t$. Nature knows $D_t$ but cannot in general infer which forecast is sampled. A suitable strategy must still learn from history; an arbitrary fixed lottery need not be calibrated.

Foster and Vohra show that, for any tolerance $epsilon>0$, a suitable randomized strategy on a sufficiently fine finite grid can achieve $limsup_(T -> infinity) EE["ECE"_T]<=epsilon$ against any Nature following this protocol #citep(<FosterVohra1998Calibration>). The expectation averages over random choices; the grid may depend on $epsilon$. No weather model or stationary outcome process is needed. Calibration ensures agreement with observed frequencies, rather than accurate prediction of each day's weather.

The next section extends these checks to groups defined by context, through multicalibration.

#lec_bibliography("meta/refs.bib")
