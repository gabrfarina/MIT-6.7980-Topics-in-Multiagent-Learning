#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

// The set of uncorrelated realization vectors. The default tilde is easy to misread as a bar.
#let tcX = $accent(cX, tilde, size: #130%)$

// L12, part 2 (correlation and imperfect recall, slides 6-7) and part 3 (realization form, slide 8).
// Parts 1 and 4 (the game, the TME, and hardness) are in a separate contribution.

// Figure L12.1 is shared with part 1 of the lecture. It is included here so this file compiles on its own.
#figure(
  image("figures/team/communication_game.svg", width: 85%),
  caption: [The communication game. Team ▲ is Players 1 and 2, and Player 3 (▼) is the adversary. Edge labels are behavioral probabilities, with $overline(x) := 1 - x$. Leaves show the team's payoff and their index $z_1, dots, z_12$. Chance draws a uniform bit that only Player 1 sees. Players 2 and 3 observe Player 1’s action and then each guess the bit. Team ▲ gets 1 if Player 2 guesses right and Player 3 guesses wrong, and 0 otherwise. Player 3 does not move after a wrong guess by Player 2, since the team then gets 0.],
) <fig-team-communication-game>

= Correlation and imperfect recall <sec-team-correlation>

Earlier in this lecture we saw that the TME of the communication game has value $1\/4$, while swapping max and min gives $1\/2$. The version of the minimax theorem we use assumes convex compact strategy sets and a utility that is linear in each side's strategy when the other side's strategy is fixed. The team's utility contains products such as $a dot c$ of the two teammates' variables, so it is not linear in the team's strategy, and the maxmin problem is nonconvex (@exr-team-bilinear shows that the utility is not even concave).

For most of this lecture we let the teammates correlate. Before the game starts they may discuss strategy and flip coins that only they see, but during play they can communicate only through the actions the game allows. Formally, the team chooses a distribution $vmu$ over its _joint_ pure plans, and the adversary chooses a mixed strategy $vy$ as usual.

#definition[Team maxmin equilibrium with correlation #citep(<Celli18:Computational>, <Farina18:Ex>)][
  A _team maxmin equilibrium with correlation (TMECor)_ is a distribution $vmu$ over joint plans $(pi_1, pi_2) in Pi_1 times Pi_2$ that solves
  $
    max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in Delta(Pi_3)) EE_((pi_1, pi_2) ~ vmu) u(pi_1, pi_2, vy).
  $
] <def-team-tmecor>

// Not from the lecture (Celli-Gatti 2018, Farina et al. 2018): the comparison with the CE device.
The distribution $vmu$ in @def-team-tmecor plays the role of the correlation device of #lecture-link("correlated", <sec-ce>)[correlated equilibrium], restricted to the team. It samples a joint plan before play. Each teammate may see all of it, as long as the adversary does not. Here we optimize a jointly chosen team strategy, so we impose none of the incentive constraints that define correlated equilibrium.

== The one-time pad <sec-team-one-time-pad>

Readers familiar with cryptography will recognize the team's optimal strategy as a _one-time pad_. Before play, Players 1 and 2 flip a shared fair coin. On heads, Player 1 sends the bit as it is, and on tails it sends the flipped bit. Coding heads and the left message as 0, the message is the bit XOR the coin. Player 2 knows the coin, so it undoes the flip and always guesses correctly. Player 3 does not know the coin, so to Player 3 the message carries no information about the bit, which is Shannon's _perfect secrecy_. Write $delta_pi$ for the point mass on a joint plan $pi$. In the coordinates $(a, b; c, d)$ of @fig-team-communication-game,
$
  vmu^star := 1/2 delta_((1, 0; 1, 0)) + 1/2 delta_((0, 1; 0, 1)).
$
The two joint plans are the heads and tails branches of the coin (@fig-team-one-time-pad).

#figure(
  image("figures/team/one_time_pad.svg", width: 85%),
  caption: [The two joint plans of the one-time pad, each drawn with probability $1\/2$. Green edges are prescribed actions, dashed at Player 2 nodes the plan never reaches. Under either plan Player 2 guesses right. Player 3 sees the message but not the plan.],
) <fig-team-one-time-pad>

Under $vmu^star$, Player 2 always guesses right, and the message is uniform and independent of the bit. So Player 3 is right with probability $1\/2$ whatever it does, and the team gets $1\/2$ against every $vy$. Conversely, the team scores only when Player 3 guesses wrong. If Player 3 guesses uniformly at random, it is wrong with probability $1\/2$, so no team strategy gets more than $1\/2$. Hence the TMECor value is $1\/2$. This is twice the TME value of $1\/4$, and it equals the min-max value computed earlier. Correlation closes the gap between the maxmin and min-max values. The factor of $2$ is particular to this game. In other games the TMECor value can exceed the TME value by a factor linear in the number of leaves #citep(<Farina18:Ex>).

