#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 7,
  date: [Tue, Oct 6, 2026],
  title: "Modeling extensive-form games",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

Imperfect-information extensive-form games  model tree-form strategic interactions in which not all actions might be observed by all players. They represent an ample majority of strategic interactions encountered in the real world, ranging from recreational games such as poker, to negotiation, and auctions.

= Game trees and information sets <sec-game-trees>

The standard representation of an imperfect-information extensive-form game is through its _game tree_, which formalizes the interaction of the players as a directed tree. In the game tree, each non-terminal node belongs to exactly one player, who acts at the node by picking one of the outgoing edges (each labeled with an action name). Imperfect information is captured in this representation by partitioning the nodes of each player into sets (called information sets) of nodes that are indistinguishable to that player given his or her observations.

#example[
  As a running example, we use _Kuhn poker_, a two-player poker variant played with a deck of only three cards: Jack, Queen, and King #citep(<Kuhn50:Simplified>). Despite its simplicity, the game already captures central aspects of deceptive behavior such as _bluffing_ and _underbidding_.

  #paragraph-marker(shape: "triangle-up") *The rules of Kuhn poker*~~ At the beginning of the game, each player contributes a \$1 ante to the pot. The deck is shuffled, each player is privately dealt one card, and the third card is set aside. Each of the six possible deals is equally likely. We abbreviate the cards as $upsans("J")$, $upsans("Q")$, and $upsans("K")$; for example, $upsans("JK")$ means that Player 1 receives a Jack and Player 2 receives a King.

  After the cards are dealt, a single betting round takes place:

  - Player 1 acts first and chooses either to check (continue without betting) or to bet \$1.
  - If Player 1 checks, Player 2 may either check, which leads directly to a showdown, or bet \$1. After a bet by Player 2, Player 1 may fold or call by contributing another \$1 to the pot.
  - If Player 1 bets, Player 2 may fold or call by contributing another \$1 to the pot.

  When a player folds, the other player wins the pot. When neither player folds, the players reveal their cards in a _showdown_, and the player with the higher card wins the pot. The King is the highest card, followed by the Queen and then the Jack.

  The diagram below summarizes the six possible deals and every possible betting sequence. The number at each endpoint gives Player 1's net winnings.

  #align(center)[
    #image("figures/efg_intro/kuhn.svg", width: 100.0%)
  ]
] <ex:kuhn>

== Histories, actions, and payoffs

The game tree represents the strategic interaction of players as a finite directed tree. The nodes of the game tree are called _histories_. Each history that is not a leaf of the game tree is associated with a unique acting player. In an $n$-player game, the set of valid players is the set $\[ n \] union { c } = {1 \, ... \, n \, c}$, where $c$ denotes the chance (or nature) player---a fictitious player that selects actions according to a known fixed probability distribution and models exogenous stochasticity of the environment (say, a roll of the dice, or drawing a card from a deck). The player is free to pick any one of the actions available at the history, which correspond to the outgoing edges at the histories. The players keep acting until a leaf of the game tree---called a _terminal history_---is reached. Terminal histories are not associated with any acting player; the set of terminal histories is denoted $Z$. When a terminal node $z in Z$ is reached, each player $i in \[ n \]$ receives a payoff according to the payoff function $u_i : Z -> bb(R)$.

== Imperfect information and information sets

To model imperfect information, the histories of each player $i in \[ n \]$ are partitioned into a collection $cal(I)_i$ of so-called information sets. Each information set $I in cal(I)_i$ groups together histories that Player i cannot distinguish between when he or she acts there. In the limit case in which all information sets are singleton, the player never has any uncertainty about which history they are acting at, and the game is said to have perfect information. Since a player always knows what actions are available at a decision node, any two histories $h \, h'$ belonging to the same information set $I$ must have the same set of available actions. Correspondingly, we can write $A_I$ to denote the set of actions available at any node that belongs to information set $I$.

#example[
  To illustrate how information sets capture private information, in this example we speculate on how different rules for Kuhn poker would translate into different information set structures.

  #align(center)[
    #image("figures/efg_intro/variations.svg", width: 100.0%)
  ]
]

#example[
  In Kuhn poker, each player observes their own private card and the actions of the opponent, but not the opponent's private card. The twelve information sets, six for Player 1 denoted $upsans(A)$ through $upsans(F)$, and six for Player 2 denoted $upsans(P)$ through $upsans(U)$, reflect this partial information. For example, Player 1's histories following actions $upsans("QK")$ and $upsans("QJ")$ of the nature player (the dealer) are part of the same information set $upsans(B)$, in that Player 1 cannot distinguish between the two histories, having observed only their private $upsans("Queen")$ card. As another example, Player 2's information set $upsans(P)$ captures the uncertainty the player has on the underlying history after having observed a private $upsans("King")$ card, and a check from Player 1.
]

