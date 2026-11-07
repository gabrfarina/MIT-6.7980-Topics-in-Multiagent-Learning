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


=== Counterfactual values, Q-values, and conditional expectations <sec-cfr-values>

Both a Q-value and a counterfactual value evaluate an action at a decision point, assuming that subsequent play follows the current strategies. The difference is how they account for _getting to_ that decision point.

- A *Q-value* asks: “If I were at this decision point and took this action, what continuation payoff should I expect?”
- A *counterfactual value* evaluates the same action while keeping the opponents' and chance's probabilities of reaching this decision point, but leaving out your own earlier action probabilities.

// Keep the worked example and its table together.
#block(breakable: false)[
  #example[
    Consider the following decision process.

    - You choose $sans("enter")$ with probability 0.1; otherwise your payoff is 0.
    - After $sans("enter")$, chance lets you continue with probability 0.2; otherwise your payoff is 0.
    - If you continue, you reach decision point $j$, where action $upsans(A)$ pays 10 and action $upsans(B)$ pays 4.

    The actual probability of reaching $j$ is $0.1 times 0.2 = 0.02$.

    #align(center, table(
      stroke: none,
      columns: 4,
      align: (left, right, right, right),
      inset: .7em,
      table.header([*Quantity*], [*Multiplier*], [*A*], [*B*]),
      [Q-value], [1], [10], [4],
      [Counterfactual value], [0.2], [2], [0.8],
      [Expected payoff], [0.02], [0.2], [0.08],
    ))

    The $upsans(A)$ and $upsans(B)$ columns assume that you choose the corresponding action at $j$. The Q-value is the continuation value once the player is placed at $j$; the counterfactual value additionally keeps chance's 0.2 reach probability but not your $sans("enter")$ probability; the expected payoff of the whole game keeps both.
  ] <ex-cfr-values>
]

More generally, fix all strategies in a perfect-recall game, and let $Q_(i)(j, a)$ and $v_(i)^("cf")(j, a)$ denote player $i$'s Q-value and counterfactual value of action $a in A_j$ at decision point $j$. By perfect recall, all histories in the same decision point $j$ share the same parent sequence of player $i$.

Let $w_(-i)(j)$ denote the external (or counterfactual) reach probability of $j$: the probability weight contributed by opponents and chance, excluding player $i$'s own earlier action probabilities. Whenever $w_(-i)(j) > 0$, the Q-value is the counterfactual value normalized by this external reach probability:
$ v_(i)^("cf")(j, a) = w_(-i)(j) dot Q_(i)(j, a). $

Thus, $Q_(i)(j, a)$ describes the continuation value of choosing $a$ once the player is placed at $j$, whereas the counterfactual value also retains the probability that opponents and chance make $j$ possible. Player $i$'s own probability of reaching $j$ is deliberately excluded, while player $i$'s strategy after taking $a$ still matters. We use the unnormalized counterfactual-value convention here.

If the event of reaching $j$ and choosing $a$ has positive probability under the current strategy profile, then $Q_(i)(j, a)$ agrees with the ordinary conditional expectation of the payoff given that event. However, the Q-value is an action value and can still be defined when player $i$'s own earlier strategy gives $j$ zero actual reach, or when the current strategy assigns zero probability to action $a$. In those cases, the corresponding ordinary conditional expectation is undefined.

This is one reason CFR works with counterfactual values. Even if your strategy in @ex-cfr-values never chooses $sans("enter")$, the Q-values at $j$ remain 10 and 4, and the counterfactual values remain 2 and 0.8. A full-tree CFR update can therefore evaluate the actions at $j$ even when your current strategy never reaches it.

*Connection to normal form* In a one-shot normal-form game, player $i$'s decision point is reached with probability 1, so there is no earlier own-reach probability to remove. Hence the Q-value and counterfactual value both reduce to
$ q_(i)(a_i) := EE_(a_(-i) ~ x_(-i))[u_(i)(a_i, a_(-i))]. $

