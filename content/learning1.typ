#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 5,
  date: [Tue, Sep 29, 2026],
  title: "Learning in games: Algorithms",
)

The #lecture-link("learning_intro", <sec-learning-applications>)[applications of regret minimization] show how no-external-regret dynamics recover several solution concepts of interest, including Nash equilibria in two-player zero-sum games, normal-form coarse-correlated equilibria in multiplayer general-sum games, and more generally convex-concave saddle point problems.

In this lecture, we begin exploring how no-external-regret dynamics can be constructed, starting from normal-form games.

= No-regret algorithms for normal-form games

For a player in normal-form games the strategy space corresponds to the probability simplex $Delta(A)$ of all distributions over the actions available to the player.
As a reminder, constructing a regret minimizer for $Delta(A)$ means that we need to build a mathematical object that supports two operations:
- `NextStrategy()` asks the regret minimizer to output the next strategy, which is a point $vx^((t)) in Delta(A)$;
- `ObserveUtility`$(u^((t)))$ provides the environment's feedback to the regret minimizer, in the form of a utility function $u^((t))$. For today, we will focus on a case of particular relevance for normal-form games: the case of _linear_ utilities (as such are the utilities in a normal-form game). In particular, to fix notation, we will let
  $
    u^((t)) : vx |-> ip(vg^((t)), vx),
  $
  where $vg^((t)) in RR^n$ is the vector that defines the linear function (called with the letter $vg$ to suggest the idea of it being the "_gradient vector_") and $ip(dot, dot)$ denotes the standard _dot_ product. Since the utility in the game cannot be unbounded, we assume that the $vg^((t))$ can be arbitrary but _bounded in norm_.
In this notation, the (external) _regret_ is defined as the quantity
$
  "Reg"^((T)) := max_(xhat in Delta(A)) {sum_(t=1)^T (ip(vg^((t)), xhat) - ip(vg^((t)), vx^((t))))}.
$
Our goal is to make sure that the regret grows sublinearly in $T$ no matter the utility vectors $vg^((t))$ chosen by the environment.

#box(
  fill: luma(94%),
  inset: 3mm,
  radius: 1.5mm,
)[
  *General principle*. Most algorithms known today for the task operate by _prioritizing actions based on how much regret they have incurred_. In particular, a key quantity to define modern algorithms is the vector of cumulated actions regrets
  $
    vr^((t)) := sum_(tau=1)^t lr(size: #150%, (vg^((tau)) - ip(vg^((tau)), vx^((tau))) vone)).
  $
  (Note that $"Reg"^((t)) = max_(a in A) r^((t))_a$.)
  The natural question is: _how to prioritize?_
]

== Follow-the-leader

Perhaps the most natural idea would be to always play the action with the highest cumulated regret (breaking ties, say, lexicograpsically). After all, this is the action we wish the most we had played in the past. This algorithm is called _follow-the-leader (FTL)_. Unfortunately, this idea is known not to work. To see that, consider the following sequence of gradient vectors:

$
  vg^((1)) = vec(0, 1\/2), quad vg^((2)) = vec(1, 0), quad vg^((3)) = vec(0, 1), quad vg^((4)) = vec(1, 0), quad vg^((
    5
  )) = vec(0, 1), quad #text(font: "New Computer Modern", style: "italic")[etc.]
$

In this case, at time $1$, we pick the first action and score a utility of 0. We then compute
$vr^((1)) = (0, 1\/2)$
and at time $t=2$ pick the second action since it has the highest regret. This results in a score of 0 and an updated regret vector
$vr^((2)) = (1, 1\/2)$
So, at time $t=3$, we will pick the first action, resulting again in a score of 0 and an updated regret
$vr^((3)) = (1, 3\/2)$
and so on...
Overall, it's easy to see that in all this jumping around, the regrets grow linearly.

Where to go from here? A few ideas seem natural:
- We can replace picking the action with the highest regret with picking actions _proportionally_ to their regret; this leads to the algorithm called _Regret Matching_, which we will discuss in @sec-rm.
- We can _smooth out_ the maximum operator by using the _softmax_ function. This leads to the _multiplicative weights update_ algorithm, which we will discuss in @sec-mwu.
- We can _regularize_ the maximum operator by adding a term that penalizes large jumps in the strategy space. This leads to a very flexible algorithm called _follow-the-regularized-leader_ algorithm, which we will discuss in @sec-ftrl as well as in the supplementary reading on #lecture-link("learning2", <sec-predictivity>)[predictive learning algorithms].

All these ideas work. Before we move on, though, it is worth knowing that---while flawed---the follow-the-leader algorithm is not completely hopeless.

#remark[Fictitious play][
  In the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], the use of follow-the-leader by all players goes under the name of _fictitious play_ #citep(<brown1949some>) #citep(<brown1951iterative>). In certain classes of games, including two-player zero-sum games, fictitious play is able to recover a Nash equilibrium, albeit with a potentially exponentially slow convergence rate #citep(<Robinson1951>).
]