== Perfect recall <sec-perfect-recall>

A standard assumption in extensive-form games is that no player forgets about their actions, and about information once acquired. Without this assumption, called _perfect recall_, solving extensive-form games can be intractable. The perfect recall condition can be formalized as follows.

#definition[Perfect recall][
  A player $i in \[ n \]$ is said to have _perfect recall_ if, for any information set $I in cal(I)_i$, for any two histories $h \, h' in I$ the sequence of Player $i$'s actions encountered along the path from the root to $h$ and from the root to $h'$ must coincide (or otherwise Player $i$ would be able to distinguish among the histories, since the player remembers all of the actions they played in the past). The game is perfect recall if all players have perfect recall.
] <def:perfect-recall>

= Player's perspective: Tree-form decision processes <sec-tfdp>

The game tree representation introduced above provides a description of the global dynamics of the game, without taking the side of any player in particular. But what is the strategy space from the point of view of _one_ decision maker (player) in the game? In a normal-form game, the strategy space of a player is a set of probability distributions over the set of actions available to that player. In an extensive-form game, the strategy space of a player is a _tree-form decision process (TFDP)_.

#example[Player 1's decision process in Kuhn poker][
  As an example, consider Player 1 in Kuhn poker @ex:kuhn. From the player's point of view, playing the game could be summarized as follows:

  - As soon as the game starts, the player observes a private card that has been dealt to them; the set of possible signals is ${upsans("Jack") \, upsans("Queen") \, upsans("King")}$.
  - No matter the card observed, the player now needs to select one action from the set ${upsans("check") \, upsans("bet")}$.

    - If the player $upsans("bets")$, the player does not have a chance to act further
    - Otherwise, if the player $upsans("checks")$, the player will then observe whether the opponent $upsans("checks")$ (at which point the interaction terminates) or $upsans("bets")$. In the latter case, a new decision needs to be made, between $upsans("folding")$ the hand, or $upsans("calling")$ the bet. In either case, after the action has been selected, the interaction terminates.

  By arranging the structure of decisions and observations along a tree as follows, we obtain the tree-form decision process for Player 1.

  #figure(caption: [Tree-form decision process faced by Player 1 in the game of Kuhn poker.])[
    #image("figures/efg_intro/kuhn_tfdp.png", width: 100.0%)
  ] <fig:kuhn-tfdp>
]

The tree-form decision process lays out the player's opportunities to act. Unlike the game tree, in which each node belongs to one of many players, the tree-form decision process is a directed tree made of only two types of nodes: decision nodes, at which the player must act by picking an action from a set of legal actions, and observation nodes, at which the player does not act but rather observes a signal drawn from a set of possible signals. Furthermore, the information structure of the player, previously defined indirectly through information sets, is captured directly in the TFDP representation.

== Extracting a tree-form decision process from the game tree

In some cases, like in @fig:kuhn-tfdp, it is straightforward to compile the tree-form decision process faced by a player starting from our intuitive understanding of the game. In this subsection we discuss how the TFDP for the player can be constructed programmatically starting from the game tree when such an understanding is missing. We assume that an $n$-player imperfect-information extensive-form game with perfect recall and a player $i in \[ n \]$ of interest, have been fixed.

The set of decision nodes $cal(J)_i$ of the player's TFDP coincides with the set of his or her information sets, that is, $cal(J)_i = cal(I)_i$. This is consistent with the fact that the player cannot condition their behavior on anything other than their information set, given that they cannot distinguish between histories in the same information set. Furthermore, the set of actions available at any decision node $j = I in cal(J)_i$ coincides with the set of actions $A_I$ available at any history in information set $I$.

Where each decision node sits in the TFDP is determined by its _trace_: the information sets Player~$i$ passed through, and the actions taken there, on the way to it.

#definition[Trace][
  Fix a player $i in \[ n \]$, an information set $I in cal(I)_i$, and a history $h in I$. Let $h_1, ..., h_m$ ($m >= 0$) be the histories of Player~$i$ that lie strictly before $h$ on the path from the root of the game tree to $h$, listed in the order in which they are encountered. For each $k = 1, ..., m$, let $I_k in cal(I)_i$ be the information set containing $h_k$, and $a_k in A_(I_k)$ be the action taken at $h_k$ on the path to $h$. The _trace_ of $h$ (for Player~$i$) is the sequence
  $
    (I_1, a_1, ..., I_m, a_m, I).
  $
] <def:trace>

