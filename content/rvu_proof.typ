#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
  lec_num: "S4.1.2",
  date: [Fall 2026],
  title: "Proof of the RVU bound",
)

// The shared heading layout reserves .6in for the section number, which is too
// narrow for "S4.1.2.1". Same layout, with the number column widened to fit.
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

#v(-4mm)
The goal of these notes is to prove the following result, the #lecture-link("learning2", <sec-rvu>)[RVU bound] (regret bounded by variation in utilities).

#theorem[RVU bound, #citep(<syrgkanis2015fast>)][
  Let $psi$ be $1$-strongly convex with respect to a norm $norm(dot.c)$, and initialize both algorithms at $vx^((1)) = argmin_(vx in cX) psi(vx)$ (see @sec-rvu-setting). Then Predictive FTRL and non-reflected Predictive OMD satisfy
  $
    "Reg"^((T)) <= max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta + eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2,
  $
  where $norm(dot.c)_*$ is the dual norm of $norm(dot.c)$.
] <thm-rvu>

#paragraph-marker() *Scope.*~~
The #lecture-link("learning2", <sec-rvu>)[course statement] of the RVU bound covers all three predictive algorithms in the #lecture-link("learning2", <sec-predictivity>)[table of predictive algorithms]. _These notes prove it only for Predictive FTRL and non-reflected Predictive OMD._ For Legendre regularizers, the three variants coincide, so this also covers reflected Predictive OMD in that case; reflected Predictive OMD with a general regularizer is not treated here.

Following #citep(<syrgkanis2015fast>), the proof is organized as follows.

- @sec-rvu-setting (_Review_). The online protocol, the two algorithms and their auxiliary sequences, and why both start at $vx^((1)) = vz^((1)) = argmin psi$.
- @sec-rvu-intermediate (_The intermediate bound_). @thm-rvu-intermediate, due to #citep(<rakhlin2013optimization>) for OMD, holds for arbitrary predictions $vm^((t))$. Its proof reduces to a single algorithm-specific ingredient, the stability bound of @lem-rvu-stability.
- @sec-rvu-ftrl (_Proof for Predictive FTRL_). Proves @lem-rvu-stability using the strong concavity of the leader objective (@lem-rvu-strong-concavity).
- @sec-rvu-omd (_Proof for non-reflected Predictive OMD_). Proves @lem-rvu-stability using the Bregman three-point inequality (@lem-rvu-three-point).
- @sec-rvu-final (_From the intermediate bound to the RVU bound_). A short algebraic step, common to both algorithms, completes the proof of @thm-rvu.

= Review <sec-rvu-setting>

#paragraph-marker() *Protocol and regret.*~~
The learner's strategies lie in a convex and compact set $cX$. At each time $t = 1, ..., T$, the learner
+ receives a prediction $vm^((t))$ of the upcoming utility gradient;
+ plays a strategy $vx^((t)) in cX$;
+ observes the utility gradient $vg^((t))$.
The regret against a fixed comparator $xhat in cX$, and the regret, are
$
  "Reg"^((T))(xhat) := sum_(t=1)^T ip(vg^((t)), xhat - vx^((t))), qquad "Reg"^((T)) := max_(xhat in cX) "Reg"^((T))(xhat).
$

#paragraph-marker() *The two algorithms.*~~
Both algorithms have a learning rate $eta > 0$ and a regularizer $psi : cX -> RR$ that is $1$-strongly convex with respect to a norm $norm(dot.c)$. (The precise form of strong convexity we use is recalled in @sec-rvu-ftrl, and the additional differentiability assumption for OMD in @sec-rvu-omd.) Both are analyzed through an _auxiliary sequence_ $vz^((t))$, which uses the observed gradients but not the predictions. Using the indexing of the #lecture-link("learning2", <sec-predictivity>)[table of predictive algorithms]:

- *Predictive FTRL.* The auxiliary point is the non-predictive ("be-the-leader") FTRL iterate. It is used only in the proof, not by the algorithm.
  $
      vx^((t)) & := argmax_(vx in cX) {ip(vm^((t)) + sum_(tau=1)^(t-1) vg^((tau)), vx) - 1 / eta psi(vx)}, \
    vz^((t+1)) & := argmax_(vz in cX) {ip(sum_(tau=1)^t vg^((tau)), vz) - 1 / eta psi(vz)}.
  $
