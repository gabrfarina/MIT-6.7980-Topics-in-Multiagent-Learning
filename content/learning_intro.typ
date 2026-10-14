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
The concept of regret in decision theory goes back to #cite(<savage1951theory>, form: "prose"), and was later applied in repeated play by #cite(<hannan1957approximation>, form: "prose"). The concept of $Phi$-regret was introduced by #cite(<greenwald2003general>, form: "prose"), and it generalizes the notion of regret to arbitrary sets $Phi$ of transformations of the player's actions. 

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

Calls to `NextStrategy` and `ObserveUtility` keep alternating to each other: first, the regret minimizer will output a point $vx^((1))$, then it will receive feedback $u^((1))$ from the environment, then it will output a new point $vx^((2))$, and so on.
The decision making encoded by the regret minimizer is _online_, in the sense that at each time $t$, the output of the regret minimizer can depend on the prior outputs $vx^((1)), ...,vx^((t-1))$ and corresponding observed utility functions $u^((1)),...,u^((t-1))$, but no information about future utilities is available.

== Interaction and feedback models

At each round $t$, the learner chooses a strategy using information from earlier rounds. Then, the learner receives feedback and uses it to choose a strategy for round $t+1$. There are two separate choices: how the learner acts, and what feedback they receive.

For a finite action set $A$, a _deterministic action_ means directly choosing and playing one action $a in A$. A _randomized strategy_ is a distribution $vx in Delta(A)$ where the learner samples and plays an action $a$ from the distribution. For example, in a coin game, $(0.7, 0.3)$ is the strategy of playing Heads with probability $0.7$ and Tails with probability $0.3$.

In the _full-information_ feedback setting the learner observes the entire utility function $u^((t)): X -> RR$ after choosing $vx^((t)) in X$. In a normal-form game, this means learning the utility of every action including the ones not played. The learner then evaluates how any strategy would have performed before choosing for round $t+1$. This model is directly tied to online convex optimization because we observe the entire utility function and can directly optimize based on it.

In the _bandit_ feedback setting, the learner only observes the realized utility of the action actually played. For a randomized strategy, that's the utility of the sampled action, not the expected utility $u^((t))(vx^((t)))$ of the distribution itself. The utilities of unplayed actions, the counterfactuals, stay hidden. Bandit algorithms have to work around this by building a gradient estimator that extracts information about the unseen utilities from the strategy played and the one piece of feedback observed.

While the bandit setting may seem more intuitive or natural as a ting point for learning about learning, the full information case is a simplified model, from which we could build the bandit setting later on. 

Strategy and feedback are two independent choices. The strategy axis is about what the learner plays, either one action or a sample from a full distribution. The feedback axis is about what comes back afterward, either the whole utility function $u^((t))$ including counterfactuals or a single real number. These choices can be combined freely. For example, playing a deterministic action does not imply bandit feedback: the learner can play one action and still observe the entire utility function $u^((t))$.


== Notable choices of transformations $Phi$ <sec-regret-transformations>
The size of the set of transformations $Phi$ considered by the player defines
a natural notion of how "rational" the agent is. There are several choices of interest for $Phi$ for a normal-form strategy space $cX = Delta(A)$.
- $Phi =$ set of _all_ stochastic matrices, mapping $Delta(A) -> Delta(A)$. This notion of $Phi$-regret is known under the name _swap regret_. If the swap regret of every player grows sublinearly in $T$, then the average correlated distribution of play converges to the set of #lecture-link("correlated", <def-ce>)[correlated equilibria]. Swap regret was defined by #cite(<blum2007external>, form: "prose") as a strengthening of internal regret. The link between internal regret and correlated equilibria was first shown by #cite(<foster1997calibrated>, form: "prose") using calibrated forecasts, and then by #cite(<hart2000simple>, form: "prose") using a simple regret-based procedure.

  For example, in rock-paper-scissors, swap regret can compare the actions actually played against replacing every action at once, such as rock with paper, scissors with rock, and paper with scissors.
  In matrix form, $Phi^"swap" = {vx |-> Q vx : Q >= 0, thin vone^top Q = vone^top}$, that is, $Q$ is column-stochastic: column $a$ of $Q$ gives the replacement distribution for action $a$.

  #align(center, image(
    "figures/learning_intro/swap_regret.svg",
    width: 12.6cm,
    alt: "Rock-paper-scissors timeline: every action actually played at times 1 through 7 is replaced, rock by paper, scissors by rock, and paper by scissors.",
  ))
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
  This is known as _internal regret_. Its transformations are action-to-action switches. Each such switch moves all probability mass from one action onto another action.

  For example, in rock-paper-scissors, the transformation $phi.alt_("scissors" -> "rock")$ compares the actions actually played against playing rock whenever scissors was played, leaving every other action unchanged.

  #align(center, image(
    "figures/learning_intro/internal_regret.svg",
    width: 12.6cm,
    alt: "Rock-paper-scissors timeline: the comparator copies the actions actually played at times 1 through 7, except that each scissors is switched to rock.",
  ))
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

