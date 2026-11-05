#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Fall 2026],
  title: "Hidden-role games and equilibrium concepts",
  instructor: [Brian Hu Zhang],
)

// This note develops slides 24--26 of L12: Team games.
// For integration into a longer team-games note, retain the sections below
// and remove the standalone header and bibliography.

In the team games considered so far, players on the same team share a utility function. In particular, when we allow correlation within a team, we have implicitly assumed that teammates know whom to coordinate with before the game begins. What happens when this assumption fails? In this lecture, we introduce _hidden-role games_, explain why the solution concepts developed so far are insufficient, and construct a new equilibrium concept from a suitably transformed team game. The construction and its commitment interpretation follow #citet(<Carminati24:HiddenRole>).

= Hidden-role games <sec-hidden-role-games>

#definition[ 
  A _hidden-role game_ (also called a _social deduction game_) is an adversarial team game in which one team, called *Good*, does not know who its teammates are. Players have roles that determine their team membership, but Good players may be unable to distinguish a teammate from a member of the opposing *Bad* team.
] <def-hidden-role-games>

An essential ingredient is *communication*. Players may talk to each other to establish trust, coordinate actions, or exchange information. Yet a Good player does not know whether the player receiving a message, or sending one, is Good or Bad. The Bad team may exploit this ambiguity by strategically choosing what to say and whom to impersonate.

Social deduction games such as _Avalon_ are natural examples. Similar information structures arise in distributed systems, network security, and federated learning: a collection of participants attempts to cooperate without being certain that everyone involved is trustworthy.

Our goal is to identify an appropriate notion of optimal play for the Good team. The obstacle is that the team's objective is collective, whereas its members are not initially able to identify one another.

= Why existing solution concepts fall short <sec-hidden-role-solution-concepts>

== Nash equilibrium

Recall that a Nash equilibrium is a strategy profile in which no player can increase their expected utility by changing their strategy unilaterally. If $vx^* = (x_1^*, dots, x_n^*)$ is a Nash equilibrium, then

$ u_i(x_i^*, vx_(-i)^*) >= u_i(x_i', vx_(-i)^*) quad "for all" i, x_i'. $

This condition is *individual*: it compares the status quo with a change by just one player, holding everyone else fixed. In a team game, however, two teammates may need to change their behavior together to achieve a higher common payoff, even if neither has an individually profitable deviation. Hence, Nash equilibria can be poor outcomes for the team, as in the communication-game example earlier in this lecture.

The problem becomes especially pronounced if there is just one team: we would like a solution concept to identify a *jointly optimal* team strategy, not merely a profile immune to unilateral changes.

== Team-correlated equilibrium

Recall the team min-max equilibrium with correlation (TMECor) from the previous sections. For a team of Players 1 and 2 facing Player 3, the correlated team chooses a joint distribution $mu$ over its members' pure strategies:

$ max_(mu in Delta(Pi_1 times Pi_2)) min_(y in Delta(Pi_3)) sum_((x_1, x_2) in Pi_1 times Pi_2) mu(x_1, x_2) u(x_1, x_2, y). $

Correlation is useful because teammates can agree on a joint plan, including the outcomes of shared random coins, before play begins. But this presupposes that they *know who their teammates are*. In hidden-role games, the Good players cannot, at the outset, securely identify their partners for such coordination. Granting them an arbitrary team-private correlation device would therefore assume away the central difficulty of the game.

Thus neither ordinary Nash equilibrium nor a conventional correlated team equilibrium captures the intended form of team optimization under hidden membership. We need a new solution concept.

= The split-personality construction <sec-split-personality>

The basic idea is to replace each physical player with two _role-specific personalities_. The resulting game is an adversarial team game whose players are the possible Good and Bad incarnations of each original player.

#definition[
  Given an $n$-player hidden-role game, its _split-personality game_ replaces every original player $i$ by a Good personality $i^G$ and a Bad personality $i^B$. Thus, the transformed game has $2n$ players, partitioned into the two teams

  $ N_G = {1^G, dots, n^G}, quad N_B = {1^B, dots, n^B}. $

  The strategy of $i^G$ specifies how original player $i$ would act when Good; the strategy of $i^B$ specifies how the same original player would act when Bad. Only the personality matching the realized role is active in any given play of the original game.
] <def-split-personality>

