#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// Introduction only. The constructions named below are developed in the
// later sections of this lecture.

= From exact solving to scalable learning

The algorithms of the previous lectures solve a game by treating it as a convex-concave problem. In a two-player zero-sum game, a Nash equilibrium is a saddle point of the bilinear problem
$ max_(vx in cX) min_(vy in cY) vx^top U vy, $
introduced with the #lecture-link("learning_intro",)[canonical self-play setup]. The strategy sets $cX$ and $cY$ are convex and compact. In a normal-form game each is a simplex. In an extensive-form game each is the polytope of #lecture-link("efg_intro",)[sequence-form strategies]. The payoff is linear in either strategy once the other player is held fixed, so the problem is concave in $vx$ and convex in $vy$.

Self-play puts a regret minimizer on each side of this problem. The two players exchange strategies, each receives the linear utility induced by the opponent's current strategy, and the average strategies converge to a Nash equilibrium whenever both regrets grow sublinearly. #lecture-link("learning1",)[Online projected gradient ascent] is one such minimizer. #lecture-link("learning_efg",)[Counterfactual regret minimization] is another: it obtains the same guarantee from a local regret minimizer at every decision point, trained on counterfactual utilities.

Both methods store an object whose dimension is the number of sequences. That is the obstacle. An extensive-form game can have more information sets than fit in memory, even after symmetries are removed. Heads-up limit hold'em marks the scale at which a tabular method can still finish the job. Go and Stratego lie beyond it. The sequence-form representation is still the right description of a strategy. It is no longer a vector we can write down and run gradient ascent on.

This lecture keeps the same goal, a strategy that does well in self-play, and changes what we insist on representing exactly. Two directions organize the methods that follow.

== "Deepifying" game-theoretic algorithms

The first direction keeps a classical algorithm and approximates the step that does not scale. Fictitious play, double oracle, and CFR stay intact as procedures. A neural network takes the place of the exact subroutine they call: a best response, or the counterfactual regrets at each decision point. Neural fictitious play, ESCHER, and Deep CFR are three instances. The game-theoretic skeleton remains visible. An exact regret bound, however, assumed an exact oracle, so it has to be revisited once that oracle is learned. The next section develops both approximations, together with what they gain and what they give up.

== "Game-theory-ifying" reinforcement learning

The second direction starts from a representation that already scales, and modifies it until self-play has a game-theoretic meaning again. A behavioral strategy assigns a distribution to each information set. A network can emit that distribution as logits from the current observation, with no sequence-form vector in memory. Self-play is then gradient ascent on those logits. The objective is no longer the convex-concave problem above, so convergence has to be re-established.

Three choices structure that development. The first is the behavioral parametrization itself, including what can still be proved about gradient ascent. The second is the estimator of the gradient: uniform exploration, REINFORCE, and REINFORCE with a learned critic. The third is regularization, which pulls the self-play dynamics back toward convergence. Decision-time planning, and the Ataraxos case study on Stratego, then ask how far the resulting player goes.

Note: AI was used to draft this introduction. Cursor produced the draft from Lectures 4, 5, 7, and 8 and from Lecture 9 slides 2–4.