#exercise[Comparing external, internal, and swap regret][
  Fix a finite action set $A$, and consider a learner that plays $vx^((1)), ..., vx^((T)) in Delta(A)$ against linear utilities $u^((1)), ..., u^((T))$. For $a, b in A$ write
  $
    G_(a -> b) := sum_(t=1)^T x_a^((t)) (u^((t))(b) - u^((t))(a))
  $
  for the total gain the learner would have made by rerouting onto $b$ whatever probability mass it placed on $a$, and let $"Reg"^((T))$, $"IntReg"^((T))$ and $"SwapReg"^((T))$ denote its external, internal and swap regret, taking $phi.alt_(a -> a)$ to be the identity.
  + Show that swap regret bounds both of the others: $"IntReg"^((T)) <= "SwapReg"^((T))$ and $"Reg"^((T)) <= "SwapReg"^((T))$.
  + Show that $"Reg"^((T)) <= |A| dot "IntReg"^((T))$.
  + Is there a direct ordering between internal and external regret?
] <ex-regret-comparison>

#solution[
  All three regrets are readings of the single array $(G_(a -> b))_(a, b in A)$:
  $
    "Reg"^((T)) &= max_(b in A) sum_(a in A) G_(a -> b), \
    "IntReg"^((T)) &= max_(a, b in A) G_(a -> b), \
    "SwapReg"^((T)) &= sum_(a in A) max_(b in A) G_(a -> b).
  $
  For the first, $u^((t))$ is linear, so the maximum over $hat(vx) in Delta(A)$ defining external regret is attained at a pure action $b$; since $sum_(a) x_a^((t)) = 1$,
  $
    u^((t))(b) - u^((t))(vx^((t))) = sum_(a in A) x_a^((t)) (u^((t))(b) - u^((t))(a)).
  $
  For the second, $phi.alt_(a -> b)$ leaves every coordinate but $a$ and $b$ alone, so $u^((t))(phi.alt_(a -> b)(vx^((t)))) - u^((t))(vx^((t))) = x_a^((t)) (u^((t))(b) - u^((t))(a))$, and summing over $t$ gives $G_(a -> b)$. For the third, a column-stochastic $Q$ gives $u^((t))(Q vx^((t))) - u^((t))(vx^((t))) = sum_(a) sum_(b) Q_(b a) x_a^((t)) (u^((t))(b) - u^((t))(a))$, using $sum_(b) Q_(b a) = 1$; the columns of $Q$ are chosen independently from $Delta(A)$, so each one picks a $b$ maximizing $G_(a -> b)$.

  + Because $phi.alt_(a -> a)$ is the identity, $G_(a -> a) = 0$, so $max_(b) G_(a -> b) >= 0$ for every $a$. A sum of nonnegative terms is at least any one of them, so $"SwapReg"^((T)) >= max_(a) max_(b) G_(a -> b) = "IntReg"^((T))$. Letting $b"*"$ attain the external maximum, $"SwapReg"^((T)) >= sum_(a) G_(a -> b"*") = "Reg"^((T))$.
  + Every $G_(a -> b)$ is at most $"IntReg"^((T))$, and the inner sum has $|A|$ terms, so $"Reg"^((T)) = max_(b) sum_(a) G_(a -> b) <= |A| dot "IntReg"^((T))$.
  + No, as soon as $|A| >= 3$: neither quantity dominates the other. Taking $T = 1$ and $vx^((1))$ uniform on $A without {b}$ for a fixed action $b$, with $u^((1))(b) = 1$ and $u^((1))(a) = 0$ otherwise, gives $G_(a -> b) = 1 \/ (|A| - 1)$ for each $a != b$ and $G = 0$ elsewhere, so $"Reg"^((T)) = 1$ exceeds $"IntReg"^((T)) = 1 \/ (|A| - 1)$. Conversely, let $A = {1, 2, 3}$ and alternate $vx^((t)) = ve_1$ with $u^((t)) = (0, 1, 0)$ on odd rounds and $vx^((t)) = ve_3$ with $u^((t)) = (0, 0, 1)$ on even ones. Then $G_(1 -> 2) = T \/ 2$ while $sum_(a) G_(a -> b) <= 0$ for every $b$, so internal regret is linear in $T$ and external regret is $0$.

    Both examples need at least three actions: for $|A| = 2$ the two expressions above reduce to $"IntReg"^((T)) = max{0, "Reg"^((T))}$. What survives in general is the one-way implication from part 2 --- sublinear internal regret forces sublinear external regret, and the alternating example shows the converse fails.
]
 A note about the relationship between Nash equilibria, correlated equilibria and coarse correlated equilibria: Nash equilibria are a subset of correlated equilibria, which are in turn a subset of coarse correlated equilibria. Unlike the set of Nash equilibria, the set of (coarse) correlated equilibria is always a convex polytope, always contains rational solutions when the payoffs are rational, and can be found in polynomial time by linear programming. By contrast, computing a Nash equilibrium is PPAD-hard, the set of Nash equilibria can be nonconvex, and with three or more players a Nash equilibrium may require irrational probabilities. Allowing the players to coordinate enlarges the set of equilibria, which can make outcomes available that no Nash equilibrium achieves, such as higher total welfare. As a result, the best payoffs achievable at equilibrium can only stay the same or go up.

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

