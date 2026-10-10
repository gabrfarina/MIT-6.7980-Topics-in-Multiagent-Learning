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

The utility function can still be picked adversarially by the environment, and the adversary knows the learner's algorithm. The utility $u^((t))$ may depend on the history $vx^((1)), ..., vx^((t-1))$, but it is chosen without knowledge of the current played strategy $vx^((t))$. In particular, the adversary can predict the output $vy^((t))$ of the full-information regret minimizer from the history, but the strategy sampler may use private randomness to transform $vy^((t))$ into $vx^((t))$. Since the adversary does not observe the sampler's coin tosses, she cannot determine $vx^((t))$ exactly before choosing the utility function. This restriction still allows convergence to equilibria if bandit algorithms are used by players to iteratively update their strategies in games.

Typically, the construction of bandit algorithms follows the template shown in @fig-bandit.
#figure(
  caption: [General template for bandit learning algorithms. The strategy sampler receives the output $vy^((t))$ of the full-information regret minimizer and produces the played strategy $vx^((t))$. The dice and lock indicate that it may use private randomness: even if the adversary knows the learning algorithm and can predict $vy^((t))$, she does not observe the sampler's coin tosses and therefore cannot predict $vx^((t))$ exactly. In the widely studied setting $cX = Delta(A)$ for a finite action set $A$, the sampler draws $a^((t)) ~ vy^((t))$ and returns $vx^((t)) = ve_(a^((t)))$. More generally, the sampler can be defined for arbitrary strategy sets $cX$.],
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
Each $u^((t))$ is fixed before round $t$ and does not depend on the learner's play at round $t$. Since $u^((t))(x^((t))) = 0$, the learner indeed observes $w^((t)) = 0$ at every round, so it plays exactly the strategies the adversary predicted, and its total utility is $0$. However, the fixed strategy $hat(x) = 1$ (if $sigma = +1$) or $hat(x) = 0$ (if $sigma = -1$) obtains total utility $sum_t (1 - x^((t)))$ or $sum_t x^((t))$ respectively, which is at least $T/2$ by the choice of $sigma$. Hence $"Reg"^((T)) >= T/2$, which is linear in $T$.

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

#paragraph-marker() *Pseudoregret versus expected regret.*~~
Since $max EE <= EE max$, we always have $"PseudoReg"^((T)) <= EE["Reg"^((T))]$. The two notions compare the learner against different benchmarks: pseudoregret competes with the best fixed strategy _in expectation_, while expected regret competes with the best fixed strategy _in hindsight on each realization_. They coincide when the benchmark does not depend on the learner's randomness. For instance, if the adversary is oblivious, so the sequence $vg^((1)), ..., vg^((T))$ is fixed in advance, then $max_(xhat) sum_t ip(vg^((t)), xhat)$ is deterministic and $max$ and $EE$ can be exchanged. Against an adaptive adversary, $vg^((t))$ depends on the learner's past random plays, so the best fixed strategy varies across realizations and the two can differ.

#paragraph-marker() *Consequences for equilibria.*~~
Suppose each of $n$ players runs a bandit algorithm in a repeated game, and player $i$'s utility gradient $vg_i^((t))$ is determined by the opponents' realized actions $a_(-i)^((t))$, so that $ip(vg_i^((t)), vx_i^((t))) = u_i (a^((t)))$. Two empirical distributions of play can be considered.
- The _expected empirical distribution_ $bar(mu)(a) = 1/T sum_t PP[a^((t)) = a]$, which averages over the randomness of the algorithms. If every player has pseudoregret at most $epsilon T$, then $bar(mu)$ is an $epsilon$-approximate coarse correlated equilibrium (CCE).
- The _realized empirical distribution_ $hat(mu) = 1/T sum_t delta_(a^((t)))$ of a single run. Its CCE gap for player $i$ equals $"Reg"_i^((T)) \/ T$ exactly, so showing that $hat(mu)$ is an approximate CCE needs a bound on the regret itself: in expectation (for the expected gap) or with high probability.
Pseudoregret bounds alone do not control $hat(mu)$.

#v(-1mm)
= Adversarial bandit learning in normal-form games

Let's start from the case of normal-form games, in which our decision maker faces the choice of picking an action out of a finite set $A$. The setting in this case is also known as _adversarial multi-armed bandit problem_. We have $cX = Delta(A)$.

#paragraph-marker() *Strategy sampler.*~~
In this settings, most algorithms use the natural strategy sampler: given a distribution $vy^((t)) in Delta(A)$, the decision maker samples an action $a^((t)) in A$ according to the probabilities in $vy^((t))$. The vector $vx^((t))$ is then set to the deterministic distribution $ve_(a^((t)))$. Clearly,
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

== Tsallis entropy

It can be shown that, information theoretically, no bandit learning algorithm for a finite set of actions $|A|$ can achieve better than $Omega(sqrt(T |A|))$ expected regret in general. The regret guaranteed by the Exp3 algorithm is therefore optimal only up to a logarithmic factor. It remained open for a long time whether this logarithmic factor could be removed. A positive answer was given by #citet(<audibert2010regret>), who proposed the idea of replacing #lecture-link("learning1", <sec-mwu>)[MWU] with #lecture-link("learning1", <ftrl-omd-general-case>)[FTRL] instantiated with the negative $(1\/2)$-Tsallis entropy regularizer
$
  psi(vx) = 2 - 2 sum_(a in A) sqrt(x_a).
$

#theorem[
  If FTRL with (1/2)-Tsallis entropy receives the estimated utilities $-hat(vell)^((t))$ defined above, with learning rate $eta = sqrt(1 \/ T)$, the resulting bandit algorithm guarantees pseudoregret
  $ "PseudoReg"^((T)) = O(sqrt(T|A|)), $
  which is the optimal bound for bandit learning on finite probability distributions.
]

