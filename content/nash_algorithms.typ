#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: "S1",
  date: [Fall 2026],
  title: "Centralized algorithms for Nash equilibrium computation",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

// Define a reusable disclosure/toggle function
#let toggle(title, body) = {
  context if sys.inputs.at("target", default: none) == "html" or target() == "html" {
    // Interactive element for the web
    html.elem("details")[
      #html.elem("summary")[*#title*]
      #body
    ]
  } else {
    // Static layout representation for PDFs (styled box)
    block(
      width: 100%,
      stroke: 0.5pt + luma(150),
      inset: 10pt,
      radius: 4pt,
      fill: luma(245),
      [
        #text(weight: "bold", title)
        #v(4pt)
        #line(length: 100%, stroke: 0.5pt + luma(200))
        #body
      ]
    )
  }
}

In previous lectures, we saw the basic game theory formalism, and some of the most fundamental equilibrium concepts, and their existence proofs. The #lecture-link("nfgs_nash", <sec-nash-existence>)[proof of Nash equilibrium existence] makes use of Brouwer's fixed point theorem, which does not immediately suggest an algorithm for computing Nash equilibria. On the other hand, we saw that the existence of Nash equilibrium in two-player zero-sum games can also be established using #lecture-link("correlated", <sec-zero-sum>)[strong linear programming duality], which suggests a polynomial-time algorithm for computing Nash equilibria in these games.

Similarly, correlated and coarse correlated equilibria in general-sum games can also be computed in time polynomial in the game description using linear programming, as the equilibrium constraints can be written as a system of linear inequalities in the joint distribution over actions. Moreover, linear programming methods can be leveraged to obtain polynomial-time algorithms for certain families of what are called “succinct games,” wherein the payoffs are sparse or have other structure that makes an explicit representation of a joint distribution over actions super-polynomial in  size compared to the game's natural description. Still a correlated or coarse correlated equilibrium can be computed efficiently in many cases, using linear programming approaches such as #lecture-link("eah", <sec-minimax-algorithm>)[Ellipsoid Against Hope]~#citep(<papadimitriou2008computing>).

In this lecture, we revisit Nash equilibrium computation in general games. We will discuss several algorithms for computing Nash equilibria. Roughly speaking those algorithms  fall into two buckets. One bucket contains algorithms that directly target the equilibrium constraints, using linear programming, and more generally algorithms for solving systems of polynomial equations and inequalities. The other bucket contains algorithms that make tighter use of the fixed point nature of Nash equilibrium, and the directed parity argument underlying its existence proofs. In all cases, our algorithms will have super-polynomial complexity, unless the game has special structure. #lecture-link("tfnp", none)[] and #lecture-link("ppad_completeness", none)[] explain the complexity-theoretic obstacles to polynomial-time algorithms.

= Support Enumeration Algorithms

To develop support enumeration algorithms, we will study whether knowing the _support_ of a Nash equilibrium, i.e.~the actions that are assigned non-zero probability, can reduce the computational complexity of solving for a Nash equilibrium. We will start with two-player games and proceed to general-sum games.

== Two-player games

Suppose we have a two-player game where one player has $m$ actions and the other player has $n$ actions. As described in earlier lectures, such games are commonly represented by a pair of $m times n$ matrices $\( R \, C \)$. The actions of one player, called “Row,” are  in one-to-one correspondence with the integers ${ 1 \, ... \, m }$ which  index  the rows of these matrices, and the actions of the other player, called “Column,” are in one-to-one correspondence with the integers ${ 1 \, ... \, n }$ which index the columns of these matrices. In particular, when Row plays action $i$ and Column plays action $j$, they receive payoffs $R_(i j)$ and $C_(i j)$ respectively. When Row uses a distribution $vx$ over ${ 1 \, ... \, m }$ and Column uses a distribution $vy$ over ${ 1 \, ... \, n }$, they  receive expected payoffs $vx^T R vy$ and $vx^T C vy$ respectively. We will assume that each payoff entry in $R$ and $C$ is a rational number whose numerator and denominator can be described using $L$ bits.

Now, suppose that someone told us the supports $S_R$ and $S_C$ of the Row and Column players' mixed strategies, respectively, in some Nash equilibrium of the game. Using this information, we can construct the following linear program to find a Nash equilibrium $\( vx \, vy \)$:

$
               upright("max ") 1 & \
      upright("s.t. ") ve_i^T R vy & >= ve_k^T R vy \, forall i in S_R \, forall k in \[ m \] \
                       vx^T C ve_j & >= vx^T C ve_k \, forall j in S_C \, forall k in \[ n \] \
                     sum x_i = 1 & upright(" and ") sum y_i = 1 \
  x_i >= 0 \, forall i in S_R & upright(" and ") x_i = 0 \, forall i in \[ m \] \\ S_R \
  y_j >= 0 \, forall j in S_C & upright(" and ") y_j = 0 \, forall j in \[ n \] \\ S_C
$

The feasibility of this linear program follows from the fact that $S_R$ and $S_C$ are the supports in some Nash equilibrium of the game. This Nash equilibrium is a feasible solution to this linear program. In the other direction, any feasible solution to the above linear program is a Nash equilibrium. This is because if $\( vx \, vy \)$ is a feasible solution to the above linear program, then $vx$ places positive probability only on a subset of $S_R$ and  $vy$ places positive probability only on a subset of $S_C$. At the same time, the first couple of constraints imply that any action in $S_R$ must be a best response to $vy$ and any action in $S_C$ must be a best response to $vy$. Putting these together we have the implications, which mean that $\( vx \, vy \)$ is a Nash equilibrium:

$
  & forall i : med med x_i > 0 med med => i in S_R med med => i med upright("is a best response to ") vy \; med upright("and")\
  & forall j : med med y_j > 0 med med => j in S_C med => j med upright("is a best response to ") vx .
$

If we don't  know the supports of some Nash equilibrium, we can enumerate over all possible pairs of supports $\( S_R \, S_C \) subset.eq \[ m \] times \[ n \]$, and try to find a feasible solution of the corresponding linear program. As a Nash equilibrium always exists, at least one of these linear programs will be feasible. So the overall running time will be $2^(m + n) dot.op op("poly") \( \| R \| \, \| C \| \)$, where the $2^(m + n)$ factor is due to trying all possible pairs of supports, and the polynomial factor in the descriptions of the matrices $R$ and $C$ is determined by the complexity of solving a linear program.

As a corollary of the correctness of the above algorithm, we also get a proof of the existence of Nash equilibria that use rational numbers of polynomial bit complexity in the size of the game.

#corollary[
  In any two-player game, there exists a Nash equilibrium whose mixed strategies use only rational numbers in their probability distributions. Moreover, these numbers have polynomial bit complexity in the bit complexity required to represent the payoff matrices of the game.
]

#proof[
  This follows from the correctness of the support enumeration algorithm. If there is a Nash equilibrium with supports $S_R$ and $S_C$, then the polytope of the corresponding LP is non-empty and any feasible solution is a Nash equilibrium. In particular, any vertex is a Nash equilibrium, and any vertex is a vector of rational numbers whose bit complexity is polynomial in the description of the LP, and hence the description of the game.
]

As illustrated by the #lecture-link("correlated", <sec-irrational-equilibria>)[irrational-equilibrium example], however, the corollary is not true for $k$-player games where $k > 2$. Indeed, Nash's 1951 paper~#citep(<Nash51:NonCooperative>) already gave an example of a 3-player game that only has irrational equilibria.

== $n$-player games
#label("sec:support enumeration for n players")

Now, let's consider how to generalize the approach to $n$-player games, for $n > 2$. Suppose that someone told us the support $S_i subset.eq A_i$ of each player $i$'s mixed strategy in some Nash equilibrium of the game. Given this information, we could solve the following program to find a Nash equilibrium $vx = \( vx_1 \, ... \, vx_n \) in Delta \( A_1 \) times ... times Delta \( A_n \)$:

$
  forall med upright("player") med i : med med med & u_i \( a_i \; vx_(- i) \) >= u_i \( a'_i \; vx_(- i) \) \, forall a_i in S_i \, forall a'_i in A_i \;\
  & sum_(a_i in A_i) x_(i \, a_i) = 1 \;\
  & x_(i \, a_i) >= 0 \, forall a_i in S_i \;\
  & x_(i \, a_i) = 0 \, forall a_i in A_i \\ S_i .
$

Indeed, if there is a Nash equilibrium $vx = \( vx_1 \, ... \, vx_n \)$ where each $vx_i$ has support $S_i$, then this Nash equilibrium is a solution to the above system of polynomial equations and inequalities. In the other direction, any feasible solution $vx = \( vx_1 \, ... \, vx_n \)$ to the above system is a Nash equilibrium. Indeed, any feasible solution satisfies that for all players $i$, $vx_i$ assigns positive probability to a subset of $S_i$. Moreover, any action in $S_i$ is a best response to $vx_(- i)$. Putting these together we have the following implications, which mean that $vx$ is a Nash equilibrium:

$
  forall med upright("players") med i \, forall a_i in A_i : med med x_(i \, a_i) > 0 med med => a_i in S_i med med => a_i med upright("is a best response to ") vx_(- i) .
$

However, notice that now $u_i \( a_i \; vx_(- i) \)$ is not linear in $vx$, but a polynomial of degree $n - 1$. So the above problem amounts to solving a system of polynomial equations and inequalities in the variables $vx$.

To analyze the running time, let us suppose for simplicity that every player has $k$ actions. Then the above problem is a system of $M = O \( n dot.op k^2 \)$ polynomial equations and inequalities, of degree $D = n - 1$ in $N = n dot.op k$ variables.#footnote[We can reduce the number of constraints to $M = O \( n dot.op k \)$ as, if we are a bit less wasteful, we can write $O \( k \)$ as opposed to $O \( k^2 \)$ constraints per player. But this won't affect the running-time asymptotics.] This can be solved, to $B$ bits of accuracy per variable, using tools from the existential theory of the reals~#citep(<renegar1992computational>), in time

$ B dot.op \( n k^n \) dot.op L dot.op \( M D \)^(O \( N \)) = B dot.op L dot.op \( n k \)^(O \( n k \)) \, $

where $L$ is the number of bits needed to represent a single payoff entry in the game.#footnote[The factor of $\( n k^n \)$ on the left hand side of the afore-stated running time is for converting all the payoffs in the game, which are rational numbers with $L$ bits in the numerator and the denominator, to integers by multiplying all numbers with their least common multiple.]  Enumerating over all possible supports incurs an additional factor of $2^(n k)$ so the overall running time to compute a Nash equilibrium with $B$ bits of accuracy per entry is:

$ B dot.op L dot.op \( n k \)^(O \( n k \)) . $

Recall that the bits required to represent a $n$-player game with $k$ actions per player is $L dot.op n dot.op k^n$. So the running time of our algorithm could be exponential in the description of the game, e.g.~when $n$ stays constant and $k$ goes to infinity. On the other hand, the running time is quasi-polynomial if the growth of $k$ is bounded by a polynomial in $n$.#footnote[A _quasi-polynomial-time algorithm_ for some computational task is an algorithm that solves an instance $Pi$ of the task in time $2^(op("poly") \( log d \( Pi \) \))$, where $d \( Pi \)$ is the description complexity of instance $Pi$. If the polynomial in the exponent of the running time is of degree $1$ the algorithm is called _polynomial-time_.]

#exercise[
  For a two-player game, given the supports $S_C$ and $S_R$, if there are finitely many Nash equilibria with that support, must there be only one? What about an n-player game?
] <S01-ImprovementP3.3>

