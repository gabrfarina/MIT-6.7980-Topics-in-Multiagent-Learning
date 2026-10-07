#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions
#show: gabri_notes.with(
  lec_num: 1,
  date: [Tue, Sep 15, 2026],
  title: "Setting and equilibria: the Nash equilibrium",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

Normal-form games model simultaneous-move interactions with a single move (think about rock-paper-scissors). Despite their simplicity, normal-form games will provide a natural ground for looking into important concepts in multiagent settings, such as notions of equilibria (Nash, maxmin, correlated, $...$), and learning from repeated play. In the second part of the course, we will move on to notions of games that explicitly capture more complex phenomena, such as sequential moves and imperfect information.

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

*Strategies*  A _randomized strategy_ (also known as _mixed strategy_) for a generic player $i in \[ n \]$ is a distribution over the set of actions. We can represent such an object as a vector $vx_i in Delta (A_i)$, that is, such that $vx_i >= 0$ and $sum_(a_i in A_i) x_(i \, a_i) = 1$. To lighten the notational burden, we will write the expected utility when all players play according to strategies $vx_1 \, ... \, vx_n$ reusing the same letter $u_i$ as the payoff, _i.e._,

$
  u_i (vx_1 \, ... \, vx_n) & := bb(E)_(a_1 ~ vx_1\
  ...\
  a_n ~ vx_n) [u_i (a_1 \, ... \, a_n)]\
  & = sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) x_(1 \, a_1) dots.h.c x_(n \, a_n) dot.op u_i (a_1 \, ... \, a_n) .
$

We will sometimes intersperse deterministic actions and mixed strategies freely and write expressions such as $u_i (a_1 \, vx_2 \, ... \, vx_n)$ to mean the expected utility when player 1 plays action $a_1$ and the other players play according to the strategies $vx_2 \, ... \, vx_n$.

== Dominant-strategy equilibrium

The question of what constitutes rational play for players can get complicated depending on the game. But, in some lucky cases, like the prisoner's dilemma game above, it turns out that some actions are just _better_ than others, _no matter what the other players do_. In such cases, we say that a player has a _dominant strategy_. In the case above, both Player 1 and Player 2 have a dominant strategy to confess$.$ In this case, we expect that the players will play their dominant strategy, and this is called a _dominant-strategy equilibrium_.

== Maxmin strategies

The benefit of dominant-strategy equilibria is that they require no counterspeculation: some strategies just are better no matter what anyone else does. However, in many games, no player has a dominant strategy. Consider, for example, rock-paper-scissor: all actions are symmetric, and no action is strictly better than the others. How can we find a good strategy for that?

One way to think about this is to consider the worst-case scenario: what is the best strategy for a player if they assume the other players are trying to minimize their payoff? This is the idea behind _maxmin strategies_. A maxmin strategy for Player $i$ is a strategy $vx_i$ that maximizes the minimum payoff that Player $i$ can get, that is,

$
  vx_i in "arg max"_(vx_i in Delta (A_i)) min_(vx_j in Delta (A_j)\
  upright("for all") j != i) u_i (vx_i \, vx_(- i)) \,
$

where the notation $vx_(- i)$ is popular syntactic sugar to denote the tuple $(vx_j)_(j != i)$.#footnote[This notation appears often in game theory, since we are often interested in studying the effect of changing a _single_ player $i$'s strategy, while keeping all “the other” strategies $vx_(- i)$ fixed.]  Thinking back about rock-paper-scissors, it is clear that the maxmin strategy is to play uniformly at random: the opponent could exploit any other strategy more than the uniform one, by playing the counteraction more often.

The above idea has some merits, especially in two-player zero-sum games, that is, those two-player games where $u_1 (a_1 \, a_2) + u_2 (a_1 \, a_2) = 0$ for all combinations of actions. In those games, players are in direct competition, so it makes sense to assume that the opponent is “out to get us.” But in more general games, the maxmin strategy can be too conservative, since it assumes that all other players have nothing better going on than to minimize our payoff, even if that hurts them.

