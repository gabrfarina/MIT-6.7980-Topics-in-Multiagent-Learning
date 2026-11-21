#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
)

// [L15] Section 5 (MD): No-regret learning for multicalibration.
// The header and the bibliography call make this file compile on its own.
// When the sections are merged, keep only the body. Labels are prefixed with
// `noregret-mc`. After merging, the prose references below can become labels:
// "the multicalibration section" / "the previous section" (protocol, MC error,
//   symmetric families, sign tests h_s) -> @sec-multicalibration,
//   @sec-multicalibration-protocol, @ex-multicalibration-ece (PR #192);
// "the previous section" / GGM -> @sec-ggm-recap, @thm-ggm-recap (PR #193);
// "the overview figure" -> @fig-calibration-intro-overview (PR #188);
// "the ECE section" -> @sec-l15-ece-adaptive (PR #181).

= No-regret learning for multicalibration <sec-noregret-mc>

In the previous section, we saw how #citet(<gordon2008no>) build a $Phi$-regret minimizer out of an external regret minimizer over the deviations $Phi$: the regret minimizer names the deviation that currently threatens the learner the most, and a fixed point neutralizes it in the current round. Multicalibration admits the same recipe, following #citet(<farina2026multicalibration>). The tests $cH$ play the part of the deviations, and an _expected variational inequality_ plays the part of the fixed point. This is the left arrow of the overview figure from the introduction.

We work in the multicalibration protocol of the multicalibration section: the forecaster sees a context $c^((t))$, announces a distribution $D^((t))$ over forecasts, and Nature, who sees $D^((t))$ but not the sampled forecast, reveals an outcome $vu^((t))$. The multicalibration error of a test $h$ is
$
  "MC"^((T))(h) := sum_(t=1)^T EE_(vp ~ D^((t)))[ip(h(c^((t)), vp), vu^((t)) - vp)],
$
and the goal is $sup_(h in cH) "MC"^((T))(h) = o(T)$.

== Expected variational inequalities <sec-noregret-mc-evi>

Suppose the forecaster already knows which test to worry about this round. Plugging the current context into that test leaves a single function $S : cU -> RR^d$, and the forecaster wants to forecast so that this one function catches almost no error, whatever outcome Nature then picks.

#definition[Expected variational inequality][
  Let $S : cU -> RR^d$ be a bounded, measurable operator and let $epsilon >= 0$. An _$epsilon$-solution to the expected variational inequality (EVI)_ induced by $S$ is a probability distribution $D$ over $cU$ such that
  $
    EE_(vp ~ D)[ip(S(vp), vu - vp)] <= epsilon quad forall vu in cU.
  $
] <def-noregret-mc-evi>

Three things to notice.#footnote[EVIs have appeared in the literature under other names, including "outgoing minimax problems" #citep(<FosterHart2021Hedging>), "accuracy certificates" #citep(<nemirovski2010accuracy>), and "negative correlation search" #citep(<perdomo2025defense>). The name and the general treatment are due to #citet(<zhang2025expected>).]
- *It holds for every outcome.* The forecaster can solve the EVI before Nature moves and use the guarantee at whichever $vu^((t))$ Nature reveals.
- *It asks for a distribution.* A point mass at $vp^star$ would reduce the condition to the classical variational inequality $ip(S(vp^star), vu - vp^star) <= epsilon$, which a fixed-point argument solves when $S$ is continuous. Tests usually are not. Against the sign test $S(p) = 1$ if $p < 1\/2$ and $-1$ otherwise, the adversarial Nature of the ECE section, every point mass has value at least $1\/2$; two points do far better, as the next example shows.
- *It is the analogue of a fixed point.* GGM plays $vx = phi.alt(vx)$ so that the deviation $phi.alt$ gains nothing whatever the utility; here the forecaster plays an EVI solution so that the test $S$ detects at most $epsilon$ whatever the outcome.

