#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 3,
  date: [Tue, Sep 22, 2026],
  title: "Properties of Nash equilibrium",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

In this lecture, we will continue analyzing the properties of Nash equilibria in normal-form games. We will then introduce the concept of correlated equilibrium, a relaxation of Nash equilibrium with desirable properties.

= Further properties of the Nash equilibrium

We introduced the #lecture-link("nfgs_nash", <def-nash-equilibrium>)[definition of a Nash equilibrium] in the notes on normal-form games. Recall that a strategy profile is a Nash equilibrium if no player can unilaterally deviate from their strategy to improve their payoff. We also discussed the existence of Nash equilibria in finite games, which is guaranteed by the Brouwer fixed-point theorem.

== Nash equilibrium in two-player zero-sum games <sec-zero-sum>

In two-player zero-sum games the Nash equilibria are exactly those strategy profiles for which both players are playing a maxmin strategy. We formalize this in the next theorem.  First, though, we introduce some notation which will make our life easier when dealing with two-player games.

#definition[Matrices $U_1$ and $U_2$ for two-player games][
  Consider a generic two-player zero-sum game, as shown next. As usual, we denote the sets of actions for player by $A_1$ and $A_2$.

  #align(center)[

    #image("figures/correlated/game_table.svg")
  ]

  Let $vx in Delta (A_1)$ denote a strategy of Player 1, and $vy in Delta (A_2)$ a strategy of Player 2. We can express the expected utilities for the players according to the bilinear expressions

  $ u_1 (vx \, vy) = vx^top U_1 vy \, #h(2em) #h(2em) u_2 (vx \, vy) = vx^top U_2 vy \, $

  where

  $
    U_1 := mat(delim: "(", a_11, a_12, dots.h.c, a_(1 m); a_21, a_22, dots.h.c, a_(2 m); dots.v, dots.v, dots.down, dots.v; a_(n 1), a_(n 2), dots.h.c, a_(n m)) \, quad U_2 := mat(delim: "(", b_11, b_12, dots.h.c, b_(1 m); b_21, b_22, dots.h.c, b_(2 m); dots.v, dots.v, dots.down, dots.v; b_(n 1), b_(n 2), dots.h.c, b_(n m)) .
  $
]

From now on, we will assume that a two-player game has been defined, and we will use the notation with $U_1$ and $U_2$ defined above to refer to the utility matrices of the players.

#theorem[
  Consider a two-player zero-sum game, that is, one for which $U_2 = - U_1$. Then, a strategy profile $(vx^(*) \, vy^(*)) in Delta (A_1) times Delta (A_2)$ is a Nash equilibrium if and only if it is a maxmin strategy, _i.e._, if and only if

  $
    vx^(*) in "arg max"_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy \, #h(2em) upright("and") #h(2em) vy^(*) in "arg max"_(vy in Delta (A_2)) min_(vx in Delta (A_1)) vx^top U_2 vy .
  $
]#label("thm:nash is mm")

