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

The concrete problem, from the #lecture-link("learning_intro", <sec-learning-zero-sum>)[self-play section], is the bilinear program
$ max_(vx in cX) min_(vy in cY) vx^top U vy, $
where $cX$ and $cY$ are convex and compact. They are simplices in a normal-form game and sequence-form polytopes in an extensive-form game. Because the payoff is linear in each strategy once the other is held fixed, the problem is concave in $vx$ and convex in $vy$. In the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], two regret minimizers exchange strategies and receive the linear utility induced by the opponent. The saddle-point gap of their average strategies is the sum of their regrets divided by $T$, so sublinear regret drives that gap to zero.

The #lecture-link("efg_intro", <sec-sequence-form>)[sequence form] is what carries this conclusion from normal-form games to extensive-form games. In that representation the utility is linear and each strategy set is a convex polytope, so the same self-play applies, as #lecture-link("learning_efg")[] spells out. Two algorithms then produce the sequence-form strategies. #lecture-link("learning1", <def-online-gradient-ascent>)[Online projected gradient ascent], the Euclidean case of online mirror descent, applies directly. Its drawback is the projection onto the sequence-form polytope. #lecture-link("learning_efg", <sec-cfr>)[Counterfactual regret minimization] avoids that projection. It builds one regret minimizer for the whole tree from a local regret minimizer at each decision point, trained on #lecture-link("learning_efg", <sec-cfr-values>)[counterfactual values].

The cost that remains is the number of those decision points. The reduced normal form of an extensive-form game is exponential in the tree, but that blowup alone is not the end of exact methods: #lecture-link("learning_efg")[] notes that multiplicative weights can still be run on the reduced normal form, and #lecture-link("kernelized", <sec-kernelization>)[] gives the construction, working in the dimension of the sequence form rather than the number of pure plans. CFR, by contrast, keeps a separate regret minimizer at every #lecture-link("efg_intro", <sec-game-trees>)[information set]. A large game has more information sets than that table can hold. Heads-up limit hold'em is a landmark for what a tabular method can finish. Go and Stratego lie beyond it.

This lecture keeps self-play as the goal and changes what we represent exactly. Two directions organize the methods that follow.

== "Deepifying" game-theoretic algorithms

The first direction keeps a classical algorithm and approximates the step that walks the whole tree. #lecture-link("learning1")[Fictitious play] still wants a best response. CFR still wants a counterfactual regret at each decision point. A network takes the place of that exact subroutine. Neural fictitious play, ESCHER, and Deep CFR are three instances. The saddle-point guarantee above used an exact oracle, so it has to be revisited once the oracle is learned. The next section develops both approximations, together with what they retain and what they give up.

== "Game-theory-ifying" reinforcement learning

The second direction starts from a representation that already scales, and modifies it until self-play has a game-theoretic meaning again. A #lecture-link("efg_intro", <sec-behavioral-form>)[behavioral strategy] places an independent distribution at each decision point. That section already records the cost of this choice: the probability of a terminal history is a product along the path, so expected utility is no longer linear in the strategy, and the bilinear saddle point above is no longer the objective being optimized. A network can emit those local distributions as logits from the current observation, with no sequence-form vector in memory. Self-play is then gradient ascent on the logits, and convergence has to be established again.

Three choices structure that development. The first is the behavioral parametrization itself, including what can still be proved about gradient ascent. The second is the estimator of the gradient: uniform exploration, REINFORCE, and REINFORCE with a learned critic. The third is regularization, which pulls the self-play dynamics back toward convergence. Decision-time planning, and the Ataraxos case study on Stratego, then ask how far the resulting player goes.

Note: AI was used to write an initial draft of this introduction. Cursor produced the draft from the course index and from #lecture-link("learning_intro", <sec-learning-zero-sum>), #lecture-link("learning1", <def-online-gradient-ascent>), #lecture-link("efg_intro", <sec-sequence-form>), #lecture-link("learning_efg", <sec-cfr>), and #lecture-link("kernelized", <sec-kernelization>), together with Lecture 9 slides 2–4. I revised the wording and added additional details from Lecture 2.