= Algorithms for Symmetric Games
#label("sec:symmetric games")

We will now discuss whether the running times of our algorithms from the previous section can be improved for the class of _symmetric_ games.

#definition[
  A $n$-player game is called _symmetric_ iff:

  - All players have the same set of actions: $A_1 = dots.h.c = A_n = { 1 \, . . . \, k }$; and
  - there exists some function $f$ of $k + 1$ arguments such that every player $i$'s utility can be written as: $u_i \( a_i \; a_(- i) \) = f \( a_i \; n_1 \( a_(- i) \) \, . . . \, n_k \( a_(- i) \) \)$, where $n_j \( a_(- i) \)$ is the number of players choosing action $j$ in action profile $a_(- i)$.

  That is, all players have the same set of actions, and all players have the same utility function that depends on their own action and the number of other players choosing each action.
]

For example, rock-paper-scissors is a two-player symmetric game. Guess-$2 / 3$-of-the-average,#footnote[#link("https://en.wikipedia.org/wiki/Guess_2/3_of_the_average")] where $n$ players submit numbers in ${ 0 \, ... \, 100 }$ and whoever is closest to $2 \/ 3$s of the average wins $\$ 1$, which is split uniformly if there are ties, is a multi-player symmetric game. Also, congestion games, where players choose paths between the same source and destination nodes in some network and they suffer traffic depending on the number of players using each edge on their path, are symmetric games. Notice that describing symmetric games can be done much more succinctly than general games. In particular, a $n$-player $k$-action symmetric game can be described by specifying $O \( min { k n^(k - 1) \, k^n } \)$ numbers, which are exponentially fewer compared to the $O \( n k^n \)$ numbers needed to describe an abitrary game, when $n$ is large and $k$ is small.

== Symmetric equilibria: existence and computation

In rock-paper-scissors, the unique Nash equilibrium of the game is symmetric, i.e.~both players use the uniform mixture over their actions. More generally, a symmetric Nash equilibrium is defined as follows.

#definition[
  In a symmetric game, a Nash equilibrium $vx = \( vx_1 \, ... \, vx_n \)$ is called _symmetric_ if $vx_1 = vx_2 = ... = vx_n$, i.e.~all players use the same mixed strategy.
]

While rock-paper-scissors has a symmetric Nash equilibrium, it is a priori not clear whether symmetric games ought to have a symmetric Nash equilibrium. As it turns out, this must be the case, as was shown by Nash in his 1951 paper. Indeed, Nash showed a more general statement than the statement below.

#theorem[#citep(<Nash51:NonCooperative>)][
  In every symmetric game, there exists a symmetric Nash equilibrium.
]#label("thm:existence of symmetric equilibria")

#proof[
  Recall the #lecture-link("nfgs_nash", <def-nash-improvement>)[Nash improvement function] $f : times_i Delta \( A_i \) -> times_i Delta \( A_i \)$, which maps some $vx$ to a $vy$ defined as follows, for all players $i$ and actions $a_i in A_i$:

  $
    y_(i \, a_i) = frac(x_(i \, a_i) + max \( 0 \, u_i \( a_i \; vx_(- i) \) - u_i \( vx \) \), 1 + sum_(a'_i in A_i) max \( 0 \, u_i \( a'_i \; vx_(- i) \) - u_i \( vx \) \)) .
  $

  Suppose we restrict the domain of Nash's function to the set:

  $ times_i Delta \( A_i \) ∩ { vx_1 = vx_2 = . . . = vx_n } . $

  Then the range of the function will be a subset of this same restricted set, since every player performs the same “update” in the function $f$. So $f$ maps points of the restricted set to points in the same set. Moreover, the set is convex, closed and bounded. So we can use Brouwer's fixed point theorem to show the existence of a fixed point in the restricted set. This fixed point is a Nash equilibrium by the #lecture-link("nfgs_nash", <thm-nash-fixed-points>)[fixed-point characterization of Nash equilibria]. And since it belongs to the restricted set, it must be a symmetric one.
]

A symmetric Nash equilibrium $vx = \( vx_1 \, ... \, vx_n \)$, where $vx_1 = ... = vx_n \,$ of a $n$-player $k$-action symmetric game can be found as follows:

- Guess the support of $vx_i$: $2^k$ possibilities;
- Write down a system of polynomial equations and inequalities corresponding to the Nash equilibrium conditions for the guessed support. This is a simplified version of the system we wrote down for general games in Section~#ref(label("sec:support enumeration for n players"), supplement: none). Done well, the total number of constraints is $M = O \( k \)$. The polynomials involved have degree $D = n - 1$ in $N = k$ variables (c.f.~$k dot.op n$ variables for general games), so the system can be solved to $B$ bits of accuracy per variable using the existential theory of the reals in a number of operations equal to:

  $
    min { k n^(k - 1) \, k^n } dot.op L dot.op \( D dot.op M \)^(O \( N \)) equiv min { k n^(k - 1) \, k^n } dot.op L dot.op \( k n \)^(O \( k \)) \,
  $

  where $L$ is the number of bits needed to represent a single payoff entry in the game.#footnote[As above, the factor of $min { k n^(k - 1) \, k^n }$ in the afore-stated running time is for converting all the payoffs in the game, which are rational numbers with $L$ bits in the numerator and the denominator, to integers by multiplying all numbers with their least common multiple.]