== The Regret Matching (RM) algorithm <sec-rm>

The Regret Matching algorithm #citep(<Hart00:Simple>) picks probabilities proportional to the "ReLU" of the cumulated regrets, that is,

#set math.equation(numbering: "(1)")
$
  vx^((t+1)) prop \[vr^((t))\]^+
$ <eq-rm>
#set math.equation(numbering: none)
whenever $\[vr^((t))\]^+ != 0$, and an arbitrary point otherwise.

The algorithm is presented in pseudocode in @algo-rm.

#wrapped-figure(
  [
    #pseudocode-list(numbered-title: [Regret Matching])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *if* $[vr^((t-1))]^+ != 0$
          + *return* $vx^((t)) <- display(([vr^((t-1))]^+) / norm([vr^((t-1))]^+)_1)$
        + *else*
          + *return* $vx^((t)) <-$ any point in $Delta(A)$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone$
    ] <algo-rm>
  ],
  [
    #pseudocode-list(numbered-title: [Regret Matching#super[+]])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *if* $[vr^((t-1))]^+ != 0$
          + *return* $vx^((t)) <- display(([vr^((t-1))]^+) / norm([vr^((t-1))]^+)_1)$
        + *else*
          + *return* $vx^((t)) <-$ any point in $Delta(A)$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- [vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone]^+$
    ] <algo-rmp>
  ],
  side: right,
  text-width: 50%,
)

#theorem[Regret bound for RM][
  The Regret Matching algorithm (@algo-rm) is an external regret minimizer, and satisfies the regret bound $"Reg"^((T)) <= Omega sqrt(T)$, where $Omega$ is the maximum norm of $norm(vg^((t)) - ip(vg^((t)), vx^((t))) vone)_2$ up to time $T$.

  In particular, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ then the regret satisfies $ "Reg"^((T)) <= 2 sqrt(T dot |A|). $
] <thm-rm-regret>
#proof[
  We start by observing that, at all times $t$,
  $
    (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)^top vx^((t+1)) = 0
  $
  (this is always true, not just for Regret Matching). Plugging in the definition (@eq-rm) of how $vx^((t+1))$ is constructed, we therefore conclude that
  #set math.equation(numbering: "(1)")
  $
    (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)^top \[vr^((t))\]^+ = 0.
  $ <eqx>
  #set math.equation(numbering: none)
  (Note that the above equation holds trivially when $\[vr^((t))\]^+=0$ and therefore $vx^((t+1))$ is picked arbitrarily.)

  Now, we use the inequality
  $
    norm([va + vb]^+)_2^2 <= norm([va]^+ + vb)_2^2,
  $
  applied to $va = vr^((t))$ and $vb = vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone$. In particular, since by definition $va + vb = vr^((t+1))$, we have
  $
    norm(\[vr^((t+1))\]^+)_2^2 &<= norm(\[vr^((t))\]^+ + (vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone))_2^2 \
    &= norm(\[vr^((t))\]^+)_2^2 + norm(vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)_2^2 + 2 (
      vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone
    )^top \[vr^((t))\]^+ \
    &= norm(\[vr^((t))\]^+)_2^2 + norm(vg^((t+1)) - ip(vg^((t+1)), vx^((t+1))) vone)_2^2 #h(4.5cm) ("from" (#[@eqx]))\
    &<= norm(\[vr^((t))\]^+)_2^2 + Omega^2.
  $
  Hence, by induction we have
  $
    norm(\[vr^((T))\]^+)_2^2 <= T Omega^2,
  $
  which implies
  $
    "Reg"^((T)) = max_(a in A) r^((T))_a <= max_(a in A) #[~]\[ r^((T))_a \]^+ <= norm(\[vr^((T))\]^+)_2 <= Omega sqrt(T).
  $
  The proof of the first part is then complete. The second part then just follows from using the inequality
  $ Omega = max_(t<=T) norm(vg^((t)) - ip(vg^((t)), vx^((t)))vone)_2 <= 2 sqrt(|A|) max_(t<=T) norm(vg^((t)))_oo. $
  #v(-6mm)
]

