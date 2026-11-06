#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: "S6",
  date: [Fall 2026],
  title: "Markov (aka stochastic) games",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

In this lecture, we turn our attention to _Markov games_, also known as _stochastic games_. These are an expressive family of games which has become especially popular recently as a mathematical model underlying multi-agent reinforcement learning. Markov games capture strategic interactions that take place over a number of rounds or perhaps an infinite number of rounds, in some environment whose state is influenced by the actions taken by players, and which in turn influences the players' rewards.

= The model

The model of Markov games was introduced in the seminal work of #citet(<shapley1953stochastic>) as a generalization of Markov decision process from the single-agent to the multi-agent setting. In this model, the agents interact with each other and with the environment, and the environment is affected by the joint actions of the agents. In this lecture, we will draw a distinction between _infinite-horizon_ games, and _finite-horizon_ games (also known as _episodic_). We start with the former. While the definition is a mouthful, the model is very natural in its examination.

#definition[Infinite-horizon stochastic game][
  An $m$-player, infinite-horizon, finite state and action _stochastic game_, also called _Markov game_, is a tuple $G = (S \, A \, ℙ \, r \, gamma \, vmu)$ where

  - $S$ is a finite set of states that the environment can be in;
  - $A = A_1 times A_2 times ... times A_m$ is the set of action profiles, where $A_i$ are the actions available to player $i$;
  - $ℙ (s' med \| med s \, a)$, for $s \, s' in S$ and $a in A$ are the transition probabilities of the environment; in particular, $ℙ (s' med \| med s \, a)$ is the probability that the state of the environment becomes $s'$ if action profile $a in A$ is taken by the players in some state $s$;
  - $r = (r_1 \, ... \, r_m)$ is a tuple of reward functions, where $r_i (s \, a)$ specifies the immediate reward received by player $i$ when the action profile $a in A$ is taken by the players in some state $s$;
  - $gamma in lr([0 \, 1))$ is the discount factor; and
  - $vmu in Delta \( S \)$ is the initialization distribution, sampling the state $s^(\( 0 \))$ of the environment at the beginning of the interaction.

  Given an infinite state-action sequence $(s^(\( t \)) \, a^(\( t \)))_(t = 0)^oo$, each player derives a _discounted utility_ of

  $ u_i ((s^(\( t \)) \, a^(\( t \)))_t) := sum_(t >= 0) gamma^t dot.op r_i (s^(\( t \)) \, a^(\( t \))) . $

  We will use the convention that $gamma^0 = 1$, when $gamma = 0$.
]#label("def:infinite horizon stochastic game")

As the name suggests, an infinite-horizon stochastic game is played over an infinite number of steps, and there is discounting of future rewards. The goal of each player is to maximize their discounted utility. If the interaction takes place over a finite number of steps, we have a finite-horizon stochastic game, as defined next.

#definition[Finite-Horizon Stochastic Game][
  A _finite-horizon stochastic game_ is defined in terms of the same primitives used to defined an infinite-horizon stochastic game, together with an additional parameter $H in NN$, called the _horizon_, which indicates that the interaction takes place over $H$ steps, indexed $t = 0 \, ... \, H - 1$. Because of the finiteness of the number of steps, the discount factor can now take any value in $\[ 0 \, 1 \]$, i.e.~the value of $gamma = 1$ is acceptable since the discounted utility is a finite sum and therefore cannot diverge. If $gamma = 1$, we say that there is _no discounting_ of future rewards.
]#label("def:finite horizon stochastic game")

= Strategies and Nash Equilibrium

In general, when we think about _strategies_, a.k.a.~_policies_, for players in a stochastic game, we may allow for the possibility that the actions taken at some state $s$ at some time $t$ may depend on the entire trajectory $\( s^(\( tau \)) \, a^(\( tau \)) \)_(tau < t)$ so far. In other words, when left unqualified, the term _policy_ allows for history-dependence and we think of it as a mapping

$ pi_i : S times (S times A)^(*) -> Delta (A_i) \, $

where the asterisk denotes a tuple of arbitrary length representing the history of play up to any point.

When further restrictions are imposed on how the policy can depend on the history, we arrive at two important distinctions.

#definition[Markovian policy][
  A policy is _history-independent_, or _Markovian_, if it only depends on the current state and time. This means that given any two histories of the same length ending in the same current state, the action distribution is the same. In particular, the policy is a function

  $ pi_i : S times NN -> Delta (A_i) . $
]

#definition[Stationary and Markovian policy][
  A policy is _stationary and Markovian_ if it only depends on the current state. In particular, the policy is just a function of the current state

  $ pi_i : S -> Delta (A_i) . $
]

Given a collection of policies $pi_1 \, ... \, pi_m$ for the players of a stochastic game, the expected utility of each player is naturally defined as follows:

$
  u_i \( pi_1 \, ... \, pi_m \) = EE_(s_0 ~ vmu \;\
  forall t > 0 : s^(\( t \)) ~ ℙ (dot.op \| med s^(\( t - 1 \)) \, a^(\( t - 1 \)))\
  forall t >= 0 \, i : med a_i^(\( t \)) ~ pi_i (s^(\( t \)) \, \( s^(\( tau \)) \, a^(\( tau \)) \)_(tau < t))) [sum_(t >= 0) gamma^t r_i \( s^(\( t \)) \, a^(\( t \)) \)] .
$

For the finite-horizon version, truncate the sum at $t=H-1$ and restrict the trajectory to those $H$ stages.

In particular, $u_i \( pi_1 \, ... \, pi_m \)$ is the expected discounted utility of player $i$ under the random trajectory which starts at $s^(\( 0 \)) ~ vmu$ and is sampled by having each player sampling an action from their policy at each state, and having the environment transition according to its dynamics. In terms of these utilities, Nash equilibrium is defined in the natural way as follows. Notice that this  definition generalizes the concept of Nash equilibrium in normal-form games.

