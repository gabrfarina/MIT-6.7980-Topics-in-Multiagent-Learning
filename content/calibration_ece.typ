#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 15,
  date: [Thu, Nov 5, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  extrathanks: [Expected calibration error section prepared by Ziyue Qiu (`ziyueqiu@mit.edu`).],
)

How can we check whether probability forecasts agree with what happens? We first measure agreement on a recorded sequence, then ask whether a forecaster can achieve it against an adversarial outcome process. This section follows #citep(<Farina2026CalibrationSlides>, [slides 5--8]).

= Expected calibration error on a finite grid <sec-l15-ece-definition>

A binary event either occurs ($y=1$) or does not ($y=0$). A forecast $p=0.7$ assigns the event probability 70%; it does not assert that the next outcome must be one. _Calibration_ asks whether, among repeated forecasts of 0.7, the event occurs about 70% of the time. A single outcome cannot settle that question.

*Warm-up.*
Suppose ten forecasts all report 0.7. If seven outcomes are one, their observed frequency is $7/10=0.7$ and the empirical calibration gap is zero. If nine are one, the frequency is 0.9 and the absolute gap is $abs(0.9-0.7)=0.2$, or _20 percentage points_. These are descriptions of the observed sample: even a correct probability model can have a nonzero empirical gap in a small sample.

At round $t$, the forecaster reports $p_t$ before observing $y_t in {0,1}$. We evaluate a realized sequence $(p_t,y_t)_(t=1)^T$, with $T>=1$ and forecasts in a finite set $Q subset.eq [0,1]$. A _bucket_ collects all rounds with the same reported probability. For $q in Q$, define
$
  I_q := {t in {1,...,T}: p_t=q}, quad N_q := |I_q|.
$
For a nonempty bucket, let $overline(y)_q := (1/N_q) sum_(t in I_q) y_t$. This is the observed event frequency among rounds assigned forecast $q$. Write $Q_+ := {q in Q: N_q>0}$.

#block(breakable: false)[
#definition[Empirical ECE][
  The frequency-weighted absolute calibration error is
  $
    "ECE"_T := sum_(q in Q_+) frac(N_q,T) abs(overline(y)_q-q)
      = frac(1,T) sum_(q in Q) abs(sum_(t in I_q) (y_t-q)).
  $
  Empty buckets contribute zero through the second expression; their mean outcome need not be defined.
] <def-l15-ece>
]

The formula is a four-step recipe:
+ *Group* the rounds by their reported probability $q$.
+ *Count* the fraction of outcomes equal to one in each bucket, $overline(y)_q$.
+ *Compare* that frequency with $q$, using the absolute gap $abs(overline(y)_q-q)$.
+ *Average* the gaps, weighting each bucket by its share $N_q/T$ of the rounds.

For $N_q>0$, the second expression follows from $sum_(t in I_q)(y_t-q)=N_q (overline(y)_q-q)$. In particular, $0<="ECE"_T<=1$, and ECE is zero exactly when every nonempty bucket has $overline(y)_q=q$.

*Why weight by bucket size?*
Suppose 90 forecasts report 0.5 and have 45 positive outcomes, while ten forecasts report 1 and have no positive outcomes. The two gaps are 0 and 1, but their weights are 0.9 and 0.1. ECE is $0.9 times 0+0.1 times 1=0.1$, rather than the unweighted average $(0+1)/2=0.5$. A uniformly chosen round belongs to the bad bucket only 10% of the time. This also explains why a small ECE can conceal a large gap in a rarely used bucket.

@fig-l15-ece-weighting turns the same 100 rounds into an area picture. Give a bucket width equal to its fraction of rounds and height equal to its absolute gap. Its area is its contribution to ECE; the total shaded area is ECE.
#figure(
  image("figures/calibration_ece/ece_weighting.svg", width: 100%,
    alt: "A population of 100 dots has 90 blue and 10 orange rounds. The blue bucket has 45 positive outcomes and forecast 0.5; the orange bucket has no positive outcomes and forecast 1. In a unit-area picture the blue bucket has width 0.9 and height zero; the orange bucket has width 0.1 and height one. Their total shaded area, ECE, is 0.1."),
  caption: [From counts to area. Each dot is one round; filled dots are positive outcomes. In the unit square, width is bucket weight and height is absolute gap, so the shaded area is ECE 0.1.],
) <fig-l15-ece-weighting>

