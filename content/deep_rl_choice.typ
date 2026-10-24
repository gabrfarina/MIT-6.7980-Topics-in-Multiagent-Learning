// Lecture 9  Choice 1: behavioral policies, logits, gradient ascent, hidden concavity.
#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Game theory-ifying: Choice 1",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

The sequence-form representation is what makes an extensive-form game a convex problem. For a fixed strategy of the opponents, a player's payoff is linear in that player's realization plan, and the set of realization plans is the sequence-form polytope. Regret minimization, and in particular #lecture-link("learning_efg", <sec-cfr>)[counterfactual regret minimization], is built on those two facts.

A game large enough that we cannot store a realization plan, or project onto that polytope, asks for different coordinates. The scalable methods in this lecture keep the game-theoretic object, a strategy of an extensive-form game, and run gradient ascent on a parameterization of it. Several choices go into making that idea work. This section is the first: which parameterization.

= Behavioral strategies and policies <sec-behavioral-policies>

A #lecture-link("efg_intro", <sec-behavioral-form>)[behavioral strategy] assigns to each decision point a distribution over the legal actions at that decision point. Write $pi(a bar.v j)$ for the probability of action $a in A_j$ at decision point $j$. Under perfect recall, #lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem] says that every distribution over terminal nodes induced by a normal-form strategy is already induced by some behavioral strategy. Moving to behavioral strategies does not shrink the set of reachable outcomes.

What it changes is the vector we store and differentiate. In the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form], the coordinate on the sequence $(j, a)$ is the product of the local probabilities on the path from the root to that sequence. Those products are the source of linearity. They are also awkward coordinates for a numerical method aimed at a long game. They are tied together by the flow constraints of the sequence-form polytope, and they decay as the path gets longer, because each new factor is a probability. A coordinate that is a product of many probabilities is a poor quantity to hand to a gradient step.

A _policy_ is a behavioral strategy produced by a map from information states to local distributions. The map may be a table, with one simplex at each decision point, or the output of a network. In either case the object we update is local. Given the local distributions, the realization plan is recovered by the same recursion used when CFR assembles a sequence-form strategy from its local regret minimizers. If $p_j$ denotes the parent sequence of decision point $j$, as in the #lecture-link("efg_intro", <sec-tfdp-notation>)[tree-form notation], and $x_∅ = 1$, then

#set math.equation(numbering: "(1)")
$ x(pi)_(j a) = x(pi)_(p_j) dot pi(a bar.v j). $ <eq-realization>
#set math.equation(numbering: none)

Equivalently, $x(pi)_(j a)$ is the product of $pi(a' bar.v j')$ over every decision of this player on the path to $(j, a)$. The flow constraints hold automatically: we never optimize over them.

= Logits <sec-logits>

The map that produces the policy will not emit the probabilities $pi(a bar.v j)$ themselves. It emits a real number $z_theta (j, a)$ for each legal action, called a _logit_, and the local distribution is the softmax of those logits,

#set math.equation(numbering: "(1)")
$ pi_theta (a bar.v j) = exp(z_theta (j, a)) / (sum_(b in A_j) exp(z_theta (j, b))). $ <eq-softmax>
#set math.equation(numbering: none)

Here $theta$ collects the logits, or the weights of a network that produces them from a representation of the information state. Three properties of this parameterization matter.

The logits at a decision point are an unconstrained vector in $RR^(A_j)$. The simplex constraint is enforced by the softmax, so a gradient step on $z_theta (j, dot.c)$ does not have to project back onto the probability simplex.

The softmax is invariant to a shift of all logits at the same decision point. Replacing $z_theta (j, a)$ by $z_theta (j, a) + c$ multiplies the numerator and every term of the denominator by $e^c$, and the local distribution is unchanged. Only differences of logits are identified by $pi_theta$.

A very small local probability is a large negative logit, which is an ordinary floating-point number. The sequence-form coordinate in @eq-realization stores the product of those probabilities instead. In a deep tree that product underflows long before any individual logit becomes hard to represent.

= A nonlinear objective <sec-nonlinear-objective>

Fix the opponents' strategies, and let $vy$ be the sequence-form strategy they induce. The player's expected payoff is linear in their own realization plan. In the logit parameterization that payoff is the function we will ascend on,

#set math.equation(numbering: "(1)")
$ J(theta; vy) = ip(x(theta), matU vy), $ <eq-objective>
#set math.equation(numbering: none)

where $x(theta)$ is the realization plan of $pi_theta$ defined by @eq-realization, and $matU$ is the payoff matrix of the sequence-form game. Linearity in $x$ does not survive the change of coordinates. Each coordinate of $x(theta)$ is a product of softmaxes, so $J(theta; vy)$ is a nonlinear function of $theta$. It is not a concave function of the behavioral probabilities, and the softmax does not restore concavity. In the sequence form the same payoff is linear in the sequence-form coordinates; the failure of concavity is an artifact of multiplying the local probabilities in @eq-realization.

= Gradient ascent <sec-gradient-ascent>

Treat $vy$ as fixed and take steps on the logits in the direction of the payoff. With step size $eta_t > 0$,

