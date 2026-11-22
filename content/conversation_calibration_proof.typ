#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 13,
  date: [Thu, Oct 29, 2026],
  title: "Alignment (part I)",
  instructor: [Natalie Collina],
)

// L13 material contribution: proof of Theorem 3.1 under exact conversation calibration.
// Standalone section for later integration with the other L13 sections.

= Proof of Theorem 3.1 Under Exact Conversation Calibration <sec-conversation-calibration-proof>

== Setting and Definitions

We have days $t = 1, 2, ..., T$, each of them containing some outcome $y_t in [0, 1]$. A human and a model both predict the value of $y_t$, possibly with disagreement.

On each day $t$, the human and the model have a _conversation_. They take turns giving predictions for each round $k$, with odd $k$ corresponding to model predictions, and even $k$ corresponding to human predictions. Accordingly, we write $p_t^k$ as the round-$k$ prediction on the $t$th day.

Each day's conversation ends when the model and human predictions meet $eps$-agreement, where $abs(p_t^k - p_t^(k-1)) <= eps$ (the distance between the human and model predictions is less than some predefined threshold $eps$) for rounds $k >= 2$. We only receive feedback on $y_t$ after the conversation ends.

Let $T^(>= k) subset.eq {1, 2, ..., T}$ denote the days whose conversation reaches round $k$. Note that these sets are nested, so $T^(>= k + 1) subset.eq T^(>= k)$.

Finally, we have the conversation calibration assumption. Define $S_k (v', v) = {t in T^(>= k) : p_t^(k - 1) = v', p_t^k = v}$ as the set of days where the other party predicted $v'$ at round $k - 1$ and the current speaker responded with prediction $v$ at round $k$. Conversation calibration assumes that $sum_(t in S_k (v', v)) (y_t - v) = 0$. This means that on the days in $S_k (v', v)$, the outcomes $y_t$ average exactly $v$, so even given the other party's prediction, the speaker's prediction is unbiased for any $k >= 2$ and $v, v' in [0, 1]$.

== Theorem Statement

Assume that both parties are conversationally calibrated. Then, for any $eps, delta in (0, 1)$ and any $K >= 1 + 1 / (eps^2 delta)$, at most $delta T$ days need more than $K$ rounds, i.e. $abs(T^(>= K + 1)) <= delta T$.

In other words, on all but a $delta$ fraction of days, the parties will reach agreement within about $1 / (eps^2 delta)$ rounds.

== Theorem Proof

Define $k_t$ to be the last round of day $t$. Let $q_t^k = p_t^(min(k, k_t))$ be the $k$th prediction on the $t$th day, clipped at the final prediction. Also define
$
  "MSE"_k = 1 / T sum_(t=1)^T (q_t^k - y_t)^2
$
Note that $"MSE"_k in [0, 1]$, since both $q_t^k$ and $y_t$ are in the range $[0, 1]$.

*Lemma 1:*
We claim that for any non-empty set of days $S$ with mean outcome $m = 1 / abs(S) sum_(t in S) y_t$ and any constant $x$, we have:
$
  sum_(t in S) (x - y_t)^2 = sum_(t in S) (m - y_t)^2 + abs(S) (x - m)^2
$
This can be shown by writing $x - y_t = (x - m) + (m - y_t)$, which gives us:
$
  sum_(t in S) (x - y_t)^2 = abs(S) (x - m)^2 + 2 (x - m) sum_(t in S) (m - y_t) + sum_(t in S) (m - y_t)^2
$
The middle term cancels since $sum_(t in S) (m - y_t) = abs(S) m - sum_(t in S) y_t = 0$, giving us:
$
  sum_(t in S) (x - y_t)^2 = sum_(t in S) (m - y_t)^2 + abs(S) (x - m)^2
$
Which is what we were meant to show.

*Lemma 2:*
We claim that the MSE monotonically decreases with $k$. Fix any round $k >= 2$.

Since any day outside of $T^(>= k)$ ended before round $k$, this means that $q_t^k = q_t^(k-1)$ (as we clip to the last round), so the MSE contributions are identical. Meanwhile, any day inside of $T^(>= k)$ has $q_t^(k-1) = p_t^(k - 1)$ and $q_t^k = p_t^k$. This means that we have:
$
  T ("MSE"_(k - 1) - "MSE"_k) = sum_(t in T^(>= k)) [(p_t^(k-1) - y_t)^2 - (p_t^k - y_t)^2]
$

We note that each day $t in T^(>= k)$ belongs to exactly one set $S_k (v', v)$, determined by the last two predictions $p_t^(k-1), p_t^k$. Fix one of these sets. By our conversation calibration assumption, the mean outcome of this set is $v$. By Lemma 1 with $x = v'$ and $m = v$, we have:
$
  sum_(t in S_k (v', v)) [(v' - y_t)^2 - (v - y_t)^2] = abs(S_k (v', v)) (v' - v)^2
$

Then, summing over all of the prediction pairs observed at round $k$, we get:
$
  T ("MSE"_(k - 1) - "MSE"_k) = sum_(t in T^(>= k)) (p_t^(k - 1) - p_t^k)^2 >= 0
$
This means that the MSE is monotonically decreasing, proving Lemma 2.

*Completing the proof.*
Suppose for the sake of contradiction that more than $delta T$ days need more than $K$ rounds to meet the $eps$ threshold. On each of these days, the predictions differed by more than $eps$ at every round $k = 2, ..., K$, as otherwise, the conversation would have ended.

Fix any such round $k$. By Lemma 2, we have:
$
  "MSE"_(k-1) - "MSE"_k = 1 / T sum_(t in T^(>= k)) (p_t^k - p_t^(k - 1))^2 > delta eps^2
$
As more than $delta T$ terms exceed $eps^2$, and all other terms are nonnegative.

Summing over the $K - 1$ rounds, we obtain:
$
  "MSE"_1 - "MSE"_K > (K - 1) delta eps^2 >= 1
$
Where the last inequality follow from the definition $K >= 1 + 1 / (delta eps^2)$.

However, this is impossible, as $"MSE"_1 <= 1$ (as shown earlier) and $"MSE"_K >= 0$ (as all terms are nonnegative). Therefore, at most $delta T$ days need more than $K$ rounds, as claimed.