#definition[Nash equilibrium][
  A collection of policies $pi = \( pi_1 \, ... \, pi_m \)$ is a _Nash equilibrium_ of a stochastic game iff for all players $i$, for all policies $pi' : S times (S times A)^(*) -> Delta (A_i)$ it holds that

  $ u_i \( pi_i med \; med pi_(- i) \) >= u_i \( pi'_i med \; med pi_(- i) \) . $

  If all strategies $pi_1 \, ... \, pi_m$ are Markovian, the Nash equilibrium is called _Nash equilibrium in Markovian strategies._ Similarly, if all strategies $pi_1 \, ... \, pi_m$ are stationary and Markovian, the Nash equilibrium is called _Nash equilibrium in stationary and Markovian strategies._
]

== Equilibrium from the initial distribution versus Markov perfection
<sec-markov-perfect>

The Nash condition above compares expected utilities from the specified initial distribution $vmu$. It can leave suboptimal behavior in continuations that are never reached at equilibrium. Restricting policies to be Markovian does not resolve this: Markovianity restricts dependence on history, whereas _Markov perfection_ requires optimality in continuation games.

Write $V_(i \, t)^pi \( s \)$ for player $i$'s expected utility when play is started at state $s$ at time $t$ under profile $pi$, with rewards discounted by $gamma^(tau-t)$ at time $tau$. The sum ends at $H-1$ in a finite-horizon game. This starts a new continuation game, even if $s$ originally had probability zero. For a stationary Markovian profile in an infinite-horizon game, the value is independent of $t$ and equals $v_i^pi \( s \)$ defined below.

#definition[Markov-perfect equilibrium][
  A Markovian profile $pi$ is a _Markov-perfect equilibrium_ (MPE) if, for every player $i$, state $s$, and time $t$ at which play can continue,

  $ V_(i \, t)^pi \( s \) >= V_(i \, t)^((pi'_i \, pi_(-i))) \( s \) #h(1em) forall pi'_i . $

  Here $pi'_i$ is any continuation policy, including a history-dependent one; opponents retain their prescribed policies from time $t$ onward. For finite horizons $t=0 \, ... \, H-1$; for infinite horizons $t >= 0$.
] <def-markov-perfect>

Thus MPE requires equilibrium in _every state and time continuation game_.#footnote[For $gamma>0$, this implies subgame perfection on feasible histories, since rescaling continuation utility by $gamma^t>0$ preserves best responses. Our definition also tests state and time pairs absent from the tree rooted at $vmu$. At $gamma=0$, it compares immediate rewards in each newly started continuation; the original initial-time utility ignores every reward after time $0$.] In particular, it implies Nash equilibrium for every initialization distribution: average the condition at $t=0$ over $s ~ vmu$, using

$ u_i \( pi \) = sum_(s in S) vmu(s) V_(i \, 0)^pi \( s \) . $

The converse fails for a specified $vmu$, even for stationary Markovian policies. This is the same issue of behavior outside equilibrium play illustrated in #[
  #show link: it => {
    let body = [the supplementary reading on sequential irrationality]
    if target() != "html" { body = text(fill: blue.darken(40%), body) }
    if it.body == body { it } else { link(it.dest, body) }
  }
  #lecture-link("perfection")]. For a general treatment of MPE, see #citet(<maskin2001markov>).

#example[Nash equilibrium supported by a noncredible threat][
  Let $H=2$, $gamma=1$, $S={s_0 \, s_1 \, z}$, and $vmu(s_0)=1$. At $s_0$, player $1$ chooses Out, giving immediate rewards $(0 \, 2)$ and moving to $z$, or Enter, giving $(0 \, 0)$ and moving to $s_1$. At $s_1$, player $2$ chooses Fight, giving $(-1 \, -1)$, or Accommodate, giving $(1 \, 1)$; either moves to $z$. The other player's action at each state has no effect, and $z$ is absorbing with zero rewards. The stationary profile “always Out, always Fight” is Nash from $vmu$: entering would reduce player $1$'s utility from $0$ to $-1$, while player $2$ cannot affect their payoff when player $1$ stays out. These conclusions hold for arbitrary unilateral policies. However, at $(s_1 \, 1)$, player $2$ improves from $-1$ to $1$ by accommodating, so the profile is not Markov-perfect.
] <ex-nash-not-markov-perfect>

= Nash Equilibrium Existence

== The finite-horizon case
#label("sec:finite horizon Nash existence")

If we are content with non-Markovian strategies, a finite-horizon stochastic game can just be “unrolled” and converted into a #lecture-link("efg_intro", <sec-game-trees>)[perfect-recall extensive-form game], whose Nash equilibrium strategies can be converted to a Nash equilibrium of the stochastic game. In general, this Nash equilibrium will not be in Markovian strategies. However, finite-horizon stochastic games do have Nash equilibria in Markovian strategies, as can be seen by a _backward induction_ argument.

#theorem[
  Every finite-horizon stochastic game with a finite number of states, actions, and players, has a Nash equilibrium in Markovian strategies. More formally, in the setting of Definition~#ref(label("def:finite horizon stochastic game"), supplement: none), there exists a collection of policies $pi_1 \, ... \, pi_m$ where $pi_i : S times { 0 \, ... \, H - 1 } -> Delta (A_i)$ such that

  $ u_i (pi_i \, pi_(- i)) >= u_i (pi'_i \, pi_(- i)) #h(2em) forall i \, pi'_i \, $

  where $pi'_i$ is _any, not necessarily Markovian,_ policy for player $i$.
]#label("thm: nash existence finite horizon stochastic games")

