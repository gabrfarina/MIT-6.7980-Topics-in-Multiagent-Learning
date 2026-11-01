#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// Introduction only. 

= From exact solving to scalable learning


We begin with the concept of #lecture-link("nfgs_nash", <sec-normal-form>)[normal-form games] and utilizing a #lecture-link("nfgs_nash", <def-nash-equilibrium>)[Nash equilibria] to model expected reward achieved by a set of two players. This concept naturally ties in with #lecture-link("correlated", <sec-zero-sum>)[linear programming formulations] for normal-form games (#lecture-link("correlated", <def-ce>)[correlated equilibrium] and #lecture-link("correlated", <def-cce>)[coarse correlated equilibrium]). With #lecture-link("learning_intro", <sec-external-regret>)[regret minimization], we understand how average regret approaches 0 over $T$ iterations in a game, creating a #lecture-link("learning_intro", <sec-learning-zero-sum>)[convex-concave saddle point] where the average strategies converge toward the Nash equilibrium set. 


To this extent, the saddle point gap becomes important to analyze. With the self-play theorem, we inherently bound this gap by the sum of the players' cumulative regrets divided by T. In this way, regret minimization essentially drives equilibrium.

No-regret algorithms focus on balancing exploitation of good actions against stability. Below is a quick recap of a select few:

(1) Follow-the-Leader -- we choose the action with the highest cumulative historical utility in order to smooth strategy selection.
$ vx^((t+1)) in argmax_(vx in Delta(A)) ip(sum_(tau=1)^t vg^((tau)), vx). $

(2) Regret Matching -- we choose probabilities proportional to positive cumulative regret in order to assign higher probabilities to more likely actions.
$ x_a^((t+1)) = (\[r_a^((t))\]^+) / (sum_b \[r_b^((t))\]^+). $

(3) Multiplicative Weights Update -- we apply a softmax across regret. Larger eta values lead to a greater preference for high-regret actions, while a smaller eta designates a smoother update.
$ x_a^((t+1)) = exp(eta r_a^((t))) / (sum_b exp(eta r_b^((t)))). $

(4) Online Mirror Descent -- we update with the latest gradient while penalizing the movement from the previous strategy. Cases differ for negative entropy regularizers and squared Euclidean regularizers.
$ vx^((t+1)) = argmax_(vx in X) \[ ip(vg^((t)), vx) - (1 / eta) D_psi (vx parallel vx^((t))) \]. $
$ D_psi (vx parallel vy) = psi(vx) - psi(vy) - ip(nabla psi(vy), vx - vy). $
$ vx^((t+1)) = Pi_X (vx^((t)) + eta vg^((t))). $


With bandit feedback, we can turn limited observations into utility estimates, allowing us to optimize for sample efficiency. 
However, these strategies depend on simulating and gathering information from many game states, creating a need for sample efficiency. In this way, extensive form games become crucial.
