#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

// Source PRs in lecture order: #175 (tasks 1 and 4), #169 (tasks 2 and 3),
// #184 (task 5), #189 (public-signal supplement), #174 (task 6),
// #176 (task 7), #185 (task 8), and #173 (task 9).
= Team games <sec-team-games>

So far every player in a game has acted for itself. In many games, players instead form _teams_ whose members share a payoff. Bridge is played by two pairs, two colluding players at a poker table share their winnings, and in many multiplayer video games a team of agents faces a common opponent. Each teammate still acts on its own information, and the teammates cannot freely talk during play.

We study the simplest such setting, an _adversarial team game_. The players are split into two teams, ▲ and ▼. All members of team ▲ receive the same utility $u$, and all members of team ▼ receive $-u$, so the game is zero-sum between the teams. Before play, teammates may agree on how to play. During play, they can communicate only through the actions the game allows, which the other team may also observe. We assume that each player has #lecture-link("efg_intro", <sec-perfect-recall>)[perfect recall]. Most of the lecture has team ▼ consist of a single player, the _adversary_.

== The communication game <sec-team-comm-game>

Our running example is the _communication game_ of @fig-team-communication-game. Team ▲ is Players 1 and 2, and Player 3 is the adversary.

+ Chance draws a uniformly random bit, which only Player 1 sees.
+ Player 1 sends a message, left or right, which both Player 2 and Player 3 observe.
+ Players 2 and 3 each guess the bit without seeing each other's guess.

Team ▲ gets $1$ if Player 2 guesses right and Player 3 guesses wrong, and $0$ otherwise. Player 1 thus wants to tell Player 2 the bit without telling Player 3, but any message that Player 2 can read, Player 3 can read too.

// This figure uses the same notation and leaf numbering as team_games_tmecor.typ,
// so the realization vectors there refer to the same leaves.
#figure(
  caption: [The communication game. Team ▲ is Players 1 and 2, and Player 3 (▼) is the adversary. Chance ($times.o$) draws a uniform bit, 0 on the left, that only Player 1 sees. Shaded bands are information sets, whose nodes a player cannot tell apart, since Players 2 and 3 see the message but not the bit. Edge labels are behavioral probabilities, with $overline(x) := 1 - x$. Leaves show the team's payoff and are numbered $z_1, ..., z_12$. Player 3 does not move after a wrong guess by Player 2, as the team then gets 0.],
)[
  #image(
    "figures/team_games_tme/communication_game.svg",
    width: 90%,
    alt: "Game tree of the communication game. Chance draws a bit, Player 1 sends a message, and Players 2 and 3 each guess the bit.",
  )
] <fig-team-communication-game>

Each player has perfect recall, so by #lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem] we can describe each player's mixed strategy by a behavioral strategy without changing the outcome distribution. In the coordinates of @fig-team-communication-game,
- $a$ and $b$ are the probabilities that Player 1 sends left when the bit is $0$ and $1$,
- $c$ and $d$ are the probabilities that Player 2 guesses $0$ after left and after right, and
- $e$ and $f$ are the probabilities that Player 3 guesses $0$ after left and after right.

Summing over the four ways in which Player 2 can be right, the team's expected utility is
$
  u(a, b; c, d; e, f) = 1/2 (a c overline(e) + overline(a) d overline(f)) + 1/2 (b overline(c) e + overline(b) overline(d) f).
$
The first group is the bit $0$, where Player 2 is right when it guesses $0$ and Player 3 is wrong when it guesses $1$. The second group is the bit $1$. The utility contains products such as $a c$ of the two teammates' variables, so it is not linear in the team's strategy.

== Team maxmin equilibrium <sec-team-tme>

How should team ▲ play? If it were a single player, it would play a maxmin strategy. A team is not a single player, as each teammate randomizes on its own. Write $Pi_i$ for the set of pure strategies (plans) of Player $i$.

#definition[Team maxmin equilibrium #citep(<Stengel97:Team>)][
  A _team maxmin equilibrium (TME)_ is a pair of mixed strategies $vmu_1 in Delta(Pi_1)$ and $vmu_2 in Delta(Pi_2)$ of the teammates that solves
  $
    max_(vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)) min_(vy in Delta(Pi_3)) EE_(pi_1 ~ vmu_1, pi_2 ~ vmu_2) [u(pi_1, pi_2, vy)].
  $
  The optimal value is the _TME value_.
] <def-team-tme>

The teammates randomize _independently_. They may agree on $vmu_1$ and $vmu_2$ before play, but they share no source of randomness. The adversary picks its strategy knowing $vmu_1$ and $vmu_2$, but not the outcome of their randomization. By Kuhn's theorem, applied to each teammate separately, we may take the maximum over behavioral strategies $(a, b)$ and $(c, d)$ instead.

For a two-player zero-sum game, the #lecture-link("learning_intro", <sec-learning-minimax>)[minimax theorem] says that swapping max and min does not change the value. For teams it does.

#theorem[Max-min and min-max values][
  In the communication game, the TME (max-min) value is $1\/4$, while the min-max value
  $
    min_(vy in Delta(Pi_3)) max_(vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)) EE_(pi_1 ~ vmu_1, pi_2 ~ vmu_2) [u(pi_1, pi_2, vy)]
  $
  is $1\/2$.
] <thm-team-tme-values>
#proof[
  _Max-min._ Fix the team's strategy $(a, b; c, d)$. In the expected utility above, $e$ appears only in the terms $1/2 (a c overline(e) + b overline(c) e)$, which are linear in $e$, so Player 3 minimizes them at $e in {0, 1}$, and likewise for $f$. Hence the team guarantees
  $
    g(a, b; c, d) := 1/2 (min{a c, b overline(c)} + min{overline(a) d, overline(b) overline(d)}).
  $
  The minimum of two numbers is at most any convex combination of them. Weighting $a c$ by $overline(c)$ and $b overline(c)$ by $c$, and $overline(a) d$ by $overline(d)$ and $overline(b) overline(d)$ by $d$,
  $
    min{a c, b overline(c)} <= c overline(c) (a + b) <= (a + b)/4, quad
    min{overline(a) d, overline(b) overline(d)} <= d overline(d) (overline(a) + overline(b)) <= (overline(a) + overline(b))/4,
  $
  since $c overline(c) <= 1\/4$ and $d overline(d) <= 1\/4$. Adding the two bounds gives $g <= 1/2 dot (a + b + overline(a) + overline(b))/4 = 1/4$. The team attains $1\/4$ at $a = b = c = d = 1\/2$, where both minima equal $1\/4$.

  _Min-max._ If Player 3 guesses uniformly ($e = f = 1\/2$), it is wrong with probability $1\/2$ whatever the team does, so the team gets at most $1\/2$. Conversely, fix any $(e, f)$. The plan in which Player 1 sends the bit in the clear and Player 2 reads it ($a = c = 1$, $b = d = 0$) gets $1/2 (overline(e) + f)$, and the plan that sends the flipped bit ($a = c = 0$, $b = d = 1$) gets $1/2 (e + overline(f))$. The two values sum to $1$, so one of them is at least $1\/2$.
]

The two orders of play explain the gap. In the min-max problem the adversary commits first, and the team then tailors its message to the adversary's known guesses. In the max-min problem the team commits first. A message that tells Player 2 anything about the bit then tells Player 3 the same thing, so the team can do no better than having Player 2 guess blindly. For instance, if Player 1 sends the bit in the clear, Player 3 copies Player 2's guess and the team gets $0$. The team's utility is not concave in $(a, b; c, d)$, so the minimax theorem does not apply (see @exr-team-bilinear). @sec-team-correlation shows that shared randomness closes the gap.


== Why not Nash equilibrium? <sec-team-nash>

We could instead treat the teammates as separate players and look for a #lecture-link("nfgs_nash", <def-nash-equilibrium>)[Nash equilibrium] of the three-player game. A Nash equilibrium is never better for the team than a TME. In a Nash equilibrium the adversary best-responds to the teammates' strategies $(vmu_1, vmu_2)$, so the team gets $min_vy EE[u(pi_1, pi_2, vy)]$, which is at most the TME value by @def-team-tme. #citet(<Stengel97:Team>) show that a TME, together with a suitable strategy of the adversary, is itself a Nash equilibrium. So the TME is the Nash equilibrium that the team likes best.

Other Nash equilibria can be much worse for the team. A Nash equilibrium rules out only _unilateral_ deviations, and a team may be stuck where only a joint deviation helps.

#example[Miscoordination][
  Two teammates each choose $L$ or $R$, and the adversary has no move. The team gets $1$ if both choose $L$, $epsilon in (0, 1)$ if both choose $R$, and $0$ otherwise. The TME value is $1$, attained at $(L, L)$. The profile $(R, R)$ is a Nash equilibrium, since a teammate that switches alone lowers the payoff from $epsilon$ to $0$. Its value $epsilon$ is arbitrarily far below the TME value.
] <ex-team-coordination>

This is why we optimize over the team's strategy as a whole, as in @def-team-tme, rather than ask that each teammate best-respond. The price is that the TME problem is nonconvex, and @sec-team-hardness shows that it is hard to solve in general.

#let tcX = $tilde(cX)$

= Correlation and imperfect recall <sec-team-correlation>

We now drop the restriction of the TME that the teammates share no source of randomness. Before play they may flip coins that only they see. Formally, the team chooses a distribution $vmu$ over its _joint_ pure plans, and the adversary chooses a mixed strategy $vy$ as usual.

#definition[Team maxmin equilibrium with correlation #citep(<Celli18:Computational>, <Farina18:Ex>)][
  A _team maxmin equilibrium with correlation (TMECor)_ is a distribution $vmu$ over joint plans $(pi_1, pi_2) in Pi_1 times Pi_2$ that solves
  $
    max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in Delta(Pi_3)) EE_((pi_1, pi_2) ~ vmu) [u(pi_1, pi_2, vy)].
  $
] <def-team-tmecor>

The distribution $vmu$ in @def-team-tmecor plays the role of the correlation device of #lecture-link("correlated", <sec-ce>)[correlated equilibrium], restricted to the team. It samples a joint plan before play. Each teammate may see all of it, as long as the adversary does not. Here we optimize a jointly chosen team strategy, so we impose none of the incentive constraints that define correlated equilibrium.

== The one-time pad <sec-team-one-time-pad>

The team's optimal strategy is a _one-time pad_. Before play, Players 1 and 2 flip a shared fair coin. On heads, Player 1 sends the bit as it is, and on tails it sends the flipped bit. Coding heads and the left message as 0, the message is the bit XOR the coin. Player 2 knows the coin, so it undoes the flip and always guesses correctly. Player 3 does not know the coin, so to Player 3 the message carries no information about the bit, which is Shannon's _perfect secrecy_. Write $delta_pi$ for the point mass on a joint plan $pi$. In the coordinates $(a, b; c, d)$ of @fig-team-communication-game,
$
  vmu^* := 1/2 delta_((1, 0; 1, 0)) + 1/2 delta_((0, 1; 0, 1)).
$
The two joint plans are the heads and tails branches of the coin (@fig-team-one-time-pad).

#figure(
  caption: [The two joint plans of the one-time pad, each drawn with probability $1\/2$. Green edges are prescribed actions, dashed at Player 2 nodes the plan never reaches. Under either plan Player 2 guesses right. Player 3 sees the message but not the plan.],
)[
  #image(
    "figures/team_games_tmecor/one_time_pad.svg",
    width: 100%,
    alt: "The heads and tails joint plans of the one-time pad, drawn as two copies of the game tree with the prescribed actions highlighted.",
  )
] <fig-team-one-time-pad>

Since the message is independent of the bit, under $vmu^*$ Player 3 is right with probability $1\/2$ whatever it does, and the team gets $1\/2$ against every $vy$. Conversely, if Player 3 guesses uniformly at random, it is wrong with probability $1\/2$, so no team strategy, correlated or not, gets more than $1\/2$.

Hence the TMECor value is $1\/2$, twice the TME value $1\/4$ and equal to the min-max value. Each joint plan alone, by contrast, guarantees only $0$, since Player 2's guess is then a function of the message and Player 3 can copy it. The factor of $2$ is particular to this game. In other games the TMECor value can exceed the TME value by a factor linear in the number of leaves #citep(<Farina18:Ex>).

#figure(
  caption: [@ex-team-hats under the plan that guesses the other color on seeing two equal hats and passes otherwise. Dashed arrows are lines of sight, and ? marks the hat its wearer cannot see. With red, red, blue only teammate 3 guesses, correctly. With all red, everyone guesses wrong.],
)[
  #image(
    "figures/team_games_tmecor/hats_setup.svg",
    width: 92%,
    alt: "Three teammates in a circle wearing red or blue hats, in a winning and a losing assignment.",
  )
] <fig-team-hats>

