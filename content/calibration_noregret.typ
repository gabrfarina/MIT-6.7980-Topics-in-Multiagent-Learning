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
// "the multicalibration section" -> @sec-multicalibration (PR #192);
// "the previous section" / GGM -> @sec-ggm-recap, @thm-ggm-recap (PR #193);
// "the overview figure" -> @fig-calibration-intro-overview (PR #188);
// "the ECE section" -> @sec-l15-ece-adaptive (PR #181).

= No-regret learning for multicalibration <sec-noregret-mc>

In the previous section, we recalled how #citet(<gordon2008no>) turn an external regret minimizer over a set of deviations $Phi$ into a $Phi$-regret minimizer. The regret minimizer proposes the deviation that currently threatens the learner the most, and a fixed-point computation neutralizes that deviation in the current round. We now apply the same recipe to multicalibration, following #citet(<farina2026multicalibration>). The tests $cH$ take the role of the deviations, and the fixed point is replaced by the solution of an _expected variational inequality_. This is the left arrow of the overview figure from the introduction.

We work in the multicalibration protocol of the previous sections. At each round $t$, the forecaster observes a context $c^((t)) in cC$ and announces a distribution $D^((t))$ over forecasts $vp in cU$. Nature sees $D^((t))$, but not the sampled forecast, and reveals an outcome $vu^((t)) in cU$, where $cU subset.eq RR^d$ is compact and convex. For a test $h : cC times cU -> RR^d$, the multicalibration error is
$
  "MC"^((T))(h) := sum_(t=1)^T EE_(vp ~ D^((t)))[ip(h(c^((t)), vp), vu^((t)) - vp)],
$
and the goal is $sup_(h in cH) "MC"^((T))(h) = o(T)$.

== Expected variational inequalities <sec-noregret-mc-evi>

Suppose that in some round the forecaster knows which test to worry about. Once the current context is plugged into that test, all that remains is a single function $S : cU -> RR^d$. The forecaster then wants a distribution of forecasts whose error, as measured by $S$, is small whatever outcome Nature picks.

#definition[Expected variational inequality][
  Let $S : cU -> RR^d$ be a bounded, measurable operator and let $epsilon >= 0$. An _$epsilon$-solution to the expected variational inequality (EVI)_ induced by $S$ is a probability distribution $D$ over $cU$ such that
  $
    EE_(vp ~ D)[ip(S(vp), vu - vp)] <= epsilon quad forall vu in cU.
  $
] <def-noregret-mc-evi>

Three features of this definition matter below.#footnote[EVIs have appeared in the literature under other names, including "outgoing minimax problems" #citep(<FosterHart2021Hedging>), "accuracy certificates" #citep(<nemirovski2010accuracy>), and "negative correlation search" #citep(<perdomo2025defense>). The name and the general treatment are due to #citet(<zhang2025expected>).]
- *It holds for every outcome.* The forecaster can solve the EVI before Nature moves and then use the guarantee at whichever $vu^((t))$ Nature reveals.
- *It asks for a distribution.* If $D$ is a point mass at $vp^star$, the condition becomes the classical variational inequality $ip(S(vp^star), vu - vp^star) <= epsilon$ for all $vu in cU$. That problem has a solution when $S$ is continuous, by a fixed-point argument, but tests are often discontinuous. For example, take $cU = [0, 1]$ and $S(p) = 1$ if $p < 1\/2$ and $S(p) = -1$ otherwise. This is the test that catches the adversarial Nature of the ECE section, which makes it rain exactly when the forecast is below $1\/2$. Every point mass has EVI value at least $1\/2$: if $p^star < 1\/2$, take $u = 1$; otherwise take $u = 0$. A two-point distribution, as in the example below, does much better. In the appendix (@sec-noregret-mc-evi-algorithms), we show that every bounded $S$ has an $epsilon$-solution for every $epsilon > 0$.
- *It is the analogue of a fixed point.* In the Gordon-Greenwald-Marks reduction, playing a fixed point $vx = phi.alt(vx)$ guarantees that the deviation $phi.alt$ gains nothing, whatever the utility. An EVI solution guarantees that the test $S$ detects at most $epsilon$ error in expectation, whatever the outcome.

