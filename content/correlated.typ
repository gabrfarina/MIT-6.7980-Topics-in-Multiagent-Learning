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

#definition[Matrices $matU_1$ and $matU_2$ for two-player games][
  Consider a generic two-player zero-sum game, as shown next. As usual, we denote the sets of actions for player by $A_1$ and $A_2$.

  #align(center)[

    #image("figures/correlated/game_table.svg")
  ]

  Let $vx in Delta (A_1)$ denote a strategy of Player 1, and $vy in Delta (A_2)$ a strategy of Player 2. We can express the expected utilities for the players according to the bilinear expressions

  $ u_1 (vx \, vy) = vx^top matU_1 vy \, #h(2em) #h(2em) u_2 (vx \, vy) = vx^top matU_2 vy \, $

  where

  $
    matU_1 := mat(delim: "(", a_11, a_12, dots.h.c, a_(1 m); a_21, a_22, dots.h.c, a_(2 m); dots.v, dots.v, dots.down, dots.v; a_(n 1), a_(n 2), dots.h.c, a_(n m)) \, quad matU_2 := mat(delim: "(", b_11, b_12, dots.h.c, b_(1 m); b_21, b_22, dots.h.c, b_(2 m); dots.v, dots.v, dots.down, dots.v; b_(n 1), b_(n 2), dots.h.c, b_(n m)) .
  $
]

From now on, we will assume that a two-player game has been defined, and we will use the notation with $matU_1$ and $matU_2$ defined above to refer to the utility matrices of the players.

#theorem[
  Consider a two-player zero-sum game, that is, one for which $matU_2 = - matU_1$. Then, a strategy profile $(vx^(*) \, vy^(*)) in Delta (A_1) times Delta (A_2)$ is a Nash equilibrium if and only if it is a maxmin strategy, _i.e._, if and only if

  $
    vx^(*) in argmax_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy \, #h(2em) upright("and") #h(2em) vy^(*) in argmax_(vy in Delta (A_2)) min_(vx in Delta (A_1)) vx^top matU_2 vy .
  $
]#label("thm:nash is mm")

#proof[
  We prove the result assuming we trust von Neumann's minimax theorem, which states that

  $
    max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy = min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy .
  $

  $(==>)$~~Suppose that $(vx^(*) \, vy^(*))$ is a Nash equilibrium. Then, by the definition of Nash equilibrium and using the fact that $matU_2 = - matU_1$, we have that

  $
    (vx^(*))^top matU_1 vy^(*) = max_(vx in Delta (A_1)) vx^top matU_1 vy^(*) \, #h(2em) upright("and") #h(2em) (vx^(*))^top matU_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top matU_1 vy .
  $

  Hence, we can write the chain of equalities and inequalities

  $
    min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy <= max_(vx in Delta (A_1)) vx^top matU_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top matU_1 vy <= max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy .
  $

  By the minimax theorem, all inequalities must be equalities; hence, $(vx^(*) \, vy^(*))$ satisfies

  $
    min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy & = max_(vx in Delta (A_1)) vx^top matU_1 vy^(*) & & quad <=> quad vy^(*) in argmin_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy\
    max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy & = min_(vy in Delta (A_2)) (vx^(*))^top matU_1 vy & & quad <=> quad vx^(*) in argmax_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy .
  $

  $(<==)$~~Conversely, suppose that $vx^(*)$ and $vy^(*)$ are maxmin strategies. Let $v^(*)$ be the common value of both sides of the minimax theorem, that is,

  $
    v^(*) := max_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy = min_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy .
  $

  We now show that $(vx^(*) \, vy^(*))$ is a Nash equilibrium. By definition, this means we need to show that

  $
    (vx^(*))^top matU_1 vy^(*) = max_(vx in Delta (A_1)) vx^top matU_1 vy^(*) & #h(2em) upright("and") #h(2em) (vx^(*))^top matU_1 vy^(*) = min_(vy in Delta (A_2)) (vx^(*))^top matU_1 vy .
  $

  Using the hypothesis,

  $
    vx^(*) & in argmax_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy \, quad & & ==> quad v^(*) = min_(vy in Delta (A_2)) (vx^(*))^top matU_1 vy \,\
    vy^(*) & in argmin_(vy in Delta (A_2)) max_(vx in Delta (A_1)) vx^top matU_1 vy \, quad & & ==> quad v^(*) = max_(vx in Delta (A_1)) vx^top matU_1 vy^(*) .
  $

  These equalities imply that $v^(*) <= (vx^(*))^top matU_1 vy^(*)$ and $v^(*) >= (vx^(*))^top matU_1 vy^(*)$, and thus $v^(*) = (vx^(*))^top matU_1 vy^(*)$. This shows that the players are best responding to the strategy of the opponent, completing the proof that $(vx^(*) \, vy^(*))$ is a Nash equilibrium.
]

*Computation*  As we will see shortly, #ref(label("thm:nash is mm")) gives us nontrivial information about the structure of Nash equilibria in two-player zero-sum games. But it also gives us a computational tool. Indeed, the theorem above tells us that finding a Nash equilibrium in a two-player zero-sum game can be expressed as an optimization problem. Let's show that this optimization problem is a linear program. Without loss of generality, let's focus on Player 1's optimization problem, that is,

