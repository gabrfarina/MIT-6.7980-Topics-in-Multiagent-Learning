#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

= Self-play and regularization <sec-rl-regularization>

Choosing a policy representation and a gradient estimator does not settle
whether self-play converges. Each player's objective changes as the opponent
learns. Even with exact gradients, the current strategies can keep moving
without approaching equilibrium.

== Exact gradients need not converge <sec-rl-cycling>

#example[Matching pennies][
  The row player receives $+1$ when the actions match and $-1$ otherwise;
  the column player receives the opposite payoff. If $p,q$ are their
  probabilities of choosing the first action, the expected row payoff is
  $u(p,q)=(2p-1)(2q-1)$. The unique Nash equilibrium is $p=q=1/2$.

  Consider simultaneous gradient ascent and descent in the scalar coordinates
  $p,q$ with step size $eta>0$. As long as both updates remain in $[0,1]$,
  $ p^+ = p + eta(4q-2), quad q^+ = q - eta(4p-2). $
  Squaring and adding the deviations from $1/2$ shows that the squared
  distance to equilibrium grows by a factor of $1+16eta^2$ at each such step.
  Thus even exact gradients move a nearby nonequilibrium point farther away.
] <ex-rl-cycling>

The
#lecture-link("learning_intro", <thm-regret-gap>)[no-regret self-play guarantee]
concerns average strategies, whereas
#lecture-link("learning2", <sec-optimism>)[optimistic updates] can give
convergence of the current strategies. Here we study regularization.

== KL regularization and MMD <sec-rl-kl-objective>

Return to a finite matrix game with strategies $vp in Delta^m$ and
$vq in Delta^n$, where $Delta^k$ denotes distributions over $k$ actions.
The row payoff is $vp^top matU vq$. Fix reference distributions
$vrho_1,vrho_2$ with every coordinate positive.
#block(breakable: false)[
  Define the Kullback--Leibler divergence using natural logarithms and $0 ln 0=0$:
  $ upright("KL")(vp || vrho_1) = sum_(a=1)^m p_a ln(p_a/rho_(1,a)). $
]
For a weight $alpha>0$, the row player maximizes and the column player
minimizes the regularized payoff
#set math.equation(numbering: "(1)")
$ L_(alpha)(vp,vq) := vp^top matU vq
    -alpha upright("KL")(vp || vrho_1)
    +alpha upright("KL")(vq || vrho_2). $ <eq-rl-kl-game>
#set math.equation(numbering: none)

The signs follow the players' objectives: the maximizer is penalized for
departing from $vrho_1$, and the minimizer for departing from $vrho_2$.
For uniform references,
$upright("KL")(vp || vrho_1)=ln m+H(vp)$, where
$H(vp)=sum_a p_a ln p_a$ is negative entropy. Thus the row player's penalty is an
entropy bonus up to a constant; the column player's penalty has the same
interpretation in its own utility.

The regularized payoff is strictly concave in $vp$ and strictly convex in
$vq$, and has a unique saddle point.

Magnetic mirror descent (MMD) adds a reference penalty to the
#lecture-link("learning1", <sec-omd-mwu>)[entropy-based mirror-descent update]
#citep(<Sokota23:MMD>). Starting from full-support strategies, the row player computes
#set math.equation(numbering: "(1)")
$ vp^((t+1)) = argmax_(vp in Delta^m) {
  vp^top matU vq^((t)) - alpha upright("KL")(vp || vrho_1)
  - eta^(-1) upright("KL")(vp || vp^((t)))
}. $ <eq-rl-mmd-prox>
#set math.equation(numbering: none)
The first KL term changes the game being solved by keeping the strategy near
the fixed reference. The second keeps the next strategy near the current one;
a smaller $eta$ makes this penalty stronger. The column player minimizes
the row payoff plus its corresponding two KL penalties. Both players use
the old opponent strategy, so their updates are simultaneous.

For this exact-feedback matrix game, fixed $alpha>0$ and
$0<eta<=alpha/M^2$, where $M=max_(a,b)|matU_(a,b)|>0$, guarantee convergence
to the regularized saddle point #citep(<Sokota23:MMD>, [Theorem 3.4]).
This result concerns full-support probability vectors; neural policies and
extensive-form entropy require their own analysis.

== Convergence to which equilibrium? <sec-rl-regularization-bias>

To measure progress in the original game, use its Nash gap $gamma(vp,vq)$:
the sum of the two players' best-response gains. It is zero exactly at Nash
equilibrium. For matching pennies,
$ gamma(vp,vq)=|2p-1|+|2q-1|. $ <eq-rl-nash-gap>

#example[A small residual, but a nonzero Nash gap][
  Use matching pennies with $vrho_1=vrho_2=(0.8,0.2)$, $alpha=0.3$, and
  $eta=0.1$, starting from $p=0.8,q=0.35$. After $1000$ simultaneous MMD
  steps, the first-action probabilities are $p approx 0.624$ and $q approx 0.434$.
  At the unrounded iterate, the partial derivatives of the regularized payoff
  in $p,q$ are both below $2 dot 10^(-11)$ in absolute value, yet
  $gamma(vp,vq) approx 0.380$.
  The update has nearly solved the regularized game, whose equilibrium differs
  from the original game's.
] <ex-rl-fixed-magnet>

#figure(
  image("figures/deep_rl_regularization/mmd_bias.svg", width: 100%,
    alt: "MMD approaches a regularized limit away from the Nash equilibrium. The original Nash gap stays near 0.38 while the regularized residual approaches zero."),
  caption: [Matching pennies from the
    #link("https://www.mit.edu/~6.7980/slides/L09_deep_rl.html#rl-regularization")[lecture slides].
    Residual: the largest absolute partial derivative of $L_alpha$ in $p,q$,
    plotted on a logarithmic scale.],
) <fig-rl-mmd-bias>

The regularization weight controls this bias. At the exact regularized
equilibrium $(vp_alpha,vq_alpha)$,
$ gamma(vp_alpha,vq_alpha) <= alpha(
      ln(1/(min_a rho_(1,a))) + ln(1/(min_b rho_(2,b)))). $
Regularized optimality bounds each player's payoff gain by its increased
KL penalty. Adding these bounds gives the result. Uniform references give
$alpha(ln m+ln n)$.

With fixed full-support references, this bound vanishes as $alpha->0$.
The regularized games must also be solved increasingly accurately;
reducing $alpha$ alone is not enough. Updating the reference policy is
outside the fixed-reference guarantee above.

#paragraph-marker() *How much entropy regularization?*~~

Across five games, Rudolph et al.
#citep(<Rudolph26:Reevaluating>, [Figure 7 and Appendix E]) found the lowest
mean exploitability at entropy coefficients $0.05$--$0.2$, pooling MMD, PPO,
and PPG. Surveyed PPO defaults were $0$--$0.01$.

These results suggest trying larger coefficients than common PPO defaults.
The best value depends on payoff scale and advantage normalization.

#lec_bibliography("meta/refs.bib")