- *Predictive OMD (non-reflected).* The algorithm itself maintains the auxiliary point.
  $
      vx^((t)) & := argmax_(vx in cX) {ip(vm^((t)), vx) - 1 / eta div(vx, vz^((t)), dgf: psi)}, \
    vz^((t+1)) & := argmax_(vz in cX) {ip(vg^((t)), vz) - 1 / eta div(vz, vz^((t)), dgf: psi)}.
  $

In both algorithms, the played point $vx^((t))$ uses the prediction $vm^((t))$, while the auxiliary point $vz^((t+1))$ uses the true gradient $vg^((t))$ in its place. Comparing the two is what drives the analysis.

#paragraph-marker() *Initialization.*~~
As assumed in @thm-rvu, both algorithms start at $vx^((1)) = vz^((1)) := argmin_(vx in cX) psi(vx)$. For FTRL, $vz^((1))$ is the update with an empty sum of gradients. In both algorithms, $vx^((1)) = vz^((1))$ holds with the prediction $vm^((1)) := 0$; for OMD this uses @lem-rvu-bregman-norm.

#remark[
  The course version of this result assumes $nabla psi(vx^((1))) = 0$ instead. By convexity, $psi(vx) >= psi(vx^((1))) + ip(nabla psi(vx^((1))), vx - vx^((1))) = psi(vx^((1)))$ for all $vx in cX$, so this implies that $vx^((1))$ minimizes $psi$, and is covered here.
]

= The intermediate bound <sec-rvu-intermediate>

#theorem[Intermediate bound, #citep(<rakhlin2013optimization>, [Lemma 1]); see also #citep(<syrgkanis2015fast>, [Theorems 17 and 19])][
  For any sequence of predictions $vm^((t))$, Predictive FTRL and non-reflected Predictive OMD, initialized as in @sec-rvu-setting so that $vx^((1)) = vz^((1)) = argmin psi$, satisfy, for every $xhat in cX$,
  $
    "Reg"^((T))(xhat) <= & (psi(xhat) - psi(vx^((1)))) / eta + sum_(t=1)^T norm(vg^((t)) - vm^((t)))_* norm(vx^((t)) - vz^((t+1))) \
                         & - 1 / (2 eta) sum_(t=1)^T (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2),
  $
  where $norm(dot.c)_*$ is the dual norm of $norm(dot.c)$.
] <thm-rvu-intermediate>

The bound has two parts. The middle term is the price of an imperfect prediction: it is large only if $vm^((t))$ is far from $vg^((t))$ _and_ the played point $vx^((t))$ is far from $vz^((t+1))$, the point the algorithm would have produced had it used $vg^((t))$ instead. The last term is a stability bonus coming from strong convexity. It is present whatever the predictions are; a vanilla regret proof simply discards it.

#paragraph-marker() *Reduction to a stability bound.*~~
The proof splits each round's regret into a _prediction-error_ term, which is handled in the same way for both algorithms, and a remainder $S_t$, which is the only algorithm-specific part. Concretely, adding and subtracting $ip(vg^((t)), vz^((t+1)))$ and $ip(vm^((t)), vz^((t+1)) - vx^((t)))$ gives the identity
#set math.equation(numbering: "(1)")
$
  ip(vg^((t)), xhat - vx^((t))) = underbrace(ip(vg^((t)) - vm^((t)), vz^((t+1)) - vx^((t))), "prediction error") + underbrace(ip(vm^((t)), vz^((t+1)) - vx^((t))) + ip(vg^((t)), xhat - vz^((t+1))), =: S_t).
$ <eq-rvu-decomposition>
#set math.equation(numbering: none)
(Expanding the right-hand side, all terms involving $vm^((t))$ and $vz^((t+1))$ cancel.) Note that $S_t$ still involves the prediction $vm^((t))$; what it leaves out is the prediction _error_. The algorithm-specific ingredient is the following bound on $S_t$, proved in @sec-rvu-ftrl for FTRL and in @sec-rvu-omd for OMD.

