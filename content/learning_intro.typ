#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: 4,
  date: [Thu, Sep 24, 2026],
  title: "Learning in games: Foundations",
)

#v(.8cm)
With this lecture we begin to explore what it means to "learn" in a game, and how that "learning", which is intrinsically a _dynamic_ and _local_ (per-player) concept, relates to the much more _static_ and _global_ concept of game-theoretic equilibrium.

= Hindsight rationality and $Phi$-regret <sec-phi-regret>

What does it mean to "learn" in games? Multiple answers are correct. However, today we focus on a powerful answer through the concept of _hindsight rationality_.

Take the point of view of _one_ player in a game, and denote with $cX$ be their set of available strategies. In #lecture-link("nfgs_nash", <sec-normal-form>)[normal-form games], we have seen that a strategy is just a distribution over the set of available actions $A$ for the player, so $cX = Delta(A)$. This framework will seamlessly apply to imperfect-information extensive-form games (#lecture-link("efg_intro")) as well, where $cX$ will be a more complicated (but still convex and compact) set of strategies.
At each time $t =1,2,...$, the player will play some strategy $vx^((t)) in cX$, receive some form
of feedback, and will incorporate that feedback to formulate a "better" strategy $vx^((t+1)) in cX$ for the next repetition of the game. A typical (and natural) choice of "feedback" is just the utility of the player, given what all the other agents played. However, for the purposes of the abstract model we are building today, let's not make any assumptions about how the feedback is assigned; we will strive to build algorithms that perform competitively under _any_ feedback---even adversarial one.

Now suppose that the game is played infinite times, and looking back at what was played by the player
we realize that every single time the player played a certain strategy $vx$, they would have been strictly better
by consistently playing different strategy $vx'$ instead. Can we really say that the player has "learnt" how to play? Perhaps not.

This concept goes under the name of _hindsight rationality_:

#definition[Hindsight rationality, informal][
  The player has "learnt" to play the game if
  looking back at the history of play, they cannot think of any transformation $phi.alt : cX -> cX$ of their
  strategies that, when applied at the whole history of play, would have given strictly better utility to the player.
]

We have thus arrived at the following formalization.

#definition[$Phi$-regret minimizer][
  Given the convex and compact strategy set $cX$ and a set $Phi$ of linear transformations $phi.alt:cX->cX$, a _$Phi$-regret minimizer for the set $cX$_ is a model for a decision maker that repeatedly interacts with a black-box environment. At each time $t$, the regret minimizer interacts with the environment through two operations:
  - `NextStrategy()` takes no input, and has the effect that the regret minimizer will output an element $vx^((t)) in cX$.
  - `ObserveUtility`$(u^((t)))$ provides the environment's feedback to the regret minimizer, in the form of a linear utility function $u^((t)) : cX -> RR$ that evaluates how good the last-output point $vx^((t))$ was.
    The utility function can depend adversarially on the outputs $vx^((1)), ..., vx^((t))$.

  Its quality metric is its cumulative _$Phi$-regret_, defined as the quantity
  $
    Phi"-Reg"^((T)) := max_(hat(phi.alt) in Phi) {sum_(t=1)^T u^((t))(hat(phi.alt)(vx^((t)))) - u^((t))(vx^((t)))},
  $ <defphiregret>
  The goal for a $Phi$-regret minimizer is to guarantee that its $Phi$-regret grows asymptotically sublinearly as time $T$ increases, no matter the sequence of utility functions $u^((t))$.
]<defphirm>

Calls to `NextStrategy` and `ObserveUtility` keep alternating to each other: first, the regret minimizer will output a point $vx^((1))$, then it will received feedback $u^((1))$ from the environment, then it will output a new point $vx^((2))$, and so on.
The decision making encoded by the regret minimizer is _online_, in the sense that at each time $t$, the output of the regret minimizer can depend on the prior outputs $vx^((1)), ...,vx^((t-1))$ and corresponding observed utility functions $u^((1)),...,u^((t-1))$, but no information about future utilities is available.

