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
  caption: [The communication game. Team ▲ is Players 1 and 2, and Player 3 (▼) is the adversary. Chance draws a uniform bit that only Player 1 sees, with bit 0 on the left. Players 2 and 3 observe Player 1's action and then each guess the bit. Team ▲ gets 1 if Player 2 guesses right and Player 3 guesses wrong, and 0 otherwise. The game ends as soon as Player 2 guesses wrong, since the team then gets 0 whatever Player 3 does, so there are 12 leaves. Edge labels are behavioral probabilities, with $overline(x) := 1 - x$. Player 1 sends the left message with probability $a$ on bit 0 and $b$ on bit 1. Players 2 and 3 guess 0 with probability $c$ and $e$ after the left message, and $d$ and $f$ after the right one. Leaves show the team's payoff and their index $z_1, dots, z_12$.],
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

Readers familiar with cryptography will recognize the team's optimal strategy as a _one-time pad_. Before play, Players 1 and 2 flip a shared fair coin. On heads, Player 1 sends the bit as it is, and on tails it sends the flipped bit. Player 2 knows the coin, so it undoes the flip and always guesses correctly. Player 3 does not know the coin, so to Player 3 the message carries no information about the bit. Write $delta_pi$ for the point mass on a joint plan $pi$. In the coordinates $(a, b; c, d)$ of @fig-team-communication-game,
$
  vmu^star := 1/2 delta_((1, 0; 1, 0)) + 1/2 delta_((0, 1; 0, 1)).
$
The two joint plans are the heads and tails branches, and the shared coin picks between them.

Under $vmu^star$, Player 2 always guesses right, and the message is uniform and independent of the bit. So Player 3 is right with probability $1\/2$ whatever it does, and the team gets $1\/2$ against every $vy$. Conversely, the team scores only when Player 3 guesses wrong. If Player 3 guesses uniformly at random, it is wrong with probability $1\/2$, so no team strategy gets more than $1\/2$. Hence the TMECor value is $1\/2$. This is twice the TME value of $1\/4$, and it equals the min-max value computed earlier. Correlation closes the gap between the maxmin and min-max values.

#exercise[The one-time pad is the only TMECor][
  In the communication game of @fig-team-communication-game, show that $vmu^star$ is the unique TMECor. That is, show that every $vmu in Delta(Pi_1 times Pi_2)$ that guarantees the team $1\/2$ against every strategy of Player 3 equals $vmu^star$.

  Hint in @sec-team-hints.
] <exr-team-pad-unique>
#solution[
  By @sec-team-one-time-pad, the TMECor value is $1\/2$ and $vmu^star$ attains it. It remains to show that every $vmu$ that guarantees $1\/2$ equals $vmu^star$. As in @ex-team-realization, $e$ and $f$ are the probabilities that Player 3 guesses 0 after the left and the right message. The team scores only at $z_2, z_5, z_8, z_11$, and chance reaches each of them with probability $1\/2$. So a pure joint plan $pi = (a, b; c, d) in {0, 1}^4$ gives
  $
    u(pi, e, f) = 1/2 (a c overline(e) + b overline(c) e + overline(a) d overline(f) + overline(b) overline(d) f),
  $
  and $u(vmu, e, f) = sum_pi mu(pi) dot u(pi, e, f)$.

  *Player 2 is always right.* Against $e = f = 1\/2$ we get $u(pi, 1\/2, 1\/2) = 1/2 r(pi)$, where $r(pi) := 1/2 (a c + b overline(c) + overline(a) d + overline(b) overline(d))$ is the probability that Player 2 guesses right. Since $r(pi) <= 1$ and $vmu$ guarantees $1\/2$,
  $
    0 <= sum_pi mu(pi) (1 - r(pi)) = 1 - 2 dot u(vmu, 1\/2, 1\/2) <= 0.
  $
  Hence $vmu$ puts all its mass on plans with $r(pi) = 1$. If $a = b$, Player 1 sends the same message for both bits, and Player 2's guess after it is right for only one bit, so $r(pi) = 1\/2$. If $(a, b) = (1, 0)$, Player 2 is right for both bits only when $(c, d) = (1, 0)$. If $(a, b) = (0, 1)$, only when $(c, d) = (0, 1)$. So
  $
    vmu = lambda delta_((1, 0; 1, 0)) + (1 - lambda) delta_((0, 1; 0, 1)) quad "for some" lambda in [0, 1].
  $

  *The two plans are equally likely.* The two plans give $u = (1 - e + f) \/ 2$ and $u = (1 + e - f) \/ 2$. Suppose Player 3 guesses 0 after the left message and 1 after the right message ($e = 1$, $f = 0$). Then the plans give $0$ and $1$, so the team gets $1 - lambda >= 1\/2$. Against the opposite guesses ($e = 0$, $f = 1$) the team gets $lambda >= 1\/2$. Hence $lambda = 1\/2$ and $vmu = vmu^star$.
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