== The Nash equilibrium <sec-nash-equilibrium>

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

It is clear that a dominant-strategy equilibrium is a special case of a Nash equilibrium, since in a dominant-strategy equilibrium, by definition,

#math.equation(
  block: true,
  numbering: (..nums) => "(Dominant-strategy eq.)",
  $forall i in \[ n \] \, vx'_i in Delta (A_i) \, vx'_(- i) in Delta (A_(- i)) \, \ u_i (vx'_i \, vx'_(- i)) <= u_i (vx_i \, vx'_(- i)) .$.body,
)

(note the stronger quantifiers.) As we will discuss more in depth shortly, in two-player zero-sum games, it turns out that Nash equilibrium and maxmin equilibrium are equivalent.

Before continuing, we consider two examples that help illustrate a couple of important properties of the Nash equilibrium.

#example[
  The only Nash equilibrium in the game of rock-paper-scissors is for all players to play the uniform strategy. This shows that in some games, no Nash equilibrium exists in pure (_i.e._, non-randomizing) strategies.
]

#example[Theater or football][
  Consider the following small game:

  #align(center)[
    #image("figures/nfgs_nash/theater_football.svg", width: 100.223pt)
  ]

  This game has two obvious Nash equilibria: Player 1 insisting and Player 2 accepting, or vice versa (top right and bottom left corners). However, there is a third equilibrium as well: both players accept with probability 1/6 and insist with probability 5/6.

  This is not a coincidence: in two-player nondegenerate games, there is always an _odd_ number of Nash equilibria. This fact comes from more profound connections with some combinatorial objects that we will uncover quite soon.
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
  The plots below visualize the displacement $phi (vx_1 \, vx_2) - (vx_1 \, vx_2)$ induced by the Nash improvement function for four games, whose payoff matrices are noted below each plot, after projecting away the probability of the first action of each player (and keeping around only the probability of the second action, which is sufficient to uniquely recover the strategy of the player since each player only has two actions). The black dots denote the fixed points of the Nash improvement function. These correspond exactly to the Nash equilibria of the game, as we make formal below.

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

= Equilibrium practice <sec-equilibrium-practice>

#exercise[Finding Equilibria in Small Games][
In each two-player game below, Player 1 chooses a row, either $U$ (up) or $D$ (down), and Player 2 chooses a column, either $L$ (left) or $R$ (right). Each entry lists the payoffs in the order $(u_1 \, u_2)$; larger payoffs are better.

Let $p$ be the probability that Player 1 chooses $U$, and let $q$ be the probability that Player 2 chooses $L$. Thus the strategy vectors are $vx_1=(p \, 1-p)$ and $vx_2=(q \, 1-q)$, where $0 <=  p \, q <= 1$. We describe a strategy profile by the pair $(p \, q)$.

A pure strategy is a special case of a mixed strategy. Here, a *non-pure equilibrium* means an equilibrium in which at least one player randomizes between both actions; a *fully mixed equilibrium* means that both players do so.

Use the lecture's dominance convention: a strategy is *dominant* if it is at least as good as every alternative strategy against every opponent strategy. For pure actions, call dominance *strict* if the payoff inequality is strict against every opponent action, and *weak* if it is never reversed and is strict against at least one opponent action. A dominant-strategy equilibrium requires both players to use dominant strategies.

For each game:

1. Identify any dominant strategies, state whether the pure-action comparisons are strict or weak, and find all dominant-strategy equilibria. If none exist, explain why.
2. Find all pure-strategy Nash equilibria by checking unilateral deviations.
3. Find all non-pure Nash equilibria, or prove that none exist. Derive the expected payoffs of each action and check both interior and boundary values of $p$ and $q$, so that your list is complete.