So the overall running time is  $min { k n^(k - 1) \, k^n } dot.op L dot.op \( k n \)^(O \( k \)) \,$ which is polynomial in the description of the game if $k = O \( n \)$.

== Symmetrization
<sec:symmetrization>

In the previous section, we saw that, when the number of actions $k = O \( n \)$ and the game is symmetric, Nash equilibria can be computed in polynomial time via support enumeration and solving systems of polynomial equations and inequalities. Can we hope to get a polynomial-time algorithm when $k = omega \( n \)$?

We will show that this is impossible for two-player symmetric games, unless there is a polynomial-time algorithms for arbitrary two-player games. In particular, we will show a polynomial-time reduction from the problem of computing a Nash equilibrium in general two-player games to the problem of computing a Nash equilibrium in two-player symmetric games. The reduction we present is due to Gale, Kuhn and Tucker~#citep(<GaleKuhnTucker52>).

Suppose that we are given an arbitrary two-player game $cal(G)_1 := \( R \, C \)$ and we want to compute a Nash equilibrium of this game. Given the following simple exercise, we will assume, without loss of generality, that $R$ and $C$  have strictly positive entries, i.e.~that $R \, C in bb(R)_(>0)^(m times n) \,$ where $m$ and $n$ are, respectively, the number of actions of the row and column players.

#exercise[
  Show that computing a Nash equilibrium of an arbitrary game $cal(G)$ can be polynomial-time reduced to the problem of computing a Nash equilibrium of a game $cal(G)'$ whose payoff entries are all strictly positive.
] <S01-ImprovementP3.1>

Next, we will construct a $\( m + n \) times \( m + n \)$ symmetric game $cal(G)_2$, with the following payoff matrices in block form:

$ cal(G)_2 := mat(delim: "(", 0 \, 0, R \, C; C^T \, R^T, 0 \, 0) . $

#theorem[
  Given a Nash equilibrium of $cal(G)_2$, we can efficiently compute a Nash equilibrium of $cal(G)_1$.
]

#proof[
  Suppose we are given a Nash equilibrium of $cal(G)_2$. We denote this equilibrium by $\( \[ vx_1 \; vy_1 \] \, \[ vx_2 \; vy_2 \] \)$, where $\[ vx_1 \; vy_1 \]$ is the mixed strategy of the row player and $\[ vx_2 \; vy_2 \]$ the mixed strategy of the column player in block form, as shown in the following diagram:

  #table(
    stroke: none,
    columns: 3,
    align: center,
    inset: .5em,
    [], [$vx_2$], [$vy_2$],
    [$vx_1$], [$0 \, 0$], [$R \, C$],
    [$vy_1$], [$C^T \, R^T$], [$0 \, 0$],
  )

  First, at least one of $vx_1$ and $vy_1$ must be nonzero. Assume WLOG that $vx_1 != 0$. We claim the following:

  #claim[
    $vx_1 != 0$ implies that $vy_2 != 0$.
  ] <claim1>

  #proof[
    Using our positivity assumption for the entries of the game, if $vy_2 = 0$, then the row player in game $cal(G)_2$ could improve her expected payoff by setting $vx_1 = 0$ and adding $norm(vx_1)_1$ probability to any action in the bottom block. This contradicts that $\( \[ vx_1 \; vy_1 \] \, \[ vx_2 \; vy_2 \] \)$ is a Nash equilibrium.
  ]

  #claim[
    Let $hat(vx)_1 = frac(vx_1, norm(vx_1)_1)$ and $hat(vy)_2 = frac(vy_2, norm(vy_2)_1)$. Then $\( hat(vx)_1 \, hat(vy)_2 \)$ is a Nash equilibrium of $\( R \, C \)$.
  ] <claim2>

  #proof[
    By contradiction. Suppose $\( hat(vx)_1 \, hat(vy)_2 \)$ is not a Nash equilibrium of $cal(G)_1$. Then without loss of generality the row player can improve her expected payoff by switching to some $tilde(vx)_1$. Then

    #math.equation(block: true, numbering: "(1)", $tilde(vx)_1^T R hat(vy)_2 > hat(vx)_1^T R hat(vy)_2 .$.body)#label(
      "eq:symmetrization proof",
    )

    #subclaim[
      #ref(label("eq:symmetrization proof")) implies that the row player in $cal(G)_2$ can improve her payoff by switching to $\[ tilde(vx)_1 dot.op norm(vx_1)_1 \; vy_1 \]$ from $\[ hat(vx)_1 dot.op norm(vx_1)_1 \; vy_1 \]$.
    ] <subclaim1>

    #proof[Subclaim~#ref(<subclaim1>, supplement: none)][
      The expected payoff of the row player in $cal(G)_2$ from mixed strategy $\[ tilde(vx)_1 dot.op norm(vx_1)_1 \; vy_1 \]$ is

      $ norm(vx_1)_1 dot.op tilde(vx)_1^T R vy_2 + vy_1^T C^T vx_2 . $

      Her expected payoff from the mixed strategy $\[ hat(vx)_1 dot.op norm(vx_1)_1 \; vy_1 \]$ is

      $ norm(vx_1)_1 dot.op hat(vx)_1^T R vy_2 + vy_1^T C^T vx_2 . $

      The first of these payoffs is strictly larger, due to~#ref(label("eq:symmetrization proof")). This concludes the proof of the subclaim.
    ]

    Given Subclaim~#ref(<subclaim1>, supplement: none), we get a contradiction to our assumption that $\( \[ vx_1 \; vy_1 \] \, \[ vx_2 \; vy_2 \] \)$ is a Nash equilibrium of $cal(G)_2$.
  ]
]