Our interest for the regret bound under the specific condition that $norm(vg^((t)))_oo <= 1$ is as follows.
#remark[Within the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], the entries of $vg^((t))$ are the expected payoffs of all actions of the players. Thus, the condition $norm(vg^((t)))_oo <= 1$ corresponds to the condition that the game's payoffs lie in $[-1,1]$.]

As of today, Regret Matching and its variants are still often some of the most practical algorithms for learning in games.

#remark[
  One very appealing property of the Regret Matching algorithm is its _lack of hyperparameters_. It just works "out of the box".
]

== The Regret Matching#super[+] (RM#super[+]) algorithm <sec-rmp>

The Regret Matching#super[+] algorithm #citep(<Tammelin14:Solving>)#citep(<Tammelin15:Solving>) is given in @algo-rmp. It differs from RM only on the last line, where a further thresholding is added. That small change has the effect that actions with negative cumulated regret (that is, "bad" actions) are treated as actions with $0$ regret. Hence, intuitively, if a bad action were to become good over time, it would take less time for RM#super[+] to notice and act on that change.
Because of that, Regret Matching#super[+] has stronger practical performance and is often preferred over Regret Matching in the game solving literature.

With a simple modification to the analysis of RM, the same bound as RM can be proven.
#theorem[Regret bound for RM#super[+]][
  The RM#super[+] algorithm (@algo-rmp) is an external regret minimizer, and satisfies the regret bound $"Reg"^((T)) <= Omega sqrt(T)$, where $Omega$ is the maximum norm $norm(vg^((t)) - ip(vg^((t)), vx^((t))) vone)_2$ up to time $T$.

  So again, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ then the regret satisfies $ "Reg"^((T)) <= 2 sqrt(T dot |A|). $

]

== Multiplicative weights update (MWU) <sec-mwu>

#wrapped-figure(
  [
    If we replace the "hard" maximum of follow-the-leader with the "soft" maximum given by

    $
      x_a^((t+1)) & = "softmax"_(a)(eta vr^((t))) \
                  & := exp(eta r_a^((t))) / (sum_(j=1)^m exp(eta vr^((t))[j])),
    $
    where $eta > 0$ is an inverse temperature parameter, then we obtain the _multiplicative weights update_ algorithm #citep(<freund1997decision>).

    This algorithm is presented in @algo-mwu.
  ],
  [
    #pseudocode-list(numbered-title: [Multiplicative Weights Update])[
      + $vr^((0)) <- 0 in RR^A, quad vx^((0)) <- vone\/|A| in Delta(A)$
      + *function* `NextStrategy()`
        + *return* $vx^((t)) <-$ `softmax`$(eta vr^((t-1)))$
      + *function* `ObserveUtility`($vg^((t))$)
        + $vr^((t)) <- vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone$
    ] <algo-mwu>
  ],
  side: right,
  text-width: 47%,
)

Compared to RM, MWU has a different flavor: it uses _softmax_ instead of ReLU. This change in prioritization function has a pretty significant impact on the regret bound that multiplicative weights guarantees. In particular, the following can be shown:

#theorem[Regret bound for MWU][
  The regret cumulated by the MWU algorithm can be upper bounded as
  $
    "Reg"^((
      T
    )) <= (log |A|) / eta + eta sum_(t=1)^T norm(vg^((t)))_oo^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_1^2,
  $
  no matter the sequence of gradient vectors $vg^((t))$ chosen by the environment. In particular, if all the gradient vectors satisfy $norm(vg^((t)))_oo <= 1$ at all times $t$ and $eta = sqrt(log |A|\/ T)$, the regret satisfies

  $ "Reg"^((T)) <= 2 sqrt(T log |A|). $
]<mwu-regret-bound>
The general FTRL/OMD bound in @ftrl-omd-regret-bound implies @mwu-regret-bound; @sec-omd-mwu gives the entropy specialization.

For now, we remark a crucial aspect of MWU. Compared with the regret bound of RM and RM#super[+], the regret bound of MWU has only a _logarithmic_ dependence on the number of actions $|A|$. Despite in practice RM/RM#super[+] tend to outperform MWU (all while getting rid of any hyperparameter tuning), this property has profound _theoretical_ implications, especially in combinatorial games where the effective number of actions is exponential. The gist of it is that several important classes of games can be converted into _exponentially large_ normal-form games (this is the case of sequential games, for example). Since MWU only has logarithmic dependence on the number of actions of the resulting normal-form games, this shows that---at least ignoring computation---external regret minimization is possible with polynomial dependence on the game size even in these classes of complex, structured games.

== Worked example: three rounds of RM and MWU by hand <sec-rm-mwu-walkthrough>

