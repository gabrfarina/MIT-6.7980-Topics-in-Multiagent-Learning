#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 15,
  date: [Tue, Nov 3, 2026],
  title: "Forecasting and calibration",
)

// [L15] Task 6 (MD), items d, e and f: the Phi-regret bound, the lecture recap,
// and the swap-regret example (nice-to-have).
// This file continues content/calibration_forecasting_to_learn.typ (PR #195), which
// covers items b and c. The header and the bibliography call make this file compile
// on its own. When the sections are merged, the content below replaces the placeholders
// of PR #195, but the labels differ and need to be reconciled:
//   PR #195 <lem-calibration-phi-by-mc>    -> here <thm-calibration-phi-bound>
//   PR #195 <thm-calibration-phi-regret>   -> here <thm-calibration-phi-combined>
//   PR #195 <sec-calibration-vs-ggm>       -> here the table <tab-calibration-phi-bound-routes>
//   PR #195 <sec-calibration-swap-example> -> here the example <ex-calibration-swap>
// Notation here follows PR #194 (bold forecasts, MC^((T)), eps^((t))); PR #195 writes
// plain p, MC_T and R_T^Phi.
//
// After merging, the prose references below can become labels:
//   "the best-response map" (theorem lead-in and end of proof) -> @def-calibration-best-response (PR #195)
//   "the deviation test" (theorem statement)    -> @def-calibration-deviation-tests (PR #195)
//   "the multicalibration algorithm"   -> @thm-noregret-mc, @cor-noregret-mc (PR #194)

// Duplicates the section heading of PR #195; drop it when merging.
= Using forecasting to learn

== Bounding $Phi$-regret by calibration error <sec-calibration-phi-bound>

So far, our only general recipe for a $Phi$-regret minimizer is the #lecture-link("phi_regret", <sec-ggm>)[reduction of Gordon, Greenwald, and Marks] #citep(<gordon2008no>): run an external-regret minimizer over the deviations $Phi$, and play a fixed point of its current proposal. In the previous section we applied the same template to a set of tests $cH$, with an expected variational inequality (EVI) in place of the fixed point, and obtained a multicalibrated forecaster. 

We will now turn that forecaster into a player. We show that a player who best responds to forecasts of their next utility vector has $Phi$-regret _at most the forecaster's multicalibration error_ on the tests built from $Phi$. The previous section bounded that multicalibration error by the external regret of the learner over the tests, plus the error of the EVI solutions. Putting the two bounds together, we obtain
$
  Phi"-regret" quad <= quad "multicalibration error" quad <= quad "external regret over the tests" + "EVI error",
$
where the first inequality is new and the second is the guarantee of the multicalibration algorithm.

This is a second recipe for $Phi$-regret minimization, and it never computes a fixed point: an #lecture-link("learning1", <sec-ftrl>)[external-regret minimizer] for the set of tests, paired with an EVI solver, becomes a $Phi$-regret minimizer.

=== $Phi$-regret is at most calibration error

Recall that, at each time $t$, the forecaster announces a distribution $D^((t))$ over forecasts in $cU$ and the player draws $vp ~ D^((t))$ and plays the best response $sigma(vp)$. Let $mu^((t))$ be the resulting distribution over the player's actions. The environment may know $D^((t))$ when it chooses the utility vector $vu^((t))$, but not the sampled forecast.

The quantity we want to bound is the player's regret. For a deviation $phi.alt : cX -> cX$, the _$Phi$-regret against $phi.alt$_ is the expected gain, in hindsight, from applying $phi.alt$ to every action played
#set math.equation(numbering: "(1)")
$
  Phi"-Reg"^((T))(phi.alt) := sum_(t=1)^T EE_(vx ~ mu^((t))) [ip(phi.alt(vx) - vx, vu^((t)))].
