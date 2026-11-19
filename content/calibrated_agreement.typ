#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 13,
  date: [Thu, Oct 29, 2026],
  title: "Alignment (part I)",
  instructor: [Natalie Collina],
)

// Tasks 7 and 8 (L13): the agreement theorem for conversation-calibrated agents and its proof sketch.
// The protocol and conversation calibration are recalled briefly; trim the recap if the Task 4-6
// sections already introduce them. Task 9 covers the general bound with the beta(T) term.

#note-status[Draft section for L13 (Tasks 7 and 8) - work in progress.]

= Conversation calibration implies fast agreement <sec-calibrated-agreement>

#citet(<aaronson2005complexity>) showed that two Bayesian agents with a common prior who take turns announcing their posterior estimates of a quantity reach approximate agreement after a number of rounds that does not depend on how much private information they hold. In this section we see that the same kind of guarantee survives when we drop both the prior and Bayesian rationality, and only ask each agent to satisfy a statistical property of its predictions, _conversation calibration_. The result is due to #citet(<collina2025tractable>).

== The repeated agreement protocol

A human and an AI model make predictions together on each of $T$ days. On day $t$, they both want to predict an outcome $y^t in [0, 1]$, such as whether an operation succeeds. Each sees its own private features, and we make no assumption on how the features relate to $y^t$. On each day they hold a short conversation, in which they take turns announcing predictions in $[0, 1]$:

+ In odd rounds $k = 1, 3, 5, ...$ the model announces a prediction $p^(t, k)$.
+ In even rounds $k = 2, 4, 6, ...$ the human announces a prediction $p^(t, k)$.
+ The conversation on day $t$ stops at the first round $k >= 2$ in which $abs(p^(t, k) - p^(t, k-1)) < eps$. We then say that the two parties _$eps$-agree_ at round $k$.

After the conversation ends, both parties observe $y^t$ and move on to day $t + 1$. Since the speaker is determined by the parity of $k$, we write a single symbol $p^(t, k)$ for the prediction of whoever speaks at round $k$.

We write $cal(T)_k subset.eq {1, ..., T}$ for the set of days on which the conversation reaches round $k$. Every conversation has rounds $1$ and $2$, so $cal(T)_1 = cal(T)_2 = {1, ..., T}$, and the sets shrink as $k$ grows: a day $t in cal(T)_k$ also belongs to $cal(T)_(k+1)$ exactly when the two parties still disagree at round $k$, that is,
$
  cal(T)_(k+1) = {t in cal(T)_k : abs(p^(t, k) - p^(t, k-1)) >= eps} quad "for all" k >= 2.
$

#paragraph-marker() *Conversation calibration.*~~
In each round $k >= 2$, the speaker is asked to be unbiased on the days that reach round $k$, conditionally on both its own current prediction and the prediction the other party announced in round $k - 1$. For simplicity, we state the condition exactly and assume that predictions take finitely many values.

#definition[Perfect conversation calibration][
  The speaker of round $k >= 2$ is _perfectly conversation-calibrated_ at round $k$ if, for every pair of values $v', v in [0, 1]$,
  $
    sum_(t in cal(T)_k) bb(1)[p^(t, k-1) = v'] dot bb(1)[p^(t, k) = v] dot (v - y^t) = 0.
  $
  In words, on the days that reach round $k$ and on which the previous speaker said $v'$ and the current speaker said $v$, the average outcome is exactly $v$. The human (resp. the model) is perfectly conversation-calibrated if it is so at every even (resp. odd) round.
] <def-ca-perfect-cc>

Like ordinary calibration, this is a property of a sequence of predictions, not an algorithm. Exact empirical unbiasedness on a finite transcript is an idealization that we adopt only to make the proof transparent; @rem-ca-approximate describes the condition that is actually achievable.

#remark[Approximate conversation calibration][
  No online algorithm can be exactly unbiased conditionally on every possible value of the other party's previous prediction. The definition of #citet(<collina2025tractable>) relaxes @def-ca-perfect-cc in two ways. First, the previous prediction $p^(t, k-1)$ is only located up to a bucket of width $g(T)$. Second, the predictions on each resulting subsequence $S$ only need to be within $ell_1$-distance $f(abs(S))$ of a perfectly calibrated sequence, where $f$ grows sublinearly. Such an agent is called _$(f, g)$-conversation-calibrated_. Such conditions can be enforced by efficient online algorithms without any prior. The analysis below then goes through with additive error terms that depend on $f$ and $g$; after normalizing the squared error by $T$, these terms vanish as $T -> infinity$ for suitable choices of $f$ and $g$. The resulting bound on the number of rounds, which involves a quantity $beta(T)$, is discussed separately.
] <rem-ca-approximate>