The pseudocode of @algo-rm and @algo-mwu is short, but it is easy to lose track of which quantity is computed when. Here we run both algorithms by hand for three rounds on the same utility vectors and record every intermediate quantity, using follow-the-leader as a baseline.

*Setup.* The learner plays rock-paper-scissors, with actions $A = {upright(R), upright(P), upright(S)}$ listed in this order, and receives utility $+1$ for a win, $-1$ for a loss, and $0$ for a tie. The opponent plays Rock, then Paper, then Scissors. Entry $a$ of the utility vector $vg^((t))$ is the payoff that action $a$ would have earned against the opponent's move at time $t$, so
$
  vg^((1)) = (0, 1, -1), quad vg^((2)) = (-1, 0, 1), quad vg^((3)) = (1, -1, 0).
$
All three have $norm(vg^((t)))_oo <= 1$, as assumed in the simplified bounds of @thm-rm-regret and @mwu-regret-bound. Since $vg^((1)) + vg^((2)) + vg^((3)) = vzero$, every fixed action earns exactly $0$ in hindsight. The regret after the three rounds is therefore minus the total utility the learner collected:
$
  "Reg"^((3)) = max_(a in A) sum_(t=1)^3 g_a^((t)) - sum_(t=1)^3 ip(vg^((t)), vx^((t))) = -sum_(t=1)^3 ip(vg^((t)), vx^((t))).
$

*What happens in a round.* Each round $t$ of either algorithm performs the same four steps:
+ `NextStrategy()` turns the cumulated regrets $vr^((t-1))$ into a strategy $vx^((t))$. This is the only step in which RM and MWU differ.
+ The environment reveals $vg^((t))$, and the learner earns the expected utility $ip(vg^((t)), vx^((t)))$.
+ The _instantaneous regret_ $vg^((t)) - ip(vg^((t)), vx^((t))) vone$ records, for every action, how much better (or worse) it would have done than $vx^((t))$ in this round.
+ `ObserveUtility` adds it to the running total: $vr^((t)) = vr^((t-1)) + vg^((t)) - ip(vg^((t)), vx^((t))) vone$.

#example[Regret Matching, step by step][
  Both algorithms start from $vr^((0)) = vzero$. Since $[vr^((0))]^+ = vzero$, RM may play any strategy at $t = 1$; we pick the uniform one, as in the initialization of @algo-rm. Each column of the table is one round, and its last row determines the strategy of the next round.

  #align(center, table(
    columns: 4,
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    inset: (x: 2.2mm, y: 1.8mm),
    stroke: (x, y) => (
      top: if y == 0 { black + .4mm } else if y == 1 { black + .25mm } else { none },
      bottom: if y == 6 { black + .4mm } else { none },
    ),
    table.header([], [$t = 1$], [$t = 2$], [$t = 3$]),
    [strategy \ $vx^((t))$], $1/3 vec(1, 1, 1)$, $vec(0, 1, 0)$, $vec(0, 1, 0)$,
    [utility vector \ $vg^((t))$], $vec(0, 1, -1)$, $vec(-1, 0, 1)$, $vec(1, -1, 0)$,
    [expected utility \ $ip(vg^((t)), vx^((t)))$], $0$, $0$, $-1$,
    [instantaneous regret \ $vg^((t)) - ip(vg^((t)), vx^((t))) vone$], $vec(0, 1, -1)$, $vec(-1, 0, 1)$, $vec(2, 0, 1)$,
    [cumulated regret \ $vr^((t))$], $vec(0, 1, -1)$, $vec(-1, 1, 0)$, $vec(1, 1, 1)$,
    [positive part \ $[vr^((t))]^+$], $vec(0, 1, 0)$, $vec(0, 1, 0)$, $vec(1, 1, 1)$,
  ))

  - *Round 1.* The uniform strategy earns $0$. Only Paper would have done better, so $[vr^((1))]^+ = (0, 1, 0)$ and RM puts all its probability on Paper. Whenever exactly one action has positive regret, RM plays the same action as follow-the-leader.
  - *Round 2.* Paper ties against Paper. The regret of Scissors rises from $-1$ to $0$, but RM only reacts to _positive_ regrets, so it plays Paper again.
  - *Round 3.* Scissors beats Paper and RM loses $1$. Now every action has cumulated regret $1$, so $vx^((4)) = (1\/3, 1\/3, 1\/3)$.

  The total utility is $-1$, so $"Reg"^((3)) = 1 = max_(a in A) r_a^((3))$. Follow-the-leader (ties broken lexicographically) plays Rock, Paper, Paper and also ends with regret $1$; see @fig-rm-mwu-walkthrough.

  The run also shows the two steps of the proof of @thm-rm-regret at work. First, each new instantaneous regret is orthogonal to the positive part of the previous cumulated regret, as in (@eqx): from the table, $ip((-1, 0, 1), (0, 1, 0)) = 0$ at $t = 2$ and $ip((2, 0, 1), (0, 1, 0)) = 0$ at $t = 3$.
  Second, the potential $norm([vr^((t))]^+)_2^2$ therefore grows each round by at most the squared norm of the instantaneous regret. It takes the values $1, 1, 3$, and indeed $1 <= 0 + 2$, $1 <= 1 + 2$, and $3 <= 1 + 5$. With $Omega = norm((2, 0, 1))_2 = sqrt(5)$, the theorem guarantees $"Reg"^((3)) <= sqrt(5) dot sqrt(3) approx 3.87$.
] <ex-rm-walkthrough>