#remark[What is being averaged?][
  Despite its name, @def-l15-ece is a statistic of the realized data. No additional expectation over a forecaster's randomization is taken here. Also distinguish the normalized error $"ECE"_T$ from the cumulative error $T "ECE"_T$; an $o(T)$ bound on the latter is an $o(1)$ bound on the former.
]

#block[
== Worked example: opposite errors do not cancel <sec-l15-ece-example>

Now consider ten forecasts on $Q={0.2,0.8}$. One possible recording is
$ p=0.2: quad (1,1,0,0,0), quad p=0.8: quad (1,1,1,0,0). $
Each bucket contains five rounds; their order within a bucket does not affect ECE.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center,
    inset: 5pt,
    table.header([$q$], [$N_q$], [Positive outcomes], [$overline(y)_q$], [ECE contribution]),
    [$0.2$], [$5$], [$2$], [$0.4$], [$0.5 times 0.2=0.1$],
    [$0.8$], [$5$], [$3$], [$0.6$], [$0.5 times 0.2=0.1$],
  ),
  caption: [The forecaster underpredicts in the 0.2 bucket and overpredicts in the 0.8 bucket.],
)

The weighted signed error is
$
  frac(1,T) sum_(t=1)^T (y_t-p_t)
  = frac(5,10)(0.4-0.2)+frac(5,10)(0.6-0.8)=0.
$
Nevertheless,
$ "ECE"_T=frac(5,10)abs(0.4-0.2)+frac(5,10)abs(0.6-0.8)=0.2. $
The forecasts and outcomes have the same overall mean, 0.5, but disagree within both buckets. Moving the absolute value outside the sum would conceal these errors.

#figure(
  image("figures/calibration_ece/ece_reliability.svg", width: 100%,
    alt: "Two panels connect the observations to a reliability diagram. The 0.2 forecast bucket contains outcomes 1,1,0,0,0, giving frequency 0.4; the 0.8 bucket contains 1,1,1,0,0, giving frequency 0.6. The diagram plots (0.2,0.4) and (0.8,0.6); each has weight one half and vertical gap 0.2 from the identity diagonal."),
  caption: [From individual outcomes to bucket gaps. In the left panel, each circle is one round; its label is the binary outcome. Both buckets have weight $1/2$ and vertical gap $0.2$ from the diagonal $overline(y)_q=q$, giving ECE $0.2$. Segments are calibration gaps, not confidence intervals.],
) <fig-l15-ece-reliability>
]

To read the diagram, locate a forecast on the horizontal axis and its observed event frequency on the vertical axis. A point _above_ the diagonal means underprediction: the event happened more often than forecast. A point _below_ means overprediction. ECE averages the _vertical_ gaps, with bucket weights; it does not average geometric distances to the line.

#block(breakable: false)[
For any sequence, the triangle inequality gives
$
  abs(frac(1,T)sum_(t=1)^T (y_t-p_t))
  <= frac(1,T)sum_(q in Q)abs(sum_(t in I_q)(y_t-q))
  = "ECE"_T.
$
]
Consequently, low ECE controls the overall signed bias, while low overall bias alone does not control ECE. @exr-l15-ece-telescoping gives an extreme separation.

== Exact buckets and aggregated bins <sec-l15-ece-binning>

The definition above groups _equal forecast values_. When many distinct probabilities are combined into a larger bin $B$, the analogous bin gap compares its mean outcome with its _mean forecast_:
$
  frac(|B|,T)abs(frac(1,|B|)sum_(t in B)y_t-frac(1,|B|)sum_(t in B)p_t)
  = frac(1,T)abs(sum_(t in B)(y_t-p_t)).
$
Using a bin midpoint instead of its mean forecast is a different statistic. Moreover, merging exact buckets can only decrease, or leave unchanged, this mean-forecast statistic: apply $abs(a+b)<=abs(a)+abs(b)$ to their residual sums. In the worked example, merging both buckets gives mean forecast and mean outcome 0.5, and hence zero error for the single aggregate bin. A reported empirical ECE therefore needs its grouping convention. It is also a finite-sample diagnostic, not by itself a certificate of population calibration.

