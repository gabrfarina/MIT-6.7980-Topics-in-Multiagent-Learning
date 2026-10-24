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
] <thm:cfr-regret>

It is then immediate to see that if each $upright("Reg")_j^(\( T \))$ grows sublinearly in $T$, then so does $upright("Reg")^(\( T \))$. We will see why this is true on a small example in @sec-cfr-proof-small.

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
] <ex:cfr-kuhn-notation>

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
== Pseudocode for CFR

Pseudocode for CFR is given in @algo:cfr. Note that the implementation is parametric on the regret minimization algorithms $R_j$ run locally at each decision point. Any regret minimizer $R_j$ for simplex domains can be used to solve the local regret minimization problems. Popular options are #lecture-link("learning1", <sec-rm>)[regret matching] and #lecture-link("learning1", <sec-rmp>)[regret matching plus].

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

== Why the regret bound holds: a small example <sec-cfr-proof-small>

#set math.equation(numbering: "(1)")

Each $R_j$ minimizes its own regret without knowing what the other regret minimizers are doing, so it is worth seeing why their regrets add up to a bound for the whole tree. Let us do this on the smallest example where something interesting happens: one decision point sitting below another. We take the Jack branch of the TFDP of Player~1 in Kuhn poker (@ex:cfr-kuhn), using the names from @ex:cfr-kuhn-notation. The player first acts at $j_1$, choosing between $sans("check")$ and $sans("raise")$. Raising ends the branch. Checking leads to the observation point $k_2$, where the opponent either checks (the hand ends) or raises; in the latter case the player acts again at $j_4$, choosing between $sans("fold")$ and $sans("call")$. So $p_(j_4) = (j_1 \, sans("check"))$, and the branch has four sequences in total. We can ignore the Queen and King branches: the root observation point $k_1$ just adds up the values of its three children, so whatever we prove for one branch holds for the others, and the regret bounds add.

Two local regret minimizers are at work, $R_(j_1)$ and $R_(j_4)$. At time $t$ they output $vb_(j_1)^((t))$ and $vb_(j_4)^((t))$, and @algo:cfr turns these into a sequence-form strategy in the obvious way, the probability of a sequence being the product of the probabilities of the actions along it:
$
  vx^((t))[j_1 a] = vb_(j_1)^((t))[a] \, quad
  vx^((t))[j_4 a] = vb_(j_1)^((t))[sans("check")] thin vb_(j_4)^((t))[a] .
$ <eq:small-sf>

What does each regret minimizer get to see? Write $vg^((t))[j]$ for the two entries of the utility vector $vg^((t))$ at decision point $j$. Nothing happens after $j_4$, so $R_(j_4)$ simply sees those two entries, $vg_(j_4)^((t)) = vg^((t))[j_4]$, and its expected value is $V^((t))[j_4] = ip(vg^((t))[j_4], vb_(j_4)^((t)))$. (The observation point $k_2$ passes this value up unchanged, since its other child is $bot$.) $R_(j_1)$ sees something richer. For $sans("raise")$ it sees the utility of that sequence. For $sans("check")$ it sees the utility of that sequence _plus_ the value $V^((t))[j_4]$ the player expects to collect further down:
$
  vg_(j_1)^((t)) = vec(
    vg^((t))[j_1 sans("check")] + V^((t))[j_4],
    vg^((t))[j_1 sans("raise")]
  ) .
$ <eq:small-cf>
This is what makes the utility _counterfactual_: the entry for $sans("check")$ is computed as if the player had checked for sure. The probability $vb_(j_1)^((t))[sans("check")]$ with which they actually check does not appear.

Why does this lead to small regret on the whole branch? Two facts do the work. The first is that the value $V^((t))[j_1]$ computed at the root is exactly the utility that the sequence-form strategy earned. Indeed, multiplying out (@eq:small-cf) against $vb_(j_1)^((t))$ and comparing with (@eq:small-sf),
$
  V^((t))[j_1]
  = vb_(j_1)^((t))[sans("check")] (vg^((t))[j_1 sans("check")] + V^((t))[j_4]) + vb_(j_1)^((t))[sans("raise")] thin vg^((t))[j_1 sans("raise")]
  = ip(vg^((t)), vx^((t))) .
$ <eq:small-root>
The second is what each local regret minimizer guarantees: its regret $upright("Reg")_j^((T)) = max_(vb_j^*) sum_t ip(vg_j^((t)), vb_j^* - vb_j^((t)))$ is small. Rearranged, this says that against any fixed $vb_j^* in Delta(A_j)$,
$
  sum_(t=1)^T V^((t))[j] >= sum_(t=1)^T ip(vg_j^((t)), vb_j^*) - upright("Reg")_j^((T)) .