#figure(
  image("figures/team/hats_setup.svg", width: 68%),
  caption: [The teammates of @ex-team-hats. The adversary, not drawn, chose the hats. Dashed arrows are lines of sight, and ? marks the hat its wearer cannot see. With red, red, blue only teammate 3 guesses, correctly. With all red, everyone guesses wrong.],
) <fig-team-hats>

#example[Three hats][
  An adversary puts a red or a blue hat on each of three teammates. Each sees the other two hats but not its own. All three act at the same time. Each guesses its own color or passes. The team gets $1$ if someone is right and nobody is wrong. This is Ebert's hat puzzle #citep(<Lenstra05:Hats>), except that an adversary places the hats instead of chance.

  A joint plan fixes in advance what each teammate does on each pair it might see, and the adversary knows the plan. A plan with no guesses never wins. If the plan has teammate 1 guess red on seeing two blue hats, the adversary puts blue on all three, and teammate 1 is wrong, so the team loses. Any guess on any pair can be punished this way, so every plan guarantees $0$.

  The plan "on seeing two equal hats, guess the other color, and otherwise pass" wins on $6$ of the $8$ assignments. It loses only on all red and all blue (@fig-team-hats). The adversary, however, picks a losing assignment.

  Shared randomness takes that choice away. Before play the teammates flip three fair coins, one per hat, unseen by the adversary. Each teammate swaps red and blue on every hat whose coin shows heads, applies the plan, and swaps its guess back if its own coin shows heads. The team wins exactly when the plan wins on the swapped hats. Each coin is a one-time pad that hides the true color of its hat from the plan. So whatever the adversary chose, the swapped assignment is uniform over all $8$, and the team wins with probability $3\/4$. The adversary can no longer steer play to all red or all blue.

  The TMECor value is $3\/4$, since uniformly random hats hold every team strategy to $3\/4$. Without shared coins the TME value is exactly $1\/2$, reached when one teammate guesses at random and the others pass. @exr-team-hats proves both values.
] <ex-team-hats>


In the communication game, too, every joint plan guarantees $0$. Player 2’s guess is then a function of the message, and Player 3 can copy it.

#exercise[The one-time pad is the only TMECor][
  In the communication game of @fig-team-communication-game, show that $vmu^star$ is the unique TMECor. That is, show that every $vmu in Delta(Pi_1 times Pi_2)$ that guarantees the team $1\/2$ against every strategy of Player 3 equals $vmu^star$.

  Hint in @sec-team-hints.
] <exr-team-pad-unique>
#solution[
  By @sec-team-one-time-pad, $vmu^star$ guarantees $1\/2$. Suppose $vmu$ also guarantees $1\/2$, and write a joint plan as $(a, b; c, d) in {0, 1}^4$.

  *Player 2 is always right.* If Player 3 guesses uniformly after each message, it is wrong with probability $1\/2$ whatever the team does, so the team gets half the probability that Player 2 guesses right. A guarantee of $1\/2$ therefore forces Player 2 to be right for both bits under every joint plan in the support of $vmu$. If $a = b$, Player 1 sends the same message for both bits, and Player 2’s guess is right for only one of them. If $(a, b) = (1, 0)$, Player 2 is right for both bits only when $(c, d) = (1, 0)$, and if $(a, b) = (0, 1)$, only when $(c, d) = (0, 1)$. So
  $
    vmu = lambda delta_((1, 0; 1, 0)) + (1 - lambda) delta_((0, 1; 0, 1)) quad "for some" lambda in [0, 1].
  $

  *The two plans are equally likely.* Suppose Player 3 guesses 0 after the left message and 1 after the right message. It is then always right against the heads plan and always wrong against the tails plan, so the team gets $1 - lambda >= 1\/2$. Against the opposite guesses the team gets $lambda >= 1\/2$. Hence $lambda = 1\/2$ and $vmu = vmu^star$.
]

== Correlation restores the minimax theorem <sec-team-minimax>

With correlation, the team acts as a single player whose pure strategies are the joint plans $Pi_1 times Pi_2$ and whose mixed strategies are the distributions $vmu$. The TMECor problem is then nothing but a large two-player zero-sum normal-form game between this player and the adversary. Its objective is bilinear in $(vmu, vy)$, so the #lecture-link("learning_intro", <sec-learning-minimax>)[minimax theorem] holds and the maxmin value equals the min-max value (@tab-team-minimax).

