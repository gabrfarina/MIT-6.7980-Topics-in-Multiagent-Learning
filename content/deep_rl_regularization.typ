#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

= Self-play and regularization <sec-rl-regularization>

Improving against a fixed opponent and converging in self-play are different
questions. In self-play, both players change their policies, so the objective
each player optimizes changes after every round. Even exact gradients can fail
to bring the current strategies to equilibrium. We first see this in a matrix
game, then introduce a regularized update that does converge in that setting.

== Exact gradients need not converge <sec-rl-cycling>

#example[Matching pennies][
  Let the row player maximize the payoff of the matrix
  $ U = mat(1, -1; -1, 1), $
  and let the column player minimize it. Write their strategies as
  $vp=(p,1-p)$ and $vq=(q,1-q)$. The expected payoff is
  $ u(p,q) = vp^top U vq = (2p-1)(2q-1), $
  and the unique Nash equilibrium is $p=q=1/2$.

  Consider simultaneous gradient ascent and descent in the scalar coordinates
  $p,q$. While neither update needs projection onto $[0,1]$,
  $ p^+ = p + eta(4q-2), quad q^+ = q - eta(4p-2). $
  Put $a=p-1/2$ and $b=q-1/2$. Then
  $ a^+ = a+4eta b, quad b^+ = b-4eta a, $
  so the squared distance to equilibrium satisfies
  $ (a^+)^2+(b^+)^2 = (1+16eta^2)(a^2+b^2). $
  Every positive step size increases this distance unless we are already at
  equilibrium. Smaller steps slow the outward motion; they do not turn it into
  attraction. In continuous time, $dot(a)=4b$ and $dot(b)=-4a$, giving
  $ (dif)/(dif t)(a^2+b^2)=0. $
  Trajectories starting on a sufficiently small circle around equilibrium keep
  rotating on that circle. There is no sampling noise or approximation error.
] <ex-rl-cycling>

The discrete calculation applies only before projection is active. It already
rules out attraction near equilibrium for this simultaneous update. It does
not say that every gradient-based algorithm fails: the
#lecture-link("learning2", <sec-optimism>)[optimistic methods] modify the update.
Similarly, the #lecture-link("learning_intro", <thm-regret-gap>)[no-regret
self-play guarantee] concerns average strategies and assumes sublinear regret.
It does not by itself establish convergence of the current policy-gradient
iterates.

== Attracting strategies toward a reference <sec-rl-kl-objective>

Return to a finite matrix game with strategies $vp in Delta^m$ and
$vq in Delta^n$, where $Delta^k$ denotes distributions over $k$ actions.
The row payoff is $vp^top U vq$. Fix reference distributions
$rho_1,rho_2$ with every coordinate positive. Define
the Kullback--Leibler divergence using natural logarithms and $0 ln 0=0$:
$ upright("KL")(vp || rho_1) = sum_(a=1)^m p_a ln(p_a/rho_(1,a)). $
For a weight $alpha>0$, consider
#set math.equation(numbering: "(1)")
$ max_(vp in Delta^m) min_(vq in Delta^n) L_(alpha)(vp,vq), quad
  L_(alpha)(vp,vq) := vp^top U vq
    -alpha upright("KL")(vp || rho_1)
    +alpha upright("KL")(vq || rho_2). $ <eq-rl-kl-game>
#set math.equation(numbering: none)

The signs follow the players' objectives: the maximizer is penalized for
departing from $rho_1$, and the minimizer for departing from $rho_2$.
If $rho_1$ is uniform, then
$upright("KL")(vp || rho_1)=ln m-H(vp)$, where
$H(vp)=-sum_a p_a ln p_a$ is entropy. Thus the row player's penalty is an
entropy bonus up to a constant; the column player's penalty has the same
interpretation in its own utility.