We conclude that finding a Nash equilibrium in general two-player games can be polynomial-time reduced to the same problem for symmetric two-player games. An interesting open problem is whether this kind of symmetrization reduction can be generalized to games with more than $2$ players.

#open-problem[
  Is there a polynomial-time reduction from general $3$-player games to symmetric $3$-player games?
]

= The Lemke-Howson Algorithm <sec-lemke-howson>

Switching gears from the previous sections, we turn to algorithms for computing equilibria that exploit the fixed point nature of  Nash equilibrium   at a deeper level. In particular, we describe the celebrated Lemke and Howson algorithm~#citep(<LemkeHowson64>), which was proposed in 1964 as a method to compute an exact Nash equilibrium of a two-player game $\( R \, C \)$ whose entries are rational numbers. This is a feasible task, as there always exists a Nash equilibrium using rational probabilities, as we have seen earlier. Indeed, the correctness proof this algorithm not only proves this fact but also that a Nash equilibrium exists. As such, the correctness proof of this algorithm provides an alternative proof of the existence of Nash equilibria in two-player games, which does not make use of Brouwer's fixed point theorem. As we will see, the proof will be reminiscent of the #lecture-link("brouwer", <sec-sperner-proof>)[proof of Sperner's lemma], and there is a deeper reason for that, as the #lecture-link("tfnp", <sec-ppad-encoding>)[PPAD reduction] makes precise.

== Preparation: symmetry and non-degeneracy

To simplify our presentation, we will assume that the input game is a symmetric $n times n$ game, i.e. $C = R^T$, and we will target finding a symmetric equilibrium of this game, which is guaranteed to exist by Theorem~#ref(label("thm:existence of symmetric equilibria"), supplement: none). From our work in Section~#ref(<sec:symmetrization>, supplement: none), we can make this assumption that the game is symmetric without loss of generality. Indeed, if a given game is asymmetric we can polynomial-time reduce it to a symmetric one. The original version of the Lemke-Howson algorithm applies directly to asymmetric games, but we believe that its presentation for symmetric games is a bit simpler.

The idea of the algorithm is to perform pivoting steps between the vertices of a polytope related to the game until a Nash equilibrium is found. The ($n$-dimensional) polytope of interest is given by

$ R dot.op vz <= vone \, vz >= 0 \, $

where $vz$ is an $n$-dimensional vector.

We now make an additional assumption:  at every vertex of the above polytope, exactly $n$ out of the $2 n$ inequalities are tight. We can make this assumption because if it is not true, we can perturb the original game entries with exponentially small noise to make it happen. The equilibria of the perturbed game will be approximate equilibria of the original game, and these can be converted to exact equilibria, as long as the noise that was added to the original game is sufficiently small. This is what the following exercise asks you to do:

#exercise[
  Part 1. Show that the Lemke-Howson polytope can be perturbed with exponentially small noise so that at every vertex exactly $n$ of the inequalities are tight. Part 2. Show that, given  a Nash equilibrium of the perturbed game, an equilibrium of the original game can be recovered in polynomial time.
]

== Main description of the algorithm

With the above setup, let us proceed to the meat of the algorithm. We make the following definition.

#definition[
  Action $i$ is _represented_ at a vertex $vz$ of the polytope if at least one of the following inequalities is tight:

  $ z_i >= 0 $

  $ ve_i^T R vz <= 1 $

  Furthermore, we call any vertex of the polytope where all actions are represented a _democracy_.
]

Notice that $\( 0 \, 0 \, ... \, 0 \)$ is a democracy according to our definition. We make an interesting observation about democracies.

#lemma[
  If a vertex $vz != 0$ of the polytope is a democracy, then $\( frac(vz, norm(vz)_1) \, frac(vz, norm(vz)_1) \)$ is a Nash equilibrium.
]

#proof[
  At a democracy we have the following implication:

  $ forall i : med med med z_i > 0 ==> ve_i^T R vz = 1 . $

  Hence

  $ forall i : med med med z_i > 0 ==> ve_i^T R vz >= ve_j^T R vz \, forall j $

  and after normalization:

  $
    forall i : med med med frac(1, norm(vz)_1) dot.op z_i > 0 ==> ve_i^T R dot.op frac(vz, norm(vz)_1) >= ve_j^T R dot.op frac(vz, norm(vz)_1) \, forall j .
  $

  Notice that these are exactly the equilibrium conditions for $\( frac(vz, norm(vz)_1) \, frac(vz, norm(vz)_1) \)$ to be a symmetric Nash equilibrium of the game.
]

The goal of the Lemke-Howson algorithm is to find a democracy in the given polytope. Let's call $n$ the “special action,” albeit this choice is arbitrary. The procedure is given in @algo-lemke-howson.

#pseudocode-list(
  max-width: true,
  numbered-title: [Lemke-Howson],
)[
  - *Data:* the polytope $P := { vz : R vz <= vone \, vz >= 0 }$ and the special action $n$.
  - *Result:* a non-zero democracy of $P$.
  + $t <- 0 \, quad vv_0 <- \( 0 \, 0 \, ... \, 0 \)$
  + $u <- \( z_n >= 0 \)$ 
  + *loop*
    + $E <-$ the edge of $P$ obtained by un-tightening $u$ at $vv_t$, keeping tight every other inequality that is tight at $vv_t$ 
    + $vv_(t + 1) <-$ the endpoint of $E$ other than $vv_t$
    + $t <- t + 1$
    + *if* $vv_t$ is a democracy
      + *return* $vv_t$
    + $j <-$ the action represented twice at $vv_t$ 
    + $u <-$ the inequality representing action $j$ that was already tight at $vv_(t-1)$ (and not the one that became tight upon reaching $vv_t$). 
] <algo-lemke-howson>