For MWU, one observation simplifies the arithmetic. Let $vG^((t)) := sum_(tau=1)^t vg^((tau))$ be the cumulated utility vector. The cumulated regret differs from it only by a multiple of $vone$:
$
  vr^((t)) = vG^((t)) - (sum_(tau=1)^t ip(vg^((tau)), vx^((tau)))) vone.
$
Adding the same constant $c$ to every entry does not change a softmax, because the factor $exp(eta c)$ cancels between numerator and denominator. Therefore
$
  vx^((t+1)) = "softmax"(eta vr^((t))) = "softmax"(eta vG^((t))), quad "that is," quad x_a^((t+1)) prop exp(eta G_a^((t))).
$
In other words, MWU's strategy depends only on the utilities the environment revealed, not on what the learner played. RM is different: its threshold $[dot]^+$ compares each action with the learner's own realized utility. We take $eta = log 2 approx 0.69$, which turns the weights into powers of two, $exp(eta G_a^((t))) = 2^(G_a^((t)))$, so every number below is an exact fraction. This is close to the value $sqrt(log 3 \/ 3) approx 0.61$ that @mwu-regret-bound prescribes for $T = 3$ and $|A| = 3$.

#example[MWU, step by step][
  The table has the same layout, with two changes: the first row holds the unnormalized weights $2^(vG^((t-1)))$ (taken entrywise), and the last row the cumulated utility $vG^((t))$.

  #align(center, table(
    columns: 4,
    align: (left + horizon, center + horizon, center + horizon, center + horizon),
    inset: (x: 2.2mm, y: 1.8mm),
    stroke: (x, y) => (
      top: if y == 0 { black + .4mm } else if y == 1 { black + .25mm } else { none },
      bottom: if y == 7 { black + .4mm } else { none },
    ),
    table.header([], [$t = 1$], [$t = 2$], [$t = 3$]),
    [weights \ $2^(vG^((t-1)))$], $vec(1, 1, 1)$, $vec(1, 2, 1\/2)$, $vec(1\/2, 2, 1)$,
    [strategy \ $vx^((t))$], $1/3 vec(1, 1, 1)$, $1/7 vec(2, 4, 1)$, $1/7 vec(1, 4, 2)$,
    [utility vector \ $vg^((t))$], $vec(0, 1, -1)$, $vec(-1, 0, 1)$, $vec(1, -1, 0)$,
    [expected utility \ $ip(vg^((t)), vx^((t)))$], $0$, $-1\/7$, $-3\/7$,
    [instantaneous regret \ $vg^((t)) - ip(vg^((t)), vx^((t))) vone$], $vec(0, 1, -1)$, $1/7 vec(-6, 1, 8)$, $1/7 vec(10, -4, 3)$,
    [cumulated regret \ $vr^((t))$], $vec(0, 1, -1)$, $1/7 vec(-6, 8, 1)$, $1/7 vec(4, 4, 4)$,
    [cumulated utility \ $vG^((t))$], $vec(0, 1, -1)$, $vec(-1, 1, 0)$, $vec(0, 0, 0)$,
  ))

  - *Round 1.* As for RM, the uniform strategy earns $0$.
  - *Round 2.* The weights are $(2^0, 2^1, 2^(-1)) = (1, 2, 1\/2)$, which normalize to $(2\/7, 4\/7, 1\/7)$. MWU favors Paper, as RM did, but keeps some probability on Rock and Scissors. Against Paper, this hedge costs $1\/7$: the $2\/7$ on Rock loses and the $1\/7$ on Scissors wins.
  - *Round 3.* The weights are $(1\/2, 2, 1)$, so $vx^((3)) = (1\/7, 4\/7, 2\/7)$. Mass moves from Rock (which just lost) to Scissors (which just won). Against Scissors, MWU loses $3\/7$, much less than RM's $1$: the $4\/7$ on Paper loses, but the $1\/7$ on Rock wins.

  Since $vG^((3)) = vzero$, MWU also returns to the uniform strategy at $t = 4$. Its total utility is $-4\/7$, so $"Reg"^((3)) = 4\/7 = max_(a in A) r_a^((3))$. With $eta = log 2$, the bound of @mwu-regret-bound gives
  $
    "Reg"^((3)) & <= (log 3) / (log 2) + 3 log 2 - 1 / (8 log 2) (norm(vx^((2)) - vx^((1)))_1^2 + norm(vx^((3)) - vx^((2)))_1^2) \
    & = (log 3) / (log 2) + 3 log 2 - 1 / (8 log 2) dot 136 / 441 approx 3.61,
  $
  where $norm(vx^((2)) - vx^((1)))_1 = 10\/21$ and $norm(vx^((3)) - vx^((2)))_1 = 2\/7$.
] <ex-mwu-walkthrough>

