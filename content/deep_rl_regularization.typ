#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

= Choice III: regularization <sec-rl-regularization>

Choosing a policy representation and a gradient estimator does not settle
whether self-play converges. Each player's objective changes as the opponent
learns. Even with exact gradients, the current strategies can keep moving
without approaching equilibrium.

== Exact gradients need not converge <sec-rl-cycling>

#example[Matching pennies][
  Let the row player maximize the payoff of the matrix
  $ matU = mat(1, -1; -1, 1), $
  and let the column player minimize it. Write their strategies as
  $vp=(p,1-p)$ and $vq=(q,1-q)$. The expected payoff is
  $ u(p,q) = vp^top matU vq = (2p-1)(2q-1), $
  and the unique Nash equilibrium is $p=q=1/2$.

  Consider simultaneous gradient ascent and descent in the scalar coordinates
  $p,q$. While neither update needs projection onto $[0,1]$,
  $ p^+ = p + eta(4q-2), quad q^+ = q - eta(4p-2). $
  With $a=p-1/2$ and $b=q-1/2$, the squared distance to equilibrium satisfies
  $ (a^+)^2+(b^+)^2 = (1+16eta^2)(a^2+b^2). $
  Thus every positive step size pushes a nearby nonequilibrium point farther away.
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
$vrho_1,vrho_2$ with every coordinate positive. Define
the Kullback--Leibler divergence using natural logarithms and $0 ln 0=0$:
$ upright("KL")(vp || vrho_1) = sum_(a=1)^m p_a ln(p_a/rho_(1,a)). $
For a weight $alpha>0$, consider
#set math.equation(numbering: "(1)")
$ max_(vp in Delta^m) min_(vq in Delta^n) L_(alpha)(vp,vq), quad
  L_(alpha)(vp,vq) := vp^top matU vq
    -alpha upright("KL")(vp || vrho_1)
    +alpha upright("KL")(vq || vrho_2). $ <eq-rl-kl-game>
#set math.equation(numbering: none)

The signs follow the players' objectives: the maximizer is penalized for
departing from $vrho_1$, and the minimizer for departing from $vrho_2$.
If $vrho_1$ is uniform, then
$upright("KL")(vp || vrho_1)=ln m-H(vp)$, where
$H(vp)=-sum_a p_a ln p_a$ is entropy. Thus the row player's penalty is an
entropy bonus up to a constant; the column player's penalty has the same
interpretation in its own utility.

The regularized payoff is strictly concave in $vp$ and strictly convex in
$vq$, and has a unique saddle point.

Magnetic mirror descent (MMD) combines attraction to the fixed reference with
a penalty for moving too far from the current strategy
#citep(<Sokota23:MMD>). With full-support initial strategies and step size
$eta>0$, the row player computes
#set math.equation(numbering: "(1)")
$ vp^((t+1)) = argmax_(vp in Delta^m) {
  vp^top matU vq^((t)) - alpha upright("KL")(vp || vrho_1)
  - eta^(-1) upright("KL")(vp || vp^((t)))
}. $ <eq-rl-mmd-prox>
#set math.equation(numbering: none)
The reference $vrho_1$ changes the target; the current strategy $vp^((t))$
limits the step. Solving this problem and its column-player counterpart gives
#set math.equation(numbering: "(1)")
$ p_a^((t+1)) & prop
  (p_a^((t)) rho_(1,a)^(alpha eta) exp(eta (matU vq^((t)))_a))^(1/(1+alpha eta)), \
  q_a^((t+1)) & prop
  (q_a^((t)) rho_(2,a)^(alpha eta) exp(-eta (matU^top vp^((t)))_a))^(1/(1+alpha eta)). $ <eq-rl-mmd-update>
#set math.equation(numbering: none)
Both updates use the old profile
$(vp^((t)),vq^((t)))$.

For this exact-feedback matrix game, fixed $alpha>0$ and
$0<eta<=alpha/M^2$, where $M=max_(a,b)|matU_(a,b)|>0$, guarantee convergence
to the regularized saddle point #citep(<Sokota23:MMD>, [Theorem 3.4]).
This result concerns full-support probability vectors; neural policies and
extensive-form entropy require their own analysis.