#proofsketch[
  The idea is to solve the game backwards, starting at the end of the horizon and proceeding backwards, down to the first step of the interaction, inductively picking Nash equilibrium strategies for hypothetical games that would start at all possible interaction steps $t$ and all possible states $s$. To compute these Nash equilibrium  strategies inductively, we need, for all $t$ and all $s$, to find Nash equilibrium strategies for a game whose payoff, $U_(i \, t \, s) \( a \)$, for each player $i$, is the immediate reward $r_i \( s \, a \)$ plus the continuation value expected for this player under the inductively computed strategies and the transitions of the environment.

  Below is a Nash equilibrium computation algorithm, whose correctness establishes the existence of Nash equilibrium in Markov policies.

  #[
    #set enum(full: true)
    + #smallcaps[Initialization ($t = H$):]

      + $V_(i \, H) \( s \) = 0$, for all $i \, s$; in particular, the expected continuation value for each player $i$ at each state $s$ at time $t = H$ is $0$, as the game has ended at $t = H$.
    + #smallcaps[Inductive Step (from $t = H - 1$ down to $t = 0$):]

      + Assume already computed expected continuation values $V_(i \, t + 1) : S -> RR$ for each player $i$.
      + For each state $s$:

        + define a game wherein player $i$'s utility is #label("algorithm step: game definition")

          $
            U_(i \, t \, s) \( a \) = r_i \( s \, a \) + gamma EE_(s' ~ ℙ \( dot.op \| s \, a \)) \[ V_(i \, t + 1) \( s' \) \] \;
          $
        + pick an arbitrary Nash equilibrium $(pi_1 (dot.op | s, t), ..., pi_m (dot.op | s, t)) in Delta(A_1) times ... times Delta(A_m)$ of the normal-form game with the above utility functions, and let $pi (a | s, t) := product_i pi_i (a_i | s, t)$ be the distribution over action profiles induced by the players randomizing independently: it is a product distribution, not an arbitrary (correlated) element of $Delta(A)$; #label("algorithm step: pick Nash in backwards induction")
        + set $V_(i \, t) \( s \) = EE_(a ~ pi \( dot.op \| s \, t \)) \[ U_(i \, t \, s) \( a \) \] .$ #label("algorithm step: continuation values")
  ]

  To argue the correctness of the above algorithm, one proceeds as follows.  Suppose that $pi_1 (dot.op | s, t), ..., pi_m (dot.op | s, t)$ are the Nash equilibrium strategies picked in Step~#link(label("algorithm step: pick Nash in backwards induction"))[2.2.2] of the algorithm for all $s \, t$. For each player $i$, define a Markovian policy $pi_i : S times { 0 \, ... \, H - 1 } -> Delta (A_i)$ as follows:

  $ pi_i \( s \, t \) \( dot.op \) := pi_i \( dot.op \| s \, t \) . $

  We claim that the collection of policies $\( pi_1 \, ... \, pi_m \)$ is a Nash equilibrium of the game in Markovian policies. The Markovianity of the policies is clear from the definition of this policies in a backwards induction manner.

  So all we need to prove is that $pi_i$ is a best-response to $pi_(- i)$. This can be shown inductively. The base case is arguing that, for each $s$, the distribution $pi_i \( s \, H - 1 \)$ is optimal for player $i$ to use, if he finds himself at state $s$ at time $H - 1$, given the policies of the other players. This follows immediately by the Nash equilibrium conditions satisfied by $pi \( dot.op \| s \, H - 1 \)$. The inductive hypothesis is that policy

  $ pi_i^(>= t + 1) := \( pi_i \( s \, tau \) \( dot.op \) \)_(s in S \, tau >= t + 1) \, $

  is optimal for player $i$ to continue the game with against the policies of the other players if the player finds himself at some state $s$ at  time $t + 1$. 
  
  The induction step is showing that under the induction hypothesis, $pi_i^(>= t)$ is optimal for continuing the game with against the policies of the other players if the player finds himself at some state $s$ at  time $t$. This can be done by supposing that player $i$ contemplates an alternative policy $pi'_i$, consisting of an alternative action distribution $pi'_i (dot.op | s, t)$ for the current step, and an arbitrary continuation strategy $(pi'_i) ^(>=t+1)$ for the future. The expected total utility of this deviated policy against opponents' fixed policies is:

  $
    U' &= sum_(a_i, a_(- i)) pi'_i (a_i | s, t) pi_(- i) (a_(- i) | s, t) [r_i (s, a_i ) + gamma sum_(s') ℙ (s' | s, a_i) dot u_(i,t+1)((pi'_i)^(>=t+1), pi_(- i)^(>=t+1) | s')] \
    &<= sum_(a_i, a_(- i)) pi'_i (a_i | s, t) pi_(- i) (a_(- i) | s, t) [r_i (s, a_i ) + gamma sum_(s') ℙ (s' | s, a_i) dot u_(i,t+1)(pi_i^(>=t+1), pi_(- i)^(>=t+1) | s')] \
    &= sum_(a_i, a_(- i)) pi'_i (a_i | s, t) pi_(- i) (a_(- i) | s, t) [r_i (s, a_i ) + gamma sum_(s') ℙ (s' | s, a_i) dot V_(i,t+1)(s')] 
  $
  where we have used the inductive hypothesis (on the optimality of $pi_i^(>=t+1)$) in obtaining the inequality, and used the definition of $V_(i,t+1)$ in the last line. Then, according to Step~#link(label("algorithm step: game definition"))[2.2.1] of the algorithm, the bracketed expression is exactly the formula used to define the payoff $U_(i,t,s)(a)$ of the hypothetical local normal-form game at state $s$ and time $t$. Therefore, 

  $
    U' &<= EE_(a_i ~pi'_i (dot.op | s, t), a_(- i) ~ pi_(- i) (dot.op | s, t)) [ U_(i,t,s)(a) ] \
    &<= EE_(a_i ~pi_i (dot.op | s, t), a_(- i) ~ pi_(- i) (dot.op | s, t)) [ U_(i,t,s)(a) ] = u_i (pi_i^(>=t), pi_(- i)^(>=t) | s) = V_(i,t)(s) .
  $
  since, in a Nash equilibrium (as we have selected in Step~#link(label("algorithm step: pick Nash in backwards induction"))[2.2.2]), player $i$ cannot improve their payoff by unilaterally changing their action distribution from $pi_i (dot.op | s,t)$ to $pi'_i (dot.op | s,t)$. Thus, this shows that $pi_i^(>=t)$ is indeed a best response to $pi_(- i)^(>=t)$, concluding the induction step.
]

