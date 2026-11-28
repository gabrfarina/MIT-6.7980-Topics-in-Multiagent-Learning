#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games",
  instructor: [Weiqiang Zheng],
)

#let prox = math.op("prox")
#set math.equation(numbering: "(1)")

#proof[
  We set $vg^((t)):= gradient ell^((t))(vx^((t))), vp^((t)):= prox_(f)(vx^((t)))$. For any function $f$ that satisfies the properties in the theorem statement, we define the Moreau-envelope potential $M_(f): cX -> RR$ by

  $ M_(f)(vx) = min_(vy in cX) {f(vy) + 1/2 norm(vx - vy)^2} qquad forall vx in cX $ <moreau-envelope-def>

  so that $M_(f)(vx)$ is the optimal value of the same objective that defines $prox_(f)(vx)$. We recall that the gradient update is $vx^((t+1)) = Pi_(cX)(vx^((t)) - eta vg^((t)))$.

  // We had used proj_(cX) in class at some points; however, other materials here use the Pi notation above.

  Since each $ell^((t))$ is convex, the first-order condition for convexity gives $forall vx, vp in cX$,
  $ ell^((t))(vx) - ell^((t))(vp) <= ip(gradient ell^((t))(vx), vx - vp). $ <eq-convex-loss>

  Using this inequality, we can bound the regret for any $f$:

  $ "Reg"^((T))_(f) &= sum_(t=1)^(T) ell^((t))(vx^((t))) - sum_(t=1)^(T) ell^((t))(vp^((t))) = sum_(t=1)^(T) (ell^((t))(vx^((t))) - ell^((t))(vp^((t)))) \
  &limits(<=)^((#[@eq-convex-loss])) sum_(t=1)^(T) ip(vg^((t)), vx^((t)) - vp^((t))). $ <eq-regret>

  Next, we analyze $M_(f)(vx^((t+1)))$ for any $f$. We first bound $M_(f)(vx)$ loosely. Let $vm in argmin_(vy in cX) f(vy)$. Then, for any $vx in cX$,

  $ f(vm) <= M_(f)(vx) limits(=)^((#[@moreau-envelope-def])) min_(vy in cX) {f(vy) + 1/2 norm(vx - vy)^2} <= f(vm) + 1/2 D^2. $ <eq-global-mf-bound>

  We now bound $M_(f)(vx^((t+1)))$ more tightly and in terms of $vx^((t))$ and our parameters. We know that for any closed convex set $cS$, as shown in #citep(<ryu2016primer>, [Section 3, pages 7-8]), $forall va, vb in RR^d$

  $ norm(Pi_(cS) (va) - Pi_(cS) (vb)) <= norm(va - vb). $ <eq-projection>

  By the fact that $vp^((t))$ is already in $cX$, $forall t = 1,...,T$,
  $ M_(f)(vx^((t+1))) &limits(=)^((#[@moreau-envelope-def])) min_(vy in cX) {f(vy) + 1/2 norm(vx^((t+1)) - vy)^2} <= f(vp^((t))) + 1/2 norm(vx^((t+1)) - vp^((t)))^2\
  &= f(vp^((t))) + 1/2 norm(Pi_(cX)(vx^((t)) - eta vg^((t))) - Pi_(cX)(vp^((t))))^2 \
  &limits(<=)^((#[@eq-projection])) f(vp^((t))) + 1/2 norm(vx^((t)) - eta vg^((t)) - vp^((t)))^2 \
  &= (f(vp^((t))) + 1/2 norm(vx^((t)) - vp^((t)))^2) + 1/2 norm(eta vg^((t)))^2 - ip(vx^((t)) - vp^((t)), eta vg^((t))) \
  &= M_(f)(vx^((t))) + 1/2 eta^2 norm(vg^((t)))^2 - eta ip(vx^((t)) - vp^((t)), vg^((t))) \
  &<= M_(f)(vx^((t))) + 1/2 eta^2 G^2 - eta ip(vx^((t)) - vp^((t)), vg^((t))).
  $
  Rearranging,
  $
    ip(vx^((t)) - vp^((t)), vg^((t))) <= frac(M_(f)(vx^((t))) - M_(f)(vx^((t+1))), eta) + 1/2 eta G^2
  $ <eq-ip-upper-bound>
  which, combined with (@eq-regret) and (@eq-global-mf-bound), implies
  $
    "Reg"_(f)^((T)) &limits(<=)^((#[@eq-regret])) sum_(t=1)^(T) ip(vg^((t)), vx^((t)) - vp^((t))) \
    &limits(<=)^((#[@eq-ip-upper-bound])) sum_(t=1)^(T) (frac(M_(f)(vx^((t))) - M_(f)(vx^((t+1))), eta) + 1/2 eta G^2) \
    &= frac(sum_(t=1)^(T) (M_(f)(vx^((t))) - M_(f)(vx^((t+1)))), eta) + 1/2 eta G^2T \
    &= frac(M_(f)(vx^((1))) - M_(f)(vx^((T+1))), eta) + 1/2 eta G^2T \
    &limits(<=)^((#[@eq-global-mf-bound])) frac((f(vm) + 1/2 D^2) - f(vm), eta) + 1/2 eta G^2T \
    &= frac(D^2, 2 eta) + 1/2 eta G^2 T.
  $
]

#remark[Since this upper bound does not depend on $f$, it holds for all admissible $f$ simultaneously.]

// Referring to Task 7/8 might be useful here.
*Implication for local $Phi$-equilibria.* As seen in the examples above,
for linear $f_(vv)(vy) = ip(vv, vy)$ with $norm(vv) <= delta$, $prox_(f_(vv))(vx) = Pi_(cX)(vx - vv)$,
which is a deviation that moves $vx$ by at most $delta$ by (@eq-projection). Hence, gradient descent with $eta = D / (G sqrt(T))$
has regret at most $D G sqrt(T)$ against all such $delta$-local deviations simultaneously.

#lec_bibliography("meta/refs.bib")
