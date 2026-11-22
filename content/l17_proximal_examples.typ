#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games: examples of proximal regret",
  instructor: [Weiqiang Zheng],
)

= Examples of proximal regret <sec-l17-proximal-examples>

We have seen that a strategy modification $phi : cX -> cX$ defines a regret benchmark. What kinds of modifications can be obtained from proximal operators? Recall that, for a nonempty compact convex set $cX subset.eq RR^d$ and a proper lower-semicontinuous function $f : cX -> (-infinity, +infinity]$, a _proximal deviation_ selects a minimizer
$
  "prox"_f(vx) in argmin_(vy in cX) { f(vy) + 1/2 norm(vy - vx)^2 }.
$
The function $f$ is fixed across rounds; it is not the online loss $ell^((t))$. A minimizer exists under these assumptions, although it need not be unique. Choosing one minimizer at each input gives a deviation rule $phi_f$. In the examples below the minimizer is unique, except where explicitly noted.

For losses $ell^((1)), dots, ell^((T))$ and played strategies $vx^((1)), dots, vx^((T))$, regret against a deviation rule $phi$ is
$
  R_T(phi) = sum_(t=1)^T (ell^((t))(vx^((t))) - ell^((t))(phi(vx^((t))))).
$
For a family $cal(F)$ of admissible functions, its proximal regret is the supremum of $R_T(phi_f)$ over $f in cal(F)$ *and* all allowed selections $phi_f$. In particular, the same deviation rule must be used across rounds. We will exhibit familiar deviation families by specifying $f$.

== Singleton indicators: external regret

#example[Constant deviations from singleton indicators][
  Fix an arbitrary comparison strategy $va in cX$ and define its indicator function by
  $
    f_va(vy) = cases(0 & "if" vy = va, +infinity & "otherwise")
  $
  Since every $vy != va$ has infinite objective value, the proximal problem has the unique minimizer $va$, independently of $vx$:
  $
    "prox"_(f_va)(vx) = va quad "for all" vx in cX.
  $
  Thus the family of singleton indicators produces _exactly_ the constant strategy modifications. Taking the supremum over this family yields
  $
    sup_(va in cX) R_T("prox"_(f_va))
      = sum_(t=1)^T ell^((t))(vx^((t)))
        - min_(va in cX) sum_(t=1)^T ell^((t))(va),
  $
  which is the usual external regret. In particular, full proximal regret is at least external regret, because it competes with a larger collection of deviations.
]

A useful contrast is the _identity_ deviation. If $f$ is constant (and finite) on $cX$, then its proximal objective is minimized uniquely by $vy = vx$, so $"prox"_f(vx) = vx$ and $R_T("prox"_f) = 0$. Consequently, full proximal regret is always nonnegative, even though external regret can be negative.

== Set indicators: nearest-point deviations

An indicator may also enforce membership in a larger set. For a nonempty closed subset $S subset.eq cX$, let $f_S(vy) = 0$ on $S$ and $+infinity$ outside $S$. Then
$
  "prox"_(f_S)(vx) in argmin_(vy in S) norm(vy-vx)^2.
$
The deviation moves to a nearest point of $S$. If $S$ is convex, this is the unique Euclidean projection $Pi_S(vx)$. If $S$ is nonconvex, multiple nearest points may exist; such selections still belong to the proximal-deviation family.

#example[Projection onto a feasible interval][
  For $cX = [0,1]$ and $S = [1/4, 3/4]$, the indicator deviation is
  $
    "prox"_(f_S)(x) = cases(
      1/4 & "if" x < 1/4,
      x & "if" 1/4 <= x <= 3/4,
      3/4 & "if" x > 3/4.
    )
  $
  Unlike the constant deviations above, the replacement strategy depends on the current strategy.
]

== Linear functions: projected translations