#remark[
  Backward induction establishes optimality at every state and time, so the constructed profile is Markov-perfect. Its continuation values $V_(i \, t) \( s \)$ equal $V_(i \, t)^pi \( s \)$.
]

Finally, we remark that in finite-horizon games, there typically do not exist Nash equilibria in stationary and Markovian policies, because the best response of a player to the policies of the other players, even if all other players use stationary and Markovian policies, typically depends on the number of interaction steps that remain. In infinite-horizon games, however, equilibria in stationary and Markovian policies do exist, as we show in the next section.

== The infinite-horizon case

#theorem[#citep(<takahashi1964equilibrium>)#citep(<fink1964equilibrium>)][
  Every infinite-horizon stochastic game with a finite number of states, actions, and players, has a Nash equilibrium in stationary, Markovian strategies. In particular, in the setting of Definition~#ref(label("def:infinite horizon stochastic game"), supplement: none), there exists a collection of policies $pi_1 \, ... \, pi_m$ where $pi_i : S -> Delta (A_i)$ such that

  $ u_i (pi_i \, pi_(- i)) >= u_i (pi'_i \, pi_(- i)) #h(2em) forall i \, pi'_i \, $

  where $pi'_i$ is _any, not necessarily stationary and Markovian,_ policy for player $i$.
]

#proof[
  Given a stationary Markov policy profile $pi = (pi_1 \, ... \, pi_m)$ and a player $i in \[ m \]$, we introduce the following notation:

  - $v_i^pi \( s \)$, for $s in S$, is the infinite discounted utility of player $i$ if the game started at state $s$ and all players used policies $pi_1 \, ... \, pi_m$. In symbols,

    #math.equation(
      block: true,
      numbering: "(1)",
      $forall s : v_i^pi \( s \) = underbrace(sum_a r_i \( s \, a \) pi \( a \| s \), =: r_i^pi \( s \)) + gamma sum_(s') v_i^pi \( s' \) underbrace(sum_a pi \( a \| s \) ℙ \( s' \| s \, a \), =: Gamma^pi \( s \, s' \))$.body,
    )#label("eq:player value functions")

    Notice that~#ref(label("eq:player value functions"), supplement: none) is a linear system of equations in the variables $\( v_i^pi \( s \) \)_s$, which we can rewrite more compactly as

    $ (I - gamma Gamma^pi) vv_i^pi = vr_i^pi . $

    We now argue that the matrix $I - gamma Gamma^pi$ is invertible. To see this, note that the matrix $Gamma^pi$ is a row-stochastic matrix:

    $
      sum_(s') Gamma^pi (s \, s') = sum_(s') sum_a pi (a \| s) ℙ (s' \| s \, a) = sum_a pi (a \| s) (sum_(s') ℙ (s' \| s \, a)) = sum_a pi (a \| s) = 1 .
    $

    Since $gamma < 1$ by #ref(label("def:infinite horizon stochastic game")), we have that $I - gamma Gamma^pi$ is _strictly_ diagonally dominant, which implies that $I - gamma Gamma^pi$ cannot be singular. Therefore, the system of equations has a unique solution, which corresponds to

    $ vv_i^pi = (I - gamma Gamma^pi)^(- 1) vr_i^pi . $

    Furthermore, the value vectors $vv_i^pi$ are _continuous_ in the policies $pi$, because the inverse matrix of the non-singular matrix $I - gamma Gamma^pi$ is continuous in the values of the entries, and these are continuous in $pi$.
  - $q_i^pi (s \, a_i)$, for $s in S$ and $a_i in A_i$, is the infinite discounted utility of player $i$ if the game started at state $s$, and players used policies $pi_1 \, ... \, pi_m$, with the only exception that the very first action of player $i$ is set to $a_i$. In symbols,

    $
      q_i^pi (s \, a_i) = sum_(a_(- i)) r_i (s \, a) dot.op pi_(- i) (a_(- i) \| s) + gamma sum_(s') v_i^pi \( s' \) sum_(a_(- i)) pi_(- i) (a_(- i) \| s) dot.op ℙ (s' \| s \, a) .
    $

    Like before, the function $q_i^pi$ is continuous in the policies $pi$, since everything on the right-hand side is continuous, including the $vv_i^pi$ as discussed above. Furthermore,

    #math.equation(
      block: true,
      numbering: "(1)",
      $v_i^pi \( s \) = sum_(a_i) pi_i (a_i \| s) dot.op q_i^pi (s \, a_i) .$.body,
    )#label("eq:linearity between v's and q's")

  We now define a Nash-type function $phi$, analogous to the #lecture-link("nfgs_nash", <def-nash-improvement>)[Nash improvement function for normal-form games], mapping policy profiles to improved policy profiles as follows:

  #math.equation(
    block: true,
    numbering: "(1)",
    $forall i \, s \, a_i : #h(2em) pi'_i (a_i \| s) <- frac(pi_i (a_i \| s) + [q_i^pi (s \, a_i) - v_i^pi \( s \)]^(+), 1 + sum_(a'_i) [q_i^pi (s \, a'_i) - v_i^pi \( s \)]^(+)) .$.body,
  )#label("eq:nash function for Markov games")

  This mapping is continuous over the convex compact set of all stationary Markov policy profiles. Hence, by Brouwer's fixed-point theorem, there exists a fixed point $pi^(*) = phi (pi^(*))$.

  To complete the proof, we need to argue that the fixed point $pi^(*)$ is a Nash equilibrium, that is, for all $i$, $pi_i^(*)$ is a best response to $pi_(- i)^(*)$, even if the best response is computed with respect to arbitrary policies $pi'_i : S times \( S times A \)^(*) -> Delta \( A_i \)$.

  Pick an arbitrary player $i$ and  state $s$. Using the #lecture-link("nfgs_nash", <thm-nash-improvement>)[utility-improvement argument from the Nash existence proof], we infer that

  #math.equation(
    block: true,
    numbering: "(1)",
    $forall a_i in A_i \, #h(2em) v_i^(pi^(*)) \( s \) >= q_i^(pi^(*)) (s \, a_i) .$.body,
  )#label("eq:one state deviations weak")

  Indeed, all that is needed to repeat the argument from Nash's proof is the linearity $v_i^pi \( s \) = sum_(a_i) pi_i (a_i \| s) dot.op q_i^pi (s \, a_i)$ and form of~#ref(label("eq:nash function for Markov games"), supplement: none).

  With this in hand, let us now show that $pi_i^(*)$ is a best response to $pi_(- i)^(*)$ for  player $i$. From the point of view of player $i$, computing a best response to $pi_(- i)^(*)$ amounts to solving a Markov decision process (MDP) with states $S$ and actions $A_i$ and  rewards, transitions given by

  $
          tilde(r) (s \, a_i) & := sum_(a_(- i)) r_i (s \, a) dot.op pi_(- i)^(*) (a_(- i) \| s) \, \
    tilde(ℙ) (s' \| s \, a_i) & := sum_(a_(- i)) ℙ (s' \| s \, a) dot.op pi_(- i)^(*) (a_(- i) \| s) .
  $

  Notice that the $V$-value function induced by policy $pi_i^(*)$ in this MDP, denoted $tilde(V)^(pi_i^(*)) \( s \)$, coincides with $v_i^(pi^(*)) \( s \) \,$ as defined above in the stochastic game, i.e.~

  $ tilde(V)^(pi_i^(*)) \( s \) equiv v_i^(pi^(*)) \( s \) \, forall s . $

  Moreover, #ref(label("eq:linearity between v's and q's")) and #ref(label("eq:one state deviations weak")) together imply that

  $
    forall s in S \, #h(2em) tilde(V)^(pi_i^(*)) \( s \) = max_(a_i) {tilde(r) (s \, a_i) + gamma sum_(s') tilde(V)^(pi_i^(*)) \( s' \) tilde(ℙ) (s' \| s \, a_i)} .
  $

  The previous condition is the Bellman equation for the MDP. From the theory of MDPs, we conclude that $pi_i^(*)$ is an optimal policy in the MDP, even among history-dependent policies. Therefore $pi_i^(*)$ is a best response to $pi_(- i)^(*)$, even among history-dependent policies.
]

