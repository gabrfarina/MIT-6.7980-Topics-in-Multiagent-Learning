#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 1,
  date: [Tue, Sep 15, 2026],
  title: "Setting and equilibria: the Nash equilibrium",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

Normal-form games model simultaneous-move interactions with a single move (think about rock-paper-scissors). Despite their simplicity, normal-form games will provide a natural ground for looking into important concepts in multiagent settings, such as notions of equilibria (Nash, maxmin, correlated, $...$), and learning from repeated play. In the second part of the course, we will move on to notions of games that explicitly capture more complex phenomena, such as sequential moves and imperfect information.

*What is a game?* Games are thought experiments that help us _predict rational behavior in situations of conflict_. Each part of this phrase has a specific meaning:

- _Situation of conflict:_ every player's actions affect the outcomes of the others.
- _Rational behavior:_ each player wants to maximize their own expected utility. There is no altruism, envy, masochism, or externality.
- _Predict:_ we want to know what happens when the game is played. Such predictions are called _solution concepts_. The Nash equilibrium, which is the focus of this lecture, is the most prominent one.

Many situations are able to be modeled as games. Besides recreational games such as rock-paper-scissors, poker, Go, and Diplomacy, game-theoretic models apply to auctions, markets, logistics, budget allocation, generative adversarial networks, multi-robot interactions, fraud detection systems, cyber-defense, and agentic AI.

= Normal-form games and the Nash equilibrium <sec-normal-form>

When introducing a (finite) normal-form game, we need to specify the following quantities:

- The set of players $\[ n \] = {1 \, ... \, n}$.
- For each player $i in \[ n \]$, a finite set of actions $A_i$.
- For each player $i in \[ n \]$, the payoff function $u_i : A_1 times dots.h.c times A_n -> bb(R)$.

To represent a normal-form game, it is common to use a matrix representation.

#example[
  #wrapped-figure(side: right, text-width: 65%)[
    For instance, in the $2 times 2$ game on the right, called “prisoner's dilemma”, the rows correspond to the actions of Player 1, and the columns correspond to the actions of Player 2.

    The entries at row $i$, column $j$ are the payoffs of the two players when Player 1 plays action $i$ and Player 2 plays action $j$.
  ][
    #image("figures/nfgs_nash/prisoner_dilemma.svg", width: 103.498pt)
  ]
]

*Notation.* We write vectors in bold, including a player’s entire strategy $vx_i$, and scalar coordinates in plain type, such as $x_(i \, a_i)$. Hats, bars, and time indices preserve this distinction. Explicit indexing such as $vx[a]$ also denotes a scalar coordinate.



#example[Introductory utility computation][
  Suppose Player 1 and Player 2 from the prisoner's dilemma (Example 1.1) randomize their actions. Let Player 1 flip a fair coin, playing the strategy $vx_1 = (0.5 \, 0.5)$ for (Deny, Confess). Let Player 2 lean heavily toward denying, playing $vx_2 = (0.8 \, 0.2)$.

  Player 1's expected utility is simply the sum of their payoffs for each possible outcome, weighted by the joint probability of that outcome occurring:
  
  $ u_1 (vx_1 \, vx_2) & = (0.5)(0.8)(-1) + (0.5)(0.2)(-3) + (0.5)(0.8)(0) + (0.5)(0.2)(-2) \
    & = -0.4 - 0.3 + 0 - 0.2 \
    & = -0.9 . $
]


*Strategies*  A _randomized strategy_ (also known as _mixed strategy_) for a generic player $i in \[ n \]$ is a distribution over the set of actions. We can represent such an object as a vector $vx_i in Delta (A_i)$, that is, such that $vx_i >= 0$ and $sum_(a_i in A_i) x_(i \, a_i) = 1$. To lighten the notational burden, we will write the expected utility when all players play according to strategies $vx_1 \, ... \, vx_n$ reusing the same letter $u_i$ as the payoff, _i.e._,

$
  u_i (vx_1 \, ... \, vx_n) & := bb(E)_(a_1 ~ vx_1\
  ...\
  a_n ~ vx_n) [u_i (a_1 \, ... \, a_n)]\
  & = sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) x_(1 \, a_1) dots.h.c x_(n \, a_n) dot.op u_i (a_1 \, ... \, a_n) .
$

We will sometimes intersperse deterministic actions and mixed strategies freely and write expressions such as $u_i (a_1 \, vx_2 \, ... \, vx_n)$ to mean the expected utility when player 1 plays action $a_1$ and the other players play according to the strategies $vx_2 \, ... \, vx_n$.

== Dominant-strategy equilibrium

The question of what constitutes rational play for players can get complicated depending on the game. But, in some lucky cases, like the prisoner's dilemma game above, it turns out that some actions are just _better_ than others, _no matter what the other players do_. In such cases, we say that a player has a _dominant strategy_. In the case above, both Player 1 and Player 2 have a dominant strategy to confess. Indeed, consider Player 1: if Player 2 denies, confessing yields a payoff of $0$ instead of $-1$; if Player 2 confesses, confessing yields $-2$ instead of $-3$. Either way, Player 1 is strictly better off confessing, and by symmetry the same holds for Player 2. When every player has a dominant strategy, we expect that the players will play it, and the resulting strategy profile is called a _dominant-strategy equilibrium_.

The prisoner's dilemma also shows that equilibrium play need not be good for the players. At the dominant-strategy equilibrium, both players receive $-2$, whereas if both had denied, both would have received $-1$. Each player's individual incentive to confess leads to an outcome that is worse for _everyone_.

