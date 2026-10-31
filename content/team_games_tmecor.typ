#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

// L12, part 2 (correlation and imperfect recall, slides 6-7) and part 3 (realization form, slide 8).
// Parts 1 and 4 (the game, the TME, and hardness) are in a separate contribution.

// Figure L12.1 is shared with part 1 of the lecture. It is included here so this file compiles on its own.
#figure(
  image("figures/team/communication_game.svg", width: 85%),
  caption: [The communication game. Team ▲ is Players 1 and 2, and Player 3 (▼) is the adversary. Edge labels are behavioral probabilities, with $overline(x) := 1 - x$. Leaves show the team's payoff and their index $z_1, dots, z_12$. Chance draws a uniform bit that only Player 1 sees. Players 2 and 3 observe Player 1's action and then each guess the bit. Team ▲ gets 1 if Player 2 guesses right and Player 3 guesses wrong, and 0 otherwise.],
) <fig-team-communication-game>

= Correlation and imperfect recall <sec-team-correlation>

Earlier in this lecture we saw that the TME of the communication game has value $1\/4$, while swapping max and min gives $1\/2$. The minimax theorem assumes convex compact strategy sets and a utility that is linear in each side's strategy when the other side's strategy is fixed. The team's utility contains products such as $a dot c$ of the two teammates' variables, so the second assumption fails and the maxmin problem is nonconvex.

For most of this lecture we let the teammates correlate. Before the game starts they may discuss strategy and flip coins that only they see, but they cannot communicate during play. Formally, the team chooses a distribution $vmu$ over its _joint_ pure plans, and the adversary chooses a mixed strategy $vy$ as usual.

#definition[Team maxmin equilibrium with correlation #citep(<Celli18:Computational>, <Farina18:Ex>)][
  A _team maxmin equilibrium with correlation (TMECor)_ is a distribution $vmu$ over joint plans $(pi_1, pi_2) in Pi_1 times Pi_2$ that solves
  $
    max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in Delta(Pi_3)) EE_((pi_1, pi_2) ~ vmu) u(pi_1, pi_2, vy).
  $
] <def-team-tmecor>

// Not from the lecture (Celli-Gatti 2018, Farina et al. 2018): the comparison with the CE device.
The distribution $vmu$ in @def-team-tmecor plays the role of the correlation device of #lecture-link("correlated", <sec-ce>)[correlated equilibrium], restricted to the team. It samples a joint plan before play. Each teammate may see all of it, as long as the adversary does not. Incentive constraints are also unnecessary, since teammates share a utility function.

== The one-time pad <sec-team-one-time-pad>

Readers familiar with cryptography will recognize the team's optimal strategy as a _one-time pad_. Before play, Players 1 and 2 flip a shared fair coin. On heads, Player 1 sends the bit as it is, and on tails it sends the flipped bit. Player 2 knows the coin, so it undoes the flip and always guesses correctly. Player 3 does not know the coin, so to Player 3 the message carries no information about the bit. In the coordinates $(a, b; c, d)$ of @fig-team-communication-game,
$
  vmu^star := 1/2 delta_((1, 0; 1, 0)) + 1/2 delta_((0, 1; 0, 1)).
$
The two joint plans are the heads and tails branches, and the shared coin picks between them.

Under $vmu^star$, Player 2 always guesses right, and the message is uniform and independent of the bit. So Player 3 is right with probability $1\/2$ whatever it does, and the team gets $1\/2$ against every $vy$. Conversely, the team scores only when Player 3 guesses wrong. If Player 3 guesses uniformly at random, it is wrong with probability $1\/2$, so no team strategy gets more than $1\/2$. Hence the TMECor value is $1\/2$. This is twice the TME value of $1\/4$, and it equals the min-max value computed earlier. Correlation closes the gap between the maxmin and min-max values.

== Correlation restores the minimax theorem <sec-team-minimax>

With correlation, the team acts as a single player whose pure strategies are the joint plans $Pi_1 times Pi_2$ and whose mixed strategies are the distributions $vmu$. The TMECor problem is then nothing but a large two-player zero-sum normal-form game between this player and the adversary. Its objective is bilinear in $(vmu, vy)$, so the #lecture-link("learning_intro", <sec-learning-minimax>)[minimax theorem] holds and the maxmin value equals the min-max value (@tab-team-minimax).

