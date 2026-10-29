#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Prepared with OpenAI Codex assistance for exposition, Typst, figures, and
// computational checks.

= Introduction: commitment and recommendations <sec-l11-intro>

We begin with two examples of how commitment and communication can change
strategic behavior: a leader committing to a strategy, and a mediator
coordinating players through recommendations. Both illustrate how to choose
a committed strategy that makes following a recommendation a best response
#citep(<Zhang2026Mechanism>, [slides 2--6]).

== Stackelberg equilibrium <sec-l11-stackelberg>

Consider the following game, where each entry gives the leader's utility
first and the follower's utility second.

#align(center)[#block(breakable: false)[
  #table(
    columns: 3, align: center, inset: 7pt,
    [], [Follower: $X$], [Follower: $Y$],
    [Leader: $X$], [$(1, 1)$], [$(11, 0)$],
    [Leader: $Y$], [$(0, 0)$], [$(10, 1)$],
  )
]]

If the players act simultaneously, $X$ strictly dominates $Y$ for the
leader, since switching to $X$ increases its payoff by $1$ against either
follower action. The follower's unique best response to $X$ is also $X$,
so the unique Nash equilibrium is $(X,X)$, with utilities $(1,1)$.

#paragraph-marker() *The effect of commitment.*~~ Suppose instead that the
leader can publicly and irrevocably commit before the follower responds.
Committing to $Y$ induces the follower to choose $Y$ as well, raising the
leader's payoff from $1$ to $10$. Although $Y$ is dominated in the
simultaneous game, committing to it changes the follower's response.

The leader can do even better by committing to play $X$ with probability
$p$ and $Y$ with probability $1-p$. The follower observes this distribution
but must act without seeing the leader's realized action, so its expected
utilities are

$ u_F (p,X)=p, quad u_F (p,Y)=1-p. $

The follower therefore prefers $Y$ when $p<1/2$, prefers $X$ when $p>1/2$,
and is indifferent at $p=1/2$. Against a follower who chooses $Y$, the
leader receives

$ u_L (p,Y)=11p+10(1-p)=10+p. $

Increasing $p$ helps the leader as long as the follower continues to choose
$Y$. Thus, by taking $p=1/2-epsilon$ for $0<epsilon<1/2$, the leader obtains
$10.5-epsilon$ with a unique follower best response. Inducing $X$ instead
gives only $u_L (p,X)=p<=1$, so it cannot improve on this choice.

#definition[Stackelberg equilibrium][
  In a Stackelberg equilibrium, the leader chooses a committed strategy to
  maximize its utility, anticipating a best response from the follower.
  A _strong Stackelberg equilibrium_ uses favorable tie-breaking: whenever
  the follower has several best responses, it selects one that gives the
  leader the greatest utility #citep(<vonStengelZamir2010>).
] <def-l11-stackelberg>

With favorable tie-breaking, the leader can take $p=1/2$ and receive
$10.5$. If the follower chooses $X$ at the tie, this value is only a
supremum, approached by taking $p$ just below $1/2$. In either case, the
improvement relies on a binding commitment: without it, the leader would
prefer to switch to $X$ with certainty after inducing the follower to
choose $Y$, making the promised mixture unconvincing.

#paragraph-marker() *The recommendation view.*~~ The leader can accompany
its commitment with the recommendation that the follower play $Y$.
Following this recommendation is the follower's _direct strategy_. In the
tree below, the follower knows $p$ but cannot distinguish the two decision
nodes, since the realized leader action is hidden. This is the role of an
information set in the #lecture-link("efg_intro", <sec-game-trees>)[game-tree representation].

#figure(
  image("figures/information_design_intro/stackelberg_tree.svg", width: 90%,
    alt: "The leader's committed randomization chooses X with probability p or Y with probability 1 minus p, and recommends Y in either case. The follower's two decision nodes are in one information set. Choosing X or Y yields the four payoffs in the game table."),
  caption: [The interaction after the leader commits to $p$. The dashed
    information set hides the realized action, and green edges indicate
    obedience to the recommendation $Y$.],
) <fig-l11-stackelberg>

