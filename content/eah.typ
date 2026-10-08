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

While the original proof of #citet(<Hart89>) is for CE, we present here a version of the proof simplified for the case of CCEs.

Recall from #lecture-link("correlated", <def-cce>)[] that a coarse correlated equilibrium is a distribution $vmu in Delta (A_1 times ... times A_n)$ such that

$
  bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i))] <= bb(E)_(a ~ vmu) [u_i (a_i \, a_(- i))] #h(2em) forall i in \[ n \] \, a'_i in A_i .
$

Equivalently, moving the right-hand side to the left, the expected gain from every unilateral fixed deviation must be nonpositive:

$
  bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 #h(2em) forall i in \[ n \] \, a'_i in A_i .
$

Since the above inequality must hold for every deviation, it is equivalent to requiring that even the largest deviation gain be nonpositive:

$
  max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

The distribution $vmu$ ranges over

$
  Delta (A_1 times ... times A_n) \,
$

the set of all joint distributions over action profiles. Since the action sets are finite, this set is a finite-dimensional probability simplex, and is therefore compact and convex.

Thus, proving that a CCE exists amounts to showing that there is some feasible $vmu$ for which the largest deviation gain is at most $0$. Equivalently, we can minimize this largest deviation gain over all feasible joint distributions and ask whether the resulting value is nonpositive:

$
  min_(vmu in Delta (A_1 times ... times A_n)) max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

Indeed, if some $vmu$ makes the largest deviation gain nonpositive, then the minimum above is also nonpositive. Conversely, because the feasible set is compact and the objective is continuous, the minimum is attained; if the minimum is nonpositive, a minimizing distribution is a CCE.

How can we prove the above inequality without resorting to the existence of Nash equilibria?

_The rescue comes from the minimax theorem._

Before we can use the minimax theorem, however, we have to “convexify” the inner problem. The outer minimization already ranges over a compact convex simplex, but the inner maximization currently ranges over the discrete set of deviations

$
  (i \, a'_i) \, #h(2em) i in \[ n \] \, a'_i in A_i .
$

This set is finite, but it is not itself convex. To place both optimization problems in the convex setting required by the minimax theorem, we convexify the inner problem.

To convexify the problem, we simply allow the possibility for the inner maximization problem to propose a _distribution_ $vnu$ over deviations $(i \, a'_i)$. In other words, $vnu in Delta ({(i \, a'_i) : i in \[ n \] \, a'_i in A_i})$.

Since there are finitely many deviations, the set of all such distributions is again a finite-dimensional probability simplex, and is therefore compact and convex.

Importantly, allowing the inner maximization to randomize over deviations does not change its optimal value. To see this, fix any $vmu$. Under a distribution $vnu$, the expected deviation gain is a weighted average of the gains of the individual deviations:

$
  bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] .
$

A weighted average cannot exceed the largest value being averaged. Therefore,

$
  & bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad <= max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]
$

for every $vnu$.

