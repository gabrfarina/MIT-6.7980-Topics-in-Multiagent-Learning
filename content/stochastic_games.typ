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
        + pick an arbitrary Nash equilibrium $pi \( dot.op \| s \, t \) in Delta \( A \)$ of the normal-form game with the above utility functions; #label("algorithm step: pick Nash in backwards induction")
        + set $V_(i \, t) \( s \) = EE_(a ~ pi \( dot.op \| s \, t \)) \[ U_(i \, t \, s) \( a \) \] .$ #label("algorithm step: continuation values")
  ]

  To argue the correctness of the above algorithm, one proceeds as follows.  Suppose that $pi \( dot.op \| s \, t \) = \( pi_1 \( dot.op \| s \, t \) \, ... \, pi_m \( dot.op \| s \, t \) \)$ are the Nash equilibrium strategies picked in Step~#link(label("algorithm step: pick Nash in backwards induction"))[2.2.2] of the algorithm for all $s \, t$. For each player $i$, define a Markovian policy $pi_i : S times { 0 \, ... \, H - 1 } -> Delta (A_i)$ as follows:

  $ pi_i \( s \, t \) \( dot.op \) := pi_i \( dot.op \| s \, t \) . $

  We claim that the collection of policies $\( pi_1 \, ... \, pi_m \)$ is a Nash equilibrium of the game in Markovian policies. The Markovianity of the policies is clear from the definition of this policies in a backwards induction manner.

  So all we need to prove is that $pi_i$ is a best-response to $pi_(- i)$. This can be shown inductively. The base case is arguing that, for each $s$, the distribution $pi_i \( s \, H - 1 \)$ is optimal for player $i$ to use, if he finds himself at state $s$ at time $H - 1$, given the policies of the other players. This follows immediately by the Nash equilibrium conditions satisfied by $pi \( dot.op \| s \, H - 1 \)$. The inductive hypothesis is that policy

  $ pi_i^(>= t + 1) := \( pi_i \( s \, tau \) \( dot.op \) \)_(s in S \, tau >= t + 1) \, $

  is optimal for player $i$ to continue the game with against the policies of the other players if the player finds himself at some state $s$ at  time $t + 1$. The induction step is showing that under the induction hypothesis, $pi_i^(>= t)$ is optimal for continuing the game with against the policies of the other players if the player finds himself at some state $s$ at  time $t$. To show the inductive step we will use the definition of the game in Step~#link(label("algorithm step: game definition"))[2.2.1] of the algorithm and the Nash equilibrium properties of the strategies picked in Step~#link(label("algorithm step: pick Nash in backwards induction"))[2.2.2]. We leave the complete details to the reader.
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
]

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

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