== Notable choices of transformations $Phi$ <sec-regret-transformations>
The size of the set of transformations $Phi$ considered by the player defines
a natural notion of how "rational" the agent is. There are several choices of interest for $Phi$ for a normal-form strategy space $cX = Delta(A)$.
- $Phi =$ set of _all_ stochastic matrices, mapping $Delta(A) -> Delta(A)$. This notion of $Phi$-regret is known under the name _swap regret_. This notion is related to convergence to the set of #lecture-link("correlated", <def-ce>)[correlated equilibria].
- $Phi =$ set of all "probability mass transport" on $cX$, defined as
  $Phi = {phi.alt_(a-> b)}_(a, b in A)$, where
  $
    (
      phi.alt_(a-> b)(vx)
    )_s := cases(
      0 & "if " s = a quad ("remove mass from " a "..."),
      x_b + x_a & "if " s = b quad ("... and give it to " b),
      x_s & "otherwise."
    )
  $
  This is known as _internal regret_.
  #theorem[Informal; formal version in @thmce-formal][
    When all agents in a multiplayer general-sum normal-form game play so that their internal or swap regret grows sublinearly, their average correlated distribution of play converges to the set of _correlated equilibria_ of the game.
  ] <thmce-informal>

  In sequential games, the above concept extends to $Phi =$ a particular set of linear transformations called _trigger deviation functions_. It is known that in this case the $Phi$-regret can be efficiently bounded with a polynomial dependence on the size of the game tree. The reason why this choice of deviation functions is important is given by the following fact.
  #theorem[Informal][
    When all agents in a multiplayer general-sum extensive-form game play so that their $Phi$-regret relative to trigger deviation functions grows sublinearly, their average correlated distribution of play converges to the set of _extensive-form correlated equilibria_ of the game.
  ]

- $Phi =$ constant transformations. In this case, we are only requiring that the player not regret substituting _all_ of the strategies they played with the _same_ strategy $hat(vx) in Delta(A)$. $Phi$-regret according to this set of transformations $Phi$ is usually called _external_ regret, or more simply just _regret_. While this seems like an extremely restricted notion of rationality, it actually turns out to be already extremely powerful. We will spend the rest of this class to see why.
  #theorem[Informal; formal version in @thmce-formal][
    When all agents in a multiplayer general-sum normal-form game play so that their external regret grows sublinearly, their average correlated distribution of play converges to the set of _coarse correlated equilibrium_ of the game.
  ] <thmcce-informal>
  #corollary[Informal][
    When all agents in a two-player zero-sum normal-form game play so that their external regret grows sublinearly, their average strategies converge to the set of _Nash equilibria_ of the game.
  ]

== An important special case: regret minimization <sec-external-regret>

The special case where $Phi$ is chosen to be the set of constant transformations is so important that it warrants its own special definition and notation.

#definition[Regret minimizer][
  Let $cX$ be a set. An _external regret minimizer for $cX$_---or simply _#quote[regret minimizer for $cX$]_---is a $Phi^"const"$-regret minimizer for the special set of _constant_ transformations
  $
    Phi^"const" := {phi.alt_xhat: vx |-> xhat}_(xhat in cX).
  $
  Its corresponding $Phi^"const"$-regret is called "_external regret_" or simply "_regret_", and it is indicated with
  $
    "Reg"^((T)) := max_(xhat in cX) {sum_(t=1)^T u^((t))(xhat) - u^((t))(vx^((t)))}.
  $
] <def-external-regret>
Again, the goal for a regret minimizer is to ensure its cumulative regret $"Reg"^((T))$ grows sublinearly in $T$.

An important result asserts the existence of algorithms that guarantee sublinear regret for any convex and compact domain $cX$, typically of the order $"Reg"^((T)) = O(sqrt(T))$ asymptotically.

As we will show below, external regret minimization alone is enough to guarantee convergence to Nash equilibrium in two-player zero-sum games, to coarse correlated equilibrium in multiplayer general-sum games, to best responses to static stochastic opponents in multiplayer general-sum games, and much more.

#paragraph-marker() *Teaser: From regret minimization to $Phi$-regret minimization.*~~
As discussed, regret minimization is _one_ instantiation of $Phi$-regret minimization---and perhaps the smallest sensible instantiation. Then, clearly, coming up with a regret minimizer for a set $cX$ cannot be harder than the problem of coming up with a $Phi$-regret minimizer for $cX$ for richer sets of transformation functions $Phi$. It might then seem surprising that there exists a construction that reduces $Phi$-regret minimization to regret minimization. #lecture-link("phi_regret", none)[] develops this reduction.

= Applications of regret minimization <sec-learning-applications>

To establish regret minimization as a meaningful abstraction for learning
in games, we check that regret minimizing and $Phi$-regret minimizing dynamics indeed lead to the expected behavior in common scenarios.

#definition[Canonical learning setup][In the cases that we will mention, a recurring idea will be to consider the setup in which all players $i in [n]$ play according to the outputs $vx_i^((t))$ of a $Phi$-regret minimizer. At each iteration, the utility function that each player $i$ observes from the environment is the utility function $u_i$ of that player, evaluated in the strategies played by all players, that is,
  $ u^((t)) : Delta(A_i) -> RR qquad qquad u^((t)) (vx_i) := u_i lr(size: #70%, (vx_i, vx^((t))_(-i))). $
  Given its importance, we give to this natural setup the name of _canonical learning setup_.
] <def-canonical-learning>