#lemma[Stability bound][
  For $t = 1, ..., T$ and $xhat in cX$, let
  $
    S_t := ip(vm^((t)), vz^((t+1)) - vx^((t))) + ip(vg^((t)), xhat - vz^((t+1))).
  $
  For any sequence of predictions $vm^((t))$, Predictive FTRL and non-reflected Predictive OMD, initialized as in @sec-rvu-setting so that $vx^((1)) = vz^((1)) = argmin psi$, satisfy, for every $xhat in cX$,
  $
    sum_(t=1)^T S_t <= (psi(xhat) - psi(vx^((1)))) / eta - 1 / (2 eta) sum_(t=1)^T (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
] <lem-rvu-stability>

In both cases, each update is a regularized maximization, and comparing the objective at its maximizer with its value at another point yields a negative quadratic term. Assuming @lem-rvu-stability, the intermediate bound follows immediately.

#proof[of @thm-rvu-intermediate, assuming @lem-rvu-stability][
  Fix $xhat in cX$. Summing the identity (@eq-rvu-decomposition) over $t$,
  $
    "Reg"^((T))(xhat) = sum_(t=1)^T ip(vg^((t)) - vm^((t)), vz^((t+1)) - vx^((t))) + sum_(t=1)^T S_t.
  $
  The dual norm is defined as $norm(vv)_* := max_(norm(vw) <= 1) ip(vv, vw)$, so that $ip(vv, vw) <= norm(vv)_* norm(vw)$ for all vectors $vv, vw$. Applying this to each prediction-error term,
  $
    ip(vg^((t)) - vm^((t)), vz^((t+1)) - vx^((t))) <= norm(vg^((t)) - vm^((t)))_* norm(vx^((t)) - vz^((t+1))).
  $
  Bounding the second sum with @lem-rvu-stability gives the statement.
]

= Proof for Predictive FTRL <sec-rvu-ftrl>

#paragraph-marker() *Strong convexity.*~~
We use the $1$-strong convexity of $psi$ in the following form: for all $vx, vx' in cX$ and $lambda in [0, 1]$,
$
  psi(lambda vx + (1 - lambda) vx') <= lambda psi(vx) + (1 - lambda) psi(vx') - (lambda (1 - lambda)) / 2 norm(vx - vx')^2.
$
For differentiable $psi$, this is equivalent to the gradient form used in the #lecture-link("learning1", <ftrl-omd-general-case>)[definition of a distance-generating function].

#lemma[
  Let $f : cX -> RR$ be $(1\/eta)$-strongly concave, meaning that $-eta f$ satisfies the strong convexity inequality above, and let $vx^* in argmax_(vx in cX) f(vx)$. Then
  $
    f(vx) <= f(vx^*) - 1 / (2 eta) norm(vx - vx^*)^2 qquad forall vx in cX.
  $
] <lem-rvu-strong-concavity>
#proof[
  Fix $vx in cX$ and $lambda in (0, 1)$. Since $vx^* + lambda (vx - vx^*) in cX$, optimality of $vx^*$ and strong concavity give
  $
    f(vx^*) >= f(vx^* + lambda (vx - vx^*)) >= lambda f(vx) + (1 - lambda) f(vx^*) + (lambda (1 - lambda)) / (2 eta) norm(vx - vx^*)^2.
  $
  Rearranging and dividing by $lambda > 0$ gives $f(vx^*) - f(vx) >= (1 - lambda) / (2 eta) norm(vx - vx^*)^2$. Letting $lambda -> 0$ proves the claim.
]

