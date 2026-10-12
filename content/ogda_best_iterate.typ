#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: "4.2.1",
  date: [Fall 2026],
  title: "Exercise: best-iterate convergence of OGDA",
)

// The shared heading layout reserves .6in for the section number, which is too
// narrow for "L4.2.1.1". Same layout, with the number column widened to fit.
#show heading: it => context {
  if target() == "html" { return it }
  let space-above = if it.level == 1 { 9mm } else if it.level == 2 { 7.5mm } else { 6mm }
  let space-below = if it.level == 1 { 5mm } else { 4.5mm }
  block(breakable: false, sticky: true, above: space-above, below: space-below)[
    #set text(hyphenate: false)
    #set par(justify: false)
    #if it.numbering != none {
      let number = strong(counter(heading).display())
      [#h(-.4in)#box(width: .3in, fill: gray, height: calc.max(.7mm, (3 - it.level) * 1mm + .7mm))#h(.1in)#box(
          width: calc.max(.6in, measure(number).width + .12in),
        )[#number]#strong(it.body)]
    } else {
      [#h(-.4in)#box(width: .3in, fill: gray, height: 2mm)#h(.1in)#strong(it.body)]
    }
  ]
}

// Start each part on a new page in the PDF; HTML has no pages.
#let part-break = context if target() != "html" { pagebreak(weak: true) }

#v(-4mm)
#paragraph-marker() *OGDA.*~~
For the saddle-point problem $max_(vx in cX) min_(vy in cY) vx^top A vy$ over convex compact sets $cX, cY subset.eq RR^n$, _optimistic gradient descent ascent_ (OGDA) runs
#set math.equation(numbering: "(1)")
$
  cases(
    vx^((t)) <- Pi_cX (vx^((t-1)) + 2 eta A vy^((t-1)) - eta A vy^((t-2))),
    vy^((t)) <- Pi_cY (vy^((t-1)) - 2 eta A^top vx^((t-1)) + eta A^top vx^((t-2))),
  )
$ <eq-ogda>
#set math.equation(numbering: none)
where $Pi_cX$ and $Pi_cY$ are Euclidean projections. We start at $vx^((1)) = 0 in cX$ and $vy^((1)) = 0 in cY$ (@rem-ogda-arbitrary-start handles other starting points), and set $vx^((0)) := vx^((1))$, $vy^((0)) := vy^((1))$. Finally, $norm(cX)_2 := max_(vx in cX) norm(vx)_2$ and $norm(cY)_2 := max_(vy in cY) norm(vy)_2$ are the radii of the feasible sets, and $norm(A)_2 := max_(vy != 0) norm(A vy)_2 \/ norm(vy)_2$ is the operator norm of $A$.

#paragraph-marker() *RVU bound.*~~
We use the #lecture-link("learning2", <sec-rvu>)[RVU bound] in the following form.

#theorem[RVU bound, #citep(<syrgkanis2015fast>)][
  When $nabla psi(vx^((1))) = 0$, all variants of Predictive FTRL and Predictive OMD satisfy
  $
    "Reg"^((T)) <= max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta + eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2,
  $
  where $norm(dot.c)$ is any norm with respect to which $psi$ is $1$-strongly convex, and $norm(dot.c)_*$ is its dual norm.
] <thm-ogda-rvu>

#remark[Arbitrary initial points][
  The requirement $nabla psi(vx^((1))) = 0$ is the only reason for starting at $0$. For an arbitrary $vx^((1)) in cX$, use instead $psi(vx) := 1/2 norm(vx - vx^((1)))_2^2$. Its Bregman divergence is again $1/2 norm(vx - vx')_2^2$, so the algorithm is unchanged, and now $nabla psi(vx^((1))) = 0$. The initial term becomes $max_(xhat in cX) norm(xhat - vx^((1)))_2^2 \/ (2 eta) <= (2 norm(cX)_2)^2 \/ (2 eta) = 2 norm(cX)_2^2 \/ eta$. So Part 1's bounds hold with $norm(cX)_2^2$ and $norm(cY)_2^2$ replaced by $4 norm(cX)_2^2$ and $4 norm(cY)_2^2$, and the constant $4$ in Part 2 becomes $8$.
] <rem-ogda-arbitrary-start>

