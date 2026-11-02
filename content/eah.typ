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

It is convenient to read the minimax problem above as a game between a _mediator_, who chooses the joint distribution $vmu$ (the trusted mediator from #lecture-link("correlated", none)[]), and a _deviator_, who chooses the distribution $vnu in Delta(D)$ over deviations. The ellipsoid method searches over the deviator's strategies. At every iteration $t$, the algorithm computes the center $vnu_t$ of the current ellipsoid. If $vnu_t in.not Delta(D)$, we shift a separating hyperplane to pass through $vnu_t$ and retain the halfspace containing $Delta(D)$. Otherwise, the algorithm takes the mediator strategy $vmu_t := vmu \( vnu_t \)$ from the proof of #ref(label("thm:hart schmeidler")). The constraint indexed by $vmu_t$ is violated at $vnu_t$, so every point of the set above lies in the open halfspace on which this constraint holds. Since the construction in #ref(<sec-hart-schmeidler-proof>, supplement: [Appendix]) gives equality, the boundary of this halfspace passes through $vnu_t$. (If the constraint vanishes identically on $Delta(D)$, it alone certifies that the set is empty, and the algorithm can stop.) The algorithm keeps this half of the ellipsoid and replaces the ellipsoid by the smallest ellipsoid containing that half.

Each such central-cut update reduces the volume of the ellipsoid by a factor of at most $exp(-1/(2(d+1)))$, where $d = |D| - 1$ is the dimension of $Delta(D)$, the method works in its affine hull, and $d >= 2$. This factor approaches $1$ as $d$ grows, so the ellipsoid does not shrink by a constant factor independent of the dimension: halving its volume takes at most $ceil(2(d+1) ln 2)$ iterations. The algorithm continues until the search space is small enough to guarantee that the set is empty, and the iteration count depends polynomially on the dimension and on encoding and conditioning bounds. For an approximate guarantee, use constraints with a positive $epsilon.alt$ margin and the corresponding separation and volume bounds; shrinking an arbitrary open set does not by itself certify exact emptiness. The following algebra describes the exact finite certificate when one has been obtained. By the last iteration $T$, the algorithm will have produced several violated constraints, each of which is associated with a mediator strategy $vmu_t$. The set

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
    columns: 3, align: center, inset: .4em, stroke: none,
    table.header([Profile], [$macron(vmu)$], [$macron(vmu)_1 ⊗ macron(vmu)_2$]),
    [$(L,L)$], [$3/4$], [$9/16$],
    [$(L,R)$], [$0$], [$3/16$],
    [$(R,L)$], [$0$], [$3/16$],
    [$(R,R)$], [$1/4$], [$1/16$],
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

*Deriving payoffs in a polymatrix game*  Let $N_i$ denote the neighbors of player $i$, and for every $j in N_i$ let $matM^(i j)$ be the matrix specifying player $i$'s payoff from the interaction with player $j$. Thus, at an action profile $a$,
$
  u_i (a) = sum_(j in N_i) matM^(i j)_(a_i,a_j) .
$

Now suppose that the players use a product distribution $vx = vx_1 ⊗ ... ⊗ vx_n$. By linearity of expectation,
$
  u_i (vx) & = bb(E)_(a ~ vx) [sum_(j in N_i) matM^(i j)_(a_i,a_j)]\
  & = sum_(j in N_i) vx_i^top matM^(i j) vx_j .
$
The important point is that every term involves only the mixed strategies of two neighboring players. We never need to construct the distribution over all joint action profiles.

The same observation lets us compute deviation gains. If player $i$ deviates to a fixed action $a'_i$, then
$
  u_i (a'_i, vx_(-i)) = sum_(j in N_i) ve_(a'_i)^top matM^(i j) vx_j ,
$
where $ve_(a'_i)$ denotes the standard basis vector of player i's action space. Define
$
  vq_i := sum_(j in N_i) matM^(i j) vx_j .
$
The expected payoff from deviating to $a'_i$ is $(vq_i)_(a'_i)$, the expected payoff from following $vx_i$ is $vx_i^top vq_i$, and hence the deviation gain is
$
  (vq_i)_(a'_i) - vx_i^top vq_i .
$
Thus, after computing $vq_i$, we obtain the deviation gain of every action of player $i$ by reading the corresponding coordinate of $vq_i$.

Computing $matM^(i j) vx_j$ takes time proportional to the size of the payoff matrix on edge $(i,j)$. Repeating this calculation over all edges takes time polynomial in the $O(|E| m^2)$-size polymatrix representation, rather than in the $m^n$ joint action profiles. Finally, deviation gains are linear in the underlying distribution. If Ellipsoid-Against-Hope returns $macron(vmu) = sum_t alpha_t vmu_t$, where every $vmu_t$ is a product distribution, then the deviation gain under $macron(vmu)$ is the same convex combination of the gains computed under the $vmu_t$.

= Expected solutions beyond equilibrium computation <sec-expected-solutions>

This exercise applies the defense-to-offense framework beyond equilibrium computation. It follows Sections 6–7 of #link("https://www.mit.edu/~gfarina/2026/sigecom26_turning_defense_into_offense/sigecom26_turning_defense_into_offense.pdf")[Farina's note]; the fixed-point response below uses a consistent lower-bound payoff convention.

#exercise("Expected variational inequalities and expected fixed points")[
Let $K subset.eq bb(R)^d$ be nonempty, compact, and convex, with
$d >= 1$. Fix $epsilon.alt > 0$. Let $F : K -> bb(R)^d$ be
bounded: there is a finite $M >= 0$ such that
$parallel F\(vz\)parallel_2 <= M$ for every
$vz in K$. Separately, let $f : K -> K$ be any map.

Write $Delta_(upright("fin"))\(K\)$ for the set of probability
distributions with finite support in $K$. In particular,

$ mu = sum_(t = 1)^T p_t delta_(vz_t)\,#h(2em) p_t >= 0\,#h(1em) sum_(t = 1)^T p_t = 1\, $

and
$bb(E)_mu\[g\(vz\)\]= sum_t p_t g\(vz_t\)$.
Here $delta_(vz_t)$ is the distribution concentrated at
$vz_t$. Restricting to finite support makes every
expectation in this exercise a finite sum, so no additional
measurability assumption on $F$ or $f$ is required.

An #strong[$epsilon.alt$-expected variational inequality solution], with
constant tests, is a distribution $mu in Delta_(upright("fin"))\(K\)$
such that

$ bb(E)_mu #h(0em) [F \( vz \)^top \( vx - vz \)] >= - epsilon.alt #h(2em) upright("for every ") vx in K . $

The test $vx$ is fixed independently of the sampled
$vz$. This is the constant-deviation version of an EVI;
the exercise does not require the stronger condition for all affine or
sample-dependent deviations.

An #strong[$epsilon.alt$-expected fixed point] is a distribution
$mu in Delta_(upright("fin"))\(K\)$ such that

$ ∥bb(E)_mu \[ f \( vz \) - vz \]∥_2 <= epsilon.alt . $

For both applications, use the following convention: the tester
minimizes the payoff, and the distribution player maximizes it. A
defense response must give payoff #strong[at least zero] against the
particular test presented to it.

You may use the following finite-dimensional consequence of minimax. Its
proof is included after the solution.

#quote(block: true)[
#strong[Mixing lemma.] Let $X subset.eq bb(R)^m$ be nonempty, compact,
and convex, and let $S$ be a nonempty set of response labels. Suppose
$va : S -> bb(R)^m$ and $b : S -> bb(R)$ are
bounded. Set
$u\(vx\,s\)= vx^top va\(s\)+ b\(s\)$.
If, for every $vx in X$, there exists $s in S$ with
$u\(vx\,s\)>= 0$, then, for every $eta > 0$, there is a
finite distribution $nu$ on $S$ satisfying
$bb(E)_(s ~ nu)\[u\(vx\,s\)\]>= - eta$ for every
$vx in X$.
]

#strong[\(a) Expected variational inequalities.] Define

$ U\(vx\,mu\)= bb(E)_mu\[F\(vz\)^top\(vx - vz\)\]. $

Express $U$ using the moments
$va_mu = bb(E)_mu\[F\(vz\)\]$ and
$b_mu = bb(E)_mu\[F\(vz\)^top vz\]$.
Construct a defense response to any given $vx in K$.
Verify the hypotheses of the mixing lemma and conclude that (EVI) has a
finite-support solution for every $epsilon.alt > 0$.

#strong[\(b) Expected fixed points and payoff signs.] Let
$B_2^d = { vq in bb(R)^d : parallel vq parallel_2 <= 1 }$
and define

$ V\(vq\,mu\)= bb(E)_mu\[vq^top\(f\(vz\)- vz\)\]. $

Find a defense response to each $vq in B_2^d$, using
linear optimization over $K$. Explain whether the response should
minimize or maximize $vq^top vz$ under our
payoff convention. Apply the mixing lemma and prove

$ min_(vq in B_2^d) V\(vq\,mu\)= - ∥bb(E)_mu \[ f \( vz \) - vz \]∥_2 . $

Deduce the existence of a finite-support solution to (EFP), without
assuming that $f$ is continuous.

#strong[\(c) Expected fixed points need not be pointwise fixed points.]
Take $K =\[0\,1\]$ and

$ f\(z\)= cases(delim: "{", 1\, & 0 <= z <= 1 / 2\,, 0\, & 1 / 2 < z <= 1 .) $

Show that $f$ has no fixed point. For
$mu = 1 / 2 delta_0 + 1 / 2 delta_1$, compute

$ bb(E)_mu\[f\(z\)- z\]\,#h(2em) bb(E)_mu\[\|f\(z\)- z\|\]\,#h(2em) f\(bb(E)_mu\[z\]\)- bb(E)_mu\[z\]. $

Explain why neither sampling from an expected fixed point nor replacing
the distribution by its mean is guaranteed to produce a pointwise fixed
point.

#strong[\(d) Connecting the reductions to Ellipsoid-Against-Hope.] For
each game, write the set of tests that obtain payoff at most
$- epsilon.alt$ against #strong[every] pure response
$vz in K$. Explain why the defense oracle certifies that
this set is empty and how a response produces a linear inequality in the
test variable.

Suppose a finite collection
$vz_1\,...\,vz_T$ of responses has been
obtained. Formulate the two feasibility problems for weights
$vp in Delta_T$ that would certify (EVI) and (EFP). For the
EVI problem, explain how a linear optimization oracle over $K$ checks
all test points without listing them. State the evaluation and geometric
oracle access that the reductions need for an algorithmic
implementation. Does the mere existence of a pointwise defense oracle
guarantee that an arbitrarily chosen finite collection of responses
admits suitable weights?

This part asks for the reduction and the final certificate, not a proof
of the ellipsoid iteration bound or a bit-complexity theorem.

#strong[\(e) Optional extension: why retain $epsilon.alt > 0$ for a
discontinuous EVI?] Let $K =\[0\,1\]$ and