#exercise[A biased bit][
  Modify the communication game of @fig-team-communication-game so that chance draws bit 0 with probability $p$ and bit 1 with probability $1 - p$, where $1\/2 <= p < 1$. Everything else stays the same.

  #set enum(numbering: "(i)")
  + Show that the TMECor value is $1 - p$.
  + For $q in [0, 1]$, consider the biased one-time pad $vmu_q := q delta_((1, 0; 1, 0)) + (1 - q) delta_((0, 1; 0, 1))$. Show that the fair pad $vmu_(1\/2) = vmu^star$ is still a TMECor. Find all $q$ for which $vmu_q$ is a TMECor. Is the message still independent of the bit for all of them?
  + Show that the TME value is $p (1 - p)$. Describe the uncorrelated strategies $(a, b; c, d)$ that attain it.
  + For $p = 2\/3$, compare the ratio of the TMECor and TME values with the case $p = 1\/2$.

  Hints in @sec-team-hints.
] <exr-team-biased-bit>
#solution[
  Write $e$ and $f$ for the probabilities that Player 3 guesses 0 after the left and after the right message. The leaves that pay 1 are $z_2, z_5, z_8, z_11$. By @lem-team-utility with the new chance probabilities and the vectors of @ex-team-realization, the uncorrelated team strategy $(a, b; c, d)$ gets
  $
    u = p a c overline(e) + (1 - p) b overline(c) e + p overline(a) d overline(f) + (1 - p) overline(b) overline(d) f.
  $

  *(i)* Suppose Player 3 always guesses 0, that is, $e = f = 1$. Then $u = (1 - p) dot (b overline(c) + overline(b) overline(d)) <= 1 - p$ for every joint plan, so no $vmu$ guarantees more than $1 - p$. Conversely, under $vmu^star$ Player 2 is always right and the message is independent of the bit. If Player 3 guesses 0 with probability $s$, it is wrong with probability $s (1 - p) + (1 - s) p >= 1 - p$, since $p >= 1\/2$. So $vmu^star$ guarantees $1 - p$, and the TMECor value is $1 - p$.

  *(ii)* By (i), $vmu_(1\/2) = vmu^star$ guarantees the value $1 - p$, so it is a TMECor. Under $vmu_q$ Player 2 is always right, and the bit and the message have joint probabilities
  $
    Pr[0, "left"] = p q, quad Pr[1, "left"] = (1 - p)(1 - q), quad Pr[0, "right"] = p (1 - q), quad Pr[1, "right"] = (1 - p) q.
  $
  After each message Player 3 guesses the likelier bit, so the team gets
  $
    V(q) = min(p q, (1 - p)(1 - q)) + min(p (1 - q), (1 - p) q).
  $
  Note that $p q - (1 - p)(1 - q) = q - (1 - p)$ and $p (1 - q) - (1 - p) q = p - q$. For $1 - p <= q <= p$ both minima are the second terms, and $V(q) = (1 - p)(1 - q) + (1 - p) q = 1 - p$. For $q > p$ we get $V(q) = (1 - p)(1 - q) + p (1 - q) = 1 - q < 1 - p$. For $q < 1 - p$ we get $V(q) = p q + (1 - p) q = q < 1 - p$. Hence $V(q) = min(q, 1 - q, 1 - p)$, and $vmu_q$ is a TMECor if and only if $q in [1 - p, p]$. For $p = 1\/2$ this is the single point $q = 1\/2$, in line with @exr-team-pad-unique.

  Player 1 sends the left message with probability $q$ after bit 0 and $1 - q$ after bit 1. So the message is independent of the bit only for $q = 1\/2$. For the other optimal $q$ the message is informative, but bit 0 stays at least as likely after both messages. Player 3 then guesses 0 regardless of the message and gains nothing from it. Perfect secrecy is sufficient for optimality but not necessary.

  *(iii)* Since $u$ is linear in $e$ and in $f$, Player 3's best response gives
  $
    min_(e, f) u = min(p a c, (1 - p) b overline(c)) + min(p overline(a) d, (1 - p) overline(b) overline(d)).
  $
  For $alpha, beta >= 0$ the map $c |-> min(alpha c, beta overline(c))$ has maximum $g(alpha, beta) := alpha beta \/ (alpha + beta)$ over $[0, 1]$, with $g(0, 0) := 0$. If $alpha, beta > 0$, the maximum is attained only at $c = beta \/ (alpha + beta)$, where the two terms are equal. Hence the TME value is the maximum over $(a, b)$ of $g(vu) + g(vv)$, where $vu := (p a, (1 - p) b)$ and $vv := (p overline(a), (1 - p) overline(b))$. The function $g$ is concave and positively homogeneous, hence superadditive. Since $vu + vv = (p, 1 - p)$, this gives
  $
    g(vu) + g(vv) <= g(p, 1 - p) = p (1 - p).
  $
  Taking $a = b$ and $c = d = 1 - p$ gives $min_(e, f) u = a dot p (1 - p) + overline(a) dot p (1 - p) = p (1 - p)$, so the TME value is $p (1 - p)$.

  For the maximizers, write $vu = (alpha_1, beta_1)$ and $vv = (alpha_2, beta_2)$. If both are nonzero, a direct computation gives
  $
    g(vu + vv) - g(vu) - g(vv) = (alpha_1 beta_2 - alpha_2 beta_1)^2 / ((alpha_1 + beta_1)(alpha_2 + beta_2)(alpha_1 + alpha_2 + beta_1 + beta_2)),
  $
  and here $alpha_1 beta_2 - alpha_2 beta_1 = p (1 - p)(a - b)$. If one of them is zero, then $a = b in {0, 1}$. So equality forces $a = b$. Then the first term equals $a dot min(p c, (1 - p) overline(c))$, which reaches $a dot p (1 - p)$ only at $c = 1 - p$ when $a > 0$. In the same way $d = 1 - p$ when $a < 1$. The uncorrelated strategies that attain the TME value are therefore exactly those with $a = b$, with $c = 1 - p$ if $a > 0$ and $d = 1 - p$ if $a < 1$. The message carries no information, and Player 2 guesses the likelier bit 0 only with probability $1 - p <= 1\/2$. For $p = 1\/2$ this means $a = b$, with $c = 1\/2$ if $a > 0$ and $d = 1\/2$ if $a < 1$. The guess after an unused message is arbitrary. It contains the point of @tab-team-dictionary but is larger.

  *(iv)* For $p = 2\/3$ the TMECor value is $1\/3$ and the TME value is $2\/9$, a ratio of $3\/2$. For $p = 1\/2$ the values are $1\/2$ and $1\/4$, a ratio of $2$. In general the ratio is $(1 - p) \/ (p (1 - p)) = 1\/p$. So correlation helps less as the bit becomes more predictable.
]