#example[Two-point solutions in one dimension][
  Let $cU = [0, 1]$, fix $m >= 1$, consider the grid $G := {0, 1\/m, ..., 1}$, and let $S : [0, 1] -> RR$ satisfy $|S| <= B$. Since $d = 1$, the EVI value of a distribution $D$ is
  $
    max_(u in [0, 1]) (u EE_(p ~ D)[S(p)] - EE_(p ~ D)[S(p) p]) = max{EE[S(p)], 0} - EE[S(p) p].
  $
  - If $S(0) <= 0$, the point mass at $p = 0$ has value $0$.
  - If $S(1) >= 0$, the point mass at $p = 1$ has value $0$.
  - Otherwise $S(0) > 0 > S(1)$, so there are adjacent grid points $a < b = a + 1\/m$ with $S(a) > 0 >= S(b)$. Put weight $lambda := -S(b) \/ (S(a) - S(b))$ on $a$ and $1 - lambda$ on $b$. Then $EE[S(p)] = 0$, and the value is
  $
    -EE[S(p) p] = lambda S(a) (b - a) = (S(a) dot (-S(b))) / (S(a) - S(b)) dot 1/m <= (S(a) - S(b)) / (4 m) <= B / (2 m),
  $
  using $x y \/ (x + y) <= (x + y) \/ 4$ for $x, y >= 0$, with $x + y > 0$.

  So a distribution on at most two adjacent grid points is a $B\/(2m)$-solution. This is the forecast-hedging idea of #citet(<FosterHart2021Hedging>) used in the ECE section, now read as an EVI solver.
] <ex-noregret-mc-two-point>

== The algorithm <sec-noregret-mc-algorithm>

The reduction uses an external regret minimizer $cR_(cH)$ whose decision set is the set of tests $cH$. This is the #lecture-link("learning_intro", <def-external-regret>)[definition of a regret minimizer] instantiated with $cH$ in place of $cX$, just as GGM instantiates it with $Phi$. As in GGM, we assume that $cH$ is convex; otherwise we run $cR_(cH)$ on $conv(cH)$. This loses nothing. The utilities fed to $cR_(cH)$ and the error $"MC"^((T))(h)$ are both linear in $h$, so their maxima over $conv(cH)$ are attained in $cH$.

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

The utility $g^((t))(h)$ is the contribution of round $t$ to $"MC"^((T))(h)$. The regret minimizer therefore drifts toward the tests that are accumulating error, which are the tests exposing the forecaster. The EVI then forecasts so that the currently selected test sees almost no error in the next round. For example:
- If $cH = {h_1, ..., h_N}$ is finite, $cR_(cH)$ can be #lecture-link("learning1", <sec-mwu>)[multiplicative weights] over $Delta^N$. Here $h^((t)) = sum_i w_i^((t)) h_i$ and the utility vector is $(g^((t))(h_1), ..., g^((t))(h_N))$.
- If $cH = {h_vtheta = sum_i theta_i f_i : vtheta in Theta}$ is linearly parameterized by a compact convex set $Theta$, $cR_(cH)$ can be #lecture-link("learning1", <sec-ogd>)[online projected gradient ascent] on $vtheta$, with gradient $(g^((t))(f_i))_i$.

@fig-noregret-mc-loop and @tab-noregret-mc-ggm line the two reductions up. In GGM, the fixed point makes the term that $cR$ never observes vanish exactly. Here, the EVI makes the corresponding term at most $epsilon^((t))$.

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

Let $"Reg"_(cH)^((T))(h) := sum_(t=1)^T (g^((t))(h) - g^((t))(h^((t))))$ be the regret of $cR_(cH)$ against the test $h$ on the utilities $g^((1)), ..., g^((T))$.

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

The proof has the same two lines as the proof of the GGM theorem. Adding and subtracting the regret minimizer's own utility leaves a term it never controls, and the nonlinear primitive takes care of that term. The only difference is that the EVI bounds the term by $epsilon^((t))$ instead of making it zero, so we get an inequality instead of an identity.

#corollary[
  If $cR_(cH)$ is an external regret minimizer, so that $max_(h in cH) "Reg"_(cH)^((T))(h) = o(T)$, and the EVIs are solved with $sum_(t=1)^T epsilon^((t)) = o(T)$ (for example $epsilon^((t)) = 1\/sqrt(t)$), then $sup_(h in cH) "MC"^((T))(h) = o(T)$. If moreover $-h in cH$ whenever $h in cH$, then $sup_(h in cH) |"MC"^((T))(h)| = o(T)$.
] <cor-noregret-mc>

