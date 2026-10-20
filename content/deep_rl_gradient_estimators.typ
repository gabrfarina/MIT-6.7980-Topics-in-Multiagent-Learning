#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

// Notation follows the lecture slides and "Choice I": the policy network outputs
// logits z_theta(I, a) at each information set I, and the softmax turns them into
// the behavioral strategy pi_theta(. | I) over the actions A(I).
#let pol(a, I) = $pi_theta (#a mid(|) #I)$
#let score(a, I) = $grad_theta log pi_theta (#a mid(|) #I)$
#let H = $sans("H")$
#let T = $sans("T")$

= Game theory-ifying, choice 2: estimating the gradient on policy <sec-choice-2>

The first choice left us with a policy network that maps every information set $I$ of a player to logits $z_theta (I, a)$, and from there, via the softmax, to a behavioral strategy $#pol($dot$, $I$) in Delta(A(I))$. Against a fixed opponent strategy $vy$, the player's expected utility $J(theta; vy)$ is a smooth function of the network parameters $theta$, and we want to run gradient ascent on it. The catch is that the exact gradient is a sum over all terminal nodes, so evaluating it requires a pass over the entire game tree. For the games we now care about, that pass is out of reach. In Stratego, the 40 pieces of each player are hidden from the other, and the number of hidden configurations compatible with a single observation is of the order of $40!$, even after accounting for symmetries. Compare this with heads-up limit hold'em, with about $10^14$ information sets, which remains one of the largest games ever solved by tabular methods. Instead, we will run _stochastic_ gradient ascent:
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
The calculation above concerns a single decision. In a tree, the correction for a sampled trajectory is the _product_ of the ratios $#pol($a$, $I$) \/ mu(a mid(|) I)$ over all of the player's decisions along it. Suppose the current policy is close to deterministic and plays a path through $d$ binary decisions. A uniform proposal follows that path with probability $2^(-d)$, so we need on the order of $2^d$ samples just to observe it once, and when we do, its importance weight is about $2^d$. The estimator stays unbiased, but its variance grows exponentially in the depth of the game.

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
Even setting variance aside, @fig-sampling-tree shows that a uniform sampler devotes most of its trajectories to regions of the tree that reasonable play rarely enters. Neither we nor a competent opponent will act at random when it matters, so precise gradient estimates at information sets reachable only through a string of mistakes buy us very little. We summarize the lesson as follows.

#box(
  fill: luma(94%),
  inset: 3mm,
  radius: 1.5mm,
)[
  *General principle: stay on policy*. Sample effort, and with it compute, should go to the situations that the current policies actually produce. Concretely, we estimate gradients from trajectories sampled from the current policies of all players, rather than from a separate exploration distribution.
]

Two caveats apply. First, in practice data is always slightly _off_ policy: by the time a batch of self-play games has been collected, the parameters have moved a little. The tools in @sec-rl-toolbox are designed to tolerate this lag. Second, sampling on policy does not remove the need to keep trying every action now and then. The entropy regularization discussed in the next choice keeps every action's probability bounded away from zero, which keeps the policy exploring on its own.

== REINFORCE <sec-reinforce>

Choosing behavioral strategies in choice 1 cost us the convexity of the utility, but it pays off here. The reach probability of each terminal node is a _product_ of behavioral probabilities, and reinforcement learning has a well-developed toolbox for estimating gradients of expectations of such products. The simplest of these tools is the REINFORCE estimator of #citet(<williams1992simple>), also known as the _likelihood-ratio_ or _score-function_ estimator #citep(<sutton2000policy>). We derive it in four steps, for a finite perfect-recall game with the opponent and chance held fixed.

#paragraph-marker() *Step 1: our own contribution to reaching a node.*~~
Fix a path of the game and let $sigma$ be the sequence of pairs $(I, a)$ at which we acted along it. The probability that our own actions follow $sigma$ is the product of the behavioral probabilities along it, which is exactly the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form] entry
$
  x_theta (sigma) = product_((I, a) in sigma) #pol($a$, $I$).
$