#figure(
  supplement: [Table],
  caption: [TME versus TMECor in the communication game.],
  table(
    stroke: none,
    columns: 5,
    align: center + horizon,
    inset: .6em,
    table.header([], [*Team strategies*], [*Value*], [*Optimization problem*], [*Minimax theorem*]),
    table.hline(stroke: .5pt),
    [TME], [$Delta(Pi_1) times Delta(Pi_2)$], [$1\/4$], [nonconvex], [fails],
    [TMECor], [$Delta(Pi_1 times Pi_2)$], [$1\/2$], [convex (bilinear saddle point)], [holds],
  ),
) <tab-team-minimax>

== Team games as imperfect-recall games <sec-team-imperfect-recall>

Equivalently, we can think of the two teammates as one player that happens to forget. In the communication game, this player observes the bit, sends a message, then forgets the bit and continues in the role of Player 2 (@fig-team-imperfect-recall). A team game is thus a two-player zero-sum game in which each team becomes a single player, who in general has imperfect recall #citep(<Farina18:Ex>, <Zhang23:Team>). Strictly, the equivalence is with _timeable_ imperfect-recall games, in which the tree can be drawn so that every information set is horizontal, that is, every player always knows what time it is. We return to timeability later in the lecture. @tab-team-dictionary translates between the two views.

#figure(
  image("figures/team/imperfect_recall_game.svg", width: 60%),
  caption: [The communication game as a two-player zero-sum game. The team is a single player (1) that observes the bit, sends a message, and then forgets the bit. Each of its second-level information sets contains nodes with different histories, so it has imperfect recall.],
) <fig-team-imperfect-recall>

#figure(
  supplement: [Table],
  caption: [Team games and two-player zero-sum games of imperfect recall.],
  table(
    stroke: none,
    columns: 3,
    align: left + horizon,
    inset: (x: .45em, y: .6em),
    table.header([*Team game*], [*Imperfect-recall game*], [*Communication game*]),
    table.hline(stroke: .5pt),
    [team], [player], [Players 1 and 2],
    [team strategy], [strategy for the player], [$(a, b; c, d)$ or $vmu$],
    [uncorrelated team strategy], [behavioral strategy], [$(a, b; c, d) in [0, 1]^4$],
    [correlated team strategy], [mixed strategy], [$vmu in Delta(Pi_1 times Pi_2)$],
    [TME], [optimal behavioral strategy], [$a = b = c = d = 1\/2$],
    [TMECor], [mixed Nash equilibrium], [$vmu^star$],
  ),
) <tab-team-dictionary>

By the minimax theorem, a maxmin strategy of the team is exactly the team's part of a mixed Nash equilibrium of this two-player game. So most of this lecture can be read as computing mixed Nash equilibria of two-player zero-sum games of imperfect recall. Behavioral and mixed strategies must be distinguished because #lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem], which makes them realization-equivalent, requires perfect recall, and the team player does not have it. A behavioral strategy randomizes independently at each information set, so it cannot make Player 2's guess depend on the coin that chose Player 1's message. The one-time pad $vmu^star$ is therefore a mixed strategy of the team player that no behavioral strategy realizes (@ex-team-pad-not-uncorrelated).

The question for the rest of the lecture is when a TMECor can be computed efficiently.

= Realization form <sec-team-realization-form>

By @sec-team-minimax, a TMECor is a maxmin strategy of a two-player zero-sum game, so we would like to use the tools we already have for such games. The obstacle is size. The distribution $vmu$ has one coordinate per joint plan, and the number of joint plans is exponential in the size of the game tree. As with the sequence form, we record only what affects the payoff, namely which terminal nodes the team plays toward.

#definition[Team realization vectors #citep(<Farina18:Ex>, <Zhang23:Team>)][
  Let $Z$ be the set of terminal nodes. The _realization vector_ of a joint plan $(pi_1, pi_2) in Pi_1 times Pi_2$ is the vector $vx^(pi_1, pi_2) in {0, 1}^Z$ with $x^(pi_1, pi_2)[z] = 1$ if and only if team ▲ plays all of its actions on the path from the root to $z$. The _realization polytope_ of the team is the convex hull of these vectors,
  $
    cX := conv(V), quad "where" quad V := {vx^(pi_1, pi_2) : (pi_1, pi_2) in Pi_1 times Pi_2} subset.eq {0, 1}^Z.
  $
] <def-team-realization>

