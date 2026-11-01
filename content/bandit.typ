#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
  lec_num: 6,
  date: [Thu, Oct 1, 2026],
  title: "Learning with bandit feedback",
)

// Following the intro, the lecture notes always refers to the learner with she/her pronouns (you can change this later on)
The #lecture-link("learning_intro", <def-external-regret>)[regret-minimization model] we've considered so far assumes that the learner receives enough information from the environment that she can compute her utility not only on the strategy she selected to play at each round of the interaction but also any counterfactual strategy that she could have played at that round. In more technical terms, we assume _full-information_ feedback.

This is a very strong assumption, and in many cases, the decision maker only receives partial feedback. In this lecture, we consider the special case where the decision maker receives feedback only on the strategy she played. This is known as _bandit feedback_.

= Setup and general considerations

Like in our prior lectures, we will study _linear_ settings, where our sequential decision maker chooses a strategy $vx^((t)) in cX$ in some $n$-dimensional strategy set $cX subset.eq RR^n$. In the full-information setting that we have already studied, the feedback that our decision maker receives, at every round $t$, is a utility function $u^((t)): vx |-> ip(vg^((t)), vx)$, from which she can compute her realized utility, $w^((t)) := ip(vg^((t)), vx^((t)))$, for the strategy she played as well as the counterfactual utility she would have received from any strategy she could have played. In the _bandit_ setting, the decision maker only receives as feedback her realized utility $w^((t))$ as opposed to her complete utility function $u^((t))$.

As a general principle, we construct algorithms for the _bandit_ setting from regret minimizers for the full-information setting. Indeed, the key idea is to construct an _estimator_ $tilde(vg)^((t))$ of the (unobserved) utility gradient $vg^((t))$, and feed that into a full-information regret minimizer. We'll construct the estimator from the observed utility $w^((t))$ and the chosen strategy $vx^((t))$.

The environment can still pick the utility function adversarially, and the adversary knows the learner's algorithm. The utility $u^((t))$ may depend on the history $vx^((1)), ..., vx^((t-1))$, but it must be chosen without knowledge of the current played strategy $vx^((t))$. In other words, the environment can pick the utility adaptively, but it must decide the utility _before_ the learner picks her strategy, not after. In particular, the adversary can predict the output $vy^((t))$ of the full-information regret minimizer from the history, but the strategy sampler may use private randomness to transform $vy^((t))$ into $vx^((t))$. Since the adversary does not observe the sampler's coin tosses, it cannot determine $vx^((t))$ exactly before choosing the utility function. This restriction still allows convergence to equilibria if bandit algorithms are used by players to iteratively update their strategies in games.

Typically, the construction of bandit algorithms follows the template shown in @fig-bandit.
#figure(
  caption: [General template for bandit learning algorithms. The strategy sampler receives the output $vy^((t))$ of the full-information regret minimizer and produces the played strategy $vx^((t))$. The dice and lock indicate that it may use private randomness: even if the adversary knows the learning algorithm and can predict $vy^((t))$, it does not observe the sampler's coin tosses and therefore cannot predict $vx^((t))$ exactly. In the widely studied setting $cX = Delta(A)$ for a finite action set $A$, the sampler draws $a^((t)) ~ vy^((t))$ and returns $vx^((t)) = ve_(a^((t)))$. More generally, the sampler can be defined for arbitrary strategy sets $cX$.],
)[
  #image(
    "figures/bandit/bandit.svg",
    width: 100%,
    alt: "Bandit algorithm template: observed utility enters a gradient estimator, then a full-information regret minimizer, whose output feeds a strategy sampler that uses private randomness, indicated by a die and a lock.",
  )
] <fig-bandit>

