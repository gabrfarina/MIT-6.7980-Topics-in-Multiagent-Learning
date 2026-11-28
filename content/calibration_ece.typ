#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  extrathanks: [Expected calibration error section prepared by Ziyue Qiu (`ziyueqiu@mit.edu`).],
)

= Expected calibration error <sec-l15-ece-definition>

An 80% rain forecast is calibrated if it rains on about 80% of the days given that forecast. Expected calibration error (ECE) measures how far the observed frequencies are from the reported probabilities, checking each forecast value separately.

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

For a record of $T>=1$ days, index the days by $t=1,...,T$. Write $p_t$ for the reported probability of rain and $y_t$ for the outcome: $y_t=1$ means rain and $y_t=0$ means no rain. Assume forecasts come from a finite set $Q subset.eq [0,1]$; here $Q={0.2,0.8}$.

A value $q in Q$ identifies one forecast group. Let $N_q$ count the days with $p_t=q$. If this count is positive, the observed rain rate in that group is
$
  overline(y)_q := frac(1,N_q) sum_(t:p_t=q) y_t.
$
Thus $N_(0.2)=5$ and $overline(y)_(0.2)=2/5=0.4$. The two rows have signed gaps $0.4-0.2=+0.2$ and $0.6-0.8=-0.2$. ECE takes their absolute values before averaging, so these errors do not cancel.

#definition[
  The empirical ECE is
  $
    "ECE"_T := sum_(q in Q: N_q>0) frac(N_q,T) abs(overline(y)_q-q).
  $
] <def-l15-ece>

The weight $N_q/T$ is the fraction of recorded days in that group; unused forecast values are omitted. In the table,
$
  "ECE"_(10) &= frac(5,10) abs(0.4-0.2)+frac(5,10) abs(0.6-0.8) \
    &=0.2.
$
This means a weighted average gap of 20 percentage points between each group's forecast and its observed rain rate. We compare group averages, rather than taking the absolute prediction error on each day. The overall forecast and rain rate are both 50%, but this agreement hides the two group errors.

= Why deterministic forecasts can fail <sec-ece-impossibility>

Suppose Nature controls the outcomes and knows the forecasting rule and all past forecasts and outcomes. Nature must commit to today's outcome before seeing the forecaster's current private random draw. The outcome remains hidden until the forecaster reports its forecast.

A deterministic rule has no private draw: Nature can calculate $p_t$ from the rule and history. It can therefore choose #citep(<Oakes1985SelfCalibrating>, <Dawid1985CalibrationComment>)
$
  y_t=cases(1 & "if " p_t<1/2, 0 & "if " p_t>=1/2).
$

For any used forecast $q<1/2$, every outcome in its group is rain. Its observed rate is therefore 1, giving gap $1-q>1/2$. For $q>=1/2$, every outcome is dry, giving rate 0 and gap $q>=1/2$. In particular, a forecast of exactly $1/2$ has gap $1/2$. Since every group's gap is at least $1/2$ and the weights sum to 1, $"ECE"_T>=1/2$.

Multiplying ECE by $T$ gives the cumulative calibration error. It adds each group's absolute difference between its rainy-day count and its sum of reported rain probabilities. Sublinear growth means this cumulative quantity divided by $T$ tends to zero, equivalently $"ECE"_T -> 0$. Nature's rule instead gives $T "ECE"_T>=T/2$, ruling this out.

Private randomization can prevent Nature from predicting the current report. The forecaster announces a distribution $D_t$ over possible forecasts. Nature commits to $y_t$ using this distribution and the public history, keeping the outcome hidden. The forecaster then privately samples and reports $p_t$ without knowing $y_t$; only then is the outcome revealed.

For example, $D_t$ might assign probability $1/2$ to each of the forecasts 0.2 and 0.8. The $1/2$ is the chance of selecting a forecast; 0.2 or 0.8 is the rain probability reported after selection. These differ from $N_q/T$, which records past usage. Nature cannot tailor its outcome to the current draw. But a fixed fair coin is insufficient: if Nature always chooses rain, both groups have observed rate 1 and their usage fractions approach $1/2$. ECE then approaches $(1/2)(0.8)+(1/2)(0.2)=0.5$. The distribution must adapt to past errors.

#block(breakable: false)[
  Foster and Vohra establish that adaptive randomization can make expected ECE arbitrarily small #citep(<FosterVohra1998Calibration>). For any desired tolerance $epsilon>0$, one can choose a sufficiently fine finite grid of forecast values and a randomized strategy such that, against every Nature obeying this protocol,
  $
    limsup_(T -> infinity) EE["ECE"_T]<=epsilon.
  $
]
The expectation averages over the forecaster's private draws and any random choices made by Nature. The limit superior says that, eventually, expected ECE stays below $epsilon$ plus any positive margin; it need not decrease every day. Smaller tolerances may require finer grids. The earlier two-value lottery is only an illustration; the theorem permits more forecast values, including probabilities near 0 and 1. This existence guarantee requires neither a weather model nor stationarity, even when Nature adapts to the public history. It guarantees agreement with group frequencies, not correct prediction of each day's weather.

The next section extends these checks to groups defined by context, through multicalibration.

#context if target() == "html" {
  link("https://ziyue-l15-ece-preview.qiuzy-william2019.chatgpt.site/interactive/calibration_ece")[Try the interactive experiment]
}

#lec_bibliography("meta/refs.bib")