#part-break
#exercise[OGDA, Part 1: RVU bounds for both players][
The cumulative regret of the max player is
$
  "Reg"_1^((T)) := max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)).
$
Using @thm-ogda-rvu, show that when both players run OGDA,
$
  "Reg"_1^((T)) <= norm(cX)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2.
$
Then argue that the min player enjoys a similar regret bound.

_Hint._ Gradient ascent can be captured by OMD with the Euclidean regularizer $psi(vx) = 1/2 norm(vx)_2^2$. Which variant of Predictive OMD is OGDA, and what are its gradients $vg^((t))$ and predictions $vm^((t))$?
] <ex-ogda-part1>

#reference-solutions(title: [Show / hide solution to Part 1])[
#solution[Part 1][
*OGDA as Predictive OMD.* Reflected Predictive OMD with regularizer $psi$ updates
$
  vx^((t+1)) := argmax_(vx in cX) {ip(vg^((t)) + vm^((t+1)) - vm^((t)), vx) - 1 / eta div(vx, vx^((t)), dgf: psi)}.
$
For $psi(vx) := 1/2 norm(vx)_2^2$, the Bregman divergence is $div(vx, vx', dgf: psi) = 1/2 norm(vx - vx')_2^2$, and completing the square turns the update into a projection:
$
  vx^((t+1)) = Pi_cX (vx^((t)) + eta (vg^((t)) + vm^((t+1)) - vm^((t)))).
$
Substituting the max player's utility gradient $vg^((t)) := A vy^((t))$ and the optimistic prediction $vm^((t)) := vg^((t-1)) = A vy^((t-1))$ gives $vx^((t+1)) = Pi_cX (vx^((t)) + 2 eta A vy^((t)) - eta A vy^((t-1)))$, which is the OGDA update (@eq-ogda).

*Applying @thm-ogda-rvu.* With the norm $norm(dot.c)_2$, the bound of @thm-ogda-rvu has three terms:
$
  "Reg"^((T)) <= underbrace(max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta, "initial term") + underbrace(eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_2^2, "prediction error") - underbrace(1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2, "movement").
$
We check the hypotheses and the left-hand side, then evaluate the three terms.
- _Regularizer._ $psi$ is $1$-strongly convex with respect to $norm(dot.c)_2$, whose dual norm is again $norm(dot.c)_2$, and
  $
    nabla psi(vx^((1))) = vx^((1)) = 0.
  $
- _Regret._ With $vg^((t)) = A vy^((t))$, the regret in @thm-ogda-rvu is the max player's regret:
  $
    "Reg"^((T)) & = max_(vx^* in cX) sum_(t=1)^T ip(A vy^((t)), vx^* - vx^((t))) \
                & = max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)) = "Reg"_1^((T)).
  $
- _Initial term._ Since $vx^((1)) = 0$,
  $
    max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta = max_(xhat in cX) norm(xhat)_2^2 / (2 eta) = norm(cX)_2^2 / (2 eta).
  $
- _Prediction error._ Since $vy^((0)) = vy^((1))$, the $t = 1$ term vanishes:
  $
    eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_2^2 = eta sum_(t=1)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 = eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2.
  $
- _Movement._ The term $-1/(8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2$ involves only the iterates, so it is unchanged.

*Result.* Substituting these into @thm-ogda-rvu, the max player's regret satisfies
$
  "Reg"_1^((T)) <= norm(cX)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A vy^((t)) - A vy^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))_2^2,
$

*The min player.* The min player maximizes the utility $vy |-> -(vx^((t)))^top A vy$. Substituting its gradient $-A^top vx^((t))$ and prediction $-A^top vx^((t-1))$ into the same update gives $vy^((t+1)) = Pi_cY (vy^((t)) - 2 eta A^top vx^((t)) + eta A^top vx^((t-1)))$, the OGDA update for $vy$. Its regret is
$
  "Reg"_2^((T)) := max_(vy^* in cY) sum_(t=1)^T ip(-A^top vx^((t)), vy^* - vy^((t))) = sum_(t=1)^T (vx^((t)))^top A vy^((t)) - min_(vy^* in cY) sum_(t=1)^T (vx^((t)))^top A vy^*,