#paragraph-marker() *Randomization is necessary.*~~
Suppose $cX = [0,1]$ and the learner is deterministic, so that $x^((t))$ is a fixed function of the feedback history $w^((1)), ..., w^((t-1))$. The adversary knows the algorithm. It can therefore simulate the learner on the feedback sequence $w^((1)) = ... = w^((T)) = 0$, and compute in advance the strategies $x^((1)), ..., x^((T))$ that the learner would play. Let $sigma = +1$ if $sum_(t=1)^T (1 - x^((t))) >= T/2$ and $sigma = -1$ otherwise, and let the adversary play the utilities
$ u^((t))(x) = sigma (x - x^((t))). $
Each $u^((t))$ is fixed before round $t$ and does not depend on the learner's play at round $t$. Since $u^((t))(x^((t))) = 0$, the learner indeed observes $w^((t)) = 0$ at every round, so she plays exactly the strategies the adversary predicted, and her total utility is $0$. However, the fixed strategy $hat(x) = 1$ (if $sigma = +1$) or $hat(x) = 0$ (if $sigma = -1$) obtains total utility $sum_t (1 - x^((t)))$ or $sum_t x^((t))$ respectively, which is at least $T/2$ by the choice of $sigma$. Hence $"Reg"^((T)) >= T/2$, which is linear in $T$.

(The utilities above are affine in $x$; they are linear on $cX = Delta({0,1})$, identifying $x$ with the probability of action $1$. They take values in $[-1,1]$. The map $u |-> (1+u)\/2$ brings them to $[0,1]$ and halves the regret to $T/4$.)

The argument fails for randomized learners because the adversary cannot predict the random $x^((t))$, and the feedback $w^((t))$ is no longer a deterministic constant. Randomization is therefore necessary in the bandit setting. It also means that the trajectory $(vx^((t)), vg^((t)))_t$ is random, so we must specify which notion of regret we bound.

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

Notice that pseudoregret and expected regret guarantees are different, since $max EE <= EE max$, but the converse is not true in general. This means that bounding expected regret automatically bounds the pseudoregret but the opposite is not necessarily the case. In fact, bounds on the pseudoregret are _not_ strong enough to conclude convergence to the set of equilibria, in general. Similarly, getting a high-probability regret guarantee typically requires even stronger bounds on the estimator's error.
#paragraph-marker() *Pseudoregret versus expected regret.*~~
Since $max EE <= EE max$, we always have $"PseudoReg"^((T)) <= EE["Reg"^((T))]$. The two notions compare the learner against different benchmarks: pseudoregret competes with the best fixed strategy _in expectation_, while expected regret competes with the best fixed strategy _in hindsight on each realization_. They coincide when the benchmark does not depend on the learner's randomness. For instance, if the adversary is oblivious, so the sequence $vg^((1)), ..., vg^((T))$ is fixed in advance, then $max_(xhat) sum_t ip(vg^((t)), xhat)$ is deterministic and $max$ and $EE$ can be exchanged. Against an adaptive adversary, $vg^((t))$ depends on the learner's past random plays, so the best fixed strategy varies across realizations and the two can differ.

#paragraph-marker() *Consequences for equilibria.*~~
Suppose each of $n$ players runs a bandit algorithm in a repeated game, and player $i$'s utility gradient $vg_i^((t))$ is determined by the opponents' realized actions $a_(-i)^((t))$, so that $ip(vg_i^((t)), vx_i^((t))) = u_i (a^((t)))$. Two empirical distributions of play can be considered.
- The _expected empirical distribution_ $bar(mu)(a) = 1/T sum_t PP[a^((t)) = a]$, which averages over the randomness of the algorithms. If every player has pseudoregret at most $epsilon T$, then $bar(mu)$ is an $epsilon$-approximate coarse correlated equilibrium (CCE).
- The _realized empirical distribution_ $hat(mu) = 1/T sum_t delta_(a^((t)))$ of a single run. Its CCE gap for player $i$ equals $"Reg"_i^((T)) \/ T$ exactly, so showing that $hat(mu)$ is an approximate CCE needs a bound on the regret itself: in expectation (for the expected gap) or with high probability.
Pseudoregret bounds alone do not control $hat(mu)$.

#v(-1mm)
= Adversarial bandit learning in normal-form games

