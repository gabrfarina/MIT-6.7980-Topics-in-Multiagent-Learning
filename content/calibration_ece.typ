#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 15,
  date: [Thu, Nov 5, 2026],
  title: "Forecasting and calibration",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  extrathanks: [Expected calibration error section prepared by Ziyue Qiu (`ziyueqiu@mit.edu`).],
)


// Questions stay in the reading flow; answers are printed in Experiment answers.
#let ece-check(title, question, answer-target) = context {
  let body = [*#title* #question

    #link(answer-target)[Answer in Experiment answers]]
  if target() == "html" {
    html.elem("aside", attrs:(class:"ece-check"))[#body]
  } else {
    block(breakable:false,above:6pt,below:6pt,inset:7pt,stroke:.4pt+luma(80%),body)
  }
}
// Reference solutions in the appendix are visible without a reveal control.
#let ece-solution(body) = context {
  if target() == "html" {
    html.elem("section", attrs:(class:"ece-reference-solution"))[#body]
  } else { solution(body) }
}


#let ece-story-box(kind, body) = context {
  if target() == "html" {
    html.elem("div", attrs: (class: "ece-story-" + kind))[#body]
  } else if kind == "insight" {
    block(width: 100%, breakable: false, fill: luma(96%), inset: 7pt, body)
  } else {
    block(width: 100%, breakable: false, body)
  }
}

// The print handout and the expanded web lab share the main text and proof.
#let ece-web(body) = context if target() == "html" { body }
#let ece-print(body) = context if target() != "html" { body }

#let ece-reliability-example = [
In the reliability diagram, points above the diagonal underpredict and points below it overpredict. ECE uses the vertical gaps. By the triangle inequality, ECE bounds the absolute overall signed bias.

#figure(
  image("figures/calibration_ece/ece_reliability.svg", width: 100%,
    alt: "Two panels connect the observations to a reliability diagram. The 0.2 forecast bucket contains outcomes 1,1,0,0,0, giving frequency 0.4; the 0.8 bucket contains 1,1,1,0,0, giving frequency 0.6. The diagram plots (0.2,0.4) and (0.8,0.6); each has weight one half and vertical gap 0.2 from the identity diagonal."),
  caption: [From individual outcomes to bucket gaps. In the left panel, each circle is one round; its label is the binary outcome. Both buckets have weight $1/2$ and vertical gap $0.2$ from the diagonal $overline(y)_q=q$, giving ECE $0.2$. Segments are calibration gaps, not confidence intervals.],
) <fig-l15-ece-reliability>
]

#let ece-privacy-story = [
#figure(
  image("figures/calibration_ece/ece_information_flow.svg", width: 90%,
    alt: "Six sequential frames. One: if Nature sees forecasts 0.25 or 0.75, it can respond with outcomes 1 or 0, forcing gaps of 0.75. Two: publish a 50-50 distribution over those forecasts and let Nature commit to a hidden outcome first. Three: privately draw forecast 0.75 without learning the outcome. Four: reveal the previously committed outcome 1; Nature cannot now switch to 0. Five: on one four-round trace each bucket receives outcomes 1 and 0, so ECE is 0.25. Six: the unchanged lottery still has expected ECE 0.5 against all-one outcomes; a suitable strategy must use the history."),
  caption: [Why privacy matters, in six frames. The gray diagonals mark agreement between the horizontal and vertical coordinates. Frames 2--3 plot _draw probabilities_; frames 1 and 4 plot outcomes; frames 5--6 plot _bucket frequencies_. Nature may use the announced distribution and history, but commits before seeing the current draw. The four-round record in frame 5 is an illustration, not a calibration guarantee.],
) <fig-l15-ece-protocol>
]

A forecaster reports a 20% chance of rain on five days and an 80% chance on five other days. The average forecast is 50%, and it rains on five of the ten days. Is the forecaster calibrated? To answer, we need to check the days assigned each probability separately. Once we can score that record, we can ask what happens when Nature chooses the outcomes. This section follows #citep(<Farina2026CalibrationSlides>, [slides 5--8]).