For example, in rock-paper-scissors, external regret compares the actions actually played against always playing the same fixed strategy, such as always playing rock.

#align(center, image(
  "figures/learning_intro/external_regret.svg",
  width: 12.6cm,
  alt: "Rock-paper-scissors timeline: the actions actually played at times 1 through 7 are each replaced by the constant comparator rock.",
))
#strong[Terminological remark.] The name _regret minimizer_ is a bit of a misnomer. The goal is not to make regret as small as possible, but to guarantee that it grows sublinearly in $T$. A regret minimizer is an online algorithm that chooses its strategy for each round using the strategies played and the utility functions observed so far. It is not required to choose the strategy that would have been best in hindsight, and it is not required to minimize the regret accumulated up to round $t$. What matters is the regret's long run growth rate. If regret grows sublinearly, then regret divided by $T$ goes to zero as $T$ grows, meaning that on average per round, the algorithm does just as well as the best fixed strategy in hindsight. Poorer performance in early rounds is acceptable. The important thing is that the algorithm doesn't keep falling behind the best fixed strategy by a significant amount as more rounds are played.

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
#proof[
  Let $overline(u)(vx_n) := u_n (overline(vx)_1, ..., overline(vx)_(n-1), vx_n)$ be Player $n$'s
  utility against the mean opponent profile and let
  $vx_n^b in argmax_(vx_n in cX_n) overline(u)(vx_n)$ be a best response to it. Let $F_(t-1)$ be
  the history up to time $t-1$, including Player $n$'s internal randomness and choice of
  $vx_n^((t))$.

  Since Player $n$ has sublinear external regret,
  $
    1/T sum_(t=1)^T [u^((t))(vx_n^b) - u^((t))(vx_n^((t)))] <= "Reg"_n^((T)) / T -> 0.
  $
  The strategy $vx_n^((t))$ is determined by $F_(t-1)$. The opponents' time $t$ samples are
  independent of $F_(t-1)$ with means $overline(vx)_1, ..., overline(vx)_(n-1)$. Since $u_n$ is
  multilinear, $EE[u^((t))(vx_n^b) - u^((t))(vx_n^((t))) | F_(t-1)] = overline(u)(vx_n^b) - overline(u)(vx_n^((t)))$.
  Hence the difference between realized and expected utility
  $
    xi_t := [u^((t))(vx_n^b) - u^((t))(vx_n^((t)))] - [overline(u)(vx_n^b) - overline(u)(vx_n^((t)))]
  $
  is a bounded martingale difference sequence. By the martingale law of large numbers,
  $1/T sum_(t=1)^T xi_t -> 0$ almost surely. Combining this with the regret bound gives
  $
    overline(u)(vx_n^b) - 1/T sum_(t=1)^T overline(u)(vx_n^((t))) -> 0
    quad "almost surely."
  $
  Since $overline(u)$ is linear, $1/T sum_(t=1)^T overline(u)(vx_n^((t))) = overline(u)(1/T sum_(t=1)^T vx_n^((t)))$,
  so
  $
    overline(u)(1/T sum_(t=1)^T vx_n^((t))) -> overline(u)(vx_n^b)
    quad "almost surely."
  $
  Since $cX_n$ is compact and $overline(u)$ is continuous, every limit point of the average strategy is a maximizer of $overline(u)$, that is, a best response. Hence the average strategy converges almost surely to the set of best responses, and to the best response itself if it is unique.
]


