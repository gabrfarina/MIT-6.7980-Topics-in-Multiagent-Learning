#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
  lec_num: 6,
  date: [Thu, Oct 1, 2026],
  title: "Learning with bandit feedback",
)

The #lecture-link("learning_intro", <def-external-regret>)[regret-minimization model] considered so far assumes that the learner receives enough information from the environment that she can compute her utility not only on the strategy she selected to play at each round of the interaction but also any counter-factual strategy that she could have played at that round. That is, we assume _full-information_ feedback. This is a strong assumption, and in many cases, the decision-maker only receives partial feedback. In this lecture, we consider the case where the decision maker receives feedback only on the strategy they played. This is known as _bandit feedback_.

= Setup and general considerations

Like in our prior lectures, we will study _linear_ settings, where our sequential decision-maker chooses a strategy $vx^((t)) in cX$ in some strategy set satisfying $cX subset.eq RR^n$. In the full-information setting that we have already studied, the feedback that our decision maker receives, at every round $t$, is a utility function $u^((t)): vx |-> ip(vg^((t)), vx)$, from which they can compute their realized utility, $w^((t)) := ip(vg^((t)), vx^((t)))$, for the strategy they played as well as the counterfactual utility they would have received from any strategy they could have played. In the _bandit_ setting, the decision-maker only receives as feedback their realized utility $w^((t))$ as opposed to their complete utility function $u^((t))$.

As a general principle, algorithms for the _bandit_ setting are constructed from regret minimizers for the full-information setting. Indeed, the key idea is to construct an _estimator_ $tilde(vg)^((t))$ of the (unobserved) utility gradient $vg^((t))$, and feed that into a full-information regret minimizer. The estimator is constructed from the observed utility $w^((t))$ and the chosen strategy $vx^((t))$.

The utility function can still be picked adversarially by the environment. However, to get guarantees, it is necessary to reduce the power of the environment by letting the utility $u^((t))$ only depend on $vx^((1)), ..., vx^((t-1))$ but _not_ on $vx^((t))$. In other words, the environment can pick the utility adaptively, but must decide the utility _before_ the learner picks the strategy, and not after. This restriction still allows convergence to equilibria if bandit algorithms are used by players to iteratively update their strategies in games.

Typically, the construction of bandit algorithms follows the template shown in @fig-bandit.
#figure(
  caption: [General template for bandit learning algorithms. $cX$ is the space of strategies of the learner. The output of the "strategy sampler" is a strategy from a restricted set of strategies. The name "strategy sampler" is generally a misnomer, but it is fitting in the widely-studied setting where $cX=Delta(A)$ for some finite set of actions $A$. In this case, a common instantiation of the strategy sampler is to take as input a distribution $vp^((t)) in Delta(A)$ and sample an action $a^((t)) ~ vp^((t))$. In this case, $vx^((t))$ would be a single-atom distribution with an atom at $a^((t))$. But, in general, we allow for more general $cX$'s and more general samplers.],
)[
  #image(
    "figures/bandit/bandit.svg",
    width: 100%,
    alt: "Bandit algorithm template: observed utility enters a gradient estimator, then a full-information regret minimizer, exploration mixture, and strategy sampler.",
  )
] <fig-bandit>

Some loss-based algorithms obtain pseudoregret bounds without an explicit exploration mixture. High-probability guarantees require additional control of estimation errors; a uniform mixture alone does not provide that guarantee. We explain the difference next.

#paragraph-marker() *Stochastic regret guarantees.*~~
Because online learning algorithms benefit from randomization, as is crucially the case in bandit settings, the regret of a bandit algorithm is a random variable. This adds a layer of complexity when approaching the analysis of bandit algorithms. As a rule of thumb, three "flavors" of guarantees are typically considered in the literature. We list them from the weakest (and easiest to obtain) to the strongest (and hardest to obtain):
- Guarantees on the _pseudoregret_, namely guarantees of the following form:
  $
    "PseudoReg"^((T)) := max_(xhat in cX) EE[sum_(t=1)^T ip(vg^((t)), xhat) - sum_(t=1)^T ip(vg^((t)), vx^((t)))] = o(T).
  $