Histories of other players and of chance do not appear in the trace. Under perfect recall (@def:perfect-recall), Player~$i$ remembers both the actions they took and the information sets where they took them, so all histories in $I$ have the same trace, which we call the _trace of_ $I$.

#example[
  Consider Kuhn poker from the point of view of Player~1 (@fig:kuhn-tfdp).

  - The trace of any history in $upsans(A)$ is the sequence $\( upsans(A) \)$.
  - The trace of any history in $upsans(E)$ is the sequence $(upsans(B) \, upsans("check") \, upsans(E))$.

  From the point of view of Player~2, the trace of any history in $upsans(R)$ is the sequence $\( upsans(R) \)$.
]

#example[
  #wrapped-figure(
    [
      Consider the following small game tree.

      Taking the side of Player~1, the trace of the only history in $upsans(B)$ is the sequence $(upsans(A) \, upsans(1) \, upsans(B))$, the trace of any history in $upsans(D)$ is $(upsans(A) \, upsans(2) \, upsans(D))$, and the trace of the only history in $upsans(A)$ is $(upsans(A))$. Taking the side of Player~2, the trace of the only history in $upsans(P)$ is $(upsans(P))$, and the trace of the only history in $upsans(Q)$ is $(upsans(Q))$.
    ],
    [#image("figures/efg_intro/small_efg.svg", width: 210pt)],
    side: right,
    text-width: 65%,
  )
] <ex:small-efg>

Traces implicitly encode a notion of partial chronological ordering between information sets, of which the player has recall---see @def:perfect-recall. Hence, for the TFDP of Player~$i$ to be an accurate representation of the decision process the player faces while playing the game, it is necessary that _traces of the information sets are the same in the game tree and in the TFDP_. In other words, we require that decision points in the TFDP be structured so as to satisfy that the trace of any information set $I$ matches the sequence of information sets and actions encountered from the root of the TFDP to decision node $I$.

#definition[Tree-form decision process][
  Fix the game tree of an $n$-player imperfect information game, and a player $i in \[ n \]$. A _tree-form decision process (TFDP) for Player~$i$_ is a directed rooted tree made of _decision_, _observation_, and _terminal nodes_, satisfying the following properties.

  - The set of decision nodes $cal(J)_i$ of the TFDP is equal to the set $cal(I)_i$ of information sets.
  - The set of actions available at each decision node $j = I in cal(I)_i$ (_i.e._, the set of outgoing edges from the decision node) is equal to the set of actions $A_I$ available at any history $h in I$ in the game tree.
  - Given any decision node $j = I in cal(I)_i$, the sequence of decision nodes and actions encountered from the root of the TFDP to $j$ is equal to the trace of $I$ (@def:trace).
] <def:tfdp>

As a remark, @def:tfdp leaves the labeling and structure of observation nodes unspecified. In fact, a player might have multiple TFDPs that satisfy the definition, and differ in how the observation nodes are placed. We illustrate this in the next example.

#example[
  The following are both valid TFDPs capturing Player~1's decision process when playing Kuhn poker (@fig:kuhn-tfdp).

  #align(center)[
    #image("figures/efg_intro/kuhn_alternatives-transparent.png", width: 100.0%)
  ]
]

#example[
  A valid TFDP representing the decision process of Player 1 in the small game of @ex:small-efg is shown below.

  #align(center)[
    #image("figures/efg_intro/small_tfdp.png")
  ]
]

== Some notation <sec-tfdp-notation>

Trees always require a bit of notation to be handled properly. We introduce some notation that will be useful when discussing decision problems faced by players in tree-form games.

#block(sticky: true)[#paragraph-marker() *Decision and observation nodes, transition function:*]

- We denote the set of decision nodes in the TFDP as $cal(J)$ , and the set of observation nodes as $cal(K)$. At each decision node $j in cal(J)$ , the player selects an action from the set $A_j$ of available actions. At each observation node $k in cal(K)$, the player observes a signal $s$ from the environment out of a set of possible signals $S_k$.
- We denote $rho$ the transition function of the process. Picking action $a in A_j$ at decision node $j in cal(J)$ results in the process transitioning to $rho \( j \, a \) in cal(J) union cal(K) union {tack.t}$, where $tack.t$ denotes the end of the decision process. Similarly, the process transitions to $rho \( k \, s \) in cal(J) union cal(K) union {tack.t}$ after the player observes signal $s in S_k$ at observation node $k in cal(K)$.

