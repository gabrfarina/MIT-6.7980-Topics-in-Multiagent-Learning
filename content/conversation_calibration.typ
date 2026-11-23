#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 13,
  date: [Thu, Nov 5, 2026],
  title: "Alignment (part I)",
  instructor: [Natalie Collina],
)

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

#lec_bibliography("meta/refs.bib")