== Team games as imperfect-recall games <sec-team-imperfect-recall>

Equivalently, we can think of the two teammates as one player that happens to forget. In the communication game, this player observes the bit, sends a message, then forgets the bit and continues in the role of Player 2 (@fig-team-imperfect-recall). A team game is thus a two-player zero-sum game in which each team becomes a single player, who in general has imperfect recall #citep(<Farina18:Ex>, <Zhang23:Team>). Strictly, the equivalence is with _timeable_ imperfect-recall games, in which the tree can be drawn so that every information set is horizontal, that is, every player always knows what time it is. We also assume that each original player has perfect recall. We return to timeability later in the lecture. @tab-team-dictionary translates between the two views.

#figure(
  image("figures/team/imperfect_recall_game.svg", width: 60%),
  caption: [The communication game as a two-player zero-sum game. The team is a single player (1) that observes the bit, sends a message, and then forgets the bit. Each of its second-level information sets joins nodes that this player reached after observing different bits. The player forgets what it knew, so it has imperfect recall.],
) <fig-team-imperfect-recall>

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
    [TME], [optimal behavioral strategy], [for example $a = b = c = d = 1\/2$],
    [TMECor], [team's part of a mixed Nash equilibrium], [$vmu^star$],
  ),
) <tab-team-dictionary>