#proof[
  We prove the result assuming we trust von Neumann's minimax theorem, which states that

  $
    max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy = min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy .
  $

  $(==>)$~~Suppose that $(vx^(*) \, vy^(*))$ is a Nash equilibrium. Then, by the definition of Nash equilibrium and using the fact that $U_2 = - U_1$, we have that

  $
    (vx^(*))^top U_1 vy^(*) = max_(vx in Delta (A_1)) vx^top U_1 vy^(*) \, #h(2em) upright("and") #h(2em) (vx^(*))^top U_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top U_1 vy .
  $

  Hence, we can write the chain of equalities and inequalities

  $
    min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy <= max_(vx in Delta (A_1)) vx^top U_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top U_1 vy <= max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy .
  $

  By the minimax theorem, all inequalities must be equalities; hence, $(vx^(*) \, vy^(*))$ satisfies

  $
    min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy & = max_(vx in Delta (A_1)) vx^top U_1 vy^(*) & & quad <=> quad vy^(*) in "arg min"_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy\
    max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy & = min_(vy in Delta (A_2)) (vx^(*))^top U_1 vy & & quad <=> quad vx^(*) in "arg max"_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy .
  $

  $(<==)$~~Conversely, suppose that $vx^(*)$ and $vy^(*)$ are maxmin strategies. Let $v^(*)$ be the common value of both sides of the minimax theorem, that is,

  $
    v^(*) := max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy = min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy .
  $

  We now show that $(vx^(*) \, vy^(*))$ is a Nash equilibrium. By definition, this means we need to show that

  $
    (vx^(*))^top U_1 vy^(*) = max_(vx in Delta (A_1)) vx^top U_1 vy^(*) & #h(2em) upright("and") #h(2em) (vx^(*))^top U_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top U_1 vy .
  $

  Using the hypothesis,

  $
    vx^(*) & in "arg max"_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy \, quad & & ==> quad v^(*) = min_(vy in Delta (A_2)) (vx^(*))^top U_1 vy \,\
    vy^(*) & in "arg min"_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top U_1 vy \, quad & & ==> quad v^(*) = max_(vx in Delta (A_1)) vx^top U_1 vy^(*) .
  $

  These equalities imply that $v^(*) <= (vx^(*))^top U_1 vy^(*)$ and $v^(*) >= (vx^(*))^top U_1 vy^(*)$, and thus $v^(*) = (vx^(*))^top U_1 vy^(*)$. This shows that the players are best responding to the strategy of the opponent, completing the proof that $(vx^(*) \, vy^(*))$ is a Nash equilibrium.
]

*Computation*  As we will see shortly, #ref(label("thm:nash is mm")) gives us nontrivial information about the structure of Nash equilibria in two-player zero-sum games. But it also gives us a computational tool. Indeed, the theorem above tells us that finding a Nash equilibrium in a two-player zero-sum game can be expressed as an optimization problem. Let's show that this optimization problem is a linear program. Without loss of generality, let's focus on Player 1's optimization problem, that is,

$ vx^(*) in "arg max"_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top U_1 vy . $

The key insight is that this problem can be rewritten as

$
  cases(max_v v, upright("s.t.") v <= vx^top U_1 ve_(a_2) quad forall a_2 in A_2, upright("") vone^top vx = 1, vx >= 0 .)
$

which is a linear program with a linear number of constraints in the number of actions of Player 2. We can use any linear programming solver to find such a solution. The #lecture-link("learning_intro", <sec-learning-zero-sum>)[self-play construction] gives more scalable methods to compute maxmin strategies from repeated play.

*Connection with linear programming*  It is worth pausing for a moment to appreciate some historical context. We started the proof by assuming von Neumann's minimax theorem, which we justified as a consequence of linear programming duality. However, historically, von Neumann did not have the luxury of linear programming to prove his theorem.

- The proof of von Neumann's minimax theorem essentially hides an optimization duality argument. Indeed, we have the following:

  #align(center)[

    #table(
      stroke: none,
      columns: 3,
      align: center + horizon,
      inset: .7em,
      [$max_(vx in Delta \( A_1 \)) min_(vy in Delta \( A_2 \)) vx^top U_1 vy$],
      [],
      [$min_(vy in Delta \( A_2 \)) max_(vx in Delta \( A_1 \)) vx^top U_1 vy$],

      [$arrow.t.b$], [], [$arrow.t.b$],
      [$ cases(max v, v <= vx^top U_1 ve_(a_2) quad forall a_2, vone^top vx = 1, vx >= 0 .) $],
      [$limits(<-->)^(upright("  linear programming  "))_(upright("duality"))$],
      [$ cases(min w, w >= ve_(a_1)^top U_1 vy quad forall a_1, vone^top vy = 1, vy >= 0 .) $],
    )

  ]