#block(sticky: true)[#paragraph-marker() *Sequences:*]

- A pair $(j \, a)$ where $j in cal(J)$ and $a in A_j$ is called a non-empty sequence. The set of all non-empty sequences is denoted as $Sigma_(*) := {(j \, a) : j in cal(J) \, a in A_j}$. For notational convenience, we will often denote an element $(j \, a)$ in $Sigma$ as $j a$ without using parentheses, especially when used as a subscript.
- The symbol $∅$ denotes a special sequence called the empty sequence. The set of all sequences, including the empty one, is denoted $Sigma$.
- Given a decision node $j in cal(J)$, we denote by $p_j$ its _parent sequence_, defined as the last sequence (that is, decision point-action pair) encountered on the path from the root of the decision process to $j$. If the player does not act before $j$ (that is, $j$ is the root of the process or only observation nodes are encountered on the path from the root to $j$), we let $p_j = ∅$.
- Given a sequence $sigma in Sigma$, we denote with $C_sigma$ the set of decision nodes j whose parent sequence is $sigma$: $C_sigma := {j in cal(J) : p_j = sigma}$.

= Strategy representations in extensive-form games

What does it mean to have a mixed strategy for an extensive-form game?
We discuss ways in which one could decide to represent a strategy, and contrast their pros and cons.

== Strategic form: Extensive-form games as normal-form games <sec-strategic-form>

One classical answer is the following. Consider a player, and imagine enumerating all their deterministic strategies for the tree. A mixed strategy is then a probability distribution over these deterministic strategies.

#example[
  In the small game of @ex:small-efg, a mixed strategy for Player 1 is a probability distribution over the following 7 strategies $pi_1 \, ... \, pi_7$.

  #align(center)[
    #image("figures/efg_intro/nf_strategies.svg", width: 100.0%)
  ]

  These strategies are called the _reduced_#footnote[The term “reduced” refers to the fact that no actions are specified for parts of the games not reached due to decisions of the player in higher parts of the game tree.] _normal-form plans_ of the player.
]

By considering the normal-form game in which each player's strategy space is the set of all deterministic strategies in the tree, we have converted the extensive-form game into its _normal-form equivalent_.

*Cons*  Of course, the most glaring issue with this representation is that the number of strategies in the normal-form game is exponential in the size of the game tree. For this reason, it was long believed that operating with this normal-form representation was computationally infeasible. Historically, this led to the development of specialized algorithms for extensive-form games, such as #lecture-link("learning_efg", <sec-cfr>)[CFR and its variants]. This belief was actually unfounded. In fact, it is possible to simulate the OMWU dynamics in the normal-form equivalent of an extensive-form game exactly in polynomial time. The #lecture-link("kernelized", <sec-kernelization>)[kernelization construction] explains how.

*Pros*  By virtue of this conversion, the machinery and concepts of normal-form games can be applied to extensive-form games, such as Nash equilibria, correlated equilibria, and so on.

== Behavioral form <sec-behavioral-form>

A different conceptualization of a strategy for a player is as a choice of (independent) distributions over the set of actions $A_j$ at each decision node $j in cal(J)$. This is called a _behavioral strategy_. We can represent it accordingly as a vector $vx in bb(R)_(>= 0)^Sigma$ indexed over sequences. Each entry $x_(j a)$ assigns to action $a$ at decision node $j$ the probability of picking that action at that decision node. The set of all possible behavioral strategies is clearly convex, as it is the Cartesian product of probability simplexes---one per each decision node.

*Cons*  However, this representation has a major drawback: the probability of reaching a particular terminal state in the decision process is the product of all actions on the path from the root to the terminal state. This makes many expressions of interest that depend on the probability of reaching terminal states (including crucially the expected utility in the game) non-convex.

#example[
  Consider the game of Kuhn poker, and let $vx \, vy$ be behavioral strategies for both players. The expected utility function for Player 1 is given by

  $
    u_1 (vx \, vy) & := (- 1) dot.op x_(upsans(A \, c h k)) dot.op y_(upsans(P \, c h k)) + (- 1) dot.op x_(upsans(A \, c h k)) dot.op y_(upsans(P \, b e t)) dot.op x_(upsans(D \, f o l d))\
    & #h(2em) + (- 2) dot.op x_(upsans(A \, c h k)) dot.op y_(upsans(P \, b e t)) dot.op x_(upsans(D \, c a l l)) + dots.h.c .
  $

  This is not a convex function of $vx$, as it contains products of entries of $vx$.
]