$ vx^(*) in argmax_(vx in Delta (A_1)) min_(vy in Delta (A_2)) vx^top matU_1 vy . $

The key insight is that, for a fixed $vx$, the inner minimum is attained at a pure action of Player 2. Indeed, $vx^top matU_1 vy = sum_(a_2 in A_2) y_(a_2) (vx^top matU_1 ve_(a_2))$ is an average of the $|A_2|$ numbers $vx^top matU_1 ve_(a_2)$, so it is never smaller than the smallest of them, and that value is attained by putting all the mass on the corresponding action. Hence $min_(vy in Delta (A_2)) vx^top matU_1 vy = min_(a_2 in A_2) vx^top matU_1 ve_(a_2)$, and introducing a variable $v$ for this minimum, the problem becomes

$
  cases(max_(vx, v) v, upright("s.t.") v <= vx^top matU_1 ve_(a_2) quad forall a_2 in A_2, upright("") vone^top vx = 1, vx >= 0 .)
$

For a fixed $vx$, the largest feasible $v$ is exactly $min_(a_2 in A_2) vx^top matU_1 ve_(a_2)$, so the optimal value of this linear program is the maxmin value, and the $vx$-part of any optimal solution is a maxmin strategy. The program has one constraint per action of Player 2, besides the simplex constraints. We can use any linear programming solver to find such a solution. The #lecture-link("learning_intro", <sec-learning-zero-sum>)[self-play construction] gives more scalable methods to compute maxmin strategies from repeated play.

*Connection with linear programming*  It is worth pausing for a moment to appreciate some historical context. We started the proof by assuming von Neumann's minimax theorem, which we justified as a consequence of linear programming duality. However, historically, von Neumann did not have the luxury of linear programming to prove his theorem.

- The proof of von Neumann's minimax theorem essentially hides an optimization duality argument. Indeed, we have the following, where, by the same argument as above, each program needs only one constraint per pure action of the opponent:

  #align(center)[

    #table(
      stroke: none,
      columns: 3,
      align: center + horizon,
      inset: .7em,
      [$max_(vx in Delta \( A_1 \)) min_(vy in Delta \( A_2 \)) vx^top matU_1 vy$],
      [],
      [$min_(vy in Delta \( A_2 \)) max_(vx in Delta \( A_1 \)) vx^top matU_1 vy$],

      [$arrow.t.b$], [], [$arrow.t.b$],
      [$ cases(max_(vx, v) v, v <= vx^top matU_1 ve_(a_2) quad forall a_2, vone^top vx = 1, vx >= 0 .) $],
      [$limits(<-->)^(upright("  linear programming  "))_(upright("duality"))$],
      [$ cases(min_(vy, w) w, w >= ve_(a_1)^top matU_1 vy quad forall a_1, vone^top vy = 1, vy >= 0 .) $],
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

#math.equation(
  block: true,
  numbering: "(1)",
  $upright("find") quad vx \, vw in bb(R)^d #h(2em) upright("s.t.") #h(2em) vw = matM vx + vq \, #h(2em) vx \, vw >= 0 \, #h(2em) vx^top vw = 0 .$.body,
) <eq:lcp-general>

The Lemke-Howson algorithm is a well-known algorithm to solve LCPs, and it can be used to find Nash equilibria in two-player general-sum games. However, the algorithm is not polynomial-time in the worst case, and it can be hard to find Nash equilibria in practice. An important corollary of the connection between two-player general-sum games and LCPs is the following:

#corollary[
  Any two-player general-sum games with rational payoffs admits a Nash equilibrium with rational coordinates.
]

This follows directly from the way Lemke-Howson works, which is similar to the simplex algorithm. The algorithm moves along edges of a rational polytope until it finds a Nash equilibrium. Since the algorithm only moves along the edges of the polytope, it will only generate rational solutions.

#exercise[Nash equilibrium as a linear complementarity problem][
  Consider a generic two-player general-sum game, with utility matrices $U_1$ and $U_2$ as defined above. Show that finding a Nash equilibrium of the game can be reduced to the LCP of #ref(<eq:lcp-general>, supplement: none), with a number of variables $d$ that is linear in $| A_1 | + | A_2 |$.

  _Hint:_ the strategy profile $(vx_1 \, vx_2)$ is a Nash equilibrium if and only if neither player has a profitable deviation to a pure action. The obstacle is that writing this down naively requires the bilinear term $vx_1^top U_1 vx_2$, which an LCP cannot express directly. Try introducing a dummy variable to stand in for each player's equilibrium payoff: the complementarity condition $vz^top vw = 0$ can then pin down its value for you, without ever expanding the bilinear product.
]