For example, the physical Player 1 is replaced by Good-P1 and Bad-P1. The former specifies Player 1's behavior in histories where Player 1 is Good; the latter specifies that player's behavior in histories where Player 1 is Bad. We do the same for every other player.

Importantly, the split is a *strategic representation*, not an announcement of anyone's hidden role. The information available to each personality must still agree with the original game's information restrictions. A Good personality cannot condition its strategy on another player's true role unless that information is available in the original game.

Once we have performed the split, we can use team-game solution concepts on the two resulting teams. In particular, we retain *uncorrelated* team strategies: the Good personalities do not receive a free, team-private correlation device that the original Good players lack.

= Hidden-role equilibrium and commitment <sec-hidden-role-equilibrium>

#definition[
  A _hidden-role equilibrium_ is a *team (uncorrelated) equilibrium* of the split-personality game. Equivalently, it describes an optimal team strategy for Good to commit to, anticipating an adversarial response by Bad.
] <def-hidden-role-equilibrium>

To make this interpretation explicit, let $vx^G = (x_1^G, dots, x_n^G)$ and $vy^B = (y_1^B, dots, y_n^B)$ be uncorrelated strategy profiles for the Good and Bad personalities, and write $U_G(vx^G, vy^B)$ for Good's expected payoff in the transformed game. The Good-first commitment problem has the form

$ max_(vx^G in cal(X)_G) min_(vy^B in cal(X)_B) U_G(vx^G, vy^B), $

where $cal(X)_G$ and $cal(X)_B$ are the allowable *product* strategy spaces of the two teams. Good commits to a contingent plan describing what each Good personality should do, while Bad chooses a response that minimizes Good's expected utility.

The interpretation is subtle. Good does *not* first discover the Good players and then select a coordinated strategy. Rather, it commits to a collection of role-contingent instructions that can be followed by whichever original players turn out to be Good. This is why the split-personality representation is appropriate for the hidden-membership setting.

== Why can we not exchange max and min?

For ordinary two-player zero-sum games with convex strategy sets and bilinear payoffs, the minimax theorem guarantees

$ max_(vx) min_(vy) u(vx, vy) = min_(vy) max_(vx) u(vx, vy). $

The hidden-role construction does *not* generally inherit these hypotheses. While each individual personality may randomize, the team is restricted to a product of uncorrelated strategies. Viewed as a joint strategy, this is not in general a convex set. Thus the standard minimax theorem cannot be invoked, and we cannot conclude that

$ max_(vx^G) min_(vy^B) U_G(vx^G, vy^B) = min_(vy^B) max_(vx^G) U_G(vx^G, vy^B). $

Accordingly, hidden-role equilibrium is *inherently asymmetric*: the Good-first commitment interpretation is part of the concept, rather than an arbitrary reordering of a saddle-point problem.

The slides provide a striking intuition for why this asymmetry matters. If the minimax theorem did hold in a hidden-role game, Good could cause the teams to become publicly identifiable by communicating sufficiently long random strings. In that case the defining uncertainty about teammates would effectively disappear. This observation is presented as motivation here; its formal argument is not developed in slides 24--26.

= Discussion <sec-hidden-role-discussion>

Hidden-role games force us to revisit the assumptions underlying familiar equilibrium concepts. Nash equilibrium does not optimize coordination within teams; team correlation presumes that teammates can identify each other before play. The split-personality construction instead represents every possible role of every player explicitly, and defines hidden-role equilibrium through the Good team's uncorrelated commitment against Bad.

The main lesson is that *uncertainty about who is on one's team changes the equilibrium problem itself*. It is not simply another uncertainty that can be handled by assuming a shared correlation device or appealing to the usual minimax theorem.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