== Learning a best response against stochastic opponents

As a first smoke test, let's verify that over time a regret minimizer would learn how to best respond to static, stochastic opponents. Specifically, consider this scenario. We are playing a repeated $n$-player general-sum game with multilinear utilities (this captures normal-form game and extensive-form games alike), where Players $i = 1, ..., n-1$ play stochastically, that is, at each $t$ they independently sample a strategy $vx_i^((t)) in cX_(i)$ from the same fixed distribution (which is unknown to any other player). Formally, this means that
$
  EE \[vx_i^((t))\] = overline(vx)_i qquad forall i =1,...,n -1, quad t = 1,2,....
$

Player $n$, on the other hand, is learning in the game, picking strategies according to some algorithm that guarantees sublinear external regret, where the feedback observed by Player $n$ at each time $t$ is their own linear utility function:
$
  u^((t)) := cX_n in.rev vx_n |-> u_n (vx_1^((t)), ..., vx_(n-1)^((t)), vx_n).
$

Then, the average of the strategies played by Player~$n$ converges almost surely to a best response to $overline(vx)_1, ...,overline(vx)_(n-1)$, that is,
$
  1 / T sum_(t=1)^T vx_n^((t)) quad limits(-->)^"a.s." quad argmax_(hat(vx)_n in cX_n) {
    u_n (overline(vx)_1, ..., overline(vx)_(n-1), hat(vx)_n)
  }.
$
(You should try to prove this!)

== Learning a Nash equilibrium in two-player zero-sum games <sec-learning-zero-sum>

It turns out that regret minimization can be used to converge to bilinear saddle points, that is solutions to problems of the form
#set math.equation(numbering: "(1)")
$
  max_(vx in cX) min_(vy in cY) vx^top U vy,
$ <bspp>
#set math.equation(numbering: none)
where $cX$ and $cY$ are convex compact sets and $U$ is a matrix. These types of optimization problems are pervasive in game-theory. The canonical prototype of bilinear saddle point problem is the computation of Nash equilibria in two-player zero-sum games (either normal-form or extensive-form). There, a Nash equilibrium is the solution to (@bspp) where $cX$ and $cY$ are the strategy spaces of Player~$1$ and Player~$2$ respectively (probability simplexes for normal-form games or sequence-form polytopes for extensive-form games), and $U$ is the payoff matrix for Player~$1$. Other examples include social-welfare-maximizing correlated equilibria and optimal strategies in two-team zero-sum adversarial team games.

The idea behind using regret minimization to converge to bilinear saddle-point problems is to use _self play_. We instantiate two regret minimization algorithms, $cR_cX$ and $cR_cY$, for the domains of the maximization and minimization problem, respectively. At each time $t$ the two regret minimizers output strategies $vx^((t))$ and $vy^((t))$, respectively. Then, they receive feedback $u_cX^((t)), u_cY^((t))$ defined as
$
  u^((t))_cX : vx |-> (U vy^((t)))^top vx ,qquad quad
  u^((t))_cY : vy |-> -(U^top vx^((t)))^top vy.
$

We can summarize the process pictorially as follows.

#align(center, image(
  "figures/learning_intro/self_play.svg",
  width: 10cm,
  alt: "Self-play flow: two regret minimizers exchange strategies and utility feedback.",
))

A well known folk theorem establish that the pair of average strategies produced by the regret minimizers up to any time $T$ converges to a saddle point of (@bspp), where convergence is measured via the _saddle point gap_
$
  0 <= gamma(vx, vy) := (max_(xhat in cX) {xhat^top U vy} - vx^top U vy) + (
    vx^top U vy - min_(yhat in cY) {vx^top U yhat}
  ) = max_(xhat in cX) {xhat^top U vy} - min_(yhat in cY) {vx^top U yhat}.
$
A point $(vx , vy) in cX times cY$ has zero saddle point gap if and only if it is a solution to (@bspp).

