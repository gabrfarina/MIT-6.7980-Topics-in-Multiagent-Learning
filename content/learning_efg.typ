#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 8,
  date: [Thu, Oct 8, 2026],
  title: "Learning in extensive-form games",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

Several approaches for constructing no-regret algorithms for extensive-form games have been proposed. For one, extensive-form games are a particular instance of combinatorial games for which the multiplicative weights update algorithm can be implemented efficiently in the reduced normal form of the game, despite the exponential size. #lecture-link("kernelized", none)[] develops this construction.

The #lecture-link("efg_intro", <sec-sequence-form>)[_sequence-form representation_] is the natural representation of strategies for learning in extensive-form games. Indeed, in that representation utility functions are linear and the strategy set of each player a convex polytope, aligning with the requirements of the regret minimization framework.

Thanks to the sequence form representation of strategies, all the results about external regret minimization we have seen so far apply to extensive-form games as well, including for example the fact that a Nash equilibrium in a two-player zero-sum game can be found by letting two regret minimizers play against each other by exchanging sequence-form strategies at every iteration according to the #lecture-link("learning_intro", <sec-learning-zero-sum>)[canonical self-play setup].

#align(center, image("figures/learning_intro/self_play.svg", width: 9cm))

Another example is the computation of coarse correlated equilibria in any multiplayer extensive-form game via external regret minimization, or computation of best responses against static opponents.

To construct an external regret minimizer that outputs sequence-form strategies, several approaches can be followed. For one, we have seen that one can always use the #lecture-link("learning1", <def-online-gradient-ascent>)[online projected gradient ascent algorithm], which is a particular instantiation of online mirror descent (OMD). The drawback of such approach is that it requires projecting onto the polytope of sequence form strategies, which might be laborious. Alternative regularizers (_i.e._, distance-generating functions) that render projection easier have been proposed. However, for today we focus on a different approach, which has been extremely popular in practice: the _counterfactual regret minimization (CFR)_ algorithm.

= The CFR algorithm <sec-cfr>

The idea of the CFR algorithm is simple: construct a regret minimizer for the whole tree-form problem starting from _local_ regret minimizers at each decision point, each learning what actions to play at that decision point.

#example[
  As an example, consider the TFDP faced by Player~1 in the game of Kuhn poker~#citep(<Kuhn50:Simplified>), introduced in the #lecture-link("efg_intro", <sec-tfdp>)[tree-form decision process example]. The black nodes are the _decision points_ of the player, and the white nodes are the _observation points_.

  #align(center, image("figures/learning_efg/kuhn_tfdp-transparent.png", width: 9cm))

  Since the player has six decision points---denoted $j_1 \, ... \, j_6$ in the figure---the CFR algorithm will use six local regret minimizers, which we denote $R_1 \, ... \, R_6$. Each regret minimizer $R_j$ will be responsible for outputting a local strategy $vb_j in Delta (A_j)$ for the decision point $j$.

] <ex:cfr-kuhn>

The local distributions output by the different local regret minimizers are then combined to form a _sequence-form strategy_ that plays according to the local distributions at each decision point.

== Where the magic happens: Counterfactual utilities

What is the training signal that each local regret minimizer receives? In other words, what is the utility that the regret minimizer at decision point $j$ observes? The answer is the _counterfactual utility_.

Remember that in the sequence form representation, the dimensionality of the strategy vectors matches the number of actions controlled by the players. Hence, the gradient vector received by the regret minimizer has one entry per each action controlled by the player, intuitively representing whether the "probability flow" passing through that action scores well or poorly. The idea of counterfactual utilities is to use as training signal for every $R_j$ the vector of expected utilities in the subtrees rooted at each of the actions $a in A_j$.

It can be shown that the regret cumulated by the CFR algorithm satisfies the following bound.

#theorem[
  Let $upright("Reg")_j^(\( T \))$, for $j in cal(J)$, denote the regret cumulated up to time $T$ by each of the regret minimizers $R_j$. Then, the regret $upright("Reg")^(\( T \))$ cumulated by @algo:cfr up to time $T$ satisfies

  $ upright("Reg")^(\( T \)) <= sum_(j in cal(J)) max {0 \, upright("Reg")_j^(\( T \))} . $
]

It is then immediate to see that if each $upright("Reg")_j^(\( T \))$ grows sublinearly in $T$, then so does $upright("Reg")^(\( T \))$.