*Pros*  One might wonder whether behavioral strategies have the same representational power as normal-form strategies. After all, a normal-form strategy is an object in a much larger space, so it is conceivable that "more might be possible" in the strategic form. The relationship is characterized by Kuhn's theorem.

#definition[Realization equivalence][
  Two strategies of a player are _realization-equivalent_ if, for every strategy profile of the other players, they induce the same probability distribution over terminal histories.
] <def:realization-equivalence>

#theorem[Kuhn's theorem #citep(<Kuhn53:Extensive>)][
  In a perfect-recall extensive-form game, every normal-form strategy of a player is realization-equivalent to a behavioral strategy, and vice versa.
]

== Sequence form <sec-sequence-form>

The _sequence-form representation_ #citep(<Romanovskii62:Reduction>, <Koller96:Efficient>, <Stengel96:Efficient>) soundly resolves the issue of non-convexity. Like behavioral strategies, in the sequence-form representation a strategy is a vector $vx in bb(R)_(>= 0)^Sigma$ whose entries are indexed by $Sigma$. However, the generic entry $x_(j a)$ contains the _product_ of the probabilities of all actions at all decision nodes on the path from the root of the process to action $a$ at decision node $j$. In order to be a valid sequence-form strategy, the entries in $vx$ must therefore satisfy the following probability-flow-conservation constraints:

#definition[
  The polytope of sequence-form strategies of a TFDP is the convex polytope

  $
    cal(Q) := {vx in bb(R)_(>= 0)^Sigma : #h(2em) x_∅ = 1 \, #h(2em) sum_(a in A_j) x_(j a) = x_(p_j) quad forall j in cal(J)} .
  $
] <def:sf>

Conversely, it is easy to see that any $vx$ that satisfies the above constraints is the sequence-form representation of at least one behavioral strategy.

#example[
  Consider the tree-form decision process faced by Player 1 in the small game of @ex:small-efg. The decision process has four decision nodes $J = {upsans(A) \, upsans(B) \, upsans(C) \, upsans(D)}$ and nine sequences including the empty sequence $∅$. For decision node D, the parent sequence is $p_(upsans(D)) = upsans(A 2)$; for $upsans(B)$ and $upsans(C)$ it is $p_(upsans(B)) = p_(upsans(C)) = upsans(A 1)$; for $upsans(A)$ it is the empty sequence $p_(upsans(A)) = ∅$. The constraints that define the sequence-form polytope @def:sf, besides nonnegativity, are

  #wrapped-figure(
    [
      $
        cases(x_∅ = 1, x_(upsans(A 1)) + x_(upsans(A 2)) = x_∅, x_(upsans(B 3)) + x_(upsans(B 4)) = x_(upsans(A 1)), x_(upsans(C 5)) + x_(upsans(C 6)) = x_(upsans(A 1)), x_(upsans(D 7)) + x_(upsans(D 8)) + x_(upsans(D 9)) = x_(upsans(A 2)) .)
      $
    ],
    [#image("figures/efg_intro/small_tfdp.png", width: 170pt)],
    side: right,
    text-width: 65%,
  )
]

*Pros*  This representation of extensive-form games is convex. Hence, we can use all the convex optimization tools we have seen so far.

= Practice problems <sec-efg-practice>

The following problems relate the normal-form and extensive-form representations of a game, and then show that perfect-information games, a subclass of extensive-form games, always have pure Nash equilibria, unlike games in general. In the game trees below, black nodes belong to Player~1, white nodes belong to Player~2, squares are terminal histories, and shaded regions are information sets.

#exercise[From normal form to extensive form][
  Prove that any finite normal-form game with $N$ players, each having $K$ available actions, can be represented as an extensive-form game. Your proof should be constructive---that is, you should describe a general procedure that takes the game's payoff structure as input and produces a valid game tree. How many leaves (terminal nodes) does this game tree have?
] <ex-nfg-to-efg>

