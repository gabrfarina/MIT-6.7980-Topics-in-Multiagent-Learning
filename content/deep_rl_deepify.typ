#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Deep multiagent RL: deepifying game-theoretic algorithms",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// [L09] One section of the L09 notes ("Deepifying" game-theoretic algorithms).
// It is written to be merged with the other L09 sections into a single note.

#note-status[Draft section of the L09 notes. It will be merged with the other sections of this lecture.]

= “Deepifying” game-theoretic algorithms <sec-deepify>

The algorithms we have seen so far for extensive-form games are _tabular_: they keep one or more numbers for every decision point and action of every player. #lecture-link("learning_efg", <sec-cfr>)[CFR], for instance, stores a cumulative regret and a cumulative strategy for every sequence $(j, a)$. This is what made heads-up limit hold'em solvable, and it is also what stops these methods from going much further. A game like Stratego has far too many information sets to give each of them its own entry in a table.

The first, and historically older, way around this obstacle is conservative. We keep a game-theoretic algorithm whose correctness we already understand, find the one step in it that does not scale, and replace _only that step_ with a learned function approximator, typically a neural network. The outer loop stays the same, and so, at least in spirit, do its guarantees.

Two primitives turn out to be the bottleneck in the algorithms we know.

- *Best responses.* Fictitious play and double oracle repeatedly ask for a best response to some fixed mixture of opponent strategies. Against a fixed opponent this is a single-agent problem, so we can ask deep reinforcement learning to approximate it (@sec-deepify-br).
- *Counterfactual regrets.* CFR asks each decision point to remember its cumulative regrets. We can instead train a network to predict them from a description of the decision point (@sec-deepify-cfr).

The following table summarizes the three algorithms we discuss in this section.

#figure(
  kind: table,
  supplement: [Table],
  caption: [Deepified game-theoretic algorithms. Each keeps a tabular outer loop and learns the step that does not scale.],
)[
  #set par(justify: false)
  #table(
    stroke: none,
    columns: 4,
    align: left + top,
    inset: .6em,
    table.header([*Tabular algorithm*], [*Expensive step*], [*What is learned*], [*Deep variant*]),
    table.hline(stroke: .4pt),
    [Fictitious play], [best response to the average opponent], [best-response policy (deep RL) and average policy (supervised)], [NFSP #citep(<Heinrich16:Deep>)],
    [Double oracle], [best response to the meta-game equilibrium], [one new best-response policy per iteration (deep RL)], [PSRO #citep(<Lanctot17:Unified>)],
    [CFR], [storing regrets at every decision point], [cumulative regrets and average strategy (regression)], [Deep CFR #citep(<Brown19:Deep>)],
  )
] <tab-deepify>

== Learning approximate best responses <sec-deepify-br>

Fix a two-player game and a strategy $vy$ of Player~2. A _best response_ of Player~1 to $vy$ is any strategy in $arg max_(vx) u_1(vx, vy)$. Once $vy$ is fixed, Player~2 is no longer a strategic agent: their actions are random events drawn from a known distribution, exactly like chance. From Player~1's point of view, the game becomes a #lecture-link("efg_intro", <sec-tfdp>)[tree-form decision process] with a stochastic environment, which is a single-agent (partially observable) reinforcement learning problem. We can therefore approximate a best response with any off-the-shelf deep RL algorithm, such as DQN or PPO, trained by playing against $vy$.

This is attractive because single-agent deep RL is a mature toolbox. Two classical algorithms are built entirely on a best-response oracle.

#wrapped-figure(
  [
    #pseudocode-list(numbered-title: [Fictitious play])[
      + $overline(pi)_i <-$ uniform policy, for each player $i$
      + *while* time is left:
        + *for each* player $i$:
          + $b_i <- $ `BestResponse`$(overline(pi)_(-i))$
          + $overline(pi)_i <- $ `UpdateAverage`$(overline(pi)_i, b_i)$
      + *return* $overline(pi)$
    ] <algo-fp-deepify>
  ],
  [
    #pseudocode-list(numbered-title: [Double oracle])[
      + $S_i <- {"uniform policy"}$, for each player $i$
      + *while* time is left:
        + $sigma <- $ `Nash`$(S_1 times S_2)$
        + *for each* player $i$:
          + $b_i <- $ `BestResponse`$(sigma_(-i))$
          + $S_i <- S_i union {b_i}$
      + *return* $sigma$
    ] <algo-do-deepify>
  ],
  side: right,
  text-width: 50%,
)

*Fictitious play.* We met fictitious play in #lecture-link("learning1", none)[] as follow-the-leader in the #lecture-link("learning_intro", <def-canonical-learning>)[canonical learning setup]: at every iteration, each player best responds to the average of the opponent's past strategies #citep(<brown1951iterative>). In two-player zero-sum games the average strategies converge to a Nash equilibrium #citep(<Robinson1951>). Both steps inside the loop are hard at scale.