= Expected calibration error on a finite grid <sec-l15-ece-definition>

Calibration compares forecasts with observed frequencies. On ten days forecast at 70%, seven rainy days give a gap of zero and nine give a gap of 20 percentage points. Even a calibrated forecaster can show a gap in a small sample.

At round $t$, report $p_t$ before observing $y_t$, where $y_t=1$ means rain and $y_t=0$ means a dry day. We evaluate a realized sequence $(p_t,y_t)_(t=1)^T$, with $T>=1$ and forecasts in a finite set $Q subset.eq [0,1]$. A _bucket_ collects all rounds with the same reported probability. For $q in Q$, define
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

Group equal forecasts, find each bucket's absolute gap, and average those gaps by bucket size. Multiplying a bucket's mean gap by its count gives the second expression. ECE is zero when every used bucket's observed frequency matches its forecast.

#ece-web[
#remark[What is being averaged?][
  Despite its name, @def-l15-ece is a statistic of the realized data. No additional expectation over a forecaster's randomization is taken here. Also distinguish the normalized error $"ECE"_T$ from the cumulative error $T "ECE"_T$; an $o(T)$ bound on the latter is an $o(1)$ bound on the former.
]
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

#ece-print(ece-reliability-example)
]

= When Nature sees the forecast <sec-ece-impossibility>

An adversarial process can invalidate calibration if it observes the _actual_ forecast before choosing the outcome. This is the classical impossibility obstruction #citep(<Oakes1985SelfCalibrating>, <Dawid1985CalibrationComment>). The following threshold version is used in the lecture and in #citep(<FosterVohra1998Calibration>, [Section 3]).

Return to the 20% and 80% buckets. Suppose Nature sees each new forecast and can decide whether it rains. It can make it rain on every 20% day and keep every 80% day dry. The observed rates become 100% and 0%, giving an 80 percentage point gap in each bucket. The claim below extends this argument to any forecast grid.

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

With this response rule, Nature can force cumulative error to grow at least linearly when it sees each draw.

= Private randomized forecasts <sec-ece-randomization>

Now announce the distribution $D_t$ over forecasts while keeping the draw private.

*Two probabilities.* For this example, switch to a coin that selects 25% or 75% with equal chance. Drawing 75% reports a 75% chance of rain. The chance of selecting that report was 50%.

*Who commits first?* Nature can use the history and $D_t$ to commit to $y_t$. The forecaster draws $p_t$ without seeing $y_t$, then observes the outcome. The same commitment applies to either draw #citep(<FosterVohra1998Calibration>, [Section 3]).

#ece-print(ece-privacy-story)

With an unchanged 50--50 lottery, all-rain outcomes still give ECE 0.5. Which forecasts we draw must change with the history.

= Foster--Vohra's positive result <sec-ece-foster-vohra>

#block(breakable: false)[
#theorem[Randomized approximate calibration][
  For every tolerance $epsilon>0$, there are a sufficiently fine finite grid $Q_epsilon subset.eq [0,1]$ and a randomized forecasting strategy such that, against every adaptive Nature obeying the protocol above,
  $ lim_(T -> infinity) EE[max("ECE"_T-epsilon,0)]=0. $
  In particular, $limsup_(T -> infinity) EE["ECE"_T]<=epsilon$.
] <thm-ece-foster-vohra>
]

This is the finite-grid version of Foster--Vohra's existence result #citep(<FosterVohra1998Calibration>). See #citep(<GuptaRamdas2022Calibration>, [Section 1]) for the excess-error formulation. The expectation includes both parties' random choices.

For $epsilon=0.05$, ECE 0.08 contributes 0.03 of excess error, while ECE 0.02 contributes zero. At fixed $epsilon$, the expected cumulative _excess_ is $o(T)$. The finer grid supplies intermediate probabilities.

