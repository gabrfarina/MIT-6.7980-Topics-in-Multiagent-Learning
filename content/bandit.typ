
#paragraph-marker() *Gradient estimator.*~~ For this setting, the standard gradient estimator is the _importance sampling_ estimator. Given the utility scalar $w^((t)) in [0, 1]$, the importance sampling estimator is defined as
$ tilde(vg)^((t)) := (w^((t)) / p^((t))_(a^((t)))) ve_(a^((t))) in RR^A. $

#theorem[Assume $p^((t))_a>0$ for every action. Let $w^((t)) = ip(vg^((t)), vx^((t)))$ where $vg^((t))$ is some unknown utility gradient. Then, the importance sampling estimator $tilde(vg)^((t))$ is unbiased, that is,
  $EE_t [tilde(vg)^((t))] = vg^((t)).$
]
#v(-2mm)
#proof[
  The result follows by direct calculation. The randomness is due to the sampling of the action $a^((t))$. Each action $a in A$ is sampled with probability $p^((t))_a$. Hence,
  $
    EE_t [tilde(vg)^((t))] = sum_(a in A) p^((t))_a (g^((t))_a / p^((t))_a) ve_a = sum_(a in A) p^((t))_a (
      ip(vg^((t)), ve_(a)) / p^((t))_a
    ) ve_a = sum_(a in A) g^((t))_a ve_a = vg^((t)).
  $
  #v(-6mm)
]

== The Exp3 algorithm

Exp3 (short for "exponential weights for exploration and exploitation") adapts #lecture-link("learning1", <sec-mwu>)[multiplicative weights] to bandit feedback and was introduced by #citet(<auer2002nonstochastic>). We use the variant from the #link("https://www.mit.edu/~6.7980/slides/L06_bandit.pdf")[lecture slides], which needs no explicit exploration mixture. Assume $vg^((t)) in [0,1]^A$ at every round.

The adversary knows the algorithm and the past interaction, so it knows the sampling distribution $vy^((t))$ when choosing $vg^((t))$. However, it does not know the sampled action $a^((t))$ when making this choice.

#pseudocode-list(numbered-title: [Exp3])[
  + *Input:* finite action set $A$, learning rate $eta > 0$.
  + *Initialize:* $vy^((1)) <- frac(vone, |A|)$.
  + *For* $t >= 1$:
    + Sample $a^((t)) ~ vy^((t))$ and play $vx^((t)) = ve_(a^((t)))$.
    + Observe the scalar gain $w^((t)) = g^((t))_(a^((t)))$.
    + Set $hat(g)^((t))_c <- 1$ for every $c in A$.
    + Set $hat(g)^((t))_(a^((t))) <- 1 + frac(w^((t)) - 1, y^((t))_(a^((t))))$.
    + For every $c in A$, update
      $ y^((t+1))_c <- frac(y^((t))_c exp(eta hat(g)^((t))_c), sum_(j in A) y^((t))_j exp(eta hat(g)^((t))_j)). $
]

The initialization and update keep all sampling probabilities positive. Unlike the standard estimator above, every coordinate of $hat(vg)^((t))$ is at most $1$, although the estimate of the sampled action can be negative.

#theorem[Exp3][
  For $|A|>=2$, $T>=1$, and $eta>0$, this algorithm satisfies
  $ "PseudoReg"^((T)) <= frac(log |A|, eta) + frac(eta |A| T, 2). $
  Taking $eta=sqrt(frac(2 log |A|, |A| T))$ gives $"PseudoReg"^((T)) <= sqrt(2 |A| T log |A|)$.
]
#proofsketch[
  Here $EE_t$ denotes expectation over the sampled action, conditional on the past interaction, the current sampling distribution, and the gain vector already chosen for this round. Direct calculation gives, for each $c in A$,
  $
    EE_t [hat(g)^((t))_c] = 1 + y^((t))_c frac(g^((t))_c - 1, y^((t))_c) = g^((t))_c,
    quad ip(vy^((t)), hat(vg)^((t))) = w^((t)).
  $
  Since $hat(g)^((t))_j <= 1$, the inequality $exp(z)<=1+z+z^2/2$ for $z<=0$ applies to $z=eta (hat(g)^((t))_j-1)$. The exponential-weights potential bound against each fixed action $c$ is therefore
  $
    sum_(t=1)^T hat(g)^((t))_c - sum_(t=1)^T w^((t))
    <= frac(log |A|, eta) + eta/2 sum_(t=1)^T sum_(j in A) y^((t))_j (hat(g)^((t))_j-1)^2.
  $
  #block(breakable: false)[
    Only the sampled coordinate contributes to the quadratic term, so
    $ EE_t [sum_(j in A) y^((t))_j (hat(g)^((t))_j-1)^2] = sum_(j in A) (g^((t))_j-1)^2 <= |A|. $
  ]
  Take expectations and then maximize over the fixed comparator. This proves pseudoregret; it does not interchange a random hindsight maximum with expectation.
]

