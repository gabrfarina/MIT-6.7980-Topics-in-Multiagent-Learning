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

In the team games considered so far, players on the same team share a utility function. Correlated team strategies additionally allow teammates to agree on common randomness before the game begins. But what if players do not know who their teammates are? This is the challenge posed by _hidden-role games_. We will see why the equilibrium concepts discussed so far are inadequate, and how a split-personality construction leads to a new notion of optimal play. We follow the framework of #citet(<Carminati24:HiddenRole>).

We use the paper's notation: *MAX* is the uninformed team (usually *Good* team), and *MIN* is the informed adversarial team (usually *Bad* team). 

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

Communication is central to this setting, but is *not itself a required action in the base game*. #cite(<Carminati24:HiddenRole>) studies distinct _communication extensions_: no communication, public broadcast communication, and public plus pairwise private communication. In the latter two cases, players communicate through actions explicitly added to the game tree. A MAX player may be unsure whether a sender or recipient is an ally, so MIN can strategically exploit messages and trust.

Social deduction games such as _Avalon_ are natural examples. Similar information structures arise in distributed systems, network security, and federated learning: a collection of participants attempts to cooperate without being certain that everyone involved is trustworthy.

Our goal is to identify an appropriate notion of optimal play for team MAX. The obstacle is that the team's objective is collective, whereas its members are not initially able to identify one another.

= Why existing solution concepts fall short <sec-hidden-role-solution-concepts>

== Nash equilibrium

Recall that a Nash equilibrium is a strategy profile in which no player can increase their expected utility by changing their strategy unilaterally. If $vx^* = (x_1^*, dots, x_n^*)$ is a Nash equilibrium, then

$ u_i(x_i^*, vx_(-i)^*) >= u_i(x_i', vx_(-i)^*) quad "for all" i, x_i'. $

This condition is *individual*: it compares the status quo with a change by just one player, holding everyone else fixed. In a team game, however, two teammates may need to change their behavior together to achieve a higher common payoff, even if neither has an individually profitable deviation. Hence, Nash equilibria can be poor outcomes for the team, as in the communication-game example earlier in this lecture.

The problem becomes especially pronounced if there is just one team: we would like a solution concept to identify a *jointly optimal* team strategy, not merely a profile immune to unilateral changes.

== Team-correlated equilibrium

Recall the team min-max equilibrium with correlation (TMECor) from the previous sections. For a team of Players 1 and 2 facing Player 3, the correlated team chooses a joint distribution $mu$ over its members' pure strategies:

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

#cite(<Carminati24:HiddenRole>) also considers a _coordinated split-personality form_, $"CSplit"(Gamma)$: all MIN personalities are merged into a single adversary who receives all their observations and chooses all their actions. The resulting game has $n+1$ players. This is a stronger model of the adversary, not a property implied by hidden roles alone.

For either form, MAX's teammates are not granted an arbitrary correlation device before team assignment. We instead use the uncorrelated team max-min solution concept developed earlier in the lecture.

= Hidden-role equilibrium and commitment <sec-hidden-role-equilibrium>

#definition[
  For a fixed communication-extended split-personality game, a _team max-min equilibrium_ (TME) is a MAX strategy profile that maximizes MAX's expected utility against a best-responding MIN team, with each team's strategy space restricted to *uncorrelated* profiles of individual mixed strategies. A _hidden-role equilibrium_ (HRE) is defined using this TME construction; formally, #cite(<Carminati24:HiddenRole>) specifies the communication model, whether MIN is uncoordinated or coordinated, and an approximation tolerance when communication is allowed.
] <def-hidden-role-equilibrium>

Let $vx = (x_1^+, dots, x_n^+)$ and $vy = (y_1^-, dots, y_n^-)$ be uncorrelated strategy profiles for the MAX and MIN personalities. For the uncoordinated split-personality game *without added communication*, the TME value is

$ "TMEVal"("USplit"(Gamma)) = max_(vx in product_(i=1)^n Delta(Pi_i^+)) min_(vy in product_(i=1)^n Delta(Pi_i^-)) u(vx, vy). $

Here $Pi_i^+$ and $Pi_i^-$ denote the sets of pure strategies for the corresponding role-specific players; the expectation over the random team assignment and subsequent play is included in $u(vx, vy)$. Here the product symbols describe independent strategy choices by the individual personalities, *not* arbitrary correlated team distributions. An optimal MAX strategy profile attains the outer maximum for this fixed finite game.

The *commitment interpretation* is that MAX fixes a collection of role-contingent strategies first. MIN then chooses a best response *knowing the entire MAX strategy*. MAX does not first discover who its teammates are: each physical player follows its MAX-personality policy if assigned to MAX.

#remark[
  *Communication-dependent values and equilibria.* #cite(<Carminati24:HiddenRole>)'s Definitions 3.5--3.6 distinguish $c in {"none", "pub", "priv"}$ and uncoordinated versus coordinated MIN. For finite message-space size $M$ and $R$ communication rounds between moves, define

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

In fact, reversing commitment order would let MAX coordinate on a secret, sufficiently long random passphrase that MIN has not learned, which can reveal who is on which team. This motivates why MIN is allowed to know MAX's committed strategy first, not conversely. We state this observation as motivation (see Section 6.2 of #cite(<Carminati24:HiddenRole>) for details).

= Discussion <sec-hidden-role-discussion>

Hidden-role games force us to revisit the assumptions underlying familiar equilibrium concepts. Nash equilibrium does not optimize coordination within teams; team correlation presumes that teammates can identify each other before play. The split-personality construction instead represents every possible role of every player explicitly, and defines hidden-role equilibrium through team MAX's uncorrelated commitment against MIN.

The main lesson is that *uncertainty about who is on one's team changes the equilibrium problem itself*. It is not simply another uncertainty that can be handled by assuming a shared correlation device or appealing to the usual minimax theorem.

#lec_bibliography("meta/refs.bib", title: none)