We fix player $i$'s action and average over the opponents' actions. When $a_i$ has positive probability under player $i$'s current strategy, this is also the ordinary conditional expectation of player $i$'s payoff given that player $i$ chooses $a_i$: by independence, conditioning on $a_i$ leaves the distribution of $a_(-i)$ unchanged. The formula above remains meaningful even when player $i$ assigns zero probability to $a_i$, in which case that ordinary conditional expectation is undefined.

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

#pseudocode-list(numbered-title: [CFR regret minimizer])[
  - *Data:* $R_j$, regret minimizer for $Delta(A_j)$; one for each decision point $j in cal(J)$ of the TFDP.
  + *function* `NextStrategy()`
    - _Step 1: ask each of the $R_j$ for their next strategy local at each decision point._
    + *for each* decision point $j in cal(J)$:
      + $vb_j^((t)) in Delta(A_j) <- R_j$.`NextStrategy()`
    - _Step 2: we construct the sequence-form representation of the strategy that plays according to the distribution $vb_j^((t))$ at each decision point $j in cal(J)$._
    + $vx^((t)) = 0 in RR^Sigma$
    + *for each* decision point $j in cal(J)$ in _top-down traversal_ order in the TFDP:
      + *for each* action $a in A_j$:
        + *if* $p_j = emptyset$:
          + $vx^((t))[j a] <- vb_j^((t))[a]$
        + *else*:
          + $vx^((t))[j a] <- vx^((t))[p_j] dot vb_j^((t))[a]$
    - _You should convince yourself that the vector $vx^((t))$ we just filled in above is a valid sequence-form strategy, that is, it satisfies the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form consistency constraints]. In symbols, $vx^((t)) in cal(Q)$._
    + *return* $vx^((t))$
  + *function* `ObserveUtility`($vg^((t)) in RR^(abs(Sigma))$)
    - _Step 1: we compute the expected utility for each subtree rooted at each node $v in cal(J) union cal(K)$._
    + $V^((t)) <-$ empty dictionary. _Eventually, it will map keys $cal(J) union cal(K) union {bot}$ to real numbers._
    + $V^((t))[bot] <- 0$
    + *for each* node in the tree $v in cal(J) union cal(K)$ in _bottom-up traversal_ order in the TFDP:
      + *if* $v in cal(J)$:
        + Let $j <- v$.
        + $V^((t))[j] <- sum_(a in A_j) vb_j^((t))[a] dot (vg^((t))[j a] + V^((t))[rho(j, a)])$
      + *else*:
        + Let $k <- v$.
        + $V^((t))[k] <- sum_(s in S_k) V^((t))[rho(k, s)]$
    - _Step 2: at each decision point $j in cal(J)$, we now construct a local utility vector $vg_j^((t))$ called counterfactual utility._
    + *for each* decision point $j in cal(J)$:
      + $vg_j^((t)) <- 0 in RR^(A_j)$
      + *for each* action $a in A_j$:
        + $vg_j^((t))[a] <- vg^((t))[j a] + V^((t))[rho(j, a)]$
      + $R_j$.`ObserveUtility`$(vg_j^((t)))$
] <algo:cfr>

=== Clarifying the Pseudocode

*Data flow.* Current strategy $vx^((t))$ $->$ current utility $vg^((t))$ $->$ local regret updates in the $R_j$ $->$ next strategy. `ObserveUtility` uses the same $vb_j^((t))$ that `NextStrategy` just produced.