#solution[
  Let the normal-form game have action sets $A_1, ..., A_N$ with $|A_i| = K$, and payoff functions $u_i : A_1 times dots.c times A_N -> bb(R)$. The idea is to let the players move one after the other, while hiding all earlier moves from each player, so that the sequential tree reproduces simultaneous play.

  *Construction.* Build the tree level by level.
  + The root is a history of Player~1, with one outgoing edge for each action $a_1 in A_1$.
  + For $i = 2, ..., N$, each history at depth $i - 1$ corresponds to the partial profile $(a_1, ..., a_(i-1))$ of actions on its path. Assign every such history to Player~$i$, with one outgoing edge for each action $a_i in A_i$. Place all $K^(i-1)$ histories at depth $i - 1$ in a _single_ information set $I_i$ of Player~$i$. This is legal because all of them belong to Player~$i$, have the same action set $A_i$, and lie at the same depth, so none is a prefix of another.
  + Each history at depth $N$ is a terminal history $z = (a_1, ..., a_N)$, with payoffs $u_i (z) := u_i (a_1, ..., a_N)$ for every player $i$.
  The tree has no chance nodes.

  *Correctness.* Each player $i$ has exactly one information set, $cal(I)_i = {I_i}$, with $A_(I_i) = A_i$. So a pure strategy of Player~$i$ in the tree is exactly an action $a_i in A_i$, and a mixed strategy is exactly a distribution over $A_i$. A pure profile $(a_1, ..., a_N)$ leads from the root to the unique terminal history $(a_1, ..., a_N)$, whose payoffs are $u_i (a_1, ..., a_N)$. Hence the tree has the same strategy sets and payoff functions as the original game: its normal form is the original game, and in particular the two have the same Nash equilibria.

  *Number of leaves.* Each level multiplies the number of histories by $K$, so there are $K^i$ histories at depth $i$, and the tree has
  $
    |Z| = K^N
  $
  leaves, one per pure strategy profile.
]

#exercise[Rock-paper-scissors as a game tree][
  Apply the procedure of @ex-nfg-to-efg to the game of rock-paper-scissors. Draw the complete extensive-form game tree. Assume the standard payoffs: the winner receives $+1$, the loser receives $-1$, and a tie results in $0$ for both players. Be sure to correctly draw and label all nodes, actions, payoffs, and the information set(s) for Player~2.
] <ex-rps-efg>

#solution[
  Here $N = 2$ and $K = 3$, with actions $upsans(R)$ (rock), $upsans(P)$ (paper), and $upsans(S)$ (scissors). Player~1 acts at the root, which forms information set $upsans(A)$. Each of Player~1's actions leads to a history of Player~2, and these three histories form Player~2's single information set $upsans(B)$. Each of the $3^2 = 9$ leaves is labeled with the payoffs $(u_1, u_2)$: the leaf reached by $(a_1, a_2)$ gets $(0, 0)$ if $a_1 = a_2$, $(+1, -1)$ if $a_1$ beats $a_2$ ($upsans(R)$ beats $upsans(S)$, $upsans(S)$ beats $upsans(P)$, and $upsans(P)$ beats $upsans(R)$), and $(-1, +1)$ otherwise.

  #align(center)[
    #image("figures/efg_intro/rps_efg.svg")
  ]

  The information set $upsans(B)$ is essential: without it, Player~2 would observe Player~1's move before acting, which is a different game.
]

#exercise[From extensive form to normal form][
  Prove that any finite extensive-form game can be converted into a normal-form representation.
] <ex-efg-to-nfg>

#solution[
  Fix a finite extensive-form game with players $[n]$, information sets $cal(I)_i$ for each player $i in [n]$, terminal histories $Z$, and payoffs $u_i : Z -> bb(R)$. We fill in the details of the construction sketched in @sec-strategic-form.

  *Strategies.* A pure strategy must tell Player~$i$ what to do wherever they may be called to act. The player cannot distinguish histories in the same information set, so a pure strategy picks one action per information set:
  $
    S_i := product_(I in cal(I)_i) A_I, quad s_i = (s_i (I))_(I in cal(I)_i).
  $
  The tree is finite, so $cal(I)_i$ and every $A_I$ are finite, and $S_i$ is finite with $|S_i| = product_(I in cal(I)_i) |A_I|$.

  *Payoffs.* Fix a pure profile $s = (s_1, ..., s_n)$. Call a terminal history $z in Z$ _consistent_ with $s$ if, at every history $h$ on the path from the root to $z$ that belongs to a player $i in [n]$, the path takes action $s_i (I)$, where $I in cal(I)_i$ is the information set containing $h$. Let $p_c (z)$ be the product of the probabilities of the chance actions on the path to $z$, with $p_c (z) = 1$ if there are none, and set
  $
    PP_s (z) := cases(p_c (z) & "if" z "is consistent with" s\,, 0 & "otherwise.")
  $
  We claim this is the distribution over terminal histories induced by $s$. Indeed, by induction on depth, when the players follow $s$, each history is reached with probability equal to the product of the chance probabilities on its path if every player action on that path agrees with $s$, and $0$ otherwise: a history of Player~$i$ in information set $I$ passes all of its probability to the child reached by $s_i (I)$, and a chance history splits its probability by the chance probabilities. At the terminal histories this is $PP_s$. Define
  $
    U_i (s) := sum_(z in Z) PP_s (z) u_i (z) quad forall i in [n].
  $
  The normal-form game with players $[n]$, finite strategy sets $S_i$, and payoffs $U_i$ is the required representation. By construction, $U_i (s)$ is Player~$i$'s expected payoff when the players follow $s$ in the tree. A mixed profile $(sigma_1, ..., sigma_n)$ corresponds to each player independently sampling $s_i ~ sigma_i$ before play starts and then following $s_i$, so by linearity of expectation its expected payoff in the tree equals its mixed payoff in the normal-form game.
]