#solution[
  *Normalizing the payoffs.*  Adding a constant $c$ to every entry of $U_1$ changes every payoff $vx^top U_1 vy$ by exactly $c$, since $vx^top (U_1 + c J) vy = vx^top U_1 vy + c (vone^top vx) (vone^top vy) = vx^top U_1 vy + c$ whenever $vx \, vy$ are probability distributions. Such a shift leaves every best response, and hence the set of Nash equilibria, unchanged. So we may assume without loss of generality that $U_1 \, U_2 > 0$ entrywise.

  *Constructing the LCP.*  Let $m := | A_1 |$ and $n := | A_2 |$. Rather than working with normalized strategies, introduce *unnormalized* vectors $vx_1 in bb(R)^m_(>= 0)$ and $vx_2 in bb(R)^n_(>= 0)$, and define the slacks

  $ vw_1 := vone_m - U_1 vx_2 \, #h(2em) vw_2 := vone_n - U_2^top vx_1 . $

  Stacking $vz := (vx_1 \, vx_2) in bb(R)^(m + n)$ and $vw := (vw_1 \, vw_2) in bb(R)^(m + n)$ gives exactly an instance of @eq:lcp-general, with $d = m + n = | A_1 | + | A_2 |$ and $M \, vq$ read off from the two displayed equalities. The constant $vone$ that appears in place of a genuine payoff value is the dummy variable from the hint: instead of solving for the (unknown, bilinear) equilibrium payoffs directly, we solve for *rescaled* strategies for which the equilibrium payoff is implicitly pinned to $1$, and recover the true equilibrium by renormalizing at the end.

  *An LCP solution yields a Nash equilibrium.*  The pair $(vz \, vw) = (0 \, vone)$ always solves the LCP, but corresponds to no equilibrium; we discard it. Take any other solution, so $vz != 0$. If $vx_2 = 0$ then $vw_1 = vone_m > 0$, so complementary slackness $vx_1^top vw_1 = 0$ forces $vx_1 = 0$ too, i.e. $vz = 0$, a contradiction; hence $vx_2 != 0$, and symmetrically $vx_1 != 0$. Normalize $hat(vx)_1 := vx_1 \/ norm(vx_1)_1$ and $hat(vx)_2 := vx_2 \/ norm(vx_2)_1$. For every $a_1 in A_1$, the inequality $w_(1 \, a_1) = 1 - ve_(a_1)^top U_1 vx_2 >= 0$ becomes, after dividing by $norm(vx_2)_1 > 0$,

  $ ve_(a_1)^top U_1 hat(vx)_2 <= 1 \/ norm(vx_2)_1 \, $

  with *equality* whenever $x_(1 \, a_1) > 0$, by complementary slackness. So every action in the support of $hat(vx)_1$ attains the same value $1 \/ norm(vx_2)_1$ against $hat(vx)_2$, and no action does better; averaging over $hat(vx)_1$ shows $hat(vx)_1^top U_1 hat(vx)_2 = 1 \/ norm(vx_2)_1$ too, so $hat(vx)_1$ is a best response to $hat(vx)_2$. The symmetric argument with $vw_2$ and $U_2$ shows $hat(vx)_2$ is a best response to $hat(vx)_1$, so $(hat(vx)_1 \, hat(vx)_2)$ is a Nash equilibrium.

  *A Nash equilibrium yields an LCP solution.*  Conversely, let $(hat(vx)_1 \, hat(vx)_2)$ be a Nash equilibrium of the (positivized) game, with payoffs $v_1 := hat(vx)_1^top U_1 hat(vx)_2 > 0$ and $v_2 := hat(vx)_1^top U_2 hat(vx)_2 > 0$. Setting $vx_1 := hat(vx)_1 \/ v_2$ and $vx_2 := hat(vx)_2 \/ v_1$ recovers a nonzero LCP solution: dividing the best-response condition $ve_(a_1)^top U_1 hat(vx)_2 <= v_1$ (equality on the support of $hat(vx)_1$) by $v_1$ gives exactly $w_(1 \, a_1) = 1 - ve_(a_1)^top U_1 vx_2 >= 0$, with equality on the support of $vx_1$; the symmetric computation handles $vw_2$.

  This gives a correspondence between nonzero solutions of the $(| A_1 | + | A_2 |)$-variable LCP and Nash equilibria of the game, as required.
]

An interesting result about the computation of $epsilon.alt$-approximate Nash equilibria is due to #citet(<LMM03>), and is based on the observation that every two-player game with payoffs in $[0, 1]$ admits an $epsilon.alt$-approximate Nash equilibrium where the strategy of Player 1 is uniform over a multiset of $w := O (frac(log(2 \| A_2 \|), epsilon.alt^2))$ actions. This follows from using a Hoeffding bound on samples from Player 1's equilibrium strategy. One can then enumerate every such strategy for Player 1, and for each one, solve a linear program in Player 2's strategy to check whether the two together form an $epsilon.alt$-approximate Nash equilibrium. For rational payoffs and any fixed $epsilon.alt > 0$, this gives a quasi-polynomial-time algorithm, with running time $s^(O(log s \/ epsilon.alt^2))$, where $s$ is the encoding size of the game. #lecture-link("nash_algorithms", <sec-lmm>)[The supplementary reading on centralized algorithms] develops this argument and the resulting algorithm in detail.

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