#figure(
  supplement: [Table],
  caption: [TME versus TMECor in the communication game.],
  table(
    // A header rule drawn through `stroke` also appears in the HTML build, unlike table.hline.
    stroke: (x, y) => if y == 0 { (bottom: .5pt) },
    columns: 5,
    align: center + horizon,
    inset: .7em,
    table.header([], [*Team strategies*], [*Value*], [*Optimization problem*], [*Minimax theorem*]),
    [TME], [$Delta(Pi_1) times Delta(Pi_2)$], [$1\/4$], [nonconvex program], [fails],
    [TMECor], [$Delta(Pi_1 times Pi_2)$], [$1\/2$], [bilinear saddle point], [holds],
  ),
) <tab-team-minimax>

== Team games as imperfect-recall games <sec-team-imperfect-recall>

Equivalently, we can think of the two teammates as one player that happens to forget. In @fig-team-communication-game this amounts to drawing Player 2’s nodes as nodes of Player 1. Each information set of Player 2 then joins nodes that the merged player reached after observing different bits, so the player forgets what it knew. A team game is thus a two-player zero-sum game in which each team becomes a single player, who in general has imperfect recall #citep(<Farina18:Ex>, <Zhang23:Team>). Strictly, the equivalence is with _timeable_ imperfect-recall games, in which every player always knows what time it is. We return to timeability later in the lecture, and we assume that each original player has perfect recall. @tab-team-dictionary translates between the two views.

The player forgets because a teammate cannot secretly share what it knows during play. Two colluding poker players who could secretly show each other their cards would merge into a single player with perfect recall. Colluders who can signal only through their bets merge into a player who in general forgets. Farina et al. test their methods on three-player poker with two colluders #citep(<Farina18:Ex>). In @ex-team-hats, a teammate who could speak during play would announce another teammate's hat color. That teammate would guess right and the others would pass, so the team would win surely, like a single player who sees all three hats.

#figure(
  supplement: [Table],
  caption: [Team games and two-player zero-sum games of imperfect recall. Uncorrelated team strategies correspond to behavioral strategies up to realization equivalence.],
  table(
    stroke: (x, y) => if y == 0 { (bottom: .5pt) },
    columns: 3,
    align: left + top,
    inset: .7em,
    table.header([*Team game*], [*Imperfect-recall game*], [*Communication game*]),
    [team], [player], [Players 1 and 2],
    [team strategy], [strategy for the player], [$(a, b; c, d)$ or $vmu$],
    [uncorrelated team strategy], [behavioral strategy], [$(a, b; c, d) in [0, 1]^4$],
    [correlated team strategy], [mixed strategy], [$vmu in Delta(Pi_1 times Pi_2)$],
    [TME], [optimal behavioral strategy], [e.g. $a = b = c = d = 1\/2$],
    [TMECor], [team's mixed Nash strategy], [$vmu^star$],
  ),
) <tab-team-dictionary>

By the #lecture-link("correlated", <sec-zero-sum>)[minimax theorem], a maxmin strategy of the team is exactly the team's part of a mixed Nash equilibrium of this game. So most of this lecture can be read as computing mixed Nash equilibria of two-player zero-sum games of imperfect recall. _Behavioral_ and _mixed_ strategies must be distinguished because #lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem], which makes them realization-equivalent, requires perfect recall, which the team player lacks. A behavioral strategy randomizes independently at each information set, so it cannot make Player 2’s guess depend on the coin behind Player 1’s message. The one-time pad is therefore a mixed strategy that no behavioral strategy realizes (@ex-team-realization).

Team-PSRO #citep(<McAleer23:Team>) keeps a mixture over joint policies and samples one per play. Averaging each teammate's policies separately can lose the correlation. For the one-time pad the average is $(1\/2, 1\/2; 1\/2, 1\/2)$, which guarantees only $1\/4$.

The question for the rest of the lecture is when a TMECor can be computed efficiently.

= Realization form <sec-team-realization-form>

By @sec-team-minimax, a TMECor is a maxmin strategy of a two-player zero-sum game. The obstacle is size. The distribution $vmu$ has one coordinate per joint plan, and the number of joint plans can be exponential in the size of the game tree, the same blowup as in the #lecture-link("efg_intro", <sec-strategic-form>)[strategic form]. As with the sequence form, we record only what affects the payoff, namely which terminal nodes the team plays toward.

#definition[Team realization vectors #citep(<Farina18:Ex>, <Zhang23:Team>)][
  Let $Z$ be the set of terminal nodes. The _realization vector_ of a joint plan $(pi_1, pi_2) in Pi_1 times Pi_2$ is the vector $vx^(pi_1, pi_2) in {0, 1}^Z$ with $x^(pi_1, pi_2)[z] = 1$ if and only if team ▲ plays all of its actions on the path from the root to $z$. The _realization polytope_ of the team is the convex hull of these vectors,
  $
    cX := conv(V), quad "where" quad V := {vx^(pi_1, pi_2) : (pi_1, pi_2) in Pi_1 times Pi_2} subset.eq {0, 1}^Z.
  $
] <def-team-realization>