#exercise[Computing a normal form][
  Consider the simple two-player extensive-form game below. The top number at each leaf is the payoff of Player~1, and the bottom number is the payoff of Player~2.

  #align(center)[
    #image("figures/efg_intro/practice_efg.svg")
  ]

  List all distinct pure strategies for Player~1 and Player~2. Then construct the normal-form representation of this game. The rows should correspond to Player~1's strategies and the columns to Player~2's strategies. The entries in the matrix should be the payoff tuples $(u_1, u_2)$ that result from each strategy profile.
] <ex-efg-to-nfg-example>

#solution[
  *Player~1* has three information sets: $upsans(A)$ with actions ${upsans(1), upsans(2)}$, $upsans(B)$ with actions ${upsans(3), upsans(4)}$, and $upsans(C)$ with actions ${upsans(5), upsans(6), upsans(7)}$. We write a pure strategy as the actions it picks at $upsans(A)$, $upsans(B)$, and $upsans(C)$, in this order. There are $2 dot 2 dot 3 = 12$ of them:
  $
    upsans("135"), upsans("136"), upsans("137"), upsans("145"), upsans("146"), upsans("147"), upsans("235"), upsans("236"), upsans("237"), upsans("245"), upsans("246"), upsans("247").
  $

  *Player~2* has two information sets: $upsans(X)$ with actions ${upsans(a), upsans(b)}$, and $upsans(Y)$ with actions ${upsans(c), upsans(d)}$. Writing the actions at $upsans(X)$ and $upsans(Y)$ in order gives $2 dot 2 = 4$ pure strategies:
  $
    upsans("ac"), upsans("ad"), upsans("bc"), upsans("bd").
  $

  *Normal form.* Each entry follows the path a profile induces; for example, under $(upsans("236"), upsans("ad"))$ play follows $upsans(2)$, then $upsans(d)$, then $upsans(6)$, which yields $(8, 12)$. The resulting normal form, with rows reordered to group payoff-equivalent strategies of Player~1, is
  #align(center, block(breakable: false, table(
    columns: 5,
    [], [$upsans("ac")$], [$upsans("ad")$], [$upsans("bc")$], [$upsans("bd")$],
    [$upsans("135")$], [$3, 10$], [$3, 10$], [$6, 6$], [$6, 6$],
    [$upsans("136")$], [$3, 10$], [$3, 10$], [$6, 6$], [$6, 6$],
    [$upsans("137")$], [$3, 10$], [$3, 10$], [$6, 6$], [$6, 6$],
    [$upsans("145")$], [$6, 3$], [$6, 3$], [$4, 12$], [$4, 12$],
    [$upsans("146")$], [$6, 3$], [$6, 3$], [$4, 12$], [$4, 12$],
    [$upsans("147")$], [$6, 3$], [$6, 3$], [$4, 12$], [$4, 12$],
    [$upsans("235")$], [$5, 5$], [$-2, 3$], [$5, 5$], [$-2, 3$],
    [$upsans("245")$], [$5, 5$], [$-2, 3$], [$5, 5$], [$-2, 3$],
    [$upsans("236")$], [$10, 7$], [$8, 12$], [$10, 7$], [$8, 12$],
    [$upsans("246")$], [$10, 7$], [$8, 12$], [$10, 7$], [$8, 12$],
    [$upsans("237")$], [$1, 7$], [$9, 5$], [$1, 7$], [$9, 5$],
    [$upsans("247")$], [$1, 7$], [$9, 5$], [$1, 7$], [$9, 5$],
  )))
  Rows within a group coincide because after $upsans(1)$ information set $upsans(C)$ is never reached, and after $upsans(2)$ information set $upsans(B)$ is never reached. Collapsing each group gives the five reduced normal-form plans $upsans("13"), upsans("14"), upsans("25"), upsans("26"), upsans("27")$ of @sec-strategic-form. Player~2's strategies do not collapse in this way: for example, $upsans("ac")$ and $upsans("ad")$ agree on the $upsans(1)$-rows but differ on the $upsans(2)$-rows.
]

