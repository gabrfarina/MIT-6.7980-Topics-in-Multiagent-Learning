#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games: introduction",
  instructor: [Weiqiang Zheng],
)

= Why non-concave games? <sec-l17-intro>

Almost every game we have studied so far had a hidden convexity built in. In a normal-form game, a player's expected utility is _linear_ in their own mixed strategy; in the online convex optimization setting, losses are convex in the learner's decision. This structure is what powered the existence theorems and the efficient learning algorithms of the previous lectures.

Many multiagent problems arising in machine learning do not have this structure. When a player's strategy is the parameter vector of a neural network (as for the generator and discriminator of a generative adversarial network, the attacker and defender in adversarial training, or the policies of agents in multi-agent reinforcement learning), the player's utility is typically far from concave in their own strategy. Daskalakis (2022) frames understanding such games as a central challenge for game theory, and asks: is there a theory of non-concave games, and which solution concepts are _meaningful, universal, and tractable_? This lecture develops one answer.

#remark[Concave utilities, convex losses][
  We follow the game-theoretic convention that players _maximize_ utilities. A utility that is concave in a player's own strategy is the same as a loss that is convex in it, so "non-concave games" (stated in terms of utilities) and "nonconvex games" (stated in terms of losses) refer to the same class of games.
]

== The setting <sec-l17-setting>

#definition[Smooth game][
  A _smooth game_ consists of $n$ players $[n] = {1, ..., n}$. Each player $i$ chooses a strategy $vx_i$ from a nonempty, convex, compact set $cX_i subset.eq RR^(d_i)$ with diameter at most $D_i$. Writing $cX := cX_1 times ... times cX_n$ for the set of strategy profiles, player $i$ receives utility $u_i : cX -> [0, 1]$. We assume that each $u_i$ is $G$-Lipschitz and $L$-smooth (that is, its gradient is $L$-Lipschitz) in $vx_i$.

  The game is _concave_ if, for every player $i$ and every $vx_(-i)$, the function $vx_i |-> u_i (vx_i, vx_(-i))$ is concave. Otherwise, it is _non-concave_.
]

Notice what the definition does _not_ change: the strategy sets $cX_i$ are still convex. The only difference from the concave setting is the shape of the utilities. The smoothness parameter $L$ will play a central role later in the lecture, since it controls how well a utility is approximated by its linearization over a small neighborhood.

Normal-form games are a special case of concave games: if $cX_i = Delta(A_i)$ is a simplex of mixed strategies, then $u_i$ is multilinear, and in particular linear in $vx_i$. So everything in this lecture applies to them as well, but the interesting phenomena appear only when concavity fails.

= What breaks without concavity <sec-l17-what-breaks>

Recall the #lecture-link("nfgs_nash", <def-nash-equilibrium>)[Nash equilibrium]: a profile $vx^* in cX$ such that, for every player $i$ and every $vx_i in cX_i$,
$
  u_i (vx^*) >= u_i (vx_i, vx^*_(-i)).
$
In concave games, a Nash equilibrium always exists (Debreu 1952; Rosen 1965). The proof applies Kakutani's fixed-point theorem to the best-response correspondence, and concavity is exactly what makes each player's set of best responses convex. Without concavity, that step fails, and so can the conclusion.

#example[A smooth game without a Nash equilibrium][
  Let $n = 2$ and $cX_1 = cX_2 = [0, 1]$, with
  $
    u_1 (x_1, x_2) = (x_1 - x_2)^2, quad u_2 (x_1, x_2) = -(x_1 - x_2)^2.
  $
  Player 1 wants to be far from Player 2, and Player 2 wants to be close to Player 1. The utilities are smooth, and $u_2$ is concave in $x_2$, but $u_1$ is _convex_ in $x_1$.

  Suppose $(x_1^*, x_2^*)$ were a Nash equilibrium. Player 2's unique best response is to match Player 1, so $x_2^* = x_1^*$, and Player 1's utility is $0$. But Player 1 can then move to whichever endpoint of $[0, 1]$ is farther from $x_2^*$, which is at distance at least $1\/2$, and obtain utility at least $1\/4 > 0$. This contradicts the equilibrium condition, so no Nash equilibrium exists.

  Note that Player 1's best responses always lie at the endpoints $0$ and $1$: the best-response set is ${1}$ when $x_2 < 1\/2$, ${0}$ when $x_2 > 1\/2$, and ${0, 1}$ when $x_2 = 1\/2$. That last set is not convex, which is precisely where the Kakutani argument breaks.
]

== Randomization restores existence, but not tractability <sec-l17-randomization>

The standard remedy is to let players randomize. By Glicksberg's theorem (Glicksberg 1952), every game with compact strategy sets and continuous utilities has a mixed Nash equilibrium, in which each player draws $vx_i$ from a distribution over $cX_i$. In the example above, one such equilibrium has Player 1 choosing $0$ or $1$ with probability $1\/2$ each, while Player 2 plays $x_2 = 1\/2$. (Check: against $x_2 = 1\/2$, no $x_1$ earns more than $1\/4$, and both endpoints earn exactly $1\/4$; against Player 1's coin flip, Player 2's expected loss $(x_2^2 + (1 - x_2)^2)\/2$ is minimized at $x_2 = 1\/2$.)

