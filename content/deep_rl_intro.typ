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

The concrete problem, from the #lecture-link("learning_intro", <sec-learning-zero-sum>)[self-play section]: the strategy sets are simplices in a normal-form game and sequence-form polytopes in an extensive-form game. Because the payoff is linear in each strategy once the other is held fixed, the problem is concave in $vx$ and convex in $vy$. In the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup], two regret minimizers exchange strategies and receive the linear utility induced by the opponent. The saddle-point gap of their average strategies is
$ gamma(overline(vx), overline(vy)) = max_(xhat in cX) { xhat^top U overline(vy) } - min_(yhat in cY) { overline(vx)^top U yhat }. $
This gap is the sum of their regrets divided by $T$, so sublinear regret drives that gap to zero.

The #lecture-link("efg_intro", <sec-sequence-form>)[sequence form] is what carries this conclusion from normal-form games to extensive-form games. In that representation the utility is linear and each strategy set is a convex polytope, so the same self-play applies, as #lecture-link("learning_efg")[] spells out. Two algorithms then produce the sequence-form strategies. #lecture-link("learning1", <def-online-gradient-ascent>)[Online projected gradient ascent], the Euclidean case of online mirror descent, applies directly. Its drawback is the projection onto the sequence-form polytope. #lecture-link("learning_efg", <sec-cfr>)[Counterfactual regret minimization] avoids that projection. It builds one regret minimizer for the whole tree from a local regret minimizer at each decision point, trained on #lecture-link("learning_efg", <sec-cfr-values>)[counterfactual values].