#proof[of @lem-rvu-stability for Predictive FTRL][
  Let $bold(G)^((t)) := sum_(tau=1)^t vg^((tau))$, with $bold(G)^((0)) := 0$, and let
  $
    F_t (vx) := ip(bold(G)^((t)), vx) - 1 / eta psi(vx).
  $
  Then $vz^((t)) in argmax F_(t-1)$ and $vx^((t)) in argmax {F_(t-1) + ip(vm^((t)), dot.c)}$, where the second objective is the function $vx |-> F_(t-1)(vx) + ip(vm^((t)), vx)$. Both objectives are a linear function minus $1/eta psi$. A linear function satisfies the convexity inequality with equality, so it adds no curvature, while $-1/eta psi$ is $(1\/eta)$-strongly concave because $psi$ is $1$-strongly convex. Hence both objectives are $(1\/eta)$-strongly concave; equivalently, $-eta$ times each objective is $psi$ plus a linear function, which is $1$-strongly convex. In particular, the prediction $vm^((t))$ enters only through a linear term and does not affect the strong concavity. Fix $t$. Apply @lem-rvu-strong-concavity twice:
  - to the objective of $vx^((t))$, at the point $vz^((t+1))$:
    $
      F_(t-1)(vz^((t+1))) + ip(vm^((t)), vz^((t+1))) <= F_(t-1)(vx^((t))) + ip(vm^((t)), vx^((t))) - 1 / (2 eta) norm(vx^((t)) - vz^((t+1)))^2;
    $
  - to $F_(t-1)$, at the point $vx^((t))$:
    $
      F_(t-1)(vx^((t))) <= F_(t-1)(vz^((t))) - 1 / (2 eta) norm(vx^((t)) - vz^((t)))^2.
    $
  Adding the two inequalities and substituting $F_(t-1)(vz^((t+1))) = F_t (vz^((t+1))) - ip(vg^((t)), vz^((t+1)))$,
  $
    F_t (vz^((t+1))) - F_(t-1)(vz^((t))) <= & ip(vg^((t)), vz^((t+1))) - ip(vm^((t)), vz^((t+1)) - vx^((t))) \
                                            & - 1 / (2 eta) (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  To bring out $S_t = ip(vm^((t)), vz^((t+1)) - vx^((t))) + ip(vg^((t)), xhat - vz^((t+1)))$, move the two inner products to the left-hand side, the difference of $F$'s to the right-hand side, and add $ip(vg^((t)), xhat)$ to both sides:
  $
    S_t <= & ip(vg^((t)), xhat) - (F_t (vz^((t+1))) - F_(t-1)(vz^((t)))) \
           & - 1 / (2 eta) (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  Summing over $t = 1, ..., T$, the inner products add up to $ip(bold(G)^((T)), xhat)$, and the differences of $F$'s telescope:
  $
    sum_(t=1)^T S_t <= ip(bold(G)^((T)), xhat) - F_T (vz^((T+1))) + F_0(vz^((1))) - 1 / (2 eta) sum_(t=1)^T (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  It remains to bound the first three terms. Since $vz^((T+1))$ maximizes $F_T$, we have $F_T (vz^((T+1))) >= F_T (xhat) = ip(bold(G)^((T)), xhat) - 1/eta psi(xhat)$; moreover, $F_0(vz^((1))) = -1/eta psi(vz^((1)))$ since $bold(G)^((0)) = 0$. Therefore
  $
    ip(bold(G)^((T)), xhat) - F_T (vz^((T+1))) + F_0(vz^((1))) <= 1 / eta psi(xhat) - 1 / eta psi(vz^((1))) = (psi(xhat) - psi(vz^((1)))) / eta.
  $
  Since $vz^((1)) = vx^((1))$, this is the bound of @lem-rvu-stability.
]

#remark[
  The proof of the same inequality in #citep(<syrgkanis2015fast>, [Appendix C]) proceeds by induction on $T$; the telescoping argument above is the same calculation written as a sum. With an additional stability property of FTRL, namely $norm(vx^((t)) - vz^((t+1))) <= eta norm(vg^((t)) - vm^((t)))_*$, the same reference also improves the constant $1\/(8 eta)$ in the RVU bound to $1\/(4 eta)$ for Predictive FTRL. We do not need this refinement here.
]

= Proof for non-reflected Predictive OMD <sec-rvu-omd>

For OMD we additionally assume, as in the #lecture-link("learning1", <ftrl-omd-general-case>)[general case of FTRL and OMD], that $psi$ is differentiable at the points where Bregman divergences are evaluated, since the gradient $nabla psi$ appears in their definition. The role of @lem-rvu-strong-concavity is played by the three-point inequality for Bregman projections. Its proof relies on the following first-order characterization of maximizers over a convex set.

#lemma[First-order optimality][
  Let $f : cX -> RR$ be differentiable at $vx^* in argmax_(vx in cX) f(vx)$. Then
  $
    ip(nabla f(vx^*), vu - vx^*) <= 0 qquad forall vu in cX.
  $
  Equivalently, if $vx^* in argmin_(vx in cX) f(vx)$, then $ip(nabla f(vx^*), vu - vx^*) >= 0$ for all $vu in cX$.
] <lem-rvu-first-order>
#proof[
  Fix $vu in cX$. For every $lambda in (0, 1]$, the point $vx^* + lambda (vu - vx^*)$ lies on the segment between $vx^*$ and $vu$, so it belongs to $cX$ by convexity. Since $vx^*$ is a maximizer,
  $
    (f(vx^* + lambda (vu - vx^*)) - f(vx^*)) / lambda <= 0.
  $
  As $lambda -> 0^+$, the left-hand side converges to the directional derivative of $f$ at $vx^*$ in the direction $vu - vx^*$, which equals $ip(nabla f(vx^*), vu - vx^*)$. The limit of nonpositive numbers is nonpositive, proving the claim. The statement for minimizers follows by applying it to $-f$.
]

