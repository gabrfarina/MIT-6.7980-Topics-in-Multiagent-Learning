#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  instructor: [Guest Lecturer: Weiqiang Zheng],
  lec_num: 17,
  title: "Nonconcave games",
)

= Gradient descent minimizes proximal regret <sec-gd-proximal>

Now that we gave the definition of proximal regret and showed that it covers a wide range of regret notions, we show that gradient descent minimizes proximal regret. In particular, we will show the bound for any proper, lower semicontinuous function $f$.

We make the following assumptions.
- *Strategy set.* $cX subset.eq RR^d$ is nonempty, convex, and compact, with diameter at most $D$:
  $ norm(vx - vy) <= D quad forall vx, vy in cX. $
- *Losses.* At each time $t$, the loss $ell^((t)): cX -> RR$ is convex and differentiable, with gradients bounded by $G$:
  $ norm(nabla ell^((t))(vx)) <= G quad forall vx in cX, t = 1, ..., T. $


The algorithm is projected gradient descent with step size $eta > 0$:
$ vx^((t+1)) := Pi_cX (vx^((t)) - eta nabla ell^((t))(vx^((t)))), $
where $Pi_cX$ denotes the Euclidean projection onto $cX$.

#theorem[#citet(<cai2026proximal>)][
  Under the assumptions above, for every proper, lower semicontinuous function $f$, the proximal regret of projected gradient descent with step size $eta$ satisfies
  $ "Reg"_f^((T)) <= D^2 / (2 eta) + eta / 2 G^2 T. $
  In particular, choosing $eta = D \/ (G sqrt(T))$ gives
  $ "Reg"_f^((T)) <= D G sqrt(T) quad "for all" f "simultaneously". $
] <thm-gd-proximal>


#remark[
  If we know the time horizon $T$, we can choose $eta$ to optimize the bound. 
  $ D^2/(2 eta) + eta/2 G^2 T = (D/sqrt(2 eta) - G sqrt((eta T)/2))^2 + D G sqrt(T) >= D G sqrt(T), quad "with equality iff" eta = D/(G sqrt(T)). $
  
  If we do not know $T$, we can use a doubling trick to achieve the same bound up to constant factors.
]

#lec_bibliography("meta/refs.bib")