#exercise[The irrational Nash equilibrium in the preceding example][
  Prove that the three-player game above has exactly the stated Nash equilibrium. In particular, rule out equilibria in which only some players mix before imposing indifference for all three players.
]

#solution[
  Let $x$, $y$, and $z$ be the probabilities of Top, Left, and Action X, respectively. The payoff gains from choosing Top rather than Bottom, Left rather than Right, and Action X rather than Action Y are
  $
    d_1 &= 3 y z + y(1-z) - (1-y)z - 2(1-y)(1-z) = y z + 3y + z - 2, \
    d_2 &= (1-x)z + 3(1-x)(1-z) - 2x z - x(1-z) = x z - 4x - 2z + 3, \
    d_3 &= 2x y - 3(1-x)(1-y) = -x y + 3x + 3y - 3.
  $
  In equilibrium, a positive gain forces the corresponding probability to be $1$, a negative gain forces it to be $0$, and a probability strictly between $0$ and $1$ requires zero gain.

  First, $x=0$ gives $d_2=3-2z>0$, so $y=1$, which gives $d_1=1+2z>0$ and contradicts $x=0$. Similarly, $x=1$ gives $d_2=-1-z<0$, so $y=0$, which gives $d_1=z-2<0$ and contradicts $x=1$. Thus $0<x<1$. Since $y=0$ makes $d_1<0$ and $y=1$ makes $d_1>0$, we also have $0<y<1$.

  It follows that $d_1=d_2=0$. If $z=0$, these equations give $(x,y)=(3/4,2/3)$ and hence $d_3=3/4>0$, contradicting $z=0$. If $z=1$, they give $(x,y)=(1/3,1/4)$ and hence $d_3=-4/3<0$, contradicting $z=1$. Therefore every player mixes, and all three gains must vanish.

  Solving $d_2=d_3=0$ gives $z=(4x-3)/(x-2)$ and $y=(3x-3)/(x-3)$. The denominators are nonzero because $0<x<1$. Substituting into $d_1=0$ yields
  $
    0 = frac(23x^2-53x+24, (x-3)(x-2)), quad
    x = frac(53 plus.minus sqrt(601), 46).
  $
  The root with the plus sign exceeds $1$. The remaining root gives
  $
    (x,y,z) = (frac(53-sqrt(601),46), frac(-13+sqrt(601),24), frac(-23+sqrt(601),4)).
  $
  All three probabilities lie strictly between $0$ and $1$ and make every player indifferent, so this profile is a Nash equilibrium. The boundary exclusions and the unique admissible root prove uniqueness. Since $601$ is not a perfect square, all three probabilities are irrational.
]

#remark[
  The issues with irrational numbers do not stop at square roots. In fact, _any polynomial root_ might be required to represent a Nash equilibrium. This was shown by #citet(<bubelis1979equilibria>), who showed how to construct games with arbitrary polynomial roots.

  Beyond the representation, the topology of Nash equilibria is also in general arbitrarily complex in three-player games. In particular, #citet(<datta2003universality>) showed that for any real algebraic variety, one can come up with some three-player game whose set of fully mixed Nash equilibria is isomorphic to that variety.
]

*Computation*  On the computational side, the situation is even more dire. As a first consideration, because Nash equilibria might require irrational numbers, even the question of how to _represent_ the output equilibrium needs attention. In general, we cannot hope for an _exact_ value. However, even asking for a _constant_ approximation turns out to be hard. We will talk about this in more detail at the end of the course, where we relate the computation of (approximate) Nash equilibria to a complexity class called PPAD.

If one is willing to stomach a worst-case superpolynomial runtime, some methods exist. While the Lemke-Howson algorithm cannot be used beyond two-player games, other methods (such as #citep(<Porter2008Jul>)) still apply.

= Correlated and coarse correlated equilibrium

The discussion above shows that Nash equilibria can be hard to compute and might not form a convex (or even contractible) set. This motivates the study of _correlated equilibria_ #citep(<Aumann1974Mar>) and _coarse correlated equilibria_ #citep(<moulin1978strategically>), which are a relaxation of Nash equilibria that are easier to compute, always form a convex set, and for which rational solutions always exist when the payoffs are rational. As we will show starting in a few lectures, another major advantage of correlated equilibria is that they can be learned from repeated play, in a way that is fundamentally incompatible with Nash equilibria.#footnote[A paradigm that has been successful in applications is to learn a correlated equilibrium from repeated play, and then marginalize it into a profile that is hoped to be close to a Nash equilibrium. This was used for example to reach superhuman performance in multiplayer poker #citep(<Brown2019Aug>).]

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

  This shows that the set of CCEs is a superset of the set of Nash equilibria. Thus, a coarse correlated equilibrium always exists in every game. This argument goes through Nash's theorem, and hence through Brouwer's fixed-point theorem; #lecture-link("eah", <sec-cce-existence>)[a direct proof] uses only the minimax theorem.
]

*Properties and computation*  We can turn @def-cce into an optimization problem. The variables are the entries of the probability distribution $vmu$. This is a $(A_1 times dots.h.c times A_n)$-dimensional nonnegative vector whose entries must satisfy the linear equality constraint

$ sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) = 1 . $

Furthermore, expanding the expectation in inequality #ref(<eq:cce>, supplement: none) defines a set of linear constraints

$
  sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) u_i (a'_i \, a_(- i)) <= sum_(a_1 in A_1) dots.h.c sum_(a_n in A_n) mu_(a_1 \, ... \, a_n) u_i (a_i \, a_(- i))
$

for all $i in \[ n \]$ and $a'_i in A_i$.
Hence, the set of CCEs is the intersection of a finite set of linear constraints, and so it is a convex polytope. Note that the number of constraints is polynomial in the game (_i.e._, in the size of the payoff table), and so we can use linear programming to compute and even optimize over the set of CCEs in time polynomial in $\| A_1 \| times ... times \| A_n \|$. Since this linear program has one variable per action profile, its size grows exponentially with the number of players. The #lecture-link("eah", <sec-minimax-algorithm>)[Ellipsoid-Against-Hope algorithm] avoids this: for rational, bounded payoffs and a polynomial-time oracle for expected utilities under product distributions, it computes an $epsilon.alt$-approximate CCE in time polynomial in the succinct input size, payoff encoding length, $|A_1| + dots.c + |A_n|$, and $log(1 \/ epsilon.alt)$.

#corollary[
  If all payoffs are rational numbers, the set of CCEs is a rational polytope, that is, it is described by finitely many linear inequalities with rational coefficients. In particular, its vertices have rational coordinates, so the game admits a CCE with rational coordinates.
]

Indeed, the coefficients of the constraints above are payoffs (and the constants $0$ and $1$), and each vertex is the unique solution of a linear system with these coefficients. The rationality assumption cannot be dropped. Consider the two-player zero-sum game with
$ matU_1 = mat(sqrt(2), 0; 0, 1). $
Its incentive constraints force the unique CCE to put probabilities $(3 - 2 sqrt(2)) dot (1, sqrt(2), sqrt(2), 2)$ on the action profiles $(1, 1), (1, 2), (2, 1), (2, 2)$, which are irrational.

#exercise[No Nash equilibrium in the interior of the CCE polytope][
  Call a game _non-trivial_ if $u_i (a_i \, a_(- i)) != u_i (a'_i \, a_(- i))$ for some player $i$, actions $a_i \, a'_i in A_i$, and $a_(- i) in A_(- i)$. Show that in any non-trivial game, no Nash equilibrium lies in the (relative) interior of the convex polytope of coarse correlated equilibria.

  _Note:_ a similar relationship holds for correlated equilibria.
]

#solution[
  Throughout, "interior" means relative to the affine hull of $Delta (A_1 times dots.h.c times A_n)$, i.e. the hyperplane on which the entries of $vmu$ sum to $1$, since the CCE polytope lives inside it.

  *An elementary fact about polytopes.*  Suppose a linear inequality $ell (vmu) <= 0$ is one of the constraints defining a polytope $Q$, some $vmu^(*) in Q$ satisfies $ell (vmu^(*)) = 0$, and $ell$ is *not* constant on the ambient affine hull. Then $vmu^(*)$ cannot lie in the interior of $Q$: since $ell$ is non-constant there, some direction strictly increases it, so moving from $vmu^(*)$ by any positive amount along that direction leaves $Q$, and no neighborhood of $vmu^(*)$ is contained in $Q$.

  *Setup.*  Let $(vx_1 \, ... \, vx_n)$ be a Nash equilibrium and $vmu := vx_1 ⊗ dots.h.c ⊗ vx_n$ the corresponding product CCE. For player $i$ and action $a'_i in A_i$, write $U_i (a'_i) := EE_(a_(- i) ~ vx_(- i)) [u_i (a'_i \, a_(- i))]$ for the payoff of deterministically playing $a'_i$ against the equilibrium strategies of the others, and $V_i := EE_(a_i ~ vx_i) [U_i (a_i)]$ for player $i$'s equilibrium payoff. Since $vmu$ is a product distribution, the CCE constraint indexed by $(i \, a'_i)$, namely $EE_vmu [u_i (a'_i \, a_(- i))] <= EE_vmu [u_i (a_1 \, ... \, a_n)]$, reads exactly $U_i (a'_i) <= V_i$ at $vmu$. Because $(vx_1 \, ... \, vx_n)$ is a Nash equilibrium, this holds for every $a'_i in A_i$, with *equality* whenever $x_(i \, a'_i) > 0$.

  *Finding a non-degenerate tight constraint.*  Since the game is non-trivial, fix a player $j$, actions $b \, b' in A_j$, and a context $d in A_(- j)$ with $u_j (b \, d) != u_j (b' \, d)$. Player $j$'s strategy $vx_j$ is a probability distribution, so it has some action $s$ with $x_(j \, s) > 0$. By the previous paragraph, the CCE constraint indexed by $(j \, s)$ is tight at $vmu$: writing $ell (vmu) := EE_vmu [u_j (s \, a_(- j))] - EE_vmu [u_j (a_1 \, ... \, a_n)]$ for this constraint's defining functional, viewed now as a function of an arbitrary $vmu in Delta (A_1 times dots.h.c times A_n)$ rather than just our equilibrium one, we have $ell (vmu) = 0$.

  It remains to check $ell$ is not constant on the ambient affine hull. Its coefficient on the pure outcome where player $j$ plays $s$ is always $0$ (both terms coincide there), so if $ell$ were constant it would be identically $0$, meaning $u_j (s \, a_(- j)) = u_j (a_j \, a_(- j))$ for *every* action $a_j in A_j$ and context $a_(- j) in A_(- j)$. In particular, taking $a_j = b$ and $a_j = b'$ at $a_(- j) = d$ gives $u_j (b \, d) = u_j (s \, d) = u_j (b' \, d)$, contradicting $u_j (b \, d) != u_j (b' \, d)$. So $ell$ is genuinely non-constant.

  By the elementary fact, $vmu$ does not lie in the interior of the CCE polytope.
]