#example[Three hats][
  An adversary puts a red or a blue hat on each of three teammates. Each sees the other two hats but not its own. All three act at the same time. Each guesses its own color or passes. The team gets $1$ if someone is right and nobody is wrong. This is Ebert's hat puzzle #citep(<Lenstra05:Hats>), except that an adversary places the hats instead of chance.

  A joint plan fixes in advance what each teammate does on each pair it might see, and the adversary knows the plan. A plan with no guesses never wins. If the plan has teammate 1 guess red on seeing two blue hats, the adversary puts blue on all three, and teammate 1 is wrong, so the team loses. Any guess on any pair can be punished this way, so every plan guarantees $0$.

  The plan "on seeing two equal hats, guess the other color, and otherwise pass" wins on $6$ of the $8$ assignments. It loses only on all red and all blue (@fig-team-hats). The adversary, however, picks a losing assignment.

  Shared randomness takes that choice away. Before play the teammates flip three independent fair coins, one per hat, unseen by the adversary. Each teammate swaps red and blue on every hat whose coin shows heads, applies the plan, and swaps its guess back if its own coin shows heads. The team wins exactly when the plan wins on the swapped hats. Each coin is a one-time pad that hides its hat's true color from the plan. So whatever the adversary chose, the swapped assignment is uniform over all $8$, and the team wins with probability $3\/4$. The adversary can no longer steer play to all red or all blue.

  The TMECor value is $3\/4$, since uniformly random hats hold every team strategy to $3\/4$. Without shared coins the TME value is exactly $1\/2$, reached when one teammate guesses at random and the others pass. @exr-team-hats proves both values.
] <ex-team-hats>

== Correlation restores the minimax theorem <sec-team-minimax>

With correlation, the team acts as a single player whose pure strategies are the joint plans $Pi_1 times Pi_2$ and whose mixed strategies are the distributions $vmu$. The TMECor problem is then a large two-player zero-sum normal-form game between this player and the adversary. Its objective is bilinear in $(vmu, vy)$, so the #lecture-link("learning_intro", <sec-learning-minimax>)[minimax theorem] holds and the maxmin value equals the min-max value (@tab-team-minimax).

#figure(
  kind: table,
  supplement: [Table],
  caption: [TME versus TMECor in the communication game.],
)[
  #table(
    stroke: none,
    columns: 5,
    align: center + horizon,
    inset: .7em,
    table.header([], [*Team strategies*], [*Value*], [*Optimization problem*], [*Minimax theorem*]),
    [TME], [$Delta(Pi_1) times Delta(Pi_2)$], [$1\/4$], [nonconvex program], [fails],
    [TMECor], [$Delta(Pi_1 times Pi_2)$], [$1\/2$], [bilinear saddle point], [holds],
  )
] <tab-team-minimax>

== Team games as imperfect-recall games <sec-team-imperfect-recall>

Equivalently, we can think of the two teammates as one player that happens to forget. In @fig-team-communication-game this amounts to drawing Player 2's nodes as nodes of Player 1. Each information set of Player 2 then joins nodes that the merged player reached after observing different bits, so the player forgets what it knew. A team game is thus a two-player zero-sum game in which each team becomes a single player, who in general has imperfect recall #citep(<Farina18:Ex>, <Zhang23:Team>). Strictly, the equivalence is with _timeable_ imperfect-recall games, in which every player always knows what time it is. @tab-team-dictionary translates between the two views.

The player forgets because a teammate cannot secretly share what it knows during play. Two colluding poker players who could secretly show each other their cards would merge into one player with perfect recall. Colluders who can signal only through their bets merge into a player who can forget. In @ex-team-hats, a teammate who could speak would announce another's hat, and the team would win surely, like one player seeing all three hats.

#figure(
  kind: table,
  supplement: [Table],
  caption: [Team games and two-player zero-sum games of imperfect recall. Uncorrelated team strategies correspond to behavioral strategies up to realization equivalence.],
)[
  #table(
    stroke: none,
    columns: 3,
    align: left + top,
    inset: .7em,
    table.header([*Team game*], [*Imperfect-recall game*], [*Communication game*]),
    [team], [player], [Players 1 and 2],
    [uncorrelated team strategy], [behavioral strategy], [$(a, b; c, d) in [0, 1]^4$],
    [correlated team strategy], [mixed strategy], [$vmu in Delta(Pi_1 times Pi_2)$],
    [TME], [optimal behavioral strategy], [e.g. $a = b = c = d = 1\/2$],
    [TMECor], [team's mixed Nash strategy], [$vmu^*$],
  )
] <tab-team-dictionary>

By the minimax theorem, a maxmin strategy of the team is exactly the team's part of a #lecture-link("correlated", <sec-zero-sum>)[mixed Nash equilibrium] of this game, so computing a TMECor amounts to computing a mixed Nash equilibrium of a two-player zero-sum game of imperfect recall. Every such equilibrium gives the team the TMECor value. Nash equilibria of the three-player game can leave the teammates miscoordinated (@ex-team-coordination), but here a joint deviation of the teammates is a unilateral deviation of the merged player.

#lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem] applies to each teammate, which has #lecture-link("efg_intro", <sec-perfect-recall>)[perfect recall], but not to the merged player, which lacks it. Its _behavioral_ and _mixed_ (normal-form) strategies therefore need not be realization-equivalent. A behavioral strategy randomizes independently at each information set, so it cannot make Player 2's guess depend on the coin behind Player 1's message. The one-time pad is therefore a mixed strategy that no behavioral strategy realizes (@ex-team-realization).

Team-PSRO #citep(<McAleer23:Team>), a team version of policy-space response oracles (PSRO), keeps a mixture over joint policies and samples one per play. Averaging each teammate's policies separately can lose the correlation. For the one-time pad the average is $(1\/2, 1\/2; 1\/2, 1\/2)$, which guarantees only $1\/4$.

= Realization form <sec-team-realization-form>

By @sec-team-minimax, a TMECor is a maxmin strategy of a two-player zero-sum game. The obstacle is size. The distribution $vmu$ has one coordinate per joint plan, and the number of joint plans can be exponential in the size of the game tree, the same blowup as in the #lecture-link("efg_intro", <sec-strategic-form>)[strategic form]. As with the sequence form, we record only what affects the payoff, namely which terminal nodes the team plays toward.

#definition[Team realization vectors #citep(<Farina18:Ex>, <Zhang23:Team>)][
  Let $Z$ be the set of terminal nodes. The _realization vector_ of a joint plan $(pi_1, pi_2) in Pi_1 times Pi_2$ is the vector $vx^(pi_1, pi_2) in {0, 1}^Z$ with $vx^(pi_1, pi_2)[z] = 1$ if and only if team ▲ plays all of its actions on the path from the root to $z$. The _realization polytope_ of the team is the convex hull of these vectors,
  $
    cX := conv(V), quad "where" quad V := {vx^(pi_1, pi_2) : (pi_1, pi_2) in Pi_1 times Pi_2} subset.eq {0, 1}^Z.
  $
] <def-team-realization>

The polytope $cY$ of team ▼ is defined in the same way. In @def-team-tmecor, team ▼ is Player 3 alone. From now on $vy$ denotes a point of $cY$ rather than a mixed strategy of team ▼. Different joint plans can have the same realization vector. In the communication game the 16 joint plans give only 12 vectors, because if Player 1 always sends the same message, Player 2's action after the other message is never used.

The _realization vector_ of a distribution $vmu in Delta(Pi_1 times Pi_2)$ is $vx^vmu := EE_((pi_1, pi_2) ~ vmu) [vx^(pi_1, pi_2)]$. Its entry $vx^vmu [z]$ is the probability that the team plays all its actions on the path to $z$, so the entries need not sum to $1$. The map $vmu |-> vx^vmu$ is linear and sends each point mass to its plan's realization vector, so it maps $Delta(Pi_1 times Pi_2)$ onto $conv(V) = cX$, the set of realization vectors of correlated team strategies. By Carathéodory's theorem, any point of $cX$ is realized by a $vmu$ on at most $abs(Z) + 1$ joint plans. Likewise, $cY$ is the image of the mixed strategies of team ▼.

#example[Realization vectors in the communication game][
  Number the leaves as in @fig-team-communication-game. If both teammates always play left ($a = b = c = d = 1$), the team plays all of its actions on the paths to $z_1$, $z_2$, and $z_4$ only, so its realization vector is $(1, 1, 0 #h(.4em) class("normal", bar.v) #h(.4em) 1, 0, 0 #h(.4em) class("normal", bar.v) #h(.4em) 0, 0, 0 #h(.4em) class("normal", bar.v) #h(.4em) 0, 0, 0)$. It has 12 entries, one per terminal node, instead of one per joint plan. Bars separate the three leaves below each Player 2 node. For a general uncorrelated team strategy in behavioral coordinates, and for Player 3,
  $
    vx(a, b; c, d) & = (a c, a c, a overline(c) #h(.4em) class("normal", bar.v) #h(.4em) b c, b overline(c), b overline(c) #h(.4em) class("normal", bar.v) #h(.4em) overline(a) d, overline(a) d, overline(a) overline(d) #h(.4em) class("normal", bar.v) #h(.4em) overline(b) d, overline(b) overline(d), overline(b) overline(d)), \
    vy & = (e, overline(e), 1 #h(.4em) class("normal", bar.v) #h(.4em) 1, e, overline(e) #h(.4em) class("normal", bar.v) #h(.4em) f, overline(f), 1 #h(.4em) class("normal", bar.v) #h(.4em) 1, f, overline(f)).
  $
  Each entry of $vx(a, b; c, d)$ is a product of one probability from each teammate, the same products that made the TME problem nonconvex. The one-time pad mixes the heads and tails plans, so its realization vector is
  $
    vx^(vmu^*) = 1/2 vx^((1, 0; 1, 0)) + 1/2 vx^((0, 1; 0, 1)) = (1/2, 1/2, 0 #h(.4em) class("normal", bar.v) #h(.4em) 0, 1/2, 1/2 #h(.4em) class("normal", bar.v) #h(.4em) 1/2, 1/2, 0 #h(.4em) class("normal", bar.v) #h(.4em) 0, 1/2, 1/2).
  $
  No behavioral strategy has this vector, since matching its first two blocks would need
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
    Pr[z "is reached"] & = p_"chance" (z) dot vx[z] dot vy[z], \
    EE[u] & = sum_(z in Z) p_"chance" (z) dot u(z) dot vx[z] dot vy[z] = vx^top U vy.
  $
  Both sides are linear in each team's distribution over pure plans, and the two distributions are independent, so the identity extends to $vmu$ and to mixed strategies of team ▼.
]

#theorem[TMECor as a saddle-point problem #citep(<Farina18:Ex>, <Zhang23:Team>)][
  The TMECor value equals $max_(vx in cX) min_(vy in cY) vx^top U vy$. A distribution $vmu$ is a TMECor if and only if $vx^vmu$ is a maxmin solution of this problem, and every maxmin solution is $vx^vmu$ for some TMECor $vmu$.
] <thm-team-bspp>
#proof[
  By @lem-team-utility, the objective of @def-team-tmecor at $vmu$ equals $min_(vy in cY) (vx^vmu)^top U vy$, since the minimum over mixed strategies $vnu$ of team ▼ equals the minimum over their realization vectors $cY$. As $vmu$ ranges over $Delta(Pi_1 times Pi_2)$, $vx^vmu$ ranges over all of $cX$, so
  $
    max_(vmu in Delta(Pi_1 times Pi_2)) min_(vnu in Delta(Pi_3)) EE_((pi_1, pi_2) ~ vmu) [u(pi_1, pi_2, vnu)]
    & = max_(vmu in Delta(Pi_1 times Pi_2)) min_(vy in cY) (vx^vmu)^top U vy \
    & = max_(vx in cX) min_(vy in cY) vx^top U vy.
  $
  Since the objective depends on $vmu$ only through $vx^vmu$, $vmu$ attains the maximum if and only if $vx^vmu$ does.
]

This #lecture-link("learning_intro", <sec-learning-zero-sum>)[saddle-point problem] adapts the sequence form to teams. When a team is a single player with perfect recall, the entry $vx[z]$ is the sequence-form entry of the player's last sequence on the path to $z$ (the empty sequence if the player does not act on that path). So $cX$ is a linear image of the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytope], and the problem above is the usual sequence-form maxmin problem composed with this linear map. For Player 3 in @ex-team-realization, this map sends the sequence-form vector $(1, e, overline(e), f, overline(f))$ to $vy$.

== Convexifying the TME <sec-team-convexification>

The TME can be written in the same form as @thm-team-bspp. Mixed strategies $vmu_1 in Delta(Pi_1)$ and $vmu_2 in Delta(Pi_2)$ of the two teammates induce the product distribution $vmu_1 times.o vmu_2$ on joint plans, a rank-one matrix in $RR^(Pi_1 times Pi_2)$, and
$
  tcX := {vx^(vmu_1 times.o vmu_2) : vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)} subset.eq cX