Geometrically, @lem-rvu-first-order says that at a maximizer, no direction pointing into $cX$ makes an acute angle with the gradient. When $vx^*$ is an interior point, all directions are allowed, and the condition reduces to the familiar $nabla f(vx^*) = 0$.

The same limiting argument shows that Bregman divergences dominate squared distances. This is how strong convexity turns divergences into the squared norms of @lem-rvu-stability.

#lemma[
  For all $vx in cX$ and all $vx' in cX$ at which $psi$ is differentiable,
  $
    div(vx, vx', dgf: psi) >= 1 / 2 norm(vx - vx')^2.
  $
  In particular, $div(vx, vx', dgf: psi) >= 0$, with equality only if $vx = vx'$.
] <lem-rvu-bregman-norm>
#proof[
  Apply the strong convexity inequality of @sec-rvu-ftrl to the points $vx$ and $vx'$, writing $lambda vx + (1 - lambda) vx' = vx' + lambda (vx - vx')$. Subtracting $psi(vx')$ from both sides and dividing by $lambda in (0, 1]$,
  $
    (psi(vx' + lambda (vx - vx')) - psi(vx')) / lambda <= psi(vx) - psi(vx') - (1 - lambda) / 2 norm(vx - vx')^2.
  $
  As $lambda -> 0^+$, the left-hand side converges to $ip(nabla psi(vx'), vx - vx')$. Rearranging the limit gives $psi(vx) - psi(vx') - ip(nabla psi(vx'), vx - vx') >= 1/2 norm(vx - vx')^2$, and the left-hand side is $div(vx, vx', dgf: psi)$ by definition.
]

#lemma[
  Let $vy in cX$, $va$ be a vector, and $vx^* := argmax_(vx in cX) {ip(va, vx) - 1/eta div(vx, vy, dgf: psi)}$. Then
  $
    ip(va, vu - vx^*) <= 1 / eta (div(vu, vy, dgf: psi) - div(vu, vx^*, dgf: psi) - div(vx^*, vy, dgf: psi)) qquad forall vu in cX.
  $
] <lem-rvu-three-point>
#proof[
  _Step 1 (gradient of the objective)._ Let $f(vx) := ip(va, vx) - 1/eta div(vx, vy, dgf: psi)$ denote the objective. Since $vy$ is fixed, expanding the Bregman divergence shows that, as a function of $vx$,
  $
    div(vx, vy, dgf: psi) = psi(vx) - ip(nabla psi(vy), vx) + underbrace((-psi(vy) + ip(nabla psi(vy), vy)), "constant in" vx).
  $
  The gradient of $vx |-> ip(vc, vx)$ is $vc$ for any fixed vector $vc$, and constants have zero gradient. Therefore
  $
    nabla_vx div(vx, vy, dgf: psi) = nabla psi(vx) - nabla psi(vy), qquad nabla f(vx^*) = va - 1 / eta (nabla psi(vx^*) - nabla psi(vy)).
  $

  _Step 2 (first-order optimality)._ Applying @lem-rvu-first-order to $f$ at its maximizer $vx^*$ gives, for all $vu in cX$,
  $
    ip(va - 1 / eta (nabla psi(vx^*) - nabla psi(vy)), vu - vx^*) <= 0.
  $
  The inner product is linear in its first argument, so this splits into $ip(va, vu - vx^*) - 1/eta ip(nabla psi(vx^*) - nabla psi(vy), vu - vx^*) <= 0$, that is,
  #set math.equation(numbering: "(1)")
  $
    ip(va, vu - vx^*) <= 1 / eta ip(nabla psi(vx^*) - nabla psi(vy), vu - vx^*) qquad forall vu in cX.
  $ <eq-rvu-omd-first-order>
  #set math.equation(numbering: none)

  _Step 3 (three-point identity)._ It remains to rewrite the right-hand side of (@eq-rvu-omd-first-order) in terms of divergences. By definition,
  $
           div(vu, vy, dgf: psi) & = psi(vu) - psi(vy) - ip(nabla psi(vy), vu - vy), \
         div(vu, vx^*, dgf: psi) & = psi(vu) - psi(vx^*) - ip(nabla psi(vx^*), vu - vx^*), \
         div(vx^*, vy, dgf: psi) & = psi(vx^*) - psi(vy) - ip(nabla psi(vy), vx^* - vy).
  $
  Subtracting the second and third lines from the first, the terms $psi(vu)$, $psi(vx^*)$, and $psi(vy)$ cancel, leaving
  $
    & div(vu, vy, dgf: psi) - div(vu, vx^*, dgf: psi) - div(vx^*, vy, dgf: psi) \
    & quad = -ip(nabla psi(vy), vu - vy) + ip(nabla psi(vx^*), vu - vx^*) + ip(nabla psi(vy), vx^* - vy) \
    & quad = ip(nabla psi(vx^*), vu - vx^*) - ip(nabla psi(vy), (vu - vy) - (vx^* - vy)) \
    & quad = ip(nabla psi(vx^*) - nabla psi(vy), vu - vx^*).
  $
  This is the _three-point identity_. Substituting it into the right-hand side of (@eq-rvu-omd-first-order) proves the lemma.
]

