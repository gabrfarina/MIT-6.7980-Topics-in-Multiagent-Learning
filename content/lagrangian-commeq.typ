#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 1,
  date: [Wed, Oct 28, 2026],
  title: "A Lagrangian-based Method for Computing the Equilibrium",
  instructor: [Arnav Adhikari (`arnavwad@mit.edu`)],
)

// As above, we've now relaxed the complicated communication equilibrium setting to solving a Linear Program! in polynomial time

// Note that we can reframe the following: "find optimal mediator strategy $\mu$ s.t. for all players $i$, the direct strategy is a best response to $\mu$ if all other players are direct"

// So we are finding $\max_{\mu} u_M(\mu, x^*)$ s.t. for all players $i$, max
// 𝒙𝑖
// 𝑢𝑖(𝝁, 𝒙𝑖
// , 𝒙−𝒊
// ∗
// ) ≤ 𝑢𝑖 𝝁, 𝒙𝑖
// ∗
// , 𝒙−

// Remark that the constraint is actually just an equality, since $x_i^*$ is a possible value of $x_i$.

// In other words the constraint becomes $V_i(\mu) = max_{x_i} u_i(x_i, x_{-i}^*) - u_i(\mu, x_i^{*}, x_{-i}^{*}) = 0$, for all $i$. We can tidy it further by saying $C(\mu) := \max_i V_i(\mu) = 0$.

// Therefore we can easily find the solution via Lagrange to $\max_mu(u_M(\mu) - \lambda V(\mu))$, which then  turns into $max
// 𝝁
// min
// 𝒊,𝒙𝒊
// 𝑢M 𝝁, 𝒙
// ∗ − 𝜆 ⋅ 𝑢𝑖 𝝁, 𝒙𝑖
// , 𝒙−𝒊
// ∗ − 𝑢𝑖 𝝁, 𝒙𝑖
// ∗
// , 𝒙−$ after noting that the first term and the latter min are indepndent.

// Because of this maximin structure, this actually becomes a zero-sum game! In particular, because of the singular expression, the "modified mediator"'s payoff is that number, while the "deviator"'s is its negative, giving the zero-sum effect.

// To formalize this, by the exact penalty theory for convex programs ~#citep(<bertsekas1999nonlinear>), there exists $\lambda* > 0$ so that for all $\lambda > \lambda *$, the equilibrium strategy for the max-player for the zero-sum game becomes the correlated equilibrium for the original game.

// ^^ clarify why this lambda star should exists

// Now we might think that we can reap our reward and call it a day. Why not just optimize the Lagrangian directly?

// Well, we could run gradient descent-ascent on it. Note the following issues:

// It's a max of a max. Evaluating $V(\mu)$ at a single point means solving $n$ best-response problems. One “function evaluation” is already expensive.

// Since $V = u - u$ is nonsmooth, $V$ is a max over a finite set, so it has kinks, and the active deviation switches discontinuously as $\mu$ moves. Subgradient methods handle this but slowly.

// And the killer: both players live in polytopes. $\mu$ ranges over mediator strategies in the communication game, $\boldsymbol x_i$ over player $i$’s strategies. Projected gradient needs projection onto a sequence-form polytope — expensive.

// That last one should sound familiar. It’s the exact objection from Lecture 8: OGD on $\mathcal Q$ is correct but you can’t afford the projections, which is why CFR exists.

// ---
// So instead, we take motivation from the zero-sum analog. It turns out that we can craft an extensive-form game like the following:

// #image("/assets/image.png")

// It does well to frame it the following way:

// The mediator represents our maximizer and the eviator represents our minimizer. The deviator goes "first", selecting a player $i$ to represent to possibly deviate (not confirmed).

// Then, nature can select, with probability $\frac{1}{2}$, whether or not player $i$ does deviate.

// The original game then gets played where player $i$ deviates accordingly, and we end up getting terminal node $z$ from the game i.e. some leaf node in the game tree of hte original game. In particular, there are utilities $u_m(z)$ and $u_i(z)$ assigned to that node.