- The connection between linear programming and two-player zero-sum games is bidirectional: as it turns out, _solving linear programming_ and _finding a Nash equilibrium in a two-player zero-sum game_ are _computationally equivalent_. This means that _any_ linear programming problem (with arbitrary constraints, variables, etc.) can be efficiently converted into a two-player zero-sum game. This is less obvious than it may seem. For one, the strategy sets in games are probability simplexes, while linear programs might have arbitrary linear equality and inequality constraints. Furthermore, linear programs might be unbounded or unfeasible; yet, a Nash equilibrium of a game always exists. It would have been perfectly reasonably to believe that linear programming was a significantly more general tool than equilibrium solvers for two-player zero-sum games, and we know today that that belief would have been wrong. For more on this, see #citep(<Brooks2023Oct>, <vonStengel2023Jul>, <adler2013equivalence>).
- All of this seems simple with the luxury of hindsight. But the two fields were not as closely connected as we might think. We know this from a transcript of the first encounter between Dantzig, one of the fathers of linear programming, and von Neumann, one of the fathers of game theory. And, perhaps in what is a plot twist, it was von Neumann to teach Dantzig about duality!

  #quote(block: true)[
    « On October 3, 1947, I visited him (von Neumann) for the first time at the Institute for Advanced Study at Princeton. I remember trying to describe to von Neumann, as I would to an ordinary mortal, the Air Force problem. I began with the formulation of the linear programming model in terms of activities and items, etc. Von Neumann did something which I believe was uncharacteristic of him. “Get to the point,” he said impatiently. Having at times a somewhat low kindlingpoint, I said to myself “O.K., if he wants a quicky, then that's what he will get.” In under one minute I slapped the geometric and algebraic version of the problem on the blackboard. Von Neumann stood up and said “Oh that!” Then for the next hour and a half, he proceeded to give me a lecture on the mathematical theory of linear programs. At one point seeing me sitting there with my eyes popping and my mouth open (after I had searched the literature and found nothing), von Neumann said: “I don't want you to think I am pulling all this out of my sleeve at the spur of the moment like a magician. I have just recently completed a book with Oskar Morgenstern on the theory of games. What I am doing is conjecturing that the two problems are equivalent. The theory that I am outlining for your problem is an analogue to the one we have developed for games.” Thus I learned about Farkas' Lemma, and about duality for the first time.»

    (from #citet(<Dantzig1982Apr>))
  ]
- In light of the above you might be wondering how easy it would be to prove the minimax theorem without relying on linear programming duality. The #lecture-link("learning_intro", <sec-learning-minimax>)[proof using regret minimization] only requires the existence of suitable learning dynamics. The supplementary reading on #lecture-link("eah", <sec-minimax-algorithm>)[constructive minimax] develops a different computational approach.

*Topological properties*  It is important to realize that what #ref(label("thm:nash is mm")) is saying is that in two-player zero-sum games, each player can plan their own strategy _independently_. _Any_ combination of maxmin strategies for the players forms an equilibrium. This is in contrast with the general case: there, in order to specify a Nash equilibrium we need to provide a tuple of strategies for all players. In two-player zero-sum games, instead, _any product of maxmin strategies is an equilibrium_. We have just arrived at the following corollary.

#corollary[
  In a two-player zero-sum game, the set of Nash equilibria is a Cartesian product of nonempty, convex, compact sets.
]#label("cor:nash product")

Since Cartesian products of nonempty, convex, and compact sets are themselves nonempty, convex, and compact, #ref(label("cor:nash product")) immediately implies the following as well.

#corollary[
  The set of Nash equilibria in a two-player zero-sum game is nonempty, convex, and compact.
]

It is worth remarking again that what does the heavy lifting here is really #ref(label("thm:nash is mm")); the rest follows as a direct corollary.

== Nash equilibrium in two-player general-sum games

In the general two-player case, often referred to as _two-player general-sum games_, many of the nice properties of the zero-sum case are lost.

*Topological properties*  Perhaps the most striking is that not only the set of Nash equilibria is no longer guaranteed to be convex, but it is not even guaranteed to be contractible. We show this phenomenon with the next example.

#remark[Complex topology of Nash equilibria; Kohlberg-Mertens game #citep(<kohlberg1986strategic>)][
  Beyond two-player zero-sum games, the set of Nash equilibria in a game can be quite complex.

  #wrapped-figure(side: right, text-width: 55%)[
    For one, _it is not at all guaranteed that the set is convex_. Even more, the set might be _topologically complex_, _e.g._, exhibiting holes.  This phenomenon was already observed by #citet(<kohlberg1986strategic>), who considered the two-player three-action game

    #align(center)[
      #image("figures/correlated/km_game.svg", width: 118.75pt)
    ]

    The figure on the right, similar to the one in #citep(<Milionis2023Oct>), shows the projection of the set of all $0.27$-approximate Nash equilibria of this game, _i.e._, all strategy profiles such that no player has a unilateral deviation that increases their utility by more than $0.27$.
  ][
    #image("figures/correlated/kohlberg_mertens.svg", width: 175.392pt)
  ]
]