The regularized payoff is strictly concave in $vp$ and strictly convex in
$vq$, so it has a unique saddle point. Its best responses have full support:
#set math.equation(numbering: "(1)")
$ p_a^* = frac(rho_(1,a) exp((U vq^*)_a/alpha),
                  sum_b rho_(1,b) exp((U vq^*)_b/alpha)), quad
  q_a^* = frac(rho_(2,a) exp(-(U^top vp^*)_a/alpha),
                  sum_b rho_(2,b) exp(-(U^top vp^*)_b/alpha)). $ <eq-rl-soft-response>
#set math.equation(numbering: none)
For example, differentiating the row objective subject to $sum_a p_a=1$
gives $(U vq)_a-alpha(ln(p_a/rho_(1,a))+1)=lambda$. Solving for $p_a$
and normalizing gives the first expression. These equations characterize the
target; repeatedly applying simultaneous best responses is a different
algorithm from the update below.

== A regularized update <sec-rl-mmd>

Magnetic mirror descent (MMD) combines attraction to the fixed reference with
a penalty for moving too far from the current strategy
#citep(<Sokota23:MMD>). With full-support initial strategies and step size
$eta>0$, the row player computes
#set math.equation(numbering: "(1)")
$ vp^((t+1)) = argmax_(vp in Delta^m) {
  vp^top U vq^((t)) - alpha upright("KL")(vp || rho_1)
  - eta^(-1) upright("KL")(vp || vp^((t)))
}. $ <eq-rl-mmd-prox>
#set math.equation(numbering: none)
The two KL terms have different roles: $rho_1$ specifies the regularized
objective, while $vp^((t))$ limits the step. The first-order condition yields
#set math.equation(numbering: "(1)")
$ p_a^((t+1)) & prop
  (p_a^((t)) rho_(1,a)^(alpha eta) exp(eta (U vq^((t)))_a))^(1/(1+alpha eta)), \
  q_a^((t+1)) & prop
  (q_a^((t)) rho_(2,a)^(alpha eta) exp(-eta (U^top vp^((t)))_a))^(1/(1+alpha eta)). $ <eq-rl-mmd-update>
#set math.equation(numbering: none)
Normalize each vector to sum to one. Both updates use the old profile
$(vp^((t)),vq^((t)))$.

For this finite matrix game with exact feedback, fixed $alpha>0$, and
$0<eta<=alpha/M^2$, where $M=max_(a,b)|U_(a,b)|>0$, MMD satisfies
$ D_(t+1) <= D_t/(1+eta alpha), quad
  D_t := upright("KL")(vp^* || vp^((t)))
       +upright("KL")(vq^* || vq^((t))). $
This is the matrix-game specialization of Theorem 3.4 in
#citep(<Sokota23:MMD>). It guarantees convergence to the regularized saddle
point. It is not a convergence guarantee for arbitrary neural self-play.
In extensive-form games, the choice of entropy and the strategy representation
require their own analysis.

== Convergence to which equilibrium? <sec-rl-regularization-bias>

To measure progress in the original game, use its Nash gap
#set math.equation(numbering: "(1)")
$ G(vp,vq) := max_(vp' in Delta^m) (vp')^top U vq
                -min_(vq' in Delta^n) vp^top U vq'. $ <eq-rl-nash-gap>
#set math.equation(numbering: none)
It is the sum of the two players' unilateral improvement opportunities, and is
zero exactly at Nash equilibrium. For matching pennies it reduces to
$ G(vp,vq)=|2p-1|+|2q-1|. $

#example[A small residual, but a nonzero Nash gap][
  Use matching pennies with $rho_1=rho_2=(0.8,0.2)$, $alpha=0.3$, and
  $eta=0.1$, starting from $p=0.8,q=0.35$. After $1000$ simultaneous MMD
  steps, the first-action probabilities are approximately
  $ p=0.623893, quad q=0.433986. $
  #block(width: 100%, breakable: false)[
    The regularized first-order conditions are
    $ r_1 &= 4q-2-alpha(ln(p/(1-p))-ln 4)=0, \
      r_2 &= 2-4p-alpha(ln(q/(1-q))-ln 4)=0. $
  ]
  At the unrounded iterate, $max(|r_1|,|r_2|)<2 dot 10^(-11)$, yet
  $ G(vp,vq) approx 0.379814. $
  This reproduces the fixed-reference example in the
  #link("https://www.mit.edu/~6.7980/slides/L09_deep_rl.html#rl-regularization")[lecture slides].
  MMD has nearly solved the regularized game. The nonzero original-game gap is the
  effect of the fixed regularization, not failure to solve that problem.
] <ex-rl-fixed-magnet>