The polytope $cY$ of team ▼ is defined in the same way. In @def-team-tmecor, team ▼ is Player 3 alone. From now on $vy$ denotes a point of $cY$ rather than a mixed strategy of team ▼. Different joint plans can have the same realization vector. In the communication game the 16 joint plans give only 12 vectors, because if Player 1 always sends the same message, Player 2's action after the other message is never used.

The _realization vector_ of a distribution $vmu in Delta(Pi_1 times Pi_2)$ is $vx^vmu := EE_((pi_1, pi_2) ~ vmu) vx^(pi_1, pi_2)$. Its entry $x^vmu [z]$ is the probability that the team plays all of its actions on the path to $z$. The map $vmu |-> vx^vmu$ is linear and sends the point mass on $(pi_1, pi_2)$ to $vx^(pi_1, pi_2)$. Since $Delta(Pi_1 times Pi_2)$ is the convex hull of the point masses, its image is exactly $conv(V) = cX$. In other words, $cX$ is the set of realization vectors of correlated team strategies. In the same way, $cY$ is the set of realization vectors of the mixed strategies of team ▼.

#example[Realization vectors in the communication game][
  Number the leaves as in @fig-team-communication-game. If both teammates always play left ($a = b = c = d = 1$), the team plays all of its actions on the paths to $z_1$, $z_2$, and $z_4$ only, so its realization vector is $(1, 1, 0 #h(.4em) bar.v #h(.4em) 1, 0, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0)$. It has 12 entries, one per terminal node, instead of one per joint plan. Bars separate the three leaves below each Player 2 node. For a general uncorrelated team strategy in behavioral coordinates, and for Player 3,
  $
    vx(a, b; c, d) & = (a c, a c, a overline(c) #h(.4em) bar.v #h(.4em) b c, b overline(c), b overline(c) #h(.4em) bar.v #h(.4em) overline(a) d, overline(a) d, overline(a) overline(d) #h(.4em) bar.v #h(.4em) overline(b) d, overline(b) overline(d), overline(b) overline(d)), \
    vy & = (e, overline(e), 1 #h(.4em) bar.v #h(.4em) 1, e, overline(e) #h(.4em) bar.v #h(.4em) f, overline(f), 1 #h(.4em) bar.v #h(.4em) 1, f, overline(f)).
  $
  Entries repeat in pairs ($a c, a c$) where two leaves differ only in Player 3's action. Each entry of $vx(a, b; c, d)$ is a product of one probability from each teammate, the same products that made the TME problem nonconvex.
] <ex-team-realization>

== TMECor as a bilinear saddle-point problem <sec-team-bspp>

The realization vectors record only the teams' actions, so the chance probabilities go into the payoff matrix. Let $p_"chance" (z)$ be the product of the chance probabilities on the path to $z$, and define the diagonal matrix
$
  U := diag((p_"chance" (z) dot u(z))_(z in Z)).
$

#lemma[Utility in realization form][
  If team ▲ plays $vmu$ and team ▼ plays a mixed strategy with realization vector $vy$, the expected utility of team ▲ is $(vx^vmu)^top U vy$.
] <lem-team-utility>
#proof[
  Fix a pure plan for each team, with realization vectors $vx$ and $vy$. A terminal node $z$ is reached if and only if chance, team ▲, and team ▼ each take their own actions on the path to $z$, and these three sets of edges are disjoint. So
  $
    Pr[z "is reached"] & = p_"chance" (z) dot x[z] dot y[z], \
    EE[u] & = sum_(z in Z) p_"chance" (z) dot u(z) dot x[z] dot y[z] = vx^top U vy.
  $
  Both sides are linear in each team's distribution over pure plans, and the two distributions are independent, so the identity extends to $vmu$ and to mixed strategies of team ▼.
]