@fig-l15-ece-aggregation compares three summaries of the same ten rounds. Signed gaps give areas above and below zero. Taking an absolute value reflects the negative area upward, so the two areas add rather than cancel. Merging first instead averages away their heights and hides the original gaps.
#figure(
  image("figures/calibration_ece/ece_cancellation.svg", width: 100%,
    alt: "Three geometric stages use bucket widths one half and signed gap heights plus 0.2 and minus 0.2. Their signed areas cancel. Reflecting the orange negative area above zero gives two positive areas of 0.1, totaling ECE 0.2. Merging both buckets instead produces mean gap zero, while the original exact-bucket ECE is still 0.2."),
  caption: [Absolute value as a reflection. Each original bucket has width 1/2 and gap magnitude 0.2, hence area 0.1. ECE adds both areas. Merging before measuring changes the statistic: its gap is zero here, while exact-bucket ECE remains 0.2.],
) <fig-l15-ece-aggregation>

= When Nature sees the forecast <sec-ece-impossibility>

An adversarial process can invalidate calibration if it observes the _actual_ forecast before choosing the outcome. This is the classical impossibility obstruction #citep(<Oakes1985SelfCalibrating>, <Dawid1985CalibrationComment>). The following threshold version is used in the lecture and in #citep(<FosterVohra1998Calibration>, [Section 3]).

The idea is to choose the outcome on the opposite side of the forecast: after a report of 0.2, choose one; after a report of 0.8, choose zero. Repeating a particular forecast then always produces the same contrary outcome, so each bucket stays far from its claimed frequency. The next claim makes this precise for _every_ possible forecast value.

#block(breakable: false)[
#claim[Forecast-observing adversary][
  Suppose Nature observes $p_t$ and then chooses
  $ y_t=cases(1 & "if" p_t<1/2, 0 & "if" p_t>=1/2). $
  For every realized sequence of forecasts and every $T>=1$,
  $ "ECE"_T>=1/2, quad T "ECE"_T>=T/2. $
] <clm-ece-adversary>
]

#proof[
  In any nonempty bucket with $q<1/2$, every outcome is one, so $overline(y)_q=1$ and the gap is $1-q>1/2$. In a bucket with $q>=1/2$, every outcome is zero, so the gap is $q>=1/2$. The bucket weights sum to one; averaging these gaps proves the claim.
]

Thus normalized ECE cannot vanish, and cumulative calibration error cannot be $o(T)$. The distinction matters: normalized ECE is always at most one, so merely calling it _sublinear_ would not express the intended goal. Randomizing does not defeat this adversary if Nature still sees each sampled $p_t$ before responding. For a deterministic forecasting rule, knowing the rule and history already determines that round's forecast.

#block(breakable: false)[
= Private randomized forecasts <sec-ece-randomization>

To escape @clm-ece-adversary, change the information available to Nature. Let $D_t$ denote the announced distribution over the forecast grid $Q$. @fig-l15-ece-protocol compares the order of events in the two models.

#figure(
  image("figures/calibration_ece/ece_information_flow.svg", width: 100%,
    alt: "Two timelines compare information flow. In the first, the forecaster reports p and Nature then chooses y after seeing it. In the second, the forecaster announces distribution D, Nature commits to a hidden outcome y, the forecaster privately samples and reports p from D, and only then is y revealed."),
  caption: [In the lower timeline, Nature commits before seeing the current private draw, while the forecaster does not learn the outcome until after drawing. Nature can still use the history and the announced distribution.],
) <fig-l15-ece-protocol>
]

Equivalently, the forecast and outcome may be drawn simultaneously, with the appropriate conditional independence. Nature can adapt to the past and observe the current distribution; it cannot condition the outcome on the current realized forecast. A point mass $D_t$ offers no such protection, because it reveals $p_t$ exactly. This protocol is the adaptive-adversary model of #citep(<FosterVohra1998Calibration>, [Section 3]).