Unfortunately, dominant strategies are the exception rather than the rule. Most games of interest have no dominant-strategy equilibrium, as the following example shows.

#example[Rock-paper-scissors][
  #wrapped-figure(side: right, text-width: 55%)[
    In rock-paper-scissors, each player simultaneously picks one of three actions. Rock beats scissors, scissors beats paper, and paper beats rock; the winner receives a payoff of $1$, the loser $-1$, and a tie gives $0$ to both players. This is the payoff matrix on the right.
  ][
    #image("figures/nfgs_nash/rock_paper_scissors.svg", width: 142.42pt)
  ]

  No action of Player 1 is better than the others no matter what Player 2 does. Every action is the best reply to one of the opponent's actions and the worst reply to another: rock is the best reply to scissors but the worst reply to paper, paper is the best reply to rock but the worst reply to scissors, and scissors is the best reply to paper but the worst reply to rock. Which action is best depends entirely on what the opponent does.

  In fact, not even a randomized strategy of Player 1 can be dominant. Suppose $vx_1 in Delta (A_1)$ were dominant. Against scissors, rock earns the largest payoff in the game, $1$, and it is the only action that does so; hence, for $vx_1$ to be at least as good as rock against scissors, $vx_1$ must put all of its mass on rock. By the same argument applied to paper, against which only scissors earns $1$, $vx_1$ must put all of its mass on scissors. These two requirements are incompatible, so Player 1 has no dominant strategy. By symmetry, neither does Player 2, and the game has no dominant-strategy equilibrium.
]

== Maxmin strategies

The benefit of dominant-strategy equilibria is that they require no counterspeculation: some strategies just are better no matter what anyone else does. However, as rock-paper-scissors shows, in many games no player has a dominant strategy: the best action depends on what the other players do. How can we find a good strategy in such games?

One way to think about this is to consider the worst-case scenario: what is the best strategy for a player if they assume the other players are trying to minimize their payoff? This is the idea behind _maxmin strategies_. A maxmin strategy for Player $i$ is a strategy $vx_i$ that maximizes the minimum payoff that Player $i$ can get, that is,

$
  vx_i in "arg max"_(vx_i in Delta (A_i)) min_(vx_j in Delta (A_j)\
  upright("for all") j != i) u_i (vx_i \, vx_(- i)) \,
$

where the notation $vx_(- i)$ is popular syntactic sugar to denote the tuple $(vx_j)_(j != i)$.#footnote[This notation appears often in game theory, since we are often interested in studying the effect of changing a _single_ player $i$'s strategy, while keeping all “the other” strategies $vx_(- i)$ fixed.]  In words, a maxmin strategy _prepares for the worst_: it is the strategy whose guaranteed payoff, against the most harmful possible behavior of the other players, is as large as possible.

Thinking back about rock-paper-scissors, intuition suggests that the maxmin strategy is to play uniformly at random: the opponent could exploit any other strategy more than the uniform one, by playing the counteraction more often. The following example makes this intuition precise.

#example[Maxmin strategies in rock-paper-scissors][
  In rock-paper-scissors, rock beats scissors, scissors beats paper, and paper beats rock; the winner receives a payoff of $1$, the loser $-1$, and a tie gives $0$ to both players. Write $vx = (x_R \, x_P \, x_S)$ for the strategy of Player 1 and $vy = (y_R \, y_P \, y_S)$ for the strategy of Player 2, where the subscripts denote rock, paper, and scissors. Summing over the nine pairs of actions, the expected utility of Player 1 is

  $
    u_1 (vx \, vy) = x_R (y_S - y_P) + x_P (y_R - y_S) + x_S (y_P - y_R) .
  $

  Preparing for the worst means solving $max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) u_1 (vx \, vy)$. We solve the two optimization problems from the inside out.

  *The worst case for a fixed strategy.* Fix $vx$. The expected utility $u_1 (vx \, vy) = y_R u_1 (vx \, R) + y_P u_1 (vx \, P) + y_S u_1 (vx \, S)$ is an average of the utilities against the three actions of Player 2, and an average is never smaller than its smallest term. Hence, the most harmful behavior of Player 2 is always attained by a deterministic action, and

  $
    min_(vy in Delta (A_2)) u_1 (vx \, vy) = min {underbrace(x_P - x_S, "vs. rock") \, underbrace(x_S - x_R, "vs. paper") \, underbrace(x_R - x_P, "vs. scissors")} .
  $

  *The best worst case.* The three quantities in the minimum sum to $0$, so their minimum is at most their average, which is $0$. Furthermore, the minimum equals $0$ only if all three quantities are equal to $0$, that is, only if $x_R = x_P = x_S$. Hence,

  $
    max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) u_1 (vx \, vy) = 0 \, #h(2em) "attained uniquely at" #h(2em) vx^* = (1/3 \, 1/3 \, 1/3) .
  $

  Every other strategy guarantees a strictly negative payoff, because Player 2 can counter whichever action Player 1 favors. For instance, the strategy $vx = (1/2 \, 1/2 \, 0)$ that never plays scissors earns $1/2$ against rock and $0$ against scissors, but $-1/2$ against paper. Since the game is symmetric, the same computation shows that the unique maxmin strategy of Player 2 is also uniform, $vy^* = (1/3 \, 1/3 \, 1/3)$, which guarantees Player 2 a payoff of $0$ as well.
] <ex:rps-maxmin>