The polytope $cY$ of team ▼ is defined in the same way. In @def-team-tmecor, team ▼ is Player 3 alone. From now on $vy$ denotes a point of $cY$ rather than a mixed strategy of team ▼. Different joint plans can have the same realization vector. In the communication game the 16 joint plans give only 12 vectors, because if Player 1 always sends the same message, Player 2’s action after the other message is never used.

The _realization vector_ of a distribution $vmu in Delta(Pi_1 times Pi_2)$ is $vx^vmu := EE_((pi_1, pi_2) ~ vmu) vx^(pi_1, pi_2)$. Its entry $x^vmu [z]$ is the probability that the team plays all its actions on the path to $z$. The map $vmu |-> vx^vmu$ is linear and sends each point mass to its plan's realization vector. Since $Delta(Pi_1 times Pi_2)$ is the convex hull of the point masses, its image is $conv(V) = cX$, the set of realization vectors of correlated team strategies. By Carathéodory's theorem, any point of $cX$ is realized by a $vmu$ on at most $abs(Z) + 1$ joint plans. Likewise, $cY$ is the image of the mixed strategies of team ▼.

#example[Realization vectors in the communication game][
  Number the leaves as in @fig-team-communication-game. If both teammates always play left ($a = b = c = d = 1$), the team plays all of its actions on the paths to $z_1$, $z_2$, and $z_4$ only, so its realization vector is $(1, 1, 0 #h(.4em) bar.v #h(.4em) 1, 0, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0)$. It has 12 entries, one per terminal node, instead of one per joint plan. Bars separate the three leaves below each Player 2 node. For a general uncorrelated team strategy in behavioral coordinates, and for Player 3,
  $
    vx(a, b; c, d) & = (a c, a c, a overline(c) #h(.4em) bar.v #h(.4em) b c, b overline(c), b overline(c) #h(.4em) bar.v #h(.4em) overline(a) d, overline(a) d, overline(a) overline(d) #h(.4em) bar.v #h(.4em) overline(b) d, overline(b) overline(d), overline(b) overline(d)), \
    vy & = (e, overline(e), 1 #h(.4em) bar.v #h(.4em) 1, e, overline(e) #h(.4em) bar.v #h(.4em) f, overline(f), 1 #h(.4em) bar.v #h(.4em) 1, f, overline(f)).
  $
  Each entry of $vx(a, b; c, d)$ is a product of one probability from each teammate, the same products that made the TME problem nonconvex. The one-time pad mixes the heads and tails plans, so its realization vector is
  $
    vx^(vmu^star) = 1/2 vx^((1, 0; 1, 0)) + 1/2 vx^((0, 1; 0, 1)) = (1/2, 1/2, 0 #h(.4em) bar.v #h(.4em) 0, 1/2, 1/2 #h(.4em) bar.v #h(.4em) 1/2, 1/2, 0 #h(.4em) bar.v #h(.4em) 0, 1/2, 1/2).
  $
  Each path uses one action from each teammate, so independent mixed plans give the same vector as their behavioral action probabilities. No uncorrelated strategy has this vector, since matching its first two blocks would need
  $
    a c = 1/2, quad a overline(c) = 0 & quad ==> quad c = 1, \
    b c = 0, quad b overline(c) = 1/2 & quad ==> quad c = 0,
  $
  which is impossible.
] <ex-team-realization>

== TMECor as a bilinear saddle-point problem <sec-team-bspp>

Realization vectors record only the teams' actions, so chance probabilities go into the payoff matrix. Let $p_"chance" (z)$ be the product of the chance probabilities on the path to $z$, and define
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
  The TMECor value equals $max_(vx in cX) min_(vy in cY) vx^top U vy$. A distribution $vmu$ is a TMECor if and only if $vx^vmu$ is a maxmin solution of this problem, and every maxmin solution is $vx^vmu$ for some TMECor $vmu$.
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

This #lecture-link("learning_intro", <sec-learning-zero-sum>)[saddle-point problem] adapts the sequence form to teams. When a team is a single player with perfect recall, the entry $x[z]$ is the sequence-form entry of the player's last sequence on the path to $z$ (the empty sequence if the player does not act on that path). So $cX$ is a linear image of the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytope], and the problem above is the usual sequence-form maxmin problem composed with this linear map. For Player 3 in @ex-team-realization, this map sends the sequence-form vector $(1, e, overline(e), f, overline(f))$ to $vy$.

== Convexifying the TME <sec-team-convexification>

// Not from the lecture: this subsection follows Farina et al. (2018), Thm 2.
The TME can be written in the same form as @thm-team-bspp. Mixed strategies $vmu_1 in Delta(Pi_1)$ and $vmu_2 in Delta(Pi_2)$ of the two teammates, written $vx_1, vx_2$ in the definition of the TME, induce the product distribution $vmu_1 times.o vmu_2$ on joint plans, a rank-one matrix in $RR^(Pi_1 times Pi_2)$, and
$
  tcX := {vx^(vmu_1 times.o vmu_2) : vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)} subset.eq cX
$
is the set of their _uncorrelated_ realization vectors, the vectors the team can reach without shared randomness. In the communication game every path meets one decision node of Player 1 and one information set of Player 2, so $tcX = {vx(a, b; c, d) : (a, b, c, d) in [0, 1]^4}$, using the vectors of @ex-team-realization. That example shows that the one-time pad, a point of $cX$, is not in $tcX$, although it is the midpoint of two points of $V subset.eq tcX$. So $tcX$ need not be convex.

#theorem[TMECor convexifies TME #citep(<Farina18:Ex>)][
  The TME value is $max_(vx in tcX) min_(vy in cY) vx^top U vy$ and the TMECor value is the same problem over $conv(tcX) = cX$, where $tcX$ is the set of realization vectors of uncorrelated team strategies.
] <thm-team-convexification>
#proof[
  By @lem-team-utility, the TME value is the maxmin problem over $tcX$, and by @thm-team-bspp the TMECor value is the same problem over $cX$. It remains to show $conv(tcX) = cX$. A joint plan is the product of two point masses, so $V subset.eq tcX$. A product distribution is a distribution on $Pi_1 times Pi_2$, so $tcX subset.eq cX$. Taking convex hulls, $cX = conv(V) subset.eq conv(tcX) subset.eq cX$.
]