Allowing correlation weakens the solution concept further. The inclusions familiar from #lecture-link("correlated", <sec-cce>)[correlated and coarse correlated equilibria] carry over, now with distributions over the continuous set $cX$:
$
  "NE" subset.eq "mixed NE" subset.eq "CE" subset.eq "CCE".
$
Since mixed Nash equilibria exist, so do correlated and coarse correlated equilibria. The trouble is computational. These equilibria are distributions over continuous strategy spaces, which in general may require infinite support (Cai et al. 2024), and computing them is hard even for the weakest notion, CCE.

To see why, consider the extreme case of a single player ($n = 1$) with a smooth, non-concave utility $u$. A CCE is then a distribution $sigma in Delta(cX)$ satisfying
$
  EE_(vx ~ sigma) [u(vx)] >= max_(vx' in cX) u(vx'),
$
which forces $sigma$ to be supported on global maximizers of $u$. Similarly, any $epsilon$-approximate CCE contains in its support a point $vx$ with $u(vx) >= max_(vx') u(vx') - epsilon$. So computing a CCE is at least as hard as globally maximizing a smooth non-concave function, which is #NP\-hard in general and requires exponentially many queries for algorithms that only access $u$ and its gradient.

Concave games are a different story. There, if every player runs a no-regret algorithm such as online gradient ascent, the empirical distribution of play converges to a CCE at rate $O(1 \/ sqrt(T))$ #lecture-link("learning_intro", <sec-phi-regret>)[by the regret-to-equilibrium connection], so an $epsilon$-approximate CCE can be computed in time polynomial in the dimension and $1\/epsilon$. Concavity is exactly what lets a gradient step certify global progress; without it, the gradient only carries _local_ information.

== Local Nash equilibrium is not an easy fix either <sec-l17-local-preview>

Since gradients only see local information, intuition would be to ask only for _local_ stability: a profile from which no player can gain much by moving a small distance $delta$. Such local Nash equilibria do exist when the required stability is weak enough, but computing them is still intractable in general: for two-player zero-sum smooth games, finding an approximate local min-max point is #PPAD\-complete (Daskalakis, Skoulakis, and Zampetakis 2021). We return to local solution concepts, and to where the boundary of tractability lies, later in this lecture.

== Summary <sec-l17-summary>

@tab-l17-summary summarizes the picture.

#figure(
  {
  set par(justify: false)
  table(
    columns: 3,
    align: (left + horizon, left + horizon, left + horizon),
    inset: .6em,
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
    [*Solution concept*], [*Concave games*], [*Non-concave games*],
    [Nash equilibrium], [Exists (Rosen 1965); #PPAD\-hard even for normal-form games], [May not exist],
    [Mixed NE, CE, CCE], [Exist; CE and CCE are learnable efficiently by no-regret dynamics], [Exist, but may need infinite support; #NP\-hard even for CCE],
    [Local Nash equilibrium], [Coincides with Nash equilibrium], [Exists for weak enough stability; intractable in general],
  )
  },
  caption: [Classical solution concepts in concave and non-concave games.],
) <tab-l17-summary>

Every classical solution concept either fails to exist or is intractable in non-concave games. This motivates the approach taken in the rest of the lecture, which combines the two relaxations above (correlation and restricted deviations) into _local $Phi$-equilibria_. As we will see, this concept becomes efficiently computable right where a gradient step can certify progress, and gradient descent achieves it by minimizing a strong notion of regret called _proximal regret_.

== References <sec-l17-intro-references>

- Weiqiang Zheng, #link("https://www.mit.edu/~6.7980/slides/L17_nonconvex_games.pdf")[Nonconvex Games]. MIT 6.7980, Lecture 17, pp. 1–4.
- Constantinos Daskalakis, #link("https://cowles.yale.edu/sites/default/files/2022-10/nonconvex-games-non-concave-utilities-and-machine-learning.pdf")[Non-Concave Games: A Challenge for Game Theory's Next 100 Years], 2022.
- Gérard Debreu, #link("https://doi.org/10.1073/pnas.38.10.886")[A Social Equilibrium Existence Theorem], _PNAS_ 38(10), 1952.
- J. B. Rosen, #link("https://doi.org/10.2307/1911749")[Existence and Uniqueness of Equilibrium Points for Concave $N$-Person Games], _Econometrica_ 33(3), 1965.
- I. L. Glicksberg, #link("https://doi.org/10.1090/S0002-9939-1952-0046638-5")[A Further Generalization of the Kakutani Fixed Point Theorem, with Application to Nash Equilibrium Points], _Proceedings of the AMS_ 3(1), 1952.
- Yang Cai, Constantinos Daskalakis, Haipeng Luo, Chen-Yu Wei, and Weiqiang Zheng, #link("https://arxiv.org/abs/2403.08171")[On Tractable $Phi$-Equilibria in Non-Concave Games], NeurIPS 2024.
- Constantinos Daskalakis, Stratis Skoulakis, and Manolis Zampetakis, #link("https://arxiv.org/abs/2009.09623")[The Complexity of Constrained Min-Max Optimization], STOC 2021.

#changelog[
  - 2026-11-23: Garrett Campagna wrote the introduction to non-concave games, the no-equilibrium example, the discussion of why classical solution concepts become intractable, and the summary table.
]