The maxmin strategies of rock-paper-scissors enjoy a further remarkable property. Suppose that Player 2 plays the uniform strategy $vy^*$. Then every action of Player 1 has the same expected utility,

$
  u_1 (R \, vy^*) = u_1 (P \, vy^*) = u_1 (S \, vy^*) = 1/3 (0 + 1 - 1) = 0 \,
$

and so every strategy of Player 1, including $vx^*$, earns exactly $0$ against $vy^*$. In particular, no strategy of Player 1 does better against $vy^*$ than $vx^*$ does: $vx^*$ is _optimal against_ $vy^*$. By symmetry, $vy^*$ is optimal against $vx^*$ too. So, even though each player derived their strategy by assuming the worst about the opponent, neither player has any reason to regret this choice once they see what the opponent actually plays.

This is not a coincidence specific to rock-paper-scissors: the same happens in _every_ two-player zero-sum game, that is, those two-player games where $u_1 (a_1 \, a_2) + u_2 (a_1 \, a_2) = 0$ for all combinations of actions. In such games, a pair of maxmin strategies always consists of strategies that are optimal against each other. This fact is a consequence of #lecture-link("correlated", <sec-zero-sum>)[von Neumann's minimax theorem], which states that in two-player zero-sum games the order of the maximization and the minimization does not matter, _i.e._, $max_(vx) min_(vy) u_1 (vx \, vy) = min_(vy) max_(vx) u_1 (vx \, vy)$. We will study this connection in depth when we return to two-player zero-sum games.

As we have just seen, the above idea has particular merit in two-player zero-sum games. In those games, players are in direct competition, so it makes sense to assume that the opponent is “out to get us.” But in more general games, the maxmin strategy can be too conservative, since it assumes that all other players have nothing better going on than to minimize our payoff, even if that hurts them.

== The Nash equilibrium <sec-nash-equilibrium>

Before introducing the Nash equilibrium, let us see concretely how maxmin strategies can go wrong outside of two-player zero-sum games.

#example[Maxmin strategies in theater or football][
  #wrapped-figure(side: right, text-width: 65%)[
    Two friends are planning an evening out, and each has a favorite activity: one prefers the theater, the other prefers football. Each friend can either _insist_ on their favorite activity or _accept_ the other's. If exactly one of them insists, they go to that friend's favorite activity: the insisting friend receives a payoff of $5$, while the accepting friend, who still enjoys the company, receives $1$. If both insist or both accept, they fail to agree on a plan, and both receive $0$. This is the payoff matrix on the right.
  ][
    #image("figures/nfgs_nash/theater_football.svg", width: 100.223pt)
  ]

  *Computing the maxmin strategies.* Let $p$ denote the probability with which Player 1 insists, so that Player 1 accepts with probability $1 - p$. As in any game, for a fixed strategy $vx_1$ of Player 1, the expected utility $u_1 (vx_1 \, vx_2)$ is an average of the utilities against the deterministic actions of Player 2, so the most harmful behavior of Player 2 is attained by a deterministic action. Player 1 receives $1$ only when accepting while Player 2 insists, and $5$ only when insisting while Player 2 accepts, so

  $
    u_1 (vx_1 \, "insist") = 1 - p \, #h(2em) u_1 (vx_1 \, "accept") = 5 p \,
  $

  and hence $min_(vx_2 in Delta (A_2)) u_1 (vx_1 \, vx_2) = min {1 - p \, 5 p}$.

  The first term decreases with $p$ while the second increases, so the minimum is largest when the two terms are equal, that is, when $1 - p = 5 p$, or $p = 1/6$. Hence, the unique maxmin strategy of Player 1 is to insist with probability $1/6$ and accept with probability $5/6$, which guarantees Player 1 an expected payoff of $5/6$ no matter what Player 2 does. Since the game is symmetric, the unique maxmin strategy of Player 2 is also to insist with probability $1/6$ and accept with probability $5/6$. Denote these maxmin strategies by $vx_1^*$ and $vx_2^*$.

  *The maxmin strategies are not optimal against each other.* Suppose that Player 2 plays the maxmin strategy $vx_2^*$. Then Player 1's actions and maxmin strategy earn

  $
    u_1 ("insist" \, vx_2^*) & = 5 dot.op 5/6 = 25/6 \,\
    u_1 ("accept" \, vx_2^*) & = 1 dot.op 1/6 = 1/6 \,\
    u_1 (vx_1^* \, vx_2^*) & = 1/6 dot.op 25/6 + 5/6 dot.op 1/6 = 5/6 .
  $

  So, against $vx_2^*$, Player 1 would be better off abandoning the maxmin strategy and always insisting, earning $25/6$ instead of $5/6$: five times as much. By symmetry, Player 2 would similarly want to deviate from $vx_2^*$ against $vx_1^*$. In other words, if each player expects the other to play their maxmin strategy, then neither player wants to play their own maxmin strategy.
] <ex:tof-maxmin>

What went wrong? Each player's maxmin strategy was computed under the pessimistic assumption that the other player is out to minimize their payoff. But in theater or football, the other player has no interest in doing so: for instance, when Player 1 insists, Player 2 prefers accepting (payoff $1$) to insisting (payoff $0$), even though accepting hands Player 1 their best outcome. Preparing for the worst thus leads both players to insist rarely, which in turn makes insisting very attractive to each of them. The maxmin strategies are therefore not a stable prediction of how the players will play: as soon as a player believes that the other is playing their maxmin strategy, the player wants to switch.