*`NextStrategy`*
- _Step 1 (local strategies)._ Each $R_j$ returns a distribution $vb_j^((t))$ over $A_j$. It is a _behavioral_ strategy: it says what to play _given that $j$ is reached_. Any regret minimizer works here (e.g., regret matching).
- _Top-down loop._ We need $vx^((t))[p_j]$ (the parent sequence) to be filled in before its children
- _$vx^((t))[j a]$._ This is the probability that the player plays the whole sequence $j a$, i.e., the product of local probabilities along the path. If $p_j = emptyset$, the parent is the empty sequence, which has probability 1, so we just copy $vb_j^((t))[a]$.
- _Why it is valid._ The sequence-form constraint says that the probability of the parent sequence equals the sum of the probabilities of its children: $vx^((t))[p_j] = sum_(a in A_j) vx^((t))[j a]$. This holds because $sum_(a in A_j) vx^((t))[j a] = vx^((t))[p_j] dot sum_(a in A_j) vb_j^((t))[a] = vx^((t))[p_j] dot 1$. In other words, the probability of reaching $j$ is split among its actions according to $vb_j^((t))$, so nothing is gained or lost.

*`ObserveUtility`*
- _Input $vg^((t))$._ The utility of this iteration only (not cumulative), with $u^((t))(vx) = vg^((t))^top vx$. The entry $vg^((t))[j a]$ collects payoffs that occur right after the player plays $j a$, _already multiplied by the probabilities of chance and the opponent_. It can be nonzero even if $j a$ is nonterminal, since the opponent may end the game after $j a$.
- _$V^((t))[bot] <- 0$._ $bot$ means "nothing follows"; $rho(j, a) = bot$ when no decision or observation point comes after $j a$.
- _Bottom-up loop._ $V^((t))[v]$ uses the values of its children, so we must traverse bottom up.
- _$V^((t))[j]$._ This is the expected utility in the subtree of $j$, assuming $j$ is reached. We multiply only by $vb_j^((t))[a]$ because the player's own choice at $j$ is the only randomness not already inside $vg^((t))$. We also do _not_ multiply by the probability that the player reaches $j$; this is what makes the value "counterfactual".
- _$V^((t))[k]$._ At an observation point no action is taken, so we just sum over signals. Their probabilities are already inside $vg^((t))$.
- _$vg_j^((t))[a]$._ This is the immediate utility of $j a$ plus the continuation value below it. It is the same quantity as inside the sum for $V^((t))[j]$, but _without_ the weight $vb_j^((t))[a]$, so that $R_j$ can compare actions. The regret decomposes into local regrets weighted by the player's own reach, so $R_j$ needs no such weight and also learns at rarely reached points. 

== A Tree-Based Version of CFR

The previous pseudocode encodes chance and opponent reach probabilities in the global utility vector $vg^((t))$. Given a game tree with utilities specified at terminal nodes, we can compute the same CFR update directly from the tree.

#pseudocode-list(numbered-title: [One CFR round on the game tree])[
  - *Input:* The game tree, the terminal utilities $u_i (z)$ of player $i$, the probability $p(a | h)$ of each chance or opponent action $a$ at node $h$ (for the opponent, this comes from their current strategy), and the current local strategies $vb_j^((t))$ of player $i$.

  - *Step 1: Compute expected values (bottom-up).*
    + At each terminal node $z$, set $V(z) <- u_i (z)$.
    + At each chance or opponent node $h$, set $V(h) <- sum_a p(a | h) dot V(h a)$.
    + At each decision node $h$ of player $i$, belonging to information set $j$, set $V(h) <- sum_(a in A_j) vb_j^((t))[a] dot V(h a)$.

  - *Step 2: Compute counterfactual utilities.*
    + For each information set $j$ of player $i$ and each action $a in A_j$, set
      $ vg_j^((t))[a] <- sum_(h in j) (product_("chance or opponent edges " e " on the path from the root to " h) p(e)) dot V(h a) . $

  - *Step 3: Update regrets and strategies.* For each information set $j$ of player $i$:
    + Compute $U_j <- sum_(a in A_j) vb_j^((t))[a] dot vg_j^((t))[a]$.
    + For each action $a in A_j$, compute the instantaneous regret $r_j (a) <- vg_j^((t))[a] - U_j$.
    + Pass $r_j$ to the local regret minimizer $R_j$ and obtain $vb_j^((t+1))$. _For regret matching:_ $R_j$ keeps the cumulative regret $C_j (a) <- C_j (a) + r_j (a)$ and sets $vb_j^((t+1))[a]$ proportional to $max(C_j (a), 0)$. Other regret minimizers update differently and need not keep cumulative regrets.
]