#paragraph-marker() *Gains in a general interval.*~~
If gains lie in a known interval $[a,b]$ with $a<b$, run the same algorithm with the observed scalar replaced by $frac(w^((t))-a, b-a)$. Translation cancels in regret comparisons, and scaling multiplies the bound by $b-a$, giving $"PseudoReg"^((T)) <= (b-a) sqrt(2 |A| T log |A|)$ with the learning rate above. If $a=b$, regret is zero.

== Tsallis entropy

It can be shown that, information theoretically, no bandit learning algorithm for a finite set of actions $|A|$ can achieve better than $Omega(sqrt(T |A|))$ expected regret in general. The regret guaranteed by the Exp3 algorithm is therefore optimal only up to a logarithmic factor. It remained open for a long time whether this logarithmic factor could be removed. A positive answer was given by #citet(<audibert2010regret>), who proposed the idea of replacing #lecture-link("learning1", <sec-mwu>)[MWU] with #lecture-link("learning1", <ftrl-omd-general-case>)[FTRL] instantiated with the negative $(1\/2)$-Tsallis entropy regularizer
$
  psi(vx) = 2 - 2 sum_(a in A) sqrt(x_a).
$

#theorem[
  If FTRL with (1/2)-Tsallis entropy receives the estimated utilities $hat(vg)^((t))$ defined above, with learning rate $eta = sqrt(1 \/ T)$, the resulting bandit algorithm guarantees pseudoregret
  $ "PseudoReg"^((T)) = O(sqrt(T|A|)), $
  which is the optimal bound for bandit learning on finite probability distributions.
]

A simplified analysis can also be found in #citep(<zimmert2021tsallis>).

== The Exp3.P algorithm

Exp3.P uses both uniform exploration and an upper-confidence correction to reward estimates #citep(<auer2002nonstochastic>). For $|A|>=2$, let $vy^((t))$ be normalized positive weights and sample from
$ vp^((t))=(1-gamma)vy^((t))+gamma frac(vone, |A|). $
With the reward estimator $tilde(vg)$ defined earlier, update the weights by
$ W_(t+1,a)=W_(t,a) exp(eta (tilde(g)^((t))_a + frac(alpha, p^((t))_a sqrt(|A| T)))). $
The positive bonus accounts for uncertainty; uniform exploration bounds inverse sampling probabilities. This is a different estimator/update from the Exp3 variant above.

#theorem[Exp3.P #citep(<auer2002nonstochastic>)][
  Initialize all weights equally. For horizon $T>=1$ and $delta in (0,1)$, choose
  $ gamma=min{3/5,2sqrt(frac(3 |A| log |A|, 5T))}, quad eta=gamma/(3 |A|), quad alpha=2sqrt(log(|A| T/delta)). $
  Then, with probability at least $1-delta$,
  $ "Reg"^((T)) <= O(sqrt(|A| T log(|A| T/delta)) + log(|A| T/delta)). $
]

The confidence parameter enters the logarithm and the bonus. Adding exploration to an unbiased estimator, without this correction or another concentration-control mechanism, is not the Exp3.P algorithm.

= Adversarial bandit learning on general convex domains

Bandit optimization also extends to any nonempty compact convex domain $cX subset.eq RR^d$. Assume uniformly bounded utilities: for some known $B>0$,
$ abs(ip(vg^((t)), vx)) <= B quad "for all" vx in cX "and all rounds" t. $
Compactness of $cX$ alone does not provide this bound. We describe the construction when $cX$ has nonempty interior; lower-dimensional domains can be handled in affine coordinates, and a singleton has zero regret.

The construction of #citet(<abernethy2008competing>) uses FTRL with a _self-concordant barrier_ $psi$. At an interior FTRL point $vy^((t))$, let $H_t := nabla^2 psi(vy^((t)))$ have positive eigenvalues $lambda_1, ..., lambda_d$ and orthonormal eigenvectors $vv_1, ..., vv_d$. Sample $i$ uniformly from ${1, ..., d}$ and, independently, a sign $sigma in {-1,+1}$ with equal probabilities. Play
$ vx^((t)) = vy^((t)) + sigma lambda_i^(-1/2) vv_i. $
The barrier's Dikin-ellipsoid property ensures $vx^((t)) in cX$. After observing only $w^((t)) = ip(vg^((t)), vx^((t)))$, form the estimate
$ tilde(vg)^((t)) := d w^((t)) sigma lambda_i^(1/2) vv_i $
and feed it to FTRL. Conditional on the past and the gain vector chosen before these random draws,
$ EE_t [vx^((t))] = vy^((t)), quad EE_t [tilde(vg)^((t))] = vg^((t)). $
The random sign cancels the center's contribution in expectation, and averaging over directions recovers the gradient. With a suitable learning rate, bounded utilities yield sublinear pseudoregret.

#lec_bibliography("meta/refs.bib")