$
is the set of their _uncorrelated_ realization vectors, the vectors reachable without shared randomness. In the communication game every path meets one decision node of Player 1 and one information set of Player 2, so $tcX = {vx(a, b; c, d) : (a, b; c, d) in [0, 1]^4}$, using the vectors of @ex-team-realization. By that example the one-time pad lies in $cX without tcX$, although it is the midpoint of two points of $V subset.eq tcX$. So $tcX$ need not be convex (@fig-team-realization-sets).

#theorem[TMECor convexifies TME #citep(<Farina18:Ex>)][
  The TME value is $max_(vx in tcX) min_(vy in cY) vx^top U vy$ and the TMECor value is the same problem over $conv(tcX) = cX$.
] <thm-team-convexification>
#proof[
  The two values follow from @lem-team-utility and @thm-team-bspp. It remains to show $conv(tcX) = cX$. A joint plan is the product of two point masses, so $V subset.eq tcX$. A product distribution is a distribution on $Pi_1 times Pi_2$, so $tcX subset.eq cX$. Taking convex hulls, $cX = conv(V) subset.eq conv(tcX) subset.eq cX$.
]

#figure(
  caption: [Schematic of $V subset.eq tcX subset.eq cX subset.neq R$ in the communication game, not to scale. $R$ is the flow polytope of a team that never forgets (@sec-team-flow). Heads and tails span an edge of $cX$. Its midpoint, the one-time pad, is not in $tcX$, and neither is the midpoint of the opposite edge, between the two plans where Player 2 is always wrong.],
)[
  #image(
    "figures/team_games_tmecor/realization_sets.svg",
    width: 75%,
    alt: "Schematic of nested sets, not to scale. A hexagon spanned by points standing for joint plans, a nonconvex uncorrelated set inside it that bows inward from the heads-tails edge, the one-time pad marked at the midpoint of that edge, and a larger dashed relaxation with four extra corners.",
  )
] <fig-team-realization-sets>

Convexifying helps only against an adversary. Without one, the team's payoff is linear in $vx$, so some joint plan in $V subset.eq tcX$ is optimal and the TME and TMECor values coincide. Against an adversary the guarantee $min_(vy in cY) vx^top U vy$ is only concave, so its maximum over $cX$ can lie outside $tcX$.


== Beyond the sequence form <sec-team-sequence-form>

The problem of @thm-team-bspp looks like the sequence-form problem, but we have not yet said how to describe $cX$ efficiently. Products of the two teammates' sequence-form entries give only $tcX$, and optimizing over $tcX$ is the TME problem again (@thm-team-convexification). In the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form], each information set has exactly one parent sequence, and its flow constraint splits the mass of that sequence among the actions at the information set. In the communication game, viewed as one player, each information set of Player 2 has two parent sequences, one through each node of Player 1.

A natural guess is to keep the flow constraints of a team that does not forget, as if Player 2 saw the bit. In the communication game this gives a polytope $R$ that strictly contains $cX$, and four extra inequalities cut it down to $cX$ (@sec-team-flow). The companion notebook `content/notebooks/team_games_tmecor/communication_game.ipynb` checks the realization vectors, the game values, and the flow relaxation with exact arithmetic.

In general we should not expect a repair like these four inequalities. A polynomial-time procedure giving a polynomial-size linear description of $cX$ would, together with the sequence form for Player 3, let linear programming solve the saddle-point problem of @thm-team-bspp in polynomial time. Computing a TMECor is NP-hard by @thm-team-sat, so unless $"P" = "NP"$ no such procedure exists.


= Computational hardness <sec-team-hardness>

In a two-player zero-sum extensive-form game, the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form] gives a maxmin strategy by a linear program of polynomial size. For teams, finding the value is NP-hard, even without an adversary. The reason is that the team, viewed as one player, can forget (@sec-team-imperfect-recall) what one teammate knew when the other acts.
The reduction below is due to #citet(<Koller92:Complexity>), who phrased it as a single player with imperfect recall.


== The satisfiability reduction <sec-team-sat>

Let $phi = C_1 and dots.c and C_m$ be a formula in conjunctive normal form over the variables $x_1, ..., x_n$, where each clause $C_j$ is a disjunction of literals $x_i$ or $not x_i$. Build the following game $G_phi$ between Players 1 and 2 of team ▲, with no adversary (@fig-team-sat-reduction).

+ Chance picks a clause $C_j$ uniformly at random, and only Player 1 sees $j$.
+ Player 1 points to one literal $ell$ of $C_j$.
+ Player 2 sees only the variable $x_i$ of $ell$, not the clause and not whether $ell$ is $x_i$ or $not x_i$. It assigns $x_i$ true ($T$) or false ($F$).
+ The team gets $1$ if $ell$ is true under Player 2's assignment, and $0$ otherwise.

The nodes of Player 2 that see the same variable $x_i$ form one information set, so a pure plan $pi_2$ of Player 2 is exactly a truth assignment to $x_1, ..., x_n$. A pure plan $pi_1$ of Player 1 picks one literal from each clause. Each player acts once, so each has perfect recall. The game tree has one chance node, $m$ nodes of Player 1, one node of Player 2 per literal occurrence, and two leaves below each, so its size is linear in the size of $phi$.

#figure(
  caption: [The game $G_phi$ for $phi = (x_1 or x_2) and (not x_1 or x_2) and (x_1 or not x_2)$. Chance picks a clause uniformly, which only Player 1 sees. Player 1 points to a literal. Player 2 sees only its variable, so the three nodes in each shaded band form one information set. The two bands are drawn at different heights because their nodes alternate along the tree. Leaves show the team's payoff, which is $1$ when the literal is true. The assignment $x_1 = x_2 = T$ satisfies $phi$, and the team wins surely if Player 2 plays it and Player 1 points to $x_1$, $x_2$, and $x_1$.],
)[
  #image(
    "figures/team_games_tme/sat_reduction.svg",
    width: 90%,
    alt: "Game tree of the satisfiability reduction. Chance picks one of three clauses, Player 1 picks a literal of the clause, and Player 2 assigns its variable true or false. Player 2 nodes that see the same variable are joined by a shaded band.",
  )
] <fig-team-sat-reduction>

#lemma[Value of a joint plan][
  Under the joint plan $(pi_1, pi_2)$, the team's expected utility in $G_phi$ is the fraction of clauses $C_j$ whose literal $pi_1 (j)$ is true under the assignment $pi_2$.
] <lem-team-sat-plans>
#proof[
  Each clause is drawn with probability $1\/m$, and given clause $C_j$ the team gets $1$ exactly when the literal $pi_1 (j)$ is true under $pi_2$.
]

#theorem[Team games are hard #citep(<Koller92:Complexity>)][
  The team can win $G_phi$ with probability $1$ if and only if $phi$ is satisfiable. This holds both with and without correlation. Hence deciding whether the TME value, or the TMECor value, of a team game is $1$ is NP-hard, even when both teammates have perfect recall and there is no adversary.
] <thm-team-sat>
#proof[
  ($<==$) Let $alpha$ be an assignment that satisfies $phi$. Player 2 plays $pi_2 = alpha$, and in each clause Player 1 points to a literal that $alpha$ makes true. By @lem-team-sat-plans this pure, hence uncorrelated, joint plan wins with probability $1$.

  ($==>$) Suppose that a distribution $vmu$ over joint plans wins with probability $1$. Its value is the average of the values of the plans in its support, each at most $1$, so some plan $(pi_1, pi_2)$ wins with probability $1$. By @lem-team-sat-plans, the literal $pi_1 (j)$ is true under $pi_2$ for every clause $C_j$, so the assignment $pi_2$ satisfies $phi$. Uncorrelated strategies are a special case of distributions over joint plans, so the same holds for the TME.

  The game $G_phi$ has polynomial size, so a polynomial-time algorithm for either value would decide 3-SAT, which is NP-complete.
]

The merged team player sees the clause when it picks the literal, then forgets the clause when it assigns the variable. This forgetting is essential. If Player 2 also saw the clause, the team would be a single player with perfect recall, and it would win surely on every formula, by setting each variable to make the chosen literal true. Forcing Player 2 to answer the same way for a variable in every clause is what makes its plan a single, consistent truth assignment.

== Hardness of approximation <sec-team-sat-gap>

The reduction proves more than NP-hardness of deciding whether the value is $1$. Write $"OPT"(phi)$ for the largest fraction of the clauses of $phi$ that a single assignment satisfies.

#theorem[Hardness of approximation][
  The TME and TMECor values of $G_phi$ both equal $"OPT"(phi)$. Consequently, for every $0 < epsilon < 1\/16$ it is NP-hard to estimate the TME or TMECor value of a team game without an adversary to within an additive error of $1\/16 - epsilon$.
] <thm-team-sat-gap>
#proof[
  Without an adversary, the team's expected utility is linear in its distribution $vmu$ over joint plans, so it is maximized at a single joint plan. A joint plan is a pair of point masses, which is uncorrelated, so the TME and TMECor values coincide. For a fixed assignment $pi_2$, Player 1 best points to a true literal in every clause that has one. By @lem-team-sat-plans, the plan then wins on exactly the clauses that $pi_2$ satisfies. Maximizing over $pi_2$ gives $"OPT"(phi)$.

  #citet(<Hastad01:Some>) shows that for every $epsilon > 0$ it is NP-hard to distinguish formulas with three literals per clause that are satisfiable ($"OPT"(phi) = 1$) from those with $"OPT"(phi) <= 7\/8 + epsilon$. An estimate within $1\/16 - epsilon$ of the value is at least $15\/16 + epsilon$ in the satisfiable case and at most $15\/16$ in the other case, so it distinguishes them. The error must stay below half the gap $1\/8$, since the estimate may be off in either direction.
]

The gap $1\/8$ is the largest this reduction can give. A uniformly random assignment satisfies a clause with three distinct variables with probability $7\/8$, so $"OPT"(phi) >= 7\/8$ for such formulas. The hardness carries over to games with an adversary, by giving the adversary a single action. Hardness for teams is therefore a worst-case statement. The rest of the lecture identifies a parameter of the team's information structure that controls the cost of computing a TMECor.

== Teams against teams <sec-team-vs-team>

So far team ▼ has been a single adversary. When team ▼ is also a team of several players, the problem becomes harder than NP, in a precise sense. Recall that $Delta_2^P$ is the class of decision problems that a polynomial-time algorithm can solve with access to a SAT oracle, which answers any satisfiability question in one step. It contains both NP and coNP, and it is believed to be strictly larger than both.

#theorem[Teams against teams #citep(<Zhang23:Team>)][
  Deciding whether the TMECor value of a team game is at least a given threshold is $Delta_2^P$-complete when both teams have several players. When team ▼ is a single player, as in @sec-team-sat, the same problem is NP-complete #citep(<Koller92:Complexity>).
] <thm-team-delta2>

Both directions explain where the extra power of the SAT oracle goes. For membership, the TMECor value is the value of a linear program over distributions of joint plans. The ellipsoid method solves it with polynomially many calls to a separation oracle, and each call asks for a best response of team ▼. When team ▼ is itself a team, computing that best response is NP-hard by @thm-team-sat, so the SAT oracle, combined with binary search on the best-response value, answers it. For hardness, #citet(<Zhang23:Team>) reduce from a $Delta_2^P$-complete variant of satisfiability. Without correlation the problem is harder still. Deciding the TME value of a team-vs-team game is $Sigma_2^P$-complete #citep(<Zhang23:Team>), another sign that the TME lacks the structure that correlation brings.

= The team belief DAG <sec-team-belief-dag>

This section presents the team belief DAG construction, following slides
11--17 #citep(<Zhang26:TeamGames>); the construction is due to
#citet(<Zhang23:Team>).

== Setup

Since different players do not have access to the private observations of
teammates (communication is only allowed before play begins), treating
teammates as one merged player removes the notion of perfect recall. I.e.,
Player 1 does not have the same infoset as teammate player 2 at a given
decision point. Computing a TMECor is also hard, so we convert the original
game tree into a new construction: a *team belief DAG* (TB-DAG).

#bpar[The idea:] The two assumptions underlying TMECor are key to the TB-DAG
construction. Recall:

- *Known teammate strategies:* The plan is agreed in advance $==>$ any member
  can counterfactually reconstruct what a teammate would have done in any
  situation.
- *No in-play mixing:* Team members do not randomize beyond the distribution
  shared in advance.

Based on these assumptions, it is possible to construct a single-player
decision problem (like sequence form) by representing what is _common
knowledge_ for the team.

== The construction

Each game tree (left) is converted into its TB-DAG (right):

#figure(
  image("figures/team_belief_dag/construction.svg", width: 100%),
  caption: [A team game tree (left) and its team belief DAG (right).],
) <fig-tbdag-construction>

- *Left: the team game tree.* Chance moves first. The first team member acts
  at $A$ or $B$ and knows which (separate infosets). The second member acts at
  $C, D, E, F$ but cannot tell $C$ and $D$ apart (see dotted line to represent
  this).
- *Right: the TB-DAG.* The blue boxes represent decision points of the team,
  while the white boxes represent observation points. The root is labeled
  $A B$. After chance moves, only the acting team member knows whether play is
  at $A$ or $B$ --- the other members do not see anything. The DAG tracks the
  team instead of the individual player. For each decision-point level, an
  observation point level is added below it, alternating between the two.

#bpar[Decision points and belief:] A _belief_ is represented by the set of
tree nodes the team may have reached at that point in time given all past
public actions as common knowledge. At the root nothing public has happened
yet, so play could be at $A$ or $B$. Thus the root is labeled with belief
${A, B}$. If every team member saw all private actions, each belief set would
shrink to an ordinary infoset because a player would be able to distinguish
all decision points. The whole object would then collapse back to sequence
form $==>$ the TB-DAG strictly generalizes sequence form.

A belief can cover infosets of several different members, so "pick one
action" does not make sense here --- whose action would it be? Instead, the
team commits to something like an answer sheet: one action for every
situation it might be in:

#figure(
  image("figures/team_belief_dag/prescription.svg", width: 100%),
  caption: [Each edge out of ${A, B}$ is one answer sheet. Two infosets, two
    actions each $==>$ four sheets $==>$ four edges.],
) <fig-tbdag-prescription>

#bpar[Prescriptions: the edges out of a belief node.] A prescription, as
shown above, is a pre-determined singular action for each infoset that meets
the belief. Ex: ${A, B}$ meets two infosets with two actions each $==>$
$2 times 2 = 4$ prescriptions $==>$ $4$ edges. Each edge has a different
representation corresponding to the original game tree: the edge to $C D$
says "left at $A$, left at $B$," while the edge to $C F$ says "left at $A$,
right at $B$." etc. The child's label is just where those deterministic
choices can lead.

== Observation points and public observations

After the team commits to its answer sheet, others respond. An _observation
point_ is simply "where could we be now?" For example, if a team starts at
${A, B}$, with the sheet ($A -> C$, $B -> D$), play could be at $C$ or $D$,
which we denote in white with the observation point ${C, D}$.

#figure(
  image("figures/team_belief_dag/public_observation.svg", width: 100%),
  caption: [After ($A -> C$, $B -> D$): the mover cannot tell $C$ from $D$
    $==>$ ${C, D}$ stays one belief. After ($A -> C$, $B -> F$): everyone can
    tell $C$ from $F$ $==>$ split into ${C}$ and ${F}$.],
) <fig-tbdag-public-observation>

#bpar[The splitting rule (public observations):]

- The team only "observes" what becomes common knowledge, i.e. the public
  observation.
- Rule: As shown above, split the observation point into connected components
  under the infoset structure, s.t. each component becomes a new belief. Two
  nodes stay together if at least one member cannot tell them apart. Ex:
  ${C, D}$ does *not* split under the answer sheet above, while ${C, F}$
  does.

This splitting rule determines branching degree in the TB-DAG: observation
point $C D$ has one child because the team cannot distinguish between ${C}$
and ${D}$, while observation point $C F$ (distinguishable) has two --- the
beliefs ${C}$ and ${F}$.

Note that the splitting rule takes connected components, not pairs, because
of transitivity: if one member cannot distinguish $x$ from $y$ and another
cannot distinguish $y$ from $z$, no public signal can separate $x$ from $z$
$==>$ ${x, y, z}$ would stay as one belief.

== A DAG is enough

Why a DAG and not a tree? The answer is size constraints. Observe that the
same belief can be reached along different paths. For example, in the TB-DAG
above, the belief ${G}$ has two parents:

- Parent 1: belief ${C}$: the answer sheet leads to observation point $G$,
  which becomes the belief ${G}$;
- Parent 2: belief ${C, D}$: the answer sheet leads to observation point
  ${G, I}$, which splits since $G$ and $I$ are publicly distinguishable.

A full tree of histories would have two separate copies of ${G}$ as leaves,
greatly increasing its size. Merging is safe because the belief itself
represents the team's entire memory. Two histories ending in the same belief
look identical from there on: same possible positions, same answer sheets,
and same information structure. Separate copies contain information that only
individuals, but not the team, can act on, making them unnecessary for this
construction.

As such, the TB-DAG enables:

- *Solving the team game as a single-player problem:* the constructed
  player's memory is common knowledge that can be accessed by the entire team
  $==>$ there is perfect recall $==>$ the sequence-form machinery that fails
  on the merged team player applies to the TB-DAG. An optimal distribution
  over flows through the DAG _is_ a TMECor.
- *Decentralized execution of the joint plan:* Since the plan is agreed in
  advance, each member can privately simulate everything the team as a whole
  can deduce $==>$ during play, every member knows the current belief and
  which prescription applies without any communication during the game.

= Worked example: public information and shared randomness <sec-team-public-signal>

An adversary chooses two bits $(x,y)$. Alice sees $x$ and Bob sees $y$. Before either teammate acts, chance independently reveals $x$ to both with probability $r$. Write $s = x$ if the bit is revealed and $s = bot$ otherwise. Alice and Bob then choose bits $a$ and $b$ simultaneously. They win if $a xor b = x y$, where $xor$ denotes exclusive OR. The winning predicate comes from the classical CHSH game (#link("https://arxiv.org/abs/quant-ph/0404076")[Cleve, Høyer, Toner, and Watrous, §3.1]).

The adversary sees the committed team strategy before choosing $(x,y)$. It cannot see the teammates’ random draws. The teammates can sample their coins before play, independently of the inputs and the reveal. Let $v_"ind"(r)$ be the maximum worst-case win probability with independent private randomization, and let $v_"cor"(r)$ be the corresponding value when a shared random draw is also allowed.

#theorem[
  For every reveal probability $r in [0,1]$,
  $ v_"ind"(r) = (1+r)/2, quad v_"cor"(r) = (3+r)/4. $
]

== When the bit is hidden

Assume $r < 1$ so the hidden branch has positive probability.

*Independent strategies.* Write $u_x = EE[(-1)^a | x, s = bot]$, and $w_y = EE[(-1)^b | y, s = bot]$. Independence gives
$ Pr("win" | x,y,s=bot) = (1 + (-1)^(x y) u_x w_y)/2. $
If every input pair had win probability strictly greater than $1/2$, then $u_0 w_0$, $u_0 w_1$, and $u_1 w_0$ would be positive and $u_1 w_1$ would be negative. This is impossible: $(u_0 w_0)(u_1 w_1) = (u_0 w_1)(u_1 w_0)$. One input pair therefore holds the team to at most $1/2$. Alice can guarantee $1/2$ on every input by outputting a fair private coin.

#block(breakable: false)[
*Correlated strategies.* Fix a deterministic joint plan with outputs $a_0,a_1,b_0,b_1$. XORing the four winning equations gives $0=1$ because each output bit occurs twice, and only $(1,1)$ requires odd parity. Each plan thus wins on at most three inputs. Any mixture wins with probability at most $3/4$ under uniform inputs, so at least one input holds it to $3/4$ or less.
]

The team can meet the bound on *every* input. Choose a row of @tbl-parity-plans uniformly before playing. For any input pair, exactly one row loses.

#figure(
  table(
    columns: 3,
    align: center,
    table.header([Losing input $(x,y)$], [Alice's $(a_0,a_1)$], [Bob's $(b_0,b_1)$]),
    [$(0,0)$], [$(0,1)$], [$(1,0)$],
    [$(0,1)$], [$(0,0)$], [$(0,1)$],
    [$(1,0)$], [$(0,1)$], [$(0,0)$],
    [$(1,1)$], [$(0,0)$], [$(0,0)$],
  ),
  caption: [Four joint plans with different losing inputs.],
) <tbl-parity-plans>

== When the bit is revealed

On reveal, $a=0$ and $b=s y$ win surely. Since every input has the same reveal probability, the input witnessing the hidden-branch upper bound gives an overall upper bound of $r$ plus $(1-r)$ times that bound. The stated strategies attain it on every input. At $r=1$, both values are $1$ directly.

In team belief DAG terms, the null signal leads to a belief containing all four input pairs. A revealed bit leads to a belief containing the two pairs with that first bit. The team's prescription then maps Bob's private input $y$ to $s y$. Shared randomness instead selects a joint prescription without narrowing the set of possible inputs. The resulting value gap is $(1-r)/4$.

= Information asymmetry <sec-team-information-asymmetry>

The team belief DAG (TB-DAG) represents a team's coordinated strategies without listing all of its pure joint plans. Its usefulness depends on how large this representation becomes. Following slides 18--21 #citep(<Zhang26:TeamGames>), we bound its size by counting the possibilities within each public state. The key parameter is the amount of information that individual teammates possess but that is not common knowledge within the team.

Recall that a decision point contains a belief $B$, a set of possible game-tree nodes. A prescription specifies an action at each information set intersecting $B$. Applying that prescription produces an observation point; a subsequent public observation determines the next decision point. A public state groups histories that cannot be separated using the team's common knowledge. In particular, a public state may contain several beliefs, because past prescriptions can rule out different histories.

== Branching factor and last-infosets

Work in a finite, timeable, two-team zero-sum game with individual perfect recall. Timeability assigns equal times within each information set and increasing times along paths. Let $N$ be the tree size and $b$ its maximum branching factor; every information set then has at most $b$ actions.

To identify the information still relevant at a public state, consider the team as one merged player. An information set $J$ _remembers_ $I$ when every history in $J$ passes through $I$ and takes the same action there. At a history $h$, retain the information sets visited along $h$ that no later visited information set remembers; call these $"LI"(h)$, the _last-infosets_. They include the current information set when the team acts at $h$.

#block(breakable: false)[
#definition[Information asymmetry][
  For a public state $P$, let
  $
    cal(L)(P) := union_(h in P) "LI"(h), quad
    k_P := |cal(L)(P)|, quad
    k := max_P k_P.
  $
  The parameter $k$ is the team's _information asymmetry_ (also called information complexity). For two teams, take the maximum over both teams' public states.
] <def-team-information-asymmetry>
]

This definition follows Carminati et al. #citep(<Carminati26:Representations>). The union over histories matters: $k$ is not the number of teammates, nor the number of last-infosets on one realized path. One teammate can have many possible private observations within the same public state, each giving a different last-infoset. Perfect recall removes older information sets remembered by that teammate's latest information set, but it does not make their private information public to the team.

At the symmetric-information extreme $k=1$, the team can be represented by a single perfect-recall player. There is then no collection of distinct private information sets on which a coordinator must simultaneously prescribe actions. Larger $k$ allows more such contingencies, even if the number of teammates stays fixed.

== Counting observation points

Fix a public state $P$ and a pure joint team plan $pi$. For each $J in cal(L)(P)$, record one of the following:

- $⊥$: no history in $J$ is consistent with $pi$;
- $a in A_J$: $pi$ is consistent with some history in $J$ and prescribes action $a$ there.

Here all teammates' actions are fixed by $pi$; opponent and chance choices may vary over the game tree. Thus reachability is with respect to the merged team player, not one teammate in isolation. It does not mean that $J$ occurs in every play or against every opponent strategy.

The resulting vector is a _signature_ of the plan at $P$. Each coordinate has at most $b+1$ possibilities, so
$
  "number of signatures at" P
    <= product_(J in cal(L)(P)) (|A_J|+1)
    <= (b+1)^(k_P)
    <= (b+1)^k.
$

Why does this count help? The reachability entries retain which histories are compatible with the team's choices. The action entries also specify the current prescription. Information sets omitted from the list are remembered by retained ones, so their relevant past actions need not be encoded again. Thus we count the decision-point/prescription possibilities together, instead of independently counting beliefs and then multiplying by all possible prescriptions.