#proof[of @lem-rvu-stability for non-reflected Predictive OMD][
  Fix $t$. Apply @lem-rvu-three-point twice, both times with $vy = vz^((t))$:
  - to the update of $vx^((t))$ (with $va = vm^((t))$), at the point $vu = vz^((t+1))$:
    $
      ip(vm^((t)), vz^((t+1)) - vx^((t))) <= 1 / eta (div(vz^((t+1)), vz^((t)), dgf: psi) - div(vz^((t+1)), vx^((t)), dgf: psi) - div(vx^((t)), vz^((t)), dgf: psi));
    $
  - to the update of $vz^((t+1))$ (with $va = vg^((t))$), at the point $vu = xhat$:
    $
      ip(vg^((t)), xhat - vz^((t+1))) <= 1 / eta (div(xhat, vz^((t)), dgf: psi) - div(xhat, vz^((t+1)), dgf: psi) - div(vz^((t+1)), vz^((t)), dgf: psi)).
    $
  Adding the two inequalities, the terms $div(vz^((t+1)), vz^((t)), dgf: psi)$ cancel. We bound the two remaining negative divergences with @lem-rvu-bregman-norm:
  $
    S_t <= & 1 / eta (div(xhat, vz^((t)), dgf: psi) - div(xhat, vz^((t+1)), dgf: psi)) \
           & - 1 / (2 eta) (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  Summing over $t$, the divergences to $xhat$ telescope. Dropping $-div(xhat, vz^((T+1)), dgf: psi) <= 0$,
  $
    sum_(t=1)^T S_t <= 1 / eta div(xhat, vz^((1)), dgf: psi) - 1 / (2 eta) sum_(t=1)^T (norm(vx^((t)) - vz^((t+1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  Finally, since $vz^((1))$ minimizes $psi$ over $cX$, @lem-rvu-first-order (in its form for minimizers, with $f = psi$ and $vu = xhat$) gives $ip(nabla psi(vz^((1))), xhat - vz^((1))) >= 0$, and hence
  #set math.equation(numbering: "(1)")
  $
    div(xhat, vz^((1)), dgf: psi) = psi(xhat) - psi(vz^((1))) - ip(nabla psi(vz^((1))), xhat - vz^((1))) <= psi(xhat) - psi(vz^((1))).
  $ <eq-rvu-omd-initial>
  #set math.equation(numbering: none)
  Since $vz^((1)) = vx^((1))$, this is the bound of @lem-rvu-stability.
]

= From the intermediate bound to the RVU bound <sec-rvu-final>

We now prove the main result, @thm-rvu, stated at the beginning of these notes. Recall that it asserts
$
  "Reg"^((T)) <= max_(xhat in cX) (psi(xhat) - psi(vx^((1)))) / eta + eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_*^2 - 1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2.
$
The proof uses only @thm-rvu-intermediate, so it applies to both algorithms at once.

#proof[of @thm-rvu][
  Fix $xhat in cX$ and start from @thm-rvu-intermediate.

  _Step 1 (Young's inequality)._ By the inequality $a b <= eta a^2 + b^2 \/ (4 eta)$,
  $
    norm(vg^((t)) - vm^((t)))_* norm(vx^((t)) - vz^((t+1))) <= eta norm(vg^((t)) - vm^((t)))_*^2 + 1 / (4 eta) norm(vx^((t)) - vz^((t+1)))^2.
  $
  The last term cancels half of the corresponding negative term in @thm-rvu-intermediate, leaving
  $
    "Reg"^((T))(xhat) <= & (psi(xhat) - psi(vx^((1)))) / eta + eta sum_(t=1)^T norm(vg^((t)) - vm^((t)))_*^2 \
                         & - 1 / (4 eta) sum_(t=1)^T norm(vx^((t)) - vz^((t+1)))^2 - 1 / (2 eta) sum_(t=1)^T norm(vx^((t)) - vz^((t)))^2.
  $

  _Step 2 (from auxiliary distances to movement)._ Shift the index of the first sum, drop its $t = T + 1$ term and the $t = 1$ term of the second, and use $1\/(2 eta) >= 1\/(4 eta)$:
  $
    & 1 / (4 eta) sum_(t=1)^T norm(vx^((t)) - vz^((t+1)))^2 + 1 / (2 eta) sum_(t=1)^T norm(vx^((t)) - vz^((t)))^2 \
    & quad >= 1 / (4 eta) sum_(t=2)^T (norm(vz^((t)) - vx^((t-1)))^2 + norm(vx^((t)) - vz^((t)))^2).
  $
  Writing $vx^((t)) - vx^((t-1)) = (vx^((t)) - vz^((t))) + (vz^((t)) - vx^((t-1)))$ and using $norm(va + vb)^2 <= 2 norm(va)^2 + 2 norm(vb)^2$,
  $
    norm(vx^((t)) - vx^((t-1)))^2 <= 2 norm(vx^((t)) - vz^((t)))^2 + 2 norm(vz^((t)) - vx^((t-1)))^2,
  $
  so the right-hand side above is at least $1 / (8 eta) sum_(t=2)^T norm(vx^((t)) - vx^((t-1)))^2$.

  Combining the two steps bounds $"Reg"^((T))(xhat)$ for each $xhat$; maximizing over $xhat in cX$ gives the statement.
]

#paragraph-marker() *Where the prediction choice enters.*~~
Nothing above depends on the choice of $vm^((t))$. Fixing $vm^((t)) := vg^((t-1))$ for $t >= 2$ (#lecture-link("learning2", <sec-optimism>)[optimism]) only changes the middle term: the prediction error $norm(vg^((t)) - vm^((t)))_*$ becomes the variation $norm(vg^((t)) - vg^((t-1)))_*$ of the utilities. The negative movement term comes from strong convexity, and is present whatever the predictions are. This is the form of the bound used for the #lecture-link("learning2", <sec-fast-zero-sum>)[accelerated convergence in two-player zero-sum games].

#remark[
  Setting $vm^((t)) = 0$ for all $t$ recovers the #lecture-link("learning1", <ftrl-omd-regret-bound>)[regret bound for non-predictive FTRL and OMD]: the iterates then satisfy $vx^((t)) = vz^((t))$, and $norm(vg^((t)) - vm^((t)))_* = norm(vg^((t)))_*$.
]

#lec_bibliography("meta/refs.bib")