#paragraph-marker() *Step 2: separating what we control from what we do not.*~~
Consider a complete play of the game, from the root to a terminal node, and call it $tau$. We write $R(tau)$ for the payoff we receive when it ends and $sigma(tau)$ for the pairs $(I, a)$ at which we acted along the way. The probability of the whole path factors into the part we control and the part we do not:
$
  P_theta (tau) = q(tau) dot x_theta (sigma(tau)), quad J(theta) = sum_tau P_theta (tau) R(tau) = EE_(tau ~ P_theta)[R(tau)],
$
where $q(tau)$ is the product of the probabilities of all opponent and chance moves along $tau$. Crucially, $q(tau)$ does not depend on $theta$.

#paragraph-marker() *Step 3: the logarithm turns products into sums.*~~
Taking the logarithm turns the product into a sum, and the opponent and chance factor drops out:
$
  s_theta (tau) := grad_theta log P_theta (tau) = underbrace(grad_theta log q(tau), = 0) + sum_((I, a) in sigma(tau)) #score($a$, $I$).
$
The quantity $s_theta (tau)$ is called the _score_ of the trajectory. Note that it does not involve the opponents' strategy or the chance probabilities at all, only our own policy along the sampled path. This is what makes the estimator practical.

#paragraph-marker() *Step 4: the gradient as an expectation.*~~
For any differentiable positive function, $grad P = P grad log P$, since $grad log P = (grad P) \/ P$. Applying this to every term of $J$ gives the following identity.

#theorem[Policy gradient][
  For every $theta$,
  $
    grad_theta J(theta) = sum_tau P_theta (tau) R(tau) s_theta (tau) = EE_(tau ~ P_theta)[R(tau) s_theta (tau)].
  $
] <thm-policy-gradient>

The gradient is an expectation over trajectories, and an expectation can be estimated without bias by sampling. We sample $B$ episodes $tau_1, ..., tau_B$ by letting every player act according to their current policy, that is, from the on-policy distribution $P_theta$, and form the _REINFORCE estimator_
$
  hat(vg)_theta := 1/B sum_(b=1)^B R(tau_b) s_theta (tau_b), quad EE[hat(vg)_theta] = grad_theta J(theta).
$
Each sampled episode thus contributes the product of the payoff it obtained and the score of its own decisions. The gradients $#score($a$, $I$)$ are exactly what automatic differentiation computes when we backpropagate the log-probability of the action actually taken. The resulting algorithm is summarized in @algo-reinforce.

#pseudocode-list(numbered-title: [REINFORCE in self-play])[
  - *Data:* policy network with parameters $theta$; step size $eta > 0$; batch size $B$.
  + *repeat*:
    + Play $B$ episodes $tau_1, ..., tau_B$ in which every player samples actions from its current policy.
    + *for each* episode $tau_b$ and each of our decisions $(I, a) in sigma(tau_b)$:
      + record the log-probability $log #pol($a$, $I$)$ and the final payoff $R(tau_b)$.
    + $hat(vg)_theta <- 1/B sum_b R(tau_b) sum_((I, a) in sigma(tau_b)) #score($a$, $I$)$ _(by backpropagation)_
    + $theta <- theta + eta hat(vg)_theta$
] <algo-reinforce>

#example[REINFORCE in Kuhn poker][
  Consider again Player~1 in #lecture-link("efg_intro", <sec-game-trees>)[Kuhn poker], with the decision points $j_1, ..., j_6$ (one per information set of Player~1) used in #lecture-link("learning_efg", <sec-cfr>)[the CFR example]. Suppose that in one self-play episode Player~1 is dealt the King, so play reaches $j_3$, where Player~1 checks. Player~2 then bets, and Player~1 calls at $j_6$. At showdown, Player~1 wins the ante and Player~2's bet, so $R(tau) = 2$. The REINFORCE estimate from this single episode is
  $
    hat(vg)_theta = 2 (#score($sans("check")$, $j_3$) + #score($sans("call")$, $j_6$)).
  $
  The chance probability $1\/6$ of the deal and the probability with which Player~2 decided to bet appear nowhere in the estimate: they belong to $q(tau)$, and the logarithm sent them to a separate term with zero gradient. Only the two information sets that Player~1 actually visited receive a gradient signal. The other four are updated only in the episodes that reach them, which, on policy, is in proportion to how often they matter.
] <ex-reinforce-kuhn>