$ F\(z\)= cases(delim: "{", - 1\, & 0 <= z <= 1 / 2\,, 1\, & 1 / 2 < z <= 1 .) $

Show that no finite-support distribution satisfies (EVI) with
$epsilon.alt = 0$. For $0 < tau <= 1 / 2$, verify that
$mu_tau = 1 / 2 delta_(1\/2) + 1 / 2 delta_(1\/2 + tau)$ has payoff
$U\(x\,mu_tau\)= - tau\/2$ for every $x in\[0\,1\]$. Choose $tau$ to
obtain an $epsilon.alt$-EVI for any $epsilon.alt > 0$.

] <ex-expected-solutions>

== Complete solution <sec-expected-solution>

#solution[
#strong[\(a) Expected variational inequalities]

Linearity of finite sums gives

$ U\(vx\,mu\)= vx^top va_mu - b_mu\,#h(2em) va_mu = sum_t p_t F\(vz_t\)\,#h(2em) b_mu = sum_t p_t F\(vz_t\)^top vz_t . $

Thus the payoff is affine in the test point and linear in the
distribution weights. It need not be linear or continuous in the
response point $vz$. Equivalently, it is a bilinear
pairing between the lifted test vector $\(vx\,1\)$ and the
moment vector $\(va_mu\,- b_mu\)$.