- Guarantees on the _expected regret_, namely guarantees of the following form:
  $
    #h(.5cm)EE["Reg"^((T))] := EE[max_(xhat in cX) sum_(t=1)^T ip(vg^((t)), xhat) - sum_(t=1)^T ip(vg^((t)), vx^((t)))] = o(T).
  $
  Note the change of order between the expectation and the maximum compared with the pseudoregret introduced in the previous bullet point.

- _High-probability regret guarantees_, namely guarantees of the following form:
  $
    PP[
      max_(xhat in cX) sum_(t=1)^T ip(vg^((t)), xhat) - sum_(t=1)^T ip(vg^((t)), vx^((t))) <= o(T) sqrt(log 1/delta)
    ] >= 1-delta
  $
  for any $delta > 0$ small enough.

To make sense of the measures with respect to which the expectations and probabilities are computed in the above definitions, consider a randomized algorithm for the learner that takes as input the history, $(vx^((tau)),w^((tau)))_(tau<t)$, observable to the learner so far and produces a strategy $vx^((t))$ and, similarly, a randomized algorithm for the adversary that takes as input the history, $(vx^((tau)),u^((tau)))_(tau<t)$, observable to the adversary so far and chooses a utility function $u^((t))$. Pitting the two algorithms against each other defines a probability measure with respect to which the above expectations and probabilities are defined.

Finally, notice that Pseudoregret and expected regret guarantees are different, since $max EE <= EE max$, but the converse is not true in general. This means that bounding expected regret automatically bounds the pseudoregret but the opposite is not necessarily the case. In fact, bounds on the pseudoregret are _not_ strong enough to conclude convergence to the set of equilibria, in general.

#v(-1mm)
= Adversarial bandit learning in normal-form games

Let's start from the case of normal-form games, in which our decision maker faces the choice of picking an action out of a finite set $A$. The setting in this case is also known as _adversarial multi-armed bandit problem_. We have $cX = Delta(A)$.

#paragraph-marker() *Strategy sampler.*~~
In this settings, most algorithms use the natural strategy sampler: given a distribution $vp^((t)) in Delta(A)$, the decision maker samples an action $a^((t)) in A$ according to the probabilities in $vp^((t))$. The vector $vx^((t))$ is then set to the deterministic distribution $ve_(a^((t)))$. Clearly,
$EE_t [vx^((t))] = vp^((t)).$

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

Exp3 (short for "exponential weights for exploration and exploitation") adapts #lecture-link("learning1", <sec-mwu>)[multiplicative weights] to bandit feedback and was introduced by #citet(<auer2002nonstochastic>). We use a variant that needs no explicit exploration mixture. Convert rewards $g^((t))_a in [0,1]$ into losses $ell^((t))_a=1-g^((t))_a$. This changes neither realized regret nor pseudoregret.

Start with positive weights $W_(1,a)=1$. At time $t$, sample action $a^((t))$ from $p^((t))_a=W_(t,a)/sum_b W_(t,b)$ and observe its loss. Set
$ hat(vell)^((t))=frac(1-w^((t)), p^((t))_(a^((t)))) ve_(a^((t))), quad W_(t+1,a)=W_(t,a) exp(-eta hat(ell)^((t))_a). $
Equivalently, the full-information utility learner receives $-hat(vell)^((t))$.