Let's start from the case of normal-form games, in which our decision maker faces the choice of picking an action out of a finite set $A$. The setting in this case is also known as _adversarial multi-armed bandit problem_. We have $cX = Delta(A) subset RR^A$, so the dimensionality is $n = |A|$.

#paragraph-marker() *Strategy sampler.*~~
In this setting, most algorithms use the natural strategy sampler: given a distribution $vy^((t)) in Delta(A)$, the decision maker samples an action $a^((t)) in A$ according to the probabilities in $vy^((t))$. The vector $vx^((t))$ is then set to the deterministic distribution $ve_(a^((t)))$. Clearly,
$EE_t [vx^((t))] = vy^((t)).$

#paragraph-marker() *Gradient estimator.*~~ For this setting, the standard gradient estimator is the _importance sampling_ estimator. Given the utility scalar $w^((t)) in [0, 1]$, the importance sampling estimator is defined as
$ tilde(vg)^((t)) := (w^((t)) / y^((t))_(a^((t)))) ve_(a^((t))) in RR^A. $

#theorem[Assume $y^((t))_a>0$ for every action. Let $w^((t)) = ip(vg^((t)), vx^((t)))$ where $vg^((t))$ is some unknown utility gradient. Then, the importance sampling estimator $tilde(vg)^((t))$ is unbiased, that is,
  $EE_t [tilde(vg)^((t))] = vg^((t)).$
]
#v(-2mm)
#proof[
  The result follows by direct calculation. The randomness is due to the sampling of the action $a^((t))$. Each action $a in A$ is sampled with probability $y^((t))_a$. Hence,
  $
    EE_t [tilde(vg)^((t))] = sum_(a in A) y^((t))_a (g^((t))_a / y^((t))_a) ve_a = sum_(a in A) y^((t))_a (
      ip(vg^((t)), ve_(a)) / y^((t))_a
    ) ve_a = sum_(a in A) g^((t))_a ve_a = vg^((t)).
  $
  #v(-6mm)
]

== The Exp3 algorithm

Exp3 (short for "exponential weights for exploration and exploitation") adapts #lecture-link("learning1", <sec-mwu>)[multiplicative weights] to bandit feedback and was introduced by #citet(<auer2002nonstochastic>). We use a variant that needs no explicit exploration mixture. Convert rewards $g^((t))_a in [0,1]$ into losses $ell^((t))_a=1-g^((t))_a$. This changes neither realized regret nor pseudoregret.

Start with positive weights $W_(1,a)=1$. At time $t$, sample action $a^((t))$ from $y^((t))_a=W_(t,a)/sum_b W_(t,b)$ and observe its loss. Set
$ hat(vell)^((t))=frac(1-w^((t)), y^((t))_(a^((t)))) ve_(a^((t))), quad W_(t+1,a)=W_(t,a) exp(-eta hat(ell)^((t))_a). $
Equivalently, the full-information utility learner receives $-hat(vell)^((t))$.

#theorem[Exp3][
  For $K=|A|>=2$, this algorithm satisfies
  $ "PseudoReg"^((T)) <= frac(log K, eta) + eta K T/2. $
  Taking $eta=sqrt(frac(2 log K, K T))$ gives $"PseudoReg"^((T)) <= sqrt(2K T log K)$ against any nonanticipating adversary.
]
#proofsketch[
  Because the estimates are nonnegative, $exp(-z)<=1-z+z^2/2$ applies for every $z=eta hat(ell)^((t))_a$, even if an estimate is large. The exponential-weights potential bound against each fixed action $a$ is
  $
    sum_t ip(vy^((t)), hat(vell)^((t))) - sum_t hat(ell)^((t))_a <= frac(log K, eta) + eta/2 sum_t sum_b y^((t))_b (hat(ell)^((t))_b)^2.
  $
  Conditional unbiasedness identifies the expected loss terms, while
  $ EE_(t)[sum_b y^((t))_b (hat(ell)^((t))_b)^2]=sum_b (ell^((t))_b)^2 <= K. $
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

