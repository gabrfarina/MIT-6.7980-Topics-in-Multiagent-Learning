#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// Notation follows the behavioral-policy section of this lecture and the earlier notes: the policy network outputs logits
// z_theta(j, a) at each decision point j, and the softmax turns them into the
// behavioral strategy pi_theta(. | j) over the actions A_j.
#let pol(a, j) = $pi_theta (#a bar.v #j)$
#let score(a, j) = $grad_theta log pi_theta (#a bar.v #j)$
#let H = $sans("H")$
#let T = $sans("T")$

= Estimating the gradient on policy <sec-gradient-estimators>

Once behavioral policies are parameterized by logits, the natural algorithm is gradient ascent on the logits, $theta^((t+1)) = theta^((t)) + eta_t grad_theta J(theta^((t)); vy)$, where $J(theta; vy) = ip(x(theta), matU vy)$ is the payoff of the realization plan $x(theta)$ induced by $pi_theta$. It provably converges for policies kept away from the boundary of the simplex and suitably regularized, but that guarantee assumes the gradient is available. The catch is that the exact gradient is a sum over all terminal nodes, so evaluating it requires a pass over the entire game tree. For the games we now care about, that pass is out of reach. In Stratego, the 40 pieces of each player are hidden from the other, and the number of hidden configurations compatible with a single observation is of the order of $40!$, even after accounting for symmetries. Compare this with heads-up limit hold'em, with about $10^14$ information sets, which remains one of the largest games ever solved by tabular methods. Instead, we will run _stochastic_ gradient ascent:
$
  theta^((t+1)) = theta^((t)) + eta_t tilde(vg)^((t)), quad "where" EE[tilde(vg)^((t))] = grad_theta J(theta^((t)); vy^((t))).
$
All the work then goes into constructing the estimator $tilde(vg)^((t))$. The choice of estimator turns out to matter a great deal in practice.

== Which gradient estimator should we use? <sec-which-estimator>

Being unbiased is not enough to pick an estimator: as we will see, there are many unbiased estimators, and they differ wildly in their variance. Less obviously, they also differ in _where_ in the game they spend their samples. To build intuition, we start from the simplest extensive-form game: a tree with a single decision, that is, a normal-form game.

#paragraph-marker() *A single decision.*~~
Suppose the player picks a distribution $vp in Delta(A)$ and, holding the opponent fixed, receives expected utility $J(vp) = vp^top vq$, where $q_a$ is the expected utility of playing action $a$. The gradient is $grad_vp J = vq$, but we never observe $vq$ in full: we play one action and observe one number. In other words, we may query a single coordinate of an unknown vector, and from that one reading we must produce a guess for the entire vector. This is exactly the #lecture-link("bandit")[bandit setting], and the standard fix is _importance sampling_. Choose any proposal distribution $vmu$ with full support, sample $a ~ vmu$, observe $q_a$, and set
$
  hat(vq) := q_a / mu_a ve_a.
$
For _any_ full-support $vmu$, this estimator is unbiased: $EE_(a ~ vmu)[hat(vq)] = sum_(a in A) mu_a (q_a \/ mu_a) ve_a = vq$. The price of unbiasedness is the factor $1 \/ mu_a$: an action that is rarely proposed gets its observed value blown up by a large weight when it does appear. How, then, should $vmu$ be chosen?

== Uniform exploration <sec-uniform-exploration>

Since in self-play every player is one of our learners, we are free to pick the sampling distribution of all of them. Suppose we pick it to make the largest importance weight as small as possible. Then the answer is the uniform distribution:
$
  min_(vmu in Delta(A), mu_a > 0) max_(a in A) 1 / mu_a = |A|, quad "attained at" mu_a = 1 / (|A|).
$
So the theory of a single decision suggests that we _explore uniformly_, independently of what the current strategy $vp$ is doing.

In the large games that motivate deep RL, however, following this advice backfires, for two reasons.

#paragraph-marker() *Importance weights multiply along trajectories.*~~
The calculation above concerns a single decision. In a tree, the correction for a sampled trajectory is the _product_ of the ratios $#pol($a$, $j$) \/ mu(a bar.v j)$ over all of the player's decisions along it. Suppose the current policy is close to deterministic and plays a path through $d$ binary decisions. A uniform proposal follows that path with probability $2^(-d)$, so we need on the order of $2^d$ samples just to observe it once, and when we do, its importance weight is about $2^d$. The estimator stays unbiased, but its variance grows exponentially in the depth of the game.