Against a particular test $vx$, choose
$mu = delta_(vx)$. Then

$ U\(vx\,delta_(vx)\)= F\(vx\)^top\(vx - vx\)= 0 . $

For the mixing lemma, take $X = K$, $S = K$,
$va\(vz\)= F\(vz\)$, and
$b\(vz\)= - F\(vz\)^top vz$.
Compactness supplies a finite radius
$R = max_(vz in K) parallel vz parallel_2$,
so $parallel va\(vz\)parallel_2 <= M$ and
$\|b\(vz\)\|<= M R$. All hypotheses hold. Taking
$eta = epsilon.alt$ gives a finite distribution satisfying (EVI).

The diagonal defense construction alone says that each test has a
suitable response, potentially a different one. The mixing lemma
supplies the additional step needed to obtain one distribution that
works for every test.

#strong[\(b) Expected fixed points, with a consistent sign convention]

Given $vq in B_2^d$, choose

$ vz_(vq) in "arg min"_(vz in K) vq^top vz . $

This minimizer exists because a linear function is continuous and $K$ is
nonempty and compact. Since
$f\(vz_(vq)\)in K$,

$ vq^top vz_(vq) <= vq^top f\(vz_(vq)\)\,#h(2em) V\(vq\,delta_(vz_(vq))\)>= 0 . $