In order to formally introduce counterfactual utility, we recall a bit of notation to deal with tree-form decision processes.

*Notation for tree-form decision processes*  We recall the following notation for dealing with tree-form decision processes (TFDPs), introduced in #lecture-link("efg_intro", <sec-tfdp-notation>)[]. The notation is also summarized in @tab:notation.

- We denote the set of decision points in the TFDP as $cal(J)$, and the set of observation points as $cal(K)$. At each decision point $j in cal(J)$, the agent selects an action from the set $A_j$ of available actions. At each observation point $k in cal(K)$, the agent observes a signal $s_k$ from the environment out of a set of possible signals $S_k$.
- We denote by $rho$ the transition function of the process. Picking action $a in A_j$ at decision point $j in cal(J)$ results in the process transitioning to $rho (j \, a) in cal(J) union cal(K) union {tack.t}$, where $tack.t$ denotes the end of the decision process. Similarly, the process transitions to $rho (k \, s) in cal(J) union cal(K) union {tack.t}$ after the agent observes signal $s in S_k$ at observation point $k in cal(K)$.
- A pair $(j \, a)$ where $j in cal(J)$ and $a in A_j$ is called a _sequence_. The set of all sequences is denoted as $Sigma := {(j \, a) : j in cal(J) \, a in A_j}$. For notational convenience, we will often denote an element $(j \, a)$ in $Sigma$ as $j a$ without using parentheses.
- Given a decision point $j in cal(J)$, we denote by $p_j$ its _parent sequence_, defined as the last sequence (that is, decision point-action pair) encountered on the path from the root of the decision process to $j$. If the agent does not act before $j$ (that is, $j$ is the root of the process or only observation points are encountered on the path from the root to $j$), we let $p_j = ∅$.

#example[
  As an example, consider again the TFDP faced by Player~1 in the game of Kuhn poker~#citep(<Kuhn50:Simplified>), which was also recalled above in @ex:cfr-kuhn. We have that $cal(J) = {j_1 \, ... \, j_6}$ and $cal(K) = {k_1 \, ... \, k_4}$. We have:

  $
    A_(j_1) = S_(k_4) & = {sans("check") \, sans("raise")} \, #h(2em) & A_(j_5) & = {sans("fold") \, sans("call")} \, #h(2em) & S_(k_1) & = {sans("jack") \, sans("queen") \, sans("king")}\
    p_(j_4) & = (j_1 \, sans("check")) \, #h(2em) & p_(j_6) & = (j_3 \, sans("check")) \, #h(2em) & p_(j_1) & = p_(j_2) = p_(j_3) = ∅ .
  $

  Furthermore,

  $
    rho (k_3 \, sans("check")) & = rho (j_2 \, sans("raise")) = tack.t \, #h(2em) & rho (k_1 \, sans("king")) & = j_3 \, #h(2em) rho (j_2 \, sans("check")) = k_3 .
  $
]

*Notation for the components of vectors*  Any vector $vx in bb(R)^Sigma$ has, by definition, as many components as sequences $Sigma$. The component corresponding to a specific sequence $j a in Sigma$ is denoted as $vx [j a]$. Similarly, given any decision point $j in cal(J)$, any vector $vx in bb(R)^(A_j)$ has as many components as the number of actions at $j$. The component corresponding to a specific action $a in A_j$ is denoted $vx \[ a \]$.

#figure(
  kind: table,
  supplement: [Table],
  caption: [Notation for tree-form decision processes used in the CFR algorithm.],
)[

  #table(
    stroke: none,
    columns: (auto, 1fr),
    align: (col, row) => if col == 0 { center + top } else { left + top },
    inset: .7em,
    table.header([*Symbol*], [*Description*]),
    [$cal(J)$], [Set of decision points],
    [$A_j$], [Set of legal actions at decision point $j in cal(J)$],
    [$cal(K)$], [Set of observation points],
    [$S_k$], [Set of possible signals at observation point $k in cal(K)$],
    [$rho$],
    [Transition function:

      - given $j in cal(J)$ and $a in A_j$, $rho \( j \, a \)$ returns the next decision or observation point $v$ in $cal(J) union cal(K)$ in the decision tree that is reached after selecting legal action $a in A_j$, or $tack.t$ if the decision process ends;
      - given $k in cal(K)$ and $s in S_k$, $rho \( k \, s \)$ returns the next decision or observation point $v in cal(J) union cal(K)$ in the decision tree that is reached after observing signal $s$ at $k$, or $tack.t$ if the decision process ends.
    ],

    [$Sigma$], [Set of sequences, defined as $Sigma := { \( j \, a \) : j in cal(J) \, a in A_j }$],
    [$p_j$],
    [Parent sequence of decision point $j in cal(J)$, defined as the last sequence (decision point-action
      pair) on the path from the root of the TFDP to decision point $j$; if the agent does not act
      before $j$, $p_j = ∅$.],
  )
] <tab:notation>