*Computation*  In two-player general-sum games, computation of Nash equilibria is not a linear program. However, it is a _linear complementarity problem_ (LCP), a more general class of problems than linear feasibility programs, and which are written in the form

$
  upright("find") quad vx \, vw in bb(R)^d #h(2em) upright("s.t.") #h(2em) vw = M vx + vq \, #h(2em) vx \, vw >= 0 \, #h(2em) vx^top vw = 0 .
$

The Lemke-Howson algorithm is a well-known algorithm to solve LCPs, and it can be used to find Nash equilibria in two-player general-sum games. However, the algorithm is not polynomial-time in the worst case, and it can be hard to find Nash equilibria in practice. An important corollary of the connection between two-player general-sum games and LCPs is the following:

#corollary[
  Any two-player general-sum games with rational payoffs admits a Nash equilibrium with rational coordinates.
]

This follows directly from the way Lemke-Howson works, which is similar to the simplex algorithm. The algorithm moves along edges of a rational polytope until it finds a Nash equilibrium. Since the algorithm only moves along the edges of the polytope, it will only generate rational solutions.

An interesting result about the computation of $epsilon.alt$-approximate Nash equilibria is due to #citet(<LMM03>), and is based on the observation that every game admits an $epsilon.alt$-approximate Nash equilibrium where the strategy of Player 1 is supported on at most $w := O (frac(log \| A_2 \|, epsilon.alt^2))$ strategies. This follows from using a Hoeffding bound on samples from the distribution of Player 1's strategy. One can then check any support for Player 1's strategy of size up to $w$, and for each such support, solve a linear program to verify if a Nash equilibrium with that support exists. This gives a subexponential-time algorithm (of order $O (s^(log s \/ epsilon.alt^2))$, where $s$ is the size of input) for computing an $epsilon.alt$-approximate Nash equilibrium.

== Nash equilibrium in games with more than two players <sec-irrational-equilibria>

In games with more than two players, the behavior of Nash equilibria can be even more problematic.

*Analytic properties*  As a start, _rational numbers might not be enough anymore_ to store the probabilities of each player's actions at equilibrium.

#example[
  In his original paper, Nash showed a three-player game with rational payoffs and with the property that _all_ Nash equilibria prescribe probabilities that are irrational numbers #citep(<Nash51:NonCooperative>). Another simple example is also reported by #citet(<nau2004geometry>), as follows:

  #align(center)[
    #image("figures/correlated/nash_irrational.svg")
  ]

  A simple calculation shows that the only Nash equilibrium $(vx^(*) \, vy^(*) \, vz^(*))$ of this game satisfies

  $
    (x_1^(*) \, y_1^(*) \, z_1^(*)) = (53 / 46 - sqrt(601) / 46 \, - 13 / 24 + sqrt(601) / 24 \, - 23 / 4 + sqrt(601) / 4) approx (0.619 \, 0.480 \, 0.379) .
  $

  From a computational point of view, this property raises the question of how a Nash equilibrium solver could even _represent_ such an output.
]