#example[Linear proximal objectives][
  Let $vv in RR^d$ and take $f_v(vy) = ip(vv,vy)$. Completing the square gives
  $
    ip(vv,vy) + 1/2 norm(vy-vx)^2
      = 1/2 norm(vy-(vx-vv))^2 + ip(vv,vx) - 1/2 norm(vv)^2.
  $
  The last two terms do not depend on $vy$. Hence
  $
    "prox"_(f_v)(vx) = Pi_cX(vx-vv).
  $
  Thus linear functions yield a family of _projected translations_: the deviation takes a fixed step and projects back to the strategy set. This choice of linear $f$ gives the deviations studied under _projection-based regret_ (also called _no-move regret_); compare Cai et al., Section 1.1.

  For a one-dimensional example, take $cX=[0,1]$ and $v=-0.3$. Then $"prox"_(f_v)(0.4)=0.7$, while $"prox"_(f_v)(0.9)=1$: the second step is truncated at the boundary. Unlike external regret, the comparator is not obliged to use the same replacement action on every round.
]

== Quadratic functions: affine deviations

Quadratic functions can encode more general affine strategy modifications. The constraint that the modification maps $cX$ back into itself is essential.

#example[An affine proximal map][
  Let $A in RR^(d times d)$ be symmetric positive definite and $vb in RR^d$. Suppose the affine map $phi(vx)=A vx+vb$ sends $cX$ into itself. Define on $cX$
  $
    f(vy)=1/2 vy^top (A^(-1)-I) vy - ip(A^(-1) vb,vy).
  $
  After adding the proximal quadratic, the terms depending on $vy$ become
  $
    1/2 vy^top A^(-1) vy - ip(A^(-1) vb + vx,vy).
  $
  Its gradient with respect to $vy$ is
  $
    A^(-1) vy - A^(-1) vb - vx,
  $
  which vanishes exactly at $vy=A vx+vb$. The Hessian $A^(-1)$ is positive definite. Therefore this point is the unique unconstrained minimizer, and our assumption $A vx+vb in cX$ makes it the constrained minimizer as well:
  $
    "prox"_f(vx) = A vx+vb.
  $
  For example, on $cX=[0,1]$, choosing $A=1/2$ and $b=1/4$ gives $f(y)=1/2 y^2 - 1/2 y$ and $"prox"_f(x)=x/2+1/4$. This sends the interval into $[1/4,3/4]$ and is neither an identity nor a constant map.
]

The calculation uses strict convexity of the *proximal objective*, whose Hessian is $A^(-1)$. It also uses feasibility: if $A vx+vb$ does not lie in $cX$, the unconstrained minimizer does not establish the displayed formula on $cX$. The result extends to symmetric positive-semidefinite (possibly singular) $A$ by a different argument; see #link("https://arxiv.org/html/2511.01852v3")[Cai et al., Section 3.3].

== A limitation: not every deviation is proximal

These examples cover much more than constant deviations, but not every strategy modification can be obtained from a proximal operator. The following elementary test identifies one obstruction.

#example[A deviation that cannot be proximal][
  Suppose $p = "prox"_f(x)$ and $q = "prox"_f(x')$ are any selected minimizers for the _same_ function $f$. Their optimality gives
  $
    f(p)+1/2 norm(p-x)^2 &<= f(q)+1/2 norm(q-x)^2, \
    f(q)+1/2 norm(q-x')^2 &<= f(p)+1/2 norm(p-x')^2.
  $
  Adding the inequalities cancels $f(p)$ and $f(q)$; expanding the squared norms yields
  $
    ip(p-q,x-x') >= 0.
  $
  In particular, on $cX=[-1,1]$, the reflection $phi(x)=-x$ cannot be a proximal deviation: choosing $x=1$ and $x'=-1$ makes the left-hand side equal to $(-2)(2)=-4$. This necessary _monotonicity_ condition is only a two-point test; the exact characterization uses cyclic monotonicity (#link("https://arxiv.org/html/2511.01852v3")[Cai et al., Section 3.2]).
]

Thus proximal regret strictly enriches the familiar constant-deviation benchmark while retaining a structured class of modifications. The following sections state and prove that online gradient descent controls regret against *every* proximal deviation with the same order-$sqrt(T)$ bound as for external regret.

// Source and adaptation note (for the TA's review):
// - Primary lecture source: L17 handwritten notes, page 7 (examples).
// - Cai, Daskalakis, Luo, Wei, Zheng (2026), arXiv:2511.01852v3,
//   Introduction and Sections 3.2-3.3, for formal definitions and qualifications.
// - Explanations, computations, interval example, and monotonicity demonstration
//   are written afresh for this section.
// - AI assistance with drafting, mathematical checks, and Typst editing must be disclosed in the PR and Gradescope report.
