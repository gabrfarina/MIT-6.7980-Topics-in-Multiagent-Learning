#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: "S2",
  date: [Fall 2026],
  title: "A second look at the minimax theorem",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

#lecture-link("correlated", <def-cce>)[] introduced the notion of coarse correlated equilibria. As we discussed, coarse correlated equilibria sidestep various difficulties (including topological and related to use of irrational numbers) that come with Nash equilibria. In this lecture, we show a powerful centralized algorithm for computing coarse correlated equilibria. (Soon in this course, we will also see that coarse correlated equilibria can also be #lecture-link("learning_intro", <sec-learning-correlated>)[_learned_ efficiently in a distributed multi-agent setting].)

The #lecture-link("correlated", <sec-cce>)[CCE incentive constraints] give a linear program for computing a coarse correlated equilibrium, in which the variables correspond to the probabilities $mu_(a_1 \, ... \, a_n)$ of the joint actions, and the constraints correspond to the incentive constraints of the players. While this is a perfectly valid way to compute a coarse correlated equilibrium, it has the drawback that the linear program has a number of variables that is exponential in the number of players. This becomes an issue quickly, if we want to consider games with many players. It also is a problem for those games in which the payoff tensor has a succinct representation (for example, a sparse factorization that we can exploit); there, we would ideally want an algorithm that runs in polynomial time in the size of such a succinct representation. The latter is often the case in structured games, which we will see later in this course.

In this lecture, we will see a different algorithm for computing coarse correlated equilibria, which does not suffer from the above issues and requires a number of variables that scales with the _sum_ (rather than _product_!) of the number of actions of the players. The algorithm is called Ellipsoid-Against-Hope, and was introduced by #citet(<papadimitriou2008computing>), with later extensions by other authors #citep(<jiang2011polynomial>, <huang2008computing>, <farina2024polynomial>).

The algorithm is based on a constructive proof of the minimax theorem, which we will also present in this lecture.

= Revisiting the existence of coarse correlated equilibria <sec-cce-existence>

In order to understand why there is hope to compute coarse correlated equilibria more efficiently, it is useful to understand better how we can prove that these equilibria exist in the first place. We will then turn such an existence proof into a computational algorithm.

So far, we have justified the existence of coarse correlated and correlated equilibria through the existence of Nash equilibria. However, one might wonder if there is a more direct way to prove the existence of CEs and CCEs, which does not rely on the existence of a much harder notion. The answer is yes, and the idea comes from a very neat proof by #citet(<Hart89>), which includes some ideas that will set the stage for the Ellipsoid-Against-Hope algorithm.

While the original proof of #citet(<Hart89>) is for CE, I will present here a version of the proof simplified for the case of CCEs.

As a reminder, by definition a coarse correlated equilibrium is a distribution $vmu in Delta (A_1 times ... times A_n)$ such that

$
  bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i))] <= bb(E)_(a ~ vmu) [u_i (a_i \, a_(- i))] #h(2em) forall i in \[ n \] \, a'_i in A_i \,
$

or equivalently,

$
  max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

A CCE then exists if and only if

$
  min_vmu max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

How can we prove the above inequality without resorting to the existence of Nash equilibria? _The rescue comes from the minimax theorem._

Before we can use the minimax theorem, we have to “convexify” the inner problem however, since the maximum is currently on a discrete set. To convexity the problem, we will simply allow the possibility for the internal maximumization problem to propose a _distribution_ $vnu$ over deviations $(i \, a_i)$, and we will rewrite the problem as