@fig-team-realization-sets sketches these sets.

#figure(
  image("figures/team/realization_sets.svg", width: 56%),
  caption: [Schematic of $V subset.eq tcX subset.eq cX subset.neq R$ in the communication game, not to scale. $R$ is the flow polytope of a team that does not forget (@sec-team-flow). The one-time pad, the midpoint of the heads and tails plans, lies in $cX$ but not in $tcX$.],
) <fig-team-realization-sets>

#remark[Why convexification can improve the guarantee][
  For a fixed $vy$, the payoff $vx^top U vy$ is linear in $vx$, so its maximum over $cX = conv(tcX)$ is attained at a point of $V subset.eq tcX$, the familiar fact that some best response is pure. Correlation can help only in the maxmin problem, where the team commits to one $vx$ and Player 3 best-responds. The guarantee $min_(vy in cY) vx^top U vy$ is a minimum of linear functions, so it is concave but in general not linear, and its maximum over $cX$ can lie outside $tcX$. In the communication game, as in matching pennies, Player 3 holds each of the heads and tails plans to $0$, while their mixture, the one-time pad, guarantees $1\/2$, more than the TME value $1\/4$.
]

#exercise[Where the nonconvexity goes][
  Use the communication game of @fig-team-communication-game and the vectors $vx(a, b; c, d)$ and $vy$ of @ex-team-realization.
  #set enum(numbering: "(i)")
  + Compute $vx(a, b; c, d)^top U vy$ as a polynomial in $a, dots, f$. Check that it agrees with the expected utility computed directly from the tree.
  + Fix Player 3 at $e = f = 1\/2$. Use the joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ and their midpoint in behavioral coordinates to show that the team's utility is not a concave function of $(a, b, c, d) in [0, 1]^4$.

  Hint in @sec-team-hints.
] <exr-team-bilinear>
#solution[
  #set enum(numbering: "(i)")
  + Chance plays each bit with probability $1\/2$, and the team scores $1$ exactly at $z_2, z_5, z_8, z_11$. So $U$ is diagonal with entry $1\/2$ at these four leaves and $0$ elsewhere. Reading off the entries of @ex-team-realization at these leaves gives
    $
      vx(a, b; c, d)^top U vy = 1/2 (a c overline(e) + b overline(c) e + overline(a) d overline(f) + overline(b) overline(d) f).
    $
    Each term is the probability, given the bit, that Player 1 sends a particular message, Player 2 is right, and Player 3 is wrong. Each bit has probability $1\/2$.

  + At $e = f = 1\/2$ the utility is
    $
      u(a, b, c, d) = 1/4 (a c + b overline(c) + overline(a) d + overline(b) overline(d)) = 1/4 (1 + (a - b) dot (c - d)).
    $
    Both joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ give $1\/2$. Their midpoint in behavioral coordinates is $(1\/2, 1\/2; 1\/2, 1\/2)$, which gives $1\/4$. A concave function would be at least $1\/2$ there, the average of its values at the endpoints. So $u$ is not concave.

  The products $a c, b overline(c), dots$ that make $u$ nonconcave have not disappeared. They are the coordinates of $vx$. So the objective is linear in $vx$, and the nonconvexity has moved into the set $tcX$, which correlation convexifies to $cX$ (@thm-team-convexification).
]