#theorem[Exp3][
  For $K=|A|>=2$, this algorithm satisfies
  $ "PseudoReg"^((T)) <= frac(log K, eta) + eta K T/2. $
  Taking $eta=sqrt(frac(2 log K, K T))$ gives $"PseudoReg"^((T)) <= sqrt(2K T log K)$ against any nonanticipating adversary.
]
#proofsketch[
  Because the estimates are nonnegative, $exp(-z)<=1-z+z^2/2$ applies for every $z=eta hat(ell)^((t))_a$, even if an estimate is large. The exponential-weights potential bound against each fixed action $a$ is
  $
    sum_t ip(vp^((t)), hat(vell)^((t))) - sum_t hat(ell)^((t))_a <= frac(log K, eta) + eta/2 sum_t sum_b p^((t))_b (hat(ell)^((t))_b)^2.
  $
  Conditional unbiasedness identifies the expected loss terms, while
  $ EE_(t)[sum_b p^((t))_b (hat(ell)^((t))_b)^2]=sum_b (ell^((t))_b)^2 <= K. $
  Take expectations and then maximize over the fixed comparator. This proves pseudoregret; it does not interchange a random hindsight maximum with expectation.
]

== Tsallis entropy <sec-tsallis>

It can be shown that, information theoretically, no bandit learning algorithm for a finite set of actions $|A|$ can achieve better than $Omega(sqrt(T |A|))$ expected regret in general. The regret guaranteed by the Exp3 algorithm is therefore optimal only up to a logarithmic factor. It remained open for a long time whether this logarithmic factor could be removed. A positive answer was given by #citet(<audibert2010regret>), who proposed the idea of replacing #lecture-link("learning1", <sec-mwu>)[MWU] with #lecture-link("learning1", <ftrl-omd-general-case>)[FTRL] instantiated with the negative $(1\/2)$-Tsallis entropy regularizer
$
  psi(vx) = 2 - 2 sum_(a in A) sqrt(x_a).
$

#paragraph-marker() *The algorithm.*~~
The learner samples $a^((t)) ~ vy^((t))$ directly, with no exploration mixture, and uses the estimator
$ hat(vg)^((t)) := vone - frac(1 - w^((t)), y^((t))_(a^((t)))) ve_(a^((t))). $
It is unbiased, since each action $a$ is played with probability $y^((t))_a$, and all of its coordinates are at most $1$, although the coordinate of the played action can be very negative. The strategies are produced by FTRL on the estimated utilities,
$
  vy^((t)) := argmax_(xhat in Delta(A)) {ip(vs^((t-1)), xhat) - 1 / eta psi(xhat)}, qquad "where" quad vs^((t-1)) := sum_(tau=1)^(t-1) hat(vg)^((tau)).
$
The partial derivatives $-1 \/ sqrt(x_a)$ of $psi$ diverge at the boundary of the simplex, so the maximizer lies in the interior, and setting the gradient of the Lagrangian to zero gives $s^((t-1))_a + 1 \/ (eta sqrt(y^((t))_a)) = lambda^((t))$ for every action. Hence, the Tsallis-FTRL update is
$
  y^((t))_a = frac(1, eta^2 (lambda^((t)) - s^((t-1))_a)^2) qquad forall a in A,
$
where $lambda^((t)) > max_(a in A) s^((t-1))_a$ is the unique value for which the right-hand sides sum to $1$. There is no closed form for $lambda^((t))$, but since that sum is decreasing in $lambda^((t))$, it can be found by binary search. In multiplicative weights, $y^((t))_a prop exp(eta s^((t-1))_a)$; here, the probability of an action decays only polynomially in the amount by which its score trails.

#theorem[
  Assume that $vg^((t)) in [0,1]^A$ at all times $t$. For any $eta > 0$, the algorithm above guarantees
  $ "PseudoReg"^((T)) <= frac(2 sqrt(|A|), eta) + eta T sqrt(|A|). $
  In particular, the learning rate $eta = sqrt(2 \/ T)$ gives $"PseudoReg"^((T)) <= 2 sqrt(2 T |A|) = O(sqrt(T |A|))$, which is the optimal bound for bandit learning on finite probability distributions.
] <thm-tsallis>

The #lecture-link("learning1", <ftrl-omd-regret-bound>)[general regret bound for FTRL] is of no use here, because the dual norm of the estimates is unbounded. We give a direct proof.