Conversely, if $(i^* \, a'_(i^*))$ is a deviation attaining the maximum on the right-hand side, we may choose $vnu$ to place probability one on that single deviation. The expected gain under $vnu$ then equals the largest individual deviation gain. Hence,

$
  & max_(vnu in Delta ({(i \, a'_i) : i in \[ n \] \, a'_i in A_i})) bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad = max_(i in \[ n \]\
  a'_i in A_i) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] .
$

Thus, convexifying the inner problem changes its feasible set but not its optimal value.

We can therefore rewrite the CCE existence problem as

$
  min_vmu max_vnu bb(E)_(a ~ vmu) bb(E)_(\( i \, a'_i \) ~ vnu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 \,
$

where, from now on, $vmu in Delta (A_1 times ... times A_n)$ and $vnu in Delta ({(i \, a'_i) : i in \[ n \] \, a'_i in A_i})$.

Both optimization domains are compact convex simplexes, and the objective is linear in each of $vmu$ and $vnu$. We are therefore in the setting of the minimax theorem. Swapping the order of optimization and the expectations, the min-max value above is equal to

$
  max_vnu min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] .
$

Can we show that this value is $<= 0$? The answer is yes, and the proof is constructive. Once $vnu$ is fixed, it is enough to exhibit one feasible $vmu$ for which the expected deviation gain is nonpositive. The following theorem provides exactly such a response---in fact, it provides a _product_ distribution.

#theorem[#citet(<Hart89>)][
  Given any distribution $vnu$ over pairs

  $
    (i \, a'_i) \, #h(2em) i in \[ n \] \, a'_i in A_i \,
  $

  we can explicitly and efficiently construct a product distribution $vmu in Delta \( A_1 \) ⊗ ... ⊗ Delta \( A_n \)$ such that

  $ bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 . $
]#label("thm:hart schmeidler")

A proof of #ref(label("thm:hart schmeidler")) is given in #ref(<sec-hart-schmeidler-proof>, supplement: [Appendix]).

It is important to distinguish the product distribution supplied by #ref(label("thm:hart schmeidler")) from the domain of the minimization problem. The latter is still the full simplex

$
  Delta (A_1 times ... times A_n)
$

of all joint distributions. Every product distribution $vmu = vmu_1 ⊗ ... ⊗ vmu_n$ induces a joint distribution over $A_1 times ... times A_n$. Thus,

$
  Delta \( A_1 \) ⊗ ... ⊗ Delta \( A_n \) subset.eq Delta (A_1 times ... times A_n)
$

when the left-hand side is understood as the class of product distributions. #ref(label("thm:hart schmeidler")) therefore does not restrict the minimization domain; it simply shows that, for every fixed $vnu$, a particularly simple feasible point---a product distribution---already achieves a nonpositive value.

In particular, for every fixed $vnu$, let $vmu^vnu$ denote the product distribution supplied by #ref(label("thm:hart schmeidler")). Since $vmu^vnu$ is feasible for the minimization problem,

$
  & min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad <= bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu^vnu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad <= 0 .
$

Thus,

$
  min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0
$

for every $vnu$. Taking the maximum over $vnu$ therefore gives

$
  max_vnu min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))] <= 0 .
$

Finally, the minimax theorem gives

$
  & min_vmu max_vnu bb(E)_(a ~ vmu) bb(E)_(\( i \, a'_i \) ~ vnu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad = max_vnu min_vmu bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_i (a'_i \, a_(- i)) - u_i (a_i \, a_(- i))]\
  & quad quad <= 0 .
$

By the equivalence established above between maximizing over distributions on deviations and maximizing over a single deviation, this means that there exists a joint distribution $vmu$ under which every unilateral fixed deviation has nonpositive expected gain. Hence, a coarse correlated equilibrium exists.

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

Let $D := {(i \, a'_i) : i in \[ n \] \, a'_i in A_i}$ denote the set of deviations. In more detail, what #ref(label("thm:hart schmeidler")) implies is that the following open polytope must be empty:

$
  lr({vnu in Delta(D) : vec(delim: #none, align: #left,
    bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu) [u_(i) (a'_i \, a_(- i)) - u_(i) (a_i \, a_(- i))] > 0,
    forall vmu in Delta (A_1 times ... times A_n),
  )}) .
$

Furthermore, for any $vnu$, we know how to prove that at least one of the constraints is violated. The key idea is then to use the ellipsoid method to _certify_ the emptiness of the polytope. Normally, the ellipsoid method is used to find a point in a set, but in our case, the point does not exist and we want to use the ellipsoid method to isolate constraints that prove the emptiness of the set. For this reason, the algorithm was called Ellipsoid-Against-Hope by #citet(<papadimitriou2008computing>).

The ellipsoid will maintain a search space which can be thought of as a suitable subset of the deviator's set. At every iteration $t$, the algorithm will compute the center point $vnu_t$ of the set. Then, it will find a violated constraint using the distribution $vmu_t := vmu \( vnu_t \)$ in the proof of #ref(label("thm:hart schmeidler")). The violated constraint implies that the deviator set must be curtailed, and the ellipsoid will be updated accordingly reducing the size of the search space by a constant. The algorithm will continue until the search space is small enough to guarantee that the set is empty. The iteration count also depends polynomially on the dimension and encoding/conditioning bounds. For an approximate guarantee, use constraints with a positive $epsilon.alt$ margin and the corresponding separation and volume bounds; shrinking an arbitrary open set does not by itself certify exact emptiness. The following algebra describes the exact finite certificate when one has been obtained. By the last iteration $T$, the algorithm will have produced several violated constraints, each of which is associated with a mediator strategy $vmu_t$. The set

$
  lr({vnu in Delta(D) : vec(delim: #none, align: #left,
    bb(E)_(\( i \, a'_i \) ~ vnu) bb(E)_(a ~ vmu_t) [u_(i) (a'_i \, a_(- i)) - u_(i) (a_i \, a_(- i))] > 0,
    forall t in \{1 \, ... \, T\},
  )}) .
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

#let valpha = $bold(alpha)$
#exercise[Recovering mixture weights with Farkas' lemma][
  Let $D$ be the deviation set defined above, let $m = |D|$,
  and suppose $T >= 1$ responses $vmu_1,...,vmu_T$
  have been collected. Define the gain matrix $matA in RR^(m times T)$ by
  $
    A_(d,t) := EE_(a ~ vmu_t)[u_(i)(a'_i,a_(-i))-u_(i)(a_i,a_(-i))],
    quad d=(i,a'_i).
  $
  Thus a row is a fixed deviation, a column is a response, and a positive
  entry is a profitable deviation. Assume the *finite certificate*
  $
    {vnu in Delta(D) : matA^T vnu > 0} = emptyset.
  $
  All vector inequalities here are coordinatewise.

  + Write the feasibility program for weights $valpha$ whose mixture
    has nonpositive gain in every row. Convert it to an equality system
    $matM vz=vb$, $vz>=0$, using one slack variable per row.
  + Use the following form of Farkas' lemma: exactly one of
    $exists vz>=0: matM vz=vb$ and
    $exists vy: matM^T vy>=0, vb^T vy<0$ holds.#footnote[
      See Boyd and Vandenberghe, _Convex Optimization_, Section 5.8.3,
      page 263 (#link("https://web.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf")[book]),
      for an equivalent form of Farkas' lemma.
    ]
    Show that infeasibility of the weight program would give a point in
    the supposedly empty set. Explain the signs and the normalization.
  + Prove that the resulting mixture $macron(vmu)=sum_t alpha_t vmu_t$
    is a CCE. Explain why the finite certificate, rather than just the
    response guarantee at each queried $vnu_t$, is needed.
  + For an $epsilon.alt$-CCE, with $epsilon.alt>=0$, identify the
    corresponding finite certificate and weight constraints.
] <ex-eah-farkas>

#solution[
  *1. Encoding the weights.* We seek $valpha>=0$ with
  $vone_T^T valpha=1$ and $matA valpha<=0$.
  Here $vone_k$ is the vector of $k$ ones and $matI_m$ is the
  $m times m$ identity matrix. Introducing nonnegative slacks
  $vs in RR^m$ makes $matA valpha+vs=0$ equivalent to $matA valpha<=0$.
  #block(breakable: false)[
  Use the block system
  $
    matM=mat(matA, matI_m; vone_T^T, 0),
    quad vz=binom(valpha,vs), quad vb=binom(0,1).
  $
  ]
  The block dimensions are $(m+1) times (T+m)$ for $matM$,
  $T+m$ for $vz$, and $m+1$ for $vb$. The last row enforces total weight
  one and excludes the zero-weight solution.

  *2. Reading the infeasibility certificate.* Suppose no such weights
  exist. Farkas supplies $vy=binom(vr,beta)$, where $vr in RR^m$ and
  $beta in RR$, such that
  $
    matA^T vr+beta vone_T>=0, quad vr>=0, quad beta<0.
  $
  The first inequalities come from the $T$ weight columns of $matM$;
  $vr>=0$ comes from its $m$ slack columns; and $vb^T vy=beta<0$ comes
  from the right-hand side. It follows that
  $
    matA^T vr>=-beta vone_T>0.
  $
  Since $T>=1$, this rules out $vr=0$. Thus $S=vone_m^T vr>0$, and
  $vnu=vr/S$ is a distribution on $D$ satisfying
  $
    sum_(d in D) A_(d,t) nu_d >=frac(-beta,S)>0
    quad forall t=1,...,T.
  $
  This contradicts the finite certificate, so feasible weights exist.
  Strict positivity is essential: $matA^T vnu>=0$ allows zero scores
  and does not contradict the certificate.

  *3. Checking the equilibrium.* The weights define a probability
  distribution because they are nonnegative and sum to one. Linearity
  of expectation gives, for every deviation $d=(i,a'_i)$,
  $
    EE_(a ~ macron(vmu))[u_(i)(a'_i,a_(-i))-u_(i)(a_i,a_(-i))]
    =sum_(t=1)^T alpha_t A_(d,t)
    =(matA valpha)_d<=0.
  $
  These are exactly the CCE constraints. The proof requires the finite
  certificate against *all saved responses*; the separate guarantees
  $g(vmu_t,vnu_t)<=0$ at the queried pairs do not imply it.

  *4. The approximate version.* Replace the finite certificate by
  $
    {vnu in Delta(D) : matA^T vnu>epsilon.alt vone_T}=emptyset
  $
  and seek $matA valpha<=epsilon.alt vone_m$, with the same simplex
  constraints on $valpha$. Apply the argument above to
  $matA-epsilon.alt vone_m vone_T^T$. Because both probability vectors
  sum to one, subtracting this matrix shifts each deviation score by
  exactly $epsilon.alt$. The resulting mixture is an
  $epsilon.alt$-CCE. This requires the finite certificate, not merely
  a small search volume.
] <sol-eah-farkas>

#block(breakable: false)[
#example[A two-row coefficient calculation][
  As an algebraic illustration of @ex-eah-farkas, consider
  $
    matA=mat(1,-2; -1,1).
  $
  Write the weight vector as $valpha=(w,1-w)^T$.
  Neither column is coordinatewise nonpositive, but the mixture has gains
  $matA valpha=binom(3w-2,1-2w)$. It is feasible exactly when
  $1/2<=w<=2/3$. For example, $w=3/5$ gives gains
  $(-1/5,-1/5)$ and slack vector $vs=(1/5,1/5)$.

  A deviation distribution $vnu=(q,1-q)$ scores the columns as
  $matA^T vnu=(2q-1,1-3q)$. Both scores would be strictly positive
  only if $q>1/2$ and $q<1/3$, which is impossible. Thus the finite
  certificate holds.
] <ex-eah-farkas-coefficients>
]

#example[Sampling the final mixture][
  Write each saved product response as
  $vmu_t=vx_(1,t) ⊗ ... ⊗ vx_(n,t)$, where
  $vx_(i,t) in Delta(A_i)$. To sample one profile from
  $macron(vmu)=sum_(t=1)^T alpha_t vmu_t$:

  + The mediator draws one common index $J$ with
    $Pr(J=t)=alpha_t$.
  + Conditional on this index, it draws each $a_i$ independently from
    $vx_(i,J)$ and privately recommends $a_i$ to player $i$.

  The law of total probability verifies the joint distribution:
  $
    Pr(a_1,...,a_n)=sum_(t=1)^T alpha_t
    product_(i=1)^n x_(i,t)(a_i)=macron(vmu)(a_1,...,a_n).
  $
  Independence holds *conditional on $J$*. Keep $J$ private and draw
  a new shared index for each profile.

  For a separate example, two players choose $L$ or $R$. Each receives
  utility $1$ when their actions match and $0$ otherwise:

  #table(
    columns: 3, align: center, inset: .4em, stroke: none,
    table.header([Player 1 / Player 2], [$L$], [$R$]),
    [$L$], [$(1,1)$], [$(0,0)$],
    [$R$], [$(0,0)$], [$(1,1)$],
  )

  Use product responses $vmu_1=delta_((L,L))$ and
  $vmu_2=delta_((R,R))$, with weights $alpha_1=3/4$ and $alpha_2=1/4$.
  Both marginals put probability $3/4$ on $L$, but multiplying those
  marginals gives a different joint distribution:

  #table(
    columns: 5, align: center, inset: .4em, stroke: none,
    table.header([Distribution], [$(L,L)$], [$(L,R)$], [$(R,L)$], [$(R,R)$]),
    [$macron(vmu)$], [$3/4$], [$0$], [$0$], [$1/4$],
    [$macron(vmu)_1 ⊗ macron(vmu)_2$], [$9/16$], [$3/16$], [$3/16$], [$1/16$],
  )

  #block(breakable: false)[
  Under the mixture, each player earns $1$. A fixed deviation to $L$
  earns $3/4$, and a fixed deviation to $R$ earns $1/4$. Their gains
  are $-1/4$ and $-3/4$, so the mixture is a CCE.
  Under the product of its marginals, each player earns
  $9/16+1/16=5/8$. Always choosing $L$ earns $3/4$, giving gain $1/8>0$.
  Thus replacing the mixture by its marginal product can lose even
  the CCE guarantee.
  ]

  If every player independently draws its own component index $J_i$,
  the result is precisely the product of the marginals:
  $
    product_(i=1)^n (sum_(t=1)^T alpha_t x_(i,t)(a_i)).
  $
  Keeping the common index preserves the correlations encoded by the
  list of product responses and their weights, without enumerating
  all joint actions. The marginal product can still be a CCE in other cases.
] <ex-eah-mixture-sampling>

== Applications beyond normal-form games

The above argument mostly uses ideas from convex optimization. In particular, it extends, with suitable oracle and encoding assumptions, to _multilinear games on compact convex domains_, that is, any setting with the following properties:

- Player $i$'s strategy set is a nonempty compact convex set of some dimension $d_i$, with suitable rational descriptions or geometric bounds for the ellipsoid method. For normal-form games, a strategy is an element of $Delta \( A_i \)$, that is, a distribution over the player's strategies. We assume an efficient separation oracle with the bit-complexity and geometric bounds required by convex optimization.
- The utility function $u_i \( vx_1 \, ... \, vx_n \)$ is linear in each player's strategy. For normal-form games, this is true since the utility is just an expectation.
- The utility function $u_i \( vx_1 \, ... \, vx_n \)$ can be evaluated efficiently, let's say in time $R$.

The Ellipsoid-Against-Hope algorithm can then be applied and has polynomial complexity in $sum_i^n d_i$, oracle costs, encoding and geometric bounds, and $log \( 1 \/ epsilon.alt \)$. Applications include polymatrix games and finite perfect-recall extensive-form games; a succinct game representation must be checked for the required oracles before applying the result.

For concrete examples of the savings from a succinct representation, consider the following games with rational payoffs and at most $m$ actions per player:

- _Polymatrix games._ Each player's payoff is the sum of pairwise payoffs from games with its neighbors in an interaction graph. With $n$ players and edge set $E$, the payoff tables contain $O(|E| m^2)$ entries, whereas the joint-action LP can have $m^n$ probability variables. Expected payoffs under independent mixed strategies are computed by summing expectations over the pairwise tables, without enumerating joint actions.
- _Graphical games with bounded neighborhoods._ Each player's payoff depends only on its own action and the actions of at most $k$ neighbors, and is specified by a local table. The tables contain at most $n m^(k+1)$ entries, which is polynomial in $n$ and $m$ for fixed $k$, while the joint-action LP can again have $m^n$ variables. Expected payoffs are computed by averaging each local table against the mixed strategies of the players in that neighborhood.

In both examples, the strategy domains are simplexes with efficient separation oracles, and expected utilities are multilinear and evaluable in polynomial time in the compact input size. Thus, explicitly constructing the obvious CE/CCE LP can take exponential time, but the Ellipsoid-Against-Hope framework avoids that expansion. The CCE construction above uses only polynomially many product distributions and a small final LP. For CE, one must also enforce deviations conditional on the recommended action; the exact-CE variant of #citet(<jiang2011polynomial>) computes a rational CE with polynomial-size support in polynomial time for these representations. Such a CE is also a CCE. These guarantees concern finding an equilibrium, not optimizing an arbitrary objective over equilibria.

= Bibliographic remarks

If you are curious to read more, the following papers contains extensions and refinements of the idea of Ellipsoid-Against-Hope.

#lec_bibliography("meta/refs.bib", title: none)

#appendix[
  = Appendix: Proof of Theorem~#ref(label("thm:hart schmeidler"), supplement: none) <sec-hart-schmeidler-proof>

  Let $s_i=sum_(a_i in A_i) nu_(i,a_i)$ be the total mass assigned to player $i$'s deviations. If $s_i>0$, set $mu_(i)(a_i)=nu_(i,a_i)/s_i$; if $s_i=0$, choose any distribution $vmu_i$ on $A_i$. Let $vmu=vmu_1 times ... times vmu_n$ be their product distribution.

  For $s_i>0$, averaging the deviating action according to $vnu_(i,dot)/s_i$ is exactly the same as drawing it from $vmu_i$, independently of the opponents. Therefore
  $
    sum_(a'_i) nu_(i,a'_i) EE_(a ~ vmu)[u_(i)(a'_i,a_(-i))-u_(i)(a_i,a_(-i))] = s_(i)(EE_(a ~ vmu)[u_(i)(a)]-EE_(a ~ vmu)[u_(i)(a)])=0.
  $
  If $s_i=0$, the same expression is zero because all its coefficients vanish. Sum over players to obtain the theorem, with equality. This normalization also handles zero-mass players, for whom an unnormalized product of the $vnu$ entries would not define a probability distribution.
]