#ece-web[
= ECE experiment and worked examples <sec-l15-ece-lab>

Follow one round of the experiment below, compare a fixed lottery with the history update, or work through the additional figures and exercises.
]

== Supplement: a binary update for the ECE experiment <sec-l15-ece-adaptive>

This update illustrates how to adapt the lottery. The full proof is in #ref(<sec-l15-ece-square-drift>, supplement: [Appendix]).

Here is the binary forecast-hedging procedure of #citep(<FosterHart2021Hedging>, [Section V, Theorem 12]). Fix an integer $m>=1$ and grid $Q={0,1/m,...,1}$ with spacing $h=1/m$. Before round $t$, store the past count $N_q$ and positive-outcome count $R_q$ for each bucket. Its _mean error_ is
$ e_q := cases(R_q/N_q-q & "if" N_q>0, 0 & "if" N_q=0). $
Positive means underprediction; negative means overprediction. Use the mean error here, rather than the cumulative residual $N_q e_q$.

+ If some $e_q=0$, choose such a forecast with probability one. This also lets the procedure try unused buckets.
+ Otherwise $e_0>0$ and $e_1<0$, so there are adjacent $a<b$ with $e_a>0>e_b$. Put all next-round mass on these two forecasts:
  $ D_(t)(a)=frac(-e_b,e_a-e_b), quad D_(t)(b)=frac(e_a,e_a-e_b). $
+ Nature commits without seeing the current draw. Privately sample $p_t~D_t$, then observe $y_t$. Update only its bucket: $N_(p_t) <- N_(p_t)+1$ and $R_(p_t) <- R_(p_t)+y_t$. Recompute the errors and distribution next round.

The lottery weights the next draw. The recorded ECE weights bucket gaps by the historical shares $N_q/T$.

#ece-print[
For example, if the errors at $0.25$ and $0.50$ are $0.50$ and $-0.25$, the draw chances are $1/3$ and $2/3$. If the second bucket goes from one rainy day in four to one in five, its mean error becomes $-0.30$ and the new lottery is $(3/8,5/8)$.

For $w_q=N_q/T$, Cauchy--Schwarz gives $"ECE"_T<=sqrt(sum_q w_q e_q^2)$. Set $V_T=T sum_q w_q e_q^2$. Empty buckets have weight zero.

#link("https://ziyue-l15-ece-preview.qiuzy-william2019.chatgpt.site/calibration_ece#sec-l15-ece-lab")[Open the online experiment, worked examples, and practice problems.]
]

#ece-web[
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

#ece-story-box("balance")[
  *Before the draw: signed contributions to the expected bucket error*
  #table(
    columns: (1fr, 1fr), align: center, inset: (x: 8pt, y: 5pt),
    stroke: .4pt + luma(86%),
    table.header([50% forecast], [25% forecast]),
    [$2/3 times (-0.25) = -1/6$], [$1/3 times 0.50 = +1/6$],
  )
]

#ece-story-box("insight")[
  *Why these weights?* The 25% bucket has twice the absolute mean error, so it gets half the draw probability. The committed outcome $y_t$ is the same for both possible draws, so its term in the expected squared-score update is proportional to $y_t (1/6-1/6)=0$. The #link(<sec-l15-ece-square-drift>)[proof] bounds the remaining terms.
]

Suppose the private draw is $0.50$ and the revealed outcome is zero. That bucket now has one positive in five rounds, so its error is $1/5-0.5=-0.3$. The other error remains $0.5$. Thus
$ D_(t+1)(0.25)=frac(0.3,0.5+0.3)=3/8, quad D_(t+1)(0.50)=5/8. $
Another zero made the higher forecast overpredict more, so the next lottery shifts toward the lower forecast. @fig-l15-ece-adaptive shows the update and a longer run.