*A hidden coin changes what Nature can do.*
Suppose $D_t$ selects $p_t=0.25$ or $p_t=0.75$, each with probability $1/2$. The threshold adversary would need to choose $y_t=1$ for the first draw and $y_t=0$ for the second. It now has to commit to one outcome without knowing which draw occurred. This removes the preceding impossibility argument while still allowing Nature to react to the history and $D_t$.

*Randomization alone is not enough.*
Keep that same 50--50 distribution forever, and let Nature always choose $y_t=1$. Every nonempty bucket then underpredicts, so
$ "ECE"_T=frac(1,T)sum_(t=1)^T (1-p_t), quad EE["ECE"_T]=1/2. $
The randomized rule is still poorly calibrated. A calibration theorem must provide a suitably designed forecasting strategy, rather than merely permission to toss a coin.

= Foster--Vohra's positive result <sec-ece-foster-vohra>

The positive result allows us to choose a target precision first and then use a suitable grid and randomized strategy. The expected error _above that precision_ vanishes in the long run.

#block(breakable: false)[
#theorem[Randomized approximate calibration][
  For every tolerance $epsilon>0$, there are a sufficiently fine finite grid $Q_epsilon subset.eq [0,1]$ and a randomized forecasting strategy such that, against every adaptive Nature obeying the protocol above,
  $ lim_(T -> infinity) EE[max("ECE"_T-epsilon,0)]=0. $
  In particular, $limsup_(T -> infinity) EE["ECE"_T]<=epsilon$.
] <thm-ece-foster-vohra>
]

This states the Foster--Vohra existence result in the finite-resolution $ell_1$ language used here #citep(<FosterVohra1998Calibration>). For this precise excess-error formulation, see #citep(<GuptaRamdas2022Calibration>, [Section 1]). The expectation is over the forecaster's private draws and any randomness of Nature. The theorem is stated here; the later lecture sections develop the no-regret reductions, rather than this section reproducing their algorithms.

*Reading the tolerance term.*
Take $epsilon=0.05$. A run with ECE 0.08 has excess $max(0.08-0.05,0)=0.03$; a run with ECE 0.02 has excess zero. The theorem says the _expectation of this excess_ tends to zero as more rounds are played. It does not claim that every finite run has ECE at most 0.05, or that 95% of individual outcomes are predicted correctly. ECE 0.05 describes a weighted average calibration gap of five percentage points.

The original paper uses the weighted squared calibration score
$ C_(2,T):=sum_(q in Q_+) frac(N_q,T)(overline(y)_q-q)^2. $
#block(breakable: false)[
Weighted Cauchy--Schwarz, with weights summing to one, gives the pathwise relation
$ "ECE"_T^2<=C_(2,T), quad "ECE"_T<=sqrt(C_(2,T)). $
]
Thus small squared calibration score also controls the absolute-error score, with a corresponding change of tolerance. The two scores should not be identified numerically.

There are three useful interpretations. First, the outcome process need not be stationary or follow a weather model: Nature may adapt to the history, provided the private draw remains hidden. Second, the target precision is chosen in advance and requires a suitable grid. The theorem does not promise zero ECE on an arbitrarily coarse fixed grid; @exr-ece-grid shows why this qualification matters. Third, calibration alone does not ensure informative forecasts or small prediction loss; @exr-l15-ece-informativeness gives an example. Nor is an asymptotic statement a guarantee of good performance after a small specified number of rounds.

@fig-l15-ece-informativeness illustrates the third point. A constant forecast can match the overall event frequency while ignoring information that would make prediction easier.
#figure(
  image("figures/calibration_ece/ece_informativeness.svg", width: 100%,
    alt: "Equally common contexts A and B always produce zero and one respectively. A constant forecast 0.5 has one reliability point at (0.5,0.5), ECE zero, and mean squared prediction loss one quarter. A context-aware forecast has points at (0,0) and (1,1), ECE zero, and mean squared loss zero."),
  caption: [Both rules are calibrated on the recorded sequence. Contexts A and B occur equally often, with outcomes always 0 in A and 1 in B. Using the context improves squared prediction loss from $1/4$ to $0$, although ECE is zero for both rules.],
) <fig-l15-ece-informativeness>