#proof[
  We know from Lecture 1 that a Nash equilibrium is guaranteed to exist, so we begin by considering the pure-strategy profiles. Checking all 8 possible pure-strategy combinations reveals that, in every case, at least one player can unilaterally deviate and increase their payoff. For example, if the players choose ("Top","Left","Action X"). Player 2 can deviate from Left to Right and increase their payoff from 0 to 2, so this profile cannot be a Nash equilibrium. The same reasoning applies to all 8 pure-strategy profiles.
  
  Since a Nash equilibrium is guaranteed to exist, but no pure-strategy equilibrium exists, the equilibrium must therefore involve mixed strategies. Let Player 1 play Top with probability x, Player 2 play Left with probability y, and Player 3 play Action X with probability z.
  
  For a mixed-strategy Nash equilibrium, each player must be indifferent between the pure actions. In other words, given the mixing probabilities of other players, the expected payoff from each of a player's available actions must be equal. Otherwise, the player could unilaterally deviate to one action to increase their expected payoff. We therefore set the expected payoffs from each player's two actions equal and solve the resulting system of equations for x, y, and z.

  Player 1:
  $
    u_1("Top") = 3"yz" + y(1-z)
  $
  $
    u_1("Bottom") = (1-y)z + 2(1-y)(1-z)
  $
  Equating $u_1("Top") = u_1("Bottom")$ and simplifying yields:
  $
    "yz" + 3y + z - 2 = 0
  $

  Player 2:
  $
    u_2("Left") = z(1-x) + 3(1-z)(1-x) = (1-x)(3-2z)
  $
  $
    u_2("Right") = z(2x) + x(1-z) = x(1+z)
  $
  Equating $u_2("Left") = u_2("Right")$ and simplifying yields:
  $
    "xz" - 4x - 2z + 3 = 0
  $

  Player 3:
  $
    u_3("Action X") = 2"xy"
  $
  $
    u_3("Action Y") = 3(1-x)(1-y)
  $
  Equating $u_3("Action X") = u_3("Action Y")$ and simplifying yields:
  $
    "xy" - 3x - 3y + 3 = 0
  $

  Solving the System of Equations:

  From Player 2's equation:
  $z = (4x-3)/(x-2)$

  From Player 3's equation:
  $y = (3x-3)/(x-3)$

  Substituting these expressions into Player 1's equation:
  $
    ((3x-3)/(x-3))((4x-3)/(x-2)) + 3((3x-3)/(x-3)) + (4x-3)/(x-2) - 2 = 0
  $
  This simplifies to:
  $
    23x^2 - 53x + 24 = 0
  $

  Using the quadratic formula to solve for $x$ gives:
  $
    x = (53 - sqrt(601))/46 approx 0.619
  $
  Substituting this irrational value of $x$ back into the expressions for $y$ and $z$ produces:
  $y = (-13 + sqrt(601))/24 approx 0.480$
  and $z = (-23 + sqrt(601))/4 approx 0.379$
]

#remark[
  The issues with irrational numbers do not stop at square roots. In fact, _any polynomial root_ might be required to represent a Nash equilibrium. This was shown by #citet(<bubelis1979equilibria>), who showed how to construct games with arbitrary polynomial roots.

  Beyond the representation, the topology of Nash equilibria is also in general arbitrarily complex in three-player games. In particular, #citet(<datta2003universality>) showed that for any real algebraic variety, one can come up with some three-player game whose set of fully mixed Nash equilibria is isomorphic to that variety.
]

*Computation*  On the computational side, the situation is even more dire. As a first consideration, because Nash equilibria might require irrational numbers, even the question of how to _represent_ the output equilibrium needs attention. In general, we cannot hope for an _exact_ value. However, even asking for a _constant_ approximation turns out to be hard. We will talk about this in more detail at the end of the course, where we relate the computation of (approximate) Nash equilibria to a complexity class called PPAD.