#example[Recovering calibration][
  Take $d = 1$, $cU = [0, 1]$, no contexts, and forecasts on the grid $G$ of @ex-noregret-mc-two-point. ECE corresponds to the sign tests $h_(vs)(p) = sum_(q in G) s_q bb(1){p = q}$, whose convex hull is $vs in [-1, 1]^G$. Since $g^((t))(h_vs) = sum_q s_q D^((t))(q)(u^((t)) - q)$,
  $
    max_(vs) "MC"^((T))(h_vs) = sum_(q in G) abs(sum_(t=1)^T D^((t))(q) (u^((t)) - q)),
  $
  which is $T$ times the ECE in which the indicator of the sampled forecast is replaced by its probability $D^((t))(q)$.

  Run online gradient ascent on the box $[-1, 1]^G$. It has diameter $2 sqrt(m+1)$, and the gradients $(D^((t))(q)(u^((t)) - q))_q$ have Euclidean norm at most $1$. With step size $eta = 2 sqrt((m+1)\/T)$, the #lecture-link("learning1", <ogd-regret-bound>)[regret bound for OGD] gives $"Reg"_(cH)^((T)) <= 2 sqrt((m+1) T)$. On the grid, the operator $S^((t))$ is the vector $vs^((t))$, so $|S^((t))| <= 1$, and @ex-noregret-mc-two-point gives $epsilon^((t)) <= 1\/(2m)$. @thm-noregret-mc then yields
  $
    1/T max_(vs) "MC"^((T))(h_vs) <= 2 sqrt((m+1) / T) + 1 / (2m),
  $
  which is $O(T^(-1\/3))$ for $m approx T^(1\/3)$. The resulting forecaster splits its mass between two adjacent grid points where $vs^((t))$ changes sign. This is a forecast-hedging procedure in the style of the ECE section, with the learned signs $vs^((t))$ in place of the raw bucket errors.
] <ex-noregret-mc-ece>

#remark[EVIs are necessary][
  The EVI primitive cannot be avoided, just as fixed points cannot be avoided for $Phi$-regret #citep(<hazan2007computational>). Suppose a forecaster is $cH$-multicalibrated. Fix a context $c$ and a test $h in cH$, and let $S := h(c, dot)$. Feed the forecaster the context $c$ in every round, and let Nature answer $D^((t))$ with $vu^((t)) in argmax_(vu in cU) ip(vu, EE_(vp ~ D^((t)))[S(vp)])$. Then for every fixed $vu^star in cU$, round $t$ contributes at least $EE_(vp ~ D^((t)))[ip(S(vp), vu^star - vp)]$ to $"MC"^((T))(h)$. So the uniform mixture of $D^((1)), ..., D^((T))$ is a $("MC"^((T))(h) \/ T)$-solution to the EVI induced by $S$, and multicalibration drives this error to zero #citep(<farina2026multicalibration>).
]

The next section turns forecasts into actions by best responding to them, and chooses the tests so that $Phi$-regret is bounded by multicalibration error. Combined with @thm-noregret-mc, this bounds the $Phi$-regret by the external regret of $cR_(cH)$ plus $sum_t epsilon^((t))$, without ever computing a fixed point.

= Appendix: algorithms for expected variational inequalities <sec-noregret-mc-evi-algorithms>

*From no-regret iterates.* The simplest EVI solver is again a regret minimizer. Run an external regret minimizer $cR_(cU)$ over $cU$ for $K$ iterations. At iteration $k$, it outputs $vp^((k))$ and then observes the linear utility $vp |-> ip(S(vp^((k))), vp)$. Let $D$ be uniform over $vp^((1)), ..., vp^((K))$. Then for every $vu in cU$,
$
  EE_(vp ~ D)[ip(S(vp), vu - vp)] = 1/K sum_(k=1)^K (ip(S(vp^((k))), vu) - ip(S(vp^((k))), vp^((k)))) <= "Reg"^((K)) / K.
$
So $D$ is a $("Reg"^((K)) \/ K)$-solution. This is the same "average the no-regret iterates" argument that #lecture-link("learning_intro", <sec-learning-correlated>)[yields coarse correlated equilibria]. It only needs to evaluate $S$ at the iterates, so $S$ need not be continuous. With online gradient ascent, a set $cU$ of diameter $D_(cU)$, and $norm(S)_2 <= B$, it gives an $epsilon$-solution after $K = (D_(cU) B \/ epsilon)^2$ iterations. In particular, every bounded $S$ admits an $epsilon$-solution for every $epsilon > 0$. This regret-based route is developed in more generality by #citep(<zhang2025expected>).

*Forecast hedging.* #citet(<FosterHart2021Hedging>) prove the existence of such distributions, which they call outgoing minimax solutions, with a minimax argument that requires no continuity of $S$. They then use them to build calibrated forecasters. @ex-noregret-mc-two-point is the one-dimensional instance of their construction.

*Polynomial-time algorithms.* The regret-based route needs $O(1\/epsilon^2)$ iterations. #citet(<zhang2025expected>) show that an $epsilon$-solution can be computed in time polynomial in $d$ and $log(B\/epsilon)$, for general, possibly nonmonotone, operators, given a membership oracle for $cU$. Their algorithm is an instance of the #lecture-link("eah")[ellipsoid against hope] seen earlier in the course. This contrasts sharply with classical variational inequalities, which generalize Nash equilibria and are intractable in general. They also show that EVIs capture correlated equilibria as a special case.

// Bibliography: remove when merging into the combined L15 source.
#lec_bibliography("meta/refs.bib")