$ <eq:small-local>

Now pick any strategy $vx^* in cal(Q)$ to compare against, and let $vb^*$ be a behavioral strategy that induces it. (If $vx^*$ never checks, $vb_(j_4)^*$ can be anything; it will get multiplied by zero.) Start at the root. Summing (@eq:small-root) over $t$ and using the guarantee (@eq:small-local) of $R_(j_1)$ with comparator $vb_(j_1)^*$, then expanding $vg_(j_1)^((t))$ with (@eq:small-cf),
$
  sum_(t=1)^T ip(vg^((t)), vx^((t)))
  >= sum_(t=1)^T ip(vg^((t))[j_1], vb_(j_1)^*)
  + vb_(j_1)^*[sans("check")] sum_(t=1)^T V^((t))[j_4]
  - upright("Reg")_(j_1)^((T)) .
$ <eq:small-step1>
The sum of the values at $j_4$ has shown up, multiplied by $vb_(j_1)^*[sans("check")]$. This is the comparator's probability of checking, a fixed number between $0$ and $1$, not the probability $vb_(j_1)^((t))[sans("check")]$ that CFR plays at time $t$; this is where the counterfactual utility pays off. A fixed nonnegative multiplier can be pulled through an inequality, so we can use the guarantee (@eq:small-local) of $R_(j_4)$ as well, with comparator $vb_(j_4)^*$. Since $vb_(j_1)^*[sans("check")] thin vb_(j_4)^*[a] = vx^*[j_4 a]$ by (@eq:small-sf), this reads
$
  vb_(j_1)^*[sans("check")] sum_(t=1)^T V^((t))[j_4]
  >= sum_(t=1)^T ip(vg^((t))[j_4], vx^*[j_4]) - vx^*[j_1 sans("check")] thin upright("Reg")_(j_4)^((T)) .
$ <eq:small-step2>
Put (@eq:small-step2) into (@eq:small-step1). The two inner products that remain, $ip(vg^((t))[j_1], vx^*[j_1])$ and $ip(vg^((t))[j_4], vx^*[j_4])$, are the two halves of $ip(vg^((t)), vx^*)$, so
$
  sum_(t=1)^T ip(vg^((t)), vx^((t)))
  >= sum_(t=1)^T ip(vg^((t)), vx^*)
  - upright("Reg")_(j_1)^((T)) - vx^*[p_(j_4)] thin upright("Reg")_(j_4)^((T)) .
$
In words: compared to any fixed strategy, CFR lost at most the regret of $R_(j_1)$ plus the regret of $R_(j_4)$ scaled by how often the comparator reaches $j_4$. That scaling factor is in $[0 \, 1]$, so $vx^*[p_(j_4)] thin upright("Reg")_(j_4)^((T)) <= max{0 \, upright("Reg")_(j_4)^((T))}$. (The $max$ is needed: a local regret can be negative, and scaling a negative number down by a factor in $[0 \, 1]$ makes it larger.) Maximizing over $vx^*$,
$
  upright("Reg")^((T)) <= max{0 \, upright("Reg")_(j_1)^((T))} + max{0 \, upright("Reg")_(j_4)^((T))} ,
$
which is @thm:cfr-regret for this branch.

Nothing in this computation is special to the example. If several decision points hang below the same observation point, all of their values show up in (@eq:small-step1) with the same multiplier and are handled like (@eq:small-step2). If the tree is deeper, we repeat the step one level at a time, and the multiplier in front of $upright("Reg")_j^((T))$ ends up being $vx^*[p_j]$, again a number in $[0 \, 1]$. One thing to keep in mind: since $vg_(j_1)^((t))$ contains $V^((t))[j_4]$, the utilities seen near the root have a larger range than the entries of $vg^((t))$, and the $O(sqrt(T))$ regret of regret matching comes with a constant that grows with the size of the subtree.

#set math.equation(numbering: none)

== Learning using self-play

The CFR algorithm can be used to learn a Nash equilibrium in a two-player zero-sum game by letting two regret minimizers play against each other. The two regret minimizers exchange their sequence-form strategies at every iteration according to the #lecture-link("learning_intro", <sec-learning-zero-sum>)[canonical self-play setup].

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - 2025-10-09: Fixed typos (thanks Josh Rountree!).
  - 2026-09-21: Fixed notation and typos (thanks Hannah Friedman!).
  - 2026-10-23: Added a proof of the CFR regret bound on a small example.
]