If one is willing to stomach a worst-case superpolynomial runtime, some methods exist. While the Lemke-Howson algorithm cannot be used beyond two-player games, other methods (such as #citep(<Porter2008Jul>)) still apply.

= Correlated and coarse correlated equilibrium

The discussion above shows that Nash equilibria can be hard to compute and might not form a convex (or even contractible) set. This motivates the study of _correlated equilibria_ #citep(<Aumann1974Mar>) and _coarse correlated equilibria_ #citep(<moulin1978strategically>), which are a relaxation of Nash equilibria that are easier to compute, always form a convex set, and for which rational solutions always exist. As we will show starting in a few lectures, another major advantage of correlated equilibria is that they can be learned from repeated play, in a way that is fundamentally incompatible with Nash equilibria.#footnote[A paradigm that has been successful in applications is to learn a correlated equilibrium from repeated play, and then marginalize it into a profile that is hoped to be close to a Nash equilibrium. This was used for example to reach superhuman performance in multiplayer poker #citep(<Brown2019Aug>).]

== Coarse correlated equilibrium <sec-cce>

Remember that in a Nash equilibrium we are seeking a strategy profile $(vx_1 \, ... \, vx_n) in Delta (A_1) times dots.h.c times Delta (A_n)$ such that no player can unilaterally deviate to improve their payoff, that is,

$ u_i (a'_i \, vx_(- i)) <= u_i (vx_i \, vx_(- i)) #h(2em) forall i in \[ n \] \, a'_i in A_i . $

Here, $u_i$ was defined as the expected payoff when all the players randomize _independently_.

The concept of _coarse correlated equilibrium_ is a relaxation of this definition. In a coarse correlated equilibrium, instead of asking for the players to pick _independent_ strategies, we allow coordination. In particular, we define the following.

#definition[Coarse correlated equilibrium #citep(<moulin1978strategically>)][
  A _coarse correlated equilibrium (CCE)_ is a correlated strategy $vmu in Delta (A_1 times ... times A_n)$ such that

  #math.equation(
    block: true,
    numbering: "(1)",
    $bb(E)_((a_1 \, ... \, a_n) ~ vmu) [u_i (a'_i \, a_(- i))] <= bb(E)_((a_1 \, ... \, a_n) ~ vmu) [u_i (a_1 \, ... \, a_n)] #h(2em) forall i in \[ n \] \, a'_i in A_i .$.body,
  ) <eq:cce>
] <def-cce>

#remark[
  The definition of a CCE is a relaxation of the definition of a Nash equilibrium. In a Nash equilibrium, the players randomize independently; in a CCE, they can randomize in a correlated way. _A Nash equilibrium is a CCE $vmu$ that happens to be a product distribution_, that is, $vmu = vx_1 ⊗ dots.h.c ⊗ vx_n .$

  This shows that the set of CCEs is a superset of the set of Nash equilibria. Thus, a coarse correlated equilibria always exists in every game.
]

*Properties and computation*  We can turn @def-cce into an optimization problem. The variables are the entries of the probability distribution $vmu$. This is a $(A_1 times dots.h.c times A_n)$-dimensional nonnegative vector whose entries must satisfy the linear equality constraint

$ sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) = 1 . $

Furthermore, expanding the expectation in inequality #ref(<eq:cce>, supplement: none) defines a set of linear constraints

$
  sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) u_i (a'_i \, a_(- i)) <= sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) u_i (a_i \, a_(- i))
$

for all $i in \[ n \]$ and $a'_i in A_i$.
Hence, the set of CCEs is the intersection of a finite set of linear constraints, and so it is a convex polytope. Note that the number of constraints is polynomial in the game (_i.e._, in the size of the payoff table), and so we can use linear programming to compute and even optimize over the set of CCEs in time polynomial in $\| A_1 \| times ... times \| A_n \|$.

#corollary[
  Since the coefficients of the linear constraints are the payoffs of the game, the set of CCEs is always a rational polytope.
]

It is worth knowing that a CCE can also be computed in polynomial time in imperfect-information sequential games, despite the number of "actions" there, which is the number of strategies in the tree, is exponential in the input. Unfortunately, we lose the ability to optimize over the set.

#exercise[Marginals of CCE in Two-Player Zero-Sum Games][
  Consider a two-player zero-sum game. Let $mu in Delta(A_1 times A_2)$ be a coarse correlated equilibrium (CCE). Let $x in Delta(A_1)$ and $y in Delta(A_2)$ be the marginal strategies of $mu$, defined by:

  $
    x(a_1) = sum_(a_2 in A_2) mu(a_1, a_2) quad "and" quad y(a_2) = sum_(a_1 in A_1) mu(a_1, a_2).
  $
  Prove that the strategy profile $(x, y)$ is a Nash equilibrium, and therefore $x$ and $y$ are maxmin strategies. Furthermore, contrast this with marginalization in general-sum games.
]