The direct strategy is a best response exactly when $1-p>=p$, so this
incentive constraint limits the leader's choice of $p$. No corresponding
best-response constraint is needed for the leader, whose behavior is fixed
by the commitment.

== Optimal correlated equilibria <sec-l11-optimal-ce>

Now suppose a separate mediator commits to a recommendation rule while
both players remain free to act. Consider two drivers approaching an
intersection, each of whom can _Stop_ ($S$) or _Go_ ($G$), with utilities

#align(center)[#block(breakable: false)[
  #table(
    columns: 3, align: center, inset: 7pt,
    [], [Player 2: $S$], [Player 2: $G$],
    [Player 1: $S$], [$(0, 0)$], [$(0, 1)$],
    [Player 1: $G$], [$(1, 0)$], [$(-5, -5)$],
  )
]]

Each driver's best response is to go if the other stops and to stop if
the other goes, so $(S,G)$ and $(G,S)$ are Nash equilibria. There is also
a symmetric mixed equilibrium: if the other driver goes with probability
$q$, going earns $1-6q$ while stopping earns $0$. Equating these payoffs
gives $q=1/6$ and expected utility $0$ for both drivers.

#paragraph-marker() *A traffic light as mediator.*~~ A traffic light can
coordinate the drivers by recommending $(S,G)$ with probability $p$ and
$(G,S)$ with probability $1-p$:

$
  mu_p (S,G)=p, quad mu_p (G,S)=1-p,
  quad mu_p (S,S)=mu_p (G,G)=0.
$

At $p=1/2$, each driver is told to go half the time, yet they are never told
to go together. This correlation matters: independent fair coins would
recommend $(G,G)$ with probability $1/4$.

To check incentives, suppose the other driver obeys its light. A driver
who sees red knows the other will go, so stopping gives $0$ while deviating
gives $-5$. A driver who sees green knows the other will stop, so going
gives $1$ while deviating gives $0$. Following the recommendation is
therefore a best response whenever it occurs, which makes $mu_p$ a
_correlated equilibrium_ for every $p in [0,1]$. This is the conditional
obedience requirement introduced by Aumann #citep(<Aumann1974Mar>) and
formalized in #lecture-link("correlated", <def-ce>)[the earlier equilibrium notes].

The tree below represents the resulting interaction. Since the lights are
always opposite, each driver's own recommendation reveals the other's
recommendation in this example, but the other's actual action remains
unobserved.

#figure(
  image("figures/information_design_intro/traffic_light_tree.svg", width: 100%,
    alt: "A mediator recommends Stop-Go with probability p or Go-Stop with probability 1 minus p. Player 1 chooses Stop or Go, followed in the drawing by Player 2. Within each recommendation branch, Player 2's two nodes form one information set, hiding Player 1's actual action. All eight action outcomes, including deviations and collisions, are shown."),
  caption: [The traffic-light game, with row player $R$ and column player
    $C$. The dashed information sets hide $R$'s action from $C$, so the
    drawing represents simultaneous driving decisions. Green edges
    indicate obedience; all deviations remain available.],
) <fig-l11-traffic-light>

#paragraph-marker() *Choosing an optimal equilibrium.*~~ If the mediator
seeks to maximize total welfare, every $mu_p$ above is optimal, since

$ bb(E)[u_1]=1-p, quad bb(E)[u_2]=p, quad bb(E)[u_1+u_2]=1, $

and no outcome in the table has total welfare greater than $1$. Choosing
$p=1/2$ shares this welfare equally, giving each driver $1/2$ and maximizing
the smaller expected utility. The pure Nash equilibria attain the same
total welfare but favor one driver, whereas the fair traffic light gives
both drivers more than the symmetric mixed Nash equilibrium.

The mediator can choose a different objective, but its recommendation rule
must still satisfy the correlated equilibrium constraints. These ensure
that the _direct profile_ in which both drivers obey is a Nash equilibrium
with the mediator's strategy fixed. Unlike the Stackelberg example,
obedience must be optimal for both players.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