$
and the same checks, with $vy^((1)) = 0$ and $vx^((0)) = vx^((1))$, give the similar bound
$
  "Reg"_2^((T)) <= norm(cY)_2^2 / (2 eta) + eta sum_(t=2)^T norm(A^top vx^((t)) - A^top vx^((t-1)))_2^2 - 1 / (8 eta) sum_(t=2)^T norm(vy^((t)) - vy^((t-1)))_2^2.
$
]
]

#part-break
#exercise[OGDA, Part 2: total movement is sublinear][
Show that when the learning rate is sufficiently small, namely $eta <= 1 \/ (4 norm(A)_2)$, the total distance of policy changes is sublinear:
$
  sum_(t=2)^T (norm(vx^((t)) - vx^((t-1)))_2 + norm(vy^((t)) - vy^((t-1)))_2) <= 4 sqrt(T) (norm(cX)_2 + norm(cY)_2).
$

_Hint._ The sum of the cumulative regrets of both players is nonnegative, since it is the sum of Nash gaps. Then apply the Cauchy--Schwarz inequality to convert the upper bound on $sum norm(dot.c)_2^2$ into an upper bound on $sum norm(dot.c)_2$.
] <ex-ogda-part2>

#reference-solutions(title: [Show / hide solution to Part 2])[
#solution[Part 2][
Let $L$ be the operator norm of $A$,
$
  L := norm(A)_2 = sup_(vv != 0) norm(A vv)_2 / norm(vv)_2, qquad "so that" qquad norm(A vv)_2 <= L norm(vv)_2 quad "for all" vv.
$
Write $Delta vx^((t)) := vx^((t)) - vx^((t-1))$, $Delta vy^((t)) := vy^((t)) - vy^((t-1))$, and let
$
  S := sum_(t=2)^T (norm(Delta vx^((t)))_2^2 + norm(Delta vy^((t)))_2^2)
$
be the total squared movement. The goal is a bound on $S$ that does not depend on $T$ (Steps 1--3), which Cauchy--Schwarz then turns into the claim (Step 4).

*Step 1: add the two RVU bounds.* The prediction errors in Part 1 are $A vy^((t)) - A vy^((t-1)) = A Delta vy^((t))$ for the max player and $A^top vx^((t)) - A^top vx^((t-1)) = A^top Delta vx^((t))$ for the min player, and the two movement terms add up to $S$. Adding the two bounds of Part 1,
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) + eta sum_(t=2)^T (norm(A Delta vy^((t)))_2^2 + norm(A^top Delta vx^((t)))_2^2) - 1 / (8 eta) S.
$

*Step 2: operator norm and step size.* By definition of the operator norm, and since $norm(A^top)_2 = norm(A)_2$,
$
  sum_(t=2)^T (norm(A Delta vy^((t)))_2^2 + norm(A^top Delta vx^((t)))_2^2) <= L^2 sum_(t=2)^T (norm(Delta vy^((t)))_2^2 + norm(Delta vx^((t)))_2^2) = L^2 S.
$
Substituting into Step 1,
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - (1 / (8 eta) - eta L^2) S.
$
If $eta <= 1 \/ (4 L)$, then $eta L^2 <= 1 \/ (16 eta)$, so $1 \/ (8 eta) - eta L^2 >= 1 \/ (16 eta)$ and
#set math.equation(numbering: "(1)")
$
  "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - 1 / (16 eta) S.
$ <eq-ogda-sum-upper>
#set math.equation(numbering: none)