#figure(
  caption: [Where the samples go in a tree of four binary decisions of the learner. Edge widths and leaf shading are proportional to the probability that a sampled trajectory passes through them. _Left:_ uniform exploration spreads samples evenly over all 16 leaves. _Right:_ sampling from a policy that picks the left action with probability $0.85$ sends about half of all trajectories down the path the policy actually plays.],
)[
  #image(
    "figures/deep_rl_gradient_estimators/sampling_tree.svg",
    width: 100%,
    alt: "Two binary trees of depth four. In the left tree all edges have equal width and all sixteen leaves are lightly shaded. In the right tree the leftmost path is drawn thick and its leaf is dark, while edges away from it get thinner.",
  )
] <fig-sampling-tree>

#paragraph-marker() *Samples are spent where it does not matter.*~~
Even setting variance aside, @fig-sampling-tree shows that a uniform sampler devotes most of its trajectories to regions of the tree that reasonable play rarely enters. Neither we nor a competent opponent will act at random when it matters, so precise gradient estimates at decision points reachable only through a string of mistakes buy us very little. We summarize the lesson as follows.

#box(
  fill: luma(94%),
  inset: 3mm,
  radius: 1.5mm,
)[
  *General principle: stay on policy*. Sample effort, and with it compute, should go to the situations that the current policies actually produce. Concretely, we estimate gradients from trajectories sampled from the current policies of all players, rather than from a separate exploration distribution.
]

Two caveats apply. First, in practice data is always slightly _off_ policy: by the time a batch of self-play games has been collected, the parameters have moved a little. The tools in @sec-rl-toolbox are designed to tolerate this lag. Second, sampling on policy does not remove the need to keep trying every action now and then. The truncation and entropy bonus required by the convergence analysis keep every local probability bounded away from zero, and so provide exactly this.

== REINFORCE <sec-reinforce>

Choosing behavioral strategies cost us the convexity of the utility, but it pays off here. The reach probability of each terminal node is a _product_ of behavioral probabilities, and reinforcement learning has a well-developed toolbox for estimating gradients of expectations of such products. The simplest of these tools is the REINFORCE estimator of #citet(<williams1992simple>), also known as the _likelihood-ratio_ or _score-function_ estimator #citep(<sutton2000policy>). We derive it in three steps, for a finite perfect-recall game with the opponent strategy $vy$ and chance held fixed.

#paragraph-marker() *Step 1: separating what we control from what we do not.*~~
// TODO when the sections are merged: cite the realization-plan equation (@eq-realization) here.
Consider a complete play of the game, from the root to a terminal node, and call it $tau$. We write $R(tau)$ for the payoff we receive when it ends and $sigma(tau)$ for the pairs $(j, a)$ at which we acted along the way. By the recursion that defines the realization plan, our own contribution to reaching the end of $tau$ is the entry of $x(theta)$ on the last of these pairs, which we abbreviate $x(theta)_(sigma(tau))$; it is the product of $#pol($a$, $j$)$ over $(j, a) in sigma(tau)$. The probability of the whole path therefore factors into the part we control and the part we do not, and the bilinear payoff becomes an expectation over plays:
$
  P_theta (tau) = q(tau) dot x(theta)_(sigma(tau)), quad J(theta; vy) = sum_tau P_theta (tau) R(tau) = EE_(tau ~ P_theta)[R(tau)],
$
where $q(tau)$ is the product of the probabilities of all opponent and chance moves along $tau$. Crucially, $q(tau)$ does not depend on $theta$.

#paragraph-marker() *Step 2: the logarithm turns products into sums.*~~
Taking the logarithm turns the product into a sum, and the opponent and chance factor drops out:
$
  s_theta (tau) := grad_theta log P_theta (tau) = underbrace(grad_theta log q(tau), = 0) + sum_((j, a) in sigma(tau)) #score($a$, $j$).
$
The quantity $s_theta (tau)$ is called the _score_ of the trajectory. Note that it does not involve the opponents' strategy or the chance probabilities at all, only our own policy along the sampled path. This is what makes the estimator practical.