This suggests a different question: _do there exist strategies for the players that are optimal against each other?_ That is, can we find strategies such that no player would want to switch after learning what the others are playing?

In general, defining what constitutes “optimal play” is tricky. But we can start from what is convincingly _not_ optimal play: if we predict that the players should play according to some strategies $vx_1 \, ... \, vx_n$, then it is not optimal if it turned out that any player would be better off by switching to something else. This is the idea behind the _Nash equilibrium_.

#definition[Nash equilibrium][
  A strategy profile $(vx_1 \, ... \, vx_n) in Delta (A_1) times dots.h.c times Delta (A_n)$ is a _Nash equilibrium_ if no player benefits from unilaterally deviating from their strategy. In symbols,

  $
    forall i in \[ n \] \, vx'_i in Delta (A_i) \, #h(2em) #h(2em) u_i (vx'_i \, vx_(- i)) <= u_i (vx_1 \, ... \, vx_n) .
  $
] <def-nash-equilibrium>

#remark[
  Without loss of generality, when verifying if a profile $(vx_1 \, ... \, vx_n)$ is a Nash equilibrium, it is sufficient to consider only _deterministic_ deviations $a_i in A_i$. Indeed, if a player has a profitable randomized deviation, this must mean that at least one of the actions they are randomizing over is profitable.
]
#proof[
  Let $vx = (vx_1 \, ... \, vx_n)$ be a strategy profile. Assume there exists a strictly profitable randomized deviation $vx'_i in Delta (A_i)$ for player $i$, meaning:
  
  $ u_i (vx'_i \, vx_(- i)) > u_i (vx_i \, vx_(- i)) . $

  By the definition of expected utility for a mixed strategy, this is the weighted sum of the pure action payoffs:
  
  $ sum_(a_i in A_i) x'_(i \, a_i) u_i (a_i \, vx_(- i)) > u_i (vx_i \, vx_(- i)) . $

  For the sake of contradiction, assume that no deterministic action is strictly profitable. Thus, for all $a_i in A_i$:
  
  $ u_i (a_i \, vx_(- i)) <= u_i (vx_i \, vx_(- i)) . $

  Because $vx'_i$ is a valid strategy in $Delta (A_i)$, we know $x'_(i \, a_i) >= 0$ for all $a_i$ and $sum_(a_i in A_i) x'_(i \, a_i) = 1$. Multiplying our assumption by the probabilities $x'_(i \, a_i)$ and summing over all $a_i in A_i$ yields:
  
  $ sum_(a_i in A_i) x'_(i \, a_i) u_i (a_i \, vx_(- i)) & <= sum_(a_i in A_i) x'_(i \, a_i) u_i (vx_i \, vx_(- i)) \
    & = u_i (vx_i \, vx_(- i)) sum_(a_i in A_i) x'_(i \, a_i) \
    & = u_i (vx_i \, vx_(- i)) . $

  This directly contradicts our premise that $vx'_i$ yields a strictly greater expected utility than $vx_i$. Therefore, if a profitable randomized deviation $vx'_i$ exists, at least one deterministic action $a_i$ in its support (where $x'_(i \, a_i) > 0$) must also strictly improve the player's utility.
]

#example[
  The only Nash equilibrium in the game of rock-paper-scissors is for all players to play the uniform strategy. This shows that in some games, no Nash equilibrium exists in pure (_i.e._, non-randomizing) strategies.
]

#example[Theater or football][
  Consider again the theater-or-football game of @ex:tof-maxmin:

  #align(center)[
    #image("figures/nfgs_nash/theater_football.svg", width: 100.223pt)
  ]

  This game has two obvious Nash equilibria: Player 1 insisting and Player 2 accepting, or vice versa (top right and bottom left corners). However, there is a third equilibrium as well: both players accept with probability 1/6 and insist with probability 5/6.

  To verify that this third profile is a Nash equilibrium, recall that it suffices to check deterministic deviations. If Player 2 insists with probability $5/6$, then Player 1 earns $5 dot.op 1/6 = 5/6$ by insisting and $1 dot.op 5/6 = 5/6$ by accepting. Since both actions earn the same, every strategy of Player 1 earns $5/6$, and Player 1 has no profitable deviation; by symmetry, neither does Player 2. Interestingly, the equilibrium probabilities are exactly those of the maxmin strategies of @ex:tof-maxmin with the roles of the two actions swapped: at the maxmin strategies each player insists with probability $1/6$, while at this equilibrium each player insists with probability $5/6$.

  This is not a coincidence: in two-player nondegenerate games, there is always an _odd_ number of Nash equilibria. This fact comes from more profound connections with some combinatorial objects that we will uncover quite soon.
]

#remark[
  All the games considered above are _one-shot games of complete information_. _Complete information_ means that the players know everything about each other's payoffs. _One-shot_ means that the players meet for a single interaction, with no stages or sequential decisions.

  One-shot games are also meant to model repeated occurrences of the same conflict, provided there are no strategic correlations between occurrences. If such correlations exist, we leave the realm of one-shot games and enter that of _repeated games_. 
]

= Existence of mixed-strategy Nash equilibrium <sec-nash-existence>

In 1950, John Nash established one of the most celebrated results in game theory:#footnote[John Nash went on to win the Nobel prize in economics for his fundamental contributions to game theory.] mixed-strategies Nash equilibria exist in all games, no matter the number of players or number of actions. The proof of Nash is nonconstructive, and fundamentally boils down to showing that one can think of Nash equilibria as fixed points. Two remarks are in order:

- The idea that Nash equilibria can be thought of as fixed points should feel extremely natural. By definition, an equilibrium is a situation where nobody has an incentive to deviate---that is, no player has a more profitable strategy given the strategies of the other players. Hence, if we are able to introduce a function that maps a strategy profile to a profile of “improved strategies”, then a fixed point of such a function would be a Nash equilibrium. We could then use one of the many theorems in analysis that guarantee existence of fixed points. Of course, the devil is in the details: _how to handle multiple profitable responses? how to ensure continuity of the deviation function?_ These are the questions that Nash had to answer.
- The idea of viewing Nash equilibria as fixed points is not just natural, but also _the only possible_. We will make this formal towards the end of this course, when we discuss the _computational complexity_ of Nash equilibria. In particular, we will show that the computation of fixed points of continuous functions and computation of Nash equilibria are computationally equivalent, in the sense that each problem can be reduced to the other in polynomial time.

In the remainder of the lecture, we will give a proof of the existence of Nash equilibria. While the first proof of #citet(<Nash50:Equilibrium>) invokes Kakutani's fixed point theorem, a year later Nash noticed that a much more elementary proof can be given #citep(<Nash51:NonCooperative>). We present a variation of the latter today.

== The Nash improvement function <sec-nash-improvement>

As mentioned above, one can think about Nash equilibria as fixed points of a “profitable response” function from the set of mixed strategy to itself. Intuitively, this function must calculate a profitable response for each player. Furthermore, to invoke fixed point theorems, this function must be continuous. The key insight of Nash was to find a simple continuous function that, given a strategy profile, calculates a “profitable response” for each player. For lack of a better term, we will refer to this function with the term _“Nash improvement function”_.

*Regret*  To formally define the Nash improvement function, we first introduce a simple quantity called _regret_, which will be a staple of this course. The _regret_ that Player $i$ experiences with respect to action $a_i in A_i$ is the difference between the payoff that Player $i$ would have obtained by playing $a_i$, and the payoff that Player $i$ actually obtained:

$ r_(i \, a_i) (vx_1 \, ... \, vx_n) := u_i (a_i \, vx_(- i)) - u_i (vx_1 \, ... \, vx_n) . $

*The Nash improvement function*  The idea is simple: if an action $a_i$ has very large regret, then the current strategy profile cannot be an equilibrium, because Player $i$ would want to increase the probability of playing $a_i$. Thus, an “improved” strategy for Player $i$ should move more probability mass to $a_i$. We need to handle two complications: (1) if multiple actions have positive regret, how should we prioritize adding mass to those? and (2) for those actions whose regret is negative (that is, “bad” actions), should we forcefully decrease the mass?

Nash's answers to the above questions are as follows: (1) add mass to all actions with positive regret, and the amount of mass added should be proportional to the regret; (2) do not decrease the mass for actions with negative regret. To retain the fact that the output of the improvement function must be a valid strategy, the step is renormalized so that the sum of the mass across all actions of any player is $1$. We can formalize this process by using the following definition.

#definition[Nash improvement function #citep(<Nash51:NonCooperative>)][
  Let $vx_1 in Delta (A_1) \, ... \, vx_n in Delta (A_n)$ be arbitrary strategies. The _Nash improvement function_ $phi : Delta (A_1) times dots.h.c times Delta (A_n) -> Delta (A_1) times dots.h.c times Delta (A_n)$ is the map

  #math.equation(
    block: true,
    numbering: "(1)",
    $phi_(i \, a_i) (vx_1 \, ... \, vx_n) := frac(x_(i \, a_i) + [r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+), 1 + sum_(a'_i in A_i) [r_(i \, a'_i) (vx_1 \, ... \, vx_n)]^(+))$.body,
  ) <nif>

  for every player $i in \[ n \]$ and action $a_i in A_i$. Here, $\[ r \]^(+) := max {0 \, r}$ denotes the positive part of $r$.
] <def-nash-improvement>

It is straightforward to verify that $phi$ is well-defined and maps strategy profiles into strategy profiles. Indeed, the numerator in #ref(<nif>, supplement: none) is always nonnegative, and the denominator is always at least $1$, implying that $phi_(i \, a_i) >= 0$ for all $a_i in A_i$ and player $i in \[ n \]$. Furthermore,

$
  forall i in \[ n \] \, #h(2em) sum_(a_i in A_i) phi_(i \, a_i) \( vx_1 \, ... \, vx_n \) = frac(sum_(a_i in A_i) (x_(i \, a_i) + [r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+)), 1 + sum_(a'_i in A_i) [r_(i \, a'_i) (vx_1 \, ... \, vx_n)]^(+)) = 1 \,
$

where we used the fact that $sum_(a_i in A_i) x_(i \, a_i) = 1$ since $vx_i$ is a valid strategy. Finally, observe that $phi$ is a continuous function.  The following example visualizes the Nash improvement function in the small games we have seen so far.