// Back to this new game tree, we get the rewards $2u_m(z)+2\lambda u_i(z)$ for the nodes where player $i$ plays directly, and $-2\lambda u_i(z)$ for the nodes where player i deviates. 

// The setting of these rewards is consistent with the Lagrangian, because $E[r(z)] = 1/2(2u_m(z)+2\lambda u_i(z)) + 1/2(-2\lambda u_i(z)) = u_m(z)+lambda(u_i(z) - u_i(z))$.

// So now we have the ability to solve a single zero-sum game, which gives us the optimal
// correlated equilibrium of a multi-player game!

// Except ... the only issue is we need a high enough Lagrange multiplier beyond $lambda *$, and since it depends on the scales of the rewards it can get large.

// If we set $\lambda := 1/eps$. We can compare results and performance from our favorite algos:

// CFR converges in averages after $1/eps^4$ iterations
// OMWU converges in averages after $1/eps^2$ iterations
// OMWU converges in iterates after $1/eps^4$ iterations

// Since the utilities in this extensive-form Lagrangian have scale that depends on $\lambda$, and since deep learning solvers aren't really good at high precision, this can become a big drawback in practice. Hence, there are some relaxations we should explore...


We have now reduced the communication-equilibrium problem to a linear program, solvable in polynomial time.

Recall what we are solving: find an optimal mediator strategy $mu$ such that for every player $i$, the direct strategy is a best response to $mu$ when all other players are also direct. Formally,

$ max_mu u_M (mu, bold(x)^*) quad "subject to" quad
max_(bold(x)_i) u_i (mu, bold(x)_i, bold(x)^*_(-i))
<= u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) quad forall i. $

The constraint says that no deviation by player $i$ is profitable. Its right-hand
side $u_i (mu, bold(x)^*_i, bold(x)^*_(-i))$ does not depend on $bold(x)_i$, so we
may bring it inside the maximum on the left:

$ max_(bold(x)_i) [ u_i (mu, bold(x)_i, bold(x)^*_(-i))
- u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) ] <= 0. $

The bracketed quantity is what player $i$ gains by switching to $bold(x)_i$ while
everyone else stays direct, so the maximum is the _best deviation available to
player $i$_. Give it a name:

$ V_i (mu) := max_(bold(x)_i) [ u_i (mu, bold(x)_i, bold(x)^*_(-i))
- u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) ]. $

Observe that $V_i (mu) >= 0$ always, since player $i$ may choose
$bold(x)_i = bold(x)^*_i$ and gain exactly nothing. The constraint
$V_i (mu) <= 0$ is therefore really $V_i (mu) = 0$: the best deviation available
to player $i$ gains them nothing at all.

This is one equation per player. Taking a maximum over players collapses them into
a single scalar,

$ V(mu) := max_i V_i (mu)
= max_(i\, bold(x)_i) [ u_i (mu, bold(x)_i, bold(x)^*_(-i))
- u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) ], $

the _largest deviation gain available to anybody_. The whole constraint set is now
the single equation $V(mu) = 0$.

Penalizing this constraint gives the Lagrangian

$ max_mu [ u_M (mu, bold(x)^*) - lambda V(mu) ]. $

Unfolding the definition of $V$,

$ max_mu [ u_M (mu, bold(x)^*) - lambda max_(i\, bold(x)_i)
( u_i (mu, bold(x)_i, bold(x)^*_(-i))
- u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) ) ]. $

Two moves turn this into a maximin. First, since $lambda > 0$, multiplying by
$-lambda$ flips the maximum into a minimum:
$-lambda max_(i\, bold(x)_i) (dot) = min_(i\, bold(x)_i) (-lambda dot)$. Second,
$u_M (mu, bold(x)^*)$ does not depend on $i$ or $bold(x)_i$, so it may be moved
_inside_ that minimum. Together,

$ max_mu min_(i\, bold(x)_i) u_M (mu, bold(x)^*)
- lambda dot [ u_i (mu, bold(x)_i, bold(x)^*_(-i))
- u_i (mu, bold(x)^*_i, bold(x)^*_(-i)) ], $