== Beyond the sequence form <sec-team-sequence-form>

The problem of @thm-team-bspp is a convex bilinear saddle-point problem that looks like the sequence-form problem, but we have not yet said how to describe $cX$ efficiently. If the team had perfect recall, $cX$ would be a linear image of a sequence-form polytope, as $cY$ is for Player 3. A team in general does not have perfect recall. In the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form], each information set has exactly one parent sequence, and its flow constraint splits the mass of that sequence among the actions at the information set. In the communication game, each information set of Player 2 has two parent sequences, one through each node of Player 1.

A natural guess is to keep the flow constraints of a team that does not forget, as if Player 2 saw the bit. In the communication game this gives a polytope $R$ that strictly contains $cX$, and four extra inequalities cut it down to $cX$ (@sec-team-flow). The companion notebook #link("https://github.com/gabrfarina/MIT-6.7980-Topics-in-Multiagent-Learning/blob/main/content/notebooks/team/communication_game.ipynb")[`communication_game.ipynb`] checks the realization vectors, the game values, and the flow relaxation with exact arithmetic.

In general we should not expect a repair like these four inequalities. Suppose some polynomial-time procedure produced, for every team game, a polynomial-size linear description of $cX$. Together with the sequence form for Player 3, linear programming would then solve the saddle-point problem of @thm-team-bspp in polynomial time. Computing a TMECor is NP-hard, as the next part of the lecture shows, so unless $P = NP$ no such procedure exists.

= Problems <sec-team-problems>

#exercise[A biased bit][
  Modify the communication game of @fig-team-communication-game so that chance draws bit 0 with probability $p$ and bit 1 with probability $1 - p$, where $1\/2 <= p < 1$. Everything else stays the same.

  #set enum(numbering: "(i)")
  + Show that the TMECor value is $1 - p$.
  + For $q in [0, 1]$, consider the biased one-time pad $vmu_q := q delta_((1, 0; 1, 0)) + (1 - q) delta_((0, 1; 0, 1))$. Show that the fair pad $vmu_(1\/2) = vmu^star$ is still a TMECor. Find all $q$ for which $vmu_q$ is a TMECor. Is the message still independent of the bit for all of them?
  + Show that the TME value is $p (1 - p)$. Describe the uncorrelated strategies $(a, b; c, d)$ that attain it.

  Hints in @sec-team-hints.
] <exr-team-biased-bit>
#solution[
  Write $e$ and $f$ for the probabilities that Player 3 guesses 0 after the left and the right message. By @lem-team-utility with the new chance probabilities and the vectors of @ex-team-realization, the uncorrelated team strategy $(a, b; c, d)$ gets
  $
    u = p a c overline(e) + (1 - p) b overline(c) e + p overline(a) d overline(f) + (1 - p) overline(b) overline(d) f.
  $

  *(i)* If Player 3 always guesses 0 ($e = f = 1$), every joint plan gets $u = (1 - p) dot (b overline(c) + overline(b) overline(d)) <= 1 - p$. So no $vmu$ guarantees more than $1 - p$. Conversely, under $vmu^star$ Player 2 is always right and the message is independent of the bit. If Player 3 guesses 0 with probability $s$, it is wrong with probability $s (1 - p) + (1 - s) p >= 1 - p$, since $p >= 1\/2$. So $vmu^star$ guarantees $1 - p$, and the TMECor value is $1 - p$.

  *(ii)* By (i), $vmu_(1\/2) = vmu^star$ is a TMECor. Under $vmu_q$ Player 2 is always right. After each message Player 3 guesses the likelier bit, so the team gets the Bayes error, the smaller of the two joint probabilities of bit and message, summed over messages:
  $
    V(q) = min(p q, (1 - p)(1 - q)) + min(p (1 - q), (1 - p) q).
  $
  Note that $p q - (1 - p)(1 - q) = q - (1 - p)$ and $p (1 - q) - (1 - p) q = p - q$. Splitting at $q = 1 - p$ and $q = p$ gives $V(q) = min(q, 1 - q, 1 - p)$, so $vmu_q$ is a TMECor if and only if $q in [1 - p, p]$. Player 1 sends the left message with probability $q$ after bit 0 and $1 - q$ after bit 1, so the message is independent of the bit only for $q = 1\/2$. For the other optimal $q$, bit 0 stays at least as likely after either message, so the message does not help Player 3.

  *(iii)* Since $u$ is linear in $e$ and in $f$,
  $
    min_(e, f) u = min(p a c, (1 - p) b overline(c)) + min(p overline(a) d, (1 - p) overline(b) overline(d)).
  $
  For $alpha, beta >= 0$ the map $c |-> min(alpha c, beta overline(c))$ has maximum $g(alpha, beta) := alpha beta \/ (alpha + beta)$ over $[0, 1]$, with $g(0, 0) := 0$. This is half the harmonic mean of $alpha$ and $beta$. If $alpha, beta > 0$, it is attained only at $c = beta \/ (alpha + beta)$. So the TME value is the maximum over $(a, b)$ of $g(vu) + g(vv)$, where $vu := (p a, (1 - p) b)$ and $vv := (p overline(a), (1 - p) overline(b))$. The function $g$ is concave and positively homogeneous, hence superadditive. Since $vu + vv = (p, 1 - p)$,
  $
    g(vu) + g(vv) <= g(p, 1 - p) = p (1 - p).
  $
  The strategy $a = b$, $c = d = 1 - p$ attains this bound, so the TME value is $p (1 - p)$.

  For equality, write $vu = (alpha_1, beta_1)$ and $vv = (alpha_2, beta_2)$. If both are nonzero, a computation gives
  $
    g(vu + vv) - g(vu) - g(vv) = (alpha_1 beta_2 - alpha_2 beta_1)^2 / ((alpha_1 + beta_1)(alpha_2 + beta_2)(alpha_1 + alpha_2 + beta_1 + beta_2)),
  $
  with $alpha_1 beta_2 - alpha_2 beta_1 = p (1 - p)(a - b)$. If one of them is zero, then $a = b in {0, 1}$. So equality forces $a = b$. The first term is then $a dot min(p c, (1 - p) overline(c))$, which reaches $a dot p (1 - p)$ only at $c = 1 - p$ when $a > 0$. Likewise $d = 1 - p$ when $a < 1$. The optimal uncorrelated strategies are therefore exactly those with $a = b$, with $c = 1 - p$ if $a > 0$ and $d = 1 - p$ if $a < 1$.
]