#example[
  The plots below visualize the displacement $phi (vx_1 \, vx_2) - (vx_1 \, vx_2)$ induced by the Nash improvement function for four games, whose payoff matrices are noted below each plot #footnote[In each payoff matrix, Player 1 (blue) picks a row, *T*\op or *B*\ottom, and Player 2 (red) picks a column, *L*\eft or *R*\ight. Each cell lists Player 1's payoff first and Player 2's second. In the plots, the horizontal axis is Player 1's probability of playing B, and the vertical axis is Player 2's probability of playing R.], after projecting away the probability of the first action of each player (and keeping around only the probability of the second action, which is sufficient to uniquely recover the strategy of the player since each player only has two actions). The black dots denote the fixed points of the Nash improvement function. These correspond exactly to the Nash equilibria of the game, as we make formal below.

  #align(center)[
    #image("figures/nfgs_nash/nash_plots.svg", width: 100.0%)
  ]  


  The background of the plots highlights the angle of displacement induced by the Nash improvement function, according to the gradient wheel shown below here.

  #wrapped-figure(side: right, text-width: 68%)[
    \[If the color scheme seems arbitrary, as a small spoiler it will play a fundamental role in the proof of the _computational complexity_ of Nash equilibria, which we will discuss later on in this course. In particular, the three regions of the coloring scheme will be key in defining an important _combinatorial_ construction called #lecture-link("brouwer", <sec-sperner>)[_Sperner coloring_].\]
  ][
    #image("figures/nfgs_nash/color_wheel.svg", width: 82.527pt)
  ]
]

== Quantifying the increase in utility of the improvement step <sec-nash-improvement-gain>

We validate our intuition that the Nash improvement function is a “profitable response” function. The following result shows that if a player has positive regret for any action, then the Nash improvement function unilaterally increases that player's utility. This is a key property that will allow us to show that the fixed points of the Nash improvement functions must be Nash equilibria.

#theorem[
  For any strategy profile $(vx_1 \, ... \, vx_n)$, and any player $i in \[ n \]$, the Nash improvement function $phi$ satisfies

  $
    u_i (phi_i (vx_1 \, ... \, vx_n) \, vx_(- i)) - u_i (vx_1 \, ... \, vx_n) = frac(sum_(a_i in A_i) ([r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+))^2, 1 + sum_(a_i in A_i) [r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+)) .
  $

  So, if even one action of a player $i$ has positive regret, then the Nash improvement function unilaterally _strictly_ increases the utility of that player.
] <thm-nash-improvement>

#proof[
  Since we are focusing on a generic player $i$ and keeping all the other ones fixed (and playing strategies $vx_(- i)$), we will reduce the notational burden by using the following shorthands:

  $
    r_(i \, a_i) & := r_(i \, a_i) (vx_1 \, ... \, vx_n) \, & upright("(regret of action ") a_i upright(" fixing ") vx_(- i) \)\
    u_(i \, a_i) & := u_i (a_i \, vx_(- i)) \, & upright("(utility of action ") a_i upright(" fixing ") vx_(- i) \)\
    x'_(i \, a_i) & := phi_(i \, a_i) (vx_1 \, ... \, vx_n) = frac(x_(i \, a_i) + r_(i \, a_i)^(+), 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+)) quad & (upright("prob. of ") a_i upright(" in improved strat.")) \,
  $

  where the notation $z^(+)$ is a shorthand for the positive part of $z$, that is, $z^(+) := \[ z \]^(+) := max {0 \, z}$.

  The increase in utility is then computed as

  $
    & sum_(a_i in A_i) u_(i \, a_i) dot.op (x'_(i \, a_i) - x_(i \, a_i))\
    & = sum_(a_i in A_i) u_(i \, a_i) dot.op (frac(x_(i \, a_i) + r_(i \, a_i)^(+), 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+)) - x_(i \, a_i))\
    & = sum_(a_i in A_i) u_(i \, a_i) dot.op frac(r_(i \, a_i)^(+) - sum_(a'_i in A_i) r_(i \, a'_i)^(+) dot.op x_(i \, a_i), 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+))\
    & = frac(1, 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+)) (sum_(a_i in A_i) r_(i \, a_i)^(+) dot.op u_(i \, a_i) - sum_(a'_i in A_i) (r_(i \, a'_i)^(+) sum_(a_i in A_i) x_(i \, a_i) dot.op u_(i \, a_i)))\
    & = frac(1, 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+)) (sum_(a_i in A_i) r_(i \, a_i)^(+) dot.op (u_(i \, a_i) - sum_(a'_i in A_i) u_(i \, a'_i) dot.op x_(i \, a'_i)))\
    & = frac(1, 1 + sum_(a'_i in A_i) r_(i \, a'_i)^(+)) (sum_(a_i in A_i) r_(i \, a_i)^(+) dot.op r_(i \, a_i)) .
  $

  Using the fact that $z^(+) dot.op z = (z^(+))^2$ for all $z in bb(R)$, we obtain the statement.
]

At this point, the following is a simple corollary.

#theorem[
  A strategy profile $(vx_1 \, ... \, vx_n)$ is a Nash equilibrium if and only if it is a fixed point of the Nash improvement function $phi$.
] <thm-nash-fixed-points>

#proof[
  ($==>$) If $(vx_1 \, ... \, vx_n)$ is a Nash equilibrium, then by definition for all $i in \[ n \]$ and $a_i in A_i$, we have $r_(i \, a_i) (vx_1 \, ... \, vx_n) <= 0$. Hence, for all $i in \[ n \]$ and $a_i in A_i$, we have

  $
    phi_(i \, a_i) (vx_1 \, ... \, vx_n) = frac(x_(i \, a_i) + [r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+), 1 + sum_(a'_i in A_i) [r_(i \, a'_i) (vx_1 \, ... \, vx_n)]^(+)) = x_(i \, a_i) \,
  $

  that is, $(vx_1 \, ... \, vx_n)$ is a fixed point of $phi$.

  ($<==$) Conversely, suppose that $(vx_1 \, ... \, vx_n)$ is a fixed point of $phi$. Then, for all $i in \[ n \]$, from @thm-nash-improvement we have

  $
    frac(sum_(a_i in A_i) ([r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+))^2, 1 + sum_(a_i in A_i) [r_(i \, a_i) (vx_1 \, ... \, vx_n)]^(+)) = u_i (phi_i (vx_1 \, ... \, vx_n) \, vx_(- i)) - u_i (vx_1 \, ... \, vx_n) = 0 .
  $

  Hence, it must be $r_(i \, a_i) (vx_1 \, ... \, vx_n) <= 0$ for all $i in \[ n \]$ and $a_i in A_i$ (or the left-hand side would be strictly positive), and therefore $(vx_1 \, ... \, vx_n)$ is a Nash equilibrium.
]