#remark[
  The Bellman optimality condition holds at every state. Thus $pi^(*)$ is a stationary Markov-perfect equilibrium, and is Nash for every initialization distribution.
]

== Shapley's theorem for two-player zero-sum Markov games

In this section, we turn our attention to _two-player zero-sum_ stochastic games. These are games where the interests of the two players are strictly opposed, i.e., $r_1 \( s \, a \) = - r_2 \( s \, a \)$ for all states $s$ and action profiles $a$. We typically denote $r \( s \, a \) := r_1 \( s \, a \)$ as the reward for Player 1 (the maximizer) and the cost for Player 2 (the minimizer).

For the remainder of this section, we will focus specifically on the more interesting case of _infinite-horizon_ games. As we discussed in the previous section, finite-horizon games generally do not admit Nash equilibria in stationary Markovian strategies (strategies that depend only on the state, not the time step). In contrast, infinite-horizon games do admit stationary equilibria.

#citet(<shapley1953stochastic>) established a sharp existence result for this setting, showing that these games have a unique _value_. While we have already established that Nash equilibria exist in general-sum Markov games (using Brouwer's fixed-point theorem), the zero-sum setting admits a “simpler” reason for existence. This simplicity translates into better computational guarantees. The existence of equilibrium here is guaranteed not merely by the existence of a fixed point of a continuous map (as in Brouwer), but specifically by the existence of a fixed point of a contraction map.

=== Contraction Mappings and Banach's Theorem

In the general-sum case, Brouwer's theorem guarantees a fixed point exists but provides no recipe for finding it. In contrast, a contraction mapping guarantees that simply _iterating_ the function will converge to the unique fixed point.

#definition[Contraction Mapping][
  Let $\( X \, d \)$ be a complete metric space. A function $T : X -> X$ is called a _$lambda$-contraction_ if there exists a constant $lambda in \[ 0 \, 1 \)$ such that for all $u \, v in X$:

  $ d \( T \( u \) \, T \( v \) \) <= lambda dot.op d \( u \, v \) . $
]

The mathematical engine behind Shapley's result is the following fundamental theorem from analysis.