== Pseudocode for CFR
=== Setting the Stage

Although its mathematical formulation can look complicated, the central idea of counterfactual regret minimization (CFR) can be understood as a repeated three-step process:

1. *Evaluate our options.* Calculate how useful each available action would be under the current strategy, accounting for the possible outcomes that follow it.

2. *Measure regret.* Compare the utility of each action with the expected utility of following the current strategy. This tells us which actions performed better or worse than expected.

3. *Update the strategy.* Use the cumulative regrets to adjust the probabilities assigned to each action.

These steps are repeated over many iterations. Over time, the algorithm learns to assign greater probability to actions that have performed better than the current strategy would suggest.

We define three main concepts that are important to the CFR algorithm.

1. *Strategy.* A strategy specifies the probability of choosing each available action at a decision point. For example, a player might play with probability 0.7 and fold with probability 0.3.

2. *Counterfactual utility.* Counterfactual utility measures how good each action would be if we chose it, given the possible outcomes that follow it. We compute it even if our current strategy assigns a low probability to that action.

3. *Regret.* Regret is the difference between an action's counterfactual utility and the expected utility of the current strategy. An action that does better than the current strategy's expected utility has a positive instantaneous regret. An action that does worse has a negative instantaneous regret.

Counterfactual utility tells us how good each action is; regret compares that utility with the expected utility of our current strategy.

=== Information Sets and Sequence-Form Strategies

In an extensive-form game with imperfect information, a player may not know the exact history of the game when making a decision. An information set groups together histories that the player cannot distinguish. The player must use the same action probabilities at every history in the same information set.

CFR updates the strategy at these decision points while respecting the information available to the player. In the pseudocode below, $j$ denotes a decision point (information set), and $sigma_j (a)$ denotes the probability of choosing action $a in A_j$ there. In other words, $sigma_j in Delta(A_j)$ is the local strategy output by the regret minimizer $R_j$, which we also denoted $vb_j$ earlier.

The lecture's formal algorithm represents strategies in sequence form. Rather than storing only the probability of each action independently, sequence form represents the probability of realizing a player's own sequence of actions. If $p_j$ is the parent sequence of $j$, then

$ vx[j a] = vx[p_j] dot sigma_j (a), $

where $vx[j a]$ is the realization probability of the sequence $j a$, and we use the convention $vx[emptyset] = 1$ for the empty sequence.

Thus, CFR's regret updates determine the local action probabilities, while sequence form combines these probabilities into a consistent representation of the player's strategy.

=== Computing the counterfactual utility $Q_j (a)$

To find the counterfactual utility of an action, we ask: _"If I take this action, how much do I expect to earn from here on?"_ The answer has two parts:

1. *What I get right away.* Some actions pay off immediately, for example folding ends the hand with a fixed loss. Other actions pay nothing yet because the game continues.
2. *What I expect to get later.* If the game continues after the action, we look at the decisions and events that follow and average the outcomes. Here we assume we keep playing our _current_ strategy at all later decision points.

Then we add the two parts together:

$ Q_j (a) = "immediate payoff of " a + "expected payoff of what follows " a . $

$Q_j (a)$ doesn't depend on how likely we are to pick $a$ right now. We only ask what would happen _if_ we picked it, so we can compute it even for actions we currently play with probability zero. That is what we mean by "counterfactual".

*Work from the bottom up.* The "what follows" part requires knowing the values of the decision points further down the tree. So we start at the end of the game and work back toward the start:

- At a decision point, the value is the average of its actions' values, weighted by how often our current strategy picks each one.
- At an observation point, the value is the sum of the values of the possible outcomes. (We add rather than average because the probability of each outcome is already included in the payoffs.)