#exercise[Three hats][
  Consider the three-hat game of @ex-team-hats.

  #set enum(numbering: "(i)")
  + Show that every joint plan wins on at most $6$ of the $8$ assignments. Conclude that the TMECor value is $3\/4$.
  + Show that the TME value is $1\/2$.

  Hints in @sec-team-hints.
] <exr-team-hats>
#solution[
  *(i)* Fix a joint plan. A guess that a teammate makes on seeing some pair is right on exactly one of the two assignments that show it that pair, and wrong on the other. So over the $8$ assignments there are as many right guesses as wrong ones. A winning assignment has at least one right guess and no wrong one, and a losing assignment has at most three wrong guesses. If the plan wins on $w$ assignments, then
  $
    w <= "#right guesses" = "#wrong guesses" <= 3 dot (8 - w),
  $
  so $w <= 6$. A team strategy is a distribution over joint plans, so against uniformly random hats it wins with probability at most $6\/8 = 3\/4$. The coins of @ex-team-hats guarantee $3\/4$, so the TMECor value is $3\/4$.

  *(ii)* If teammate 1 guesses red or blue with probability $1\/2$ each and the others pass, the team wins with probability $1\/2$ on every assignment. For the upper bound, fix an uncorrelated team strategy. Write an assignment as $(h_1, v)$, where $h_1$ is teammate 1’s hat and $v$ is the pair of hats of teammates 2 and 3, which teammate 1 sees. Let $W(h_1, v)$ be the probability that the team wins on $(h_1, v)$ if teammate 1 is made to pass.

  Write $"win"(h_1, v)$ for the probability that the team wins on $(h_1, v)$. Fix $v$, and let teammate 1 guess with total probability $q$ on seeing $v$. Teammate 1 randomizes independently of the others. If it passes, the team wins with probability $W(h_1, v)$. If it guesses right, the team wins with probability at most $1$, and if it guesses wrong, the team loses. Its guess is right for only one of the two values of $h_1$, so summing over $h_1$,
  $
    "win"("red", v) + "win"("blue", v) <= (1 - q) dot (W("red", v) + W("blue", v)) + q.
  $

  Now fix $h_1$. Teammates 2 and 3 then play a game with two hats, in which each sees the other's hat. The counting argument of (i), with at most two wrong guesses per losing assignment, shows that every joint plan of teammates 2 and 3 wins on at most $2$ of the $4$ pairs $v$. Averaging over their strategies, $sum_v W(h_1, v) <= 2$. Summing over $h_1$ gives $sum_v (W("red", v) + W("blue", v)) <= 4$. There are four pairs $v$, so for some $v$ we have $W("red", v) + W("blue", v) <= 1$. For that $v$ the right-hand side above is at most $1$, so the team wins with probability at most $1\/2$ on $("red", v)$ or on $("blue", v)$. Hence the TME value is $1\/2$.
]