which is the expression on the slide.

Because of this maximin structure, the problem is a zero-sum game. There is a
single payoff expression: the mediator's payoff is that number and the deviator's
is its negative, so the two sum to zero.

To formalize the correspondence, by exact-penalty theory for convex programs
~#citep(<bertsekas1999nonlinear>) there exists $lambda^* > 0$ such that for every
$lambda > lambda^*$, an equilibrium strategy for the max-player of the corresponding zero-sum
game is an optimal correlated equilibrium of the original game.

Now we might think we can reap our reward and call it a day. Why not optimize the
Lagrangian directly?

We could run gradient descent-ascent on it, but three issues arise.

First, it is a maximum of a maximum. Evaluating $V(mu)$ at a single point requires
solving $n$ best-response problems, so one function evaluation is already expensive.

Second, $V$ is nonsmooth. It is a maximum over a finite set, so it has kinks, and
the active deviation switches discontinuously as $mu$ moves. Subgradient methods
handle this, but slowly.

Third, and most seriously, both players live in polytopes: $mu$ ranges over
mediator strategies in the communication game, and $bold(x)_i$ over player $i$'s
strategies. Projected gradient therefore requires projection onto a sequence-form
polytope, which is expensive.

That last objection should sound familiar. It is exactly the objection that powers #lecture-link("learning_efg", <sec-cfr>)[CFR], because while online gradient descent on $cal(Q)$ is correct, projections are
unaffordable.

#line(length: 100%)

So instead we exploit the zero-sum structure directly. It turns out the Lagrangian
can be realized as the following extensive-form game.

#image("/assets/image.png")

The mediator is the maximizer and the deviator is the minimizer. The deviator moves
first, selecting a player $i$ to represent and possibly deviate on behalf of.

Nature then selects, uniformly at random, whether player $i$ actually deviates.

The original game is then played out, with player $i$ deviating or playing directly
according to nature's choice, terminating at some leaf $z$ of the original game
tree, where the payoffs $u_M (z)$ and $u_i (z)$ are defined.

Back in the new game tree, the payoffs are $2 u_M(z) + 2 lambda u_i(z)$ at the
nodes where player $i$ plays directly, and $-2 lambda u_i (z)$ at the nodes where
player $i$ deviates.

These payoffs are consistent with the Lagrangian. Writing $u^"dir"$ and $u^"dev"$
for the utilities realized in the two branches, which reach different leaves,

$ bb(E)["payoff"] = 1/2 (2 u_M^"dir" + 2 lambda u_i^"dir")
+ 1/2 (-2 lambda u_i^"dev")
= u_M^"dir" - lambda (u_i^"dev" - u_i^"dir"), $

which is precisely the expression above. The factors of $2$ exist to undo nature's
$1/2$, and $u_M$ appears only in the direct branch because $u_M(mu, bold(x)^*)$ is
evaluated at the all-direct profile.

Some notes:
- Nature's $1/2$ is technically arbitrary and can be replaced with $p$
- the rewards from the game tree are also arbitrary and just need to be chosen accordingly with $p$ such that $bb(E)["payoff"]$ stays the same
- However, these are still optimal choices - as we'll see, moderating the scale of these quantities is important because in practice deep learning solvers will lose precision. So keeping values symmetric and roughly equal is best.

So we can now solve a single zero-sum game and recover the optimal correlated
equilibrium of a multi-player game.

The remaining issue is that we need a Lagrange multiplier above $lambda^*$, and
since $lambda^*$ depends on the scale of the rewards, it can be large.

Setting $lambda := 1\/epsilon$, we can compare the performance of the usual
algorithms:

- CFR converges in averages after $1\/epsilon^4$ iterations
- OMWU converges in averages after $1\/epsilon^2$ iterations
- OMWU converges in iterates after $1\/epsilon^4$ iterations

Since the utilities in this extensive-form Lagrangian have scale depending on
$lambda$, and since deep learning solvers are not good at high precision, this is a
significant drawback in practice. Hence there are relaxations worth exploring.


= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