#proof[
  Let $Phi(vs) := max_(xhat in Delta(A)) {ip(vs, xhat) - psi(xhat) \/ eta}$, so that $vy^((t))$ attains the maximum in $Phi(vs^((t-1)))$.

  _Step 1: regret against the estimates._ Fix any $vx^* in Delta(A)$. Since $Phi(vs^((T))) >= ip(vs^((T)), vx^*) - psi(vx^*) \/ eta$ and $Phi(vs^((0))) = -min psi \/ eta$, telescoping $Phi(vs^((T))) - Phi(vs^((0)))$ gives
  $
    sum_(t=1)^T ip(hat(vg)^((t)), vx^* - vy^((t))) <= frac(psi(vx^*) - min psi, eta) + sum_(t=1)^T (Phi(vs^((t))) - Phi(vs^((t-1))) - ip(hat(vg)^((t)), vy^((t)))).
  $
  On the simplex, $psi$ is at most $0$ and, by the Cauchy--Schwarz inequality, at least $2 - 2 sqrt(|A|)$. So the first term is at most $2 sqrt(|A|) \/ eta$.

  _Step 2: stability._ We show that each term of the last sum is at most $eta sum_(a in A) (y^((t))_a)^(3\/2) (1 - hat(g)^((t))_a)^2$. Fix $t$ and write $vy := vy^((t))$, $vs := vs^((t-1))$, and $vv := hat(vg)^((t)) - vone$, so that $vv <= 0$ in every coordinate. Since $ip(vone, xhat) = 1$ on the simplex, the term is unchanged if $hat(vg)^((t))$ is replaced by $vv$, and it is therefore equal to
  $
    Phi(vs + vv) - Phi(vs) - ip(vv, vy) = max_(xhat in Delta(A)) {ip(vv, xhat - vy) + ip(vs, xhat - vy) - frac(psi(xhat) - psi(vy), eta)}.
  $
  The optimality condition for $vy$ above reads $vs = lambda^((t)) vone + nabla psi(vy) \/ eta$, so $ip(vs, xhat - vy) = ip(nabla psi(vy), xhat - vy) \/ eta$ for all $xhat in Delta(A)$, and the term becomes
  $
    max_(xhat in Delta(A)) {ip(vv, xhat - vy) - 1 / eta div(xhat, vy, dgf: psi)}, qquad "where" quad div(xhat, vy, dgf: psi) = sum_(a in A) frac((sqrt(hat(x)_a) - sqrt(y_a))^2, sqrt(y_a)).
  $
  We now enlarge the domain of the maximum to all $xhat >= 0$, where the objective splits across coordinates. In the variable $z = sqrt(hat(x)_a)$, the objective for coordinate $a$ is the quadratic $v_a (z^2 - y_a) - (z - sqrt(y_a))^2 \/ (eta sqrt(y_a))$, which is concave because $v_a <= 0$. Its maximum value is
  $
    frac(eta y_a^(3\/2) v_a^2, 1 - eta sqrt(y_a) v_a) <= eta y_a^(3\/2) v_a^2.
  $
  This is where we use that the estimates are at most $1$: for a large positive $v_a$ the quadratic is convex, and its supremum is infinite.

  _Step 3: expectations._ The vector $vone - hat(vg)^((t))$ is zero except in the coordinate $a^((t))$, where it is at most $1 \/ y^((t))_(a^((t)))$. So the bound of Step 2 is at most $eta \/ sqrt(y^((t))_(a^((t))))$, and since $a^((t)) ~ vy^((t))$,
  $
    EE_(t)[frac(eta, sqrt(y^((t))_(a^((t)))))] = eta sum_(a in A) sqrt(y^((t))_a) <= eta sqrt(|A|),
  $
  again by the Cauchy--Schwarz inequality. Moreover, $vg^((t))$ and $vy^((t))$ are determined before $a^((t))$ is sampled, so $EE_(t)[ip(hat(vg)^((t)), vx^* - vy^((t)))] = ip(vg^((t)), vx^*) - EE_(t)[w^((t))]$. Taking expectations in Step 1 therefore gives
  $
    EE[sum_(t=1)^T ip(vg^((t)), vx^*) - sum_(t=1)^T w^((t))] <= frac(2 sqrt(|A|), eta) + eta T sqrt(|A|)
  $
  for every fixed $vx^* in Delta(A)$, which is the statement.
]