_For readers who want the math:_ $ Q_j (a) = vg[j a] + V(rho(j, a)) , $ where $vg[j a]$ is the immediate payoff of $a$, and $V(rho(j, a))$ is the expected payoff of the subtree reached after $a$ when we keep playing the current strategy.



Now that we have built a framework for understanding CFR, we can dive into the full pseudocode, given in @algo:cfr. The symbols it uses are summarized in @tab:cfr-notation.


#figure(
  kind: table,
  supplement: [Table],
  caption: [Symbols used in the CFR pseudocode.],
)[
  #table(
    stroke: none,
    columns: (auto, 1fr),
    align: (col, row) => if col == 0 { center + top } else { left + top },
    inset: .7em,
    table.header([*Symbol*], [*Description*]),
    [$sigma_j (a)$], [Probability of choosing action $a in A_j$ at decision point $j$ under the current strategy],
    [$vg [j a]$], [Immediate payoff for playing action $a$ at decision point $j$],
    [$Q_j (a)$], [Counterfactual utility of action $a$ at $j$],
    [$U_j$], [Expected utility of the current strategy at $j$],
    [$r_j (a)$], [Instantaneous regret of action $a$ at $j$: $Q_j (a) - U_j$],
    [$C_j (a)$], [Cumulative regret of action $a$ at $j$: the running sum of $r_j (a)$ over iterations],
    [$C_j^+ (a)$], [Positive part of the cumulative regret: $max(C_j (a), 0)$],
  )
] <tab:cfr-notation>




#pseudocode-list(numbered-title: [CFR: Counterfactual Regret Minimization])[
  - _Initialize:_
  + *for each* decision point $j in cal(J)$ and each action $a in A_j$:
    + $C_j (a) <- 0$ #h(1em) _cumulative regret_
    + $sigma_j (a) <- 1 / abs(A_j)$ #h(1em) _uniform (or another initial) strategy_
  + *for* $t = 1, 2, dots$ *do*
    - _Step 1: evaluate our options._
    + Observe the utility vector $vg in RR^Sigma$.
    + Compute $Q_j (a)$ (counterfactual) for all $j in cal(J)$ and $a in A_j$, as described above.
    - _Step 2: measure regret._
    + *for each* decision point $j in cal(J)$:
      + $U_j <- sum_(a in A_j) sigma_j (a) dot Q_j (a)$ #h(1em) _expected utility of the current strategy_
      + *for each* action $a in A_j$:
        + $r_j (a) <- Q_j (a) - U_j$ #h(1em) _instantaneous regret_
        + $C_j (a) <- C_j (a) + r_j (a)$ #h(1em) _update cumulative regret_
    - _Step 3: update the strategy._
    + *for each* decision point $j in cal(J)$:
      + *for each* action $a in A_j$:
        + $C_j^+ (a) <- max(C_j (a), 0)$
      + *if* $sum_(b in A_j) C_j^+ (b) > 0$:
        + *for each* action $a in A_j$:
          + $sigma_j (a) <- C_j^+ (a) / (sum_(b in A_j) C_j^+ (b))$
      + *else*:
        + *for each* action $a in A_j$:
          + $sigma_j (a) <- 1 / abs(A_j)$ #h(1em) _fall back to the uniform distribution_
] <algo:cfr>

=== Worked example: one iteration of CFR


To better understand the CFR algorithm, we will walk through one iteration of a small example. 

Consider a small game between players A and B. Each player is dealt card 1 with probability $1/3$ or card 2 with probability $2/3$, independently, and sees only their own card (@fig:cfr-tree). Player A moves first and either plays or folds. If A folds, A pays B 15. Otherwise B plays or folds. If B folds, B pays A 15. If both play, the payoffs depend on the cards, as shown at the leaves.

Each player has two decision points, one per card they might hold: $"A1"$, $"A2"$, $"B1"$, $"B2"$. We start from the strategy shown in the figure, with all cumulative regrets $C_j (a) = 0$.

#figure(
  image("figures/learning_efg/cfr_example_tree.png", width: 100%),
  caption: [The example game. Chance deals the cards $("A's card", "B's card")$. Leaves show payoffs $(A, B)$. Nodes with the same label (such as the two $"A1"$ nodes) are the same decision point, because the player cannot see the opponent's card.],
) <fig:cfr-tree>