*Step 3: bound $S$.* The right-hand side of (@eq-ogda-sum-upper) decreases in $S$, so any lower bound on $"Reg"_1^((T)) + "Reg"_2^((T))$ caps $S$. We show $"Reg"_1^((T)) + "Reg"_2^((T)) >= 0$. In the sum of the two regrets, the terms $sum_t (vx^((t)))^top A vy^((t))$ cancel. With $overline(vx) := 1/T sum_t vx^((t)) in cX$ and $overline(vy) := 1/T sum_t vy^((t)) in cY$ (by convexity),
$
  "Reg"_1^((T)) + "Reg"_2^((T)) = T (max_(vx^* in cX) (vx^*)^top A overline(vy) - min_(vy^* in cY) overline(vx)^top A vy^*) >= T (overline(vx)^top A overline(vy) - overline(vx)^top A overline(vy)) = 0,
$
where the inequality takes $vx^* = overline(vx)$ and $vy^* = overline(vy)$. (This is $T$ times the #lecture-link("learning_intro", <thm-regret-gap>)[saddle point gap] of $(overline(vx), overline(vy))$.) Chaining with (@eq-ogda-sum-upper),
$
  0 <= "Reg"_1^((T)) + "Reg"_2^((T)) <= (norm(cX)_2^2 + norm(cY)_2^2) / (2 eta) - 1 / (16 eta) S,
$
that is,
$
  S <= 8 (norm(cX)_2^2 + norm(cY)_2^2).
$

*Step 4: from $S$ to the total movement.* By the Cauchy--Schwarz inequality over the $T - 1$ terms, then $(a + b)^2 <= 2 a^2 + 2 b^2$ (which gives the sum $S$), and finally Step 3,
$
  & sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) \
  & quad <= sqrt(T - 1) (sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2)^2)^(1\/2) <= sqrt(T - 1) sqrt(2 S) \
  & quad <= 4 sqrt(T - 1) sqrt(norm(cX)_2^2 + norm(cY)_2^2) <= 4 sqrt(T) (norm(cX)_2 + norm(cY)_2),
$
where the last step uses $sqrt(a^2 + b^2) <= a + b$ for $a, b >= 0$.
]
]

#part-break
#exercise[OGDA, Part 3: sublinear regret and best-iterate convergence][
For the projection step $vw <- Pi_cX (vv)$, the following inequality holds for any $vx in cX$:
$
  ip(vv - vw, vx - vw) <= 0.
$
Intuitively, the vector $vv - vw$ points outward from the convex set $cX$ at the point $vw$, and any vector $vx - vw$ pointing into $cX$ forms an obtuse angle with it.

Show that when $eta <= 1 \/ (4 norm(A)_2)$, the max player achieves sublinear cumulative regret:
$
  max_(vx^* in cX) sum_(t=1)^T (vx^*)^top A vy^((t)) - sum_(t=1)^T (vx^((t)))^top A vy^((t)) <= O(sqrt(T) / eta (norm(cX)_2 + norm(cY)_2)^2).
$
Then conclude that OGDA achieves best-iterate convergence: with a proper choice of $eta$, for every $T$ there exists some $t <= T$ such that
$
  (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* <= O(1 / sqrt(T) (norm(cX)_2 + norm(cY)_2)^2 norm(A)_2).
$

_Hint._ Start by applying the projection inequality to the update $vx^((t)) <- Pi_cX (vx^((t-1)) + 2 eta A vy^((t-1)) - eta A vy^((t-2)))$ with $vx = vx^*$. From this, extract an upper bound on $(vx^*)^top A vy^((t-1)) - (vx^((t-1)))^top A vy^((t-1))$. The additional inner product terms can be bounded individually using the Cauchy--Schwarz inequality.
] <ex-ogda-part3>