It is worth knowing that a CCE can also be computed in polynomial time in imperfect-information sequential games, despite the number of "actions" there, which is the number of strategies in the tree, is exponential in the input; one way is #lecture-link("eah", <sec-minimax-algorithm>)[the same Ellipsoid-Against-Hope approach]. Unfortunately, we lose the ability to optimize over the set.

#exercise[Marginals of a zero-sum CCE form a Nash equilibrium][
  Let $vmu in Delta (A_1 times A_2)$ be a coarse correlated equilibrium of a two-player _zero-sum_ game, i.e. $matU_2 = - matU_1$. Show that the marginal strategies

  $ x_(1 \, a_1) := sum_(a'_2 in A_2) mu_(a_1 \, a'_2) \, #h(2em) x_(2 \, a_2) := sum_(a'_1 in A_1) mu_(a'_1 \, a_2) $

  form a Nash equilibrium $(vx_1 \, vx_2)$ of the game, and hence are maxmin strategies. Give a general-sum game and a CCE whose marginal strategies do not form a Nash equilibrium.
]

#solution[
  Write $overline(V) := EE_vmu [u_1 (a_1 \, a_2)]$ for the (correlated) payoff realized under $vmu$; since the game is zero-sum, $EE_vmu [u_2 (a_1 \, a_2)] = - overline(V)$.

  For every $a'_1 in A_1$, the CCE constraint for player $1$'s deviation to $a'_1$ only depends on the realized action of player $2$, so it can be rewritten using the marginal $vx_2$:

  $ ve_(a'_1)^top matU_1 vx_2 = EE_vmu [u_1 (a'_1 \, a_2)] <= overline(V) . $

  Symmetrically, for every $a'_2 in A_2$, using $matU_2 = - matU_1$,

  $
    - vx_1^top matU_1 ve_(a'_2) = EE_vmu [u_2 (a_1 \, a'_2)] <= EE_vmu [u_2 (a_1 \, a_2)] = - overline(V) \, quad upright("i.e.") quad vx_1^top matU_1 ve_(a'_2) >= overline(V) .
  $

  Averaging the first family of inequalities against the weights $vx_1$ gives $vx_1^top matU_1 vx_2 <= overline(V)$; averaging the second family against the weights $vx_2$ gives $vx_1^top matU_1 vx_2 >= overline(V)$. Hence both hold with equality, $vx_1^top matU_1 vx_2 = overline(V)$, and substituting this back, the two families of inequalities become

  $ ve_(a'_1)^top matU_1 vx_2 <= vx_1^top matU_1 vx_2 quad forall a'_1 in A_1 \, #h(2em) vx_1^top matU_1 ve_(a'_2) >= vx_1^top matU_1 vx_2 quad forall a'_2 in A_2 . $

  The first says no pure deviation improves on $vx_1$ against $vx_2$ (so no mixed deviation does either, by linearity), i.e. $vx_1$ is a best response to $vx_2$ under $matU_1$. The second says no pure deviation improves player $2$'s payoff $- vx_1^top matU_1 ve_(a'_2)$ against $vx_1$, i.e. $vx_2$ is a best response to $vx_1$ under $matU_2 = - matU_1$. Together, $(vx_1 \, vx_2)$ is a Nash equilibrium.

  By #ref(label("thm:nash is mm")), these marginal strategies are maxmin strategies. The conclusion can fail in general-sum games: let both players have payoff matrix $matU_1=matU_2=mat(2,0;0,1)$, and let $vmu$ put probability $1/2$ on each diagonal profile. Each player earns $3/2$, while always choosing the first or second action gives $1$ or $1/2$, respectively, so $vmu$ is a CCE. Its marginals are both $(1/2,1/2)$; under their product, each player earns $3/4$ and can improve to $1$ by always choosing the first action. Thus the product of the marginals need not be a Nash equilibrium.
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
  A CCE is a relaxation of a CE: choosing the constant function $phi.alt_i (a_i) = a'_i$ in @def-ce recovers exactly the CCE constraint #ref(<eq:cce>, supplement: none) for the deviation $a'_i$. A CE must additionally withstand every nonconstant $phi.alt_i$, that is, deviations that depend on the recommended action $a_i$. A player who sees the recommendation before deciding how to deviate has more deviations available, so the CE conditions are more demanding and every CE is a CCE.

  Conversely, any Nash equilibrium $(vx_1, ..., vx_n)$, viewed as the product distribution $vmu = vx_1 ⊗ dots.c ⊗ vx_n$, is a CE. Under $vmu$, $a_(-i) ~ vx_(-i)$ independently of $a_i$, so the recommendation reveals nothing about the other players' actions. Hence, for every $i in [n]$ and $phi.alt_i : A_i -> A_i$,
  $
    bb(E)_(a ~ vmu) [u_i (phi.alt_i (a_i), a_(-i))] & = sum_(a_i in A_i) x_(i, a_i) u_i (phi.alt_i (a_i), vx_(-i)) \
    & <= sum_(a_i in A_i) x_(i, a_i) u_i (vx_i, vx_(-i)) = bb(E)_(a ~ vmu) [u_i (a_i, a_(-i))],
  $
  where the inequality is the Nash condition $u_i (a'_i, vx_(-i)) <= u_i (vx_i, vx_(-i))$ applied to $a'_i = phi.alt_i (a_i)$.

  Thus, identifying Nash equilibria with product distributions, $"NE" subset.eq "CE" subset.eq "CCE"$.
] <rem-ce-subset-cce>

All remarks made about the computation of CCEs in normal-form games apply to CEs as well, with one caveat: @def-ce has one constraint for each function $phi.alt_i : A_i -> A_i$, and there are $|A_i|^(|A_i|)$ of them. Most of these constraints are redundant. Splitting the expectation according to the recommended action $a_i$, the constraint for $phi.alt_i$ reads
$
  sum_(a_i in A_i) g_i (a_i, phi.alt_i (a_i)) <= 0, quad "where" quad g_i (a_i, a'_i) := sum_(a_(-i) in A_(-i)) mu_(a_i, a_(-i)) [u_i (a'_i, a_(-i)) - u_i (a_i, a_(-i))].