#theorem[
  Consider the self-play setup summarized in the figure above, where $cR_cX$ and $cR_cY$ are regret minimizers for the sets $cX$ and $cY$, respectively. Let $"Reg"_cX^((T))$ and $"Reg"_cY^((T))$ be the (sublinear) regret cumulated by $cR_cX$ and $cR_cY$, respectively, up to time $T$, and let $overline(vx)^((T))$ and $overline(vy)^((T))$ denote the average of the strategies produced up to time $T$. Then, the saddle point gap $gamma(overline(vx)^((T)), overline(vy)^((T)))$ of $(overline(vx)^((T)), overline(vy)^((T)))$ satisfies
  $
    gamma(overline(vx)^((T)), overline(vy)^((T))) = ("Reg"_cX^((T)) + "Reg"_cY^((T))) / T -> 0 qquad "as " T->oo.
  $
] <thm-regret-gap>
#proof[
  By definition of regret,
  $
    & ("Reg"_cX^((T)) + "Reg"_cY^((T))) / T \
    & #h(5mm) = 1 / T max_(xhat in cX) {sum_(t=1)^T u_cX^((t))(xhat) } - 1 / T sum_(t=1)^T u_cX^((t))(vx^t)
      +
      1 / T max_(yhat in cY) {sum_(t=1)^T u_cY^((t))(yhat) } - 1 / T sum_(t=1)^T u_cY^((t))(vy^t) \
    & #h(5mm) = 1 / T max_(xhat in cX) {sum_(t=1)^T u_cX^((t))(xhat) } + 1 / T max_(yhat in cY) {sum_(t=1)^T u_cY^((t))(
          yhat
        ) } #h(.6cm) ("since" u^((t))_cX (vx^((t))) + u^((t))_cY ( vy^((t))) = 0) \
    & #h(5mm) = max_(xhat in cX) { xhat^top U overline(vy)^((T)) } - min_(yhat in cY) { (
          overline(vx)^((T))
        )^top U yhat } \
    & #h(5mm) = gamma(overline(vx)^((T)), overline(vy)^((T))).
  $
  Letting $T -> oo$ and using the sublinearity of regret, we obtain the statement.
]

== Proof of the minimax theorem <sec-learning-minimax>

The very _existence_ of regret minimizers is a powerful enough fact to imply the minimax theorem!

#theorem[Minimax theorem][
  Let $cX$ and $cY$ be convex compact sets, and let $U$ be a matrix. Suppose that a regret minimizer $cR_cX$ for set $cX$ guaranteeing sublinear regret no matter the sequence of utilities can be constructed. Then,
  $ max_(vx in cX) min_(vy in cY) vx^top U vy = min_(vy in cY) max_(vx in cX) vx^top U vy. $
]
#proof[
  One direction of the equality, specifically
  $
    max_(vx in cX) min_(vy in cY) vx^top U vy <= min_(vy in cY) max_(vx in cX) vx^top U vy,
  $
  follows from definition (this is often called _weak duality_).

  To show the reverse inequality, we will interpret the bilinear saddle point $min_(vy in cY) max_(vx in cX) vx^top U vy$ as a repeated game. At each time $t$, we will let a regret minimizer $cR_cX$ pick actions $vx^((t)) in cX$, whereas we will always assume that $vy^((t)) in cY$ is chosen by the environment to best respond to $vx^((t))$, that is,
  $
    vy^((t)) in argmin_(vy in cY) (vx^((t)))^top U vy.
  $
  The utility function observed by $cR_cX$ at each time $t$ is set to the linear function
  $
    u^((t))_cX (vx) = vx^top U vy^((t)).
  $
  Letting $overline(vx)^((T)) in cX$ and $overline(vy)^((T)) in cY$ be the average strategies output up to time $T$, that is,
  $
    overline(vx)^((T)) := 1 / T sum_(t=1)^T vx^((t)) qquad overline(vy)^((T)) := 1 / T sum_(t=1)^T vy^((t)),
  $
  then we have
  $
    max_(vx in cX) min_(vy in cY) vx^top U vy >= min_(vy in cY) {
      (overline(vx)^((T)))^top U vy
    } = 1 / T min_(vy in cY) sum_(t=1)^T (vx^((t)))^top U vy >= 1 / T sum_(t=1)^T (vx^((t)))^top U vy^((t)).
  $
  The important insight is that the right-hand side can be related to the regret incurred on $cX$: by definition,
  $
    1 / T sum_(t=1)^T (vx^((t)))^top U vy^((t)) & = -"Reg"_cX^((T)) / T + 1 / T max_(vx in cX) {
                                                    sum_(t=1)^T vx^top U vy^((t))
                                                  } \
                                                & = -"Reg"_cX^((T)) / T+ max_(vx in cX)
                                                  vx^top U overline(vy)^((T)) \
                                                & >= -"Reg"_cX^((T)) / T + min_(vy in cY) max_(vx in cX)
                                                  vx^top U vy
  $
  Combining the expressions, we obtain
  $
    max_(vx in cX) min_(vy in cY) vx^top U vy >= min_(vy in cY) max_(vx in cX) vx^top U vy - "Reg"_cX^((T)) / T.
  $
  Letting $T -> oo$ proves the result.
]

