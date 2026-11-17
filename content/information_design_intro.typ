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

We now turn from analyzing equilibria in a fixed game to designing
commitments and recommendations that shape play. The following examples
introduce the central constraint: players who remain free to act must find
it optimal to follow the intended behavior.

== Stackelberg equilibrium <sec-l11-stackelberg>

Consider the following game, with the leader's payoff listed first in each
entry.

#align(center)[#block(breakable: false)[
  #table(
    columns: 3, align: center, inset: 7pt,
    [], [Follower: $X$], [Follower: $Y$],
    [Leader: $X$], [$(1, 1)$], [$(11, 0)$],
    [Leader: $Y$], [$(0, 0)$], [$(10, 1)$],
  )
]]

With simultaneous play, $X$ strictly dominates $Y$ for the leader by a
payoff gain of $1$ against either follower action. Since the follower's best
response to $X$ is also $X$, the unique Nash equilibrium is $(X,X)$ with
utilities $(1,1)$.

#paragraph-marker() *The effect of commitment.*~~ If the leader can publicly
commit before the follower responds, committing to $Y$ induces $(Y,Y)$ and
raises its payoff to $10$. The commitment must be binding, since otherwise
the leader would prefer to switch to $X$ after inducing $Y$.

More generally, let the leader commit to $X$ with probability $p$ and $Y$
with probability $1-p$. The follower observes the distribution, but not the
realized action, and receives

$ u_F (p,X)=p, quad u_F (p,Y)=1-p. $

Thus $Y$ is a best response exactly when $1-p>=p$, or $p<=1/2$. Subject to
this incentive constraint, the leader seeks to maximize

$ u_L (p,Y)=11p+10(1-p)=10+p. $

The optimum is $10.5$ at $p=1/2$, provided the indifferent follower chooses
$Y$. Inducing $X$ instead gives only $u_L (p,X)=p<=1$.

#definition[Stackelberg equilibrium][
  The leader chooses a committed strategy to maximize its utility,
  anticipating a follower best response. A _strong Stackelberg equilibrium_
  breaks ties among follower best responses in the leader's favor
  #citep(<vonStengelZamir2010>).
] <def-l11-stackelberg>

If the follower instead chooses $X$ at the tie, $10.5$ is only a supremum:
taking $p=1/2-epsilon$ for $0<epsilon<1/2$ makes $Y$ the unique best response
and gives the leader $10.5-epsilon$.

#paragraph-marker() *The recommendation view.*~~ The leader can recommend
$Y$, making obedience the follower's _direct strategy_. The constraint
$p<=1/2$ ensures that this strategy is a best response; the committed leader
needs no corresponding incentive constraint. In the
#lecture-link("efg_intro", <sec-game-trees>)[game tree] below, the follower's
information set captures its uncertainty about the realized leader action.

#figure(
  image("figures/information_design_intro/stackelberg_tree.svg", width: 90%,
    alt: "The leader's committed randomization chooses X with probability p or Y with probability 1 minus p, and recommends Y in either case. The follower's two decision nodes are in one information set. Choosing X or Y yields the four payoffs in the game table."),
  caption: [The interaction after the leader commits to $p$. The dashed
    information set hides the realized action, and green edges indicate
    obedience to the recommendation $Y$.],
) <fig-l11-stackelberg>

== Optimal correlated equilibria <sec-l11-optimal-ce>

Now let a separate mediator commit to a recommendation rule, leaving both
players free to act. Consider two drivers who can _Stop_ ($S$) or _Go_ ($G$)
at an intersection, with utilities

#align(center)[#block(breakable: false)[
  #table(
    columns: 3, align: center, inset: 7pt,
    [], [Player 2: $S$], [Player 2: $G$],
    [Player 1: $S$], [$(0, 0)$], [$(0, 1)$],
    [Player 1: $G$], [$(1, 0)$], [$(-5, -5)$],
  )
]]

The pure Nash equilibria are $(S,G)$ and $(G,S)$: each driver prefers to go
exactly when the other stops. If the other goes with probability $q$,
going earns $1-6q$ and stopping earns $0$, so indifference gives the
symmetric mixed equilibrium $q=1/6$, with expected utility $0$ for both.

#block(breakable: false)[
  #paragraph-marker() *A traffic light as mediator.*~~ Consider the
  recommendation distribution

  $
    mu_p (S,G)=p, quad mu_p (G,S)=1-p,
    quad mu_p (S,S)=mu_p (G,G)=0.
  $
]

This is a traffic light that always gives opposite signals. At $p=1/2$,
each driver is told to go half the time, but $(G,G)$ is never recommended,
whereas independent fair coins would recommend it with probability $1/4$.

If the other driver obeys, stopping at red gives $0$ instead of $-5$ from
going, while going at green gives $1$ instead of $0$ from stopping.
Obedience is therefore optimal conditional on every recommendation that
occurs, so $mu_p$ is a _correlated equilibrium_ for every $p in [0,1]$
#citep(<Aumann1974Mar>), as in the
#lecture-link("correlated", <def-ce>)[earlier definition].

Here, each driver's signal reveals the other's recommendation but not its
action, a distinction captured by the information sets below.

#figure(
  image("figures/information_design_intro/traffic_light_tree.svg", width: 100%,
    alt: "A mediator recommends Stop-Go with probability p or Go-Stop with probability 1 minus p. Player 1 chooses Stop or Go, followed in the drawing by Player 2. Within each recommendation branch, Player 2's two nodes form one information set, hiding Player 1's actual action. All eight action outcomes, including deviations and collisions, are shown."),
  caption: [The traffic-light game, with row player $R$ and column player
    $C$. The dashed information sets hide $R$'s action from $C$, so the
    drawing represents simultaneous driving decisions. Green edges
    indicate obedience; all deviations remain available.],
) <fig-l11-traffic-light>

#paragraph-marker() *Choosing an optimal equilibrium.*~~ Every $mu_p$
maximizes total welfare, because

$ bb(E)[u_1]=1-p, quad bb(E)[u_2]=p, quad bb(E)[u_1+u_2]=1, $

and no outcome has total welfare above $1$. Choosing $p=1/2$ also maximizes
the smaller expected utility, giving each driver $1/2$. Thus the fair
traffic light matches the welfare of the pure Nash equilibria while
sharing it equally, and improves both drivers' utilities over the symmetric
mixed equilibrium.

More generally, the mediator optimizes its objective subject to obedience
constraints for both players. These make the _direct profile_, in which
both obey, a Nash equilibrium of the game with the recommendation rule fixed.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