Each pivot is well defined. By non-degeneracy exactly $n$ inequalities are tight at every vertex, so the un-tightening in the edge-update step in @algo-lemke-howson always traverses an edge of the polytope. At $vv_0$ the tight inequalities are exactly $z_1 >= 0 \, ... \, z_n >= 0$, so there are exactly $n$ edges adjacent to $vv_0$, one per action, and the initialization step in @algo-lemke-howson selects the one belonging to the special action $n$.

The choice made in the pivot step in @algo-lemke-howson never retraces the step just taken. Both $z_j >= 0$ and $ve_j^T R vz <= 1$ are tight at $vv_t$, and un-tightening the one that just became tight would define the same edge $\( vv_(t - 1) vv_t \)$ that brought us to $vv_t$. Un-tightening the other inequality representing action $j$ makes progress instead.

Finally, the selection of the doubly represented action in @algo-lemke-howson is justified by the following property of the walk: whenever the algorithm reaches it, all actions in ${ 1 \, ... \, n - 1 }$ are represented at $vv_t$, exactly one of them is represented twice, and the special action $n$ is not represented at all.

At $vv_1$ the property holds whenever $vv_1$ is not a democracy. If $vv_1$ is a democracy, the algorithm has already returned. The inequalities kept tight on the way from $vv_0$ are $z_1 >= 0 \, ... \, z_(n - 1) >= 0$, so actions $1$ through $n - 1$ stay represented, while $z_n >= 0$ is no longer tight. Exactly one new inequality becomes tight. If it is $ve_n^T R vz <= 1$, then action $n$ is represented and $vv_1$ is a democracy. Otherwise it is $ve_j^T R vz <= 1$ for some $j != n$, so action $j$ is represented twice and action $n$ is not represented at all.

For every later vertex the same property is the inductive step. Assume it holds at $vv_(t - 1)$. The pivot un-tightens one inequality of the action that was represented twice there, so that action stays represented through the inequality that was kept, and every action that was represented once keeps its tight inequality. Action $n$ was not represented. The single newly tight inequality either represents $n$, making $vv_t$ a democracy, or represents some action in ${ 1 \, ... \, n - 1 }$ a second time, so $vv_t$ again satisfies the property. This is property $Pi$ in the proof below.

We are now ready to show that the algorithm is guaranteed to terminate at a non-zero democracy, thereby recovering a Nash equilibrium of the game. The theorem below shows that the returned vertex is non-zero, so the lemma above turns it into the symmetric Nash equilibrium $vv_t \/ norm(vv_t)_1$.

#theorem[
  The Lemke-Howson algorithm (@algo-lemke-howson) will terminate and it will terminate at a non-zero democracy.
]#label("thm:Lemke-Howson's correctness")

#proof[
  The Lemke-Howson algorithm defines a walk $vv_0 \, ... \, vv_t \, ...$ on the vertices of the polytope. We show that the vertices encountered in this walk satisfy a special property.

  #claim[
    For all $t$, $vv_t$ is either a democracy, or it satisfies the following property:

    #table(
      stroke: none,
      columns: (auto, 1fr),
      align: left + top,
      inset: .5em,
      [$Pi:$],
      [All of the actions in ${ 1 \, ... \, n - 1 }$ are represented at $vv_t$, exactly one of them is represented twice, and action $n$ is not represented at all.],
    )
  ]

  #proof[
    $vv_0$ is a democracy. In the description of the algorithm, we justified that $vv_1$ is either a democracy or satisfies property $Pi$. In the description of the algorithm we also justified  that if $vv_(t - 1)$ satisfied property $Pi$ then $vv_t$ is either a democracy or it satisfies property $Pi$.
  ]

  Consider now all the vertices of the polytope that satisfy property $Pi$, as well as all the vertices of the polytope that are democracies. We define an auxiliary graph $G$ on these vertices, where the vertices satisfying property $Pi$ have exactly two neighbors in $G$, and those that are democracies have exactly one neighbor in $G$. In particular,

  - The two neighbors (in $G$) of a vertex $vv$ satisfying property $Pi$ are obtained from the polytope as follows: If $j$ is the action that is represented twice at $vv$, consider un-tightening either $z_j >= 0$ or $ve_j^T R vz <= 1$. Either one will define an edge of the polytope adjacent to $vv$ whose other endpoint is either a democracy or a vertex satisfying property $Pi$. Set those two vertices to be the neighbors of $vv$ in $G$.
  - The single neighbor (in $G$) of a vertex $vv$ that is a democracy is obtained from the polytope as follows: Since $vv$ is a democracy, either $z_n >= 0$ or $ve_n^T R vz <= 1$ is tight. Consider un-tightening whichever inequality is tight. This defines an edge of the polytope whose other endpoint is either a democracy or a vertex satisfying property $Pi$. Set that vertex to be the neighbor of $vv$ in $G$.

  Clearly $G$ comprises paths and cycles, as every vertex has degree either $1$ or $2$. Moreover, all democracies are endpoints of paths in $G$, since they have degree $1$. Let's call “main path” the path that has $vv_0 = \( 0 \, ... \, 0 \)$ as one of its endpoints  and some democracy $vv^(*) != vv_0$ as its other endpoint. The following can be easily shown by induction.

  #claim[
    The Lemke-Howson algorithm traverses the main path starting from $vv_0$, moving in the direction of $vv^(*)$, visiting every vertex in this path once, and terminating at $vv^(*)$.
  ]

  Given the claim, the proof is concluded.
]