$ <eq-calibration-phi-bound-regret>
#set math.equation(numbering: none)
This is the #lecture-link("learning_intro", <defphiregret>)[$Phi$-regret defined earlier in the course] before taking the maximum over $phi.alt$, extended to a player who randomizes. When every $phi.alt in Phi$ is linear, the two definitions agree: a learner that outputs the mean action $EE_(vx ~ mu^((t)))[vx]$ has exactly this regret.

Note that, following #citet(<farina2026multicalibration>),#footnote[#citet(<farina2026multicalibration>) state their results for _losses_ rather than utilities: the best response is $sigma(vp) in "arg min"_(vx in cX) ip(vx, vp)$, the tests are $h_phi.alt (vp) = sigma(vp) - phi.alt(sigma(vp))$, and the regret is $sum_t EE[ip(vx - phi.alt(vx), bold(ell)^((t)))]$ for loss vectors $bold(ell)^((t))$. Replacing $bold(ell)^((t))$ by $-vu^((t))$ and $vp$ by $-vp$ turns their statements into ours.] the set $Phi$ can be any family of such maps: they need not be linear or continuous.

The next theorem bounds this regret by a quantity that depends only on the quality of the forecasts. We achieve this by first turning each deviation $phi.alt$ into a test $h_phi.alt$ for the forecaster. Then we show the regret against $phi.alt$ is at most the multicalibration error of that one test.

#theorem[#citep(<farina2026multicalibration>, [Theorem 5])\; see also #citep(<anagnostides-farina-zhang-2026-phi-equilibria-chapter-4>, [Theorem 4.3])][
  Suppose that at every time $t$ the player draws a forecast $vp ~ D^((t))$ and plays the best response $sigma(vp)$. For each deviation $phi.alt in Phi$, let
  $
    h_phi.alt (vp) := phi.alt(sigma(vp)) - sigma(vp)
  $
  be its deviation test. Then, for every $phi.alt in Phi$ and every $T$,
  $
    Phi"-Reg"^((T))(phi.alt) <= "MC"^((T))(h_phi.alt),
  $
  no matter the sequence of utility vectors $vu^((1)), ..., vu^((T)) in cU$. In particular, if the forecaster is multicalibrated with respect to the deviation tests $cH_Phi := {h_phi.alt : phi.alt in Phi}$ (which means $"MC"^((T))(h) = o(T)$ for every $h in cH_Phi$), then the player has sublinear $Phi$-regret against every $phi.alt in Phi$.
] <thm-calibration-phi-bound>
#proof[
  Fix a deviation $phi.alt in Phi$. We first rewrite the regret in terms of forecasts instead of actions. The action at time $t$ is $sigma(vp)$ with $vp ~ D^((t))$, and ties between best responses are broken by a fixed rule, so the same forecast always leads to the same action. Hence
  $
    Phi"-Reg"^((T))(phi.alt)
      = sum_(t=1)^T EE_(vp ~ D^((t))) [ip(phi.alt(sigma(vp)) - sigma(vp), vu^((t)))]
      = sum_(t=1)^T EE_(vp ~ D^((t))) [ip(h_phi.alt (vp), vu^((t)))].
  $

  Next, we split each utility vector into the forecast plus the forecast error, $vu^((t)) = vp + (vu^((t)) - vp)$. By linearity of the inner product,
  $
    Phi"-Reg"^((T))(phi.alt)
      = underbrace(sum_(t=1)^T EE_(vp ~ D^((t))) [ip(h_phi.alt (vp), vu^((t)) - vp)], = thin "MC"^((T))(h_phi.alt))
       + sum_(t=1)^T EE_(vp ~ D^((t))) [ip(h_phi.alt (vp), vp)],
  $
  where the first sum is, by definition, the multicalibration error of the test $h_phi.alt$.

  Recall that the best response to $vp$ maximizes the forecast utility,
  $
    sigma(vp) in argmax_(vx in cX) ip(vx, vp),
  $
  and that $phi.alt(sigma(vp))$ is itself a point of $cX$. So, for every forecast $vp$,
  $
    ip(h_phi.alt (vp), vp) = ip(phi.alt(sigma(vp)), vp) - ip(sigma(vp), vp) <= 0,
  $
  which means the forecast part cannot help the deviation. The second sum is therefore nonpositive, and $Phi"-Reg"^((T))(phi.alt) <= "MC"^((T))(h_phi.alt)$. No assumption was made on the utility vectors, so the bound holds for every sequence.
]

