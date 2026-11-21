#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 13,
  date: [Thu, Nov 5, 2026],
  title: "Alignment (part I)",
  instructor: [Natalie Collina],
)
 
// Task 6 (L13): why conversation calibration conditions only on the other
// agent's prediction from the previous round.
// Notation follows the Tasks 7-8 section (PR #196): days t, rounds k, a single
// symbol p^(t, k) for whoever speaks at round k, and T_k for the days that
// reach round k. The recap in the first paragraph can be trimmed once the
// Tasks 4-5 section defines conversation calibration.
// Drafted with assistance from Claude (Anthropic).
 
= Why only the previous round? <sec-prev-round>
 
Recall the repeated agreement protocol. On each day $t = 1, ..., T$, a model and a human take turns announcing predictions of an outcome $y^t in [0, 1]$: the model speaks in odd rounds and the human in even rounds, and the conversation on day $t$ stops as soon as two consecutive predictions are within $eps$ of each other. We write $p^(t, k)$ for the prediction made at round $k$ of day $t$, whoever the speaker is, and $cal(T)_k$ for the set of days on which the conversation reaches round $k$. Conversation calibration asks the speaker of each round $k >= 2$ to be unbiased on the days in $cal(T)_k$, conditionally on its own prediction _and_ on the prediction that the other agent made in round $k - 1$. In its idealized form, for all values $v'$ and $v$,
#set math.equation(numbering: "(1)")
$
  sum_(t in cal(T)_k) bb(1)[p^(t, k-1) = v'] dot bb(1)[p^(t, k) = v] dot (v - y^t) = 0.
$ <eq-prev-cc>
#set math.equation(numbering: none)
 
This choice of conditioning may look arbitrary. A Bayesian agent is unbiased conditionally on _everything_ it has observed, including the whole conversation, while ordinary calibration conditions only on the agent's own prediction. Conversation calibration sits in between: it adds exactly one piece of the conversation, namely the other agent's most recent prediction. In this section we explain why this is the right amount. Conditioning on less would not guarantee agreement, and conditioning on more would not improve the guarantee but would make the condition far harder to satisfy. Both points are made by #citet(<collina2025tractable>), who introduced the definition.
 
#lec_bibliography("meta/refs.bib")