Today, we know that bandit optimization is possible well past probability simplices. In fact, we can construct bandit algorithms for any convex and compact domain $cX subset.eq RR^n$.
In particular, we mention the general result by #citet(<abernethy2008competing>), who showed that a bandit algorithm can be constructed starting from a full-information regret minimizer built using the FTRL algorithm with a self-concordant distance-generating function.

= Problems

#exercise[Variance of the importance-sampling estimator][
  Let $A$ be finite, and suppose the gain vector $vg^((t)) in [0,1]^A$ is fixed before the learner samples $a^((t)) ~ vy^((t))$, where $y^((t))_a > 0$ for every $a in A$. The learner observes $w^((t)) = g^((t))_(a^((t)))$ and uses the importance-sampling estimator
  $ tilde(vg)^((t))_a = (w^((t)) / y^((t))_a) 1{a^((t)) = a}. $
  Compute the conditional variance of each coordinate $tilde(vg)^((t))_a$. Explain why these variances can be arbitrarily large while the conditional expectation of the weighted second moment $sum_(a in A) y^((t))_a (tilde(vg)^((t))_a)^2$ used in the Exp3 proof is bounded by $|A|$.
]

#solution[
  Condition on the history and on $vg^((t))$, leaving only the action $a^((t))$ random. For each $a in A$,
  $
    EE_(t)[tilde(vg)^((t))_a] = g^((t))_a, quad
    EE_(t)[(tilde(vg)^((t))_a)^2] = (g^((t))_a)^2 / y^((t))_a.
  $
  Hence
  $ "Var"_(t)(tilde(vg)^((t))_a) = (g^((t))_a)^2 (1 / y^((t))_a - 1). $
  If $g^((t))_a > 0$, this variance grows without bound as $y^((t))_a -> 0$. In the weighted second moment, however, the sampling probability cancels the inverse probability in expectation:
  $
    EE_(t)[sum_(a in A) y^((t))_a (tilde(vg)^((t))_a)^2]
    = sum_(a in A) (g^((t))_a)^2 <= |A|.
  $
  This bounds the conditional *expectation* of the weighted second moment; its value for a particular sampled action can still be large.
]

#exercise[Zero pseudoregret need not yield a realized CCE][
  Consider the two-player coordination game with actions ${0,1}$, where both players receive utility $1$ when their actions agree and $0$ otherwise. Player 1 flips a fair coin once and plays the resulting action in every round. Player 2 flips a fair coin independently in every round. Compute both players' pseudoregret after $T$ rounds. Does the realized empirical distribution of action profiles converge almost surely to a coarse correlated equilibrium (CCE)?
]

#solution[
  Write $B$ for Player 1's initial coin toss and $C_t$ for Player 2's round-$t$ toss. Thus $a_1^((t))=B$ and $a_2^((t))=C_t$. For either player $i$, every fixed action $b in {0,1}$ earns expected utility $1/2$ in each round: Player 1 faces a fair $C_t$, while Player 2's expectation averages over the single fair toss $B$. The played actions also agree with probability $1/2$ in each round. Since the maximum in pseudoregret is taken *after* these expectations,
  $
    "PseudoReg"_i^((T))
    = max_(b in {0,1}) EE[sum_(t=1)^T u_(i)(b, a_(-i)^((t))) - sum_(t=1)^T u_(i)(a_1^((t)), a_2^((t)))]
    = 0
  $
  for both $i=1,2$ and every $T$.

  Conditional on $B=b$, the strong law of large numbers gives a limiting realized empirical distribution with probability $1/2$ on $(b,0)$ and probability $1/2$ on $(b,1)$. Under this distribution, Player 2's expected utility is $1/2$, but the fixed deviation to action $b$ gives utility $1$. Its CCE inequality fails by $1/2$. Hence the realized empirical distribution converges almost surely, but its limit is *not* a CCE. Averaging over $B$ instead gives the uniform joint distribution, which is a CCE; this averaging conceals the incentive to deviate in each realized limit.
]

#lec_bibliography("meta/refs.bib")