#reference-solutions(title: [Show / hide solution to Part 3])[
#solution[Part 3][
Write $L := norm(A)_2$, $Delta vx^((t)) := vx^((t)) - vx^((t-1))$, $Delta vy^((t)) := vy^((t)) - vy^((t-1))$, and $D := norm(cX)_2 + norm(cY)_2$. Fix an alternative strategy $vx^* in cX$, the fixed strategy whose payoff the max player compares its own against in hindsight, and let
$
  r_t := (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^((t)) = ip(A vy^((t)), vx^* - vx^((t)))
$
be the regret of round $t$, so that $"Reg"_1^((T)) = max_(vx^* in cX) sum_(t=1)^T r_t$.

*Decomposition of $r_(t-1)$.* For $t >= 2$, let $vq^((t)) := 2 A vy^((t-1)) - A vy^((t-2))$, so that $vx^((t)) = Pi_cX (vx^((t-1)) + eta vq^((t)))$. Substituting $A vy^((t-1)) = vq^((t)) - A Delta vy^((t-1))$ and $vx^* - vx^((t-1)) = (vx^* - vx^((t))) + Delta vx^((t))$,
#set math.equation(numbering: "(1)")
$
  r_(t-1) & = ip(A vy^((t-1)), vx^* - vx^((t-1))) \
          & = underbrace(ip(vq^((t)), vx^* - vx^((t))), "Step 1") + underbrace(ip(A Delta vy^((t-1)), vx^((t)) - vx^*) + ip(A vy^((t-1)), Delta vx^((t))), "Step 2").
$ <eq-ogda-r-decomp>
#set math.equation(numbering: none)

*Step 1: bound the first term with the projection inequality.* The projection inequality with $vv = vx^((t-1)) + eta vq^((t))$, $vw = vx^((t))$, and $vx = vx^*$ gives
$
  ip(vx^((t-1)) - vx^((t)), vx^* - vx^((t))) + eta ip(vq^((t)), vx^* - vx^((t))) <= 0,
$
that is, $eta ip(vq^((t)), vx^* - vx^((t))) <= ip(Delta vx^((t)), vx^* - vx^((t)))$.
Expanding $norm(vx^* - vx^((t-1)))_2^2 = norm((vx^* - vx^((t))) + Delta vx^((t)))_2^2$ gives the identity
$
  2 ip(Delta vx^((t)), vx^* - vx^((t))) = norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2 - norm(Delta vx^((t)))_2^2.
$
Dropping the last (nonpositive) term,
$
  ip(vq^((t)), vx^* - vx^((t))) <= 1 / (2 eta) (norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2).
$

*Step 2: bound the other two terms with Cauchy--Schwarz.* By Cauchy--Schwarz and the definition of $L$, using $norm(vx^((t)) - vx^*)_2 <= 2 norm(cX)_2$ and $norm(vy^((t-1)))_2 <= norm(cY)_2$,
$
  ip(A Delta vy^((t-1)), vx^((t)) - vx^*) <= 2 L norm(cX)_2 norm(Delta vy^((t-1)))_2, qquad ip(A vy^((t-1)), Delta vx^((t))) <= L norm(cY)_2 norm(Delta vx^((t)))_2.
$
Substituting Steps 1 and 2 into (@eq-ogda-r-decomp), for every $t = 2, ..., T$,
$
  r_(t-1) <= 1 / (2 eta) (norm(vx^* - vx^((t-1)))_2^2 - norm(vx^* - vx^((t)))_2^2) + 2 L norm(cX)_2 norm(Delta vy^((t-1)))_2 + L norm(cY)_2 norm(Delta vx^((t)))_2.
$

*Step 3: sum and invoke Part 2.* Summing over $t = 2, ..., T$, the distances telescope, and $norm(vx^* - vx^((1)))_2^2 <= 4 norm(cX)_2^2$. Since $Delta vy^((1)) = 0$ by the convention $vy^((0)) = vy^((1))$, the sum of $norm(Delta vy^((t-1)))_2$ is at most $sum_(t=2)^T norm(Delta vy^((t)))_2$. Bounding both $norm(cX)_2$ and $norm(cY)_2$ by $D$,
$
  sum_(t=1)^(T-1) r_t & <= (2 norm(cX)_2^2) / eta + 2 L D sum_(t=2)^T (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) \
                      & <= (2 D^2) / eta + 2 L D dot.c 4 sqrt(T) D <= (2 D^2) / eta + (2 sqrt(T) D^2) / eta,
$
where we used Part 2 and then $L <= 1 \/ (4 eta)$.

*Step 4: the last round.* Step 3 covers $r_1, ..., r_(T-1)$. For $r_T$, by Cauchy--Schwarz, $r_T <= L norm(cY)_2 dot.c 2 norm(cX)_2 <= L D^2 \/ 2 <= D^2 \/ (8 eta)$, using $norm(cX)_2 norm(cY)_2 <= D^2 \/ 4$.

Adding Steps 3 and 4 and using $1 <= sqrt(T)$,
$
  sum_(t=1)^T r_t <= (2 + 1 / 8 + 2 sqrt(T)) D^2 / eta <= (5 sqrt(T) D^2) / eta.
$
The bound holds for every $vx^* in cX$, so $"Reg"_1^((T)) <= 5 sqrt(T) D^2 \/ eta = O(sqrt(T) D^2 \/ eta)$. The symmetric argument for the min player, with gradient $-A^top vx^((t))$, gives $"Reg"_2^((T)) <= 5 sqrt(T) D^2 \/ eta$.

*Step 5: from cumulative regret to the best iterate.* A saddle point $(vx^*, vy^*)$ exists by the minimax theorem, since $cX$ and $cY$ are convex and compact. Define the gap of round $t$,
$
  G_t := (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^*.
$
Adding and subtracting $(vx^((t)))^top A vy^((t))$ splits it into one round of regret for each player:
$
  G_t = underbrace((vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^((t)), "max player vs." vx^*) + underbrace((vx^((t)))^top A vy^((t)) - (vx^((t)))^top A vy^*, "min player vs." vy^*).
$
Summing over $t$, the first bracket sums to at most $"Reg"_1^((T))$ (with $vx^*$ as the max player's alternative strategy) and the second to at most $"Reg"_2^((T))$ (with $vy^*$ as the min player's), so
$
  sum_(t=1)^T G_t <= "Reg"_1^((T)) + "Reg"_2^((T)) <= (10 sqrt(T) D^2) / eta.
$
Each $G_t$ is nonnegative. With $v := (vx^*)^top A vy^*$, the saddle-point property gives $(vx^*)^top A vy >= v$ for all $vy in cY$ and $vx^top A vy^* <= v$ for all $vx in cX$, so
$
  G_t = (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* >= v - v = 0.
$
Hence
$
  min_(1 <= t <= T) G_t <= 1 / T sum_(t=1)^T G_t <= (10 D^2) / (eta sqrt(T)).
$

*Step 6: choose the step size.* Take $eta := 1 \/ (4 L)$ (if $L = 0$, every $G_t$ is $0$). Then $1 \/ eta = 4 L$, and some $t <= T$ satisfies
$
  (vx^*)^top A vy^((t)) - (vx^((t)))^top A vy^* <= (40 norm(A)_2 (norm(cX)_2 + norm(cY)_2)^2) / sqrt(T) = O(1 / sqrt(T) (norm(cX)_2 + norm(cY)_2)^2 norm(A)_2).
$
]

]

#reference-solutions(title: [Show / hide solution outlines])[
#block(breakable: false)[
*Solution outlines*

Here $L := norm(A)_2$, $D := norm(cX)_2 + norm(cY)_2$, and the step size satisfies $eta <= 1 \/ (4 L)$ in Parts 2 and 3.

#align(center)[
#table(
  columns: (auto, 1fr, 1fr),
  align: left,
  inset: 6pt,
  stroke: 0.4pt + luma(170),

  table.header([*Part*], [*Result*], [*Main tools*]),

  [1], [RVU bound for each player, with initial term $norm(cX)_2^2 \/ (2 eta)$ (resp. $norm(cY)_2^2 \/ (2 eta)$)], [OGDA is reflected Predictive OMD with $psi = 1/2 norm(dot.c)_2^2$ and $vm^((t)) = vg^((t-1))$],

  [2], [$sum_t (norm(Delta vx^((t)))_2 + norm(Delta vy^((t)))_2) <= 4 sqrt(T) D$], [Sum of RVU bounds; operator norm; nonnegative combined regret; Cauchy--Schwarz],

  [3], [$"Reg"_1^((T)), "Reg"_2^((T)) <= 5 sqrt(T) D^2 \/ eta$; some $t <= T$ has gap $<= 40 L D^2 \/ sqrt(T)$], [Projection inequality; telescoping; Part 2; nonnegative gaps; minimum $<=$ average],
)
]
]
]

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)
