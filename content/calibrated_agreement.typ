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

// Tasks 4 and 5 (L13): normal calibration vs. conversation calibration.

= Calibration and conversation calibration <sec-cc>

 #citet(<collina2025tractable>) don't assume the parties are Bayesian. Instead, they ask that each party's predictions satisfy a stronger form of calibration, which they call conversation calibration. 

When we say calibration, we are not referring to an algorithm, but to a statistical property of a sequence of predictions and the outcomes that followed them. We can check whether it holds just by looking at the transcript after the fact, without any reference to a distribution over outcomes, and predictions produced in both Bayesian and non-Bayesian ways may all satisfy it. Online algorithms such as the one of are tools we can use to achieve calibration. We should be careful not confusing them with the property itself. The same applies to conversation calibration.

== Calibration <sec-cc-calibration>

Let's start with a single forecaster that, on each day $t = 1, ..., T$, predicts $p^t in [0, 1]$ and then observes the outcome $y^t in [0, 1]$. We can assume that the predictions take only finitely many values. We call the set of days $t$ on which $p^t = v$ the level set of $v$.

#definition[Perfect calibration][
  The predictions $p^1, ..., p^T$ are perfectly calibrated with respect to the outcomes $y^1, ..., y^T$ if, for every $v in [0, 1]$,
  $
    sum_(t = 1)^T bb(1)[p^t = v] dot (p^t - y^t) = 0.
  $
] <def-cc-calibration>

If we divide by the size of the level set of $v$, the condition reads that on the days on which the forecaster predicted $v$, the average outcome was exactly $v$. So if we go back and look at all the days on which our weather forecaster announced a 70% chance of rain, we should find that it rained on 70% of them. This means that our predictions are unbiased on their own level sets.

This idea goes back to #citet(<dawid1982well>). Note that, following #citet(<collina2025tractable>), we wrote the condition as a sum of signed errors $p^t - y^t$ rather than in terms of a conditional probability or expectation, since all we have is a fixed transcript. In practice, though, exact equality is too much to ask for. The paper quantifies how far a sequence is from being calibrated using the distance to calibration, that is, the $ell_1$ distance from $(p^1, ..., p^T)$ to the closest perfectly calibrated sequence, and asks that it grow sublinearly in $T$.

== Conversation calibration <sec-cc-conversation>

Let us now recall the protocol we saw in lecture. On each day $t = 1, ..., T$, the model and the human take turns announcing a prediction of $y^t$, with the model speaking in odd rounds and the human in even rounds. The conversation stops at the first round $k >= 2$ when $abs(p^(t, k) - p^(t, k-1)) < eps$, and then $y^t$ is revealed. We write $p^(t, k)$ for the prediction made at round $k$ of day $t$, regardless of who made it. We denote the set of days where the conversation reaches round $k$ as $cal(T)_k$.

#definition[Perfect conversation calibration][
  The speaker of round $k >= 2$ is _perfectly conversation-calibrated_ at round $k$ if, for all $v', v in [0, 1]$,
  $
    sum_(t in cal(T)_k) bb(1)[p^(t, k-1) = v'] dot bb(1)[p^(t, k) = v] dot (p^(t, k) - y^t) = 0.
  $
  The human (respectively, the model) is perfectly conversation-calibrated if it is so at every even (respectively, odd) round k ≥ 2.
] <def-cc-conversation>

It is worth pausing to compare this with @def-cc-calibration. The condition is now imposed round by round, and only on the days that reach that round. More importantly, we now take each level set of the speaker's own prediction and split it further, according to what the other party said in the previous round, and we ask the speaker to be unbiased on every piece. Note that we only look at the previous round, rather than at the whole history of the conversation. We discuss the reason for this choice separately.

#example[Round 2 of the protocol][
  To see what this means, suppose that on some days the human opens with $0.2$ and the model replies $0.1$, while on other days the human opens with $0.5$ and the model again replies $0.1$. For the model's round-2 predictions to be calibrated, it is enough that the average outcome over all of these days is $0.1$. Conversation calibration asks for more: the average outcome must be $0.1$ on the days on which the human said $0.2$, and also on the days on which the human said $0.5$. Basically we are asking the model's reply to be a correct refinement of whatever the human has said.
] <ex-cc-round-two>

#remark[The definition used in the paper][
  #citet(<collina2025tractable>) use an approximate version of @def-cc-conversation: instead of conditioning on the exact value of $p^(t, k-1)$, they condition on which bucket of width $g(T)$ contains it, and on each resulting subsequence they allow a small distance to calibration $f$ rather than requiring exact equality. @def-cc-conversation is the idealized interpretation with no error and one bucket per value.
] <rem-cc-paper>

== Conversation calibration is strictly narrower than calibration <sec-cc-narrower>

The two definitions have the same shape. Both ask the predictions to be unbiased, and they only differ in where we look for bias. With calibration we check on the level sets of the speaker's own prediction. With conversation calibration, at round $k$, we check on the intersections of those level sets with the level sets of the other party's previous prediction. Since every set of the first kind is a union of sets of the second kind, conversation calibration imposes more constraints, and so fewer sequences of predictions satisfy it. Therefore it is the strictly narrower of the two properties.


#lemma[Conversation calibration implies calibration][
  If the speaker of round $k >= 2$ is perfectly conversation-calibrated at round $k$, then its round-$k$ predictions are perfectly calibrated on the days in $cal(T)_k$, that is, for every $v in [0, 1]$,
  $
    sum_(t in cal(T)_k) bb(1)[p^(t, k) = v] dot (p^(t, k) - y^t) = 0.
  $
] <lem-cc-implies-calibration>

#proof[
  When we fix $v$ and sum the identity in @def-cc-conversation over the finitely many values $v'$ taken by the previous predictions, we find that on each day $t$, exactly one of the indicators $bb(1)[p^(t, k-1) = v']$ is equal to $1$, so summing over $v'$ makes them disappear, and we are left with exactly the identity in the statement.
]

#example[Calibrated but not conversation-calibrated][
  Let's consider two days, both of which reach round $k$, with outcomes $y^1 = 0$ and $y^2 = 1$. In round $k - 1$ the other party announced $p^(1, k-1) = 0$ and $p^(2, k-1) = 1$, and in round $k$ the speaker announces $1 \/ 2$ on both days.

  The round-$k$ predictions are perfectly calibrated, since their only level set is ${1, 2}$ and the average outcome on it is $1 \/ 2$. However, they are not conversation-calibrated. Indeed, the only day on which the previous message was $v' = 0$ is day $1$, and on that day the speaker said $1 \/ 2$ while the outcome was $0$.
] <ex-cc-strict>

In this example the speaker simply ignored the information contained in the other party's message. If we only ask for calibration, we have no way of noticing this, because we only ever look at the speaker's own level sets. If instead we ask for conversation calibration, we catch it immediately, and in fact we force the speaker to predict $0$ on day $1$ and $1$ on day $2$.

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

#lec_bibliography("meta/refs.bib")