#figure(
  kind: table,
  supplement: [Table],
  caption: [Payoffs $(A, B)$ when both players play. If A folds, the payoffs are $(-15, 15)$. If A plays and B folds, they are $(15, -15)$.],
)[
  #table(
    columns: 4,
    stroke: none,
    align: center + horizon,
    inset: .6em,
    table.cell(colspan: 2, rowspan: 2)[],
    table.cell(colspan: 2)[*B's card*],
    [*1*], [*2*],
    table.hline(),
    table.cell(rowspan: 2)[*A's card*], [*1*], [$(-10, 10)$], [$(-20, 30)$],
    [*2*], [$(25, -30)$], [$(5, 15)$],
  )
] <tab:cfr-payoffs>
\



*Step 1: evaluate our options.* For each action, we add up the payoffs, weighted by the probability that the opponent's card and action lead there. Folding gives an immediate payoff, so $Q_"A1" (sans("fold")) = Q_"A2" (sans("fold")) = -15$. For the other actions:

$
  Q_"A1" (sans("play")) & = 1/3 (0.2)(-10) + 1/3 (0.8)(15) + 2/3 (0.4)(-20) + 2/3 (0.6)(15) = 4, \
  Q_"A2" (sans("play")) & = 1/3 (0.2)(25) + 1/3 (0.8)(15) + 2/3 (0.4)(5) + 2/3 (0.6)(15) = 13, \
  Q_"B1" (sans("play")) & = 1/3 (0.6)(10) + 2/3 (0.8)(-30) = -14, \
  Q_"B1" (sans("fold")) & = 1/3 (0.6)(-15) + 2/3 (0.8)(-15) = -11.
$

In the same way, $Q_"B2" (sans("play")) = 14$ and $Q_"B2" (sans("fold")) = -11$. Notice that we never multiply by the probability that the player chooses the action itself. We only ask what would happen _if_ they chose it.\
\

*Step 2: measure regret.* At $"A1"$, the current strategy plays with probability $0.6$ and folds with probability $0.4$, so

$
  U_"A1" = 0.6 (4) + 0.4 (-15) = -3.6, quad \
  r_"A1" (sans("play")) = 4 - (-3.6) = 7.6, quad \
  r_"A1" (sans("fold")) = -15 - (-3.6) = -11.4.
$

Since $C_j (a) = 0$ initially, these instantaneous regrets become the cumulative regrets. @tab:cfr-example shows all four decision points.

*Step 3: update the strategy.* At $"A1"$, only $sans("play")$ has positive regret, so the new strategy plays with probability $1$. At $"B1"$, only $sans("fold")$ has positive regret, so the new strategy folds with probability $1$. The other two decision points are filled in the same way in the table.

#figure(
  kind: table,
  supplement: [Table],
  caption: [One iteration of CFR on the example. The new probability of $sans("fold")$ is one minus the new probability of $sans("play")$.],
)[
  #table(
    stroke: none,
    columns: 8,
    align: center + horizon,
    inset: .6em,
    table.header(
      [*Decision point*],
      [*Current* $sigma_j (sans("play"))$],
      [$Q_j (sans("play"))$],
      [$Q_j (sans("fold"))$],
      [$U_j$],
      [$r_j (sans("play"))$],
      [$r_j (sans("fold"))$],
      [*New* $sigma_j (sans("play"))$],
    ),
    [$"A1"$], [$0.6$], [$4$], [$-15$], [$-3.6$], [$7.6$], [$-11.4$], [$1$],
    [$"A2"$], [$0.8$], [$13$], [$-15$], [$7.4$], [$5.6$], [$-22.4$], [$1$],
    [$"B1"$], [$0.2$], [$-14$], [$-11$], [$-11.6$], [$-2.4$], [$0.6$], [$0$],
    [$"B2"$], [$0.4$], [$14$], [$-11$], [$-1$], [$15$], [$-10$], [$1$],
  )
] <tab:cfr-example>

This is only one iteration. In later iterations, the new regrets are added to the existing cumulative regrets, so the strategy changes more gradually.
== Learning using self-play

The CFR algorithm can be used to learn a Nash equilibrium in a two-player zero-sum game by letting two regret minimizers play against each other. The two regret minimizers exchange their sequence-form strategies at every iteration according to the #lecture-link("learning_intro", <sec-learning-zero-sum>)[canonical self-play setup].

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - 2025-10-09: Fixed typos (thanks Josh Rountree!).
  - 2026-09-21: Fixed notation and typos (thanks Hannah Friedman!).
]