#figure(
  image(
    "figures/learning1/rm_mwu_walkthrough.svg",
    width: 100%,
    alt: "Strategies of follow-the-leader, Regret Matching, and MWU over four rounds of rock-paper-scissors, drawn on the probability simplex. Follow-the-leader jumps between the Rock and Paper corners, Regret Matching jumps from the center to the Paper corner and back, and MWU circles near the center.",
  ),
  caption: [The strategies $vx^((1)), dots, vx^((4))$ of @ex-rm-walkthrough and @ex-mwu-walkthrough, drawn on the simplex $Delta(A)$; corners are pure strategies and the center is the uniform strategy. Follow-the-leader jumps between corners, RM between the center and a corner, and MWU stays near the center.],
) <fig-rm-mwu-walkthrough>

The two runs illustrate four differences between RM and MWU.
- *Sparsity versus full support.* RM gives zero probability to every action whose cumulated regret is not positive (as long as some action has positive regret), so it can commit to a pure strategy. MWU gives every action positive probability, proportional to $exp(eta G_a^((t)))$. Here, committing was costly: the cycling opponent punished RM's pure strategy in round 3, just as it punished follow-the-leader.
- *How far the strategies move.* RM jumped from the center to a corner and back, moves of $ell_1$ length $norm((0, 1, 0) - (1\/3, 1\/3, 1\/3))_1 = 4\/3$. MWU never moved more than $10\/21$ in a single round (@fig-rm-mwu-walkthrough). This follows from MWU being FTRL with the entropy regularizer (@sec-omd-mwu): FTRL's strategies move by at most $eta norm(vg^((t)))_oo$ in $ell_1$ norm per round (@sec-ftrl), which is $log 2 approx 0.69$ here. This stability is what prevents the oscillations of follow-the-leader.
- *Hyperparameters.* RM has no parameters. MWU depends on $eta$: as $eta -> 0$ it stays at the uniform strategy, and as $eta -> oo$ it puts all its mass on the actions with the largest cumulated utility, which is follow-the-leader.
- *Worst-case bounds are loose on a single run.* The observed regrets ($1$ and $4\/7$) are far below the guarantees ($approx 3.87$ and $approx 3.61$), because the theorems must hold for _every_ sequence of utility vectors, including far more adversarial ones.

= More general approaches: FTRL and OMD <sec-ftrl>

Finally, we turn our attention to the third way of obtaining no-regret algorithms, that is, by considering a regularized (i.e., smoothed) version of the follow-the-leader algorithm discussed above. The idea is that, instead of playing by always putting 100% of the probability mass on the action with highest cumulated regret, we look for the distribution that maximizes the expected cumulated regret, _minus_ some regularization term that prevents us from putting all the mass on a single action.

#definition[Distance-generating function for a set][
  A function $psi : cX -> RR$, differentiable on the relative interior, is a _distance-generating function_ if it is $1$-strongly convex with respect to a specified norm. At points where the gradients exist, this means
  $ (nabla psi(vx) - nabla psi(vx'))^top (vx - vx') >= norm(vx - vx')^2 qquad forall vx,vx' in "ri"(cX) $
  with respect to some norm $norm(dot.c)$. Bregman divergences below are evaluated where their second argument is differentiable. Initialize the algorithms at a minimizer of $psi$; for entropy on the simplex this is the uniform distribution.
]

== FTRL in the normal-form case

#definition[FTRL, simplex case][
  Let $psi$ be a distance-generating function for the strategy set $Delta(A)$.
  The follow-the-_regularized_-leader algorithm (FTRL; sometimes also called "regularized follow-the-leader") defines the choice of strategy#footnote[In particular, $vx^((1)) := argmin_(xhat in Delta(A)) psi(xhat)$ since the regrets of all actions are $0$ at the beginning.]
  $
    vx^((t)) & := argmax_(xhat in Delta(A)) {ip(vr^((t-1)), xhat) - 1 / eta psi(xhat)}.
  $]