$
Taking $phi.alt_i$ to change only $a_i$ into $a'_i$ (and to keep every other action $b$, for which $g_i (b, b) = 0$) shows that $g_i (a_i, a'_i) <= 0$ is necessary, and summing these inequalities shows that they are also sufficient. Hence $vmu$ is a CE if and only if
$
  sum_(a_(-i) in A_(-i)) mu_(a_i, a_(-i)) u_i (a'_i, a_(-i)) <= sum_(a_(-i) in A_(-i)) mu_(a_i, a_(-i)) u_i (a_i, a_(-i)) #h(2em) forall i in [n], a_i, a'_i in A_i.
$
Dividing by the probability that $a_i$ is recommended (when positive), this says that following the recommendation $a_i$ is a best response to the conditional distribution of $a_(-i)$ given $a_i$. Together with the constraints that $vmu$ is a probability distribution, these $sum_i |A_i|^2$ linear inequalities describe the set of CEs, which is therefore a convex polytope (rational if the payoffs are). As for CCEs, linear programming can compute a CE, or optimize any linear objective over the set of CEs, in time polynomial in $|A_1| times dots.c times |A_n|$.

However, the remark about computation in imperfect-information sequential games does not apply to CEs. Whether a CE can be computed efficiently in such games is an open question in the field. Some mild evidence suggests that the problem might be hard. Intuitively, the issue is that the number of functions $phi.alt$ in those games might be too large to control.

#exercise[Equivalence of CE and CCE for two-action games][
  Prove that if every player has two actions, the sets of coarse correlated equilibria and correlated equilibria coincide.
]

#solution[
  Every CE is a CCE because constant deviations are allowed in the definition of a CE. Conversely, let $vmu$ be a CCE and fix a player $i$ with $A_i={b,c}$. Expanding the CCE constraint for always choosing $b$ and canceling the terms where $b$ was already recommended gives
  $
    sum_(a_(-i) in A_(-i)) mu_(c,a_(-i)) [u_(i)(b,a_(-i))-u_(i)(c,a_(-i))] <= 0.
  $
  Similarly, always choosing $c$ gives
  $
    sum_(a_(-i) in A_(-i)) mu_(b,a_(-i)) [u_(i)(c,a_(-i))-u_(i)(b,a_(-i))] <= 0.
  $
  There are four maps $phi.alt_i:A_i -> A_i$. The two constant maps satisfy the CE constraint because $vmu$ is a CCE, and the identity map gives zero gain. For the map that swaps $b$ and $c$, the expected gain is the sum of the two displayed expressions, so it is nonpositive as well. Thus every recommendation-dependent deviation has nonpositive gain, for every player, and $vmu$ is a CE.
]

Say an action $a_i in A_i$ is _dominated_ by another action $a_i^(*) in A_i$ if, for every combination of actions $a_(- i) in A_(- i)$ chosen by the other players, $a_i^(*)$ always yields a strictly higher payoff for player $i$ than $a_i$, that is, $u_i (a_i^(*) \, a_(- i)) > u_i (a_i \, a_(- i))$.

