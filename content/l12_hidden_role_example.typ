#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

The previous section defined hidden-role equilibria as team max-min equilibria of the _split-personality game_: each physical player is replaced by a Good copy and a Bad copy, and the Good team commits to a jointly optimal uncorrelated strategy. Because roles have not yet been dealt, teammates cannot share a private random bit before the game begins. The following three-player election, adapted from #citep(<CarminatiZFGS24>), isolates what that restriction costs. With indistinguishable Good roles the value is exactly $2/3$. Making the two Good cards distinguishable, a change that never appears in the payoff function, raises the value to $1$ by injecting _implicit correlation_ into the deal.

= An election example <sec-l12-election-example>

#example[A three-player election][
  There are three players, labeled $1, 2, 3$, and three role cards. Two of the cards are marked Good and one is marked Bad. The cards are shuffled and dealt privately, so the Bad card is equally likely to sit at any of the three seats. After a round of public communication, the three players vote simultaneously for a winner. If some player receives at least two votes, that player is elected and that player's team wins. If no player receives a majority, the Bad player wins by default.

  Payoffs are $0$--$1$: the Good team receives $1$ if a Good player is elected and $0$ otherwise. Communication is public, and the Good team cannot correlate using team-private randomness before the cards are dealt.
]

The protocol looks simple, and a majority of the seats are Good. The catch is that the Good players do not know which of the other two seats is their teammate, while the Bad player hears every message.

#theorem[Value of the indistinguishable-role election][
  In the election game with indistinguishable Good roles, the hidden-role value for the Good team is exactly $2/3$.
] <prop-l12-value-two-thirds>

#proof[
  We show matching lower and upper bounds.

  *Good can guarantee $2/3$.* Consider the strategy in which every Good player ignores the entire communication phase and votes for player $1$. There are always two Good players, so player $1$ receives at least two votes and is elected no matter how the Bad player votes. Player $1$ is Good with probability $2/3$, since the Bad card is uniformly random among the three seats. Hence this uncorrelated strategy wins with probability $2/3$. The same guarantee is obtained by using a public coin to select a seat $i$ uniformly and having every Good player vote for $i$.

  *Bad can hold Good to $2/3$.* Fix an arbitrary strategy of the Good team. Because the two Good cards are identical, a Good player at seat $i$ has a well-defined behavioral strategy as a function of the public history and of $i$'s private randomness: the only private observation is the indistinguishable Good label. Let the Bad player mimic that strategy, playing at whatever seat $j$ received the Bad card exactly as a Good player at seat $j$ would, with an independent copy of the corresponding private randomness.

  Under this mimic, every seat generates messages and votes from the same distribution that the Good strategy would have produced at that seat. The public transcript and the vote profile are therefore independent of the identity $B$ of the Bad player; they are distributed as if all three seats were Good. Let $W in {1, 2, 3} union {bot}$ denote the elected player, with $W = bot$ if no majority forms. Then $W$ is independent of $B$, while $B$ remains uniform on ${1, 2, 3}$.

  If $W = bot$, the Good team receives $0$. If $W = i$, the Good team wins if and only if $i != B$, which has probability $2/3$. In all, the winning probability is at most $2/3$.

  The two bounds match, so the value is exactly $2/3$. Public communication cannot improve on electing an arbitrary player: whenever Bad impersonates a Good teammate, the Good team learns nothing about $B$ from the transcript, and the best remaining action is to elect someone at random.
]

== Distinguishable Good roles

Now make one small change to the cards. Keep the payoffs, the voting rule, and the public communication channel exactly as they were, but print the two Good cards differently: one is marked Good and the other is marked Good'. The labels never enter the payoff function. A Good player still wins if and only if a Good player, of either label, is elected.

#theorem[Deterministic win from distinguishable roles][
  In the election game with distinguishable Good roles, the Good team has a strategy, using only public communication, that wins with probability $1$.
] <prop-l12-distinguishable-win>

#proof[
  The two Good players announce their printed labels honestly. After the three announcements are public, they vote according to the following rule. Write $S$ for the set of players who announced either Good or Good'.

  - If some player announced a string outside ${"Good", "Good'"}$, both Good players vote for the lowest-index player in $S$.
  - If two players announced Good, both Good players vote for the player who announced Good'.
  - If two players announced Good', both Good players vote for the player who announced Good.

  The rule is a deterministic function of the public transcript, so the two Good players always cast the same vote and a majority is guaranteed. It remains to check that the elected player is Good, no matter what the Bad player announces.

  #align(center)[
    #table(
      columns: (auto, auto, auto),
      align: left,
      inset: 6pt,
      stroke: 0.4pt + luma(170),
      table.header(
        [*Bad announces*],
        [*Public record*],
        [*Who is elected*],
      ),
      [neither Good nor Good'],
      [the two honest labels, plus one junk string],
      [a player in $S$, hence a true Good player],
      [Good],
      [two Good and one Good'],
      [the unique Good' announcement: the true Good' player],
      [Good'],
      [two Good' and one Good],
      [the unique Good announcement: the true Good player],
    )
  ]

  In the first row, the unique deviant announcement is Bad, so both members of $S$ are Good. In the second row, Bad has copied the Good label, and the leftover unique announcement is the true Good' card. The third row is symmetric. In every row the elected player is Good, so the strategy wins on every deal.
]

The Bad player's dilemma is complete. Announcing Good elects Good'; announcing Good' elects Good; announcing anything else identifies Bad as the deviant speaker.

#remark[Implicit correlation][
  The two theorems together show that a payoff-irrelevant distinction between Good cards changes the value from $2/3$ to $1$. What the distinction supplies is a piece of _correlated_ randomness that the hidden-role solution concept otherwise withholds.

  After the cards are dealt, the two Good seats hold complementary labels: exactly one of them is Good and the other is Good'. Equivalently, the deal samples a uniformly random permutation of the two labels. That permutation is perfectly negatively correlated across the two Good players. Once the labels are announced, the public transcript names a unique honest declaration that Bad cannot match, because Bad can copy at most one of the two labels.

  Hidden-role equilibrium forbids the Good team from sharing a private coin before roles are assigned. Such a coin would be team-private randomness of the kind that defines TMECor rather than TME, and in a hidden-role game it would let Good publicly reveal teammates: a long random string, checked for consistency, would expose any Bad impersonator and collapse the hidden-role structure. Distinguishable role cards smuggle the missing correlation into the type space itself. The players do not agree on a coin; the dealer hands them complementary private observations, and public speech makes just enough of that complementarity common knowledge to elect a teammate.

  The same phenomenon appears in Avalon. Replacing an ordinary Resistance configuration by Merlin together with two Mordreds does not merely multiply the Resistance value by $2/3$, even though Merlin then knows nothing and is murdered with probability $1/3$ at the end of the game. Merlin is a distinguishable Good card, so the deal again injects implicit correlation. The numerical comparison belongs to the Avalon section; the election game is the mechanism in isolation.
]

#lec_bibliography("meta/refs.bib", title: none)