The regularization term $-psi(xhat)$ _limits the amount of variation between consecutive strategies_. This makes intuitive sense: if $eta -> 0$, $vx^((t))$ is constant (and equal to $argmin_(xhat in Delta(A)) psi(xhat)$). When $eta = oo$, we recover the follow-the-leader algorithm, where strategies can jump arbitrarily. For intermediate $eta$, as you might expect, the amount of variation between strategies at consecutive times is bounded above by a quantity proportional to $eta$:
$
  norm(vx^((t+1)) - vx^((t))) <= eta norm(vg^((t)))_*,
$
where $norm(dot.c)_*$ is the _dual_ norm of $norm(dot.c)$.

We will see the regret bound for FTRL in the general case in @ftrl-omd-general-case.

== OMD in the normal-form case

The last general method that we mention today is the _online mirror descent (OMD)_ algorithm. This is the online generalization of the mirror descent optimization method, one of the workhorses of modern optimization theory. A good way to think about OMD is as a generalization of gradient ascent.

#definition[OMD, simplex case][
  Let $psi : Delta(A) -> RR$ be a distance-generating function. The online mirror descent algorithm (OMD) defines the choice of strategy
  $
    vx^((t)) & := argmax_(xhat in Delta(A)) {ip(vg^((t-1)), xhat) - 1 / eta div(xhat, vx^((t-1)), dgf: psi)},
  $
  where
  $
    div(xhat, vx, dgf: psi) := psi(xhat) - psi(vx) - ip(nabla psi(vx), xhat - vx)
  $
  is called the _Bregman divergence_ associated with $psi$.
]

Two choices of regularizer are standard for the probability simplex:
- The _negative entropy_ function $H(vx) := sum_(a in A) x_a log x_a$. This is 1-strongly convex with respect to the $ell_1$ norm $norm(dot.c)_1$ (and therefore also with respect to $norm(dot.c)_2$). OMD instantiated with this regularizer leads to the multiplicative weights update algorithm seen in @sec-mwu; see also @sec-omd-mwu.

- The _squared Euclidean norm_ $psi(vx) := 1/2 norm(vx)_2^2$, which is 1-strongly convex with respect to the $ell_2$ norm $norm(dot.c)_2$. OMD instantiated with this regularizer leads to the online projected gradient descent algorithm, which we will discuss in @sec-ogd.

== The general case <ftrl-omd-general-case>

FTRL and OMD apply well beyond the case of probability simplices. In fact, they can be applied to any convex and compact domain $cX$. In this case, the vector of regrets $vr^((t))$ must be replaced with the cumulative gradient vector $sum_(tau=1)^t vg^((tau))$, as follows:
#definition[FTRL, general version][
  For a generic convex and compact domain $cX$, the FTRL algorithm produces strategies $vx^((t))$ by solving the optimization problem
  $ vx^((t)) := argmax_(xhat in cX) {ip(sum_(tau=1)^(t-1) vg^((tau)), xhat) - 1 / eta psi(xhat)}. $
]
#definition[OMD, general version][
  For $t>=2$, after initializing $vx^((1))$ as above, the OMD algorithm produces strategies $vx^((t))$ by solving the optimization problem
  $ vx^((t)) := argmax_(xhat in cX) {ip(vg^((t-1)), xhat) - 1 / eta div(xhat, vx^((t-1)), dgf: psi)}. $
]

We also remark the following connection between the two algorithms.

#remark[For linear utilities and a fixed learning rate, FTRL and OMD agree when the mirror updates stay in the interior of the regularizer's domain without additional active constraints. Their dual-coordinate updates then telescope. Entropy on the simplex is an example (working within its affine hull). With additional constraints, the required projections can make the two algorithms different.]

We mention the following regret bound for the general case. The supplementary reading on #lecture-link("learning2", <sec-rvu>)[predictive regret bounds] gives a stronger result when feedback is predictable.

