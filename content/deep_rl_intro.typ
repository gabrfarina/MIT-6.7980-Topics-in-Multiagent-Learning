#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// Introduction only. 

= Overview (Deepify-ing Game Theory)


We begin with the concept of #lecture-link("nfgs_nash", <sec-normal-form>)[normal-form games] and utilizing a #lecture-link("nfgs_nash", <def-nash-equilibrium>)[Nash equilibria] to model expected reward achieved by a set of two players. This concept naturally ties in with #lecture-link("correlated", <sec-zero-sum>)[linear programming formulations] for normal-form games (#lecture-link("correlated", <def-ce>)[correlated equilibrium] and #lecture-link("correlated", <def-cce>)[coarse correlated equilibrium]). With #lecture-link("learning_intro", <sec-external-regret>)[regret minimization], we understand how average regret approaches 0 over $T$ iterations in a game, creating a #lecture-link("learning_intro", <sec-learning-zero-sum>)[convex-concave saddle point] where the average strategies converge toward the Nash equilibrium set. 


To this extent, the #lecture-link("learning_intro", <thm-regret-gap>)[saddle point gap] becomes important to analyze. With the #lecture-link("learning_intro", <thm-regret-gap>)[self-play theorem], we inherently bound this gap by the sum of the players' cumulative regrets divided by T. In this way, regret minimization essentially drives equilibrium.

#lecture-link("learning1")[No-regret algorithms] focus on balancing exploitation of good actions against stability. Below is a quick recap of a select few:

(1) Follow-the-Leader -- we choose the action with the highest cumulative historical utility in order to smooth strategy selection.
$ vx^((t+1)) in argmax_(vx in Delta(A)) ip(sum_(tau=1)^t vg^((tau)), vx). $

(2) Regret Matching -- we choose probabilities proportional to positive cumulative regret in order to assign higher probabilities to more likely actions.
$ x_a^((t+1)) = (\[r_a^((t))\]^+) / (sum_b \[r_b^((t))\]^+). $

(3) Multiplicative Weights Update -- we apply a softmax across regret. Larger eta values lead to a greater preference for high-regret actions, while a smaller eta designates a smoother update.
$ x_a^((t+1)) = exp(eta r_a^((t))) / (sum_b exp(eta r_b^((t)))). $

(4) #lecture-link("learning1", <sec-omd>)[Online Mirror Descent] -- we update with the latest gradient while penalizing the movement from the previous strategy. Cases differ for #lecture-link("learning1", <sec-omd-mwu>)[negative entropy] regularizers and #lecture-link("learning1", <sec-ogd>)[squared Euclidean] regularizers.
$ vx^((t+1)) = argmax_(vx in X) \[ ip(vg^((t)), vx) - (1 / eta) D_psi (vx parallel vx^((t))) \]. $
$ D_psi (vx parallel vy) = psi(vx) - psi(vy) - ip(nabla psi(vy), vx - vy). $
$ vx^((t+1)) = Pi_X (vx^((t)) + eta vg^((t))). $

However, these strategies depend on simulating and gathering information from many game states, creating a need for sample efficiency. With #lecture-link("bandit")[bandit feedback], we can turn limited observations into utility estimates, allowing us to optimize for sample efficiency. 

(1) Importance Sampling Estimator -- we feed utilities into information learning algorithms
$ hat(vg)^((t)) = (u^((t)) / p^((t))_(a_t)) e_(a_t). $
$ EE_t [hat(vg)^((t))] = vg^((t)). $

(2) Exponential Weights for Exploration and Exploitation -- this formula allows us to have a pseudoregret guarantee
$ hat(ell)^((t)) = ((1 - u^((t))) / p^((t))_(a_t)) e_(a_t). $
$ W_(t+1, a) = W_(t, a) e^(-eta hat(ell)^((t))_a). $
$ "PseudoReg"(T) <= (log K) / eta + (eta K T) / 2. $
$ "PseudoReg"(T) = O(sqrt(K T log K)). $

(3) Tsallis entropy and optimal bandit regret -- we improve the pseudoregret bound
$ psi(x) = 2 - 2 sum_a sqrt(x_a). $
$ O(sqrt(K T)). $


(4) Exp3.P and high-probability guarantees -- we prevent sampling probabilities from being too small and control estimation uncertainty
$ vp^((t)) = (1 - gamma) vy^((t)) + (gamma / K) vone. $
$ O(sqrt(K T log(K T / delta)) + log(K T / delta)). $



However, these strategies depend on simulating and gathering information from many game states, creating a need for sample efficiency. In this way, #lecture-link("efg_intro", <sec-game-trees>)[extensive form games] become crucial, as they allow us to model sequential interactions with hidden information. This topic naturally leads us into the next section of the introduction, where we discuss reinforcement learning.

= Overview (Game Theory-ifying RL)


We can model these games as trees (corresponding decision nodes, observation nodes, and transition functions). While Kuhn's theorem allows us to state mixed normal-form and behavioral strategies as realization-equivalent, sequence-form strategies have convex representations that are amenable to linear optimization.

(1) Sequence-form polytope -- we conclude that flow out is equivalent to flow in 
$ Q = { vx >= 0 : x_∅ = 1, sum_(a in A_j) x_(j a) = x_(p_j) quad forall j in cal(J) }. $

Additionally, with CFR, we can convert global regret-minimization to manageable local learning problems by initializing a regret minimizer for each decision point and combining local distributions into a sequence-form strategy with a top-down tree traversal. As average regret decreases, the average sequence-form strategies approach the set of Nash equilibria. 

(2) Reduction of saddle-point gap
$ gamma(overline(vx), overline(vy)) <= ("Reg"_1 (T) + "Reg"_2 (T)) / T. $


The Stratego and Ataraxos systems can be used to demonstrate modern deep multiagent RL systems. With these techniques, we can scale strategic learning to games that are too large for tabular methods (offline Q-learning), despite convergence being a key concern.
