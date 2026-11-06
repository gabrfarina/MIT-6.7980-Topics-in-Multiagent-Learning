#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 15,
  date: [Thu, Nov 5, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  extrathanks: [Expected calibration error section prepared by Ziyue Qiu (`ziyueqiu@mit.edu`).],
)


// The short checks use native disclosure controls in HTML and complete answers in PDF.
#let ece-check(title, question, answer) = context {
  if target() == "html" {
    html.elem("aside", attrs:(class:"ece-check", style:"padding:16px;margin-block:24px;border:1px solid #d7d0c6;border-radius:8px;"))[
      #html.elem("p")[*#title* #question]
      #html.elem("details")[
        #html.elem("summary",attrs:(style:"cursor:pointer;padding:8px 0;font-weight:700;"))[Check your reasoning]
        #answer
      ]
    ]
  } else {
    block(breakable:false,above:6pt,below:6pt,inset:7pt,stroke:.4pt+luma(80%))[
      *#title* #question

      _Answer._ #answer
    ]
  }
}
#let ece-static(body) = context {
  if target() == "html" {
    html.elem("details",attrs:(class:"ece-static"))[
      #html.elem("summary",attrs:(style:"cursor:pointer;padding:12px 0;font-weight:700;"))[Static companion for the PDF]
      #body
    ]
  } else { body }
}

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

#ece-check([Quick check: zero signed bias], [Two equally frequent forecasts are $0.25$ and $0.75$; both buckets have observed frequency $0.50$. The signed bias is zero. What is ECE?], [The two absolute gaps are both $0.25$, so $"ECE"=0.25$. Signed errors cancel; absolute bucket gaps add.]) <check-l15-ece-signed>

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

= Private randomized forecasts <sec-ece-randomization>

To escape @clm-ece-adversary, change the information available to Nature. Let $D_t$ denote the announced distribution over the forecast grid $Q$. The six frames in @fig-l15-ece-protocol follow one example from the visible-forecast obstruction to a private draw and its limitations. Read left to right, then down.

*Two probabilities play different roles.*
If $D_t$ puts probability $1/2$ on each of $0.25$ and $0.75$, the coin chooses _which probability to report_. A draw of $p_t=0.75$ reports a 75% event forecast; the chance of choosing that report was 50%. The coin does not generate the event outcome.

*A hidden coin changes what Nature can do.*
Frames 2--4 have a strict order: announce $D_t$; Nature commits to a hidden $y_t$; privately draw and report $p_t$ without knowing $y_t$; reveal $y_t$ and update the history. Suppose Nature committed to one and the private coin selected $0.75$. The threshold response would require zero, but Nature can no longer switch. Had the coin selected $0.25$, that same committed one would have been the threshold response. The point is that one commitment cannot implement both responses to a draw that has not yet been seen. This removes the preceding impossibility argument while still allowing Nature to react to the history and $D_t$.

Equivalently, the forecast and outcome may be drawn simultaneously, with the appropriate conditional independence. Nature can adapt to the past and observe the current distribution; it cannot condition the outcome on the current realized forecast. A point mass $D_t$ offers no such protection, because it reveals $p_t$ exactly. This protocol is the adaptive-adversary model of #citep(<FosterVohra1998Calibration>, [Section 3]).

#figure(
  image("figures/calibration_ece/ece_information_flow.svg", width: 100%,
    alt: "Six sequential frames. One: if Nature sees forecasts 0.25 or 0.75, it can respond with outcomes 1 or 0, forcing gaps of 0.75. Two: publish a 50-50 distribution over those forecasts and let Nature commit to a hidden outcome first. Three: privately draw forecast 0.75 without learning the outcome. Four: reveal the previously committed outcome 1; Nature cannot now switch to 0. Five: on one four-round trace each bucket receives outcomes 1 and 0, so ECE is 0.25. Six: the unchanged lottery still has expected ECE 0.5 against all-one outcomes; a suitable strategy must use the history."),
  caption: [Why privacy matters, in six frames. The gray diagonals mark agreement between the horizontal and vertical coordinates. Frames 2--3 plot _draw probabilities_; frames 1 and 4 plot outcomes; frames 5--6 plot _bucket frequencies_. Nature may use the announced distribution and history, but commits before seeing the current draw. The four-round record in frame 5 is an illustration, not a calibration guarantee.],
) <fig-l15-ece-protocol>