== Hints for the exercises <sec-team-hints>

*@exr-team-pad-unique.* First let Player 3 guess uniformly. How often must Player 2 then be right, and which joint plans achieve that? Then let Player 3 guess 0 after left and 1 after right.

*@exr-team-bilinear.* For (ii), write the utility at $e = f = 1\/2$ in terms of $a - b$ and $c - d$.

*@exr-team-biased-bit.* For (i), let Player 3 ignore the message. For (iii), Player 3 best-responds after each message. For fixed $a, b$, choose $c$ and $d$ to equalize its two options, and use that $g(alpha, beta) := alpha beta \/ (alpha + beta)$ is concave and positively homogeneous, so $g(vu) + g(vv) <= g(vu + vv)$.

*@exr-team-hats.* For (i), each guess is right on exactly one of the two assignments where it is made. Count right and wrong guesses. For (ii), fix the pair $v$ that teammate 1 sees, compare both colors of its hat, and apply (i) to teammates 2 and 3 alone.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#appendix[
  = Appendix: The flow relaxation <sec-team-flow>

  // Not from the lecture: this appendix is an addition (derived and verified numerically).
  This appendix works out the relaxation of @sec-team-sequence-form for the communication game.

  #example[The flow relaxation is too large][
    Consider the relaxation obtained by revealing the bit to Player 2. It is the flow polytope of a team that does _not_ forget. With leaves numbered as in @fig-team-communication-game, it says that the team's total mass is $1$ for each value of the bit and that the two children of each Player 3 node carry equal mass:
    $
      R := {vx in RR_(>= 0)^Z : & x[z_1] + x[z_3] + x[z_7] + x[z_9] = 1, quad x[z_4] + x[z_5] + x[z_10] + x[z_11] = 1, \
        & x[z_1] = x[z_2], quad x[z_5] = x[z_6], quad x[z_7] = x[z_8], quad x[z_11] = x[z_12]}.
    $
    A point of $R$ is a pair of distributions over the team's four possible outcomes, one for each value of the bit, so $R$ is a product of two simplices. Its 16 vertices are the pairs of outcomes, one per value of the bit. A joint plan produces every pair except the four in which Player 1 sends the same message for both values of the bit, yet Player 2 acts differently, which only a Player 2 who sees the bit could do:
    #align(center, table(
      stroke: (x, y) => if y == 0 { (bottom: .5pt) },
      columns: 3,
      align: center + horizon,
      inset: .7em,
      table.header([*Bit 0 leaf*], [*Bit 1 leaf*], [*Inequality that cuts it off*]),
      [$z_1$], [$z_5$], [$x[z_1] + x[z_5] <= 1$],
      [$z_3$], [$z_4$], [$x[z_3] + x[z_4] <= 1$],
      [$z_7$], [$z_11$], [$x[z_7] + x[z_11] <= 1$],
      [$z_9$], [$z_10$], [$x[z_9] + x[z_10] <= 1$],
    ))
    So $cX subset.neq R$. Adding the four inequalities to $R$ gives exactly $cX$, by a coupling argument with Gale's supply–demand theorem #citep(<Gale57:Theorem>), which generalizes Hall's marriage theorem. The forbidden pairs match each bit 0 outcome with one bit 1 outcome, so Gale's condition is nontrivial only for single outcomes, where it gives the four inequalities.
  ] <ex-team-flow-gap>

  The gap does not show in the value of this game. If Player 3 guesses uniformly, it is wrong with probability $1\/2$ whatever the team does, so the team gets at most $1\/2$ on all of $R$. The one-time pad lies in $cX subset.eq R$ and attains $1\/2$, so the maxmin value over $R$ is also $1\/2$.

  The picture of @fig-team-realization-sets also appears in variational inference #citep(<Wainwright08:Graphical>, [Sec.~5.4]). The mean parameters of product distributions, the naive mean-field family, form a subset of the marginal polytope containing all its vertices (point masses are product distributions), so it is nonconvex unless it is the whole polytope. They play the role of $tcX$, the marginal polytope that of $cX$, and the local polytope, an outer bound from local consistency, that of $R$.
]