$
  min_vmu max_vnu bb(E)_(a ~ vmu) bb(E)_(\( i \, a'_i \) ~ vnu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

By the minimax theorem and swapping the order of the expectations, the above min-max value is equal to

$
  max_vnu min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] .
$

Can we show that this value is $<= 0$? The answer is yes, and constructive: given any $vnu$, we can find a $vmu$ in closed form---in fact, a _product_ distribution---such that the value is $<= 0$.

#theorem[#citet(<Hart89>)][
  Given any distribution $vnu$ over pairs $(i \, a'_i) : i in \[ n \] \, a'_i in A_i$, we can explicitly and efficiently construct a product distribution $vmu in Delta \( A_1 \) ⊗ ... ⊗ Delta \( A_n \)$ such that

  $ bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 . $
]#label("thm:hart schmeidler")

The above theorem immediately implies that

$
  max_vnu min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 \,
$

and using the minimax theorem, we conclude the existence of coarse correlated equilibria.

= Turning the minimax theorem into an efficient algorithm <sec-minimax-algorithm>

As in the #lecture-link("brouwer", <sec-sperner-proof>)[analysis of the existence proof underlying Nash equilibrium], it is worth inspecting where the “magic” happens in the above proof. If we squint our eyes a bit, the argument of the proof looked like this:

+ We want to prove that $min_vmu max_vnu g \( vmu \, vnu \) <= 0$, for an appropriate $g$ that is linear in both $vmu$ and $vnu$. That is, we want to show that there _exists_ a $vmu$ such that _for all_ $vnu$, $g \( vmu \, vnu \) <= 0$.
+ To do that, we instead show that _for all_ $vnu$, there _exists_ a $vmu$ (dependent on $vnu$) such that $g \( vmu \, vnu \) <= 0$. This shows that $max_vnu min_vmu g \( vmu \, vnu \) <= 0$.
+ Then, we use the minimax theorem to swap the order of the quantifiers, and conclude that $min_vmu max_vnu g \( vmu \, vnu \) <= 0$. The use of the minimax theorem in our case was justified because $g \( vmu \, vnu \)$ is linear in both $vmu$ and $vnu$.

It is easy to brush away swapping the order of the quantifiers as just one of the many results in mathematics that are concerned with swapping orders of operators. But let us stop to consider how powerful this is. The original problem was to find a single $vmu^(*)$ that works for all $vnu$ (Step 1). However, the minimax theorem (Step 3) tells us that as long as for any specific $vnu$ we can construct a $vmu \( vnu \)$ that works _for that $vnu$ specifically_, then a $vmu^(*)$ that works for any $vnu$ (not for one specific) must exist (Step 2). It feels way less simple than it looks at first sight, right?

The Ellipsoid-Against-Hope algorithm can then be seen as a way to convert the minimax theorem from a tool guaranteeing existence into a computational algorithm. In particular, the idea is the following:

- We will query a few “well-chosen” distributions $vnu_t$, and for each of them, construct the corresponding $vmu \( vnu_t \)$ that works for that specific $vnu_t$. The number of queries will be small, polynomial in the sum of the number of actions of the players and $log \( 1 \/ epsilon.alt \)$.
- Then, we will combine all the $vmu \( vnu_t \)$ we have constructed into a single $vmu^(*)$ that works for all $vnu$. In particular, the $vmu^(*)$ will be a convex combination of the $vmu \( vnu_t \)$ we have constructed, with coefficients that can be computed efficiently by solving a linear program with a number of variables that is again polynomial in the sum of the number of actions of the players and $log \( 1 \/ epsilon.alt \)$.

Combining the two steps above, we will have constructed a $vmu^(*)$ that is an $epsilon.alt$-coarse correlated equilibrium, and that can be represented as a convex combination of product distributions. In other words, we have shown the following corollary.

#corollary[
  Assume rational, bounded payoffs and an oracle that evaluates expected payoffs under product distributions in polynomial time. Then an $epsilon.alt$-coarse correlated equilibrium can be computed in time polynomial in the representation size, payoff encoding length, the sum of the numbers of actions, and $log \( 1 \/ epsilon.alt \)$. Such a coarse correlated equilibrium is represented as a convex combination of product distributions.
]

== Sketch of the Ellipsoid-Against-Hope algorithm

In more detail, what #ref(label("thm:hart schmeidler")) implies is that the following open polytope must be empty:

$
  {vnu in Delta {(i \, a'_i) : i in \[ n \] \, a_i in A_i} : bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] > 0\
    forall vmu in Delta (A_1 times ... times A_n)} .
$

Furthermore, for any $vnu$, we know how to prove that at least one of the constraints is violated. The key idea is then to use the ellipsoid method to _certify_ the emptiness of the polytope. Normally, the ellipsoid method is used to find a point in a set, but in our case, the point does not exist and we want to use the ellipsoid method to isolate constraints that prove the emptiness of the set. For this reason, the algorithm was called Ellipsoid-Against-Hope by #citet(<papadimitriou2008computing>).

The ellipsoid will maintain a search space which can be thought of as a suitable subset of the deviator's set. At every iteration $t$, the algorithm will compute the center point $vnu_t$ of the set. Then, it will find a violated constraint using the distribution $vmu_t := vmu \( vnu_t \)$ in the proof of #ref(label("thm:hart schmeidler")). The violated constraint implies that the deviator set must be curtailed, and the ellipsoid will be updated accordingly reducing the size of the search space by a constant. The algorithm will continue until the search space is small enough to guarantee that the set is empty. The iteration count also depends polynomially on the dimension and encoding/conditioning bounds. For an approximate guarantee, use constraints with a positive $epsilon.alt$ margin and the corresponding separation and volume bounds; shrinking an arbitrary open set does not by itself certify exact emptiness. The following algebra describes the exact finite certificate when one has been obtained. By the last iteration $T$, the algorithm will have produced several violated constraints, each of which is associated with a mediator strategy $vmu_t$. The set

$
  {vnu in Delta {(i \, a_i) : i in \[ n \] \, a_i in A_i} : bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu_1) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] > 0\
    dots.v\
    bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu_T) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] > 0} .
