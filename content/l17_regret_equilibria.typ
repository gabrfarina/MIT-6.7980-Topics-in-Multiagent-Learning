#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games",
  instructor: [Weiqiang Zheng],
)

// Standalone Task 5 contribution; place after the local-equilibria section.
= From local equilibria to $Phi$-regret minimization <sec-l17-regret-equilibria>

Having reduced the computation of local equilibria to controlling linearized deviation gains, we are interested in which families of transformations $Phi$ admit efficient learning in online convex optimization.

Recall from #lecture-link("learning_intro")[] that minimizing $Phi$-regret allows us to compute $Phi$-equilibria. Richer families of transformations yield stronger equilibrium guarantees, but may come at a greater computational cost. Let us examine whether three regret minimization algorithms we've covered so far can reconcile these two objectives.

#paragraph-marker() *Setting.*~~
Consider a convex and compact strategy set $X subset.eq RR^d$ of diameter $D$. At each time $t$, the learner plays a strategy $x^((t)) in X$ and observes a differentiable convex loss function $ell^((t)): X -> RR$, with bounded gradients $norm(nabla ell^((t))(x)) <= G$ for all $x in X$.

We work with losses to be minimized rather than utilities to be maximized. Setting $ell^((t)) = -u^((t))$, the cumulative $Phi$-regret is
$ Phi"-Reg"^((T)) := sum_(t=1)^T ell^((t))(x^((t))) - min_(phi.alt in Phi) sum_(t=1)^T ell^((t))(phi.alt(x^((t)))). $

The goal is to guarantee sublinear regret, so that the average regret $(Phi"-Reg"^((T))) / T$ vanishes as $T -> infinity$. By #lecture-link("learning_intro", <thmce-formal>)[the regret-to-equilibrium theorem], average regret controls the equilibrium approximation error, making the rate of regret minimization particularly important.

#paragraph-marker() *External regret.*~~
Let $Phi$ consist of all constant transformations $phi.alt(x) = a$, where $a in X$. Minimizing external regret leads to coarse correlated equilibria (CCE), since players cannot benefit from switching to a fixed alternative strategy independently of their recommendation.

#block(breakable: false)[
An important algorithm for minimizing external regret in online convex optimization is projected gradient descent (GD). Recall that the update rule
$ x^((t+1)) = op("proj")_X [x^((t)) - eta nabla ell^((t))(x^((t)))], $
guarantees $O(sqrt(T))$ regret with a suitable step size, as established in #lecture-link("learning1", <sec-ogd>)[the projected gradient regret bound]. The update can be implemented efficiently when projection onto $X$ is efficient.
]

#paragraph-marker() *Swap regret.*~~
At the other extreme, let $Phi$ consist of all transformations $phi.alt: X -> X$. Minimizing swap regret leads to correlated equilibria (CE), since players cannot benefit from deviations that depend arbitrarily on their recommended strategy.

To minimize this richer notion of regret, the #lecture-link("phi_regret", <sec-treeswap>)[TreeSwap reduction] and related work #citep(<dagan2024external>)#citep(<peng2023fast>) achieve a schematic regret rate of order $T / (log T)$ using distributional play. Under this bound, exponentially many rounds in $1 / epsilon$ suffice to achieve $epsilon$-average regret. Furthermore, Daskalakis et al. #citep(<daskalakis2024lower>) rule out a general guarantee polynomial in both the game-tree size and $1 / epsilon$ for swap regret in extensive-form games.

#paragraph-marker() *Linear swap regret.*~~
To recover faster convergence while retaining more expressive deviations than external regret, we can restrict $Phi$ to affine transformations $phi.alt(x) = A x + b$ mapping $X$ into itself. This gives rise to linear correlated equilibrium, an intermediate solution concept between CCE and CE.

Daskalakis et al. #citep(<daskalakis2025linear>) show that $O(sqrt(T))$ regret is achievable for this family of transformations, although their algorithm requires the ellipsoid method as a subroutine, with suitable oracle access to $X$. This subroutine handles optimization over transformations, making the algorithm more involved than a single projected gradient update.

// Web: collapsible explorer. PDF: static chart.
#context if target() == "html" {
  html.elem("details", {
    html.elem("summary", attrs: (style: "cursor: pointer; padding: 0.75em 0;"))[Illustrative example]
    [Play with the toggles to compare the three deviation families.]
    // The explorer stacks below 560px, so its frame needs more height there.
    html.elem("style", ".deviation-frame{container-type:inline-size}.deviation-frame iframe{display:block;width:100%;height:370px;border:0}@container (max-width:559px){.deviation-frame iframe{height:600px}}")
    html.elem("div", attrs: (class: "deviation-frame"), html.elem("iframe", attrs: (
      src: "interactive/deviation_families.html",
      title: "Deviation families",
      loading: "lazy",
    )))
  })
} else {
  figure(
    image("figures/l17_regret_equilibria/deviation_families.svg", width: 100%,
      alt: "Three maps on identical unit-square axes: the constant map 0.65, the affine map 0.2 + 0.6x, and the nonlinear example x squared."),
    caption: [The graphs above show one example from each deviation family. Dots mark $x = 0.2, 0.5, 0.8$.],
  )
}

#figure(
  {
    set text(size: 9pt)
    set par(justify: false)
    table(
      columns: (0.9fr, 1.2fr, 0.9fr, 1fr, 1.15fr),
      align: (left, center, center, center, center),
      inset: 5pt,
      stroke: 0.4pt + luma(180),
      table.header([*Regret notion*], [*Transformations* $phi.alt(x)$], [*Equilibrium*], [*Cumulative regret*], [*Algorithm*]),
      [External], [Constant $a$], [CCE], [$O(sqrt(T))$], [Gradient descent],
      [Linear swap], [Affine $A x + b$], [Linear CE], [$O(sqrt(T))$], [Ellipsoid-based],
      [Swap], [Arbitrary], [CE], [$O(T / (log T))$], [TreeSwap],
    )
  },
  kind: table,
  caption: [The table above compares the three regret notions across transformations, equilibrium, cumulative regret, and algorithm.],
) <tab-l17-regret-comparison>

External regret admits a simple and efficient algorithm, but restricts the player to constant deviations. Richer deviation families come at the expense of either convergence speed, as in swap regret, or algorithmic simplicity, as in linear swap regret.

This motivates the search for a useful middle ground: a richer family of transformations than constant deviations for which gradient descent retains its $O(sqrt(T))$ regret guarantee.

// When assembling Lecture 17, retain a single bibliography at its end.
#block(breakable: false)[
= Bibliography
#lec_bibliography("meta/refs.bib", title: none)
]

#changelog[
  - 2026-11-25: Diego de Lope contributed the recap of regret minimization and equilibrium computation.]