By the minimax theorem, a maxmin strategy of the team is exactly the team's part of a mixed Nash equilibrium of this two-player game. So most of this lecture can be read as computing mixed Nash equilibria of two-player zero-sum games of imperfect recall. Behavioral and mixed strategies must be distinguished because #lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem], which makes them realization-equivalent, requires perfect recall, and the team player does not have it. A behavioral strategy randomizes independently at each information set, so it cannot make Player 2's guess depend on the coin that chose Player 1's message. The one-time pad $vmu^star$ is therefore a mixed strategy of the team player that no behavioral strategy realizes (@ex-team-pad-not-uncorrelated).

The question for the rest of the lecture is when a TMECor can be computed efficiently.

= Realization form <sec-team-realization-form>

By @sec-team-minimax, a TMECor is a maxmin strategy of a two-player zero-sum game, so we would like to use the tools we already have for such games. The obstacle is size. The distribution $vmu$ has one coordinate per joint plan, and the number of joint plans can be exponential in the size of the game tree. As with the sequence form, we record only what affects the payoff, namely which terminal nodes the team plays toward.

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

This #lecture-link("learning_intro", <sec-learning-zero-sum>)[saddle-point problem] adapts the sequence form to teams. When a team is a single player with perfect recall, the entry $x[z]$ is the sequence-form entry of the player's last sequence on the path to $z$ (the empty sequence if the player does not act on that path). So $cX$ is a linear image of the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytope], and the problem above is the usual sequence-form maxmin problem composed with this linear map. For Player 3 in @ex-team-realization, this map sends the sequence-form vector $(1, e, overline(e), f, overline(f))$ to $vy$.

== Convexifying the TME <sec-team-convexification>

// Not from the lecture: this subsection follows Farina et al. (2018), Thm 2.
The TME can be written in the same form as @thm-team-bspp. An uncorrelated team strategy is a pair of mixed strategies, written $vx_1, vx_2$ in the definition of the TME. Since $vx$ now denotes a realization vector, we rename them $vmu_1 in Delta(Pi_1)$ and $vmu_2 in Delta(Pi_2)$. They induce the product distribution $vmu_1 times.o vmu_2$ on joint plans, and
$
  tilde(cX) := {vx^(vmu_1 times.o vmu_2) : vmu_1 in Delta(Pi_1), vmu_2 in Delta(Pi_2)} subset.eq cX
$
is the set of their realization vectors, the vectors the team can reach _without_ shared randomness. This set need not be convex, and @ex-team-pad-not-uncorrelated shows that it is not convex in the communication game.

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