== The agreement theorem

The conclusion of the theorem concerns agreement, not calibration. We say that the protocol achieves _$(eps, delta)$-agreement within $K$ rounds_ if on at least a $(1 - delta)$ fraction of the $T$ days the conversation stops by round $K$, that is, the two parties $eps$-agree at some round $k <= K$.

#theorem[Agreement under conversation calibration, idealized][
  Suppose that both the human and the model are perfectly conversation-calibrated, and let $eps, delta in (0, 1]$. Then the protocol achieves $(eps, delta)$-agreement within
  $
    K = 1 + ceil(1 / (eps^2 delta))
  $
  rounds. Moreover, if we stop all conversations at a common round $k$, the total squared error of the predictions in force at that point is non-increasing in $k >= 1$.
] <thm-ca-agreement>

The number of rounds depends only on the agreement tolerance $eps$ and on the fraction $delta$ of days we are willing to give up, not on the dimension of the features, the number of days, or how the outcomes are generated. The bound matches the $O(1 \/ (delta eps^2))$ rounds of the Bayesian protocol of #citet(<aaronson2005complexity>), but neither party needs a prior, and neither needs to compute a posterior.

The second part of the theorem says that conversation does not hurt accuracy in aggregate: summed over the days, the final predictions have squared error at most that of the model's opening predictions and of the human's first replies. (This need not hold on each individual day.)

== Proof sketch: squared error decreases with every disagreement <sec-ca-proof>

The proof tracks the squared error of the predictions in force after each round. Since conversations end at different rounds on different days, we freeze a prediction once the conversation ends: let $k_t$ be the last round of day $t$, and set $overline(p)^(t, k) := p^(t, min(k, k_t))$. The potential function is
$
  "SQE"_k := sum_(t = 1)^T (overline(p)^(t, k) - y^t)^2,
$
the squared error over all days if every conversation is cut off after round $k$. Since $y^t$ and the predictions all lie in $[0, 1]$, we have $0 <= "SQE"_k <= T$.

The proof rests on one idea. Fix a round $k >= 2$, and consider the days in $cal(T)_k$ on which the previous speaker said $v'$ and the current speaker says $v$. On these days, the old prediction is the constant $v'$, and by calibration the new prediction $v$ is the average outcome. Replacing a constant by the average outcome reduces the total squared error on these days by $(v - v')^2$ per day on average, which is at least $eps^2$ when the two disagree.

#example[One round of conversation][
  Take $eps <= 0.1$, and suppose that on six days the model announces $0.2$ at round $k - 1$. In round $k$, the human disagrees: they announce $0.1$ on three of the days and $0.3$ on the other three. If the human is conversation-calibrated, the outcomes average to $0.1$ on the first three days and to $0.3$ on the other three. On the first three days, moving from $0.2$ to the average outcome $0.1$ lowers the squared error by $3 dot (0.2 - 0.1)^2 = 0.03$, and the same holds for the other three days. In total the squared error falls by $0.06$. If instead the human had echoed the model's $0.2$ on all six days, the conversation would have ended with no change in squared error.
] <ex-ca-one-round>

The following elementary identity makes the idea precise. For any finite set of days $S$, constant $c in RR$, and mean outcome $m := 1 / abs(S) sum_(t in S) y^t$, expanding the square shows that the cross term vanishes:
$
  sum_(t in S) (c - y^t)^2 = sum_(t in S) (m - y^t)^2 + abs(S) (c - m)^2.
$

#block(breakable: false)[
#lemma[Each round reduces squared error][
  If the speaker of round $k >= 2$ is perfectly conversation-calibrated at round $k$, then
  $
    "SQE"_(k-1) - "SQE"_k = sum_(t in cal(T)_k) (p^(t, k) - p^(t, k-1))^2 >= eps^2 abs(cal(T)_(k+1)).
  $
] <lem-ca-one-round>
]