#theorem[Regret bound for FTRL and OMD][
  The regret cumulated by the FTRL and OMD algorithms is upper bounded by
  $
    "Reg"^((
      T
    )) <= B / eta + eta sum_(t=1)^T norm(vg^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2,
  $
  where $B=max_(vx in cX) psi(vx)-min_(vx in cX) psi(vx)$ for FTRL, and $B=max_(vx in cX) div(vx, vx^((1)), dgf: psi)$ for OMD. The latter reduces to the former when the initial minimizer lies in the relative interior. We assume these quantities are finite. As above, $norm(dot.c)_*$ is the dual norm.
  In particular, if the norm of the gradient vectors is bounded, then by picking learning rate $eta = 1/sqrt(T)$, we obtain that $"Reg"^((T))$ is bounded as roughly $sqrt(T)$ (a sublinear function!) at all times $T$.
] <ftrl-omd-regret-bound>

== Multiplicative weights update (MWU) as a special case <sec-omd-mwu>

#wrapped-figure(
  [
    Multiplicative weights update is the special case of _both FTRL and OMD_ in which the regularizer $psi$ is set to the _negative entropy_ function
    $ H(vx) := sum_(a in A) x_a log x_a. $

    #example[
      The adjacent plot displays the negative entropy function in the case of $|A|=2$ actions.
    ]
  ],
  [
    #image(
      "figures/learning1/entropy.svg",
      width: 100%,
      alt: "Negative entropy on a two-action simplex, minimized at the uniform distribution.",
    )
  ],
  side: right,
  text-width: 65%,
)

The negative entropy function has the following properties:
- it is $1$-strongly convex with respect to the $ell_1$ norm $norm(dot.c)_1$;
- the maximum of the function is $0$, attained at any deterministic strategy;
- the minimum is attained at the uniformly random strategy $ overline(vx) = ( 1\/m, ..., 1\/m), $
  at which $H(overline(vx)) = m dot 1/m log 1/m = -log m$.

Plugging the bound above into the general analysis of FTRL and OMD algorithms (@ftrl-omd-regret-bound) yields @mwu-regret-bound.

== Online Projected Gradient Ascent <sec-ogd>

In the special case in which $psi(vx) := 1/2 norm(vx)_2^2$, then the OMD algorithm reduces to _online projected gradient ascent_.

#definition[Online projected gradient ascent][
  The online projected gradient ascent algorithm is the special case of OMD in which the regularizer is (half) the squared Euclidean norm, that is, $psi(vx) = 1/2 norm(vx)_2^2$. The choice of strategy is given by
  $
    vx^((t)) = argmax_(xhat in cX) {
      ip(vg^((t-1)), xhat) - 1 / (2 eta) norm(xhat - vx^((t-1)))_2^2
    } = #text(size: 14pt, $Pi$) _(cX)(vx^((t-1)) + eta vg^((t-1))).
  $
] <def-online-gradient-ascent>

Since the squared Euclidean norm is $1$-strongly convex with respect to the $ell_2$ norm, the regret bound for OGD can be derived from the general bound for OMD (@ftrl-omd-regret-bound) and is as follows.

#theorem[Regret bound for OGD][
  Let $D$ be the Euclidean diameter of $cX$. With any initial point in $cX$, projected gradient ascent satisfies
  $ "Reg"^((T)) <= D^2/(2 eta) + eta/2 sum_(t=1)^T norm(vg^((t)))_2^2. $
  On the simplex, $D <= sqrt(2)$. If $norm(vg^((t)))_oo <= 1$, then $norm(vg^((t)))_2^2 <= |A|$. Choosing $eta=sqrt(2/(T|A|))$ therefore gives
  $ "Reg"^((T)) <= sqrt(2T|A|). $
]<ogd-regret-bound>

The next plots illustrate the behavior of OGD and MWU in a simple $2 times 2$ game.

#example[
  The adjacent plots show the behavior of the online projected gradient ascent (OGD) and multiplicative weights update (MWU) algorithms in the $2 times 2$ game given by
  #wrapped-figure(
    [
      $ U_1 = mat(2, 1; 0, 2). $
      The unique Nash equilibrium of the game is in
      $
        vx^* & = (2/3, 1/3), \
        vy^* & = (1/3, 2/3).
      $
      The purple dot indicates the starting strategy. The gray dotted line tracks the profile of _average_ strategies, which converges to an approximate Nash equilibrium as proved by the #lecture-link("learning_intro", <thm-regret-gap>)[regret-to-equilibrium argument].
    ],
    [
      #image(
        "figures/learning1/ogd_mwu.svg",
        width: 100%,
        alt: "OGD and MWU trajectories in the two-by-two zero-sum game; averages converge to equilibrium.",
      )
    ],
    side: right,
    text-width: 36%,
  )
]

#lec_bibliography("meta/refs.bib")

#changelog[
  - 2025-10-05: Fixed typos (thanks George Cao!).
  - 2025-11-30: Fixed typo in summation $t -> tau$ (thanks Sophie Wang!).
]