#paragraph-marker() *Step 3: the gradient as an expectation.*~~
For any differentiable positive function, $grad P = P grad log P$, since $grad log P = (grad P) \/ P$. Applying this to every term of $J$ gives the following identity.

#theorem[Policy gradient][
  For every $theta$,
  $
    grad_theta J(theta; vy) = sum_tau P_theta (tau) R(tau) s_theta (tau) = EE_(tau ~ P_theta)[R(tau) s_theta (tau)].
  $
] <thm-policy-gradient>

The gradient is an expectation over trajectories, and an expectation can be estimated without bias by sampling. We sample $B$ episodes $tau_1, ..., tau_B$ by letting every player act according to their current policy, that is, from the on-policy distribution $P_theta$, and form the _REINFORCE estimator_
$
  hat(vg)_theta := 1/B sum_(b=1)^B R(tau_b) s_theta (tau_b), quad EE[hat(vg)_theta] = grad_theta J(theta; vy).
$
Each sampled episode thus contributes the product of the payoff it obtained and the score of its own decisions. The gradients $#score($a$, $j$)$ are exactly what automatic differentiation computes when we backpropagate the log-probability of the action actually taken. The resulting algorithm is summarized in @algo-reinforce.

#pseudocode-list(numbered-title: [REINFORCE in self-play])[
  - *Data:* policy network with parameters $theta$; step size $eta > 0$; batch size $B$.
  + *repeat*:
    + Play $B$ episodes $tau_1, ..., tau_B$ in which every player samples actions from its current policy.
    + *for each* episode $tau_b$ and each of our decisions $(j, a) in sigma(tau_b)$:
      + record the log-probability $log #pol($a$, $j$)$ and the final payoff $R(tau_b)$.
    + $hat(vg)_theta <- 1/B sum_b R(tau_b) sum_((j, a) in sigma(tau_b)) #score($a$, $j$)$ _(by backpropagation)_
    + $theta <- theta + eta hat(vg)_theta$
] <algo-reinforce>

#example[REINFORCE in Kuhn poker][
  Consider again Player~1 in #lecture-link("efg_intro", <sec-game-trees>)[Kuhn poker], with the decision points $j_1, ..., j_6$ (one per information set of Player~1) used in #lecture-link("learning_efg", <sec-cfr>)[the CFR example]. Suppose that in one self-play episode Player~1 is dealt the King, so play reaches $j_3$, where Player~1 checks. Player~2 then bets, and Player~1 calls at $j_6$. At showdown, Player~1 wins the ante and Player~2's bet, so $R(tau) = 2$. The REINFORCE estimate from this single episode is
  $
    hat(vg)_theta = 2 (#score($sans("check")$, $j_3$) + #score($sans("call")$, $j_6$)).
  $
  The chance probability $1\/6$ of the deal and the probability with which Player~2 decided to bet appear nowhere in the estimate: they belong to $q(tau)$, and the logarithm sent them to a separate term with zero gradient. Only the two decision points that Player~1 actually visited receive a gradient signal. The other four are updated only in the episodes that reach them, which, on policy, is in proportion to how often they matter.
] <ex-reinforce-kuhn>

In self-play, every player runs the same update on its own payoff. In a two-player zero-sum game, both seats are often played by a single network that receives the seat as part of its input.

#paragraph-marker() *What REINFORCE does to the logits.*~~
With the softmax parameterization of the policy, the gradient of the log-probability with respect to the logits $vz = z_theta (j, dot)$ at $j$ has a simple form:
$
  grad_vz log "softmax"(vz)_a = ve_a - #pol($dot$, $j$).
$
So a single REINFORCE sample raises the logit of the action taken by an amount proportional to the payoff received and lowers every logit in proportion to its current probability. When the payoff is negative, the update reverses: probability mass moves away from the action taken.