This is the required defense response. At $vq = 0$, any
point of $K$ works. An oracle written as a maximization oracle can
implement this response by querying it with $- vq$.

By contrast, maximizing $vq^top vz$ gives
$vq^top\(f\(vz\)- vz\)<= 0$,
which is not the lower-bound guarantee required here. Maximization would
be appropriate after negating the payoff and reversing which player
seeks a lower or upper bound.

For the mixing lemma, use $X = B_2^d$, $S = K$,
$va\(vz\)= f\(vz\)- vz$,
and $b\(vz\)= 0$. Both $vz$ and
$f\(vz\)$ belong to $K$, so
$parallel va\(vz\)parallel_2 <= "diam"\(K\)$.
The lemma therefore gives a finite distribution $mu$ with
$V\(vq\,mu\)>= - epsilon.alt$ for all
$vq in B_2^d$.

Set
$vr = bb(E)_mu\[f\(vz\)- vz\]$.
For every $parallel vq parallel_2 <= 1$,
Cauchy--Schwarz gives

$ vq^top vr >= - parallel vr parallel_2 . $

If $vr != 0$, equality is attained at
$vq = - vr\/parallel vr parallel_2$.
If $vr = 0$, every direction has payoff zero. Consequently

$ min_(vq in B_2^d) V\(vq\,mu\)= - parallel vr parallel_2 . $

The uniform lower bound implies
$- parallel vr parallel_2 >= - epsilon.alt$, hence
$parallel vr parallel_2 <= epsilon.alt$ as required.
Neither the defense construction nor this proof uses continuity of $f$.

#strong[\(c) What the expectation does, and does not, guarantee]

For $z <= 1\/2$, the equation $f\(z\)= z$ would require $z = 1$,
outside that branch. For $z > 1\/2$, it would require $z = 0$, also
outside that branch. Thus there is no fixed point.

At the two support points, $f\(0\)- 0 = 1$ and $f\(1\)- 1 = - 1$.
Therefore

$ bb(E)_mu\[f\(z\)- z\]= 1 / 2\(1\)+ 1 / 2\(- 1\)= 0\,#h(2em) bb(E)_mu\[\|f\(z\)- z\|\]= 1 . $

This distribution is an exact expected fixed point, although every
sampled point has residual magnitude one. Its mean is
$bb(E)_mu\[z\]= 1\/2$. With the specified value at the boundary,
$f\(1\/2\)= 1$, so