By invoking #lecture-link("brouwer", <sec-brouwer-general>)[Brouwer's fixed-point theorem], we recover the central result of this lecture: Nash equilibria always exist.

#corollary[
  Since $phi$ is continuous and maps the nonempty compact convex set $Delta (A_1) times dots.h.c times Delta (A_n)$ into itself, by Brouwer's fixed point theorem, it has a fixed point. By @thm-nash-fixed-points, this implies that every game has (at least) one Nash equilibrium in mixed strategies.
] <cor-nash-existence>


= Suggested Examples <sec-examples>


=== Iterated removal of dominated strategies

True dominant strategies are rare in that most games do not have an action that is best against _everything_. A weaker but far more common situation is that an action is _never_ a good idea because there is always another action that does better. A rational player will never play such an action, so we can delete it from the game (i.e. remove its row or column from the payoff matrix). Deleting it can in turn make other actions removable: an action that was a sensible reply to the deleted action may become dominated in the smaller game that remains.

#definition[
  Let $a_i, a'_i$ be two actions of Player $i$. We say that $a_i$ is _strictly dominated_ by $a'_i$ if
  $ u_i (a'_i, a_(-i)) > u_i (a_i, a_(-i)) quad "for every" a_(-i), $
  and that $a_i$ is _weakly dominated_ by $a'_i$ if
  $ u_i (a'_i, a_(-i)) >= u_i (a_i, a_(-i)) quad "for every" a_(-i), $
  with strict inequality for at least one $a_(-i)$.
]

_Iterated removal of strictly dominated strategies_ repeatedly deletes strictly dominated actions of players, and considers the smaller game that remains, until no action of any player is strictly dominated. Since a rational player would never play a strictly dominated action, and we assume rationality within each player, only the surviving actions are candidates for rational play.

#example[
  Consider the following game, where Player 1 picks a row and Player 2 picks a column.

  #align(center, table(
    columns: 4,
    [], [L], [C], [R],
    [T], [$4, 3$], [$5, 1$], [$6, 2$],
    [M], [$2, 1$], [$8, 4$], [$3, 6$],
    [B], [$3, 0$], [$9, 6$], [$2, 8$],
  ))

  Neither player has a dominant strategy, and initially no row is dominated. However, column C is strictly dominated by column R for Player 2 ($2 > 1$, $6 > 4$, $8 > 6$). Once C is removed, row T strictly dominates both M ($4 > 2$, $6 > 3$) and B ($4 > 3$, $6 > 2$). With only row T left, Player 2 compares $3$ against $2$ and removes R. The unique surviving profile is (T, L), with payoffs $(4, 3)$.
]

#exercise[
  In the example above, we removed actions in one particular order. This raises a natural question: _does the order matter?_ Let's explore this through two games, one using strict domination and one using weak domination.

  + Consider iterated removal of *strictly dominated strategies* in the following game.

    #align(center, table(
      columns: 4,
      [], [L], [C], [R],
      [T], [$4, 4$], [$4, 3$], [$1, 1$],
      [M], [$3, 4$], [$3, 3$], [$5, 0$],
      [B], [$2, 1$], [$2, 5$], [$0, 0$],
    ))

    + Which actions are strictly dominated at the start? Explain why M and C are _not_ strictly dominated yet.
    + Carry out the removal process starting by removing B, and separately starting by removing R. Write down the game that remains after each step. Do the two orders pass through the same intermediate games? Where do they end up?
    + Suppose you remove R and then M, so that Player 1 has only T and B left. Why is C still not dominated at this point, and what finally makes it dominated?

  + Now consider iterated removal of *weakly dominated strategies* in the following game.
  #align(center, table(
      columns: 3,
      [], [L], [R],
      [T], [$1, 1$], [$0, 0$],
      [M], [$1, 1$], [$2, 1$],
      [B], [$0, 0$], [$2, 1$],
    ))

    + Show that both T and B are weakly dominated for Player 1, and that initially neither of Player 2's actions is weakly dominated.
    + Carry out the removal process in two orders: (i) remove T, then L and (ii) remove B, then R. What survives in each case, and what payoffs do the players get? _(Bonus: which other removal orders are possible, and where do they end?)_
    + Find all pure-strategy Nash equilibria of the game. Which of them survive each removal order? What does this suggest about using weak domination to predict play?
    + In part 1, once an action was strictly dominated, removing opponent actions could never "rescue" it. In this game, what happens to the comparison between M and T once R is removed? Why can't this happen with strict domination?
]