#exercise[Where the nonconvexity goes][
  Use the communication game of @fig-team-communication-game and the vectors $vx(a, b; c, d)$ and $vy$ of @ex-team-realization.
  #set enum(numbering: "(i)")
  + Compute $vx(a, b; c, d)^top U vy$ as a polynomial in $a, dots, f$. Check that it agrees with the expected utility computed directly from the tree.
  + Fix Player 3 at $e = f = 1\/2$. Use the joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ and their midpoint in behavioral coordinates to show that the team's utility is not a concave function of $(a, b, c, d) in [0, 1]^4$.
  + Now take the midpoint of the same two plans in realization coordinates. What utility does it give against $e = f = 1\/2$? Which of the two midpoints can the team play without shared randomness?

  Hint in @sec-team-hints.
] <exr-team-bilinear>
#solution[
  #set enum(numbering: "(i)")
  + Chance plays each bit with probability $1\/2$, and the team scores $1$ exactly at $z_2, z_5, z_8, z_11$. So $U$ is diagonal with entry $1\/2$ at these four leaves and $0$ elsewhere. Reading off the entries of @ex-team-realization at these leaves gives
    $
      vx(a, b; c, d)^top U vy = 1/2 (a c overline(e) + b overline(c) e + overline(a) d overline(f) + overline(b) overline(d) f).
    $
    Directly from the tree, suppose the bit is $0$. The team scores if Player 1 sends left ($a$), Player 2 guesses $0$ ($c$), and Player 3 guesses $1$ ($overline(e)$), or if Player 1 sends right ($overline(a)$), Player 2 guesses $0$ ($d$), and Player 3 guesses $1$ ($overline(f)$). For bit $1$ the scoring paths have probabilities $b overline(c) e$ and $overline(b) overline(d) f$. Weighting each bit by $1\/2$ gives the same polynomial.

  + At $e = f = 1\/2$ the utility is
    $
      u(a, b, c, d) = 1/4 (a c + b overline(c) + overline(a) d + overline(b) overline(d)) = 1/4 (1 + (a - b) dot (c - d)).
    $
    Both joint plans $(1, 0; 1, 0)$ and $(0, 1; 0, 1)$ give $1\/2$. Their midpoint in behavioral coordinates is $(1\/2, 1\/2; 1\/2, 1\/2)$, which gives $1\/4$. A concave function would be at least $1\/2$ there, the average of its values at the endpoints. So $u$ is not concave on $[0, 1]^4$.

  + The realization vectors of the two plans are $(1, 1, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0 #h(.4em) bar.v #h(.4em) 0, 1, 1)$ and $(0, 0, 0 #h(.4em) bar.v #h(.4em) 0, 1, 1 #h(.4em) bar.v #h(.4em) 1, 1, 0 #h(.4em) bar.v #h(.4em) 0, 0, 0)$. Their midpoint is $vx^(vmu^star)$ of @ex-team-pad-not-uncorrelated. Since $vx |-> vx^top U vy$ is linear, it gives the average utility $1\/2$. Indeed, by (i) it gives $1/4 (overline(e) + e + overline(f) + f) = 1\/2$ against every $vy$.

    The behavioral midpoint has realization vector $vx(1\/2, 1\/2; 1\/2, 1\/2)$, with every entry equal to $1\/4$. It lies in $tilde(cX)$, so the team can play it without shared randomness, but it only gets $1\/4$. The realization midpoint is not in $tilde(cX)$ by @ex-team-pad-not-uncorrelated. It needs the shared coin.

  The products $a c, b overline(c), dots$ that make $u$ nonconcave have not disappeared. They are the coordinates of $vx$. So the objective is linear in $vx$, and the nonconvexity has moved into the set $tilde(cX)$, which correlation convexifies to $cX$ (@thm-team-convexification).
]

== Beyond the sequence form <sec-team-sequence-form>

The problem of @thm-team-bspp is a convex bilinear saddle-point problem that looks like the sequence-form problem, but we have not yet said how to describe $cX$ efficiently. If the team had perfect recall, $cX$ would be a linear image of a sequence-form polytope, as $cY$ is for Player 3. A team in general does not have perfect recall. In the sequence form, each information set has exactly one parent sequence, and its flow constraint splits the mass of that sequence among the actions at the information set. In the communication game, each information set of Player 2 has two parent sequences, one through each node of Player 1.