*Hint.* A player who assigns positive probability to both actions must be indifferent between them. If one action gives strictly higher expected payoff, a best response assigns probability one to that action. Indifference is only a necessary condition for a player who mixes: check the other player's best-response condition too.

*A common method.*

For a fixed opponent strategy, the expected payoff of a mixture is the probability-weighted average of its pure-action payoffs. Consequently, it is enough to compare pure actions: a mixture cannot outperform the better action. A player can mix between both actions only when their payoffs are equal.

We will write expressions such as $u_1 (U \, vx_2)$ for the payoff from playing $U$ against Player 2's mixture. The variables $p$ and $q$ always denote the probabilities specified above, not payoff values.

*Game A: Strict incentives*

#align(center)[
#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Player 1 / Player 2*], [*$L$*], [*$R$*]),

  [$U$], [$(3 \, 3)$], [$(0 \, 4)$],

  [$D$], [$(4 \, 0)$], [$(1 \, 1)$],

)
]

#reference-solutions(title: [Show / hide solution to Game A])[
#solution[Game A][
*Dominance.* Against $L$, Player 1 earns $4$ from $D$ and $3$ from $U$. Against $R$, Player 1 earns $1$ from $D$ and $0$ from $U$. Thus $D$ strictly dominates $U$.

Similarly, Player 2 earns $4>3$ by choosing $R$ rather than $L$ against $U$, and $1>0$ by choosing $R$ rather than $L$ against $D$. Thus $R$ strictly dominates $L$. The unique dominant-strategy equilibrium is $(D \, R)$, or $(p \, q)=(0 \, 0)$.

*All Nash equilibria.* Against an arbitrary $q$,

$
u_1 (U \, vx_2)=3q \,  quad quad
u_1 (D \, vx_2)=4q+(1-q)=1+3q.
$

The second payoff is larger by $1$ for every $q$. A mixture putting positive probability on $U$ therefore earns strictly less than playing $D$ alone. Every best response has $p=0$.

For Player 2,

$
u_2 (vx_1 \, L)=3p \,  quad quad
u_2 (vx_1 \, R)=4p+(1-p)=1+3p.
$

Every best response has $q=0$. The two conditions hold simultaneously only at $(p \, q)=(0 \, 0)$. At $(D \, R)$, either player's switch lowers its payoff from $1$ to $0$, so this profile is indeed a Nash equilibrium.

Therefore $(D \, R)$ is the unique pure Nash equilibrium, and there are no non-pure Nash equilibria. Strict dominance also excludes any other dominant mixed strategy.
]
]

*Game B: Coordination with different preferences*

#align(center)[
#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Player 1 / Player 2*], [*$L$*], [*$R$*]),

  [$U$], [$(3 \, 2)$], [$(0 \, 0)$],

  [$D$], [$(0 \, 0)$], [$(2 \, 3)$],

)
]

#reference-solutions(title: [Show / hide solution to Game B])[
#solution[Game B][
*Dominance.* Player 1 strictly prefers $U$ against $L$, but strictly prefers $D$ against $R$. Player 2 strictly prefers $L$ against $U$, but strictly prefers $R$ against $D$. Neither player has a dominant pure action.

There is also no dominant mixed strategy: to be optimal against $L$, Player 1 would have to choose $U$ with probability one, whereas optimality against $R$ requires choosing $D$ with probability one. The requirements are incompatible. The same argument applies to Player 2. Hence there is no dominant-strategy equilibrium.

*Pure Nash equilibria.* At $(U \, L)$, each player would drop to payoff $0$ by deviating. The same is true at $(D \, R)$. Thus both are Nash equilibria. At $(U \, R)$, Player 1 can switch to $D$ and improve from $0$ to $2$; at $(D \, L)$, Player 1 can switch to $U$ and improve from $0$ to $3$. There are no other pure equilibria.

*Mixed Nash equilibria.* Player 1's action payoffs are