#proof[
  On a day $t in.not cal(T)_k$, the conversation has already ended, so $overline(p)^(t, k) = overline(p)^(t, k-1)$, and the day contributes nothing to $"SQE"_(k-1) - "SQE"_k$. On a day $t in cal(T)_k$ both rounds took place, so $overline(p)^(t, k-1) = p^(t, k-1)$ and $overline(p)^(t, k) = p^(t, k)$.

  Partition $cal(T)_k$ into the cells $S_(v', v) := {t in cal(T)_k : p^(t, k-1) = v', p^(t, k) = v}$. By @def-ca-perfect-cc, the mean outcome on $S_(v', v)$ is $v$. Applying the identity above on this cell, once with $c = v'$ and once with $c = v$, and subtracting,
  $
    sum_(t in S_(v', v)) (v' - y^t)^2 - sum_(t in S_(v', v)) (v - y^t)^2 = abs(S_(v', v)) (v' - v)^2 = sum_(t in S_(v', v)) (p^(t, k-1) - p^(t, k))^2.
  $
  Summing over all cells gives the equality in the statement. For the inequality, drop the days of $cal(T)_k$ on which the two parties agree at round $k$. On every remaining day, $(p^(t, k) - p^(t, k-1))^2 >= eps^2$, and by the description of $cal(T)_(k+1)$ in the protocol, these days are exactly $cal(T)_(k+1)$.
]

#proofsketch[of @thm-ca-agreement][
  The second part of the theorem is immediate from @lem-ca-one-round: $"SQE"_k <= "SQE"_(k-1)$ for every $k >= 2$.

  For the first part, apply @lem-ca-one-round at rounds $k = 2, ..., K$ and add the inequalities. The left-hand sides telescope:
  $
    T >= "SQE"_1 - "SQE"_K >= eps^2 sum_(k=2)^K abs(cal(T)_(k+1)) >= eps^2 (K - 1) abs(cal(T)_(K+1)),
  $
  where the first inequality uses $0 <= "SQE"_k <= T$, and the last uses that the sets $cal(T)_k$ are nested, so $abs(cal(T)_(k+1)) >= abs(cal(T)_(K+1))$ for all $k <= K$. The days on which the parties have not $eps$-agreed within the first $K$ rounds are exactly the days in $cal(T)_(K+1)$, and their fraction is
  $
    abs(cal(T)_(K+1)) / T <= 1 / (eps^2 (K - 1)) <= delta
  $
  by the choice of $K$.
]

Informally, each round in which at least a $delta$ fraction of the days remain in conversation after that round removes at least $eps^2 delta T$ from a potential that starts at most at $T$ and never becomes negative. So there can be at most about $1 \/ (eps^2 delta)$ such rounds.

// Task 15 (L13): traditional vs. market alignment.
// Notation agreed with the Task 14 section: u_A and u_{B_i} as on the slides, "providers (Bobs)",
// C = the providers' profile of conversation rules, OPT_aligned vs. OPT_FB.

= Traditional and market alignment <sec-market-alignment>

Recall the setting. Alice chooses an action $a in cA$, the state of nature is $y in cY$, and Alice's utility is $u_A (a, y)$. There are $k$ AI providers (the Bobs) $B_1, dots, B_k$, and provider $B_i$ has its own utility $u_(B_i) (a, y)$, defined on the same pairs. A provider never influences $(a, y)$ directly. Each provider commits to a conversation rule, and the conversations shape what Alice learns and therefore which action she takes. Write $C = (C_1, dots, C_k)$ for the providers' profile of conversation rules, where $C_i$ is the rule chosen by provider $B_i$. All that matters about $C$ is the joint distribution $I^* (C) in Delta (cA times cY)$ of Alice's action and the state that it induces. Every player's payoff is an expectation under that distribution. We now ask what it should mean for the providers to be "aligned" with Alice.

== Traditional alignment

The usual answer asks for a single provider who wants exactly what Alice wants.

#definition[Aligned provider][
  Provider $B_i$ is _aligned_ with Alice if $u_(B_i) (a, y) = u_A (a, y)$ for all $a in cA$ and $y in cY$.
] <def-ma-aligned-provider>

An aligned provider picks its conversation rule to maximize its own expected utility, which is exactly Alice's. The utility Alice obtains from interacting with such a provider is our benchmark:

$ "OPT"_"aligned" := max_C EE_((a, y) ~ I^* (C)) [u_A (a, y)]. $

It is the best Alice can do when the provider is fully on her side. It should not be confused with the first-best benchmark $"OPT"_"FB"$, the utility Alice would get if she observed both her own features $x_A$ and the providers' features $x_B$.