#theorem[TMECor as a saddle-point problem #citep(<Farina18:Ex>, <Zhang23:Team>)][
  The TMECor value equals
  $
    max_(vx in cX) min_(vy in cY) vx^top U vy.
  $
  A distribution $vmu$ is a TMECor if and only if $vx^vmu$ is a maxmin solution of this problem, and every maxmin solution is $vx^vmu$ for some TMECor $vmu$.
] <thm-team-bspp>
#proof[
  By @lem-team-utility, the objective of @def-team-tmecor at $vmu$ equals $min_(vy in cY) (vx^vmu)^top U vy$, since the minimum over mixed strategies of team ▼ equals the minimum over their realization vectors $cY$. As $vmu$ ranges over $Delta(Pi_1 times Pi_2)$, $vx^vmu$ ranges over all of $cX$, so
  $
    max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in Delta(Pi_3)) EE_((pi_1, pi_2) ~ vmu) u(pi_1, pi_2, vy)
    & = max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in cY) (vx^vmu)^top U vy \
    & = max_(vx in cX) min_(vy in cY) vx^top U vy.
  $
  The objective depends on $vmu$ only through $vx^vmu$. So the two maxima are equal, and $vmu$ attains the maximum if and only if $vx^vmu$ does.
]

This #lecture-link("learning_intro", <sec-learning-zero-sum>)[saddle-point problem] adapts the sequence form to teams. When a team is a single player with perfect recall, the entry $x[z]$ is the sequence-form entry of the player's last sequence on the path to $z$ (the empty sequence if the player does not act on that path). So $cX$ is a linear image of the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytope], and the problem above is the usual sequence-form maxmin problem up to a linear change of variables. For Player 3 in @ex-team-realization, this map sends the sequence-form vector $(1, e, overline(e), f, overline(f))$ to $vy$.

== Convexifying the TME <sec-team-convexification>

// Not from the lecture: this subsection follows Farina et al. (2018), Thm 2.
The TME can be written in the same form as @thm-team-bspp. An uncorrelated team strategy is a pair of mixed strategies, written $vx_1, vx_2$ in the definition of the TME. Since $vx$ now denotes a realization vector, we rename them $vmu_1 in Delta(Pi_1)$ and $vmu_2 in Delta(Pi_2)$. They induce the product distribution $vmu_1 times.o vmu_2$ on joint plans, and
$
  tilde(cX) := {vx^(vmu_1 times.o vmu_2) : vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)} subset.eq cX
$
is the set of their realization vectors, the vectors the team can reach _without_ shared randomness. This set is not convex (@ex-team-pad-not-uncorrelated).

#theorem[TMECor convexifies TME #citep(<Farina18:Ex>)][
  The TME value is $max_(vx in tilde(cX)) min_(vy in cY) vx^top U vy$ and the TMECor value is the same problem over $conv(tilde(cX)) = cX$, where $tilde(cX)$ is the set of realization vectors of uncorrelated team strategies.
] <thm-team-convexification>
#proof[
  By @lem-team-utility, the TME objective at $(vmu_1, vmu_2)$ is $min_(vy in cY) (vx^(vmu_1 times.o vmu_2))^top U vy$, so the TME value is the maxmin problem over $tilde(cX)$. By @thm-team-bspp, the TMECor value is the same problem over $cX$, so it remains to show $conv(tilde(cX)) = cX$. A joint plan is the product of two point masses, so $V subset.eq tilde(cX)$. A product distribution is a distribution on $Pi_1 times Pi_2$, so $tilde(cX) subset.eq cX$. Taking convex hulls, $cX = conv(V) subset.eq conv(tilde(cX)) subset.eq cX$.
]

#example[The one-time pad is not uncorrelated][
  Every path of the communication game meets one decision node of Player 1 and one information set of Player 2, so $vx^(vmu_1 times.o vmu_2)$ depends on $vmu_1$ and $vmu_2$ only through the probability of each action at each of these, that is, through the behavioral probabilities $(a, b; c, d)$. Hence $tilde(cX)$ is exactly the set of vectors $vx(a, b; c, d)$ of @ex-team-realization with $(a, b; c, d) in [0, 1]^4$. The realization vector of the one-time pad is
  $
    vx^(vmu^star) = 1/2 vx^((1, 0; 1, 0)) + 1/2 vx^((0, 1; 0, 1)) = (1/2, 1/2, 0 #h(.4em) bar.v #h(.4em) 0, 1/2, 1/2 #h(.4em) bar.v #h(.4em) 1/2, 1/2, 0 #h(.4em) bar.v #h(.4em) 0, 1/2, 1/2) in cX.
  $
  If $vx^(vmu^star) = vx(a, b; c, d)$, the first two blocks would need
  $
    a c = 1/2, quad a overline(c) = 0 & quad ==> quad c = 1, \
    b c = 0, quad b overline(c) = 1/2 & quad ==> quad c = 0,
  $
  which is impossible. So $vx^(vmu^star) in.not tilde(cX)$, although it is the midpoint of two points of $V subset.eq tilde(cX)$.
] <ex-team-pad-not-uncorrelated>