#solution[
  + *Strict Domination Problems*
    + For Player 1, B is strictly dominated by T, since $4 > 2$, $4 > 2$, and $1 > 0$. For Player 2, R is strictly dominated by L, since $4 > 1$, $4 > 0$, and $1 > 0$. No other action is strictly dominated at the start:
      - M is not dominated by T, because against R it gives Player 1 $5 > 1$. It is not dominated by B either, since $3 > 2$ against L.
      - C is not dominated by L, because against B it gives Player 2 $5 > 1$. It is not dominated by R either, since $3 > 1$ against T.
      - T and L are each the best reply to some action of the opponent (T against L, and L against T), so they are not dominated.

    + Let's walk through both orders of removal, starting with the order that removes B first. 
    
      #underline[First order:] remove B first. With B gone, Player 1 is left with T and M, so the remaining game is ${"T", "M"} times {"L", "C", "R"}$. Now L strictly dominates C for Player 2, since $4 > 3$ in both remaining rows. Removing C leaves ${"T", "M"} times {"L", "R"}$. L still strictly dominates R ($4 > 1$, $4 > 0$), and removing R leaves ${"T", "M"} times {"L"}$. Finally, T strictly dominates M ($4 > 3$), leaving ${"T"} times {"L"}$.

      #underline[Second order:] remove R first. With R gone, the remaining game is ${"T", "M", "B"} times {"L", "C"}$. Now T strictly dominates M ($4 > 3$, $4 > 3$), and it also dominates B. Removing M leaves ${"T", "B"} times {"L", "C"}$. C is still not dominated, so we remove B next, leaving ${"T"} times {"L", "C"}$. Finally, L strictly dominates C ($4 > 3$), leaving ${"T"} times {"L"}$.

      The two orders pass through different intermediate games. For example, ${"T", "B"} times {"L", "C"}$ appears only in the second. Other choices at each step are also possible, such as removing R before C in the first order. However, every order ends at the same profile, (T, L), with payoffs $(4, 4)$. This is also the unique pure-strategy Nash equilibrium of the game.

    + With Player 1 restricted to T and B, Player 2 compares L and C row by row. Against T, L is better ($4 > 3$), but against B, C is better ($5 > 1$). So C is still a sensible reply as long as Player 1 might play B. Once B is removed (since T strictly dominates it since $4 > 2$ against both L and C), the only remaining row is T, where L beats C. This leaves C to become strictly dominated.

  + *Weak Domination Problems*
    + M weakly dominates T for Player 1: against L they tie ($1 >= 1$), and against R, M is strictly better ($2 > 0$). M also weakly dominates B: against L, M is strictly better ($1 > 0$), and against R they tie ($2 >= 2$).

      For Player 2, L is better than R in row T ($1 > 0$), R is better than L in row B ($1 > 0$), and they tie in row M. This means neither of Player 2's actions weakly dominates the other.

    + Let's start with the order of T, then L. After removing T, Player 1 has M and B. Player 2's action R now weakly dominates L mearning they tie in row M ($1 >= 1$), and R is strictly better in row B ($1 > 0$). Removing L leaves ${"M", "B"} times {"R"}$. Here M and B both give Player 1 a payoff of 2, so neither dominates the other and the process stops. The players get payoffs $(2, 1)$.

      Now, let's do the order of B, then R. After removing B, Player 1 has T and M. Player 2's action L now weakly dominates R: L is strictly better in row T ($1 > 0$), and they tie in row M ($1 >= 1$). Removing R leaves ${"T", "M"} times {"L"}$. Here T and M both give Player 1 a payoff of 1, so the process stops. The players get payoffs $(1, 1)$.

      So the surviving games are different, and Player 1's payoff is 2 in one order and 1 in the other.

      For the bonus question, the only other possibility is to remove both T and B before any of Player 2's actions, in either order. This leaves ${"M"} times {"L", "R"}$, where Player 2 is indifferent ($1$ either way), so nothing more is removed. The players get $(1, 1)$ or $(2, 1)$, depending on Player 2's choice. In total, the process can end at three different games.

    + Checking each profile,
      - (T, L) is a Nash equilibrium: Player 1 cannot gain by deviating (M gives 1 and B gives 0), and neither can Player 2 (R gives 0).
      - (T, R) is not: Player 1 would switch to M (payoff 2 instead of 0).
      - (M, L) is a Nash equilibrium: Player 1's alternatives give 1 and 0, and Player 2 is indifferent between L and R.
      - (M, R) is a Nash equilibrium: T gives Player 1 only 0 and B gives the same 2, and Player 2 is indifferent.
      - (B, L) is not: Player 1 would switch to T or M (payoff 1 instead of 0).
      - (B, R) is a Nash equilibrium: Player 1's alternatives give 0 and 2, and Player 2's alternative L gives 0.

      So the pure-strategy Nash equilibria are (T, L), (M, L), (M, R), and (B, R). Order (i) keeps only (M, R) and (B, R), order (ii) keeps only (T, L) and (M, L), and the bonus order keeps (M, L) and (M, R).

      Each order removes some Nash equilibria, and different orders remove different ones. This suggests that iterated weak domination is not a reliable way to predict play: its prediction depends on an arbitrary choice of order, and it can rule out outcomes that are perfectly stable.

    + Against L alone, M and T both give Player 1 a payoff of 1. The strict inequality in "M weakly dominates T" came only from column R. Once R is removed, all that is left is a tie, so M no longer weakly dominates T, and T survives the second order (B then R).

      This cannot happen with strict domination, because strict domination requires a strict inequality against _every_ opponent action. Removing some opponent actions just removes some of these inequalities, and the remaining ones are still strict. With weak domination, it's possible that the removed action may be the only place where the inequality was strict, and a tie on the rest does not count as domination.
]


= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
