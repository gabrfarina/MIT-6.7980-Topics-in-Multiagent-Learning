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
  As a running example, we will illustrate the representation by analyzing the game tree of a simplified two-player variant of poker (perhaps the archetype of imperfect-information extensive-form games), known as _Kuhn poker_ #citep(<Kuhn50:Simplified>). As noted by Kuhn himself, even the previous small game already captures central aspects of deceptive behavior such as _bluffing_ and _underbidding_.

  #align(center)[
    #image("figures/efg_intro/kuhn.svg", width: 100.0%)
  ]
] <ex:kuhn>

#paragraph-marker(shape: "triangle-up") *The rules of Kuhn poker*~~ In the game tree of Kuhn poker, the root history of the tree (the first move in the game) belongs to the _nature player_ $c$. It models a dealer that privately deals one card to each player from a shuffled deck containing cards Jack, Queen, King. The actions of the nature player correspond to the six possible assignments of two cards from the deck, which are annotated on the edges; for example, the leftmost edge $upsans("JK")$ corresponds to the case in which Player 1 is dealt a Jack and Player 2 is dealt a King. Since the deck is shuffled, each of the six actions are selected with probability 1/6 by the nature player. No matter the action selected by the dealer, the game transitions to a history of Player 1, which marks the beginning of what in poker is called a “betting round”. First, Player 1 decides to either check (continue without betting any money) or bet \$1. Then,

- If Player 1 checks, Player 2 can either check, or bet \$1.
  - If Player 2 checks, the game terminates with a showdown: the player with the higher card receives from the other player whatever amount the other player bet, plus an ante amount of \$1.
  - If, instead, Player 2 bets the additional \$1, then Player 1 can either fold his hand or call, that is, raise his bet by \$1.
    - If Player 1 folds, he has to give Player 2 only the \$1 ante;
    - if Player 1 calls, a showdown with the same dynamics as before.
- If Player 1 bets the \$1, Player 2 can either fold her hand or call.
  - If Player 2 folds her hand, Player 2 gives Player 1 the \$1 ante.
  - If, instead, Player 2 calls the bet, she increases her bet by \$1 and a showdown occurs, with the same dynamics as before.

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
  - Given any decision node $j = I in cal(I)_i$, the sequence of decision nodes and actions encountered from the root of the TFDP to $j$ is equal to the trace of any history $h in I$.
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

*Pros*  One might wonder whether behavioral strategies have the same representational power as normal-form strategies. After all, a normal-form strategy is an object in a much larger space, so it is conceivable that "more might be possible" in the strategic form. A positive answer equating the powers of normal-form and behavioral strategies is given by Kuhn's theorem, which requires that the game is perfect recall.

#theorem[Kuhn's theorem][
  In a perfect recall extensive-form game, any distribution over terminal nodes that can be induced via normal-form strategies can be induced via behavioral strategies, and _vice versa_.
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

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