Here, $V(h)$ is the expected payoff to player $i$ _conditional on reaching node $h$_ and following the current strategies thereafter. It is *not* the same object as $V^((t))[dot]$ in the sequence-form pseudocode: $V(h)$ does not include any reach probability of getting to $h$, while the reach weighting of $V^((t))[dot]$ is hidden inside $vg^((t))$. In Step 2, the product includes only chance and opponent action probabilities along the path to $h$, not player $i$'s own action probabilities. Also, $h a$ denotes the node reached by playing $a$ at $h$.
=== Why this is equivalent

Both procedures compute the same counterfactual utilities. They differ only in _where_ chance and opponent probabilities are applied.

*How $vg^((t))$ encodes them.* Each terminal node $z$ contributes $u_i (z)$ times $p(e)$ for every chance or opponent edge $e$ on the path to $z$. This product is added to the entry of $vg^((t))$ for the last sequence player $i$ played before $z$.

*Where each procedure applies them.*
- _Sequence form:_ nowhere in the code. They are already inside the input $vg^((t))$, and the recursion only multiplies by player $i$'s own $vb_j^((t))[a]$.
- _Tree-based:_ explicitly, in two places. Step 1 applies them below $h a$ (inside $V(h a)$), and Step 2 applies them above $h$ (the product from the root to $h$).

*Why the results match.* Fix an action $a$ at the information set $j$ and a terminal node $z$ below $j a$. The information set $j$ contains several histories (game-tree nodes), and the path from the root to $z$ passes through at least one of them. By perfect recall, a player never returns to the same information set along one path, so no two histories of $j$ lie on the same path. Hence the path to $z$ passes through exactly one history $h in j$, and Step 2 counts $z$ once. Along this path, $u_i (z)$ gets multiplied by three groups of probabilities:
+ chance and opponent edges from the root to $h$,
+ chance and opponent edges from $h a$ down to $z$,
+ player $i$'s own $vb_j^((t))$ probabilities from $j a$ down to $z$.

Both procedures multiply in all three groups, just at different times:
- _Sequence form:_ groups 1 and 2 are already inside $vg^((t))$ when $z$'s payoff is stored there. The recursion for $V^((t))$ then multiplies in group 3 on the way up to $j a$.
- _Tree-based:_ $V(h a)$ multiplies in groups 2 and 3 on the way up from $z$ to $h a$. Step 2 then multiplies in group 1.

Since each $z$ gets the same product in both, summing over all $z$ below $j a$ gives
$ vg^((t))[j a] + V^((t))[rho(j, a)] = sum_(h in j) (product_("chance or opponent edges " e " on the path from the root to " h) p(e)) dot V(h a) . $
The left side is computed by `ObserveUtility` and the right side by Step 2, so both feed the same $vg_j^((t))$ to the same $R_j$ and produce the same CFR update.

== Worked example: one iteration of CFR

Consider a small game between players A and B. Each player is dealt card $1$ with probability $1 slash 3$ or card $2$ with probability $2 slash 3$, independently, and sees only their own card (@fig:cfr-tree). Player A moves first and either plays or folds. If A folds, A pays B 15. Otherwise B plays or folds. If B folds, B pays A 15. If both play, the payoffs depend on the cards, as shown in @tab:cfr-payoffs.

Each player has two decision points, one per card they might hold: $"A1"$, $"A2"$, $"B1"$, $"B2"$. Note that $"B1"$ contains two histories, because B cannot tell whether A holds card 1 or card 2. We start from the strategy

$ vb_"A1" (sans("play")) = 0.6 , quad vb_"A2" (sans("play")) = 0.8 , quad vb_"B1" (sans("play")) = 0.2 , quad vb_"B2" (sans("play")) = 0.4 , $

where $sans("fold")$ gets the remaining probability, and all cumulative regrets are $C_j (a) = 0$.

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