#remark[Alignment only needs to hold up to a positive affine transformation][
  If $u_(B_i) = lambda u_A + c$ for some $lambda > 0$ and $c in RR$, then for every distribution $I$ over $cA times cY$,

  $ EE_I [u_(B_i)] = lambda EE_I [u_A] + c. $

  So provider $B_i$ ranks every conversation rule exactly as Alice does, and it behaves like an aligned provider. The scale and offset of a utility function carry no information about preferences. We will use this observation again below.
]

Asking any single provider to be aligned is a strong requirement. A model trained or funded by a pharmaceutical company may give excellent medical advice _and_ prefer that the company's drug be prescribed. Such a provider is not aligned in the sense of @def-ma-aligned-provider, even if it is almost aligned everywhere else.

== Market alignment

Market alignment moves the requirement from an individual provider to the market as a whole.

#definition[Market alignment][
  Let $eps >= 0$. The providers are _$eps$-market aligned_ with Alice if there exist weights $w_1, dots, w_k >= 0$ and an offset $c in RR$ such that

  $ sup_(a in cA, y in cY) abs(sum_(i=1)^k w_i u_(B_i) (a, y) + c - u_A (a, y)) <= eps. $

  When $eps = 0$, we simply say the providers are _market aligned_. In words, Alice's utility is (approximately) a non-negative linear combination of the providers' utilities, up to an additive constant.
] <def-ma-market-alignment>

The approximate version with tolerance $eps$ follows #citet(<collina2025emergent>).

Market alignment is a property of the market, and it says nothing about any individual provider. Every provider may be substantially misaligned, as long as their interests _collectively span_ Alice's.

*Geometric view*  Think of each utility function as a vector in $RR^(cA times cY)$, with one coordinate per action–state pair. Traditional alignment asks that $u_A$ coincide with one of the provider vectors $u_(B_1), dots, u_(B_k)$. Market alignment asks only that $u_A$ lie (within $eps$ in every coordinate) in the cone generated by $u_(B_1), dots, u_(B_k)$, shifted along the all-ones direction $vone$. A shift along $vone$ adds the same constant to every outcome, so it does not change preferences. The lecture's picture draws Alice's utility inside the convex hull of the providers' utilities. That is the special case $sum_i w_i = 1$, and any non-negative combination is enough.

Two consequences are immediate.

- *Traditional alignment is a special case.* If provider $B_j$ is aligned, take $w_j = 1$, all other weights $0$, and $c = 0$. More generally, any provider aligned up to a positive affine transformation suffices on its own.
- *More providers can only help.* Adding a provider to the market enlarges the set of non-negative combinations, so market alignment becomes easier to satisfy as the market grows larger and more diverse.

The converse of the first point fails, and the gap between the two notions is the whole point. The lecture's pharmaceutical example shows how large that gap can be.

#example[Competing drug makers][
  Alice is a doctor choosing between two drugs, $cA = {upsans(J), upsans(P)}$. The state $y in {upsans(J), upsans(P)}$ records which drug is better for the patient, and Alice wants to prescribe the better one:

  $ u_A (a, y) = bb(1)[a = y]. $

  There are two providers. Provider $B_1$ is sponsored by the maker of $upsans(J)$, and provider $B_2$ by the maker of $upsans(P)$. Each provider cares about the patient just as Alice does, but receives an extra payoff $beta > 0$ whenever its own sponsor's drug is prescribed:

  $
    u_(B_1) (a, y) = u_A (a, y) + beta dot bb(1)[a = upsans(J)], #h(2em) u_(B_2) (a, y) = u_A (a, y) + beta dot bb(1)[a = upsans(P)].
  $

  Neither provider is aligned, even up to a positive affine transformation. If $beta > 1$, then $u_(B_1) (upsans(J), upsans(P)) = beta > 1 = u_(B_1) (upsans(P), upsans(P))$. Provider $B_1$ prefers that its sponsor's drug be prescribed even when the other drug is better for the patient, and symmetrically for $B_2$.

  However, exactly one drug is prescribed, so $bb(1)[a = upsans(J)] + bb(1)[a = upsans(P)] = 1$, and the average of the two utilities is

  $ 1/2 u_(B_1) (a, y) + 1/2 u_(B_2) (a, y) = u_A (a, y) + beta / 2. $

  The market is therefore exactly market aligned, with $w_1 = w_2 = 1\/2$ and $c = -beta\/2$. The biases cancel because they pull in opposite directions. @fig-ma-drug-makers shows this geometrically.

  Two details are worth noting. First, the offset is negative, and no other choice of weights avoids this. Writing out $w_1 u_(B_1) + w_2 u_(B_2) + c = u_A$ at all four action–state pairs forces $w_1 + w_2 = 1$ and $beta w_1 = beta w_2 = -c$. So the only solution is $w_1 = w_2 = 1\/2$ and $c = -beta\/2 < 0$, which is why the offset $c$ must be allowed to take any real value. Second, the cancellation needs _both_ manufacturers in the market. With only one of the two providers, Alice's utility is not a non-negative combination of the providers' utilities plus a constant.
] <ex-ma-drug-makers>