#example[One REINFORCE step in matching pennies][
  Consider matching pennies with payoff matrix $matU = mat(1, -1; -1, 1)$ for the learner, who wins when the two coins match. Let the opponent play heads with probability $0.35$. The learner's expected payoffs are then $vq = (2 dot 0.35 - 1, 1 - 2 dot 0.35) = (-0.3, 0.3)$ over $(#H, #T)$, so the best response is tails. Start from logits $vz = bold(0)$, so that $vp = (1\/2, 1\/2)$, and take one sample per step. Both the learner's action and the opponent's coin are random, and the update to the logits is $eta R (ve_a - vp)$:
  - the coins match ($R = 1$): the update is $plus.minus (eta \/ 2)(1, -1)$, pushing toward the action played;
  - the coins differ ($R = -1$): the update pushes away from the action played.
  Averaging over the four outcomes, heads gains $eta \/ 2$ with probability $0.35$ and loses $eta \/ 2$ with probability $0.65$, so the expected update is $eta (-0.15, 0.15)$. This matches the exact gradient of $vp^top vq$ with respect to $vz$ at $vz = bold(0)$, which is $vp dot.o vq - vp (vp^top vq) = (-0.15, 0.15)$. Note how weak the signal is compared with the noise: every individual update has size $eta \/ 2$ per coordinate, but on average they only point toward tails by $0.15 eta$.

  Now add a constant $10$ to every payoff, which changes neither the game nor the best response. The expected update is unchanged, since the extra term $10 eta (ve_a - vp)$ has mean zero. But every individual update is now about ten times larger and points in the direction of whatever action happened to be sampled. The estimator is still unbiased, but its variance has exploded.
] <ex-reinforce-pennies>

#exercise[REINFORCE is on-policy importance sampling][
  Consider a single decision with logits $vz$ and $vp = "softmax"(vz)$. Show that the REINFORCE estimator in logit space, $q_a (ve_a - vp)$ with $a ~ vp$, is obtained by taking the importance-sampling estimator $hat(vq) = (q_a \/ p_a) ve_a$ of @sec-which-estimator with proposal $vmu = vp$ and applying the chain rule through the softmax, whose Jacobian is $diag(vp) - vp vp^top$.
] <ex-reinforce-is>

#solution[
  By the chain rule, a gradient $hat(vq)$ with respect to $vp$ becomes the gradient $(diag(vp) - vp vp^top) hat(vq)$ with respect to $vz$, since the Jacobian is symmetric. Substituting $hat(vq) = (q_a \/ p_a) ve_a$,
  $
    (diag(vp) - vp vp^top) q_a / p_a ve_a = q_a / p_a (p_a ve_a - p_a vp) = q_a (ve_a - vp).
  $
  So REINFORCE is exactly the importance-sampling estimator with the _on-policy_ proposal $vmu = vp$, rather than the uniform proposal that minimizes the worst-case importance weight. Note that the factor $1\/p_a$ cancels: the logit parameterization removes the large importance weights of rarely played actions.
]

== Reducing variance: baselines and learned critics <sec-baselines>

Unbiasedness does not make REINFORCE practical on its own. The single payoff observed at the end of an episode, itself a random quantity, multiplies the score of every decision taken along the way, early and late, relevant or not. A further source of noise appears in @ex-reinforce-pennies: shifting all payoffs by a constant leaves the signal unchanged but inflates the variance. Reinforcement learning offers several well-tested remedies.