- `BestResponse` is a full deep RL problem against the fixed policy $overline(pi)_(-i)$.
- `UpdateAverage` requires care: the average of behavioral strategies is _not_ obtained by averaging the action probabilities at each decision point separately. A decision point that the $t$-th policy rarely reaches should contribute little to the average there. The correct average is taken in the #lecture-link("efg_intro", <sec-sequence-form>)[sequence form]: if $vx^((t))$ is the sequence-form strategy of the $t$-th iterate, the average policy at decision point $j$ is
  $
    overline(pi)^((T))(a | j) = (sum_(t=1)^T vx^((t))[p_j] dot pi^((t))(a | j)) / (sum_(t=1)^T vx^((t))[p_j]),
  $
  so each iterate is weighted by its own probability of reaching $j$ #citep(<Heinrich15:Fictitious>).

_Neural fictitious self-play_ (NFSP) #citep(<Heinrich16:Deep>) approximates both steps with networks. A best-response network is trained with off-policy deep RL (DQN) on the agent's experience. An average-policy network is trained by supervised classification to imitate the actions that the agent took _when following its best-response network_. These state-action pairs are kept in a reservoir buffer, which retains a uniform sample of everything seen so far. Supervised learning on this buffer handles the weighting above automatically. A decision point appears in the buffer in proportion to how often the past best responses reached it, which is the reach weight in the formula above. At each step the agent acts according to the best-response network with a small probability $eta$ (the _anticipatory parameter_) and according to the average network otherwise. In this way, the experience used to train each best response comes from opponents playing (approximately) their average policies, as fictitious play prescribes.

*Double oracle.* Double oracle #citep(<McMahan03:Planning>) keeps, for each player, a _population_ $S_i$ of strategies found so far. At every iteration it solves the _restricted game_ (also called _meta-game_), the normal-form game in which each player may only mix over the strategies in their population. It then adds to each population a best response to the opponent's restricted equilibrium strategy $sigma_(-i)$. If neither best response improves on the value of the restricted game, then $sigma$ is a Nash equilibrium of the full game. Since a finite game has finitely many pure strategies, the algorithm terminates.

_Policy-space response oracles_ (PSRO) #citep(<Lanctot17:Unified>) is the deep version. Each population member is a neural-network policy, and `BestResponse` is a deep RL run against the mixture $sigma_(-i)$. The restricted game is not given to us, so its payoff matrix is estimated by simulation: the entry for a pair of policies $(pi_1^k, pi_2^l)$ is the average return of many rollouts in which they play each other. PSRO also allows replacing `Nash` by other _meta-solvers_. For example, the uniform distribution over the population recovers a fictitious-play-like method.

Both approximations break the exact termination test. A best response found by RL is only approximately a best response, so “the new policy does not improve” no longer certifies an equilibrium. What we keep is the outer loop itself, unchanged; its guarantee degrades gracefully with oracle accuracy, so the more accurate the oracle, the closer we are to the tabular algorithm.

== Learning counterfactual regrets <sec-deepify-cfr>

Recall that CFR places a local regret minimizer at every decision point $j$ and feeds it the #lecture-link("learning_efg", <sec-cfr-values>)[counterfactual values] $v^("cf")_(i)(j, a)$ of the current strategy profile. With #lecture-link("learning1", <sec-rm>)[regret matching] as the local learner, the update at iteration $t$ is
$
  r^((t))(j, a) & := v^("cf")_(i)(j, a) - sum_(b in A_j) pi^((t))(b | j) dot v^("cf")_(i)(j, b), & #h(2em) R^((t))(j, a) & := sum_(tau=1)^t r^((tau))(j, a),\
  pi^((t+1))(a | j) & = ([R^((t))(j, a)]^+) / (sum_(b in A_j) [R^((t))(j, b)]^+),
$
where $r^((t))(j, a)$ is the instantaneous regret of action $a$ and $R^((t))(j, a)$ is its cumulative regret. As in tabular regret matching, any action can be played when all cumulative regrets are nonpositive.

Two things in this update do not scale.

+ *Computing counterfactual values* exactly requires a traversal of the whole game tree at every iteration.
+ *Storing* $R^((t))(j, a)$, together with the cumulative average strategy, takes one table entry per sequence. Solving heads-up limit hold'em with CFR#super[+] already required heavily compressed tables spread across a large cluster #citep(<Tammelin15:Solving>).

The first issue predates deep learning. _Monte Carlo CFR_ (MCCFR) #citep(<Lanctot09:Monte>) replaces exact counterfactual values with unbiased estimates computed from sampled trajectories. In the _external sampling_ variant, chance and opponent actions are sampled from their current strategies, while all actions of the updating player are explored. Iterations then touch only a small part of the tree, at the price of noise. The second issue is where neural networks come in. Instead of a table indexed by $j$, we learn a function that maps a description of the decision point (for example, the cards a player has seen and the public betting history) to a vector of regrets. Similar decision points then share statistical strength, and memory no longer grows with the number of decision points. This idea first appeared with regression trees in _regression CFR_ #citep(<Waugh15:Solving>).