// Not from the lecture: this example is an addition (derived and verified numerically).
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
  So $cX subset.neq R$, and adding the four inequalities to $R$ gives exactly $cX$. Indeed, a point of $R$ lies in $cX$ exactly when its two distributions can be coupled without using a forbidden pair. By Gale's supply–demand theorem #citep(<Gale57:Theorem>), such a coupling exists if and only if every set of bit 0 outcomes has at most the mass of its allowed bit 1 partners. For a single outcome this says that its mass is at most one minus the mass of its forbidden partner, which is one of the four inequalities in the table. Different outcomes forbid different partners, so any set of two or more outcomes is allowed all four bit 1 outcomes, and its condition follows from the total mass being 1.
] <ex-team-flow-gap>

The gap is invisible in the value of this game. A point of $R$ is a pair of distributions over the team's outcomes, one for each value of the bit. If Player 3 guesses uniformly ($e = f = 1\/2$), it is wrong with probability $1\/2$ whatever these distributions are, and the team scores only when Player 3 is wrong. So the team gets at most $1\/2$ on all of $R$, and since $cX subset.eq R$, the maxmin value over $R$ is also $1\/2$. But $R$ contains strategies that no team can play. In this small game, four extra inequalities repair the relaxation. In general we should not expect an efficient repair. Suppose some polynomial-time procedure produced, for every team game, a polynomial-size linear description of $cX$. When team ▼ is a single player with perfect recall, as Player 3 is, $cY$ has such a description too, namely the sequence form. Linear programming would then solve the saddle-point problem of @thm-team-bspp in polynomial time. Computing a TMECor is NP-hard, as the next part of the lecture shows, so unless $P = NP$ no such procedure exists.