#example[
  Suppose a public state has three last-infosets and each has actions $L$ and $R$. There are at most $3^3=27$ signatures. For example, $(⊥,L,R)$ says that the first information set is excluded by the joint team plan, while the other two prescribe $L$ and $R$. This is an upper bound: some signatures may violate the game's reachability constraints, and different signatures need not create different DAG nodes. If all three information sets must be reachable under every plan, only the $2^3=8$ action-only signatures remain.
]

#figure(
  image("figures/team_games/last_infoset_signature.svg", width: 100%),
  caption: [Encoding a plan at a public state with $k_P=3$ and $b=2$. Each last-infoset contributes $⊥$, $L$, or $R$; the highlighted choices give $(⊥,L,R)$. These are encoding choices, not branches of a game tree. Some combinations may be infeasible, so $27$ is an upper bound.],
) <fig-team-last-infoset-signature>

The lecture's $(b+1)^k$ bound captures this combinatorial part of the observation-point count. In a construction that further separates compatible histories into public-observation components, one signature may generate several disjoint components. Accounting for their incident edges gives the more explicit bound
$
  E <= N (b+1)^(k+1)
      = (b+1)^k dot N(b+1),
$
where $E$ is the number of TB-DAG edges; see Theorem 6.2 of Carminati et al. #citep(<Carminati26:Representations>). In either convention, the exponential dependence is on $k$, with only a polynomial factor in the original tree size.

== Consequences for regret minimization

The TB-DAG supports regret minimization directly #citep(<Zhang23:Team>). A CFR iteration propagates values through the DAG and updates local regrets, with work proportional to its representation size. Consequently, the size bound gives
$
  "time per CFR iteration"
    = O(N(b+1)^(k+1))
    = (b+1)^k "poly"(N).
$
For two teams, the iteration visits both representations; using their maximum $k$ gives the same asymptotic bound. Three consequences clarify the guarantee.

First, *constant information asymmetry gives polynomial per-iteration time*. Since $b <= N$, fixing $k$ makes the displayed expression polynomial in $N$. The exponent of that polynomial can nevertheless depend on $k$.

Second, *the representation may still be large*. Even with binary actions, the counting term is $3^k$. The bound is useful when information asymmetry is small relative to the game, not merely when the team has few members.

Third, *this is a per-iteration bound*. Running $T$ CFR iterations costs $O(T N(b+1)^(k+1))$, apart from constructing the representation. The accuracy of the averaged strategies depends on the regret accumulated over those iterations. The size bound alone does not specify how many iterations achieve a requested approximation error, and one iteration does not compute an exact equilibrium.

== How much improvement should we expect?

Slide 21 uses bridge to illustrate the scale of the savings. Its rough estimates are $N approx 2^200$, $b < 2^6$, and $k approx binom(52,13) < 2^40$. Plugging these estimates into the counting term yields
$
  (b+1)^k <= 2^(6k) < 2^(6 dot 2^40).
$
This is much smaller than the slide's naive normal-form estimate of roughly $2^(2^200)$, even after allowing polynomial overhead in $N$. Both quantities remain enormous. The comparison demonstrates the benefit of organizing computation around private-information contingencies; it is not a practical running-time prediction for solving bridge.

Finally, could we replace the dependence on $b$ and $k$ by $2^(O(k)) "poly"(N)$ in general? The lecture rules this out assuming $"FPT" != "W[1]"$, a standard parameterized-complexity assumption weaker than the Exponential Time Hypothesis. Even the exact mixed-strategy value problem for one imperfect-recall player admits no $f(k) "poly"(N)$ algorithm under that assumption #citep(<Carminati26:Representations>). There is no contradiction with the constant-$k$ guarantee: in $N(b+1)^(k+1)$ the exponent of $N$ may grow with $k$, whereas the exponent in $f(k) "poly"(N)$ must be independent of $k$. Extra structure can still make particular game families easier.

= Hidden-role games <sec-hidden-role-games>

#definition[
  A _hidden-role game_ is a finite extensive-form game $Gamma$ with $n$ players that satisfies the following properties:

  + *Initial assignment by chance.* At the root, only chance has a nontrivial action set. Chance draws a team-assignment vector

    $ cal(D) in Delta({"MAX", "MIN"}^n), quad t = (t_1, dots, t_n) tilde cal(D). $

    Here $t_i$ denotes the team of player $i$.

  + *Asymmetric information about teams.* Each player $i$ privately observes at least $t_i$. Every player assigned to MIN also privately observes the entire vector $t$. MAX players may have additional information, but full team membership need not be known to them.

  + *Team-dependent, opposing utilities.* There exists a common terminal payoff function $u: Z arrow RR$ such that, at every terminal history $z in Z$,

    $ u_i(z) = cases(u(z) & "if" t_i = "MAX", -u(z) & "if" t_i = "MIN".) $
] <def-hidden-role-games>

The game is _zero-sum between teams_: the teams have opposed objectives. If their sizes differ, the sum of all *individual* payoffs need not be zero and a suitable rescaling would need to be applied.

A _team assignment_ states whether a player belongs to MAX or MIN. A _role_ may also specify additional private information or legally available actions. For example, Merlin in _Avalon_ is a MAX player who observes more than an ordinary MAX player. Information can also be revealed later in the game. The formal definition permits some MAX players to know additional teammates' identities; the interesting hidden-role case is when MAX cannot simply identify its team from the outset.

Communication is central to this setting, but is *not itself a required action in the base game*. #cite(<CarminatiZFGS24>) studies distinct _communication extensions_: no communication, public broadcast communication, and public plus pairwise private communication. In the latter two cases, players communicate through actions explicitly added to the game tree. A MAX player may be unsure whether a sender or recipient is an ally, so MIN can strategically exploit messages and trust.

Social deduction games such as _Avalon_ are natural examples. Similar information structures arise in distributed systems, network security, and federated learning: a collection of participants attempts to cooperate without being certain that everyone involved is trustworthy.

Our goal is to identify an appropriate notion of optimal play for team MAX. The obstacle is that the team's objective is collective, whereas its members are not initially able to identify one another.

= Why existing solution concepts fall short <sec-hidden-role-solution-concepts>

== Nash equilibrium

Recall that a Nash equilibrium is a strategy profile in which no player can increase their expected utility by changing their strategy unilaterally. If $vx^* = (x_1^*, dots, x_n^*)$ is a Nash equilibrium, then

$ u_i(x_i^*, vx_(-i)^*) >= u_i(x_i', vx_(-i)^*) quad "for all" i, x_i'. $

This condition is *individual*: it compares the status quo with a change by just one player, holding everyone else fixed. In a team game, however, two teammates may need to change their behavior together to achieve a higher common payoff, even if neither has an individually profitable deviation. Hence, Nash equilibria can be poor outcomes for the team, as in the communication-game example earlier in this lecture.

The problem becomes especially pronounced if there is just one team: we would like a solution concept to identify a *jointly optimal* team strategy, not merely a profile immune to unilateral changes.

== Team-correlated equilibrium

Recall the team maxmin equilibrium with correlation (TMECor) from @sec-team-correlation. For a team of Players 1 and 2 facing Player 3, the correlated team chooses a joint distribution $mu$ over its members' pure strategies:

$ max_(mu in Delta(Pi_1 times Pi_2)) min_(y in Delta(Pi_3)) sum_((x_1, x_2) in Pi_1 times Pi_2) mu(x_1, x_2) u(x_1, x_2, y). $

Correlation is useful because teammates can agree on a joint plan, including the outcomes of shared random coins, before play begins. But this presupposes that they *know who their teammates are*. In hidden-role games, the MAX players cannot generally, at the outset, securely identify their partners for such coordination. Granting them an arbitrary team-private correlation device among the actual MAX members would therefore assume away the central difficulty of the game. Communication during play may still create coordination, but it must be represented as actions within the game.

Thus neither ordinary Nash equilibrium nor a conventional correlated team equilibrium captures the intended form of team optimization under hidden membership. We need a new solution concept.

= The split-personality construction <sec-split-personality>

The idea is to introduce two _role-specific personalities_ for every physical player. We first describe the *uncoordinated split-personality form*, which is the $2n$-player transformation of the $n$-player hidden-role game.

#definition[
  Given an $n$-player hidden-role game $Gamma$, the _uncoordinated split-personality game_ $"USplit"(Gamma)$ replaces every original player $i$ with two players $i^+$ and $i^-$, controlling $i$'s actions when their realized team is MAX and MIN respectively. The resulting adversarial team game has $2n$ players:

  $ N_"MAX" = {1^+, dots, n^+}, quad N_"MIN" = {1^-, dots, n^-}. $
] <def-split-personality>

For example, physical Player 1 is represented by MAX-P1 and MIN-P1. Exactly one personality controls the physical player's moves, depending on the chance-selected team assignment. This is a *strategic representation*, not a public announcement of that assignment: both personalities act through the identity of the same physical player. In particular, messages are attributed to physical Player 1, and observers do not learn which personality generated them.

#cite(<CarminatiZFGS24>) also considers a _coordinated split-personality form_, $"CSplit"(Gamma)$: all MIN personalities are merged into a single adversary who receives all their observations and chooses all their actions. The resulting game has $n+1$ players. This is a stronger model of the adversary, not a property implied by hidden roles alone.

For either form, MAX's teammates are not granted an arbitrary correlation device before team assignment. We instead use the uncorrelated team max-min solution concept developed earlier in the lecture.

= Hidden-role equilibrium and commitment <sec-hidden-role-equilibrium>

#definition[
  For a fixed communication-extended split-personality game, a _team max-min equilibrium_ (TME) is a MAX strategy profile that maximizes MAX's expected utility against a best-responding MIN team, with each team's strategy space restricted to *uncorrelated* profiles of individual mixed strategies. A _hidden-role equilibrium_ (HRE) is defined using this TME construction; formally, #cite(<CarminatiZFGS24>) specifies the communication model, whether MIN is uncoordinated or coordinated, and an approximation tolerance when communication is allowed.
] <def-hidden-role-equilibrium>

Let $vx = (x_1^+, dots, x_n^+)$ and $vy = (y_1^-, dots, y_n^-)$ be uncorrelated strategy profiles for the MAX and MIN personalities. For the uncoordinated split-personality game *without added communication*, the TME value is

$ "TMEVal"("USplit"(Gamma)) = max_(vx in product_(i=1)^n Delta(Pi_i^+)) min_(vy in product_(i=1)^n Delta(Pi_i^-)) u(vx, vy). $

Here $Pi_i^+$ and $Pi_i^-$ denote the sets of pure strategies for the corresponding role-specific players; the expectation over the random team assignment and subsequent play is included in $u(vx, vy)$. Here the product symbols describe independent strategy choices by the individual personalities, *not* arbitrary correlated team distributions. An optimal MAX strategy profile attains the outer maximum for this fixed finite game.

The *commitment interpretation* is that MAX fixes a collection of role-contingent strategies first. MIN then chooses a best response *knowing the entire MAX strategy*. MAX does not first discover who its teammates are: each physical player follows its MAX-personality policy if assigned to MAX.

#remark[
  *Communication-dependent values and equilibria.* #cite(<CarminatiZFGS24>)'s Definitions 3.5--3.6 distinguish $c in {"none", "pub", "priv"}$ and uncoordinated versus coordinated MIN. For finite message-space size $M$ and $R$ communication rounds between moves, define

  $ "UVal"_c^(M,R)(Gamma) = "TMEVal"("USplit"("Comm"_c^(M,R)(Gamma))). $

  The uncoordinated value with communication type $c$ is

  $ "UVal"_c(Gamma) = sup_(M,R) "UVal"_c^(M,R)(Gamma). $

  The coordinated counterpart substitutes $"CSplit"$ and is denoted $"CVal"_c(Gamma)$. An $epsilon$-uncoordinated HRE is a tuple $(M,R,vx)$: the MAX strategy profile $vx$ in the relevant communication-extended USplit game guarantees a value at least $"UVal"_c(Gamma) - epsilon$. The coordinated definition uses CSplit and CVal instead. Thus, allowing communication entails optimizing not only the strategy but also the communication parameters. For $c = "none"$, the communication extension is just the base game.
]

== Why can we not exchange max and min?

For two-player zero-sum games with convex compact strategy sets and bilinear payoffs, the minimax theorem guarantees

$ max_(vx) min_(vy) u(vx, vy) = min_(vy) max_(vx) u(vx, vy). $

The hidden-role construction does *not* generally inherit these hypotheses. While each individual personality may randomize, a team is restricted to products of independent mixed strategies. The set of resulting joint distributions is generally nonconvex, and expected utility is multilinear rather than bilinear in the separate team members' strategies. Thus the standard minimax theorem cannot be invoked, and we cannot conclude that