#theorem[Banach Fixed-Point Theorem][
  Let $\( X \, d \)$ be a non-empty complete metric space and $T : X -> X$ be a $lambda$-contraction. Then:

  #[
    #set enum(full: true)
    + $T$ admits a _unique_ fixed point $x^(*) in X$ (i.e., $T \( x^(*) \) = x^(*)$).
    + For any initial guess $x^(\( 0 \)) in X$, the sequence defined by $x^(\( t + 1 \)) = T \( x^(\( t \)) \)$ converges to $x^(*)$.
  ]
]

#proofsketch[
  The reason contraction maps have fixed points is intuitive: applying the map strictly shrinks the distance between points. Consider the distance between two successive iterates:

  $
    d \( x^(\( t + 1 \)) \, x^(\( t \)) \) = d \( T \( x^(\( t \)) \) \, T \( x^(\( t - 1 \)) \) \) <= lambda dot.op d \( x^(\( t \)) \, x^(\( t - 1 \)) \) .
  $

  By induction, the steps become exponentially smaller: $d \( x^(\( t + 1 \)) \, x^(\( t \)) \) <= lambda^t d \( x^(\( 1 \)) \, x^(\( 0 \)) \) .$ For $k>t$, the triangle inequality bounds $d(x^((k)),x^((t)))$ by $lambda^t d(x^((1)),x^((0)))/(1-lambda)$. Completeness gives a limit $x^*$. Continuity of $T$ implies $T(x^*)=x^*$. If $y^*$ were another fixed point, contraction would give $d(x^*,y^*) <= lambda d(x^*,y^*)$, forcing equality of the points.
]

=== Shapley's Operator

Shapley used this machinery to prove that zero-sum stochastic games have a value. He constructed a contraction mapping over the space of _value functions_ (not strategies). Let $vV in RR^(abs(S))$ be a vector representing the value of the game to Player 1 at each state. We use the infinity norm $norm(vV)_oo = max_s abs(V(s))$.

We define the _Shapley Operator_ (or Bellman Operator) $cal(T) : RR^(abs(S)) -> RR^(abs(S))$ as follows. For a given estimate of future values $vV$, we construct a “local” matrix game at each state $s$ where the payoff for joint action $a$ is the immediate reward plus the discounted future value:

$ Q_(s \, vV) \( a \) := r \( s \, a \) + gamma sum_(s') ℙ \( s' \| s \, a \) V \( s' \) . $

The operator updates the value of state $s$ to be the #lecture-link("correlated", <sec-zero-sum>)[minimax value] of this local game:

$
  \( cal(T) vV \) \( s \) := max_(vpi_1 in Delta \( A_1 \)) min_(vpi_2 in Delta \( A_2 \)) EE_(a ~ \( vpi_1 \, vpi_2 \)) \[ Q_(s \, vV) \( a \) \] .
$

#theorem[Shapley's Minimax Theorem][
  The operator $cal(T)$ is a contraction mapping with modulus $gamma$. That is, $norm(cal(T) vU - cal(T) vV)_oo <= gamma norm(vU - vV)_oo$. Consequently, there exists a unique value vector $vV^(*)$ such that $cal(T) vV^(*) = vV^(*)$. This $vV^(*)$ is the value of the stochastic game.
]#label("thm: shapley's minimax theorem")

#proofsketch[
  The proof relies on the fact that the value of a zero-sum matrix game is _non-expansive_ with respect to its payoffs (if payoffs change by $delta$, the value changes by at most $delta$). Here, if future values $vU$ and $vV$ differ by $epsilon.alt$, the payoffs in the local matrix games differ by at most $gamma epsilon.alt$. Thus, the values of these local games differ by at most $gamma epsilon.alt$.

  At the fixed point, choose a saddle pair in each local matrix game. Fixing either player's policy gives the other player a discounted MDP. Its optimal Bellman operator fixes $vV^*$ because the chosen local strategies are a saddle pair. Uniqueness of the MDP value therefore shows that these stationary policies secure $vV^*$ against arbitrary history-dependent opponents. This proves the value and equilibrium assertions, as well as the contraction claim.
]

=== Computation: value iteration and a stopping certificate

Value iteration starts from $vV_0=0$ and computes $vV_(t+1)=cal(T)vV_t$. Each step solves one matrix game per state. To extract policies with a specified equilibrium error, we need to relate the Bellman residual to deviation gains.

#theorem[Residual certificate for an approximate equilibrium][
  Let $vV$ be any value vector and choose a saddle pair $pi=(pi_1,pi_2)$ in every local matrix game $Q_(s,vV)$. Set
  $ rho=norm(cal(T)vV-vV)_oo. $
  The resulting stationary profile is a $2 rho/(1-gamma)$-Nash equilibrium from every initial state, for the unnormalized discounted utilities used in this lecture.
]
#proof[
  Let $cal(T)_pi$ be the affine Bellman operator obtained by fixing both policies. Let $cal(T)_1$ be the maximizing player's best-response operator with $pi_2$ fixed, and $cal(T)_2$ the minimizing player's best-response operator with $pi_1$ fixed. The local saddle conditions give
  $ cal(T)_pi vV = cal(T)_1 vV = cal(T)_2 vV = cal(T)vV. $
  All three operators are $gamma$-contractions. For any contraction $F$ with fixed point $vw$,
  $ norm(vw-vV)_oo <= gamma norm(vw-vV)_oo + norm(F vV-vV)_oo. $
  Thus its fixed point lies within $rho/(1-gamma)$ of $vV$. Applied to the three operators, this bounds the profile value and both best-response values. Their pairwise differences are at most $2 rho/(1-gamma)$, which bounds either player's unilateral gain. Discounted MDP optimality includes history-dependent deviations.
]

A concrete algorithm is therefore:

1. Set $vV=0$.
2. For each state, solve $Q_(s,vV)$, retaining its value $W(s)$ and saddle strategies $pi_1(s),pi_2(s)$.
3. If $norm(vW-vV)_oo <= epsilon.alt(1-gamma)/2$, return the retained policies.
4. Otherwise set $vV=vW$ and repeat.

The returned policies are those computed from the same $vV$ whose residual was tested. The proof also handles $gamma=0$ without dividing by $gamma$. If the stage games are solved numerically, their optimization errors must be included in the residual and best-response bounds; the displayed certificate assumes exact local solutions.

=== Discount dependence and computational complexity

Suppose $|r(s,a)| <= R$ and $0<gamma<1$. Contraction implies
$ norm(vV_(t+1)-vV_t)_oo <= gamma^t norm(vV_1-vV_0)_oo <= gamma^t R. $
Consequently the stopping criterion is met once $gamma^t R <= epsilon.alt(1-gamma)/2$. For fixed $R>0$, the number of iterations is bounded by
$ 1 + O(frac(1, 1-gamma) log max{1, frac(2R, epsilon.alt(1-gamma))}). $
Each iteration solves $|S|$ matrix games. This is an arithmetic/optimization bound; bit complexity also accounts for rational input lengths and the precision of the local solves. If $1-gamma$ is exponentially small in its binary encoding length, this iteration bound is not polynomial in the input length.

Changing the discount factor changes the problem, and cannot in general remove this dependence. For example, a one-state game with reward $1$ at every step has value $1/(1-gamma)$. Replacing $gamma=0.9999$ by $1-epsilon.alt$ with $epsilon.alt=0.01$ changes the value from $10,000$ to $100$. There is no $O(epsilon.alt)$ approximation of these unnormalized values. Such a substitution also needs a separate policy-transfer argument before it can certify an equilibrium of the original game.

The computational comparisons should therefore be made with their models specified:

- A rational two-player zero-sum normal-form game can be solved exactly by linear programming in polynomial bit complexity.
- For finite discounted two-player zero-sum Markov games, the value-iteration guarantee above depends on $1/(1-gamma)$ as well as the requested accuracy. Banach's theorem supplies this quantitative convergence argument, not a discount-independent polynomial bound.
- General-sum two-player normal-form Nash computation is PPAD-complete #citep(<chen2009settling>). For more players, exact algebraic solutions and approximate equilibria must be distinguished #citep(<etessami2010fixedpoints>).

Simple stochastic games, studied by #citet(<condon1992stochastic>), form a different model: a turn-based reachability game with maximizing, minimizing, and random vertices. The decision problem belongs to NP intersect coNP. This result is not a claim about strongly polynomial algorithms for arbitrary simultaneous-move discounted Markov games. Here, “polynomial time” counts the binary encoding of numerical data, whereas “strongly polynomial” imposes a stricter arithmetic-operation requirement.

== Example: A small two-state zero-sum game

We conclude this reading by illustrating the concepts of stochastic games and Shapley's theorem with a small example. Consider a scenario where Player 1 (Attacker, Maximizer) attempts to breach a system, while Player 2 (Defender, Minimizer) attempts to prevent this. The system can be in one of two states: $s_1$ (Secure) or $s_2$ (Infiltrated). The players have the following actions and payoffs:

- If the system is in state $s_1$ (Secure):
  - Player 1 can choose to either "Exploit" (E) or "Wait" (W).
  - Player 2 can choose to either "Patch" (P) or "Monitor" (M).
- If the system is in state $s_2$ (Infiltrated):
  - Player 1 can choose to either "Exfiltrate" (X) or "Hide" (H).
  - Player 2 can choose to either "Reboot" (R) or "Scan" (S).

In this two-player zero-sum game, we denote $r(s,a)=r_1 (s,a)$ since $r_2 (s, a) = -r_1 (s, a)$. The transitions and payoffs for player 1 are shown in the following diagram:

#figure[
    #image(
      "figures/stochastic_games/markov_game.svg",
      width: 14cm,
      alt: "A Markov game with two states and two players, illustrating the actions and payoffs for each state.",
    )
  ]

=== Solving the finite-horizon version of the game

The game with a short finite horizon (say, with $H=2, gamma=0.5$) can be solved using value iteration, with the algorithm outlined in Theorem ~#link(label("thm: nash existence finite horizon stochastic games"))[S6.6]. We can start by initializing $V_(i,2) (s) = 0$ at $t=H=2$ for all $s$, and then inductively compute the strategy and value functions for $t=1$ and $t=0$. The resulting strategies will form a Nash equilibrium for the finite-horizon game.

*At $t=1$*, we find that the local bi-matrix game is just the payoffs $U_(i,t=1,s) = r_i (s,a) + gamma EE_(s') [V_(i,2) (s')] = r_i (s,a)$.

- At state $s_1$ (Secure), with $A_1(s_1) = \{E, W\}$ and $A_2(s_1) = \{P, M\}$, the local bi-matrix game is:
  $ U_(t=1, s_1) = mat(
    (-2, +2), (+3, -3);
    (+1, -1), (-1, +1)
  ) $
  Solving for Player 1's optimal mixed strategy $p_1(E) = p$:
  $ (-2)p + (+1)(1-p) = (+3)p + (-1)(1-p) => 1 - 3p = 4p - 1 => p^* = 2/7 $
  The resulting continuation values at $t=1$ are:
  $ V_(1,1)(s_1) = 1/7, quad V_(2,1)(s_1) = -1/7 $