We apply the tree-based procedure. Before doing so, note where the probabilities of Step 2 come from for each player.

- For A, chance deals A's card, and everything else (B's card and B's action) happens _after_ A's decision. So the only reach probability is the chance of A's card, and the probabilities of B's card and action are inside the expected value of the action, which is computed bottom-up (Step 1).
- For B, chance deals A's card, A plays, and chance deals B's card _before_ B's decision. So the reach of each history of B's information set is the product of the chance of A's card, the probability that A plays, and the chance of B's card. The chance of B's card is the same for both histories of the information set, so in the calculations below we pull it out of the sum and multiply by it at the end.

We go through one iteration of CFR. For each decision point we do the same four things:

1. *Evaluate each action.* Look down the tree below the action and add up the payoffs, each multiplied by the probability of the opponent's card (chance) and the probability of the opponent's action. This value assumes that the player already holds the card, so it does not include the chance of being dealt it.
2. *Compute the utility of the current strategy* at the decision point, by weighting the values of the actions with the current strategy.
3. *Compute the regret* of each action, which is its value minus the utility of the current strategy. We call this the regret _before reach_.
4. *Multiply by the chance probability of holding the card* ($1 slash 3$ for card 1 and $2 slash 3$ for card 2). This gives the counterfactual utilities and regrets that CFR actually uses.

=== Player A

*A has card 1.*

*Play:* B holds card 1 with probability $1 slash 3$ and card 2 with probability $2 slash 3$, and B plays or folds with the probabilities of $vb_"B1"$ and $vb_"B2"$ described above. Multiplying all the probabilities and outcomes together, we get:

$ 1/3 (0.2)(-10) + 1/3 (0.8)(15) + 2/3 (0.4)(-20) + 2/3 (0.6)(15) = -2/3 + 4 - 16/3 + 6 = 4 . $

*Fold:* the game ends, regardless of B's card, so the value is $-15$.

Given A holds card 1, the expected utility of A's current strategy is $4 dot 0.6 + (-15) dot 0.4 = -3.6$. Subtracting this from the value of each action tells us how much better or worse that action is than the strategy itself: for $(sans("play"), sans("fold"))$ we get $(4 - (-3.6), -15 - (-3.6)) = (7.6, -11.4)$. Finally, we weight by the probability that A holds card 1, which is $1 slash 3$, to obtain the counterfactual regrets:

$ r_"A1" = (7.6/3, -3.8) . $

*A has card 2.*


*Play:* The only difference in this calculation is the payoffs of each outcome, as described in @tab:cfr-payoffs.

$ 1/3 (0.2)(25) + 1/3 (0.8)(15) + 2/3 (0.4)(5) + 2/3 (0.6)(15) = 5/3 + 4 + 4/3 + 6 = 13 . $

*Fold:* the value is $-15$.

As for card 1, we subtract the expected utility of the current strategy, $13 dot 0.8 + (-15) dot 0.2 = 7.4$, from each action's value, giving $(5.6, -22.4)$. Weighting by the probability $2 slash 3$ that A holds card 2:

$ r_"A2" = (11.2/3, -44.8/3) . $

=== Player B

If A folds, B does not act, so only the case where A plays matters for B's decision points. For each card, we apply the same three steps as for A: compute the value of each action, subtract the expected utility of B's current strategy, and weight by the probability of holding that card.

*B has card 1.*

*Play:* A holds card 1 with probability $1 slash 3$ and plays with $0.6$, or A holds card 2 with probability $2 slash 3$ and plays with $0.8$:

$ 1/3 (0.6)(10) + 2/3 (0.8)(-30) = 2 - 16 = -14 . $

*Fold:* B gets $-15$ in both cases:

$ 1/3 (0.6)(-15) + 2/3 (0.8)(-15) = -3 - 8 = -11 . $

The expected utility of the current strategy is $(-14) dot 0.2 + (-11) dot 0.8 = -11.6$, so the action values minus this are $(-2.4, 0.6)$. Weighting by $1 slash 3$:

$ r_"B1" = (-0.8, 0.2) . $

*B has card 2.*

*Play:*

$ 1/3 (0.6)(30) + 2/3 (0.8)(15) = 6 + 8 = 14 . $

*Fold:* $-11$, as before.

The expected utility of the current strategy is $14 dot 0.4 + (-11) dot 0.6 = -1$, so the action values minus this are $(15, -10)$. Weighting by $2 slash 3$:

$ r_"B2" = (10, -20/3) . $
=== The counterfactual utility

Step 4 can also be applied to the values before computing the regrets, and it gives the same result, because everything is multiplied by the same number. This is how the counterfactual utility $vg_j [a]$ in the pseudocode is calculated. To calculate the counterfactual utilities we simply multiply the value of each action (before reach) by the probability of holding the given card.

$
  vg_"A1" & = 1/3 (4 , -15) = (4/3 , -5) , quad & vg_"A2" & = 2/3 (13 , -15) = (26/3 , -10) , \
  vg_"B1" & = 1/3 (-14 , -11) = (-14/3 , -11/3) , quad & vg_"B2" & = 2/3 (14 , -11) = (28/3 , -22/3) .
$

=== Regrets and the new strategy

Since all $C_j (a)$ started at $0$, the cumulative regrets after this iteration are equal to the regrets above. @tab:cfr-example summarizes the iteration.

We use regret matching as $R_j$ (see Step 3 above). Since $C_j (a)$ started at $0$, the cumulative regrets after this iteration equal the regrets above. @tab:cfr-example summarizes the iteration.

#figure(
  kind: table,
  supplement: [Table],
  caption: [One iteration of CFR on the example. Regrets are written as $(sans("play") , sans("fold"))$. The new probability of $sans("fold")$ is one minus the new probability of $sans("play")$.],
)[
  #table(
    stroke: none,
    columns: 5,
    align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
    inset: .5em,
    table.header(
      [],
      [*A1*],
      [*A2*],
      [*B1*],
      [*B2*],
    ),
    table.hline(),
    [*Current* $vb_j (sans("play"))$], [$0.6$], [$0.8$], [$0.2$], [$0.4$],
    [*Value of* $sans("play")$], [$4$], [$13$], [$-14$], [$14$],
    [*Value of* $sans("fold")$], [$-15$], [$-15$], [$-11$], [$-11$],
    [*Utility of current strategy*], [$-3.6$], [$7.4$], [$-11.6$], [$-1$],
    [*Value minus utility*], [$(7.6 , -11.4)$], [$(5.6 , -22.4)$], [$(-2.4 , 0.6)$], [$(15 , -10)$],
    [*Chance of card*], [$1/3$], [$2/3$], [$1/3$], [$2/3$],
    [*Counterfactual regret* $r_j$], [$(7.6/3 , -3.8)$], [$(11.2/3 , -44.8/3)$], [$(-0.8 , 0.2)$], [$(10 , -20/3)$],
    [*New* $vb_j (sans("play"))$], [$1$], [$1$], [$0$], [$1$],
  )
] <tab:cfr-example>
For the new strategy in this example we use regret matching. At $"A1"$ and $"A2"$ only $sans("play")$ has positive regret, so A plays with probability $1$. At $"B1"$ only $sans("fold")$ has positive regret, so B folds with probability $1$. At $"B2"$ only $sans("play")$ has positive regret, so B plays with probability $1$.

This is only one iteration. In later iterations, the new regrets are added to the existing cumulative regrets, so the strategy changes more gradually.


== Learning using self-play

The CFR algorithm can be used to learn a Nash equilibrium in a two-player zero-sum game by letting two regret minimizers play against each other. The two regret minimizers exchange their sequence-form strategies at every iteration according to the #lecture-link("learning_intro", <sec-learning-zero-sum>)[canonical self-play setup].

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - 2025-10-09: Fixed typos (thanks Josh Rountree!).
  - 2026-09-21: Fixed notation and typos (thanks Hannah Friedman!).
]