#solution[
  Let $v$ be the expected utility of Player 1 under the joint CCE distribution $mu$. Because the game is zero-sum, Player 2's expected utility under $mu$ is $-v$. By the definition of a CCE, Player 1 cannot strictly improve their expected utility by unilaterally deviating to any fixed action $a_1 ' in A_1$. We can write Player 1's expected utility for this deviation as:

  $
    & sum_(a_1 in A_1) sum_(a_2 in A_2) mu(a_1, a_2) u_1(a_1 ', a_2) <= v\
    <=> quad & sum_(a_2 in A_2) [sum_(a_1 in A_1) mu(a_1, a_2)] u_1(a_1 ', a_2) <= v\
    <=> quad & sum_(a_2 in A_2) y(a_2) u_1(a_1 ', a_2) <= v.
  $

  This is exactly the expected utility for Player 1 playing $a_1 '$ against Player 2's marginal strategy $y$. Therefore,

  $
    u_1(a_1 ', y) <= v quad forall a_1 ' in A_1.
  $

  Similarly, the CCE definition ensures Player 2 cannot improve from $-v$ by deviating to any $a_2 ' in A_2$. So,
  $
    u_2(x, a_2 ') <= -v quad forall a_2 ' in A_2.
  $

  Substituting $u_2 = -u_1$, this becomes

  $
    u_1(x, a_2 ') >= v quad forall a_2 ' in A_2.
  $

  Combining both bounds, we see that for any pure responses $a_1 '$ and $a_2 '$,

  $
    u_1(a_1 ', y) <= v <= u_1(x, a_2 ').
  $

  This forces $u_1(x, y) = v$. More importantly, it demonstrates that $x$ and $y$ are mutual best responses. If Player 2 plays $y$, Player 1 is capped at $v$ and cannot do better than playing $x$. If Player 1 plays $x$, Player 2 cannot do better than playing $y$. Thus, $(x, y)$ is a Nash equilibrium.

  *Marginalization in general-sum games*

  In a coarse correlated equilibrium (CCE), a trusted mediator draws from a joint distribution and privately recommends actions to each player. In general-sum games, this joint distribution is essential because it allows players to coordinate and avoid mutually bad outcomes.

  When you marginalize a CCE, you remove this coordination and force players to randomize independently. Because the players are now acting blindly relative to one another, the risk of uncoordinated, mutual bad outcomes increases. Consequently, players gain new incentives to unilaterally deviate to protect themselves, meaning the marginal strategies no longer form a Nash equilibrium. 

  In contrast, two-player zero-sum games have perfectly opposed interests, with $U_2 = -U_1$. As shown above, the marginal strategies form a Nash equilibrium and satisfy the maximin conditions. Intuitively, in this case there are no mutually beneficial outcomes that require coordination through the joint distribution. Thus, removing the correlation does not introduce new incentives to deviate, allowing the marginal strategies to retain their equilibrium properties.
]

== Correlated equilibrium <sec-ce>

The concept of _correlated equilibrium_ is an intermediate relaxation between Nash equilibrium and coarse correlated equilibrium.

#definition[Correlated equilibrium #citep(<Aumann1974Mar>)][
  A _correlated equilibrium (CE)_ is a correlated strategy $vmu in Delta (A_1 times ... times A_n)$ such that

  $
    bb(E)_((a_1 \, ... \, a_n) ~ vmu) [u_i (phi.alt_i (a_i) \, a_(- i))] <= bb(E)_((a_1 \, ... \, a_n) ~ vmu) [u_i (a_i \, a_(- i))] #h(2em) forall i in \[ n \] \, phi.alt_i : A_i -> A_i \,
  $

  where the function $phi.alt_i : A_i -> A_i$ is arbitrary.
] <def-ce>

#remark[
  A CCE is a relaxation of a CE, whereby the functions $phi.alt_i$ considered are only _constant_ functions. Furthermore, it is not hard to show from expanding the definition that any Nash equilibrium is a CE. Thus, the set of CEs is a superset of the set of Nash equilibria and a subset of the set of CCEs.
]<rem-ce-subset-cce>

All remarks made about the computation of CCEs in normal-form games apply to CEs as well. In particular, the set of CEs is a convex polytope, and a CE can be computed in polynomial time using linear programming.

However, the remark about computation in imperfect-information sequential games does not apply to CEs. Whether a CE can be computed efficiently in such games is an open question in the field. Some mild evidence suggests that the problem might be hard. Intuitively, the issue is that the number of functions $phi.alt$ in those games might be too large to control.

#exercise[Equivalence of CE and CCE for two-action games][
  Prove that if every player has exactly two actions, the set of coarse correlated equilibrium (CCE) and correlated equilibrium (CE) coincide.
]