We now analyze a special class of extensive-form games. A _perfect-information sequential game_ is one whose game tree has only singleton information sets, so each player knows exactly which history they are at, and no chance nodes; tic-tac-toe, chess, and go are classic examples. While normal-form games do not always have a pure Nash equilibrium (think of rock-paper-scissors), perfect-information sequential games always do.

#exercise[Pure equilibria in perfect-information games][
  Prove that every finite perfect-information sequential game has a _pure_ Nash equilibrium, that is, one in which every player uses a _deterministic_ strategy (all probability mass placed on one action).
] <ex-pure-ne-perfect-info>

#solution[
  We use _backward induction_. All information sets are singletons, so a pure strategy of Player~$i$ picks an action $s_i (h) in A_h$ at every history $h$ of Player~$i$, where $A_h$ is the set of actions available at $h$. For any history $h$, the subtree rooted at $h$ is itself a finite perfect-information game, which we denote $Gamma_h$. There are no chance nodes, so every pure profile of $Gamma_h$ leads to a single terminal history. We prove the following claim by strong induction on the height of the subtree rooted at $h$:

  _For every history $h$, the game $Gamma_h$ has a pure Nash equilibrium $s^h$._

  We write $vv(h) in bb(R)^n$ for the payoffs of $s^h$. Applying the claim at the root proves the result.

  *Base case.* If $h$ is terminal, nobody acts in $Gamma_h$. The empty profile is trivially an equilibrium, with $v_i (h) = u_i (h)$.

  *Inductive step.* Let $h$ be a non-terminal history belonging to Player~$i$, and for each $a in A_h$ let $h a$ denote the child reached by playing $a$. Each subtree rooted at $h a$ has smaller height, so by the inductive hypothesis $Gamma_(h a)$ has a pure equilibrium $s^(h a)$ with payoffs $vv(h a)$. Since $A_h$ is finite and nonempty, we can pick
  $
    a^star in argmax_(a in A_h) v_i (h a).
  $
  Define the pure profile $s^h$ of $Gamma_h$ to play $a^star$ at $h$ and to follow $s^(h a)$ at every history in the subtree rooted at $h a$, for every $a in A_h$. This is well defined because the subtrees are disjoint. Under $s^h$, play moves to $h a^star$ and then follows $s^(h a^star)$, so $vv(h) = vv(h a^star)$.

  Next we check that no player $j$ has a profitable pure deviation $s'_j$ in $Gamma_h$, where the other players keep playing $s^h_(-j)$.
  - If $j = i$ and $s'_i (h) = a != a^star$, play moves to $h a$ and continues in $Gamma_(h a)$, where Player~$i$ deviates from the equilibrium $s^(h a)$ alone. By the inductive hypothesis, Player~$i$ gets at most $v_i (h a) <= v_i (h a^star) = v_i (h)$.
  - Otherwise, either $j != i$ or $s'_i (h) = a^star$, and play moves to $h a^star$. From there, Player~$j$ deviates alone from the equilibrium $s^(h a^star)$ of $Gamma_(h a^star)$, so by the inductive hypothesis gets at most $v_j (h a^star) = v_j (h)$. Choices in subtrees other than the one rooted at $h a^star$ are never reached and do not affect the payoff.
  Pure deviations therefore do not help. Since the opponents play deterministically, the payoff of a mixed deviation is an average of the payoffs of pure deviations, so it cannot help either. Hence $s^h$ is a pure Nash equilibrium of $Gamma_h$, completing the induction.

  Perfect information is what makes each $Gamma_h$ a game of its own and lets Player~$i$ pick $a^star$ separately at each history; in rock-paper-scissors (@ex-rps-efg), by contrast, Player~2 must pick one action for all of $upsans(B)$. Finally, $s^h$ restricts to $s^(h')$ on the subtree rooted at any history $h'$ below $h$, so the profile built at the root is an equilibrium of every $Gamma_h$, that is, a subgame perfect equilibrium, which rules out the non-credible threats discussed in #lecture-link("perfection").
]

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