#block(breakable: false)[
*Watch what can enter each bucket.*
For frame 5, consider the possible four-round recording
$ (p_t,y_t): quad (0.75,1), (0.25,1), (0.75,0), (0.25,0). $
]
Nature can commit to the outcome sequence $(1,1,0,0)$ without seeing the private draws. Each bucket then contains one zero and one one, with frequency $1/2$ and gap $0.25$. The recorded ECE is $0.5 times 0.25+0.5 times 0.25=0.25$. If Nature instead saw each draw and used the threshold response, every $0.25$ forecast would receive one and every $0.75$ forecast zero, giving ECE $0.75$. The private protocol prevents that round-by-round targeting; it does not promise that this balanced record will occur.

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

This states the Foster--Vohra existence result in the finite-resolution $ell_1$ language used here #citep(<FosterVohra1998Calibration>). For this precise excess-error formulation, see #citep(<GuptaRamdas2022Calibration>, [Section 1]). The expectation is over the forecaster's private draws and any randomness of Nature. The later lecture sections develop the general no-regret reductions; the binary example below supplies a separate explicit update rule.

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

== A concrete update from the history <sec-l15-ece-adaptive>

Here is the binary forecast-hedging procedure of #citep(<FosterHart2021Hedging>, [Section V, Theorem 12]). Fix an integer $m>=1$ and grid $Q={0,1/m,...,1}$ with spacing $h=1/m$. Before round $t$, store the past count $N_q$ and positive-outcome count $R_q$ for each bucket. Its _mean error_ is
$ e_q := cases(R_q/N_q-q & "if" N_q>0, 0 & "if" N_q=0). $
Positive means underprediction; negative means overprediction. Use the mean error here, rather than the cumulative residual $N_q e_q$.

+ If some $e_q=0$, choose such a forecast with probability one. This also lets the procedure try unused buckets.
+ Otherwise $e_0>0$ and $e_1<0$, so there are adjacent $a<b$ with $e_a>0>e_b$. Put all next-round mass on these two forecasts:
  $ D_(t)(a)=frac(-e_b,e_a-e_b), quad D_(t)(b)=frac(e_a,e_a-e_b). $
+ Nature commits without seeing the current draw. Privately sample $p_t~D_t$, then observe $y_t$. Update only its bucket: $N_(p_t) <- N_(p_t)+1$ and $R_(p_t) <- R_(p_t)+y_t$. Recompute the errors and distribution next round.

These probabilities choose the _next report_. Historical ECE still uses $N_q/T$ and absolute gaps; changing $D_t$ does not change the recorded data or make ECE zero.