#paragraph-marker() *Where the improvement comes from.*~~
The analysis of Exp3 has the same two terms, and the regularizer trades one against the other. With the entropy regularizer the first term is only $log |A| \/ eta$, but the stability term weighs the squared estimate of action $a$ by $y^((t))_a$, which leaves a total of up to $eta |A|$ per round in expectation. The Tsallis regularizer weighs it by the smaller factor $(y^((t))_a)^(3\/2)$, which leaves at most $eta sqrt(|A|)$. The price is a first term of $2 sqrt(|A|) \/ eta$ instead of $log |A| \/ eta$, but the trade is favorable: after tuning $eta$, the regret scales as the square root of the product of the two terms, and that product is of order $T |A| log |A|$ for Exp3 but only $T |A|$ here.

A closely related analysis can be found in #citep(<zimmert2021tsallis>).

== The Exp3.P algorithm <sec-exp3p>

The guarantees seen so far bound the pseudoregret, an average over the learner's own randomness, and say little about a single run of the algorithm. The obstacle is that the conditional variance of $tilde(g)^((t))_a$ can be as large as the inverse of the probability of sampling $a$. #citet(<auer2002nonstochastic>) observe that, as a result, the realized regret of Exp3 might be as large as order $T^(3\/4)$.

Exp3.P is the modification of Exp3 that #citet(<auer2002nonstochastic>) introduced to obtain a regret bound that holds with high probability. It adds two ingredients to multiplicative weights. First, the learner samples not from the distribution $vy^((t)) in Delta(A)$ produced by multiplicative weights, but from its mixture with the uniform distribution,
$ vp^((t)) := (1-gamma) vy^((t)) + gamma vone / (|A|), $
where $gamma in (0,1]$ is the _exploration rate_. The importance sampling estimator accordingly divides by $p^((t))_(a^((t)))$. Second, multiplicative weights is fed not the estimate $tilde(vg)^((t))$ itself but $tilde(vg)^((t)) + vb^((t))$, where the _confidence bonus_ $b^((t))_a := alpha \/ (p^((t))_a sqrt(|A| T))$ is added to _every_ action, including those that were not played. The resulting algorithm is given in @algo-exp3p.

#pseudocode-list(
  numbered-title: [Exp3.P],
)[
  - *Parameters:* horizon $T$, learning rate $eta > 0$, exploration rate $gamma in (0,1]$, confidence parameter $alpha > 0$.
  + $vs^((0)) <- 0 in RR^A$
  + *for* $t = 1, ..., T$
    + $vy^((t)) <-$ `softmax`$(eta vs^((t-1)))$
    + $vp^((t)) <- (1-gamma) vy^((t)) + gamma vone \/ |A|$
    + sample $a^((t)) ~ vp^((t))$ and observe the utility $w^((t)) = g^((t))_(a^((t)))$
    + $tilde(vg)^((t)) <- (w^((t)) \/ p^((t))_(a^((t)))) ve_(a^((t)))$
    + $b^((t))_a <- alpha \/ (p^((t))_a sqrt(|A| T))$ for every $a in A$
    + $vs^((t)) <- vs^((t-1)) + tilde(vg)^((t)) + vb^((t))$
] <algo-exp3p>

Equivalently, the weights $W_(t,a) := exp(eta s^((t-1))_a)$ start equal and follow the multiplicative update
$ W_(t+1,a) = W_(t,a) exp(eta (tilde(g)^((t))_a + frac(alpha, p^((t))_a sqrt(|A| T)))). $