- At state $s_2$ (Infiltrated), with $A_1(s_2) = \{X, H\}$ and $A_2(s_2) = \{R, S\}$, the local bi-matrix game is:
  $ U_(t=1, s_2) = mat(
    (-1, +1), (+4, -4);
    (+2, -2), (-2, +2)
  ) $
  Solving for Player 1's optimal mixed strategy $p_1(X) = p$:
  $ (-1)p + (+2)(1-p) = (+4)p + (-2)(1-p) => 2 - 3p = 6p - 2 => p^* = 4/9 $
  The resulting continuation values at $t=1$ are:
  $ V_(1,1)(s_2) = 2/3, quad V_(2,1)(s_2) = -2/3 $

*At $t=0$*, we incorporate the future continuation values $V_(i,1)(s')$ into the stage game payoffs via $U_(i,0,s)(a) = r_i (s,a) + gamma EE_(s') [V_(i,1)(s')]$ with $gamma = 0.5$:

- At state $s_1$ (Secure):
  $ U_(t=0, s_1) = mat(
    (-2 + 0.5(1/7), +2 - 0.5(1/7)), (+3 + 0.5(2/3), -3 - 0.5(2/3));
    (+1 + 0.5(1/7), -1 - 0.5(1/7)), (-1 + 0.5(1/7), +1 - 0.5(1/7))
  ) = mat(
    (-27/14, +27/14), (+10/3, -10/3);
    (+15/14, -15/14), (-13/14, +13/14)
  ) $
  Equating Player 1's expected payoffs yields $p^* = 84/305$ for playing $E$. The stage values at $t=0$ are:
  $ V_(1,0)(s_1) = 1047/4270 approx 0.245, quad V_(2,0)(s_1) approx -0.245 $

- At state $s_2$ (Infiltrated):
  $ U_(t=0, s_2) = mat(
    (-1 + 0.5(1/7), +1 - 0.5(1/7)), (+4 + 0.5(2/3), -4 - 0.5(2/3));
    (+2 + 0.5(2/3), -2 - 0.5(2/3)), (-2 + 0.5(1/7), +2 - 0.5(1/7))
  ) = mat(
    (-13/14, +13/14), (+13/3, -13/3);
    (+7/3, -7/3), (-27/14, +27/14)
  ) $
  Equating Player 1's expected payoffs yields $p^* = 179/400$ for playing $X$. The stage values at $t=0$ are:
  $ V_(1,0)(s_2) = 14677/16800 approx 0.874, quad V_(2,0)(s_2) approx -0.874 $

=== Solving the discounted infinite-horizon version of the game

In the infinite-horizon discounted setting, continuation values are stationary across time steps. Following Shapley's formulation for two-player zero-sum Markov games (Section S6.3.3), we track a single value vector $vV in bb(R)^(|S|)$ representing Player 1's expected payoff (with Player 2's value defined implicitly as $-vV$).

We update $vV$ iteratively using the Shapley operator $cal(T) : bb(R)^(|S|) -> bb(R)^(|S|)$, defined for each state $s in S$ as:
$ Q_(s, vV)(a) := r(s,a) + gamma sum_(s') bb(P)(s'|s,a) V(s') $
$ (cal(T) vV)(s) := max_(pi_1 in Delta(A_1(s))) min_(pi_2 in Delta(A_2(s))) EE_(a ~ (pi_1, pi_2)) [ Q_(s,vV)(a) ] $

*Iteration 0 ($t=0$):* Initialize Player 1's value vector to zero: $vV_0 = vec(0, 0)$.

*Iteration 1 ($t=1$):* Compute $V_1 = cal(T) vV_0$. Because $vV_0 = 0$, $Q_(s, vV_0)(a) = r(s,a)$:

- At state $s_1$: $Q_(s_1, vV_0) = mat(-2, +3; +1, -1)$. Solving for the minimax value yields $(cal(T) vV_0)(s_1) = 1/7$.

- At state $s_2$: $Q_(s_2, vV_0) = mat(-1, +4; +2, -2)$. Solving for the minimax value yields $(cal(T) vV_0)(s_2) = 2/3$.

- Thus, altogether we have $vV_1 = vec(1/7, 2/3) approx vec(0.143, 0.667)$.

*Iteration 2 ($t=2$):* Now we can compute $vV_2 = cal(T) vV_1$. Constructing the local payoff matrices $Q_(s, vV_1)(a)$ with $gamma = 0.5$ gives us, in each state:

- At state $s_1$:
  $ Q_(s_1, vV_1) = mat(
    -2 + 0.5(1/7), +3 + 0.5(2/3);
    +1 + 0.5(1/7), -1 + 0.5(1/7)
  ) = mat(
    -27/14, +10/3;
    +15/14, -13/14
  ) approx mat(
    -1.929, +3.333;
    +1.071, -0.929
  ) $
  Solving for the minimax value of $Q_(s_1, vV_1)$ gives $(cal(T) vV_1)(s_1) = 1047/4270 approx 0.245$.

- At state $s_2$:
  $ Q_(s_2, vV_1) = mat(
    -1 + 0.5(1/7), +4 + 0.5(2/3);
    +2 + 0.5(2/3), -2 + 0.5(1/7)
  ) = mat(
    -13/14, +13/3;
    +7/3, -27/14
  ) approx mat(
    -0.929, +4.333;
    2.333, -1.929
  ) $
  Solving for the minimax value of $Q_(s_2, vV_1)$ gives $(cal(T) vV_1)(s_2) = 14677/16800 approx 0.874$.

This yields $vV_2 = cal(T) vV_1 approx vec(0.245, 0.874)$. By Shapley's Minimax Theorem (Theorem #link(label("thm: shapley's minimax theorem"))[S6.10]), $cal(T)$ is a $gamma$-contraction mapping under the supremum norm $||vV||_oo = max_s |vV(s)|$, guaranteeing that value iteration $vV_(t+1) = cal(T) vV_t$ converges exponentially to the unique fixed point $vV^* = cal(T) vV^*$.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)