So if the forecasts were exactly right, no deviation could improve on a best response. The only scenario in which the player regrets not having deviated by $phi.alt$ is if the forecaster is systematically wrong in the direction $h_phi.alt$ points, which is the direction $phi.alt$ moves the player's action. If a forecaster passes the test $h_phi.alt$, this cannot occur.

=== Combining with the multicalibration algorithm

@thm-calibration-phi-bound holds for _any_ forecaster. We now take the forecaster to be the multicalibration algorithm of the previous section, run with an external-regret minimizer $cR_cH$ over a set of tests $cH$ and with EVI errors $eps^((t)) > 0$. Writing $"Reg"_cH^((T))(h)$ for the regret of $cR_cH$ against a test $h in cH$, the previous section showed #citep(<farina2026multicalibration>, [Theorem 4]) that
#set math.equation(numbering: "(1)")
$
  "MC"^((T))(h) <= "Reg"_cH^((T))(h) + sum_(t=1)^T eps^((t)) qquad "for every" h in cH.
$ <eq-calibration-phi-bound-mcreg>
#set math.equation(numbering: none)

The next theorem bounds the player's $Phi$-regret by two quantities we know how to control: the external regret of $cR_cH$ and the EVI errors. We achieve this by first requiring that the set of tests $cH$ contains every deviation test $h_phi.alt$. Then we chain @thm-calibration-phi-bound with the guarantee (@eq-calibration-phi-bound-mcreg).

#theorem[#citep(<farina2026multicalibration>, [Theorems 4 and 5])\; see also #citep(<anagnostides-farina-zhang-2026-phi-equilibria-chapter-4>, [Section 4.2.1])][
  Let $cH$ be any set of tests that contains the deviation tests, $cH supset.eq cH_Phi$. Suppose the player best responds to the forecasts produced by the multicalibration algorithm run with the external-regret minimizer $cR_cH$ and EVI errors $eps^((1)), eps^((2)), ...$. Then, for every deviation $phi.alt in Phi$ and every $T$,
  $
    Phi"-Reg"^((T))(phi.alt) <= "MC"^((T))(h_phi.alt) <= "Reg"_cH^((T))(h_phi.alt) + sum_(t=1)^T eps^((t)).
  $
  In particular, if the regret of $cR_cH$ is sublinear uniformly over the tests, that is, $sup_(h in cH) "Reg"_cH^((T))(h) = o(T)$, and $sum_(t=1)^T eps^((t)) = o(T)$, then $sup_(phi.alt in Phi) Phi"-Reg"^((T))(phi.alt) = o(T)$.
] <thm-calibration-phi-combined>
#proof[
  Fix $phi.alt in Phi$. The first inequality is @thm-calibration-phi-bound, which applies to every forecaster. For the second, note that $h_phi.alt in cH_Phi subset.eq cH$, so $h_phi.alt$ is one of the tests the algorithm competes against, and (@eq-calibration-phi-bound-mcreg) may be applied with $h = h_phi.alt$:
  $
    "MC"^((T))(h_phi.alt) <= "Reg"_cH^((T))(h_phi.alt) + sum_(t=1)^T eps^((t)).
  $

  For the last claim, take the supremum over $phi.alt in Phi$ on both sides. Every $h_phi.alt$ belongs to $cH$, so the supremum over the deviation tests is at most the supremum over all of $cH$:
  $
    sup_(phi.alt in Phi) Phi"-Reg"^((T))(phi.alt)
      <= sup_(phi.alt in Phi) "Reg"_cH^((T))(h_phi.alt) + sum_(t=1)^T eps^((t))
      <= sup_(h in cH) "Reg"_cH^((T))(h) + sum_(t=1)^T eps^((t)).
  $
  Both terms on the right are $o(T)$ by assumption: the first is the regret of $cR_cH$, and the second is the total EVI error.
]