*An update you can calculate by hand.*
Consider this finite initial history on a coarse grid:
#figure(
  table(
    columns: (auto,auto,auto,auto), align: center, inset: 4pt,
    table.header([$q$], [$N_q$], [$R_q$], [$e_q$]),
    [$0$],[$1$],[$1$],[$1$],
    [$0.25$],[$4$],[$3$],[$0.5$],
    [$0.50$],[$4$],[$1$],[$-0.25$],
    [$0.75$],[$1$],[$0$],[$-0.75$],
    [$1$],[$1$],[$0$],[$-1$],
  ),
  caption: [A finite initial history; the adjacent 0.25 and 0.50 buckets bracket zero mean error.],
)
#figure(
  table(columns:(auto,1fr,auto),inset:5pt,align:left,
    table.header([Symbol], [What it describes], [At forecast $0.50$]),
    [$q$, $p_t$], [A bucket's forecast value; the value actually reported this round.], [$0.50$],
    [$y_t$], [This round's binary outcome, chosen before the private draw.], [$0$ or $1$],
    [$overline(y)_q=R_q/N_q$], [The observed event frequency in that bucket's history.], [$1/4=0.25$],
    [$D_(t)(q)$], [The chance of selecting this forecast for the next report.], [$2/3$],
    [$N_q/T$], [The bucket's historical share, used to weight ECE.], [$4/11$],
    [$e_q$], [Observed bucket frequency minus its forecast value.], [$0.25-0.50=-0.25$],
  ),
  caption:[Keep the forecast, the draw chance, the observed rate and the historical weight separate. Numerical entries use the initial history immediately above.],
) <tab-l15-ece-symbols>

The rule gives $D_(t)(0.25)=1/3$ and $D_(t)(0.50)=2/3$, since $(1/3)(0.5)+(2/3)(-0.25)=0$. Suppose the private draw is $0.50$ and the revealed outcome is zero. That bucket now has one positive in five rounds, so its error is $1/5-0.5=-0.3$. The other error remains $0.5$. Thus
$ D_(t+1)(0.25)=frac(0.3,0.5+0.3)=3/8, quad D_(t+1)(0.50)=5/8. $
Another zero made the higher forecast overpredict more, so the next lottery shifts toward the lower forecast. @fig-l15-ece-adaptive shows the update and a longer run.

#figure(
  image("figures/calibration_ece/ece_adaptive.svg", width: 100%,
    alt: "Four panels: normalized errors plus 0.5 and minus 0.25 at adjacent forecasts 0.25 and 0.50; next-draw weights one third and two thirds; after outcome zero at forecast 0.50, its error becomes minus 0.3 and the weights become three eighths and five eighths; sampled checkpoints from a seeded 4000-round run on a finer grid show ECE becoming small with fluctuations."),
  caption: [From past errors to the next lottery. Panels 1--3 use spacing 0.25 and the table's initial history. Panel 4 uses a fresh run with spacing 0.05, PCG64 seed 20261105, and Nature choosing one exactly when the public mean forecast is below 0.65, before the private draw. The curve shows sampled checkpoints; the full run has 1,958 upward ECE steps and ends at 0.0050375. This single trajectory illustrates the rule; it is not the convergence proof.],
) <fig-l15-ece-adaptive>

=== Try the interactive experiment <sec-l15-ece-experiment>

In the #interactive-link("calibration_ece")[interactive experiment], commit an outcome before drawing the next forecast. The learner can see the committed outcome for teaching purposes, but the forecasting rule reads only the history and its frozen lottery. A commitment alone adds no data. A draw updates exactly one bucket.

#context if target() == "html" {
  html.elem("div",attrs:(class:"ece-experiment-embed"))[
    #html.elem("iframe",attrs:(src:"interactive/calibration_ece.html",title:"Interactive ECE experiment: commit, draw and update",loading:"lazy",style:"display:block;width:100%;height:1150px;border:0;",onload:"const f=this;const fit=()=>f.style.height=(f.contentDocument.body.getBoundingClientRect().height+2)+'px';new ResizeObserver(fit).observe(f.contentDocument.body);fit();"))[]
  ]
}

Start with the worked history and inspect the possible next records without changing it. Then choose zero, commit, and draw. @fig-l15-ece-experiment follows one possible draw; the private coin can choose the other forecast instead. The display distinguishes next-draw chances from historical bucket frequencies, and plots ECE together with the root mean square of bucket errors.

#ece-static[
#figure(
  image("figures/calibration_ece/ece_experiment.svg",width:100%,alt:"Two matching experiment states. Before drawing: committed outcome zero, eleven records, ECE0.5227 and next-draw chances one third at0.25 and two thirds at0.50. After one possible draw0.50 with outcome zero: twelve records, ECE0.5208, and new chances three eighths and five eighths; only the0.50 bucket count changes from4 to5."),
  caption:[A static companion to the browser experiment. Committing zero leaves history and ECE unchanged. One possible private draw at $0.50$ then changes its count from four to five, gives $"ECE"_12=25/48$, and recomputes the next lottery to $3/8$, $5/8$. The root mean square is a separate upper bound on the same recorded ECE.],
) <fig-l15-ece-experiment>
]

For a longer experiment, choose an automatic outcome rule and run batches of 100 rounds. Each outcome is decided from public information before a fresh draw. Compare the history update rule with keeping the original lottery fixed, and try always choosing one. Changing the starting history or forecasting rule resets the experiment. The empty-history preset uses spacing $0.05$; the worked preset uses spacing $0.25$. An empty history is displayed as having no observed score. The curves illustrate actual runs, while the theorem supplies the asymptotic expected guarantee.

=== Four possible next records <sec-l15-ece-four-cases>