$ f\(bb(E)_mu\[z\]\)- bb(E)_mu\[z\]= 1 - 1 / 2 = 1 / 2 . $

Expected residuals can cancel. The definition controls the norm of the
expected residual, not the expected norm, and it does not permit moving
$f$ outside the expectation. In general
$f\(bb(E)_mu\[z\]\)!= bb(E)_mu\[f\(z\)\]$.

#strong[\(d) Empty test sets, cuts, and finite certificates]

The two sets are

$ Omega_(upright(V I)) = { vx in K : F\(vz\)^top\(vx - vz\)<= - epsilon.alt upright(" for every ") vz in K }\, $

$ Omega_(upright(F P)) = { vq in B_2^d : vq^top\(f\(vz\)- vz\)<= - epsilon.alt upright(" for every ") vz in K } . $

Both are convex intersections of the test domain with linear halfspaces.
They are empty: the defense response at any candidate test has payoff at
least zero, contradicting $epsilon.alt > 0$.

For a candidate $vx_0 in K$, the VI response is
$vz = vx_0$. Every point in the purported
feasible set must obey

$ F\(vx_0\)^top\(vx - vx_0\)<= - epsilon.alt . $

The candidate itself has left-hand side zero. For a candidate direction
$vq_0 in B_2^d$, the fixed-point response
$vz_(vq_0)$ similarly produces the
constraint

$ vq^top\(f\(vz_(vq_0)\)- vz_(vq_0)\)<= - epsilon.alt\, $

violated by $vq_0$. If the coefficient vector of either
inequality is zero, the inequality is $0 <= - epsilon.alt$ and itself
certifies emptiness; otherwise it supplies a genuine separating
halfspace. A candidate outside the test domain must instead be rejected
by that domain's separation oracle.

These responses play the same role as the violated constraints selected
in S2. The generalized EAH procedure selects responses and recovers
mixing weights using quantitative geometric and precision guarantees.
Mere emptiness of an arbitrary strict system, or small volume without an
appropriate quantitative argument, is not being used here as a proof of
an approximation guarantee.

For given responses $vz_1\,...\,vz_T$,
define

$ va\(vp\)= sum_t p_t F\(vz_t\)\,#h(1em) b\(vp\)= sum_t p_t F\(vz_t\)^top vz_t\,#h(1em) vr\(vp\)= sum_t p_t\(f\(vz_t\)- vz_t\). $

The VI certificate is the feasibility problem

$ vp in Delta_T\,#h(2em) min_(vx in K) vx^top va\(vp\)- b\(vp\)>= - epsilon.alt . $

The minimum exists. A linear optimization oracle returns a worst test
$vx^(*)$. If its payoff is below $- epsilon.alt$, the
linear inequality

$ sum_t p_t F\(vz_t\)^top\(vx^(*) - vz_t\)>= - epsilon.alt $

is a violated constraint in weight space. This checks the entire test
set, not only a sample of its points. If $K$ is a polytope with an
explicitly listed vertex set, testing all vertices also suffices, since
the payoff is affine. One must not assume that such a vertex list is
small.

The fixed-point certificate is

$ vp in Delta_T\,#h(2em) parallel vr\(vp\)parallel_2 <= epsilon.alt . $

This is a convex feasibility problem, specifically a second-order cone
constraint together with simplex constraints; it is not generally a
linear program under the Euclidean norm. If it is violated, the
direction
$vq^(*) = - vr\/parallel vr parallel_2$
exposes a violated linear test.

To implement the reductions, the VI game needs evaluation of $F$ at
response points and separation over $K$\; its defense response itself
needs no nonlinear optimization. Linear optimization over $K$ checks the
final VI certificate. The fixed-point game needs evaluation of $f$,
linear optimization over $K$ to produce its defense response, and
separation over the unit ball, which is explicit. For a direction
outside the ball, the separating inequality
$vq_0^top vq <= parallel vq_0 parallel_2$
is valid on the ball and violated by
$vq = vq_0$.