#figure(
  image("figures/deep_rl_regularization/mmd_bias.svg", width: 100%,
    alt: "Matching-pennies MMD trajectory approaches a regularized limit away from the Nash equilibrium. Over 1000 iterations, the original Nash gap stays near 0.38 while the regularized KKT residual falls below 2 times 10 to the minus 11."),
  caption: [Simultaneous MMD with $rho_1=rho_2=(0.8,0.2)$,
    $alpha=0.3$, and $eta=0.1$, from $p=0.8,q=0.35$ for $1000$ steps.
    The right panel uses a logarithmic vertical scale.],
) <fig-rl-mmd-bias>

Reducing $alpha$ can reduce this bias. The following exercise makes precise
what must also happen to the optimization error.

#exercise[Regularization bias][
  Define the regularized saddle gap
  $ G_(alpha)(vp,vq) := max_(vp' in Delta^m) L_(alpha)(vp',vq)
                       -min_(vq' in Delta^n) L_(alpha)(vp,vq'). $
  Suppose $G_(alpha)(vp,vq)<=delta$. Show that
  $ G(vp,vq) <= delta + alpha(
      ln(1/(min_a rho_(1,a))) + ln(1/(min_b rho_(2,b)))). $
  Deduce the bound $delta+alpha(ln m+ln n)$ for uniform references.
] <ex-rl-bias-bound>

#block(width: 100%, breakable: false)[
#solution[
  Write $K_(1)(vp)=upright("KL")(vp || rho_1)$ and
  $K_(2)(vq)=upright("KL")(vq || rho_2)$. Let $hat(vp)$ be a best response
  to $vq$, and $hat(vq)$ a best response to $vp$, in the original game.
  Expanding $L_alpha$ gives
  $ G(vp,vq)
    &= L_(alpha)(hat(vp),vq)-L_(alpha)(vp,hat(vq)) \
    &quad +alpha(K_(1)(hat(vp))-K_(1)(vp)
                  +K_(2)(hat(vq))-K_(2)(vq)) \
    &<= delta+alpha(K_(1)(hat(vp))+K_(2)(hat(vq))). $
  We used the definition of $G_alpha$ and nonnegativity of KL divergence.
  For any distribution $vs$ and full-support $rho$,
  $ upright("KL")(vs || rho)
    =sum_a s_a ln s_a +sum_a s_a ln(1/rho_a)
    <=ln(1/(min_a rho_a)). $
  Apply this to both remaining terms.
]
]

For fixed full-support references, a sequence with $alpha->0$ and
$G_alpha->0$ therefore has vanishing original-game Nash gap. Simply decreasing
the coefficient during training does not ensure the second condition.
Updating the reference policy is another way to change the regularized
problem, but it is not the same as annealing the coefficient; the fixed-reference
convergence statement above does not analyze that outer update.

== How much entropy regularization? <sec-rl-entropy-coefficient>

The coefficient matters in practice. Figure 7 and Appendix E of
#citep(<Rudolph26:Reevaluating>) aggregate MMD, PPO, and PPG results across
five imperfect-information games. In these sweeps, entropy coefficients
between $0.05$ and $0.2$ gave the best average exploitability, whereas the
surveyed PPO implementations used defaults between $0$ and $0.01$.
The results vary by game; they support tuning entropy explicitly rather
than treating a standard single-agent default as a suitable choice.

These numbers depend on the implementation's payoff scale and advantage
normalization. In the matrix-game objective above, multiplying $U$ by
$c>0$ while holding $alpha$ fixed is equivalent, after dividing the
objective by $c$, to using the original payoffs with coefficient $alpha/c$.
Thus a useful numerical range in one setup need not transfer to another.

#lec_bibliography("meta/refs.bib")