#paragraph-marker() *Why we can subtract a baseline.*~~
The key fact is that the score has zero mean at every decision point:
$
  EE_(a ~ #pol($dot$, $j$))[#score($a$, $j$)] = sum_(a in A_j) #pol($a$, $j$) (grad_theta #pol($a$, $j$)) / #pol($a$, $j$) = grad_theta sum_(a in A_j) #pol($a$, $j$) = grad_theta 1 = bold(0).
$
So we can subtract from $R(tau)$ any quantity $b(j)$ that is fixed before the action at $j$ is sampled, without introducing bias.

#theorem[Baselines preserve unbiasedness][
  Let $b$ assign a number to each decision point (more generally, any random variable determined before the action at $j$ is sampled). Then
  $
    grad_theta J(theta; vy) = EE_(tau ~ P_theta)[sum_((j, a) in sigma(tau)) #score($a$, $j$) (R(tau) - b(j))].
  $
] <thm-baseline>

#proof[
  By @thm-policy-gradient, it suffices to show that each term $EE[#score($a$, $j$) b(j)]$ vanishes. Condition on the episode up to the moment we act at $j$. Given this history, $b(j)$ is a constant and $a$ is drawn from $#pol($dot$, $j$)$, so the conditional expectation is $b(j)$ times the zero-mean score above. Taking expectations over the history concludes the proof.
]

Since the baseline only needs to be determined before the action at $j$ is sampled, it may even depend on information the player cannot see, such as the opponent's private cards. This matters for critics trained centrally in self-play. The policy itself, of course, must still depend only on the player's own information.

#paragraph-marker() *From REINFORCE to actor-critic.*~~
Define the _action value_, _state value_, and _advantage_ of a decision point under the current policies:
$
  Q_theta (j, a) & := EE_(tau ~ P_theta)[R(tau) bar.v j "reached", a "chosen"], \
  V_theta (j) & := sum_(b in A_j) #pol($b$, $j$) Q_theta (j, b), \
  A_theta (j, a) & := Q_theta (j, a) - V_theta (j).
$
The advantage measures how much better $a$ is than our current average behavior at $j$. Taking $b = V_theta$ in @thm-baseline and conditioning on each decision, the policy gradient can be rewritten with advantages in place of payoffs:
$
  grad_theta J = EE_(tau ~ P_theta)[sum_((j, a) in sigma(tau)) A_theta (j, a) #score($a$, $j$)].
$
Actions that do better than expected get reinforced, and actions that do worse get suppressed. In @ex-reinforce-pennies, the baseline $V_theta = 10$ would remove the offset entirely.

The advantage is unknown, so we approximate it with a second learned model, called the _critic_, which may predict $A_theta$ itself or the values $V$ and $Q$ from which it is computed. The policy $pi_theta$ that the critic helps train is called the _actor_ #citep(<konda2000actor>). For instance, a network $V_phi$ can be trained on the same self-play data to predict the final payoff,
$
  min_phi EE_(tau ~ P_theta)[sum_((j, a) in sigma(tau)) (V_phi (j) - R(tau))^2],
$
while the actor is updated with the advantage estimates $R(tau) - V_phi (j)$ in place of $R(tau)$. The critic can be a separate network or a second "head" on a trunk shared with the policy. Either way, one model decides how to act and the other judges how good those decisions were. A critic can go one step further and _bootstrap_, estimating $Q_theta (j, a)$ from its own prediction at the next decision point instead of waiting for the end of the episode. This lowers variance further but introduces bias whenever the critic is inaccurate.

@fig-baseline-curves returns to matching pennies with an offset of $10$, as in @ex-reinforce-pennies, and compares plain REINFORCE with REINFORCE using the simplest possible critic: a single number $b$, updated as a running average $b <- b + 0.1 (R - b)$ of the payoffs received.

#figure(
  caption: [Probability of tails over 400 steps of REINFORCE in matching pennies, with one sample per step and $eta = 0.1$, against an opponent who plays heads with probability $0.35$, after adding $10$ to every payoff. Each grey line is one of 20 independent runs, and the dashed line is exact gradient ascent. _Left:_ without a baseline, every sampled action receives a large positive update, so whichever action gets sampled early tends to win, and many runs lock onto heads. _Right:_ with a learned baseline $b$ (initialized at $0$), the runs follow the exact gradient toward tails: 19 of the 20 end above $0.9$, and the last one is still climbing.],
)[
  #image(
    "figures/deep_rl_gradient_estimators/baseline_curves.svg",
    width: 100%,
    alt: "Two line plots of the probability of tails over 400 steps. Left: twenty grey runs without a baseline jump erratically; about half rise to one and many collapse to zero. Right: with a learned baseline, the runs rise smoothly toward one, close to the dashed exact-gradient curve.",
  )
] <fig-baseline-curves>

You can rerun this experiment with other opponents, offsets, step sizes, batch sizes, and baselines in the #interactive-link("reinforce_pennies")[interactive REINFORCE explorer].

#remark[Connection to CFR][
  Policy gradient and CFR are closer relatives than they first appear. With one logit $z(j, a)$ per decision point and action in a perfect-recall game, a direct calculation gives
  $
    (partial J) / (partial z(j, a)) = P_theta (j) dot #pol($a$, $j$) dot A_theta (j, a),
  $
  where $P_theta (j)$ is the probability that play reaches $j$. Factoring $P_theta (j)$ into our own reach probability and the reach probability $w_(-i)(j)$ of the opponents and chance, the product $w_(-i)(j) A_theta (j, a)$ is exactly the instantaneous counterfactual regret of action $a$ at $j$ that drives #lecture-link("learning_efg", <sec-cfr>)[CFR]. So an actor-critic update at $j$ is driven by the same comparison of an action against the current average that CFR uses, with the extra factor of our own reach probability and $pi_theta (a bar.v j)$ #citep(<srinivasan2018actor>). Abandoning the sequence form, then, left us closer to the game-theoretic algorithms than the change of representation might suggest.
] <rem-cfr-connection>