#set math.equation(numbering: "(1)")
$ theta^((t+1)) = theta^((t)) + eta_t nabla_theta J(theta^((t)); vy). $ <eq-ascent>
#set math.equation(numbering: none)

There is no projection in this iteration. The softmax in @eq-softmax is what keeps every local distribution on the simplex.

Because the objective we are ascending is not concave, it is not obvious that @eq-ascent converges, or even that every stationary point is a global maximizer. And in a game too large to differentiate $J$ in closed form, the gradient in @eq-ascent has to be replaced by an estimator built from sampled trajectories. This section answers the first question for exact gradients. The design of the estimator is the next choice.

= Hidden concavity <sec-hidden-concavity>

The failure of concavity is real in the behavioral coordinates. The sequence form is a reparameterization that makes the same function linear.

#definition[Hidden concavity][
  A function $J : Theta -> RR$ is _hidden concave_ if there exist a map $c : Theta -> cU$ into some set $cU$ and a concave function $H : cU -> RR$ such that
  $ J(theta) = H(c(theta)) quad "for every" theta in Theta. $
  The map $c$ is a concave reparameterization of $J$.
] <def-hidden-concavity>

For the objective in @eq-objective, take $c(theta) = x(theta)$ and $H(vx) = ip(vx, matU vy)$. For fixed $vy$, the function $H$ is linear on the sequence-form polytope, hence concave. Extensive-form payoffs are hidden concave in any parameterization of the behavioral strategy, including the logits of @eq-softmax. The sequence form is the reparameterization that makes the concavity visible. The same pattern appears outside extensive-form games. The linear quadratic regulator is a nonconvex problem in the entries of the controller and a convex problem in a different set of coordinates #citep(<Fazel18:LQR>).

One could ascend on the sequence-form vector $x$, where $H$ is concave. A scalable method ascends on $theta$ instead, so the property that replaces concavity has to be stated in those coordinates.

= The Polyak–Łojasiewicz condition <sec-pl>

#definition[Polyak–Łojasiewicz condition][
  Let $J$ attain a finite maximum value $J^*$. Then $J$ satisfies the _Polyak–Łojasiewicz (PŁ) condition_ with modulus $mu > 0$ if
  #set math.equation(numbering: "(1)")
  $ J^* - J(theta) <= (1 / (2 mu)) norm(nabla J(theta))_2^2 $ <eq-pl>
  #set math.equation(numbering: none)
  at every $theta$ where the gradient exists.
] <def-pl>

The inequality reads in either direction. If $nabla J(theta) = 0$, the right-hand side vanishes, so $J(theta) = J^*$. Every stationary point is a global maximizer. In the other direction, a large optimality gap forces the gradient to be large, so a gradient step taken far from the maximizer still moves.

Smooth strongly concave functions satisfy @eq-pl. On an unconstrained domain, $mu$-strong concavity means
$ J(theta') <= J(theta) + ip(nabla J(theta), theta' - theta) - (mu / 2) norm(theta' - theta)_2^2 $
for every $theta, theta'$. The right-hand side, as a function of $theta'$, is maximized at $theta' = theta + mu^(-1) nabla J(theta)$, where its value is $J(theta) + (1 / (2 mu)) norm(nabla J(theta))_2^2$. Since no value of $J$ exceeds $J^*$, this implies @eq-pl with the same modulus $mu$.

The converse fails: the PŁ condition does not require concavity, and functions that are nonconcave can still satisfy @eq-pl #citep(<Karimi16:PL>).

= Convergence of gradient ascent <sec-pl-convergence>

PŁ and smoothness are enough for gradient ascent. No concavity is required. The argument below is for exact steps on one fixed unconstrained objective.

#theorem[
  Let $J$ be $L$-smooth, attain its maximum $J^*$, and satisfy @def-pl with modulus $mu in (0, L]$. The iteration
  $ theta^((t+1)) = theta^((t)) + L^(-1) nabla J(theta^((t))) $
  satisfies
  $ J^* - J(theta^((t))) <= (1 - mu / L)^t (J^* - J(theta^((0)))). $
] <thm-pl-rate>

#proof[
  $L$-smoothness gives, for every $theta$ and $theta'$,
  $ J(theta') >= J(theta) + ip(nabla J(theta), theta' - theta) - (L / 2) norm(theta' - theta)_2^2. $
  Substitute $theta' = theta + L^(-1) nabla J(theta)$. The inner product contributes $L^(-1) norm(nabla J(theta))_2^2$, and the quadratic penalty contributes half of that, so
  $ J(theta^((t+1))) >= J(theta^((t))) + (1 / (2 L)) norm(nabla J(theta^((t))))_2^2. $
  Rearranging @eq-pl as $(1/2) norm(nabla J)_2^2 >= mu (J^* - J)$ turns the increase into a fixed fraction of the gap,
  $ (1 / (2 L)) norm(nabla J(theta^((t))))_2^2 >= (mu / L) (J^* - J(theta^((t)))). $
  Therefore
  $ J^* - J(theta^((t+1))) <= (1 - mu / L) (J^* - J(theta^((t)))). $
  Iterating the contraction gives the claim.
]

The step size $1/L$ is the one that makes the algebra close. Any fixed step in $(0, 2/L)$ also produces a geometric rate under the same hypotheses #citep(<Karimi16:PL>).

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