#figure(
  image("figures/calibration_ece/ece_adaptive.svg", width: 100%,
    alt: "Four panels: normalized errors plus 0.5 and minus 0.25 at adjacent forecasts 0.25 and 0.50; next-draw weights one third and two thirds; after outcome zero at forecast 0.50, its error becomes minus 0.3 and the weights become three eighths and five eighths; sampled checkpoints from a seeded 4000-round run on a finer grid show ECE becoming small with fluctuations."),
  caption: [From past errors to the next lottery. Panels 1--3 use spacing 0.25 and the table's initial history. Panel 4 uses a fresh run with spacing 0.05, PCG64 seed 20261105, and Nature choosing one exactly when the public mean forecast is below 0.65, before the private draw. The curve shows sampled checkpoints; the full run has 1,958 upward ECE steps and ends at 0.0050375. This single trajectory illustrates the rule; it is not the convergence proof.],
) <fig-l15-ece-adaptive>

=== Try the interactive experiment <sec-l15-ece-experiment>

Open the #interactive-link("calibration_ece")[interactive experiment] with the worked history.

#ece-story-box("lab-steps")[
  + *Commit 0.* The record still contains 11 rounds.
  + *Draw once.* Check which forecast bucket gains a round.
  + *Compare.* If you drew 0.50, ECE moves from 0.5227 to 0.5208 and the next chances become 3/8 and 5/8.
]

#context if target() == "html" {
  html.elem("div",attrs:(class:"ece-experiment-embed"))[
    #html.elem("iframe",attrs:(src:"interactive/calibration_ece.html",title:"Interactive ECE experiment: commit, draw and update",loading:"lazy",style:"display:block;width:100%;height:1150px;border:0;",onload:"const f=this;const fit=()=>f.style.height=(f.contentDocument.body.getBoundingClientRect().height+2)+'px';new ResizeObserver(fit).observe(f.contentDocument.body);fit();"))[]
  ]
}

#link(<ece-static-1>)[See the same round in the static companions.]

=== Why the lottery must learn <sec-l15-ece-comparison>

Let every new outcome be one. With independent draws from the fixed lottery, both bucket frequencies tend to one and their shares tend to $1/3$ and $2/3$. The initial history has vanishing weight, so almost surely
$ lim_(T -> oo) "ECE"_T=frac(1,3)abs(1-0.25)+frac(2,3)abs(1-0.50)=frac(7,12) approx 0.5833. $

In the run in @fig-l15-ece-comparison, the adaptive rule eventually puts 99.5% of its next-draw probability on 1. As better forecasts accumulate, the older buckets count for less in ECE.

*Try it.* Choose _Always 1_ and seed 20261105, then select _Run both to 1,000_. Both strategies start with the same eleven records and use the same outcomes and uniform draws.

#context if target()=="html" { html.elem("p")[#html.elem("a",attrs:(href:"interactive/calibration_ece.html#comparison"))[Open the comparison controls]] }

#let comparison-data=json("figures/calibration_ece/ece_comparison.json")
#let comparison-score(v)=str(calc.round(v,digits:4))
#figure(
 table(columns:(auto,auto,auto),align:center,inset:5pt,
  table.header([New rounds], [Fixed lottery ECE], [History update ECE]),
  [100], [#comparison-score(comparison-data.series.at(100).at(1))], [#comparison-score(comparison-data.series.at(100).at(2))],
  [1,000], [#comparison-score(comparison-data.fixed.ece)], [#comparison-score(comparison-data.adaptive.ece)],
 ),caption:[Checkpoints from the default reproducible comparison. Each score also includes the original eleven records.],
) <tab-l15-ece-comparison>

#link(<ece-static-2>)[Static companion in the static companions]

=== Four possible next records <sec-l15-ece-four-cases>

Write $C_q=R_q-N_q q$ for the total residual in bucket $q$. ECE is the sum of the absolute bucket residuals divided by the record count.
The selected buckets have $C_(0.25)=2$ and $C_(0.50)=-1$. The other three buckets contribute $1+0.75+1=2.75$ to the absolute sum. Thus the current score is
$ "ECE"_11=frac(abs(2)+abs(-1)+2.75,11)=frac(23,44) approx 0.5227. $

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
Both averages fall below $23/44$ for this starting history. The individual branch with $p=0.25$ and $y=1$ rises, so the long-run result needs a separate argument.

#ece-check([Quick check: a rising branch], [One private draw gives $"ECE"_12=13/24>23/44$. Does this disprove the long-run theorem?], <ece-quick-answer-2>) <check-l15-ece-branch>

#figure(
  image("figures/calibration_ece/ece_bridge.svg", width: 100%,
    alt: "Top: the two possible forecast draws for each committed outcome give four ECE values. One branch rises above the old ECE 0.5227, while the conditional means 0.5000 and 0.4722 are lower. Bottom: five bucket widths match counts 1,4,4,1,1 and positive heights are absolute mean errors 1,0.5,0.25,0.75,1. The mean absolute gap 0.5227 lies below the weighted root mean square 0.5887."),
  caption: [Two different averages. The upper panel averages complete next-record ECE values using the draw chances $1/3$ and $2/3$. The lower panel uses historical frequency weights $N_q/11$ to compare the mean absolute bucket gap with its root mean square. All four next-record values and both geometric reference levels use the same initial history.],
) <fig-l15-ece-bridge>