#solution[
  Let the action space for player $i$ be $A_i = {x, y}$. We must show that CE $subset.eq$ CCE, and conversely, CCE $subset.eq$ CE for two-action games.

  *Every CE is a CCE.*
  
  From @rem-ce-subset-cce we know that CE $subset.eq$ CCE for all games.

  *Every CCE is a CE when $|A_i| = 2$.*

  Let $mu$ be a CCE. So,
  $
    E_((a_1, dots, a_n) tilde mu) [u_i (a_i', a_(-i))] <= E_((a_1, dots, a_n) tilde mu) [u_i (a_i, a_(-i))]
  $

  must hold for any fixed deviation. Consider a unilateral deviation by player $i$ to always play $x$. Expanding the expectation over the possible recommended actions $a_i in {x, y}$ gives:

  $
    sum_(a_(-i)) mu(x, a_(-i)) u_i (x, a_(-i)) + sum_(a_(-i)) mu(y, a_(-i)) u_i (x, a_(-i))\
    <= sum_(a_(-i)) mu(x, a_(-i)) u_i (x, a_(-i)) + sum_(a_(-i)) mu(y, a_(-i)) u_i (y, a_(-i))
  $

  Subtracting the common term $sum_(a_(-i)) mu(x, a_(-i)) u_i (x, a_(-i))$ from both sides:

  #set math.equation(numbering: "(1)")
  $
    sum_(a_(-i)) mu(y, a_(-i)) u_i (x, a_(-i)) <= sum_(a_(-i)) mu(y, a_(-i)) u_i (y, a_(-i))
  $ <eq:ce-cce-dev-x>

  Similarly, consider a unilateral deviation to always play $y$. Expanding the CCE expectation and simplifying gives:

  $
    sum_(a_(-i)) mu(x, a_(-i)) u_i (y, a_(-i)) <= sum_(a_(-i)) mu(x, a_(-i)) u_i (x, a_(-i))
  $ <eq:ce-cce-dev-y>
  #set math.equation(numbering: none)

  To prove $mu$ is a CE, we must show that the CE inequality holds for all possible functions $phi_i: A_i -> A_i$. Since $A_i = {x, y}$, there are exactly four such functions:

  1. *Always deviate to $x$ or always deviate to $y$* ($phi_i (a_i) = x$ or $phi_i (a_i) = y$): These are satisfied because $mu$ is a CCE.

  2. *Identity* ($phi_i (a_i) = a_i$): This trivially holds as an equality since the expected payoffs remain completely unchanged.

  3. *Swap* ($phi_i (x) = y$ and $phi_i (y) = x$): The expected utility of swapping recommended actions must not exceed the expected utility of playing the recommendations. The required CE inequality for the swap function is:

  $
    sum_(a_(-i)) mu(x, a_(-i)) u_i (y, a_(-i)) + sum_(a_(-i)) mu(y, a_(-i)) u_i (x, a_(-i))\
    <= sum_(a_(-i)) mu(x, a_(-i)) u_i (x, a_(-i)) + sum_(a_(-i)) mu(y, a_(-i)) u_i (y, a_(-i))
  $

  This expression is exactly the sum of inequalities (@eq:ce-cce-dev-x) and (@eq:ce-cce-dev-y). Since both inequalities are true by the assumption that $mu$ is a CCE, their sum must also hold.

  Because all four possible modification functions satisfy the CE requirement, $mu$ is a CE.
]

== How to think about correlated play in games

We can think of the correlation between the strategies of the players in a correlated or coarse correlated equilibrium as arising from some _correlation device_ in the game. This is a trusted mediator that can recommend but not enforce behavior. The distribution $vmu$ from which the correlation device samples recommendations is public knowledge, but the players only get to observe the recommended action that was sampled for them. A correlated / coarse correlated equilibrium is then a distribution $vmu$ such that no player can unilaterally deviate from the recommended action to improve their payoff.

The distinction between correlated and coarse correlated equilibrium is in when the players decide when to commit to the recommended action. In a coarse correlated equilibrium, the players commit to the recommended action _before_ the recommendation is made. In a correlated equilibrium, the players commit to the recommended action _after_ the recommendation is made.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - 2025-10-05: Fixed typos (thanks Eric Yang Yu!).
]