In the same stochastic setting, even a very simple strategy can guarantee sublinear _swap_ regret, as the following example shows.

#example[A threshold strategy against a biased coin][
  Consider matching pennies: the learner and the opponent both choose an action from $A = {upright(H), upright(T)}$ (Heads and Tails), and the learner's utility is
  $
    u(a, y) := cases(+1 & "if" a = y\,, -1 & "otherwise.")
  $
  The upright letters $upright(H)$ and $upright(T)$ denote actions, while the italic $T$ remains the number of rounds. The opponent plays stochastically, as above: the actions $y^((1)), y^((2)), ...$ are independent, with $PP[y^((t)) = upright(H)] = p$ for a fixed $p in [0, 1]$ that the learner does not know. Let $delta := 2p - 1$. As in the canonical learning setup, after round $t$ the learner observes the linear utility function
  $
    u^((t))(vx) := x_upright(H) u(upright(H), y^((t))) + x_upright(T) u(upright(T), y^((t))) quad "for" vx = (x_upright(H), x_upright(T)) in Delta(A).
  $

  Let $D^((t-1))$ be the number of Heads minus the number of Tails among $y^((1)), ..., y^((t-1))$. On round $t$, the learner plays the _threshold strategy_
  $
    vx^((t)) := cases(
      (1, 0) & "if" D^((t-1)) >= t^(2\/3) & quad ("play" upright(H))\,,
      (0, 1) & "if" D^((t-1)) <= -t^(2\/3) & quad ("play" upright(T))\,,
      (1\/2, 1\/2) & "otherwise.",
    )
  $
  The strategy $vx^((t))$ depends only on $y^((1)), ..., y^((t-1))$. We show that for every $p in [0, 1]$, its expected swap regret is $O(T^(2\/3))$:
  $
    EE[Phi^"swap""-Reg"^((T))] <= 8 T^(2\/3) + 4 sqrt(T(1 + ln T)) + 4 sqrt(T).
  $
] <ex-threshold-swap-regret>
#proof[
  _Step 1: swap regret with two actions._ For distinct $a, b in A$, let $Z_(a -> b)^((t)) := u(b, y^((t))) - u(a, y^((t)))$, and let $G_(a -> b)$ be the gain of the internal-regret transformation $phi.alt_(a -> b)$ from @sec-regret-transformations:
  $
    G_(a -> b) := sum_(t=1)^T (u^((t))(phi.alt_(a -> b)(vx^((t)))) - u^((t))(vx^((t)))) = sum_(t=1)^T x_a^((t)) Z_(a -> b)^((t)).
  $
  By linearity, a column-stochastic $Q$ gains $sum_(a in A) sum_(b != a) Q_(b a) G_(a -> b)$. Each column can be optimized separately, and with two actions the best column either keeps $a$ or moves all of its mass to $b$, so
  $
    Phi^"swap""-Reg"^((T)) = max{0, G_(upright(H) -> upright(T))} + max{0, G_(upright(T) -> upright(H))}.
  $

  _Step 2: drift plus noise._ Since $EE[u(upright(H), y^((t)))] = p - (1 - p) = delta = -EE[u(upright(T), y^((t)))]$, the drift $mu_(a -> b) := EE[Z_(a -> b)^((t))]$ satisfies $mu_(upright(H) -> upright(T)) = -2 delta = -mu_(upright(T) -> upright(H))$. As $Z_(a -> b)^((t)) in {-2, +2}$, $op("Var")(Z_(a -> b)^((t))) <= 4$. Write
  $
    G_(a -> b) = mu_(a -> b) sum_(t=1)^T x_a^((t)) + N_(a -> b), quad N_(a -> b) := sum_(t=1)^T x_a^((t)) (Z_(a -> b)^((t)) - mu_(a -> b)).
  $
  Since $x_a^((t))$ is fixed before $y^((t))$ is drawn independently, the terms of $N_(a -> b)$ have mean zero, second moment at most $4$, and are pairwise uncorrelated. Hence $EE[N_(a -> b)^2] <= 4T$, and by Cauchy--Schwarz, $EE[abs(N_(a -> b))] <= 2 sqrt(T)$. Using $max{0, alpha + beta} <= max{0, alpha} + abs(beta)$ in Step 1,
  $
    EE[Phi^"swap""-Reg"^((T))] <= sum_(a != b) max{0, mu_(a -> b)} sum_(t=1)^T EE[x_a^((t))] + 4 sqrt(T).
  $

  _Step 3: reduce to the wrong action._ If $p = 1\/2$, both drifts vanish; since Steps 1--2 hold for any strategy, against a fair coin _every_ strategy has expected swap regret at most $4 sqrt(T)$. Otherwise, assume $p > 1\/2$ (the case $p < 1\/2$ is symmetric). Then $mu_(upright(H) -> upright(T)) < 0$, and
  $
    EE[Phi^"swap""-Reg"^((T))] <= 2 delta sum_(t=1)^T EE[x_upright(T)^((t))] + 4 sqrt(T).
  $

  _Step 4: weight on the wrong action._ The strategy weights $upright(T)$ only when $D^((t-1)) < t^(2\/3)$, so $EE[x_upright(T)^((t))] <= PP[D^((t-1)) < t^(2\/3)]$, where $D^((t-1))$, a sum of $t - 1$ independent $plus.minus 1$ variables, has mean $delta(t - 1)$ and variance at most $t - 1$. The rounds $t < t_0 := 64\/delta^3$ contribute at most $64\/delta^3$. For $t >= t_0 >= 64$, $delta(t - 1) >= delta t\/2 >= 2 t^(2\/3)$, so by Chebyshev's inequality,
  $
    PP[D^((t-1)) < t^(2\/3)] & <= PP[abs(D^((t-1)) - delta(t - 1)) >= (delta(t - 1)) / 2] \
    & <= (t - 1) / (delta(t - 1)\/2)^2 = 4 / (delta^2 (t - 1)).
  $
  Summing with $sum_(n=1)^T 1\/n <= 1 + ln T$ and multiplying by $2 delta$,
  $
    2 delta sum_(t=1)^T EE[x_upright(T)^((t))] <= 128 / delta^2 + (8(1 + ln T)) / delta.
  $

  _Step 5: a bound uniform in $p$._ The left-hand side is also at most $2 delta T$. Since $min{alpha + beta, gamma} <= min{alpha, gamma} + min{beta, gamma}$ for nonnegative $alpha, beta, gamma$, and each minimum below is largest where its sides are equal ($delta = 4 T^(-1\/3)$ and $delta^2 = 4(1 + ln T)\/T$, respectively),
  $
    2 delta sum_(t=1)^T EE[x_upright(T)^((t))] & <= min{128 / delta^2, 2 delta T} + min{(8(1 + ln T)) / delta, 2 delta T} \
    & <= 8 T^(2\/3) + 4 sqrt(T(1 + ln T)).
  $
  Combined with Step 3, this gives the claimed bound for every $p$.
]