== Beyond the sequence form <sec-team-sequence-form>

The problem of @thm-team-bspp is a convex bilinear saddle-point problem that looks like the sequence-form problem, but we have been hiding something. If the team had perfect recall, $cX$ would be a linear image of a sequence-form polytope, as $cY$ is for Player 3. A team in general does not have perfect recall. In the sequence form, each information set has exactly one parent sequence, and its flow constraint splits the mass of that sequence among the actions at the information set. In the communication game, each information set of Player 2 has two parent sequences, one through each node of Player 1.

// Not from the lecture: this example is an addition (derived and verified numerically).
#example[The flow relaxation is too large][
  The natural flow relaxation of the communication game is the polytope of a team that does _not_ forget, as if Player 2 also saw the bit. With leaves numbered as in @fig-team-communication-game, it says that the team's total mass is $1$ for each value of the bit and that the two children of each Player 3 node carry equal mass:
  $
    R := {vx in RR_(>= 0)^Z : & x[z_1] + x[z_3] + x[z_7] + x[z_9] = 1, quad x[z_4] + x[z_5] + x[z_10] + x[z_11] = 1, \
      & x[z_1] = x[z_2], quad x[z_5] = x[z_6], quad x[z_7] = x[z_8], quad x[z_11] = x[z_12]}.
  $
  A point of $R$ is a pair of distributions over the team's four possible outcomes, one for each value of the bit, so $R$ is a product of two simplices. Its 16 vertices are the pairs of outcomes, one per value of the bit. A joint plan produces every pair except the four in which Player 1 sends the same message for both values of the bit, yet Player 2 acts differently, which only a Player 2 who sees the bit could do:
  #align(center, table(
    stroke: none,
    columns: 3,
    align: center + horizon,
    inset: (x: .6em, y: .45em),
    table.header([*Bit 0 leaf*], [*Bit 1 leaf*], [*Inequality that cuts it off*]),
    table.hline(stroke: .5pt),
    [$z_1$], [$z_5$], [$x[z_1] + x[z_5] <= 1$],
    [$z_3$], [$z_4$], [$x[z_3] + x[z_4] <= 1$],
    [$z_7$], [$z_11$], [$x[z_7] + x[z_11] <= 1$],
    [$z_9$], [$z_10$], [$x[z_9] + x[z_10] <= 1$],
  ))
  So $cX subset.neq R$, and adding the four inequalities to $R$ gives exactly $cX$. Indeed, a point of $R$ lies in $cX$ exactly when its two distributions can be coupled without using a forbidden pair. By Gale's supply–demand theorem #citep(<Gale57:Theorem>), and since each outcome forbids exactly one partner and different outcomes forbid different partners, the only conditions are the four inequalities in the table.
] <ex-team-flow-gap>

The gap is invisible in the value of this game. A point of $R$ is a pair of distributions over the team's outcomes, one for each value of the bit. If Player 3 guesses uniformly ($e = f = 1\/2$), it is wrong with probability $1\/2$ whatever these distributions are, and the team scores only when Player 3 is wrong. So the team gets at most $1\/2$ on all of $R$, and since $cX subset.eq R$, the maxmin value over $R$ is also $1\/2$. But $R$ contains strategies that no team can play. In this small game, four extra inequalities repair the relaxation. In general no repair is efficient. If $cX$ had an efficient representation, for example by polynomially many linear inequalities, we could plug it into the saddle-point problem of @thm-team-bspp and compute a TMECor in polynomial time. Computing a TMECor is NP-hard, as the next part of the lecture shows, so unless $P = NP$ no such representation exists.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