Balancing the signed errors chooses the next lottery; it does not erase the absolute errors already recorded. To see what actually changes, keep the full initial history above. Write each bucket's _cumulative residual_ as $C_q:=R_q-N_q q=N_q e_q$. Then
$ "ECE"_T=frac(1,T)sum_(q in Q)abs(C_q). $
The selected buckets have $C_(0.25)=2$ and $C_(0.50)=-1$. The other three buckets contribute $1+0.75+1=2.75$ to the absolute sum. Thus the current score is
$ "ECE"_11=frac(abs(2)+abs(-1)+2.75,11)=frac(23,44) approx 0.5227. $
Solving $w(0.5)+(1-w)(-0.25)=0$ gives $w=1/3$; this is why the next-draw probabilities are $1/3$ and $2/3$. They are not the historical weights in ECE.

Nature commits either zero or one before the private draw. For each possible committed outcome, there are two possible draws. Only the drawn bucket changes, by $C_p^+=C_p+(y-p)$; the total count becomes 12 in all four cases.
#figure(
  table(
    columns: (auto,auto,auto,auto,auto), align: center, inset: 5pt,
    table.header([Outcome $y$], [Draw $p$], [Draw chance], [New $C_p$], [New $"ECE"_12$]),
    [$0$],[$0.25$],[$1/3$],[$7/4$],[$11/24 approx 0.4583$],
    [$0$],[$0.50$],[$2/3$],[$-3/2$],[$25/48 approx 0.5208$],
    [$1$],[$0.25$],[$1/3$],[$11/4$],[$13/24 approx 0.5417$],
    [$1$],[$0.50$],[$2/3$],[$-1/2$],[$7/16 approx 0.4375$],
  ),
  caption: [All four next records from the same initial history. Draw chances are conditional on the committed outcome; no probability distribution for Nature's outcome is assumed.],
) <tab-l15-ece-four-cases>
For example, with $p=0.50$ and $y=0$, the residual changes from $-1$ to $-1+(0-0.50)=-1.50$. The new score is $(abs(2)+abs(-1.50)+2.75)/12=25/48$. The absolute-error numerator grew, but the average fell because it is now divided by 12.

For either committed outcome, average over the draw probabilities _after_ computing each branch's ECE:
$ EE["ECE"_12 | y=0]=frac(1,3)frac(11,24)+frac(2,3)frac(25,48)=frac(1,2), $
$ EE["ECE"_12 | y=1]=frac(1,3)frac(13,24)+frac(2,3)frac(7,16)=frac(17,36). $
Both are below the current $23/44$. These are averages over alternative random records; each record still takes absolute values bucket by bucket. Nature cannot choose a different outcome after learning which branch was drawn. One branch, $p=0.25$ with $y=1$, increases ECE. This table establishes a one-step expectation decrease for _this history_; it is not a proof that every history has such a decrease. The distribution must be recomputed after every observed outcome.

#ece-check([Quick check: a rising branch], [One private draw gives $"ECE"_12=13/24>23/44$. Does this disprove the long-run theorem?], [No. A single branch can increase ECE. The theorem bounds a long-run expectation under the stated protocol; it does not promise improvement after every draw.]) <check-l15-ece-branch>

#figure(
  image("figures/calibration_ece/ece_bridge.svg", width: 100%,
    alt: "Top: the two possible forecast draws for each committed outcome give four ECE values. One branch rises above the old ECE 0.5227, while the conditional means 0.5000 and 0.4722 are lower. Bottom: five bucket widths match counts 1,4,4,1,1 and positive heights are absolute mean errors 1,0.5,0.25,0.75,1. The mean absolute gap 0.5227 lies below the weighted root mean square 0.5887."),
  caption: [Two different averages. The upper panel averages complete next-record ECE values using the draw chances $1/3$ and $2/3$. The lower panel uses historical frequency weights $N_q/11$ to compare the mean absolute bucket gap with its root mean square. All four next-record values and both geometric reference levels use the same initial history.],
) <fig-l15-ece-bridge>

=== From squared calibration error to ECE <sec-l15-ece-square-bridge>

The long-run argument tracks squared _bucket mean errors_. Set $w_q=N_q/T$ and recall the squared calibration score $C_(2,T)=sum_q w_q e_q^2$. Define its cumulative form by
$ V_T:=sum_(q in Q)N_q e_q^2=T C_(2,T). $
An empty bucket contributes zero. This is different from the individual prediction loss $T^(-1)sum_t (y_t-p_t)^2$: outcomes are averaged within a bucket _before_ its calibration error is squared.