#exercise[
  Verify the formula in @rem-cfr-connection. _Hint:_ only the terminal nodes below $j$ depend on $z(j, a)$, and the derivative of the softmax is $partial pi(a' bar.v j) \/ partial z(j, a) = pi(a' bar.v j)(bb(1)[a = a'] - pi(a bar.v j))$.
]

#solution[
  By perfect recall, each terminal node below $j$ passes through $j$ exactly once, through some action $a'$, and its reach probability factors as $P_theta (j) dot pi(a' bar.v j) dot P'(tau)$, where $P'(tau)$ collects the probabilities of all moves after $(j, a')$. By definition of $Q_theta$, $sum_(tau "below" (j, a')) P'(tau) R(tau) = Q_theta (j, a')$. Hence
  $
    (partial J) / (partial z(j, a)) = P_theta (j) sum_(a' in A_j) pi(a' bar.v j)(bb(1)[a = a'] - pi(a bar.v j)) Q_theta (j, a') = P_theta (j) pi(a bar.v j) (Q_theta (j, a) - V_theta (j)),
  $
  using $V_theta (j) = sum_(a') pi(a' bar.v j) Q_theta (j, a')$.
]

== The RL toolbox <sec-rl-toolbox>

Because reach probabilities factor over our own decisions, and the logarithm turns that factorization into a sum, the machinery developed for single-agent reinforcement learning applies almost as is. All of the following tools are, at heart, different ways of building or reusing gradient estimators.

- *Interpolating between estimators.* $n$-step returns, TD($lambda$), and generalized advantage estimation (GAE) #citep(<schulman2016high>) trade off the unbiased Monte Carlo estimate $R(tau) - V_phi (j)$ (which corresponds to $lambda = 1$) with the lower-variance bootstrapped estimate from the critic (which corresponds to $lambda = 0$).
- *Tolerating slightly stale data.* Proximal policy optimization (PPO) #citep(<schulman2017proximal>) reuses each batch for several gradient steps, correcting with the ratio between the new and the old policy and clipping it, so that the data never drifts too far from on policy.
- *Large batches and normalization.* Averaging over many self-play episodes from both seats and normalizing the advantages within a batch are simple and effective ways to tame variance.

None of these tools addresses the cycling of simultaneous updates; forcing convergence requires regularization. With regularization in place, the approach is very competitive. A large empirical study, spanning more than 7,000 training runs on five benchmark games where exploitability can be measured exactly, found policy gradient methods such as PPO and MMD to be at least as good as NFSP, PSRO, Deep CFR, and the other game-theoretic deep RL methods it compared against #citep(<rudolph2026reevaluating>).

For a thorough treatment of policy gradient and actor-critic methods in the single-agent setting, see #citet(<sutton2018reinforcement>, supplement: [Chapter 13]).

= Further modifications and take-aways <sec-takeaways>

== Two directions, revisited <sec-two-directions>

The lecture started from a problem we have been solving since the #lecture-link("correlated", <sec-zero-sum>)[first lectures on zero-sum games]: find a saddle point of $max_(vx in cX) min_(vy in cY) vx^top matU vy$, where, for extensive-form games, $cX$ and $cY$ are the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytopes]. Every method we had for this problem stores something per decision point, whether an LP variable, a cumulative regret, or an average strategy, and that is exactly what breaks once the game has as many information sets as Stratego. Two ways around the obstacle were considered.

- *"Deepify" game theory.* Begin with an equilibrium-finding algorithm that is already proven correct, such as fictitious play, double oracle, or CFR, identify its one expensive primitive, and hand that primitive to a neural network: a best response trained by deep RL (NFSP, PSRO), or a network that predicts cumulative regrets (Deep CFR). The appeal is that the outer loop, and with it the intuition for why the method should work, stays intact.
- *"Game-theorify" deep RL.* Start from methods that are already known to scale, policy gradient methods in particular, and change only what is needed for them to find equilibria. This took three design choices: parameterize behavioral policies by logits, estimate gradients on policy with baselines and critics, and regularize so that self-play converges instead of cycling.

@tab-two-directions puts the two directions side by side.

#figure(
  kind: table,
  supplement: [Table],
  caption: [The two directions of this lecture.],
)[
  #set par(justify: false)
  #table(
    stroke: none,
    columns: 3,
    align: left + top,
    inset: .55em,
    table.header([], [*Deepify game theory*], [*Game-theorify deep RL*]),
    table.hline(stroke: .4pt),
    [Starting point], [a tabular algorithm with guarantees], [a scalable single-agent RL method],
    [What is learned], [best responses, regrets, average policies], [the policy itself, plus a critic],
    [Structure], [nested: an outer loop around many training runs], [one training run of self-play],
    [Examples], [NFSP, PSRO, Deep CFR], [PPO, MMD, VRPO],
    [Main cost], [each best response is a full RL problem], [noisy gradients and the need to regularize],
  )
] <tab-two-directions>