Note that $eps^((t))$ cannot generally be set to zero. Consider how the best-response map jumps from one action to another when the forecast crosses a tie. This makes the deviation tests discontinuous in the forecast. For such a test, the forecaster can make the EVI error arbitrarily small by mixing forecasts on either side of the jump, but an exact solution need not exist #citep(<zhang2025expected>, [Proposition 3.3]). Approximate solutions always exist and can be computed efficiently #citep(<zhang2025expected>, [Theorems 3.1 and 4.1]).

#example[Swap regret on the simplex][
  Let $cX = Delta^n$ be the simplex over the actions $A = {1, ..., n}$, and let $Phi$ be the #lecture-link("learning_intro", <sec-regret-transformations>)[swap deviations] $phi.alt_Q (vx) := Q vx$, where $Q = (vq_1 | dots.c | vq_n)$ is a column-stochastic matrix. We run the forecasting route for this $Phi$ and compare it with the route of Gordon, Greenwald, and Marks.

  A linear function on the simplex is maximized at a vertex, so the best response is a single action: $sigma(vp) = ve_(a(vp))$, where $a(vp)$ is the best action under the forecast $vp$, with ties broken in favor of the lowest index. Since $Q ve_a = vq_a$, the deviation tests are
  $
    h_Q (vp) = vq_(a(vp)) - ve_(a(vp)).
  $
  They depend on the forecast only through _which action is the best response_. Grouping the forecasts accordingly, the multicalibration error splits into one term per action:
  $
    "MC"^((T))(h_Q) = sum_(a in A) ip(vq_a - ve_a, sum_(t=1)^T vb_a^((t))),
    qquad "where" quad
    vb_a^((t)) := EE_(vp ~ D^((t))) [bb(1)[a(vp) = a] (vu^((t)) - vp)]
  $
  is the forecast error at time $t$ on the forecasts that recommend action $a$. So for the forecaster to pass every swap test, it is enough that, for each action, these errors average out over time. This is the condition that Noarov et al. #citep(<noarov2025high>) use to guarantee low swap regret, and it is weaker than the full calibration with which Foster and Vohra #citep(<foster1997calibrated>) reach correlated equilibria.

  Now take $cH = cH_Phi$. At time $t$, the test $h_Q$ is rewarded with $sum_(a in A) ip(vq_a - ve_a, vb_a^((t)))$, which has one term per column of $Q$. The learner over the tests can therefore be run as $n$ independent external-regret minimizers for $Delta^n$, where minimizer $a$ chooses the column $vq_a^((t))$ and observes $vb_a^((t))$. Writing $"Reg"_a^((T))(vq_a)$ for its regret against the column $vq_a$, @thm-calibration-phi-combined reads
  $
    Phi"-Reg"^((T))(phi.alt_Q) <= sum_(a in A) "Reg"_a^((T))(vq_a) + sum_(t=1)^T eps^((t)).
  $

  For swap deviations, the Gordon-Greenwald-Marks route is the #lecture-link("phi_regret")[algorithm of Blum and Mansour] #citep(<blum2007external>). It also runs one minimizer per column, but minimizer $a$ observes $x_a^((t)) vu^((t))$, and the player plays a stationary distribution $vx^((t))$ of $Q^((t))$. In the forecasting route, writing $mu^((t))[a]$ for the probability of playing action $a$,
  $
    vb_a^((t)) = mu^((t))[a] thin vu^((t)) - EE_(vp ~ D^((t))) [bb(1)[a(vp) = a] thin vp].
  $
  The first term has the same form as what the Gordon-Greenwald-Marks minimizer observes, with $mu^((t))[a]$ in place of $x_a^((t))$. The second subtracts what the forecasts that recommend $a$ predicted. So one route shows its learners utilities and solves a fixed-point problem in the space of actions, while the other shows them forecast errors and solves an EVI in the space of utilities.
] <ex-calibration-swap>