#exercise[The uncorrelated set is cut out by two quadratics][
  Let $R$ be the flow relaxation of @ex-team-flow-gap. Show that
  $
    tilde(cX) = {vx in R : x[z_1] dot x[z_5] = x[z_3] dot x[z_4], quad x[z_7] dot x[z_11] = x[z_9] dot x[z_10]}.
  $
  Interpret each equation as a statement about Player 2's conditional behavior. Use the result to show again that $vx^(vmu^star) in.not tilde(cX)$, and conclude that $tilde(cX)$ is not convex.

  Hint in @sec-team-hints.
] <exr-team-uncorrelated-quadratics>
#solution[
  Write $x_i := x[z_i]$ and $overline(a) := 1 - a$, and let $Q$ denote the right-hand side. By @ex-team-pad-not-uncorrelated, $tilde(cX)$ is the set of vectors $vx(a, b; c, d)$ of @ex-team-realization with $(a, b; c, d) in [0, 1]^4$.

  *$tilde(cX) subset.eq Q$.* The entries of $vx(a, b; c, d)$ are products of numbers in $[0, 1]$, so they are nonnegative. We have
  $
    x_1 + x_3 + x_7 + x_9 & = a c + a overline(c) + overline(a) d + overline(a) overline(d) = 1, \
    x_4 + x_5 + x_10 + x_11 & = b c + b overline(c) + overline(b) d + overline(b) overline(d) = 1,
  $
  and $x_1 = x_2 = a c$, $x_5 = x_6 = b overline(c)$, $x_7 = x_8 = overline(a) d$, $x_11 = x_12 = overline(b) overline(d)$. So $vx(a, b; c, d) in R$. Moreover
  $
    x_1 dot x_5 = a c dot b overline(c) = a overline(c) dot b c = x_3 dot x_4, quad
    x_7 dot x_11 = overline(a) d dot overline(b) overline(d) = overline(a) overline(d) dot overline(b) d = x_9 dot x_10.
  $

  *$Q subset.eq tilde(cX)$.* Let $vx in Q$, and set $a := x_1 + x_3$ and $b := x_4 + x_5$. The two mass constraints of $R$ and nonnegativity give $a, b in [0, 1]$, $x_7 + x_9 = overline(a)$, and $x_10 + x_11 = overline(b)$. Put $c := x_1 \/ a$ if $a > 0$, $c := x_4 \/ b$ if $a = 0 < b$, and $c := 0$ if $a = b = 0$. Then $c in [0, 1]$, and we claim
  $
    a c = x_1, quad a overline(c) = x_3, quad b c = x_4, quad b overline(c) = x_5.
  $
  If $a = 0$, then $x_1 = x_3 = 0$, so the first two hold for every $c$. If $b = 0$, then $x_4 = x_5 = 0$, so the last two hold for every $c$. In each of these cases the definition of $c$ gives the other pair. If $a, b > 0$, the first two hold by definition, and the last two hold if and only if $x_1 \/ a = x_4 \/ b$. This is the first equation, since
  $
    x_1 dot (x_4 + x_5) - x_4 dot (x_1 + x_3) = x_1 dot x_5 - x_3 dot x_4.
  $
  Define $d$ in the same way from $(x_7, x_9)$ and $(x_10, x_11)$, with masses $overline(a)$ and $overline(b)$. The same argument with the second equation gives $overline(a) d = x_7$, $overline(a) overline(d) = x_9$, $overline(b) d = x_10$, and $overline(b) overline(d) = x_11$. The equalities $x_2 = x_1$, $x_6 = x_5$, $x_8 = x_7$, $x_12 = x_11$ of $R$ give the remaining entries. Hence $vx = vx(a, b; c, d) in tilde(cX)$.

  *Interpretation.* Given bit 0, Player 1 sends the left message with probability $x_1 + x_3$, and $x_1$ is the probability that Player 1 sends the left message and Player 2 guesses 0. So $x_1 \/ (x_1 + x_3)$ is the probability that Player 2 guesses 0 given the left message and bit 0. Likewise $x_4 \/ (x_4 + x_5)$ is the same probability given the left message and bit 1. When the left message has positive probability under both bits, the first equation says that these two conditional probabilities are equal. In other words, after the left message Player 2's guess is independent of the bit. The second equation says the same after the right message, with $x_7 \/ (x_7 + x_9) = x_10 \/ (x_10 + x_11)$. Player 2 does not see the bit, so without shared randomness it cannot react to it. With a shared coin it can.

  *The one-time pad.* By @ex-team-pad-not-uncorrelated, $vx^(vmu^star)$ has $x_1 = x_5 = 1\/2$ and $x_3 = x_4 = 0$. So $x_1 dot x_5 = 1\/4 != 0 = x_3 dot x_4$, and $vx^(vmu^star) in.not tilde(cX)$. After the left message, Player 2 guesses 0 with probability $1$ if the bit is 0 and with probability $0$ if it is 1. The endpoints $vx^((1, 0; 1, 0))$ and $vx^((0, 1; 0, 1))$ lie in $V subset.eq tilde(cX)$, and $vx^(vmu^star)$ is their midpoint. Hence $tilde(cX)$ is not convex.
]

= Hints for the exercises <sec-team-hints>

*@exr-team-pad-unique.* First let Player 3 guess uniformly at random after each message. What does this force about how often Player 2 guesses right? Which joint plans make Player 2 right for both values of the bit? Then try the pure strategy in which Player 3 guesses 0 after the left message and 1 after the right message.

*@exr-team-biased-bit.* For (i), find a strategy of Player 3 that ignores the message and holds the team to $1 - p$. For (iii), Player 3 best-responds separately after each message. For fixed $a, b$, choose $c$ and $d$ to equalize Player 3's two options. Then use that $g(alpha, beta) := alpha beta \/ (alpha + beta)$, with $g(0, 0) := 0$, is concave and positively homogeneous on $RR_(>= 0)^2$, so $g(vu) + g(vv) <= g(vu + vv)$.

*@exr-team-bilinear.* For (ii), write the utility at $e = f = 1\/2$ in terms of $a - b$ and $c - d$.

*@exr-team-uncorrelated-quadratics.* By @ex-team-pad-not-uncorrelated, $tilde(cX)$ is the set of vectors $vx(a, b; c, d)$. For the reverse inclusion, set $a := x[z_1] + x[z_3]$ and $b := x[z_4] + x[z_5]$, and treat the cases $a = 0$ and $b = 0$ separately.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