We make some final remarks about the Lemke-Howson algorithm.

- The algorithm provides an alternative proof that a Nash equilibrium exists in 2-player games. In particular, the existence of a Nash equilibrium is implied by the correctness of the algorithm.
- Moreover, it shows that there always exists a rational equilibrium in 2-player games.
- The proof works by virtue of a parity argument, reminiscent of the proof of Sperner’s lemma. It identifies a directed path on the vertices of the polytope whose sink is a solution.
- Its worst-case running time is exponential in the number of actions. This lower bound was established by Savani and von Stengel~#citep(<SavaniVS06>).
- There are generalizations of the Lemke-Howson algorithm for multi-player games working with manifolds instead of polytopes. See Rosenmüller~#citep(<Rosenmuller71>) and Wilson~#citep(<Wilson71>).

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

= Appendix A: Solutions to Selected Exercises

== Solution to #ref(<S01-ImprovementP3.3>)

#toggle[Reveal Solution to #ref(<S01-ImprovementP3.3>)][
  #proof[
  Consider an two-player game $cal(G):= (R,C)$. Suppose we are given the supports $S_R$ and $S_C$ and know that there are finitely many Nash equilibria with these supports. We will prove that there must be only one such Nash equilibrium.

  Assume for sake of contradiction that there are at least two Nash equilibria $(vx_1, vy_1)$ and $(vx_2, vy_2)$ with supports $S_R$ and $S_C$.

  For any $t in [0,1]$, define
  $
    bold(x)_t := t bold(x)_1 + (1-t) bold(x)_2 quad upright("and") quad
    bold(y)_t := t bold(y)_1 + (1-t) bold(y)_2.
  $

  Since both Nash equilibria have the same supports, for every $t in (0,1)$ $vx_t$ and $vy_t$ also have the same supports, since the coordinates corresponding to the common support will be strictly positive for linear combinations.

  We now show that $(bold(x)_t, bold(y)_t)$ is also a Nash equilibrium.

  Since $(bold(x)_1, bold(y)_1)$ and $(bold(x)_2, bold(y)_2)$ are Nash equilibria, every row in $S_R$ is a best response to both $bold(y)_1$ and $bold(y)_2$. Thus, there exist $u_1,u_2 in bb(R)$ such that
  $
  R_(S_R,S_C) bold(y)_1 = u_1 bold(1)
  quad
  upright("and")
  quad
  R_(S_R,S_C) bold(y)_2 = u_2 bold(1).
  $

  where $R_(S_R,S_C)$ is the payoff matrix restricted to the rows and columns of the supports.

  By linearity in the opponent's mixed strategy,
  $
  R_(S_R,S_C) bold(y)_t
  = t R_(S_R,S_C) bold(y)_1
  + (1-t) R_(S_R,S_C) bold(y)_2
  = (t u_1 + (1-t)u_2) bold(1).
  $

  Hence every row in $S_R$ is a best response to $bold(y)_t$.

  Similarly, because every column in $S_C$ is a best response to both $bold(x)_1$ and $bold(x)_2$, we find that every column in $S_C$ is a best response to the linear combination $bold(x)_t$.

  Finally, since $bold(x)_t$ and $bold(y)_t$ assign probability zero to actions outside $S_R$ and $S_C$, respectively, and every action in their supports is a best response to the opponent's strategy, $(bold(x)_t, bold(y)_t)$ is a Nash equilibrium.

  Thus, for every $t in (0,1)$, there is a Nash equilibrium with supports $S_R$ and $S_C$. Since the two original equilibria are distinct, these equilibria are distinct for infinitely many values of $t$.

  This contradicts the assumption that there are only finitely many Nash equilibria with supports $S_R$ and $S_C$. Therefore, there can be only one Nash equilibrium with the given supports in a two-player game.

  \

  In contrast, for $n$-player games with $n >= 3$, the analogous statement is *false*.
  That is, it is possible to have finitely many Nash equilibria with the same supports, but more than one such equilibrium.

  The key difference from the two-player case is that, in an $n$-player
  game, a player's expected payoff is generally *multilinear* in the
  other players' mixed strategies. Thus, the indifference conditions are
  not linear in all players' strategies simultaneously, and they may have
  multiple isolated solutions.

  We present a counterexample in the case of $n=3$. Consider the following symmetric three-player game with two actions,
  $0$ and $1$. For a player, let the difference between the payoff from
  action $1$ and the payoff from action $0$ depend on the number $k$ of
  the other two players who choose action $1$. Define

  $ d(0) = 3, quad d(1) = -5, quad d(2) = 3. $

  Suppose that player $i$ independently chooses action $1$ with
  probability $p_i$. The expected payoff difference between choosing action
  $1$ and choosing action $0$ for player 1 is then

  $ 3(1-p_2)(1-p_3) - 5p_2(1-p_3) - 5(1-p_2)p_3 + 3p_2p_3. $

  Player 1 satisfies the conditions for Nash equilibrium when they are indifferent to the action they take, in other words, when

  $ 3 - 8p_2 - 8p_3 + 16p_2p_3 = 0. $

  Similarly, the other two players require

  $ 3-8p_1-8p_3+16p_1p_3&=0 \
    3-8p_1-8p_2+16p_1p_2&=0. $

  Subtracting pairs of equations yields the equations

  $ (p_1-p_2)(1-2p_3)=0 \
    (p_2-p_3)(1-2p_1)=0 \
    (p_3-p_1)(1-2p_2)=0. $

  Suppose some player chooses to use a mixed strategy with probability $1/2$. Without loss of generality suppose $p_1 = 1/2$. Then the original expected payoff condition for player 2 reduces to

  $ 3-8p_1-8p_3+16p_1p_3& = -1 $

  which contradicts the indifference condition. Thus, there are no Nash equilibria when $p_i = 1/2$, so for Nash equilibrium to hold, we must have $p_1 = p_2 = p_3 = p$, In this case, the indifference conditions reduce to 

  $ 3 - 16p + 16 p^2 = 0, $

  which yields solutions $p = 1/4$ or $p = 3/4. $

  This gives two distinct completely mixed Nash equilibria:

  $ (1/4, 1/4, 1/4)
    quad "and" quad
    (3/4, 3/4, 3/4). $

  Both equilibria have the same support, as every player assigns positive probability to both actions. Furthermore, we have proven that there are no further Nash equilibria for this game. Hence, unlike the two-player case, finiteness of the number of Nash equilibria with a given support does *not* imply uniqueness when there are three or more players.
  ]
]
== Solution to #ref(<S01-ImprovementP3.1>)

