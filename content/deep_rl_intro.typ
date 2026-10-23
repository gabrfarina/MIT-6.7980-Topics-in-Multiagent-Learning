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

No-regret algorithms (such as Follow-The-Leader, Regret Matching, Multiplicative Weights Update, and Online Mirror Descent) focus on balancing exploitation of good actions against stability. Below is a quick recap of each:

(1) Follow-the-Leader -- we choose the action with the highest cumulative historical utility in order to smooth strategy selection.
$ vx^((t+1)) in argmax_(a in A) (sum_(tau=1)^t vg^((tau)))_a. $

(2) Regret Matching -- we choose probabilities proportional to positive cumulative regret in order to assign higher probabilities to more likely actions.
$ vx^((t+1)) = (\[vr^((t))\]^+) / (norm(\[vr^((t))\]^+)_1). $

(3) Multiplicative Weights Update -- we apply a softmax across regret. Larger eta values lead to a greater preference for high-regret actions, while a smaller eta designates a smoother update.
$ x_a^((t+1)) = exp(eta r_a^((t))) / (sum_(j in A) exp(eta r_j^((t)))). $

(4) Online Mirror Descent -- we update with the latest gradient while penalizing the movement from the previous strategy. Cases differ for negative entropy regularizers and squared Euclidean regularizers.
$ vx^((t)) = argmax_(xhat in Delta(A)) { ip(vg^((t-1)), xhat) - 1 / eta div(xhat, vx^((t-1)), dgf: psi) }. $
$ psi(vx) = sum_(a in A) x_a log x_a. $
$ vx^((t)) = Pi_(cX)(vx^((t-1)) + eta vg^((t-1))). $