$
u_1 (U \, vx_2)=3q \,  quad quad
u_1 (D \, vx_2)=2(1-q).
$

Player 1 is indifferent exactly when $3q=2(1-q)$, or $q=2/5$. It strictly prefers $U$ for $q>2/5$ and $D$ for $q<2/5$.

Player 2's action payoffs are

$
u_2 (vx_1 \, L)=2p \,  quad quad
u_2 (vx_1 \, R)=3(1-p).
$

Player 2 is indifferent exactly when $2p=3(1-p)$, or $p=3/5$. It strictly prefers $L$ for $p>3/5$ and $R$ for $p<3/5$.

Thus the fully mixed candidate is

$
(p \, q)=(frac(3, 5) \, frac(2, 5)) \,  quad quad
vx_1=(frac(3, 5) \, frac(2, 5)) \,  quad
vx_2=(frac(2, 5) \, frac(3, 5)).
$

At this profile, both actions give Player 1 payoff $6/5$, and both actions give Player 2 payoff $6/5$. Every unilateral mixture also gives that same player's payoff $6/5$, so neither player can improve. The candidate is a Nash equilibrium.

*Completeness.* If $q>2/5$, Player 1 must choose $p=1$, which forces Player 2's best response $q=1$. If $q<2/5$, Player 1 must choose $p=0$, which forces $q=0$. If $q=2/5$, Player 2 is mixing between both actions, so its best-response condition requires $p=3/5$. These cases cover the entire square $0 <=  p \, q <= 1$.

The complete equilibrium set is $(p \, q)=(1 \, 1)$, $(0 \, 0)$, and $(3/5 \, 2/5)$. In particular, there are no equilibria in which exactly one player mixes.
]
]

*Game C: Matching pennies*

#align(center)[
#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Player 1 / Player 2*], [*$L$*], [*$R$*]),

  [$U$], [$(1 \, -1)$], [$(-1 \, 1)$],

  [$D$], [$(-1 \, 1)$], [$(1 \, -1)$],

)
]

#reference-solutions(title: [Show / hide solution to Game C])[
#solution[Game C][
*Dominance and pure equilibria.* Player 1 prefers $U$ against $L$ and $D$ against $R$. Player 2 prefers $R$ against $U$ and $L$ against $D$. These conflicting strict best responses rule out dominant strategies, including dominant mixed strategies.

There is no pure Nash equilibrium. At $(U \, L)$ and $(D \, R)$, Player 2 can increase its payoff from $-1$ to $1$ by switching columns. At $(U \, R)$ and $(D \, L)$, Player 1 can increase its payoff from $-1$ to $1$ by switching rows.

*Mixed Nash equilibria.* The action payoffs are

$
u_1 (U \, vx_2)=2q-1 \,  quad quad
u_1 (D \, vx_2)=1-2q \,
$

and

$
u_2 (vx_1 \, L)=1-2p \,  quad quad
u_2 (vx_1 \, R)=2p-1.
$

Player 1 is indifferent exactly when $q=1/2$, and Player 2 is indifferent exactly when $p=1/2$. At $(p \, q)=(1/2 \, 1/2)$, every action gives payoff $0$ to its player. All unilateral mixtures also give payoff $0$, so this profile is a Nash equilibrium.

*Completeness.* If $q>1/2$, Player 1 strictly prefers $U$, so $p=1$; Player 2 then strictly prefers $R$, giving $q=0$, a contradiction. If $q<1/2$, Player 1 strictly prefers $D$, so $p=0$; Player 2 then strictly prefers $L$, giving $q=1$, again a contradiction. Therefore $q=1/2$ in every equilibrium. Since Player 2 then mixes, its indifference condition requires $p=1/2$.

Thus $(1/2 \, 1/2)$ is the unique Nash equilibrium. It is fully mixed, and there is no dominant-strategy equilibrium.
]
]