The exercise's mathematical assumptions alone do not provide efficient
oracle implementations. A polynomial-time claim additionally needs
quantitative bounds on feature vectors and domain geometry, efficient
evaluation/response/separation oracles, and controlled numerical
precision and encoding. The mixing lemma proves existence, not such a
running-time bound. No efficient optimization of the arbitrary nonlinear
maps $F$ or $f$ is assumed.

Finally, arbitrary collections of responses need not admit suitable
weights. For example, in part (c), if the collection contains only
$z_1 = 0$, every mixture over that collection has residual one and fails
(EFP) for $epsilon.alt < 1$. EAH's selection and certificate extraction
are substantive steps; simply averaging any responses is not a
substitute.

#strong[\(e) Optional extension: approximate does not automatically mean
exact]

At the test $x = 1\/2$,

$ F\(z\)\(1\/2 - z\)= cases(delim: "{", z - 1\/2\, & z <= 1\/2\,, 1\/2 - z\, & z > 1\/2 .) $

Every value is nonpositive, and it is zero only at $z = 1\/2$. For a
finite distribution to have expected payoff at least zero at this test,
all its positive mass must therefore be at $z = 1\/2$. But the resulting
$delta_(1\/2)$ has payoff $F\(1\/2\)\(1 - 1\/2\)= - 1\/2$ at $x = 1$.
Thus no exact finite-support EVI solution exists.

On the other hand,

$ U\(x\,mu_tau\)= 1 / 2\[-\(x - 1\/2\)\]+ 1 / 2\[x -\(1\/2 + tau\)\]= - tau\/2 $

for every $x in\[0\,1\]$. Choosing $tau = min { 1\/4\,epsilon.alt } > 0$
gives a valid support point in $K$ and payoff at least $- epsilon.alt$.
This example explains why the general mixing lemma provides arbitrarily
accurate finite distributions without asserting an exact EVI solution
for discontinuous $F$.

]

== Why finite mixtures exist <sec-expected-mixing-proof>

The following argument proves the mixing lemma used in the exercise.

Let

$ A = {\(va\(s\)\,b\(s\)\): s in S } subset.eq bb(R)^(m + 1)\,#h(2em) C = overline("conv"\(A\)) . $

Boundedness of $va$ and $b$ makes $C$ bounded. In finite
dimension its closure is compact, and $C$ is nonempty and convex. For
$vy =\(va\,beta\)in C$, define

$ L\(vx\,vy\)= vx^top va + beta . $

This is continuous and affine in each argument. Equivalently, after
replacing $X$ by ${\(vx\,1\): vx in X }$, it
is a bilinear payoff on two compact convex sets. The finite-dimensional
minimax theorem applies, giving

$ max_(vy in C) min_(vx in X) L\(vx\,vy\)= min_(vx in X) max_(vy in C) L\(vx\,vy\)>= 0 . $

The inequality follows because, for each $vx$, the defense
hypothesis provides a point of $A subset.eq C$ with payoff at least
zero. There is therefore $vy^(*) in C$ with
$L\(vx\,vy^(*)\)>= 0$ for all
$vx in X$.

Let
$H = max_(vx in X) parallel\(vx\,1\)parallel_2$,
a finite positive number. By the definition of closure, choose
$tilde(vy) in "conv"\(A\)$ with
$parallel tilde(vy) - vy^(*) parallel_2 < eta\/H$.
For every $vx in X$,

$ \|L\(vx\,tilde(vy)\)- L\(vx\,vy^(*)\)\|<= H parallel tilde(vy) - vy^(*) parallel_2 < eta . $

The bound is uniform over the whole test domain. By the definition of
convex hull, $tilde(vy)$ is a finite convex combination of
points of $A$. Use those response labels and coefficients as $nu$. It
satisfies the desired payoff bound for every test.

Crucially, we took the closure of the moment set, not the closure of the
graph of $F$ or $f$ and not an unjustified compactness assumption on all
distributions. The final distribution uses actual response points.
Approximating its moments accounts for $eta > 0$.





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