#theorem[Exp3.P #citep(<auer2002nonstochastic>)][
  Let $|A| >= 2$ and assume that $vg^((t)) in [0,1]^A$ at all times $t$. For any horizon $T>=1$ and any $delta in (0,1)$, run @algo-exp3p with
  $
    gamma = min{3/5, 2 sqrt(frac(3 |A| log |A|, 5 T))}, quad eta = frac(gamma, 3 |A|), quad alpha = 2 sqrt(log frac(|A| T, delta)).
  $
  Then, with probability at least $1-delta$, the realized regret $"Reg"^((T)) = max_(a in A) sum_(t=1)^T g^((t))_a - sum_(t=1)^T w^((t))$ satisfies
  $ "Reg"^((T)) <= O(sqrt(|A| T log frac(|A| T, delta)) + log frac(|A| T, delta)). $
] <thm-exp3p>

Both the horizon $T$ and the confidence level $delta$ must be known in advance, since they enter the parameters. #citet(<auer2002nonstochastic>) prove the bound for utilities fixed in advance, and remark that the argument extends to an environment that chooses $vg^((t))$ knowing the learner's draws up to time $t-1$.

#paragraph-marker() *The role of the confidence bonus.*~~
For a high-probability bound, the scores $vs^((T))$ must not _underestimate_ the true cumulative utility of any action, and in particular of the best one in hindsight. The unbiased estimates do not provide this: $sum_(t=1)^T tilde(g)^((t))_a$ is correct on average, but its deviations grow with the cumulative variance, which can be as large as $sum_(t=1)^T 1 \/ p^((t))_a$ and is largest exactly for the actions that the algorithm has been neglecting. The bonuses collected by an action are proportional to this same quantity, and they turn the scores into _upper confidence bounds_: #citet(<auer2002nonstochastic>) show that whenever $2 sqrt(log(|A| T \/ delta)) <= alpha <= 2 sqrt(|A| T)$, with probability at least $1-delta$,
$
  sum_(t=1)^T (tilde(g)^((t))_a + b^((t))_a) + alpha sqrt(|A| T) >= sum_(t=1)^T g^((t))_a qquad "simultaneously for all" a in A.
$
This is where the confidence level $delta$ enters the algorithm. The price of the bonus is bias: in each round the bonus inflates the scores by $ip(vp^((t)), vb^((t))) = alpha sqrt(|A| \/ T)$ on average under the sampling distribution, for a total of $alpha sqrt(|A| T)$, which is of the same order as the bound in @thm-exp3p.

#paragraph-marker() *The role of exploration.*~~
The uniform mixture plays no part in the concentration argument above. Its role is to guarantee that $p^((t))_a >= gamma \/ |A|$ for every action, which caps the size of everything that is fed to multiplicative weights: with $eta = gamma \/ (3|A|)$ and $alpha <= 2 sqrt(|A| T)$,
$
  eta (tilde(g)^((t))_a + b^((t))_a) <= 1/3 + frac(alpha, 3 sqrt(|A| T)) <= 1.
$
The analysis of multiplicative weights needs this, since it relies on the inequality $e^z <= 1 + z + z^2$, which is valid for $z <= 1$ but fails for large $z$. The price is that a $gamma$ fraction of the rounds is spent on uniformly random actions, which costs at most $gamma T$ in regret.

To summarize, exploration keeps each individual update small, while the confidence bonus keeps the accumulated estimation error one-sided. Adding exploration to an unbiased estimator, without the bonus or another mechanism that controls concentration, is not the Exp3.P algorithm and does not enjoy the guarantee of @thm-exp3p.

= Adversarial bandit learning on general convex domains

Today, we know that bandit optimization is possible well past probability simplexes. In fact, we can construct bandit algorithms for any convex and compact domain $cX subset.eq RR^d$.
In particular, we mention the general general result by #citet(<abernethy2008competing>), who showed that the a bandit algorithm can be constructed starting from a full-information regret miminizer built using the FTRL algorithm with a self-concordant distance-generating function.

#lec_bibliography("meta/refs.bib")