*Deep CFR* #citep(<Brown19:Deep>) combines both ideas. At every iteration $t$ and for each player $i$, it does the following.

+ Run a batch of external-sampling traversals with the current strategy. At each visited decision point $j$ of player $i$, record the sampled instantaneous regrets $tilde(r)^((t))(j, a)$ in an _advantage memory_, together with $j$ and $t$.
+ Train an _advantage network_ $V_theta (j, a)$ from scratch on the whole advantage memory by minimizing the weighted squared error
  $
    sum_((j, t, tilde(r)) in "memory") t dot sum_(a in A_j) (V_theta (j, a) - tilde(r)^((t))(j, a))^2.
  $
  A squared-loss regressor predicts a weighted average of its targets. Weighting the sample from iteration $t$ by $t$ makes this average match the weighting used by _linear CFR_ #citep(<Brown19:Discounted>), a variant that regret-matches on the linearly weighted cumulative regret
  $
    R_("lin")^((T))(j, a) := sum_(t=1)^T t dot r^((t))(j, a)
  $
  instead of the plain $R^((T))(j, a)$ defined above, and converges faster as a result. The prediction is therefore approximately _proportional_ to $R_("lin")^((T))(j, a)$ — not to the plain cumulative regret $R^((T))(j, a)$ — up to a positive factor that is shared by all actions at $j$.
+ Play regret matching on the predictions. Because regret matching normalizes, a positive common factor does not change the strategy:
  $
    pi^((t+1))(a | j) = ([V_theta (j, a)]^+) / (sum_(b in A_j) [V_theta (j, b)]^+).
  $
  If every prediction is nonpositive, Deep CFR plays the action with the largest prediction.

As always with CFR, the guarantee concerns the _average_ strategy, not the last iterate. Deep CFR therefore stores the strategies played at sampled decision points in a separate memory and, at the end, trains a _strategy network_ to predict the (linearly weighted) average policy. This network is the one that is deployed.

Even external sampling has a cost: because the traverser explores every one of its own actions at each visited decision point, a single traversal's cost still grows with the traverser's branching factor. The cheaper alternative, _outcome sampling_, follows a single trajectory to a terminal node and corrects for it by dividing by the probability of that trajectory; these importance weights can be very large, and this is the main source of variance in sampling-based CFR #citep(<Steinberger20:DREAM>). ESCHER #citep(<McAleer23:ESCHER>) targets this tradeoff directly: it samples one action per decision point from a fixed baseline policy and learns a _history value function_ to estimate regrets from it, avoiding both the branching-factor cost of external sampling and the importance-weight variance of outcome sampling.

== Advantages and drawbacks <sec-deepify-tradeoffs>

The deepified algorithms inherit strengths from their tabular counterparts.

- *Error-aware guarantees.* Each method starts from a tabular algorithm with a convergence proof. If the networks were perfect, we would recover that algorithm. With imperfect networks, the error can often be accounted for. For instance, Deep CFR's regret bound degrades with the prediction error of the advantage network #citep(<Brown19:Deep>).
- *Independently testable components.* Every network has a well-defined target: a best response to a fixed opponent, an average policy, or a vector of regrets. Each of these is a standard single-agent RL or supervised learning problem that can be tested on its own.

They also have drawbacks, which ultimately motivate the second direction of this lecture.

- *Best responses are expensive.* Learning a strong best response requires exploring the game and learning how to act everywhere the opponent might take us. In practice this is nearly as hard as learning an equilibrium. The only simplification is that the opponent is fixed.
- *The loop is nested.* Fictitious play and double oracle call the best-response oracle once per outer iteration, and each call is a full deep RL training run. Work done by one run is largely discarded when the next run starts against a new opponent mixture. Deep CFR similarly retrains its advantage network from scratch at every iteration.
- *The outer loop can be slow even when exact.* Fictitious play can converge very slowly. With adversarial tie-breaking, its rate in $n times n$ zero-sum games can be as bad as $t^(-1\/n)$ #citep(<Daskalakis14:Counter>), and even a $10 times 10$ game forces a rate no better than $t^(-1\/3)$, regardless of how ties are broken #citep(<Wang25:Tie>). Double oracle can require a number of iterations that is exponential in the size of the game description — not merely in its number of pure strategies, which is already exponential in that size #citep(<Zhang24:Exponential>). With deep RL, every one of these iterations becomes a training run.
- *Populations cost memory and simulation.* PSRO must store every policy it has trained and estimate a payoff matrix whose size grows quadratically with the population. Each entry of the matrix requires many rollouts.

The drawbacks above motivate the question that drives the rest of the lecture: can we skip the outer loop and run gradient ascent directly on the policies? In a large study over five imperfect-information benchmarks with exactly computed exploitability and over 7000 training runs, properly tuned policy-gradient methods matched or outperformed NFSP, PSRO, and ESCHER #citep(<Rudolph26:Reevaluating>).

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