=== From squared calibration error to ECE <sec-l15-ece-square-bridge>

The long-run argument uses the weighted square of each _bucket's_ mean error. With $w_q=N_q/T$ and $e_q=overline(y)_q-q$, set $C_(2,T)=sum_q w_q e_q^2$ and $V_T=T C_(2,T)$. This is the squared calibration score used by Foster--Vohra. The outcome is averaged within each bucket before squaring, and empty buckets contribute zero.

Since the weights sum to one, Cauchy--Schwarz gives $"ECE"_T<=sqrt(C_(2,T))$. In @fig-l15-ece-bridge, $C_(2,11)=61/176 approx 0.3466$, so ECE $0.5227$ is bounded by the square root, $0.5887$.

#ece-check([Quick check: take the square root], [Suppose the squared bucket calibration score is $C_(2,T)=0.04$. What upper bound follows for ECE? Must ECE equal that bound?], <ece-quick-answer-3>) <check-l15-ece-root>

The #link(<sec-l15-ece-square-drift>)[appendix proof] bounds the long-run expected ECE for this particular rule. The Foster--Vohra statement above controls expected excess over a chosen tolerance.

#block(breakable: false)[
== Exercises <sec-l15-ece-exercises>

#exercise[Small signed bias can hide maximal ECE][
  Set $y_0=0$ and forecast the previous outcome, $p_t=y_(t-1)$.
  + Show that the average signed error has absolute value at most $1/T$, for every binary outcome sequence.
  + Now let $y_t=1$ for odd $t$ and $y_t=0$ for even $t$. Compute $"ECE"_T$ for every $T>=1$ using $Q={0,1}$.
  + Explain why this forecasting rule solves the simplified signed-error objective on slide 8 but does not ensure calibration.
] <exr-l15-ece-telescoping>

#link(<ece-reference-solution-1>)[Reference solution in the experiment answers]
]

#block(breakable: false)[
#exercise[Calibration does not imply informativeness][
  There are $2m$ rounds, with $m>=1$. A context $c_t in {A,B}$ is observed before the forecast; each context occurs $m$ times. The outcome is always zero in context $A$ and always one in context $B$.
  + Compute ECE for a forecaster that always reports $p_t=1/2$.
  + Compare with the context-aware rule $p_t=0$ in context $A$ and $p_t=1$ in context $B$. Does ECE distinguish the two rules?
  + Compare their average squared prediction losses, $(1/(2m))sum_(t=1)^(2m) (y_t-p_t)^2$.
] <exr-l15-ece-informativeness>

#link(<ece-reference-solution-2>)[Reference solution in the experiment answers]
]