$ max_(vx) min_(vy) u(vx, vy) = min_(vy) max_(vx) u(vx, vy). $

Accordingly, hidden-role equilibrium is *inherently asymmetric*: the MAX-first commitment interpretation is part of the concept, rather than an arbitrary reordering of a saddle-point problem.

In fact, reversing commitment order would let MAX coordinate on a secret, sufficiently long random passphrase that MIN has not learned, which can reveal who is on which team. This motivates why MIN is allowed to know MAX's committed strategy first, not conversely. We state this observation as motivation (see Section 6.2 of #cite(<CarminatiZFGS24>) for details).

= Discussion <sec-hidden-role-discussion>

Hidden-role games force us to revisit the assumptions underlying familiar equilibrium concepts. Nash equilibrium does not optimize coordination within teams; team correlation presumes that teammates can identify each other before play. The split-personality construction instead represents every possible role of every player explicitly, and defines hidden-role equilibrium through team MAX's uncorrelated commitment against MIN.

The main lesson is that *uncertainty about who is on one's team changes the equilibrium problem itself*. It is not simply another uncertainty that can be handled by assuming a shared correlation device or appealing to the usual minimax theorem.

= An election example <sec-l12-election-example>

The previous section defined a hidden-role equilibrium through the _split-personality game_: each physical player has a Good copy and a Bad copy, and the Good copies choose an optimal uncorrelated strategy. Before the roles are dealt, a player does not yet know who their teammates will be, so the Good team cannot arrange team-private shared randomness. The election game below, adapted from #citep(<CarminatiZFGS24>), shows why this matters. With two identical Good cards, Good wins with probability at most $2/3$. Merely labeling the cards Good and Good' raises the value to $1$, even though the labels never affect the payoffs.


#example[A three-player election][
  #wrapped-figure(side: right, text-width: 58%)[
    There are three players, labeled $1, 2, 3$, and three role cards. Two of the cards are marked Good and one is marked Bad. The cards are shuffled and dealt privately, so the Bad card is equally likely to sit at any of the three seats. After a round of public communication, the three players vote simultaneously for a winner. If some player receives at least two votes, that player is elected and that player's team wins. If no player receives a majority, the Bad player wins by default.

    Payoffs are $0$--$1$: the Good team receives $1$ if a Good player is elected and $0$ otherwise. Communication is public, and the Good team cannot correlate using team-private randomness before the cards are dealt.
  ][
    #image(
      "figures/team_games/election_setup.svg",
      width: 168pt,
      alt: "Players 1, 2, and 3 sit at the vertices of a triangle. Beside them are two identical blue Good cards and one red Bad card, dealt privately.",
    )
  ]
]

Good occupies two of the three seats, but neither Good player knows which of the other two players is their teammate. Bad also hears every public message.

#theorem[Value of the indistinguishable-role election][
  In the election game with indistinguishable Good roles, the hidden-role value for the Good team is exactly $2/3$.
] <prop-l12-value-two-thirds>

#proof[
  *Lower bound.* Have both Good players ignore the discussion and vote for player $1$. Their two votes elect player $1$ regardless of Bad's vote. Since the Bad card is equally likely to be in any seat, player $1$ is Good with probability $2/3$. Thus Good can guarantee $2/3$.

  *Upper bound.* Fix any strategy for the Good team. Bad can pretend to have received a Good card: at seat $j$, Bad sends the same messages and casts the same votes that the Good strategy prescribes at seat $j$, using fresh private randomness when needed.

  When Bad plays this way, every seat behaves as if it held a Good card. The public transcript and the votes therefore reveal nothing about which seat is Bad. Let $B$ be the Bad seat, and let $W in {1, 2, 3} union {bot}$ be the election result, where $W = bot$ means that nobody receives a majority. Then $B$ is uniform on ${1, 2, 3}$ and independent of $W$.

  Good loses when $W = bot$. If $W = i$, Good wins exactly when $i != B$, an event of probability $2/3$. Hence no Good strategy can win with probability greater than $2/3$. Together with the lower bound, this proves that the value is $2/3$.
]

The #interactive-link("hidden_role_election")[hidden-role election explorer] lets you play from a randomly assigned seat. With identical Good cards, the simulation approaches the $2/3$ value above.

== Distinguishable Good roles

Now change only the labels on the cards: one Good card says Good, and the other says Good'. The voting rule, communication channel, and payoffs stay the same. In particular, electing either Good role is a win for Good.

#figure(
  image(
    "figures/team_games/election_strategy.svg",
    width: 100%,
    alt: "Three panels. If Bad copies Good, the unique Good-prime announcement is elected. If Bad copies Good-prime, the unique Good announcement is elected. If Bad says anything else, either remaining Good player is elected.",
  ),
  caption: [Honest announcements of Good and Good'. A green ring marks a player the Good team can safely elect.],
) <fig-l12-election-strategy>

#theorem[Deterministic win from distinguishable roles][
  In the election game with distinguishable Good roles, the Good team has a strategy, using only public communication, that wins with probability $1$.
] <prop-l12-distinguishable-win>

#proof[
  Each Good player publicly announces the label on their card. Once all three announcements are known, let $S$ be the set of players who said either Good or Good'. The Good players use the following rule:

  - If somebody says neither Good nor Good', vote for the lowest-index player in $S$.
  - If two players say Good, vote for the player who says Good'.
  - If two players say Good', vote for the player who says Good.

  Both Good players see the same announcements, so they cast the same vote. It remains to check that their chosen player is Good. The three possibilities are shown in @fig-l12-election-strategy. If Bad copies Good, the unique Good' claim comes from the real Good' player. If Bad copies Good', the unique Good claim comes from the real Good player. If Bad says something else, both players in $S$ are Good. Thus the two Good votes always elect a Good player.
]

Bad has no useful announcement: saying Good elects Good', saying Good' elects Good, and saying anything else reveals which player is Bad. In the explorer, switch to labeled Good cards and try each claim when you are dealt Bad.

#remark[Implicit correlation][
  Why can a payoff-irrelevant label change the value from $2/3$ to $1$? The labels provide _correlated randomness_.

  The two Good players receive opposite labels: exactly one is Good and the other is Good'. Equivalently, the deal gives them a random permutation of the two labels. Their private observations are therefore perfectly negatively correlated. Bad may copy either label, but cannot make both labels appear twice.

  A hidden-role equilibrium does not otherwise give the Good team a shared private coin before roles are assigned. Doing so would amount to team-private correlation, as in TMECor rather than TME. It would also undermine the hidden-role setting: Good players could authenticate one another using a sufficiently long shared random string. The labeled cards provide a much smaller piece of correlation through the role assignment itself, and that is already enough to solve this election.

  This also explains a feature of Avalon discussed later in the lecture. A game with Merlin and two Mordreds is not simply Resistance followed by an independent $1/3$ chance of identifying Merlin: the distinguishable Merlin card gives the Good team implicit correlation.
]

#let custom-thm(
  title: "Theorem",
  number: none,        // e.g., "1.2", "A", or none for unnumbered
  name: none,          // e.g., "Pythagoras"
  color: blue,         // accent color for border & header
  fill: black,
  body,
) = block(
  fill: color.lighten(90%),
  stroke: (left: 3pt + color),
  inset: (left: 1em, rest: 0.8em),
  radius: 4pt,
  width: 100%,
  {
    // Build the header line
    let header = {
      set text(weight: "bold", fill: color.darken(20%))
      title
      if number != none {
        [ ]
        number
      }
      if name != none {
        [ (]
        name
        [)]
      }
      [.]
    }
    header
    body
  }
)
#let star = $""^ast$
#let val(a, cmp, b, c, marked: false) = box[$#a #h(0.14em) #sym.slash #h(0.14em) #b #cmp #c #h(0.05em) #(if marked { star })$]
= Computation of Hidden-Role Equilibria
== Results Overview

Given three reasonable and common assumptions, it becomes possible to compute hidden-role equilibria efficiently! The criteria are:

+ *Private communication* between any pair of players, which can be implemented e.g. by public-key encryption (still viable as of Nov. 2026)
+ "Bad" team is a *minority* (reasonable in many games where e.g. majority voting is involved)
+ "Bad" team can *coordinate* (i.e. know each other's identities, can share randomness, etc.)

Assuming no collapse of computational complexity classes, private communication and coordination are both necessary for efficient computation. Whether "Bad" team minority is required is still open. As found in #cite(<Carminati2023HRG>), here is a table of the state of the art knowledge of computational complexity in hidden-role equilibria:
#figure(
table(
  columns: 4,
  stroke: 0.5pt,
  align: center + horizon,

  // Header
  [*Adversary Team Assumptions*],
  table.cell(colspan: 3)[*Communication Type*],

  [],
  [*None*],
  [*Public*],
  [*Private*],

  // Coordinated rows
  [*Coordinated, Minority*],
  table.cell(rowspan: 2)[NP-complete],
  table.cell(rowspan: 2)[NP-hard],
  [P],

  [*Coordinated*],
  [_open_],

  // Uncoordinated rows
  [*Minority*],
  table.cell(rowspan: 2)[$Sigma_2^P$-complete],
  table.cell(rowspan: 2)[$Sigma_2^P$-hard],
  table.cell(rowspan: 2)[coNP-hard],

  [*None*],
),
caption: [
    Complexity results for computing hidden-role value with a constant number of players, for various assumptions about the adversary team and notions of communication.
  ]
)

Let us now sketch a proof of this theorem, more directly stated as follows:
#custom-thm(
  title: "Theorem",
  number: "12.Y",
  name: "Efficient Hidden-Role Equilibria",
)[
  Consider a hidden-role game $Gamma$ with $n$ players, $k$ of which are on the bad team. All players can communicate pairwise privately and all the bad players can be coordinated as if they were a single player. If $k < n\/2$, then there exists a poly-time $epsilon$-approximation of the hidden-role equilibrium for the good players.
]

== Proof Sketch using a Mediated-Hidden-Role Game

We introduce a slight variant of the hidden-role game which introduces a *mediator* player on the "Good" team. This player is known to be good but does not know the "goodness" of the players in the game, and all players are free to interface with this player with the same private bidirectional communications as between normal players. Clearly this game $Gamma'$ is strictly better for the "Good" team and thus has an equilibrium value at least that of $Gamma$; the challenge will be to prove that this game $Gamma'$ has an efficiently computable equilibrium strategy that is actually also playable in $Gamma$, which ultimately proves that it is a hidden-role equilibrium strategy for $Gamma$ as well.

In other words, there remain three more pieces to this proof that we will provide high-level sketches for:

+ A description of the mediator-good player interface to reduce to a two-player zero-sum game
+ Explaining why this mediator interface isn't exploitable (i.e. the equilibrium value of the zero-sum game is at least that of the mediated hidden-role game)
+ Explaining how to simulate this mediator in the original hidden-role game setting, deriving a hidden-role equilibrium for $Gamma$.

#custom-thm(
  title: "Key Idea",
  number: "1",
  name: "Mediator Interface",
  color: green
)[
  In a mediated hidden-role game, we will have the mediator take on the role of simulating all of the strategies. In other words, the good players and mediator agree on the following scheme:
  + The good players privately communicate all observed info to the mediator
  + The mediator sends out actions to all actors
  + All good players execute actions as issued by the mediator
]

With this interface, only the mediator makes any decisions; the "good" players simply report their observations to the mediator and follow its instructions. In other words, this is our "reduction" of the mediated hidden-role game into a two-player zero-sum game, as all good player strategic decision-making is subsumed into the mediator and all bad player decision-making was coordinated to begin with and thus can also be subsumed into the decisions of one actor.

