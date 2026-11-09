#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

// Parts 1 and 4 of the team-games lecture (team games and the TME, and computational
// hardness). Parts 2 and 3 (correlation and the realization form) are in
// team_games_tmecor.typ, which picks up where @sec-team-tme ends.

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

The two orders of play explain the gap. In the min-max problem the adversary commits first, and the team then tailors its message to the adversary's known guesses. In the max-min problem the team commits first. A message that tells Player 2 anything about the bit then tells Player 3 the same thing, so the team can do no better than having Player 2 guess blindly. For instance, if Player 1 sends the bit in the clear, Player 3 copies Player 2's guess and the team gets $0$. The team's utility is not concave in $(a, b; c, d)$, so the minimax theorem does not apply. The next part of the lecture shows that shared randomness closes the gap.
// Merge: link "The next part of the lecture" to @sec-team-correlation in part 2.

== Why not Nash equilibrium? <sec-team-nash>

We could instead treat the teammates as separate players and look for a #lecture-link("nfgs_nash", <def-nash-equilibrium>)[Nash equilibrium] of the three-player game. A Nash equilibrium is never better for the team than a TME. In a Nash equilibrium the adversary best-responds to the teammates' strategies $(vmu_1, vmu_2)$, so the team gets $min_vy EE[u(pi_1, pi_2, vy)]$, which is at most the TME value by @def-team-tme. #citet(<Stengel97:Team>) show that a TME, together with a suitable strategy of the adversary, is itself a Nash equilibrium. So the TME is the Nash equilibrium that the team likes best.

Other Nash equilibria can be much worse for the team. A Nash equilibrium rules out only _unilateral_ deviations, and a team may be stuck where only a joint deviation helps.

#example[Miscoordination][
  Two teammates each choose $L$ or $R$, and the adversary has no move. The team gets $1$ if both choose $L$, $epsilon in (0, 1)$ if both choose $R$, and $0$ otherwise. The TME value is $1$, attained at $(L, L)$. The profile $(R, R)$ is a Nash equilibrium, since a teammate that switches alone lowers the payoff from $epsilon$ to $0$. Its value $epsilon$ is arbitrarily far below the TME value.
] <ex-team-coordination>

This is why we optimize over the team's strategy as a whole, as in @def-team-tme, rather than ask that each teammate best-respond. The price is that the TME problem is nonconvex, and @sec-team-hardness shows that it is hard to solve in general.

= Computational hardness <sec-team-hardness>

In a two-player zero-sum extensive-form game, the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form] gives a maxmin strategy by a linear program of polynomial size. For teams, finding the value is NP-hard, even without an adversary. The reason is that the team, viewed as one player, can forget what one teammate knew when the other acts.
The reduction below is due to #citet(<Koller92:Complexity>), who phrased it as a single player with imperfect recall.
// Merge: link "can forget" to @sec-team-imperfect-recall in part 2.

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
  With no adversary, the team's utility is $EE_((pi_1, pi_2) ~ vmu) [u(pi_1, pi_2)]$, a linear function of $vmu in Delta(Pi_1 times Pi_2)$. Its maximum over the simplex is attained at a vertex, a point mass on a joint plan. A point mass is the product of two point masses, so it is uncorrelated, and the TME value is at least the TMECor value. The reverse inequality holds since every uncorrelated strategy is correlated. With an adversary, the team's guarantee $min_vy EE[u]$ is a minimum of linear functions of $vmu$. It is concave rather than linear, so its maximum need not be at a vertex. In the communication game it is $1\/2$ at the one-time pad, the correlated strategy of the next part of the lecture, but $0$ at every joint plan.
  // Merge: link "one-time pad" to @sec-team-one-time-pad in part 2.
]

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