#block(breakable: false)[
#exercise[Why the grid matters][
  Restrict the forecaster to $Q={0,1}$. Outcomes are independent fair coin flips; the next outcome is independent of the history and of the forecaster's current private randomization.
  + Show that $"ECE"_T$ equals the fraction of rounds on which $p_t!=y_t$.
  + Show that $EE["ECE"_T]=1/2$ for every forecasting strategy in this model and every $T>=1$.
  + Explain why this does not contradict @thm-ece-foster-vohra.
] <exr-ece-grid>

#link(<ece-reference-solution-3>)[Reference solution in the experiment answers]
]

== Visual examples for the main ideas <sec-l15-ece-visual-examples>

*Why weight by bucket size?* In 90 rounds forecast at 0.5, 45 outcomes are one. In ten rounds forecast at 1, none are one. Only the smaller bucket has a gap, so ECE is $0.1 times 1=0.1$.

@fig-l15-ece-weighting shows each contribution as an area.
#figure(
  image("figures/calibration_ece/ece_weighting.svg", width: 100%,
    alt: "A population of 100 dots has 90 blue and 10 orange rounds. The blue bucket has 45 positive outcomes and forecast 0.5; the orange bucket has no positive outcomes and forecast 1. In a unit-area picture the blue bucket has width 0.9 and height zero; the orange bucket has width 0.1 and height one. Their total shaded area, ECE, is 0.1."),
  caption: [From counts to area. Each dot is one round; filled dots are positive outcomes. In the unit square, width is bucket weight and height is absolute gap, so the shaded area is ECE 0.1.],
) <fig-l15-ece-weighting>

In the ten-day example, the reliability diagram shows a gap of $0.2$ in each bucket.

#ece-reliability-example

#ece-check([Quick check: zero signed bias], [Two equally frequent forecasts are $0.25$ and $0.75$; both buckets have observed frequency $0.50$. The signed bias is zero. What is ECE?], <ece-quick-answer-1>) <check-l15-ece-signed>

== Exact buckets and aggregated bins <sec-l15-ece-binning>

When forecasts are pooled into a bin, compare its mean outcome with its mean forecast. Merging buckets can only reduce this version of ECE, since $abs(a+b)<=abs(a)+abs(b)$ for their residual sums.

In @fig-l15-ece-aggregation, merging the two buckets gives a single gap of zero. The original buckets still give ECE 0.2.
#figure(
  image("figures/calibration_ece/ece_cancellation.svg", width: 100%,
    alt: "Three geometric stages use bucket widths one half and signed gap heights plus 0.2 and minus 0.2. Their signed areas cancel. Reflecting the orange negative area above zero gives two positive areas of 0.1, totaling ECE 0.2. Merging both buckets instead produces mean gap zero, while the original exact-bucket ECE is still 0.2."),
  caption: [Absolute value as a reflection. Each original bucket has width 1/2 and gap magnitude 0.2, hence area 0.1. ECE adds both areas. Merging before measuring changes the statistic: its gap is zero here, while exact-bucket ECE remains 0.2.],
) <fig-l15-ece-aggregation>

#ece-story-box("protocol")[
  #table(
    columns: (1fr, 1fr), align: left, inset: (x: 8pt, y: 5pt),
    stroke: .4pt + luma(86%),
    table.header([*Nature sees the draw*], [*Nature sees the lottery*]),
    [Nature can choose a different outcome for each draw.],
    [A commitment to rain applies to either draw.],
    [25% forecast: rain \ 75% forecast: no rain],
    [25% forecast: rain \ 75% forecast: rain],
  )
]

#ece-privacy-story

Frame 5 gives one possible four-round record. Each bucket receives one rain and one dry outcome, for ECE 0.25. Seeing the draw would let Nature force ECE 0.75 in this example. Privacy removes that option, but the same 50--50 lottery still has expected ECE 0.5 if it always rains. We need a strategy that learns which forecasts to report.