An extension: bad players can (and in a sense "should", to be as "confusing" as possible) send observations to the mediator, they just aren't obligated to be truthful. Moreover, they receive actions from the mediator, as the mediator may not know if they are bad. In other words; bad players send potentially misleading info in step 1, receive potentially useful info in step 3.
#custom-thm(
  title: "Key Idea",
  number: "2",
  name: "Mediator optimality",
  color: green
)[
  We can simulate any strategy $x$ in the mediated game with the interface in Key Idea 1(call the simulated strategy $x'$), such that we do at least as good as the worst-case strategy against $x$. Moreover, if $x$ is any hidden-role equilibrium of $Gamma'$, then our simulated strategy $x'$ must also be a hidden-role equilibrium of $Gamma'$.
]

_Proof Sketch._ For any strategy $x$; all observations can be forwarded to the mediator, and then the individual players can just be internally simulated within the mediator, including any communications with one another, and then actions can be issued to the players themselves; this is our strategy $x'$. Now consider any best-response to $x'$, call this $y'$; we can turn $y'$ into a (possibly suboptimal) way of playing against $x$ by filling in the "virtual" interactions in a strategy $y^*$.

In other words, we use $x, y'$ to simulate a  $(x,y^*)$ that is equivalent to $(x', y')$:

For each bad player in $y^*$ simulate your "bad" best-response _actor_ $y'$ and your "good" response _communicator_ $x$. Let the simulated $x$ communicate with the $y'$ info but otherwise act like an $x$(basically act like a "misled" good actor communications wise), but the actions from your $y'$ determine your actual actions from your $y^*$. The communications between $x$ and $y^*$ are the same as the ones internally simulated in the mediator and the actions of $x$ the simulated ones with the same info as $x'$, and similarly the actions of $y^*$ are the same actions simulated in $y'$. This is illustrated much more clearly in the figures below:

#figure(image("figures/mediator-hidden-role/6.7980_L12_P9_F1.svg", width:100%), caption: [Anatomy of $y'$ best response to $x'$. Note that y' can still essentially "zombify" $x_i$ to potentially send deceptive messages within the mediator simulation.]) <fig-team-mediator-simulation>

#figure(image("figures/mediator-hidden-role/6.7980_L12_P9_F2.svg", width:100%), caption: [Anatomy of $y^*$ response to $x$. Note that internal functionality is exactly the same as in @fig-team-mediator-simulation, so the distribution over the outcomes in $Gamma$ are the same, so the expected utility is the same as well.])

As the utility from $(x',y')$ is the same as the utility from $(x, y^*)$, if we base $x'$ off of $x_"OPT" $ then we create an $(x',y')$ that is equal to $(x_"OPT" , y^*)$, which is in turn at least as good as $(x_"OPT" , y_"OPT")$, which must be optimal. Hence $(x', y')$ is in this case always an equilibrium. Because $(x', y')$ are also a Nash equilibrium of a two-player zero-sum game, they can be computed efficiently.

#custom-thm(
  title: "Key Idea",
  number: "3",
  name: "MPC Simulation of mediator behavior",
  color: green
)[
  We can simulate any such mediator strategy using secure multiparty computation.
]

The secure multiparty computation paradigm goes as follows:

Consider some (possibly randomized) function $f:X^n arrow.r X^n$ (where $X$ is some set of possible inputs/outputs to a function, e.g. bitstrings of length at most $m$). We want each player to evaluate their output $in X$, i.e. $f_i (X_1, X_2, dots, X_n)$. Then secure MPC guarantees the following(in a private messaging environment):

+ Each player computes their output correctly with high probability.
+ No group of $< n \/ 2$ players can learn any significant info other than their own outputs.

A similar(and related) cryptographic paradigm is "secret sharing". It looks like the following: a secret $x$ is distributed into $n$ pieces $x_i = "Share"(x,i)$ to $n$ players such that the following to guarantees are satisfied:

+ The secret can be reconstructed from any group of $> n\/2$ people's secret pieces with a function $"Merge"(x_1, x_2, dots, x_n)$ that can accept $< n\/2$ faulty inputs.
+ No group of $< n\/2$ players has can learn any significant info about the secret.

Both of these cryptographic protocols exist, as shown in #cite(<Rabin1989MPCSecret>).

Effectively what happens is this. The mediator strategy is effectively a function $f$ that takes in the infostate $s$ and $n$ inputs from the players $o_i$. Then the mediator outputs a new infostate $s'$ and $n$ actions $a_i$. More formally, if $"Update"$ is the infostate update function,
$ f(s, o_1, o_2, dots, o_n) = s', a_1, a_2, dots, a_n, $
where $s' = "Update"(s, o_1, o_2, dots, o_n)$.

Clearly we want this $f$ in the MPC to map $o_i$ to $a_i$, but what to do with $s, s'$? The answer is to break it up with secret sharing, so that the function computed in MPC is actually $ f'((s_1, o_1), (s_2, o_2), dots, (s_n, o_n)) = ((s'_1, a_1), (s'_2, a_2), dots (s'_n, a_n)), $ where $ s'_i = "Share"("Update"("Merge"(s_1, s_2, dots, s_n), a_1, a_2, dots, a_n),i) $ and $ a_i = f_i ("Merge"(s_1,s_2, dots,s_n), o_1,o_2, dots,o_n). $

This $f'$ computed with MPC is correct with high probability and thus has expected utility at least $"OPT"(Gamma') - W/2^lambda $, where $W$ is some constant that rolls in both the worst case utility and the number of times error can accumulate throughout the game itself. Two natural results:

+ Taking $lambda arrow.r infinity$ means that $"OPT"(Gamma) >= "OPT"(Gamma') - epsilon$ for all $epsilon$, which coupled with the fact that $"OPT"(Gamma) >= "OPT"(Gamma')$ means $"OPT"(Gamma) >= "OPT"(Gamma')$. Because a hidden-role equilibrium for $Gamma'$ is computable, so too is a hidden-role equilibrium EV for $Gamma$.
+ Moreover, such a simulated strategy is in fact playable in polynomial time, as long as you're willing to accept error $epsilon$ with extra polynomial terms in $log(1\/epsilon) = lambda + O(1)$.

== An Application of Efficient Hidden-Role Equilibria

The famous game _Avalon_ becomes solvable with $<7$ players, as the bad team can be treated as if they are coordinated #cite(<Carminati2023HRG>). Using the optimal zero sum game from Key Idea 2 with some (lossless) computational simplification, #cite(<Carminati2023HRG>) calculated optimum values with PCFR+ that are detailed in the table below:

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    stroke: none,
    inset: (x: 0.7em, y: 0.18em),

    // top rule
    table.hline(stroke: 0.6pt),
    [*Variant*], [*5 Players*], [*6 Players*],
    // rule below header
    table.hline(stroke: 0.6pt),

    [No special roles (_Resistance_)],
      val([3], [=], [10], [0.3000], marked: true),
      val([1], [$approx$], [3], [0.3333], marked: true),
    [Merlin],
      val([2], [$approx$], [3], [0.6667], marked: true),
      val([3], [=], [4], [0.7500], marked: true),
    [Merlin & Mordred],
      val([731], [$approx$], [1782], [0.4102]),
      val([6543], [$approx$], [12464], [0.5250]),
    [Merlin & 2 Mordreds],
      val([5], [$approx$], [18], [0.2778]),
      val([99], [$approx$], [340], [0.2912]),
    [Merlin, Mordred, Percival, Morgana],
      val([67], [$approx$], [120], [0.5583]),
      [$—$], // em dash: too large to solve

    // bottom rule
    table.hline(stroke: 0.6pt),
  ),
  caption: [
    Exact equilibrium values for 5- and 6-player _Avalon_. The values marked
    $""^ast$ were also manually derived
    by Christiano #cite(<Christiano2018Avalon>).
  ],
)

This demonstrates the feasibility of this poly-time equilibrium EV finding algorithm on real-world games, as equilibrium EVs for Avalon were previously computationally intractable.

== AI Acknowledgement
DeepSeek-V4.1-Flash-1017 was used to generate table, theorem box, and figure code. I also asked it for a surface-level proofread.

= Problems <sec-team-tme-problems>

#exercise[Nash equilibria of the miscoordination game][
  Find all Nash equilibria of @ex-team-coordination, including mixed ones, and the team's value in each.

  _Hint:_ in a mixed equilibrium each teammate must be indifferent between $L$ and $R$.
] <exr-team-coordination>

#solution[
  The pure equilibria are $(L, L)$, with value $1$, and $(R, R)$, with value $epsilon$. The profiles $(L, R)$ and $(R, L)$ are not equilibria, since either teammate gains by matching the other. If a teammate mixes, it must be indifferent. Let the other teammate play $L$ with probability $q$. Then $L$ pays $q$ and $R$ pays $(1 - q) epsilon$, which are equal when $q = epsilon\/(1 + epsilon)$. A teammate that plays a pure strategy makes the other one strictly prefer to match it, so in any mixed equilibrium both teammates mix, each with $q = epsilon\/(1 + epsilon)$. The team then gets
  $
    q^2 + (1 - q)^2 epsilon = (epsilon^2 + epsilon)/(1 + epsilon)^2 = epsilon/(1 + epsilon),
  $
  which is below $epsilon$. Only $(L, L)$ attains the TME value.
]

#exercise[Other team maxmin equilibria][
  In the communication game, show that the following team strategies guarantee $1\/4$, and so are TMEs by @thm-team-tme-values.
  + Player 1 always sends right ($a = b = 0$), and Player 2 guesses uniformly after right ($d = 1\/2$), with any $c$.
  + Player 1 sends a uniformly random message ($a = b = 1\/2$), and Player 2 guesses uniformly ($c = d = 1\/2$).

  Also show that if Player 1 sends the bit in the clear ($a = 1$, $b = 0$), the team guarantees $0$ whatever Player 2 does.
] <exr-team-tme-multiple>

#solution[
  Use the function $g$ from the proof of @thm-team-tme-values. For the first strategy, $min{0, 0} = 0$ and $min{d, overline(d)} = 1\/2$, so $g = 1/2 dot 1/2 = 1\/4$. For the second, both minima equal $1\/4$, so $g = 1/2 dot 1/2 = 1\/4$. With $a = 1$ and $b = 0$, $min{c, 0} = 0$ and $min{0, overline(d)} = 0$, so $g = 0$. Indeed, Player 1 then sends left exactly when the bit is $0$, so Player 3 guesses $0$ after left and $1$ after right ($e = 1$, $f = 0$) and is always right.
]

#exercise[No adversary, no correlation needed][
  Show that if team ▼ has no decisions, then the TME and TMECor values of any team game are equal. Explain why this fails in the communication game.
] <exr-team-no-adversary>

#solution[
  With no adversary, the team's utility is $EE_((pi_1, pi_2) ~ vmu) [u(pi_1, pi_2)]$, a linear function of $vmu in Delta(Pi_1 times Pi_2)$. Its maximum over the simplex is attained at a vertex, a point mass on a joint plan. A point mass is the product of two point masses, so it is uncorrelated, and the TME value is at least the TMECor value. The reverse inequality holds since every uncorrelated strategy is correlated. With an adversary, the team's guarantee $min_vy EE[u]$ is a minimum of linear functions of $vmu$. It is concave rather than linear, so its maximum need not be at a vertex. In the communication game it is $1\/2$ at the one-time pad (@sec-team-one-time-pad), but $0$ at every joint plan.

]

= Problems on correlation and realization form <sec-team-problems>

#exercise[The one-time pad is the only TMECor][
  In the communication game of @fig-team-communication-game, show that $vmu^*$ is the unique TMECor. That is, show that every $vmu in Delta(Pi_1 times Pi_2)$ that guarantees the team $1\/2$ against every strategy of Player 3 equals $vmu^*$.

  _Hint:_ first let Player 3 guess uniformly. How often must Player 2 then be right, and which joint plans achieve that? Then let Player 3 guess 0 after left and 1 after right.
] <exr-team-pad-unique>

#solution[
  By @sec-team-one-time-pad, $vmu^*$ guarantees $1\/2$. Suppose $vmu$ also guarantees $1\/2$, and write a joint plan as $(a, b; c, d) in {0, 1}^4$.

  First, Player 2 must always be right. If Player 3 guesses uniformly, it is wrong with probability $1\/2$ whatever the team does, so the team gets half the probability that Player 2 guesses right. A guarantee of $1\/2$ therefore forces Player 2 to be right for both bits under every joint plan in the support of $vmu$. If $a = b$, Player 1 sends the same message for both bits, and Player 2 is right for only one of them. If $(a, b) = (1, 0)$, Player 2 is right for both bits only when $(c, d) = (1, 0)$, and if $(a, b) = (0, 1)$, only when $(c, d) = (0, 1)$. So
  $
    vmu = lambda delta_((1, 0; 1, 0)) + (1 - lambda) delta_((0, 1; 0, 1)) quad "for some" lambda in [0, 1].
  $

  Second, the two plans must be equally likely. Suppose Player 3 guesses 0 after the left message and 1 after the right message. It is then always right against the heads plan and always wrong against the tails plan, so the team gets $1 - lambda >= 1\/2$. Against the opposite guesses the team gets $lambda >= 1\/2$. Hence $lambda = 1\/2$ and $vmu = vmu^*$.
]

#exercise[Values of the three-hat game][
  Consider the three-hat game of @ex-team-hats.

  + Show that every joint plan wins on at most $6$ of the $8$ assignments. Conclude that the TMECor value is $3\/4$.
  + Show that the TME value is $1\/2$.

  _Hint:_ for part 1, each guess is right on exactly one of the two assignments where it is made. Count right and wrong guesses. For part 2, fix the pair $v$ that teammate 1 sees, compare both colors of its hat, and apply part 1 to teammates 2 and 3 alone.
] <exr-team-hats>