The hardest opponent has a bias of about $delta approx T^(-1\/3)$. That bias is just barely detectable by the $t^(2\/3)$ threshold within $T$ rounds, and it is also where the $T^(2\/3)$ rate comes from.

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

A well known folk theorem establishes that the pair of average strategies produced by the regret minimizers up to any time $T$ converges to a saddle point of (@bspp), where convergence is measured via the _saddle point gap_
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

The very _existence_ of regret minimizers is a powerful enough fact to imply the minimax theorem! This argument is due to #cite(<freund1999adaptive>, form: "prose"), who proved it for finite games using multiplicative weights. The version below, for general convex compact sets and an arbitrary regret minimizer, follows the same proof.

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
  Let $vx^((t))_1, ..., vx^((t))_n$ be the strategies played by the players at any time $t$, and let $Phi"-Reg"_i^((t))$ denote the $Phi$-regret incurred by Player $i$ up to time $t$. Consider now the average correlated distribution of play up to any time $T$, that is, the distribution $vmu^((T))$ that selects a time $overline(t)$ uniformly at random from the set ${1,...,T }$, and selects actions $(a_1,..., a_n)$ independently according to the $vx_i^((overline(t)))$, that is,
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

@thmce-formal holds for any set $Phi$, and the approximate equilibria it produces are sometimes called approximate "$Phi$-equilibria". Specializing it to the three choices of $Phi$ from @sec-regret-transformations recovers the three classical notions of regret, together with the equilibrium each one certifies.