== Convergence to which equilibrium? <sec-rl-regularization-bias>

To measure progress in the original game, use its Nash gap
#set math.equation(numbering: "(1)")
$ gamma(vp,vq) := max_(vp' in Delta^m) (vp')^top matU vq
                -min_(vq' in Delta^n) vp^top matU vq'. $ <eq-rl-nash-gap>
#set math.equation(numbering: none)
It is the sum of the two players' unilateral improvement opportunities, and is
zero exactly at Nash equilibrium. For matching pennies it reduces to
$ gamma(vp,vq)=|2p-1|+|2q-1|. $

#example[A small residual, but a nonzero Nash gap][
  Use matching pennies with $vrho_1=vrho_2=(0.8,0.2)$, $alpha=0.3$, and
  $eta=0.1$, starting from $p=0.8,q=0.35$. After $1000$ simultaneous MMD
  steps, the first-action probabilities are $p approx 0.624$ and $q approx 0.434$.
  #block(width: 100%, breakable: false)[
    Define the residuals of the regularized first-order conditions:
    $ r_1 &:= 4q-2-alpha(ln(p/(1-p))-ln 4), \
      r_2 &:= 2-4p-alpha(ln(q/(1-q))-ln 4). $
  ]
  Both vanish at the regularized saddle point. At the unrounded iterate,
  $max(|r_1|,|r_2|)<2 dot 10^(-11)$, yet $gamma(vp,vq) approx 0.380$.
  The update has nearly solved the regularized game, whose equilibrium differs
  from the original game's.
] <ex-rl-fixed-magnet>

#figure(
  image("figures/deep_rl_regularization/mmd_bias.svg", width: 100%,
    alt: "MMD approaches a regularized limit away from the Nash equilibrium. The original Nash gap stays near 0.38 while the regularized residual approaches zero."),
  caption: [The fixed-reference example from the
    #link("https://www.mit.edu/~6.7980/slides/L09_deep_rl.html#rl-regularization")[lecture slides].
    The residual is $max(|r_1|,|r_2|)$; the right panel uses a logarithmic scale.],
) <fig-rl-mmd-bias>

To separate this bias from optimization error, define the regularized saddle gap
$ gamma_(alpha)(vp,vq) := max_(vp' in Delta^m) L_(alpha)(vp',vq)
                       -min_(vq' in Delta^n) L_(alpha)(vp,vq'). $
Then
$ gamma(vp,vq) <= gamma_(alpha)(vp,vq) + alpha(
      ln(1/(min_a rho_(1,a))) + ln(1/(min_b rho_(2,b)))). $
To see this, choose pure best responses $ve_a$ to $vq$ and $ve_b$ to $vp$
in the original game. Expanding $L_alpha$ and dropping the nonpositive KL terms gives
$ gamma(vp,vq) <= L_(alpha)(ve_a,vq)-L_(alpha)(vp,ve_b)
    +alpha ln(1/rho_(1,a))+alpha ln(1/rho_(2,b)). $
The first difference is at most $gamma_alpha$; bounding each reference
probability below proves the claim. For uniform references the bias term is
$alpha(ln m+ln n)$.

With fixed full-support references, $alpha->0$ and $gamma_alpha->0$ together
give vanishing original-game Nash gap. Annealing the coefficient alone does
not ensure that optimization error vanishes. Updating the reference policy
is a different operation, outside the fixed-reference guarantee above.

#paragraph-marker() *How much entropy regularization?*~~

In the five-game sweeps of Rudolph et al.
#citep(<Rudolph26:Reevaluating>, [Figure 7 and Appendix E]), pooling MMD,
PPO, and PPG, entropy coefficients between $0.05$
and $0.2$ gave the best average exploitability. The surveyed PPO defaults were
$0$ to $0.01$. This supports tuning beyond familiar single-agent defaults.

The numerical scale depends on the implementation's payoff scale and advantage
normalization. For example, multiplying $matU$ by $c>0$ in the matrix-game
objective is equivalent to using the original payoffs with weight $alpha/c$.

#lec_bibliography("meta/refs.bib")