#solution[
  For part 1, fix a joint plan. A guess that a teammate makes on seeing some pair is right on exactly one of the two assignments that show it that pair, and wrong on the other. So over the $8$ assignments there are as many right guesses as wrong ones. A winning assignment has at least one right guess and no wrong one, and a losing assignment has at most three wrong guesses. If the plan wins on $w$ assignments, then
  $
    w <= "#right guesses" = "#wrong guesses" <= 3 dot (8 - w),
  $
  so $w <= 6$. A team strategy is a distribution over joint plans, so against uniformly random hats it wins with probability at most $6\/8 = 3\/4$. The coins of @ex-team-hats guarantee $3\/4$, so the TMECor value is $3\/4$.

  For part 2, if teammate 1 guesses red or blue with probability $1\/2$ each and the others pass, the team wins with probability $1\/2$ on every assignment. For the upper bound, fix an uncorrelated team strategy. Write an assignment as $(h_1, v)$, where $h_1$ is teammate 1's hat and $v$ is the pair of hats of teammates 2 and 3, which teammate 1 sees. Let $W(h_1, v)$ be the probability that the team wins on $(h_1, v)$ if teammate 1 is made to pass.

  Write $"win"(h_1, v)$ for the probability that the team wins on $(h_1, v)$. Fix $v$, and let teammate 1 guess with total probability $q$ on seeing $v$. Teammate 1 randomizes independently of the others. If it passes, the team wins with probability $W(h_1, v)$. If it guesses right, the team wins with probability at most $1$, and if it guesses wrong, the team loses. Its guess is right for only one of the two values of $h_1$, so summing over $h_1$,
  $
    "win"("red", v) + "win"("blue", v) <= (1 - q) dot (W("red", v) + W("blue", v)) + q.
  $

  Now fix $h_1$. Teammates 2 and 3 then play a game with two hats, in which each sees the other's hat. The counting argument of part 1, with at most two wrong guesses per losing assignment, shows that every joint plan of teammates 2 and 3 wins on at most two of the four pairs $v$. Averaging over their strategies, $sum_v W(h_1, v) <= 2$. Summing over $h_1$ gives $sum_v (W("red", v) + W("blue", v)) <= 4$. There are four pairs $v$, so for some $v$ we have $W("red", v) + W("blue", v) <= 1$. For that $v$ the right-hand side above is at most $1$, so the team wins with probability at most $1\/2$ on $("red", v)$ or on $("blue", v)$. Hence the TME value is $1\/2$.
]

#exercise[A biased bit][
  Modify the communication game of @fig-team-communication-game so that chance draws bit 0 with probability $p$ and bit 1 with probability $1 - p$, where $1\/2 <= p < 1$. Everything else stays the same.

  + Show that the TMECor value is $1 - p$.
  + For $q in [0, 1]$, consider the biased one-time pad $vmu_q := q delta_((1, 0; 1, 0)) + (1 - q) delta_((0, 1; 0, 1))$. Find all $q$ for which $vmu_q$ is a TMECor, and compare with @exr-team-pad-unique. Is the message independent of the bit for all of them?
  + Show that the TME value is $p (1 - p)$.

  _Hint:_ for part 1, let Player 3 ignore the message. For part 3, maximize $min(alpha c, beta overline(c))$ over $c$, and use that the maximum is concave and positively homogeneous in $(alpha, beta)$.
] <exr-team-biased-bit>

#solution[
  Write $e$ and $f$ for the probabilities that Player 3 guesses 0 after the left and the right message. By @lem-team-utility with the new chance probabilities and the vectors of @ex-team-realization, the uncorrelated team strategy $(a, b; c, d)$ gets
  $
    u = p a c overline(e) + (1 - p) b overline(c) e + p overline(a) d overline(f) + (1 - p) overline(b) overline(d) f.
  $

  For part 1, if Player 3 always guesses 0 ($e = f = 1$), every joint plan gets $u = (1 - p) dot (b overline(c) + overline(b) overline(d)) <= 1 - p$. So no $vmu$ guarantees more than $1 - p$. Conversely, under $vmu^*$ Player 2 is always right and the message is independent of the bit. If Player 3 guesses 0 with probability $s$ after a given message, then given that message it is wrong with probability $s (1 - p) + (1 - s) p >= 1 - p$, since $p >= 1\/2$. So $vmu^*$ guarantees $1 - p$, and the TMECor value is $1 - p$.

  For part 2, under $vmu_q$ Player 2 is always right. After each message Player 3 guesses the likelier bit, so the team gets the Bayes error, the smaller of the two joint probabilities of bit and message, summed over messages:
  $
    V(q) = min(p q, (1 - p)(1 - q)) + min(p (1 - q), (1 - p) q).
  $
  Note that $p q - (1 - p)(1 - q) = q - (1 - p)$ and $p (1 - q) - (1 - p) q = p - q$. Splitting at $q = 1 - p$ and $q = p$ gives $V(q) = min(q, 1 - q, 1 - p)$, so $vmu_q$ is a TMECor if and only if $q in [1 - p, p]$. Player 1 sends the left message with probability $q$ after bit 0 and $1 - q$ after bit 1, so the message is independent of the bit only for $q = 1\/2$. For the other optimal $q$, bit 0 stays at least as likely after either message, so the message does not help Player 3. At $p = 1\/2$ the interval is the single point $q = 1\/2$, as in @exr-team-pad-unique.

  For part 3, since $u$ is linear in $e$ and in $f$,
  $
    min_(e, f) u = min(p a c, (1 - p) b overline(c)) + min(p overline(a) d, (1 - p) overline(b) overline(d)).
  $
  For $alpha, beta >= 0$ the map $c |-> min(alpha c, beta overline(c))$ has maximum $h(alpha, beta) := alpha beta \/ (alpha + beta)$ over $[0, 1]$, with $h(0, 0) := 0$. This is half the harmonic mean of $alpha$ and $beta$. So the TME value is the maximum over $(a, b)$ of $h(vu) + h(vv)$, where $vu := (p a, (1 - p) b)$ and $vv := (p overline(a), (1 - p) overline(b))$. The function $h$ is concave and positively homogeneous, hence superadditive. Since $vu + vv = (p, 1 - p)$,
  $
    h(vu) + h(vv) <= h(p, 1 - p) = p (1 - p).
  $
  The strategy $a = b$, $c = d = 1 - p$ attains this bound, so the TME value is $p (1 - p)$.
]

#exercise[Where the nonconvexity goes][
  Use the communication game of @fig-team-communication-game and the vectors $vx(a, b; c, d)$ and $vy$ of @ex-team-realization.
  + Compute $vx(a, b; c, d)^top U vy$ as a polynomial in $a, ..., f$, and check that it is the team's expected utility.
  + Fix Player 3 at $e = f = 1\/2$. Use the joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ and their midpoint in behavioral coordinates to show that the team's utility is not a quasiconcave function of $(a, b; c, d) in [0, 1]^4$, by finding a midpoint where it is below its values at both endpoints.

  _Hint:_ for part 2, write the utility at $e = f = 1\/2$ in terms of $a - b$ and $c - d$.
] <exr-team-bilinear>

#solution[
  For part 1, chance plays each bit with probability $1\/2$, and the team scores $1$ exactly at $z_2, z_5, z_8, z_11$. So $U$ is diagonal with entry $1\/2$ at these four leaves and $0$ elsewhere. Reading off the entries of @ex-team-realization at these leaves gives
  $
    vx(a, b; c, d)^top U vy = 1/2 (a c overline(e) + b overline(c) e + overline(a) d overline(f) + overline(b) overline(d) f).
  $
  Given the bit, each term is the probability that Player 1 sends a particular message, Player 2 is right, and Player 3 is wrong. Each bit has probability $1\/2$, so this is the expected utility.

  For part 2, at $e = f = 1\/2$ the utility is
  $
    u(a, b; c, d) = 1/4 (a c + b overline(c) + overline(a) d + overline(b) overline(d)) = 1/4 (1 + (a - b) dot (c - d)).
  $
  Both joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ give $1\/2$. Their behavioral midpoint $(1\/2, 1\/2; 1\/2, 1\/2)$ gives $1\/4$. A quasiconcave function would be at least $1\/2$ there, the minimum of its endpoint values. So $u$ is not quasiconcave.

  The products $a c, b overline(c), ...$ are the coordinates of $vx$, so the nonconvexity has moved from the objective into $tcX$ (@thm-team-convexification).
]

= Problems on public information

#exercise[
  With no reveal, allow arbitrary finite input sets and specify a target bit $c_(x y)$ for each allowed pair $(x,y)$. Form a bipartite graph with these pairs as edges labeled by their target bits. Prove that the team can win surely exactly when the labels XOR to zero on every cycle. What if one input pair is removed from the original four-input game?
]

#solution[
  A sure win requires a deterministic plan that wins on every edge, since any plan used with positive probability must win on each edge. A plan assigns bits to vertices whose endpoint XOR must equal each edge label. XORing around any cycle cancels every vertex bit. Conversely, in each component fix a root bit and propagate along a spanning tree. Each remaining edge closes a cycle, so its label agrees with the assigned bits. Removing any edge from the four-input game leaves a tree. The row in @tbl-parity-plans that loses on the removed input gives a sure win.
]

#exercise[
  With probability $r$, let the public signal reveal $s=x xor y$ instead of $x$. With probability $1-r$ it is still $bot$. Does either value change?
]

#solution[
  Bob recovers $x=s xor y$, so $a=0$ and $b=(s xor y)y$ win on every revealed input. The parity alone leaves two possible pairs. Each teammate can recover the other bit using their own. The reveal probability and hidden-branch game are unchanged, so both values stay the same.
]

#appendix[
  = Appendix: The flow relaxation <sec-team-flow>

  #example[The flow relaxation is too large][
    Consider the relaxation obtained by revealing the bit to Player 2. It is the flow polytope of a team that does _not_ forget. With leaves numbered as in @fig-team-communication-game, it says that the team's total mass is $1$ for each value of the bit and that the two children of each Player 3 node carry equal mass:
    $
      R := {vx in RR_(>= 0)^Z : & vx[z_1] + vx[z_3] + vx[z_7] + vx[z_9] = 1, quad vx[z_4] + vx[z_5] + vx[z_10] + vx[z_11] = 1, \
        & vx[z_1] = vx[z_2], quad vx[z_5] = vx[z_6], quad vx[z_7] = vx[z_8], quad vx[z_11] = vx[z_12]}.
    $
    A point of $R$ is a pair of distributions over the team's four possible outcomes, one for each value of the bit, so $R$ is a product of two simplices. Its 16 vertices are the pairs of outcomes, one per value of the bit. A joint plan produces every pair except the four in which Player 1 sends the same message for both values of the bit, yet Player 2 acts differently, which only a Player 2 who sees the bit could do:
    #align(center, table(
      stroke: none,
      columns: 3,
      align: center + horizon,
      inset: .7em,
      table.header([*Bit 0 leaf*], [*Bit 1 leaf*], [*Inequality that cuts it off*]),
      [$z_1$], [$z_5$], [$vx[z_1] + vx[z_5] <= 1$],
      [$z_3$], [$z_4$], [$vx[z_3] + vx[z_4] <= 1$],
      [$z_7$], [$z_11$], [$vx[z_7] + vx[z_11] <= 1$],
      [$z_9$], [$z_10$], [$vx[z_9] + vx[z_10] <= 1$],
    ))
    So $cX subset.neq R$. Adding the four inequalities to $R$ gives exactly $cX$, by a coupling argument with Gale's supply--demand theorem #citep(<Gale57:Theorem>), which generalizes Hall's marriage theorem. Distinct bit 0 outcomes forbid distinct bit 1 partners, so any two of them together have all four outcomes as allowed partners. Gale's condition is then nontrivial only for single outcomes, where it gives the four inequalities.
  ] <ex-team-flow-gap>

  The gap does not show in the value of this game. If Player 3 guesses uniformly, the team gets at most $1\/2$ on all of $R$, since each bit's mass is $1$. The one-time pad attains $1\/2$ in $cX subset.eq R$, so the maxmin value over $R$ is $1\/2$.

  The picture of @fig-team-realization-sets also appears in variational inference #citep(<Wainwright08:Graphical>, [Sec.~5.4]). The mean parameters of product distributions, the naive mean-field family, form a subset of the marginal polytope containing all its vertices (point masses are product distributions), so it is nonconvex unless it is the whole polytope. They play the role of $tcX$, the marginal polytope that of $cX$, and the local polytope, an outer bound from local consistency, that of $R$.
]

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
