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
  No online algorithm can be exactly unbiased conditionally on every possible value of the other party's previous prediction. The definition of #citet(<collina2025tractable>) relaxes @def-ca-perfect-cc in two ways. First, the previous prediction $p^(t, k-1)$ is only located up to a bucket of width $g(T)$. Second, the predictions on each resulting subsequence $S$ only need to be within $ell_1$-distance $f(abs(S))$ of a perfectly calibrated sequence, where $f$ grows sublinearly. Such an agent is called _$(f, g)$-conversation-calibrated_. Such conditions can be enforced by efficient online algorithms without any prior. The analysis below then goes through with additive error terms that depend on $f$ and $g$; after normalizing the squared error by $T$, these terms vanish as $T -> infinity$ for suitable choices of $f$ and $g$. The resulting bound on the number of rounds, which involves a quantity $beta(T)$, is discussed in @sec-ca-approx-bound.
] <rem-ca-approximate>

#remark[Conversation calibration vs. Bayesian conditioning][

Although conversation calibration is computationally cheaper than Bayesian conditioning, it is also weaker than Bayesian conditioning, since it only restricts average outcomes over groups of days, rather than restricting each and every prediction on each day. In fact, we can show that a Bayesian with a correct prior is approximately conversation-calibrated.

Suppose that the days are drawn independently from a distribution, and that the human is a Bayesian whose prior is that distribution. Since the model's round-$(k-1)$ prediction and the human's own round-$k$ prediction are both part of the information the human conditions on, the expected outcome on the days where the model said $v'$ and the human said $v$ is exactly $v$. So over many days, the Bayesian human is approximately conversation-calibrated, with an error that vanishes as $T$ grows. (However, note that it will not necessarily satisfy @def-ca-perfect-cc exactly on a finite set of days.)

Note that the converse fails: someone who simply repeats the model's prediction is conversation-calibrated, but is not Bayesian, since they don't use their own information.
] <rem-ca-bayes>

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

== Agreement under approximate calibration <sec-ca-approx-bound>

@thm-ca-agreement assumed that both parties are perfectly conversation-calibrated, but no online algorithm can guarantee perfect conversation calibration. As such, we now describe a bound on the number of rounds under the approximate condition described in @rem-ca-approximate. The following result is due to #citet(<collina2025tractable>); we state it for a common $f$ and $g$, with $f$ nondecreasing and concave, which simplifies the $beta(T)$ term in their Theorem 3.1.

#theorem[Agreement under approximate conversation calibration][
  Suppose that both the human and the model are $(f, g)$-conversation-calibrated, and let
  $
    beta(T) := 6 (g(T) + f(g(T) dot T) / (g(T) dot T)).
  $
  Then for any $eps, delta in (0, 1]$ with $eps^2 delta > beta(T)$, the protocol achieves $(eps, delta)$-agreement within
  $
    K = 1 + ceil(1 / (eps^2 delta - beta(T)))
  $
  rounds.
] <thm-ca-approx-agreement>

We note that the bound of @thm-ca-agreement is just the special case of @thm-ca-approx-agreement when we set $beta(T) = 0$. 

#proofsketch[of @thm-ca-approx-agreement][
  This proof is the same as the proof of @thm-ca-agreement, except that the per-round guarantee in @lem-ca-one-round becomes weaker. There are two reasons each round now lowers the squared error by less than before:
  1. The speaker is only calibrated with respect to which bucket of width $g(T)$ the previous prediction falls into, not the exact value, which then reduces the guaranteed drop in squared error by $O(g(T) T)$.
  2. Within each bucket, the speaker's predictions are only close to calibrated, within distance $f$. Adding up this error over the $1 \/ g(T)$ buckets, and using that $f$ is concave, further reduces the guaranteed drop by $O(f(g(T) T) \/ g(T))$.

  Altogether,
  $
    "SQE"_(k-1) - "SQE"_k >= eps^2 abs(cal(T)_(k+1)) - beta(T) T,
  $
  and the rest of the argument is the same as in the proof of @thm-ca-agreement.
]

#paragraph-marker() *How many days are needed.*~~
Unlike @thm-ca-agreement, this bound depends on $T$: it gives $O(1 \/ (eps^2 delta))$ rounds only once $beta(T) <= eps^2 delta \/ 2$. With the efficient algorithm of #citet(<collina2025tractable>), which achieves $f(tau) = O(sqrt(tau))$ and $g(T) = T^(-1\/3)$, we get $beta(T) = O(T^(-1\/3))$, so $T = O(1 \/ (eps^6 delta^3))$ days suffice.

#lec_bibliography("meta/refs.bib")