What did each direction buy us? The deepified methods keep their guarantees only to the extent that every learned component is accurate, and they pay for that structure with nested training loops. A single accurate best response in a large game costs about as much to train as the equilibrium we were after in the first place, and these algorithms ask for one per outer iteration. The game-theorified methods spend their entire budget on a single self-play run. In return they give up convexity, but less than one might expect: the payoff is still hidden concave in the policy, and with truncation and regularization, policy gradient provably converges. Empirically, tuned policy gradient methods are at least as good as the deepified ones on games where exploitability can be computed exactly #citep(<rudolph2026reevaluating>), and the same recipe, together with decision-time planning, produced the first superhuman Stratego agent, at a small fraction of the compute used by earlier attempts #citep(<sokota2026scalable>).

== What might still go wrong: noise <sec-still-noisy>

Every gradient in this recipe is estimated from sampled play, so even a correct and unbiased method can be too noisy to train well. Baselines and critics (@sec-baselines) remove much of the noise, but games add a source of noise that single-agent RL rarely sees. We discuss two practical fixes.

#paragraph-marker() *Noise that survives a perfect critic.*~~
PPO estimates advantages with GAE, which adds up one-step residuals $r + V(s') - V(s)$ along the sampled trajectory. In an MDP, an optimal policy can be deterministic, so near convergence the later actions along a trajectory are nearly predictable. In a game, equilibrium play is typically mixed, and the actions sampled _later_ in the trajectory by the opponent, by chance, and by ourselves keep injecting randomness into the estimate of the advantage of an _earlier_ action. This happens even when the value function is exact #citep(<fan2026gae>).

#example[Residual noise in matching pennies][
  Let the learner play heads, after which the opponent, who does not see the learner's coin, plays heads or tails with probability $1\/2$ each, as at equilibrium. A critic that sees everything assigns value $0$ to the state "learner played heads", which is exact: the learner wins or loses $1$ with equal probability. The true advantage of heads is also $0$. Yet the GAE estimate of that advantage is $R - V = plus.minus 1$, depending on the opponent's coin. No amount of critic training removes this $plus.minus 1$, because it comes from the opponent's sampled action, not from an error in $V$.
] <ex-residual-noise>

_Variance-reduced policy optimization_ (VRPO) #citep(<fan2026gae>) fixes this with a centralized action-value critic $Q(s, a)$, where $s$ is the full state of the game, including hidden information, which is allowed by the observation after @thm-baseline. Wherever GAE would bootstrap through the single action that happened to be sampled at a state, the new estimator, called _Q-boosting_, instead averages over the policy at that state, $V(s) = sum_a pi(a bar.v s) Q(s, a)$, in the spirit of Expected SARSA. If $Q$ is exact, every residual along the trajectory vanishes, and the estimate of the advantage of the action $a$ taken at $s$ is exactly $Q(s, a) - V(s)$. In @ex-residual-noise this gives $0$, with no noise at all. With an inexact critic, the estimator stays unbiased for the policy gradient when its trace parameter is $lambda = 1$, and it improves on GAE whenever the critic is accurate enough. VRPO plugs Q-boosting into PPO and otherwise leaves it unchanged. On three games with exactly computable exploitability, it reached exploitability more than $15%$ lower than tuned policy gradient baselines (independent PPO, MAPPO, MMD, and PPG), and in Dou Dizhu it overtook the previous strongest agent while using roughly $40%$ of that agent's training steps #citep(<fan2026gae>). The price is that $V(s)$ requires enumerating the actions at $s$, so large action spaces must be broken into several smaller decisions.