$

The constraints of the set are all linear in $vnu$, and the set is empty. By Farkas' lemma, there must exist a convex combination of the constraints the makes all the coefficients on the left-hand size non-positive. In other words, there must exist $alpha_1 \, ... \, alpha_T >= 0$ with $sum_t alpha_t=1$ such that

$
  sum_(t = 1)^T alpha_t bb(E)_(a ~ vmu_t) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 \, #h(2em) forall i in \[ n \] \, a'_i in A_i .
$

Letting $macron(vmu) := sum_(t = 1)^T alpha_t vmu_t$, we can then write

$
  bb(E)_(a ~ macron(vmu)) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 \, #h(2em) forall i in \[ n \] \, a'_i in A_i \,
$

and hence $macron(vmu)$ is a coarse correlated equilibrium. The only question is whether this combination ${ alpha_t }$ can computed efficiently. This is indeed the case, as we can use linear programming directly to find such a combination, by solving the feasibility program

$
  upright("find") & alpha_1 \, ... \, alpha_T >= 0\
  upright("s.t.") & sum_(t = 1)^T alpha_t bb(E)_(a ~ vmu_t) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 #h(2em) forall i in \[ n \] \, a'_i in A_i\
  & alpha_1 + ... + alpha_T = 1 .
$

This completes the sketch of the proof of the correctness of the Ellipsoid-Against-Hope algorithm.

== Applications beyond normal-form games

The above argument mostly uses ideas from convex optimization. In particular, it extends, with suitable oracle and encoding assumptions, to _multilinear games on compact convex domains_, that is, any setting with the following properties:

- Player $i$'s strategy set is a nonempty compact convex set of some dimension $d_i$, with suitable rational descriptions or geometric bounds for the ellipsoid method. For normal-form games, a strategy is an element of $Delta \( A_i \)$, that is, a distribution over the player's strategies. We assume an efficient separation oracle with the bit-complexity and geometric bounds required by convex optimization.
- The utility function $u_i \( vx_1 \, ... \, vx_n \)$ is linear in each player's strategy. For normal-form games, this is true since the utility is just an expectation.
- The utility function $u_i \( vx_1 \, ... \, vx_n \)$ can be evaluated efficiently, let's say in time $R$.

The Ellipsoid-Against-Hope algorithm can then be applied and has polynomial complexity in $sum_i^n d_i$, oracle costs, encoding and geometric bounds, and $log \( 1 \/ epsilon.alt \)$. Applications include polymatrix games and finite perfect-recall extensive-form games; a succinct game representation must be checked for the required oracles before applying the result. We will see some of these games later in this course.

= Bibliographic remarks

If you are curious to read more, the following papers contains extensions and refinements of the idea of Ellipsoid-Against-Hope.

#lec_bibliography("meta/refs.bib", title: none)

#appendix[
  = Appendix: Proof of Theorem~#ref(label("thm:hart schmeidler"), supplement: none)

  Let $s_i=sum_(a_i in A_i) nu_(i,a_i)$ be the total mass assigned to player $i$'s deviations. If $s_i>0$, set $mu_(i)(a_i)=nu_(i,a_i)/s_i$; if $s_i=0$, choose any distribution $vmu_i$ on $A_i$. Let $vmu=vmu_1 times ... times vmu_n$ be their product distribution.

  For $s_i>0$, averaging the deviating action according to $vnu_(i,dot)/s_i$ is exactly the same as drawing it from $vmu_i$, independently of the opponents. Therefore
  $
    sum_(a'_i) nu_(i,a'_i) EE_(a ~ vmu)[u_(i)(a'_i,a_(-i))-u_(i)(a_i,a_(-i))] = s_(i)(EE_(a ~ vmu)[u_(i)(a)]-EE_(a ~ vmu)[u_(i)(a)])=0.
  $
  If $s_i=0$, the same expression is zero because all its coefficients vanish. Sum over players to obtain the theorem, with equality. This normalization also handles zero-mass players, for whom an unnormalized product of the $vnu$ entries would not define a probability distribution.
]