@tab-calibration-phi-bound-routes compares the two $Phi$-regret minimizers we built up in this lecture.

#figure(
  table(
    columns: (auto, 1fr, 1.35fr),
    align: (left, left, left),
    inset: 6pt,
    stroke: 0.4pt + luma(170),
    table.header(
      [],
      [*Gordon-Greenwald-Marks*],
      [*Forecasting route*],
    ),
    [*Learn over*], [the valid deviations $Phi$], [any set of tests $cH supset.eq cH_Phi$],
    [*Optimization step*], [a fixed point of the proposed deviation $phi.alt^((t))$], [an $eps^((t))$-solution of the EVI for the proposed test $h^((t))$],
    [*Play*], [the fixed point], [the best response $sigma(vp)$ to a sampled forecast $vp ~ D^((t))$],
    [*Guarantee*],
    [$Phi$-regret equals the learner's external regret],
    [$Phi$-regret is at most the learner's external regret plus the total EVI error],
  ),
  caption: [The two routes from external regret to $Phi$-regret. The equality on the left assumes exact fixed points.],
) <tab-calibration-phi-bound-routes>

== Summary <sec-calibration-summary>

This lecture started from a question about forecasting: what does it mean for a probability forecast to be right? We answered it with calibration, built calibrated forecasters out of external-regret minimizers, and then turned those forecasters into players. This gives a second route from external regret to $Phi$-regret; the first is the #lecture-link("phi_regret", <sec-ggm>)[reduction of Gordon, Greenwald, and Marks]. The main ideas were the following:

+ *Calibration.* A calibrated forecaster's predictions match the outcomes at every forecast value: on the days it forecasts a 70% chance of rain, it rains 70% of the time. The expected calibration error (ECE) measures how far a forecaster is from being calibrated. Against an adversary that sees the forecast, no deterministic forecaster can drive the ECE to zero. In contrast, a forecaster that randomizes and reveals only the distribution of its forecast can drive the ECE to zero.
+ *Multicalibration.* Calibration generalizes to forecasts and outcomes in a convex set $cU subset.eq RR^d$ by fixing a family $cH$ of _tests_. Each test $h$ picks a direction in which to look for forecast error, and the forecaster must keep $"MC"^((T))(h) = o(T)$ for every $h in cH$. The ECE is the special case of one particular family of tests.
+ *The Gordon-Greenwald-Marks template.* A $Phi$-regret minimizer can be built from an external-regret minimizer over the deviations $Phi$ and one nonlinear step: a fixed point of the deviation it proposes.
+ *Multicalibration from external regret.* The same template gives a multicalibrated forecaster. An external-regret minimizer over $cH$ proposes the test to worry about, and the forecaster answers with a distribution that solves the expected variational inequality (EVI) for that test. The multicalibration error is then at most the external regret over $cH$ plus the EVI errors.
+ *$Phi$-regret from multicalibration.* If the forecasts predict the player's next utility vector and the player best responds, the $Phi$-regret against $phi.alt$ is at most the multicalibration error of the test $h_phi.alt (vp) = phi.alt(sigma(vp)) - sigma(vp)$ (@thm-calibration-phi-bound).
+ *A second route to $Phi$-regret.* Chaining the last two ideas gives a $Phi$-regret minimizer built from an external-regret minimizer and an EVI solver, with no fixed point computation (@thm-calibration-phi-combined). @tab-calibration-phi-bound-routes compares it with the Gordon-Greenwald-Marks one.

#lec_bibliography("meta/refs.bib")
