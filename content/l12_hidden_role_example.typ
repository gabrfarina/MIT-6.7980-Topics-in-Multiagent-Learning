#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "Team games and hidden-role games",
  instructor: [Brian Hu Zhang],
)

The previous section defined a hidden-role equilibrium through the _split-personality game_: each physical player has a Good copy and a Bad copy, and the Good copies choose an optimal uncorrelated strategy. Before the roles are dealt, a player does not yet know who their teammates will be, so the Good team cannot arrange team-private shared randomness. The election game below, adapted from #citep(<CarminatiZFGS24>), shows why this matters. With two identical Good cards, Good wins with probability at most $2/3$. Merely labeling the cards Good and Good' raises the value to $1$, even though the labels never affect the payoffs.

= An election example <sec-l12-election-example>

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

#lec_bibliography("meta/refs.bib", title: none)