Solutions always exist, and a regret minimizer finds them. Run an external regret minimizer $cR_(cU)$ over $cU$ for $K$ iterations, where iteration $k$ outputs $vp^((k))$ and then observes the linear utility $vp |-> ip(S(vp^((k))), vp)$, and let $D$ be uniform over $vp^((1)), ..., vp^((K))$. Then for every $vu in cU$,
$
  EE_(vp ~ D)[ip(S(vp), vu - vp)] = 1/K sum_(k=1)^K (ip(S(vp^((k))), vu) - ip(S(vp^((k))), vp^((k)))) <= "Reg"^((K)) / K,
$
which is the same "average the no-regret iterates" argument that #lecture-link("learning_intro", <sec-learning-correlated>)[yields coarse correlated equilibria]. It evaluates $S$ only at the iterates, so $S$ need not be continuous, and with online gradient ascent it reaches an $epsilon$-solution in $(D_(cU) B \/ epsilon)^2$ iterations when $norm(S)_2 <= B$ and $cU$ has diameter $D_(cU)$.

#example[Two-point solutions in one dimension][
  Let $cU = [0, 1]$ and let $S : [0, 1] -> RR$ satisfy $|S| <= B$. Since $d = 1$, a distribution $D$ has EVI value
  $
    max_(u in [0, 1]) (u EE_(p ~ D)[S(p)] - EE_(p ~ D)[S(p) p]) = max{EE[S(p)], 0} - EE[S(p) p].
  $
  If $S(0) <= 0$, the point mass at $p = 0$ has value $0$, and if $S(1) >= 0$, the point mass at $p = 1$ does. Otherwise $S$ is positive at $0$ and negative at $1$, so it changes sign in between. Fix $m >= 1$ and the grid $G := {0, 1\/m, ..., 1}$, and let $a < b = a + 1\/m$ be adjacent grid points straddling a sign change, so that $S(a) > 0 >= S(b)$. Putting weight $lambda := -S(b) \/ (S(a) - S(b))$ on $a$ and $1 - lambda$ on $b$ makes $EE[S(p)] = 0$, which kills the first term. The second is small only because the two points are $1\/m$ apart:
  $
    -EE[S(p) p] = lambda S(a) (b - a) = (S(a) dot (-S(b))) / (S(a) - S(b)) dot 1/m <= (S(a) - S(b)) / (4 m) <= B / (2 m),
  $
  using $x y \/ (x + y) <= (x + y) \/ 4$ for $x, y >= 0$, with $x + y > 0$.

  So hedging across a sign change on a grid of width $1\/m$ always gives a $B\/(2m)$-solution. This is the forecast hedging of #citet(<FosterHart2021Hedging>) from the ECE section, now read as an EVI solver.
] <ex-noregret-mc-two-point>

== The algorithm <sec-noregret-mc-algorithm>

The reduction runs an external regret minimizer $cR_(cH)$ over the tests themselves: the #lecture-link("learning_intro", <def-external-regret>)[definition of a regret minimizer] with $cH$ in place of $cX$, which we assume convex.#footnote[Otherwise run $cR_(cH)$ on $conv(cH)$. Nothing is lost, because the utilities fed to $cR_(cH)$ and the error $"MC"^((T))(h)$ are both linear in $h$, so their maxima over $conv(cH)$ are attained in $cH$.]

#pseudocode-list(numbered-title: [Multicalibration from external regret])[
  + *function* `NextForecast`$(c^((t)))$
    + $h^((t)) <- cR_(cH)$.`NextStrategy()`
    + $S^((t))(vp) := h^((t))(c^((t)), vp)$
    + $D^((t)) <-$ an $epsilon^((t))$-solution to the EVI induced by $S^((t))$
    + *return* $D^((t))$
  + *function* `ObserveUtility`$(vu^((t)))$
    + $cR_(cH)$.`ObserveUtility`$(g^((t)))$, where
      $ g^((t))(h) := EE_(vp ~ D^((t)))[ip(h(c^((t)), vp), vu^((t)) - vp)] $
] <algo-noregret-mc>