#corollary[Specializing @thmce-formal to CCE and CE][
  Consider the canonical learning setup (@def-canonical-learning) in a finite normal-form game, and write $epsilon_i := (Phi"-Reg"_i^((T))) / T$ for the time-averaged $Phi$-regret of Player $i$. Then the average correlated distribution of play $vmu^((T))$ satisfies the following, where every expectation is taken over $a ~ vmu^((T))$.
  + _External regret_ ($Phi = Phi^"const"$, the constant maps): for every $a'_i in A_i$,
    $
      EE [u_(i)(a'_i, a_(-i))] <= EE [u_(i)(a_i, a_(-i))] + epsilon_i,
    $
    so $vmu^((T))$ is an $epsilon_i$-approximate #lecture-link("correlated", <def-cce>)[coarse correlated equilibrium].
  + _Internal regret_ ($Phi = Phi^"int"$, the probability mass transports): for every $r, s in A_i$,
    $
      sum_(a_(-i) in A_(-i)) mu^((T))_(r, a_(-i)) [u_(i)(s, a_(-i)) - u_(i)(r, a_(-i))] <= epsilon_i.
    $
    These are the pairwise correlated equilibrium conditions of #lecture-link("correlated", <sec-ce>)[], each relaxed by $epsilon_i$; summing the $|A_i|$ of them that constitute a map $phi.alt : A_i -> A_i$ shows that $vmu^((T))$ is an $(|A_i| epsilon_i)$-approximate correlated equilibrium.
  + _Swap regret_ ($Phi = Phi^"swap"$, the column-stochastic matrices): for every $phi.alt : A_i -> A_i$,
    $
      EE [u_(i)(phi.alt(a_i), a_(-i))] <= EE [u_(i)(a_i, a_(-i))] + epsilon_i,
    $
    so $vmu^((T))$ is an $epsilon_i$-approximate #lecture-link("correlated", <def-ce>)[correlated equilibrium].
] <cor-phi-specialization>
#proof[
  Each part evaluates the maximum on the left-hand side of @thmce-formal over the relevant $Phi$, recalling that the theorem applies $phi.alt$ only to deterministic recommendations.
  + The objective is affine in $xhat$, so its maximum over $Delta(A_i)$ is attained at a vertex, that is, at a pure action $a'_i$.
  + Applied to a deterministic recommendation, $phi.alt_(r -> s)$ moves all of the mass when $a_i = r$, and leaves the recommendation untouched otherwise, there being no mass on $r$ to move. Only the $a_i = r$ slice of the expectation survives.
  + The objective is linear in each column separately, and the columns range independently over $Delta(A_i)$, so the maximum is attained with every column at a vertex---that is, at a deterministic map $phi.alt : A_i -> A_i$. This is the same independent-column argument that makes the Blum--Mansour bound an equality in #lecture-link("phi_regret", none)[].
]

In each case, sublinear $Phi$-regret drives $epsilon_i -> 0$, so $vmu^((T))$ converges to the corresponding equilibrium set, as claimed informally in @thmce-informal and @thmcce-informal.
Note that @thmce-formal holds for any set $Phi$. The approximate equilibria found this way are sometimes called approximate "$Phi$-equilibria". In the special cases of $Phi =$ all constant transformations, it is clear that the previous result implies convergence to the set of coarse correlated equilibria. For correlated equilibria, we need to convince ourselves that any arbitrary mapping $A -> A$ can be represented via a stochastic matrix. This is indeed the case, by constructing the matrix whose columns indicate what action is assigned to each action in $A$ by the mapping. (You should convince yourself!) Finally, for the case of $Phi =$ all probability mass transportations, it is enough to note that the $Phi$-regret of any stochastic matrix transformations is at most $|A|$ times larger than the worst possible regret of a probability mass transportation between two actions.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