== Learning (coarse) correlated equilibria <sec-learning-correlated>

The previous result is in fact a direct corollary of the more general connection between $Phi$-regret minimization and the set of coarse-correlated equilibria in multiplayer general-sum games. We present a general form of this connection in the next theorem.

#theorem[Formal version of #ref(<thmce-informal>, supplement: "Theorems") and #ref(<thmcce-informal>, supplement: "")][
  Let $vx^((t))_1, ..., vx^((t))_n$ the strategies played by the players at any time $t$, and let $Phi"-Reg"_i^((t))$ denote the $Phi$-regret incurred by Player $i$ up to time $t$. Consider now the average correlated distribution of play up to any time $T$, that is, the distribution $vmu^((T))$ that selects a time $overline(t)$ uniformly at random from the set ${1,...,T }$, and selects actions $(a_1,..., a_n)$ independendently according to the $vx_i^((overline(t)))$, that is,
  $
    vmu^((T)) := 1 / T sum_(t=1)^T vx_1^((t))⊗...⊗ vx_n^((t)).
  $
  This distribution satisfies the inequality
  $
    max_(phi.alt in Phi) EE_(a ~ vmu^((T))) [u_i (phi.alt(a_i), a_(-i)) - u_i (a_i, a_(-i))] <= (Phi"-Reg"^((T))_i) / T.
  $
] <thmce-formal>
#proof[
  Pick an arbitrary $phi.alt in Phi$. With the usual slight abuse of notation, we will denote with $phi.alt(a)$, where $a$ is an action, as the strategy returned by $phi.alt$ when evaluated in the _deterministic_ strategy that places all the mass on $a$. Expanding the specific structure of $vmu^((T))$, we can decompose the expectation
  $
    EE_(a ~ vmu^((T))) [u_i (phi.alt(a_i), a_(-i)) - u_i (a_i, a_(-i))]
  $
  as
  $
    & EE_(a ~ vmu^((T))) [u_i (phi.alt(a_i), a_(-i)) - u_i (a_i, a_(-i))] \
    & qquad = 1 / T sum_(t=1)^T EE_(a ~ vx_1^((t))⊗...⊗ vx_n^((t))) [
        (u_i (phi.alt(a_i), a_(-i)) - u_i (a_i, a_(-i)))
      ] \
    & qquad =
      1 / T sum_(t=1)^T
      (
        u_i (EE_(a_i ~ vx_i^((t))) [phi.alt(a_i)], EE_(a_(-i) ~ ⊗ vx_(-i)^((t)))[a_(-i)]) - u_i (
          EE_(a_i ~ vx_i^((t)))[ a_i ], EE_(a_(-i) ~ ⊗ vx_(-i)^((t))) [a_(-i)]
        )
      ) \
    & qquad =
      1 / T sum_(t=1)^T
      (
        u_i (phi.alt(EE_(a_i ~ vx_i^((t))) [a_i]), EE_(a_(-i) ~ ⊗ vx_(-i)^((t))) [a_(-i)]) - u_i (
          EE_(a_i ~ vx_i^((t))) [a_i], EE_(a_(-i) ~ ⊗ vx_(-i)^((t))) [a_(-i)]
        )
      ) \
    & qquad =
      1 / T sum_(t=1)^T
      (u_i (phi.alt(vx^((t))_i), vx^((t))_(-i)) - u_i (vx^((t))_i, vx^((t))_(-i)))
  $
  where the second equality follows by linearity of $phi.alt$ and $u_i$. Taking now a maximum over $phi.alt in Phi$, and recognizing the definition of $Phi$-regret on the right-hand side, we obtain the desired inequality.
]

Note that @thmce-formal holds for any set $Phi$. The approximate equilibria found this way are sometimes called approximate "$Phi$-equilibria". In the special cases of $Phi =$ all constant transformations, it is clear that the previous result implies convergence to the set of coarse correlated equilibria. For correlated equilibria, we need to convince ourselves that any arbitrary mapping $A -> A$ can be represented via a stochastic matrix. This is indeed the case, by constructing the matrix whose columns indicate what action is assigned to each action in $A$ by the mapping. (You should convince yourself!) Finally, for the case of $Phi =$ all probability mass transportations, it is enough to note that the $Phi$-regret of any stochastic matrix transformations is at most $|A|$ times larger than the worst possible regret of a probability mass transportation between two actions.