In cumulative units, @thm-ece-foster-vohra gives
$ EE[T max("ECE"_T-epsilon,0)]=o(T). $
For a fixed positive tolerance it is this _excess_ error that is sublinear; one should not silently delete the grid/tolerance term. Choosing arbitrarily small target tolerances is the sense in which long-run calibration can be made arbitrarily accurate.

#block(breakable: false)[
= Exercises and reference solutions <sec-l15-ece-exercises>

#exercise[Small signed bias can hide maximal ECE][
  Set $y_0=0$ and forecast the previous outcome, $p_t=y_(t-1)$.
  + Show that the average signed error has absolute value at most $1/T$, for every binary outcome sequence.
  + Now let $y_t=1$ for odd $t$ and $y_t=0$ for even $t$. Compute $"ECE"_T$ for every $T>=1$ using $Q={0,1}$.
  + Explain why this forecasting rule solves the simplified signed-error objective on slide 8 but does not ensure calibration.
] <exr-l15-ece-telescoping>
]

#block(breakable: false)[
#solution[
  The signed residual telescopes:
  $ frac(1,T)sum_(t=1)^T (y_t-p_t)=frac(1,T)sum_(t=1)^T (y_t-y_(t-1))=frac(y_T-y_0,T)=frac(y_T,T). $
  Its absolute value is at most $1/T$. On the alternating sequence, every $p_t=0$ is followed by $y_t=1$, while every $p_t=1$ is followed by $y_t=0$. Each nonempty bucket has gap one. Their weights sum to one, so $"ECE"_T=1$, including when $T=1$ and only one bucket is nonempty. For even $T$, the signed error is exactly zero. The global signed objective allows systematic underprediction and overprediction to cancel, whereas ECE tests each forecast bucket separately.
]
]

#block(breakable: false)[
#exercise[Calibration does not imply informativeness][
  There are $2m$ rounds, with $m>=1$. A context $c_t in {A,B}$ is observed before the forecast; each context occurs $m$ times. The outcome is always zero in context $A$ and always one in context $B$.
  + Compute ECE for a forecaster that always reports $p_t=1/2$.
  + Compare with the context-aware rule $p_t=0$ in context $A$ and $p_t=1$ in context $B$. Does ECE distinguish the two rules?
  + Compare their average squared prediction losses, $(1/(2m))sum_(t=1)^(2m) (y_t-p_t)^2$.
] <exr-l15-ece-informativeness>
]

#block(breakable: false)[
#solution[
  The constant forecaster has one bucket with mean outcome $m/(2m)=1/2$, so its ECE is zero. The context-aware rule has buckets $(q,overline(y)_q)=(0,0)$ and $(1,1)$, so its ECE is also zero. The first rule has squared loss $(0-1/2)^2=(1-1/2)^2=1/4$ on every round; the second has zero loss on every round. Both are calibrated, but the second uses information that the first discards. Calibration assesses agreement with frequencies, not every aspect of forecast quality.
]
]

#block(breakable: false)[
#exercise[Why the grid matters][
  Restrict the forecaster to $Q={0,1}$. Outcomes are independent fair coin flips; the next outcome is independent of the history and of the forecaster's current private randomization.
  + Show that $"ECE"_T$ equals the fraction of rounds on which $p_t!=y_t$.
  + Show that $EE["ECE"_T]=1/2$ for every forecasting strategy in this model and every $T>=1$.
  + Explain why this does not contradict @thm-ece-foster-vohra.
] <exr-ece-grid>
]

#block(breakable: false)[
#solution[
  At forecast zero, the absolute residual sum is the number of outcomes equal to one. At forecast one, it is the number of outcomes equal to zero. Their sum counts exactly the mistakes, so $"ECE"_T=T^(-1)sum_(t=1)^T bb(1)_(p_t!=y_t)$. Conditional on the history and the chosen $p_t in {0,1}$, a fair next outcome differs from $p_t$ with probability $1/2$. Linearity of expectation gives $EE["ECE"_T]=1/2$. This remains true for randomized, history-dependent forecasts under the stated independence assumption. @thm-ece-foster-vohra allows a grid chosen for the desired tolerance, rather than requiring a guarantee on this two-point grid.
]
]

#block(breakable: false)[
= References

#lec_bibliography("meta/refs.bib", title: none)
]