A simplified analysis can also be found in #citep(<zimmert2021tsallis>).

== The Exp3.P algorithm

Exp3.P uses both uniform exploration and an upper-confidence correction to reward estimates #citep(<auer2002nonstochastic>). For $K=|A|>=2$, let $vy^((t))$ be normalized positive weights and sample from
$ vp^((t))=(1-gamma)vy^((t))+gamma vone/K. $
With the reward estimator $tilde(vg)$ defined earlier, computed using the sampling probabilities $p^((t))_(a^((t)))$ in place of $y^((t))_(a^((t)))$, update the weights by
$ W_(t+1,a)=W_(t,a) exp(eta (tilde(g)^((t))_a + frac(alpha, p^((t))_a sqrt(K T)))). $
The positive bonus accounts for uncertainty; uniform exploration bounds inverse sampling probabilities. This is a different estimator/update from the loss-form Exp3 above.

#theorem[Exp3.P #citep(<auer2002nonstochastic>)][
  Initialize all weights equally. For horizon $T>=1$ and $delta in (0,1)$, choose
  $ gamma=min{3/5,2sqrt(frac(3K log K, 5T))}, quad eta=gamma/(3K), quad alpha=2sqrt(log(K T/delta)). $
  Then, with probability at least $1-delta$,
  $ "Reg"^((T)) <= O(sqrt(K T log(K T/delta)) + log(K T/delta)). $
]

The confidence parameter enters the logarithm and the bonus. Adding exploration to an unbiased estimator, without this correction or another concentration-control mechanism, is not the Exp3.P algorithm.

= Adversarial bandit learning on general convex domains

Today, we know that bandit optimization is possible well past probability simplexes. In fact, we can construct bandit algorithms for any convex and compact domain $cX subset.eq RR^d$.
In particular, we mention the general general result by #citet(<abernethy2008competing>), who showed that the a bandit algorithm can be constructed starting from a full-information regret miminizer built using the FTRL algorithm with a self-concordant distance-generating function.

#lec_bibliography("meta/refs.bib")
