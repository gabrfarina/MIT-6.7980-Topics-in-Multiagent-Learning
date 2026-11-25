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

  so that $M_(f)(vx)$ is the optimal value of the same objective that defines $prox_(f)(vx)$. We denote the Euclidean projection onto a set $cS$ by $Pi_(cS): RR^(d)-> cS$. With this notation, the gradient update becomes $vx^((t+1)) = Pi_(cX)(vx^((t)) - eta vg^((t)))$.

  // We had used proj_(cX) in class at some points; however, other materials here use the Pi notation above.

  Since each $ell^((t))$ is convex, $forall vx, vp in cX$,
  $ ell^((t))(vx) - ell^((t))(vp) <= ip(gradient ell^((t))(vx), vx - vp). $ <eq-convex-loss>

  Using this inequality, we can bound the regret for any $f$:

  $ "Reg"^((T))_(f) &= sum_(t=1)^(T) ell^((t))(vx^((t)))  - sum_(t=1)^(T) ell^((t))(vp^((t))) = sum_(t=1)^(T) (ell^((t))(vx^((t))) - ell^((t))(vp^((t)))) \
  &limits(<=)^((#[@eq-convex-loss])) sum_(t=1)^(T) ip(vg^((t)), vx^((t)) - vp^((t))). $ <eq-regret>

  Next, we analyze $M_(f)(vx^((t+1)))$ for any $f$. We first bound $M_(f)(vx)$ loosely. Let $vm in argmin_(vy in cX) f(vy).$ Then, for any $vx in cX$,

  $ f(vm) <= M_(f)(vx) limits(=)^((#[@moreau-envelope-def])) min_(vy in cX) {f(vy) + 1/2 norm(vx - vy)^2} <= f(vm) + 1/2 D^2. $ <eq-global-mf-bound>

  We now bound $M_(f)(vx^((t+1)))$ more tightly, in terms of $vx^((t))$ and our parameters. We know that for any closed convex set $cS$,

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
  Since this upper bound does not depend on $f$, it also holds for $sup_(f in F) "Reg"_(f)^((T))$.
]

// Let us consider a family of functions $F := {f_(vv): f_(vv)(vx) = ip(vv, vx), norm(vv) <= delta}$. We see that $forall f_(vv) in F$ and $forall vx in cX$,

// $
// prox_(f_(vv))(vx) &= argmin_(y in cX) {f_(vv)(y) + 1/2 norm(vx - vy)^2} \
// &= argmin_(y in cX) {1/2 norm(vv)^2 - ip(vv, vx) +f_(vv)(y) + 1/2 norm(vx - vy)^2} \
// &= argmin_(y in cX) {1/2 norm((vx - vy) - vv)^2}  = argmin_(y in cX) {1/2 norm((vx - vv) - vy)^2} = Pi_(cX)(vx - vv),
// $

// which moves $vx$ by at most $delta$ by (#[@eq-projection]). Hence, every map $vx |-> prox_(f_(vv))(vx)$ belongs to $Phi(delta)$. Then, choosing $eta = D/(G sqrt(T))$ in the theorem gives

// $
//   max_(f_(vv) in F) "Reg"_(f_(vv))^((T)) <= D G sqrt(T).
// $
// Hence, the regret against all these local deviations is sublinear.

// On the other hand, taking $f$ to be the indicator function $I_(va)$ of a point $va in cX$ ($0$ at $va$ and $+oo$ elsewhere) gives $prox_(f) = va$ and represents external regret. Therefore, proximal regret strengthens external regret while also capturing a tractable family of local deviations in $Phi(delta)$.

// Referring to Task 7 might be useful here.
*Implication for local $Phi$-equilibria.* As seen in the examples above, for linear $f_(vv)(vy) = ip(vv, vy)$ with $norm(vv) <= delta$, $prox_(f_(vv))(vx) = Pi_(cX)(vx - vv)$, which is a deviation that moves $vx$ by at most $delta$. Hence, all these proximities are in $Phi(delta)$. If we choose $eta = D / (G sqrt(T))$, gradient descent attains regret at most $D G sqrt(T)$ against all of these local deviations simultaneously.