#exercise[A dominated action is never recommended by a correlated equilibrium][
  Show that a dominated action cannot be in the support of any correlated equilibrium, in any $n$-player game. In other words, any correlated equilibrium must place zero probability on every action tuple that contains a dominated action $a_i$.
] <ex:dominated-ce>

#solution[
  Fix a player $i$ and suppose $a_i in A_i$ is dominated by $a_i^(*)$. Let $vmu$ be a correlated equilibrium (@def-ce), and apply its defining condition to the deviation function $phi.alt_i$ that swaps $a_i$ for $a_i^(*)$ and leaves every other action unchanged, that is $phi.alt_i (a_i) = a_i^(*)$ and $phi.alt_i (x) = x$ for $x != a_i$. Since $phi.alt_i$ is the identity away from $a_i$, every pure outcome in which player $i$'s realized action differs from $a_i$ contributes the same term to both sides of the defining inequality and cancels; only the outcomes where player $i$ actually plays $a_i$ survive:

  $
    0 >= EE_vmu [u_i (phi.alt_i (a_i) \, a_(- i))] - EE_vmu [u_i (a_i \, a_(- i))] = sum_(a_(- i) in A_(- i)) mu_(a_i \, a_(- i)) [u_i (a_i^(*) \, a_(- i)) - u_i (a_i \, a_(- i))] .
  $

  Every term on the right is a nonnegative probability $mu_(a_i \, a_(- i))$ times a strictly positive quantity, by domination. A sum of such nonnegative terms can only be $<= 0$ if every term is exactly $0$, so $mu_(a_i \, a_(- i)) = 0$ for every $a_(- i) in A_(- i)$. Hence $vmu$ places zero probability on every action tuple in which player $i$ plays $a_i$.
]

#exercise[A dominated action can appear in a coarse correlated equilibrium][
  Show that #ref(<ex:dominated-ce>, supplement: none) fails for coarse correlated equilibria, by exhibiting a game together with a CCE of that game whose support includes a dominated action.
]

#solution[
  Consider a two-player game where Player 1 has actions ${ U \, M \, D }$, Player 2 has actions ${ L \, R }$, Player 2's payoff is identically $0$, and Player 1's payoffs are

  #show table: it => block(breakable: false, it)
  #align(center)[
    #table(
      stroke: none,
      columns: 3,
      align: center + horizon,
      inset: .7em,
      [], [$L$], [$R$],
      [$U$], [$1$], [$1$],
      [$M$], [$3$], [$0$],
      [$D$], [$0$], [$0$],
    )
  ]

  Action $D$ is dominated by $U$: $u_1 (U \, L) = 1 > 0 = u_1 (D \, L)$ and $u_1 (U \, R) = 1 > 0 = u_1 (D \, R)$.

  Let $vmu$ place probability $1 \/ 2$ on $(M \, L)$ and probability $1 \/ 2$ on $(D \, R)$. Player 2's payoff is identically $0$, so every CCE constraint for Player 2 holds trivially. For Player 1, the realized payoff is $EE_vmu [u_1 (a_1 \, a_2)] = (1 \/ 2) dot.op 3 + (1 \/ 2) dot.op 0 = 3 \/ 2$, and every constant deviation satisfies the CCE constraint:

  $
    EE_vmu [u_1 (U \, a_2)] = (1 \/ 2) dot.op 1 + (1 \/ 2) dot.op 1 = 1 <= 3 \/ 2 \, #h(1.5em) EE_vmu [u_1 (M \, a_2)] = 3 \/ 2 <= 3 \/ 2 \, #h(1.5em) EE_vmu [u_1 (D \, a_2)] = 0 <= 3 \/ 2 .
  $

  So $vmu$ is a CCE, yet it places probability $1 \/ 2$ on the dominated action $D$.

  Intuitively, deviating to the constant action $U$ is unattractive precisely because it also gives up the high payoff $M$ earns whenever the correlation device happens to recommend $(M \, L)$; a coarse deviation must commit to a single action before observing the recommendation, so it cannot exploit the conditional swap used in #ref(<ex:dominated-ce>, supplement: none).
]

== How to think about correlated play in games

We can think of the correlation between the strategies of the players in a correlated or coarse correlated equilibrium as arising from some _correlation device_ in the game. This is a trusted mediator that can recommend but not enforce behavior. The distribution $vmu$ from which the correlation device samples recommendations is public knowledge, but the players only get to observe the recommended action that was sampled for them. A correlated / coarse correlated equilibrium is then a distribution $vmu$ such that no player can unilaterally deviate from the recommended action to improve their payoff.

The distinction between correlated and coarse correlated equilibrium is in when the players decide when to commit to the recommended action. In a coarse correlated equilibrium, the players commit to the recommended action _before_ the recommendation is made. In a correlated equilibrium, the players commit to the recommended action _after_ the recommendation is made.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#changelog[
  - 2025-10-05: Fixed typos (thanks Eric Yang Yu!).
]