#figure(
  caption: [The multicalibration reduction of #citet(<farina2026multicalibration>), drawn to mirror the #lecture-link("phi_regret", <fig-ggm>)[Gordon-Greenwald-Marks diagram]: the external regret minimizer works in the space of tests $cH$, and an EVI solver, which also sees the context, turns its output into a distribution over forecasts.],
)[
  #image(
    "figures/calibration_noregret/loop.svg",
    width: 100%,
    alt: "Block diagram of the multicalibration reduction. The outcome u in U enters a utility construction block, which produces a utility g from H to the reals. An external regret minimizer over the tests H outputs a test h, and an EVI solver for the operator S equal to h of c and dot, which also receives the context c, outputs a distribution D over forecasts. The dashed box enclosing the three blocks is the H-multicalibrated forecaster.",
  )
] <fig-noregret-mc-loop>

The utility $g^((t))(h)$ is exactly what round $t$ contributes to $"MC"^((T))(h)$. The regret minimizer therefore drifts toward whichever tests are accumulating error, that is, toward the tests currently exposing the forecaster, and the EVI then forecasts so that the selected test sees almost nothing next round. Any external regret minimizer will do: #lecture-link("learning1", <sec-mwu>)[multiplicative weights] over $Delta^N$ when $cH = {h_1, ..., h_N}$ is finite, or #lecture-link("learning1", <sec-ogd>)[online projected gradient ascent] when $cH$ is linearly parameterized, as in @ex-noregret-mc-ece below.

@fig-noregret-mc-loop and @tab-noregret-mc-ggm line the two reductions up piece by piece.

#figure(
  caption: [The Gordon-Greenwald-Marks reduction and the multicalibration reduction, side by side.],
)[
  #table(
    columns: 3, align: left, inset: .45em, stroke: none,
    table.hline(),
    table.header([], [*Gordon-Greenwald-Marks*], [*Multicalibration*]),
    table.hline(stroke: .5pt),
    [$cR$ learns over], [deviations $Phi$], [tests $cH$],
    [Nonlinear primitive], [fixed point $vx = phi.alt^((t))(vx)$], [$epsilon^((t))$-EVI for $h^((t))(c^((t)), dot)$],
    [Output], [strategy $vx^((t))$], [distribution $D^((t))$ over forecasts],
    [Utility fed to $cR$], [$phi.alt |-> u^((t))(phi.alt(vx^((t))))$], [$h |-> g^((t))(h)$],
    [Primitive ensures], [$U^((t))(phi.alt^((t))) = u^((t))(vx^((t)))$], [$g^((t))(h^((t))) <= epsilon^((t))$],
    [Guarantee], [$Phi"-Reg"^((T)) = "Reg"_Phi^((T))$], [$"MC"^((T))(h) <= "Reg"_(cH)^((T))(h) + sum_t epsilon^((t))$],
    table.hline(),
  )
] <tab-noregret-mc-ggm>

== Sublinear multicalibration error <sec-noregret-mc-analysis>

Everything now rests on the regret minimizer. Let $"Reg"_(cH)^((T))(h) := sum_(t=1)^T (g^((t))(h) - g^((t))(h^((t))))$ be its regret against the test $h$ on the utilities $g^((1)), ..., g^((T))$. The theorem below says the forecaster ends up only as badly multicalibrated as $cR_(cH)$ is regretful, plus whatever slack the EVI solver left behind.

#theorem[#citep(<farina2026multicalibration>)][
  For every $h in cH$, the forecasts produced by @algo-noregret-mc satisfy
  $
    "MC"^((T))(h) <= "Reg"_(cH)^((T))(h) + sum_(t=1)^T epsilon^((t)).
  $
] <thm-noregret-mc>

#proof[
  The distribution $D^((t))$ was computed before $vu^((t))$ was revealed, but the EVI holds for every $vu in cU$, in particular for $vu = vu^((t))$. With $S^((t)) = h^((t))(c^((t)), dot)$, this reads $g^((t))(h^((t))) <= epsilon^((t))$. Hence, for any $h in cH$,
  $
    "MC"^((T))(h) = sum_(t=1)^T g^((t))(h)
    = sum_(t=1)^T (g^((t))(h) - g^((t))(h^((t)))) + sum_(t=1)^T g^((t))(h^((t)))
    <= "Reg"_(cH)^((T))(h) + sum_(t=1)^T epsilon^((t)).
  $
]