In self-play, every player runs the same update on its own payoff. In a two-player zero-sum game, both seats are often played by a single network that receives the seat as part of its input.

#paragraph-marker() *What REINFORCE does to the logits.*~~
With the softmax parameterization of choice 1, the gradient of the log-probability with respect to the logits $vz = z_theta (I, dot)$ at $I$ has a simple form:
$
  grad_vz log "softmax"(vz)_a = ve_a - #pol($dot$, $I$).
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
The key fact is that the score has zero mean at every information set:
$
  EE_(a ~ #pol($dot$, $I$))[#score($a$, $I$)] = sum_(a in A(I)) #pol($a$, $I$) (grad_theta #pol($a$, $I$)) / #pol($a$, $I$) = grad_theta sum_(a in A(I)) #pol($a$, $I$) = grad_theta 1 = bold(0).
$
So we can subtract from $R(tau)$ any quantity $b(I)$ that is fixed before the action at $I$ is sampled, without introducing bias.

#theorem[Baselines preserve unbiasedness][
  Let $b$ assign a number to each information set (more generally, any random variable determined before the action at $I$ is sampled). Then
  $
    grad_theta J(theta) = EE_(tau ~ P_theta)[sum_((I, a) in sigma(tau)) #score($a$, $I$) (R(tau) - b(I))].
  $
] <thm-baseline>

#proof[
  By @thm-policy-gradient, it suffices to show that each term $EE[#score($a$, $I$) b(I)]$ vanishes. Condition on the episode up to the moment we act at $I$. Given this history, $b(I)$ is a constant and $a$ is drawn from $#pol($dot$, $I$)$, so the conditional expectation is $b(I)$ times the zero-mean score above. Taking expectations over the history concludes the proof.
]

Since the baseline only needs to be determined before the action at $I$ is sampled, it may even depend on information the player cannot see, such as the opponent's private cards. This matters for critics trained centrally in self-play. The policy itself, of course, must still depend only on the player's own information.

#paragraph-marker() *From REINFORCE to actor-critic.*~~
Define the _action value_, _state value_, and _advantage_ of an information set under the current policies:
$
  Q_theta (I, a) := EE_(tau ~ P_theta)[R(tau) mid(|) I "reached", a "chosen"], quad V_theta (I) := sum_(b in A(I)) #pol($b$, $I$) Q_theta (I, b), quad A_theta (I, a) := Q_theta (I, a) - V_theta (I).
$
The advantage measures how much better $a$ is than our current average behavior at $I$. Taking $b = V_theta$ in @thm-baseline and conditioning on each decision, the policy gradient can be rewritten with advantages in place of payoffs:
$
  grad_theta J = EE_(tau ~ P_theta)[sum_((I, a) in sigma(tau)) A_theta (I, a) #score($a$, $I$)].
$
Actions that do better than expected get reinforced, and actions that do worse get suppressed. In @ex-reinforce-pennies, the baseline $V_theta = 10$ would remove the offset entirely.

The advantage is unknown, so we approximate it with a second learned model, called the _critic_, which may predict $A_theta$ itself or the values $V$ and $Q$ from which it is computed. The policy $pi_theta$ that the critic helps train is called the _actor_ #citep(<konda2000actor>). For instance, a network $V_phi$ can be trained on the same self-play data to predict the final payoff,
$
  min_phi EE_(tau ~ P_theta)[sum_((I, a) in sigma(tau)) (V_phi (I) - R(tau))^2],
$
while the actor is updated with the advantage estimates $R(tau) - V_phi (I)$ in place of $R(tau)$. The critic can be a separate network or a second "head" on a trunk shared with the policy. Either way, one model decides how to act and the other judges how good those decisions were. A critic can go one step further and _bootstrap_, estimating $Q_theta (I, a)$ from its own prediction at the next information set instead of waiting for the end of the episode. This lowers variance further but introduces bias whenever the critic is inaccurate.

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
  Policy gradient and CFR are closer relatives than they first appear. With one logit $z(I, a)$ per information set and action in a perfect-recall game, a direct calculation gives
  $
    (partial J) / (partial z(I, a)) = P_theta (I) dot #pol($a$, $I$) dot A_theta (I, a),
  $
  where $P_theta (I)$ is the probability that play reaches $I$. Factoring $P_theta (I)$ into our own reach probability and the reach probability $w_(-i)(I)$ of the opponents and chance, the product $w_(-i)(I) A_theta (I, a)$ is exactly the instantaneous counterfactual regret of action $a$ at $I$ that drives #lecture-link("learning_efg", <sec-cfr>)[CFR]. So an actor-critic update at $I$ is driven by the same comparison of an action against the current average that CFR uses, with the extra factor of our own reach probability and $pi_theta (a mid(|) I)$ #citep(<srinivasan2018actor>). Abandoning the sequence form, then, left us closer to the game-theoretic algorithms than the change of representation might suggest.
] <rem-cfr-connection>

#exercise[
  Verify the formula in @rem-cfr-connection. _Hint:_ only the terminal nodes below $I$ depend on $z(I, a)$, and the derivative of the softmax is $partial pi(a' mid(|) I) \/ partial z(I, a) = pi(a' mid(|) I)(bb(1)[a = a'] - pi(a mid(|) I))$.
]

#solution[
  By perfect recall, each terminal node below $I$ passes through $I$ exactly once, through some action $a'$, and its reach probability factors as $P_theta (I) dot pi(a' mid(|) I) dot P'(tau)$, where $P'(tau)$ collects the probabilities of all moves after $(I, a')$. By definition of $Q_theta$, $sum_(tau "below" (I, a')) P'(tau) R(tau) = Q_theta (I, a')$. Hence
  $
    (partial J) / (partial z(I, a)) = P_theta (I) sum_(a' in A(I)) pi(a' mid(|) I)(bb(1)[a = a'] - pi(a mid(|) I)) Q_theta (I, a') = P_theta (I) pi(a mid(|) I) (Q_theta (I, a) - V_theta (I)),
  $
  using $V_theta (I) = sum_(a') pi(a' mid(|) I) Q_theta (I, a')$.
]

== The RL toolbox <sec-rl-toolbox>

Because reach probabilities factor over our own decisions, and the logarithm turns that factorization into a sum, the machinery developed for single-agent reinforcement learning applies almost as is. All of the following tools are, at heart, different ways of building or reusing gradient estimators.

- *Interpolating between estimators.* $n$-step returns, TD($lambda$), and generalized advantage estimation (GAE) #citep(<schulman2016high>) trade off the unbiased Monte Carlo estimate $R(tau) - V_phi (I)$ (which corresponds to $lambda = 1$) with the lower-variance bootstrapped estimate from the critic (which corresponds to $lambda = 0$).
- *Tolerating slightly stale data.* Proximal policy optimization (PPO) #citep(<schulman2017proximal>) reuses each batch for several gradient steps, correcting with the ratio between the new and the old policy and clipping it, so that the data never drifts too far from on policy.
- *Large batches and normalization.* Averaging over many self-play episodes from both seats and normalizing the advantages within a batch are simple and effective ways to tame variance.

There is one problem the toolbox does not solve. Both players are updating at the same time, and even with exact gradients, simultaneous policy-gradient updates in matching pennies cycle around the equilibrium rather than converging to it. Forcing convergence through regularization is the subject of the next choice. With regularization in place, the approach is very competitive. A large empirical study, spanning more than 7,000 training runs on five benchmark games where exploitability can be measured exactly, found policy gradient methods such as PPO and MMD to be at least as good as NFSP, PSRO, Deep CFR, and the other game-theoretic deep RL methods it compared against #citep(<rudolph2026reevaluating>).

For a thorough treatment of policy gradient and actor-critic methods in the single-agent setting, see #citet(<sutton2018reinforcement>, supplement: [Chapter 13]).

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