#toggle[Reveal Solution to #ref(<S01-ImprovementP3.1>)][
  #proof[
  Consider an arbitrary game $cal(G)$ with $n$ players. We will prove that the problem of computing a Nash equilibrium of $cal(G)$ polynomial-time reduces to the problem of computing a Nash equilibrium of a game $cal(G)'$ whose payoff entries are all strictly positive.
  
  Let the $i$th player in $cal(G)$ choose actions from the set $A_i$ and let $u_1,u_2,...,u_n$ be the payoff functions, where
  
  $
  u_i : A_1 times dots.h.c times A_n -> bb(R).
  $
  
 We also reuse the letter $u_i$ to denote the expected utility when players play according to strategies $bold(x)_1,...,bold(x)_n$.
  
Then for any Nash equilibrium $(bold(x)_1,...,bold(x)_n)$, by definition,

  $
    forall i in \[ n \] \, vx'_i in Delta (A_i) \, #h(2em) #h(2em) u_i (vx'_i \, vx_(- i)) <= u_i (vx_1 \, ... \, vx_n) .
  $

  The key observation is that the Nash equilibrium condition is equivalent up to a scalar translation of the utility function. For each payoff function $u_i$, let $p_i = min(u_i)$ over all payoffs in $u_i$. We will define a new normal-form game $cal(G)'$ with the same players, same actions, and new payoff functions
  
  $
  forall i in \[ n \] \, #h(2em) #h(2em)u_i ' = u_i - p_i + 1.
  $

  We note that $cal(G)'$ can be defined in polynomial-time given $cal(G)$, and all payoff entries of $cal(G)'$ are strictly positive because

  $
  min(u_i ') = min(u_i) - p_i+1 = 1.
  $

  Furthermore,

  $
  forall i in \[ n \] \, vx'_i in Delta (A_i) \, #h(2em) #h(2em) u_i (vx'_i \, vx_(- i)) &<= u_i (vx_1 \, ... \, vx_n) \
  <==> u_i (vx'_i \, vx_(- i)) - p_i+1 &<= u_i (vx_1 \, ... \, vx_n) - p_i+1 \
  <==> u_i ' (vx'_i \, vx_(- i)) &<= u_i ' (vx_1 \, ... \, vx_n),
  $
  
  so every Nash equilibrium of $cal(G)$ is a Nash equilibrium of $cal(G)'$ and vice versa. Thus, computing a Nash equilibrium of an arbitrary game $cal(G)$ can be polynomial-time reduced to the problem of computing a Nash equilibrium of a game $cal(G')$ whose payoff entries are all strictly positive.
  ]

  Potential point of confusion: One might ask if we can adjust all of our utility functions by a constant so that all entries are positive, then can we not use the same trick make all utilities average to zero, and thus reduce all normal-form games to zero-sum games?

  Obviously, the answer is no, we cannot use this trick to reduce all normal form games to zero-sum games. This is because zero-sum games are not defined by the average utility of a single player being zero, but rather by the payoffs summed over all players being zero.

  As an example, suppose we take a very simple two player game $cal(G):=(R,C)$, where the first player has one action and the second player has two actions, with the payoff matrices
  $
    R := mat(delim: "(", 1 \, -1 ) #h(2em) C := mat(delim: "(", 0 \, 1 ).
  $

  Now obviously this is not much of a game, as the outcome is completely controlled by the column player, but we can also see using this example that there is no way to convert this game to a zero-sum game simply by adding a constant to the payoff. By adding any arbitrary constants $r$ and $c$ to the payoff matrices, we can get a game $cal(G)':= (R',C')$ with
  $
    R' := mat(delim: "(", 1+r \, -1+r ) #h(2em) C' := mat(delim: "(", c \, 1+c ),
  $
  which has the same Nash equilibria as $cal(G)$. However, in order for $cal(G)'$ to be a zero-sum game, we would require $R' + C' =0$, which we find is not possible for any constants $r, c$.

  Our constants shift every payoff of a given player by the same amount, and therefore preserve that player's preferences over strategies. In this example, choosing \(c=-1/2\) makes the column player's average of the payoff entries zero (the row player's average of payoff entries is already zero). Nevertheless, the resulting game is not zero-sum, which requires $sum_i u_i=0$, that is, the SUM of all payoffs of all players to be zero for any selection of pure strategies.

]