#figure(
  image("figures/market_alignment/drug_makers.svg", width: 100%),
  caption: [Utilities from @ex-ma-drug-makers with $beta = 1.5$, one panel per state $y$. Each point shows a player's utility for prescribing $upsans(J)$ (horizontal) and $upsans(P)$ (vertical). Points above the dashed diagonal prefer $upsans(P)$, and points below it prefer $upsans(J)$. In each state one provider disagrees with Alice. The midpoint of the two providers (hollow) is Alice's utility shifted by $beta\/2$ along $(1, 1)$. That shift is parallel to the diagonal, so it never changes which drug is preferred, and the same shift appears in both panels.],
) <fig-ma-drug-makers>

== Why a non-negative linear combination? <sec-ma-why-linear>

Why is market alignment defined through a non-negative linear combination, and not some other way of aggregating the providers' utilities? The reason is that the providers' incentives are expressed as expected utilities under the distribution $I^* (C)$, and expectations interact well with linear combinations. The next lemma isolates the consequence we need.

#lemma[If no provider gains, neither does Alice][
  Suppose the providers are $eps$-market aligned with Alice. Let $I$ and $I'$ be two distributions over $cA times cY$ such that no provider prefers $I'$ to $I$:

  $ EE_(I') [u_(B_i)] <= EE_I [u_(B_i)] quad "for all" i = 1, dots, k. $

  Then $EE_(I') [u_A] <= EE_I [u_A] + 2 eps$. In particular, when $eps = 0$, Alice does not prefer $I'$ to $I$ either.
] <lem-ma-no-gain>

#proof[
  Multiply the $i$-th inequality by $w_i >= 0$ and sum over $i$. By linearity of expectation,

  $ EE_(I') [sum_i w_i u_(B_i)] <= EE_I [sum_i w_i u_(B_i)]. $

  By market alignment, $u_A - c - eps <= sum_i w_i u_(B_i) <= u_A - c + eps$ pointwise. Applying the lower bound on the left-hand side and the upper bound on the right-hand side gives

  $ EE_(I') [u_A] - c - eps <= EE_I [u_A] - c + eps. $

  The offset $c$ cancels, which proves the claim.
]

Read in the contrapositive, the lemma says that any change that would make Alice noticeably better off must also make some provider better off. Each ingredient of @def-ma-market-alignment is used exactly once in the proof.

- *Linearity.* Linearity of expectation turns $k$ separate statements about the providers' expected utilities into one statement about the expected value of $sum_i w_i u_(B_i)$, and hence about Alice. A nonlinear aggregate does not allow this step. Consider three outcomes on which $(u_(B_1), u_(B_2))$ equals $(1, 0)$, $(0, 1)$, and $(1\/2, 1\/2)$, and suppose $u_A = min(u_(B_1), u_(B_2))$, so Alice values compromise. Both providers are indifferent between a fair coin flip over the first two outcomes and the third outcome for sure, since each gets $1\/2$ in expectation either way. Alice gets $0$ from the coin flip and $1\/2$ from the compromise. The providers' incentives say nothing about Alice's.
- *Non-negativity.* Multiplying an inequality by $w_i >= 0$ preserves its direction. With a negative weight the argument breaks, and the conclusion can fail completely. If $u_A = -u_(B_1)$, so that Alice and a single provider play a zero-sum game, then every outcome the provider dislikes is one Alice prefers.
- *The offset.* Every distribution $I$ has $EE_I [c] = c$, so the constant appears on both sides and cancels. This is why $c$ may be any real number, as @ex-ma-drug-makers requires. The same reasoning shows that only the direction of $u_A$ matters, not its scale or offset, in line with the earlier remark on positive affine transformations.

This is what makes market alignment useful in the game between the providers. Equilibrium conditions constrain each provider's _own_ utility, and @lem-ma-no-gain is the step that turns those constraints into a statement about Alice's utility, even though no individual provider is on her side.

#lec_bibliography("meta/refs.bib")