#paragraph-marker() *Noise in the iterates.*~~
Even with good gradient estimates, stochastic updates with a constant step size never settle exactly: the parameters keep jittering around a good region. The theory of the earlier lectures already hints at a fix. No-regret dynamics guarantee that the #lecture-link("learning_intro", <sec-learning-zero-sum>)[_average_ strategies] converge, and CFR outputs an average strategy for the same reason. A cheap stand-in is to keep an _exponential moving average_ of the parameters,
$
  overline(theta)^((t)) = beta overline(theta)^((t-1)) + (1 - beta) theta^((t)), quad 0 < beta < 1,
$
and to evaluate and deploy the network with parameters $overline(theta)^((t))$ rather than $theta^((t))$. The average effectively covers the last $1 \/ (1 - beta)$ updates, so Ataraxos, which uses $beta = 0.999$ for its setup and move networks #citep(<sokota2026scalable>), averages over roughly the last thousand updates. This is a form of the iterate averaging long used in stochastic optimization #citep(<polyak1992acceleration>). One caveat is important. The map from parameters to policies is nonlinear, so the policy of $overline(theta)^((t))$ is in general _not_ the average of the policies $pi_(theta^((s)))$. It is not the reach-weighted sequence-form average that CFR and fictitious play require either. The moving average is a practical device for stability, not a substitute for the averaging in the theorems.

== Key take-aways <sec-key-takeaways>

+ *At scale, the priorities change.* For tabular methods, the questions were convergence rates and exactness. For large games, they are representation, sample efficiency, and stability. Running gradient ascent on the policy itself, in one long self-play run, beats wrapping deep learning inside an outer loop.
+ *Losing convexity in the representation does not mean losing it in the problem.* The sequence form makes the payoff linear, and the behavioral parameterization hides this structure without destroying it. Hidden concavity explains why gradient ascent on logits still converges.
+ *The estimator is part of the algorithm.* Sampling on policy, subtracting baselines, learning critics, and, in games, averaging out the noise from mixed strategies (VRPO) decide in practice whether training works. These ideas are the bandit estimators of @sec-which-estimator pushed through a tree.
+ *Self-play needs regularization.* Simultaneous gradient updates can cycle, as in matching pennies. Entropy regularization restores convergence, and in practice it should be used more heavily than single-agent defaults suggest #citep(<rudolph2026reevaluating>).
+ *Training and planning complement each other.* A blueprint policy trained by self-play can be improved at decision time by a little extra search, as Ataraxos does in Stratego.

#paragraph-marker() *How this lecture connects to the rest of the course.*~~
Most of the ingredients of this lecture appeared earlier in the course in tabular form.
- The objective is the same #lecture-link("correlated", <sec-zero-sum>)[saddle-point problem] as before, and self-play is the #lecture-link("learning_intro", <sec-learning-zero-sum>)[self-play setup] for learning in zero-sum games, now run on network parameters.
- The softmax policy with an entropy bonus is a close relative of #lecture-link("learning1", <sec-mwu>)[multiplicative weights] and of #lecture-link("learning1", <sec-ftrl>)[FTRL] with an entropy regularizer. The concern with whether the iterates themselves converge, rather than their averages, is the subject of #lecture-link("learning2", <sec-iterate-convergence>)[last-iterate convergence].
- Gradient estimation from a single sampled outcome is the problem solved by the importance-sampling estimators of #lecture-link("bandit")[bandit feedback].
- The choice between behavioral and #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form] strategies drives the whole lecture, and the actor-critic update turns out to compare each action against the current average just as #lecture-link("learning_efg", <sec-cfr>)[CFR] does, with $Q$-values where CFR uses counterfactual values (@rem-cfr-connection).

What is new is the willingness to trade exact guarantees for scale. The theory of the earlier lectures is what tells us which approximations are safe to make.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