*Game D: Ties and boundary equilibria (additional challenge)*

#align(center)[
#table(
  columns: (auto, auto, auto),
  align: center,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Player 1 / Player 2*], [*$L$*], [*$R$*]),

  [$U$], [$(1 \, 1)$], [$(1 \, 0)$],

  [$D$], [$(1 \, 0)$], [$(0 \, 0)$],

)
]

For Game D, also explain why a Nash equilibrium need not be a dominant-strategy equilibrium, even when both players have dominant actions.

#reference-solutions(title: [Show / hide solution to Game D])[
#solution[Game D][
*Dominance.* For Player 1, $U$ and $D$ both give payoff $1$ against $L$, while $U$ gives $1>0$ against $R$. Thus $U$ weakly dominates $D$, but does not strictly dominate it.

For Player 2, $L$ gives $1>0$ against $U$, while both columns give $0$ against $D$. Thus $L$ weakly dominates $R$, but does not strictly dominate it. The profile $(U \, L)$ is a dominant-strategy equilibrium under the stated convention.

It is the only such equilibrium. A row mixture with $p<1$ gives payoff $p<1$ against $R$, so it is not dominant. A column mixture with $q<1$ gives payoff $q<1$ against $U$, so it is not dominant either. There is no equilibrium in strictly dominant actions.

*All Nash equilibria.* The expected action payoffs are

$
u_1 (U \, vx_2)=1 \,  quad quad
u_1 (D \, vx_2)=q \,
$

and

$
u_2 (vx_1 \, L)=p \,  quad quad
u_2 (vx_1 \, R)=0.
$

If $q<1$, Player 1 strictly prefers $U$, so any equilibrium would have $p=1$. But then Player 2 strictly prefers $L$, forcing $q=1$, a contradiction. Thus every equilibrium must have $q=1$.

When $q=1$, Player 1's two actions both give payoff $1$, so every $p in [0 \, 1]$ is a best response. Player 2's choice $L$ is also a best response: it gives payoff $p >= 0$, whereas $R$ gives $0$. Consequently, the complete equilibrium set is

$
{(p \, q):0 <=  p <= 1 \,  thin q=1}.
$

The pure equilibria are $(U \, L)$ and $(D \, L)$, corresponding to $p=1$ and $p=0$. For every $0<p<1$, there is a non-pure equilibrium in which Player 1 mixes and Player 2 chooses $L$ with probability one. There are no fully mixed equilibria.

*Why Nash does not imply dominance.* At $(D \, L)$, Player 1 is best responding to the actual opponent action $L$, because $U$ would give the same payoff. But $D$ is not dominant: against $R$, switching to $U$ would improve Player 1's payoff. Nash equilibrium requires optimality against the opponent's chosen strategy; dominance requires optimality against every opponent strategy. This also shows why a weakly dominated action can still be played in a Nash equilibrium.
]
]

#reference-solutions(title: [Show / hide answer summary])[
#block(breakable: false)[
*Answer summary*

Here $(p \, q)$ records the probabilities of $U$ and $L$, respectively. Dominant-strategy equilibria use the non-strict convention stated in the exercise.

#align(center)[
#table(
  columns: (auto, 1fr, 1fr, 1fr),
  align: left,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Game*], [*Pure Nash equilibria*], [*Non-pure Nash equilibria*], [*Dominant-strategy equilibria*]),

  [A], [$(D \, R)$], [None], [$(D \, R)$; both actions strictly dominant],

  [B], [$(U \, L)$, $(D \, R)$], [$(p \, q)=(3/5 \, 2/5)$], [None],

  [C], [None], [$(p \, q)=(1/2 \, 1/2)$], [None],

  [D], [$(U \, L)$, $(D \, L)$], [$(p \, 1)$ for $0<p<1$], [$(U \, L)$; both actions weakly dominant],

)
]
]
]

] <ex-small-game-equilibria>

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