Both forecasters in @fig-l15-ece-informativeness have ECE zero. @exr-l15-ece-informativeness asks how their accuracy differs.
#figure(
  image("figures/calibration_ece/ece_informativeness.svg", width: 100%,
    alt: "Equally common contexts A and B always produce zero and one respectively. A constant forecast 0.5 has one reliability point at (0.5,0.5), ECE zero, and mean squared prediction loss one quarter. A context-aware forecast has points at (0,0) and (1,1), ECE zero, and mean squared loss zero."),
  caption: [Both rules are calibrated on the recorded sequence. Contexts A and B occur equally often, with outcomes always 0 in A and 1 in B. Using the context improves squared prediction loss from $1/4$ to $0$, although ECE is zero for both rules.],
) <fig-l15-ece-informativeness>

== Static companions <sec-l15-ece-static-companions>

=== Experiment storyboard <ece-static-1>

#figure(
  image("figures/calibration_ece/ece_experiment.svg",width:100%,alt:"Two matching experiment states. Before drawing: committed outcome zero, eleven records, ECE0.5227 and next-draw chances one third at0.25 and two thirds at0.50. After one possible draw0.50 with outcome zero: twelve records, ECE0.5208, and new chances three eighths and five eighths; only the0.50 bucket count changes from4 to5."),
  caption:[A static companion to the browser experiment. Committing zero leaves history and ECE unchanged. One possible private draw at $0.50$ then changes its count from four to five, gives $"ECE"_12=25/48$, and recomputes the next lottery to $3/8$, $5/8$. The root mean square is a separate upper bound on the same recorded ECE.],
) <fig-l15-ece-experiment>

#link(<sec-l15-ece-experiment>)[Return to the experiment]

=== Fixed and adaptive ECE <ece-static-2>

#figure(
 image("figures/calibration_ece/ece_comparison.svg",width:100%,alt:"Two ECE curves use the same eleven initial records, one thousand all-one outcomes, and seed20261105. The fixed lottery remains near0.5833 and ends at0.5814. The history update ends at0.0208 and puts99.5percent of the next-draw probability at forecast1. All labels are English."),
 caption:[Randomness needs feedback. The orange dashed and blue solid lines are both empirical ECE, on the same axes. The right panel shows the next lottery, not historical bucket weights. The editable figure data are generated by the same model as the browser comparison; the all-one limit describes the fixed lottery with independent draws.],
) <fig-l15-ece-comparison>

#link(<sec-l15-ece-comparison>)[Return to the experiment]

== Answers and reference solutions <sec-l15-ece-answers>

=== Quick check: zero signed bias <ece-quick-answer-1>

The two absolute gaps are both $0.25$, so $"ECE"=0.25$. Signed errors cancel; absolute bucket gaps add.

#link(<check-l15-ece-signed>)[Return to the quick check]

=== Quick check: a rising branch <ece-quick-answer-2>

No. A single branch can increase ECE. The theorem bounds a long-run expectation under the stated protocol; it does not promise improvement after every draw.

#link(<check-l15-ece-branch>)[Return to the quick check]

=== Quick check: take the square root <ece-quick-answer-3>

We obtain $"ECE"_T<=sqrt(0.04)=0.20$. Equality is not required. The score $0.04$ itself is not the bound supplied by this inequality.

#link(<check-l15-ece-root>)[Return to the quick check]

#block(breakable:false)[
=== Exercise L15.5 <ece-reference-solution-1>

#ece-solution[
  The signed residual telescopes:
  $ frac(1,T)sum_(t=1)^T (y_t-p_t)=frac(1,T)sum_(t=1)^T (y_t-y_(t-1))=frac(y_T-y_0,T)=frac(y_T,T). $
  Its absolute value is at most $1/T$. On the alternating sequence, every $p_t=0$ is followed by $y_t=1$, while every $p_t=1$ is followed by $y_t=0$. Each nonempty bucket has gap one. Their weights sum to one, so $"ECE"_T=1$, including when $T=1$ and only one bucket is nonempty. For even $T$, the signed error is exactly zero. The global signed objective allows systematic underprediction and overprediction to cancel, whereas ECE tests each forecast bucket separately.
]