#block(breakable: false)[
ECE is the weighted mean of the nonnegative gaps $abs(e_q)$; $sqrt(C_(2,T))$ is their weighted root mean square. The latter always bounds the former. One way to see this without allowing signed cancellation is to expand a sum of squares:
$ 0<=sum_(q in Q)w_q (abs(e_q)-"ECE"_T)^2=C_(2,T)-"ECE"_T^2. $
Therefore
$ "ECE"_T^2<=C_(2,T)=V_T/T, quad "ECE"_T<=sqrt(V_T/T). $
Every term on the left of the first display is nonnegative. Large positive and negative bucket errors both contribute positively after squaring.

]

In the same initial history, $V_11=61/16$, so
$ C_(2,11)=61/176 approx 0.3466, quad "ECE"_11=23/44 approx 0.5227 <= sqrt(61/176) approx 0.5887. $
The square root matters: the numerical squared score $0.3466$ is not itself an upper bound on ECE. @fig-l15-ece-bridge connects the four possible records to this geometric bound.

#ece-check([Quick check: take the square root], [Suppose the squared bucket calibration score is $C_(2,T)=0.04$. What upper bound follows for ECE? Must ECE equal that bound?], [We obtain $"ECE"_T<=sqrt(0.04)=0.20$. Equality is not required. The score $0.04$ itself is not the bound supplied by this inequality.]) <check-l15-ece-root>

=== Why the update controls this square <sec-l15-ece-square-drift>

Here is the mathematical link behind the guarantee of #citep(<FosterHart2021Hedging>, [Section V, Theorem 12]). In this paragraph, counts and errors refer to the history before one new round. Expectations condition on that history and any committed outcome $y$, and average only over the private draw $p$. Expanding the selected bucket's new square gives
$ Delta V=2 e_p (y-p)-e_p^2+rho, quad rho:=frac((y-p-e_p)^2,N_p+1). $
For a used bucket, $y-p-e_p=y-R_p/N_p$ lies between minus one and one. For an unused bucket, $e_p=0$ and $abs(y-p)<=1$. Hence $0<=rho<=1/(N_p+1)$ in both cases.

The draw weights were chosen so that $EE[e_p]=0$. Consequently,
$ EE[e_p (y-p)]=y EE[e_p]-EE[e_p p]=-EE[e_p p]. $
The unknown outcome has disappeared from this term. In our numerical example, both possible outcomes give the same value:
$ frac(1,3)(0.5)(y-0.25)+frac(2,3)(-0.25)(y-0.50)=1/24. $
It is this _influence on the new squared total_ that is hedged; the historical absolute gaps are still measured separately.

#block(breakable: false)[
Adjacency controls what remains. Let $z=(a+b)/2$ for the two-point mixture, or $z=p$ when selecting a zero-error bucket. Since $abs(z-p)<=h/2$,
$ EE[e_p (y-p)]=EE[e_p (z-p)] <= (h/2) EE[abs(e_p)]. $
]

#block(breakable: false)[
Combining this with the square update and the elementary bound $h abs(e)-e^2<=h^2/4$ yields
$ EE[Delta V]<=h^2/4+EE[rho]. $
]

The remainder is small _after averaging over time_. Each selection of a bucket contributes at most the next term of its harmonic sum, $1+1/2+1/3+...$. For $K=abs(Q)$ buckets, their combined remainder through $T$ total records is at most $K(1+log T)$, where the logarithm is natural. Keep the grid fixed as $T$ grows.

Allow a finite initial history of size $T_0$ (11 in our example). There are $T-T_0$ new rounds. Summing the conditional bounds gives the convenient estimate
$ EE[V_T/T]<=h^2/4+frac(V_(T_0)+K(1+log T),T). $
The second term vanishes. Finally, applying the ECE bound and then the concavity of the square root,
$ EE["ECE"_T]<=EE[sqrt(V_T/T)]<=sqrt(EE[V_T/T]), $
so
$ limsup_(T -> infinity) EE["ECE"_T] <= h/2. $
Spacing $h=0.05$ gives an asymptotic expected ceiling of $0.025$. A finer grid permits a smaller target error, with more buckets to learn. Neither a single branch nor the expected score after every individual round is guaranteed to improve. The guarantee uses private draws, adjacent grid points, and probabilities recomputed from the current history.

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