These are the same two lines as the GGM proof: add and subtract the regret minimizer's own utility, and let the nonlinear primitive absorb the leftover term. The EVI only bounds that term by $epsilon^((t))$ rather than zeroing it, which is why GGM's identity becomes an inequality here.

#corollary[
  If $cR_(cH)$ is an external regret minimizer, so that $max_(h in cH) "Reg"_(cH)^((T))(h) = o(T)$, and the EVIs are solved with $sum_(t=1)^T epsilon^((t)) = o(T)$ (for example $epsilon^((t)) = 1\/sqrt(t)$), then $sup_(h in cH) "MC"^((T))(h) = o(T)$, and hence $sup_(h in cH) |"MC"^((T))(h)| = o(T)$ for the symmetric test families of the multicalibration section.
] <cor-noregret-mc>

#example[Recovering calibration][
  Plain calibration is the case with no contexts. Take $d = 1$, $cU = [0, 1]$, and forecasts on the grid $G$ of @ex-noregret-mc-two-point, and recall from the multicalibration section that maximizing over the sign tests $h_(vs)$, now with $vs$ ranging over the convex hull $[-1, 1]^G$, accumulates the absolute error in each bucket: $max_(vs) "MC"^((T))(h_vs)$ is $T$ times the ECE, with the indicator of the sampled forecast replaced by its probability $D^((t))(q)$.

  So run the reduction on these tests. The utility $g^((t))(h_vs) = sum_q s_q D^((t))(q)(u^((t)) - q)$ is linear in $vs$ with gradient of Euclidean norm at most $1$, and the box $[-1, 1]^G$ has diameter $2 sqrt(m+1)$, so online gradient ascent with step size $eta = 2 sqrt((m+1)\/T)$ has #lecture-link("learning1", <ogd-regret-bound>)[regret] $"Reg"_(cH)^((T)) <= 2 sqrt((m+1) T)$. On the grid the operator $S^((t))$ is the vector $vs^((t))$, so $|S^((t))| <= 1$, and @ex-noregret-mc-two-point solves each EVI to $epsilon^((t)) <= 1\/(2m)$. @thm-noregret-mc then yields
  $
    1/T max_(vs) "MC"^((T))(h_vs) <= 2 sqrt((m+1) / T) + 1 / (2m).
  $
  The grid is the tension here: a finer grid leaves less hedging error, but gives the regret minimizer more to learn. Balancing the two at $m approx T^(1\/3)$ gives $O(T^(-1\/3))$. The forecaster that comes out splits its mass between the two grid points where $vs^((t))$ changes sign: forecast hedging again, now driven by learned signs rather than raw bucket errors.
] <ex-noregret-mc-ece>

EVIs are not an artifact of this particular reduction: any $cH$-multicalibrated forecaster solves them implicitly, much as a $Phi$-regret minimizer is always computing fixed points #citep(<hazan2007computational>, <farina2026multicalibration>). So the question is whether they are easier than the fixed points they replace, and they are. The regret-based solver of @sec-noregret-mc-evi needs $O(1\/epsilon^2)$ iterations, and #citet(<zhang2025expected>) compute an $epsilon$-solution in time polynomial in $d$ and $log(B\/epsilon)$, for general, possibly nonmonotone, operators, given a membership oracle for $cU$; their algorithm is an instance of the #lecture-link("eah")[ellipsoid against hope] seen earlier in the course. Classical variational inequalities, by contrast, generalize Nash equilibria and are intractable in general.

The next section turns forecasts into actions by best responding to them, choosing the tests so that $Phi$-regret is controlled by multicalibration error. With @thm-noregret-mc, that bounds $Phi$-regret by external regret plus $sum_t epsilon^((t))$, with no fixed point anywhere.

// Bibliography: remove when merging into the combined L15 source.
#lec_bibliography("meta/refs.bib")