#link(<exr-l15-ece-telescoping>)[Return to the exercise]
]

#block(breakable:false)[
=== Exercise L15.6 <ece-reference-solution-2>

#ece-solution[
  The constant forecaster has one bucket with mean outcome $m/(2m)=1/2$, so its ECE is zero. The context-aware rule has buckets $(q,overline(y)_q)=(0,0)$ and $(1,1)$, so its ECE is also zero. The first rule has squared loss $(0-1/2)^2=(1-1/2)^2=1/4$ on every round; the second has zero loss on every round. Both are calibrated, but the second uses information that the first discards. Calibration assesses agreement with frequencies, not every aspect of forecast quality.
]

#link(<exr-l15-ece-informativeness>)[Return to the exercise]
]

#block(breakable:false)[
=== Exercise L15.7 <ece-reference-solution-3>

#ece-solution[
  At forecast zero, the absolute residual sum is the number of outcomes equal to one. At forecast one, it is the number of outcomes equal to zero. Their sum counts exactly the mistakes, so $"ECE"_T=T^(-1)sum_(t=1)^T bb(1)_(p_t!=y_t)$. Conditional on the history and the chosen $p_t in {0,1}$, a fair next outcome differs from $p_t$ with probability $1/2$. Linearity of expectation gives $EE["ECE"_T]=1/2$. This remains true for randomized, history-dependent forecasts under the stated independence assumption. @thm-ece-foster-vohra allows a grid chosen for the desired tolerance, rather than requiring a guarantee on this two-point grid.
]

#link(<exr-ece-grid>)[Return to the exercise]
]
]

#block(breakable: false)[
= References

#lec_bibliography("meta/refs.bib", title: none)
]

#appendix[
= Appendix: long-run guarantee for the supplementary binary rule <sec-l15-ece-square-drift>

This optional appendix supplies the full proof for the supplementary binary update in @sec-l15-ece-adaptive. It concerns that concrete ECE example; the lecture develops its general multicalibration and no-regret construction separately.

Here is the mathematical link behind the guarantee of #citep(<FosterHart2021Hedging>, [Section V, Theorem 12]). In this paragraph, counts and errors refer to the history before one new round. Expectations condition on that history and any committed outcome $y$, and average only over the private draw $p$. Expanding the selected bucket's new square gives
$ Delta V=2 e_p (y-p)-e_p^2+rho, quad rho:=frac((y-p-e_p)^2,N_p+1). $
For a used bucket, $y-p-e_p=y-R_p/N_p$ lies between minus one and one. For an unused bucket, $e_p=0$ and $abs(y-p)<=1$. Hence $0<=rho<=1/(N_p+1)$ in both cases.

The draw weights were chosen so that $EE[e_p]=0$. Consequently,
$ EE[e_p (y-p)]=y EE[e_p]-EE[e_p p]=-EE[e_p p]. $
#block(breakable: false)[
The unknown outcome has disappeared from this term. In our numerical example, both possible outcomes give the same value:
$ frac(1,3)(0.5)(y-0.25)+frac(2,3)(-0.25)(y-0.50)=1/24. $
]
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

#ece-web[
#block(breakable:false)[
= Citation and review information <sec-l15-ece-review-info>

== Citation format

Gabriele Farina. _Forecasting and calibration._ MIT 6.7980, Lecture 15, November 5, 2026. Expected calibration error section prepared by Ziyue Qiu.

== Review snapshot

This Task 2 section is a draft for staff and group review. It preserves the required ECE narrative and labels the binary example as supplementary. The official course version requires staff review and merge.

#link("https://github.com/gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning/pull/181")[Draft PR 181] · #link("https://ziyue-l15-ece-preview.qiuzy-william2019.chatgpt.site/calibration_ece")[Live review preview]

== Other course notes

#link("https://www.mit.edu/~6.7980/")[Course website and lecture notes]

]
]

]
