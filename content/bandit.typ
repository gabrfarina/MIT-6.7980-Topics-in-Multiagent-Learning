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
With the reward estimator $tilde(vg)$ defined earlier, update the weights by
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

= Problems <sec-bandit-problems>

#exercise[An adversary that sees the current action][
  Consider a learner with two actions, $A = {1, 2}$, and utilities $vg^((t)) in [0,1]^A$. Suppose that, unlike the adversary described in the setup at the beginning of this lecture, the adversary observes the action $a^((t))$ sampled by the learner at round $t$ before choosing $vg^((t))$. Construct such an adversary that forces
  $ "Reg"^((T)) >= T/2 $
  for every learner, with probability one.
]

#solution[
  At each round $t$, after observing $a^((t))$, the adversary sets $vg^((t)) := ve_(b^((t)))$, where $b^((t))$ is the action other than $a^((t))$. The learner plays $vx^((t)) = ve_(a^((t)))$, so it collects $ip(vg^((t)), vx^((t))) = 0$ at every round.

  Let $N_a := |{t : b^((t)) = a}|$ count the rounds in which action $a$ receives utility $1$. Each round rewards exactly one action, so $N_1 + N_2 = T$. The maximum of a linear function over $Delta(A)$ is attained at a vertex, hence
  $
    "Reg"^((T)) = max_(xhat in Delta(A)) sum_(t=1)^T ip(vg^((t)), xhat) - sum_(t=1)^T ip(vg^((t)), vx^((t))) = max{N_1, N_2} - 0 >= T/2.
  $
  The argument applies to every realization of the learner's randomness, so the bound holds with probability one. It never uses the learner's feedback either, so it also holds under full-information feedback.

  This does not contradict the guarantees for Exp3 and Exp3.P. In the probability model of this lecture's setup, the adversary chooses $vg^((t))$ from the history $(vx^((tau)), w^((tau)))_(tau < t)$ only. The learner's fresh randomness at round $t$ is therefore hidden from it, and randomization keeps the learner from being exploited as above. Against a deterministic learner, the adversary can compute $a^((t))$ from the history alone, so the same construction applies without seeing the current action. Sublinear regret therefore requires randomization.
]

#exercise[Exp3.P dynamics and coarse correlated equilibria][
  Consider an $n$-player normal-form game with finite action sets $A_1, ..., A_n$, where $K_i := |A_i| >= 2$ and $K := max_i K_i$, and utilities $u_i : A_1 times dots.h.c times A_n -> [0,1]$. Players repeatedly play the game for $T$ rounds. Each player $i$ runs Exp3.P over $A_i$ and observes only its realized payoff $u_i (a^((t)))$, where $a^((t)) = (a_1^((t)), ..., a_n^((t)))$ is the realized action profile. Recall that $vmu in Delta(A_1 times dots.h.c times A_n)$ is an _$epsilon$-approximate_ #lecture-link("correlated", <def-cce>)[coarse correlated equilibrium] if
  $ EE_(a ~ vmu) [u_i (a'_i, a_(-i)) - u_i (a)] <= epsilon quad forall i in [n], a'_i in A_i. $
  Show that, with probability at least $1 - delta$, the empirical distribution of play
  $ hat(vmu)^((T)) := 1/T sum_(t=1)^T ve_(a^((t))) $
  is an $epsilon$-approximate coarse correlated equilibrium, and determine how $epsilon$ depends on $n$, $K$, $T$, and $delta$.
]

#solution[
  *Each player faces a bandit problem.*  Fix player $i$ and define
  $ vg_i^((t)) := (u_i (a_i, a_(-i)^((t))))_(a_i in A_i) in [0,1]^(A_i). $
  Player $i$ plays $vx_i^((t)) = ve_(a_i^((t)))$ and observes $w_i^((t)) = u_i (a^((t))) = ip(vg_i^((t)), vx_i^((t)))$. This is exactly the bandit feedback model of this lecture, with the other players acting as the adversary.

  The other players sample $a_(-i)^((t))$ from strategies computed from the history before round $t$, independently of player $i$'s draw at round $t$. Hence $vg_i^((t))$ cannot depend on $a_i^((t))$, unlike in the previous exercise. The other players do react to past play, so the adversary is adaptive, which the probability model of this lecture's setup allows.

  *A regret bound for every player.*  Let player $i$ run Exp3.P with the parameters of the Exp3.P theorem above and confidence parameter $delta/n$. Write $"Reg"_i^((T))$ for player $i$'s realized regret with respect to $vg_i^((1)), ..., vg_i^((T))$. By the theorem, there is an absolute constant $C$ such that
  $
    PP["Reg"_i^((T)) > C(sqrt(K_i T log(n K_i T \/ delta)) + log(n K_i T \/ delta))] <= delta/n.
  $
  A union bound over the $n$ players shows that, with probability at least $1 - delta$, simultaneously for all $i in [n]$,
  $
    "Reg"_i^((T)) <= C(sqrt(K T log(n K T \/ delta)) + log(n K T \/ delta)).
  $

  *From regret to equilibrium.*  External regret is $Phi$-regret for the set of constant transformations (see #lecture-link("learning_intro", <sec-external-regret>)[external regret]). Apply the #lecture-link("learning_intro", <thmce-formal>)[regret-to-equilibrium theorem] to the played strategies $vx_i^((t)) = ve_(a_i^((t)))$. Their products are $ve_(a_1^((t))) ⊗ dots.h.c ⊗ ve_(a_n^((t))) = ve_(a^((t)))$, so the average correlated distribution of play is exactly $hat(vmu)^((T))$. For each player $i$ and deviation $a'_i in A_i$, the theorem gives
  $
    EE_(a ~ hat(vmu)^((T))) [u_i (a'_i, a_(-i)) - u_i (a)] = 1/T sum_(t=1)^T (g_(i, a'_i)^((t)) - ip(vg_i^((t)), vx_i^((t)))) <= ("Reg"_i^((T))) / T.
  $
  Hence, with probability at least $1 - delta$, $hat(vmu)^((T))$ is an $epsilon$-approximate coarse correlated equilibrium with
  $
    epsilon = max_(i in [n]) ("Reg"_i^((T))) / T <= C(sqrt((K log(n K T \/ delta)) / T) + (log(n K T \/ delta)) / T).
  $

  The number of players enters only through $log n$, from the union bound; each player runs its own algorithm on its own payoffs and never observes the others' actions. The bound grows as $sqrt(K)$ in the size of the largest action set, up to logarithmic factors, compared with $sqrt(log K)$ for MWU under full-information feedback; the extra factor is the price of bandit feedback. Finally, $epsilon$ decays as $tilde(O)(1 \/ sqrt(T))$, so for $epsilon <= 1$ it suffices to take $T = tilde(O)(K log(n\/delta) \/ epsilon^2)$ rounds.
]

#lec_bibliography("meta/refs.bib")
