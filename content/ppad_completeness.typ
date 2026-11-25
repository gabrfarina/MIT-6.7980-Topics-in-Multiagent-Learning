#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 20,
  date: [Tue, Nov 24, 2026],
  title: "PPAD-hardness of Nash equilibrium",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

#note-status[Lecture note unfinished - work in progress.]

// HTML cell padding and math fonts need more room for labels such as x = 0.
#let payoff-table-columns() = {
  let width = if target() == "html" { 2cm } else { 1.3cm }
  (width, width, width)
}


We continue the discussion from #lecture-link("tfnp", none)[] by giving a glimpse of how the PPAD-hardness of finding $eps$-approximate Nash equilibria was shown by #citet(<dgp09>).

The proof can be broken down into two main steps:
- Reduction from #lecture-link("tfnp", <sec-end-of-line>)[End-of-Line] to (approximate) Brouwer.
- Reduction from (approximate) Brouwer to (approximate) Nash equilibria.

The first step requires a carefully encoded path and interpolation construction; we will not cover it here. The second step is more involved and requires a careful construction of a reduction from Brouwer to Nash equilibria. This is the part we will focus on in this lecture.

The key idea is the following: in the reduction from #smallcaps[End-of-the-line] to Brouwer, we define a continuous function $f$ for which we need to find an approximate fixed point. We now need to construct a game such that every sufficiently accurate approximate Nash equilibrium can be decoded into an approximate fixed point of $f$. The issue is that it is not clear how we can have games "compute" functions. Can we construct games in such a way that their behavior at Nash equilibria can be seen as "computing something"? The answer is positive, as we see next.

= Generalized circuits and approximation <sec-generalized-circuits>

We show that given a function represented as an _arithmetic circuit_, it is possible to construct a game whose Nash equilibria correspond to computing a fixed point of the function. This is the key idea behind the reduction from Brouwer to Nash equilibria.

In particular, we will restrict our attention to functions constructed through circuits that are composed of the following:
- Variable nodes $v_1, ..., v_n$;
- Gate nodes $g_1, ..., g_m$ of six possible types:
  #table(
    columns: (2.65cm, 4cm, 1fr),
    align: (horizon + left, horizon + center, horizon + left),
    inset: (x: 2mm, y: 2.5mm),
    stroke: .2mm,
    table.header[*Gate*][*Symbol*][*Input-output relationship*],
    [Assignment],
    [#image("figures/ppad_completeness/gate_assignment.svg", width: 3cm, alt: "Assignment gate.")],
    [$y = x_1$],

    [Constant], [#image("figures/ppad_completeness/gate_constant.svg", width: 3cm, alt: "Constant gate.")], [$y=a$],
    [Addition],
    [#image("figures/ppad_completeness/gate_addition.svg", width: 3cm, alt: "Addition gate.")],
    [$y=min{1, x_1+x_2}$],

    [Subtraction],
    [#image("figures/ppad_completeness/gate_subtraction.svg", width: 3cm, alt: "Subtraction gate.")],
    [$y=max{0, x_1-x_2}$],

    [Scaling],
    [#image("figures/ppad_completeness/gate_multiplication.svg", width: 3cm, alt: "Multiplication gate.")],
    [$y=max{0,min{1, a dot x_1}}$],

    [Comparison],
    [#image("figures/ppad_completeness/gate_comparison.svg", width: 3cm, alt: "Comparison gate.")],
    [$y=display(
        cases(
          1\, qquad& "if" x_1 > x_2,
          0\, & "if" x_1<x_2, "any"\, & "if" x_1 = x_2.
        )
      )$

      When the inputs are equal, this gate does not restrict the output.
    ],
  )
- Each constant $a$ is rational and lies in $[0,1]$. Scaling multiplies by this constant; multiplication of two variable inputs is not one of the permitted gates.
- Directed edges connecting variables to gates and gates to variables (loops are allowed);
- Variable nodes have in-degree 1; gates have 0, 1, or 2 inputs depending on type as above; gates & nodes have arbitrary fanout.

The table gives ideal gate relations. To state a finite search problem appropriate for approximate Nash, fix a rational tolerance $delta in (0,1/4)$.

#definition[Approximate generalized-circuit problem][
  Find a rational assignment $v_1,...,v_n in [0,1]$ such that each assignment, constant, addition, subtraction, and scaling gate has output within $delta$ of the value in the table. A comparison gate must satisfy
  $ x_1 > x_2+delta ==> y >= 1-delta, quad x_1 < x_2-delta ==> y <= delta. $
  If $|x_1-x_2| <= delta$, any output in $[0,1]$ is allowed. Cyclic wiring is permitted; this is a simultaneous constraint problem, rather than an acyclic circuit evaluation.
]

#example[
  In the diagram below, the exact relations force $a=b=c=1/2$; with positive tolerance, assignments need only satisfy the approximate relations.
  #figure[
    #image(
      "figures/ppad_completeness/circuit.svg",
      width: 6cm,
      alt: "A cyclic arithmetic circuit containing a one-half constant, a comparison gate, and an assignment gate.",
    )
  ]
]

#theorem[Generalized-circuit hardness #citep(<chen2009settling>)][
  Approximate generalized circuits always have a solution. For sufficiently small inverse-polynomial tolerance in the circuit encoding size, finding such a solution is PPAD-complete.
]

#proofsketch[
  Replace each comparison by a continuous ramp: output $0$ when $x_1-x_2 <= -delta/2$, output $1$ when $x_1-x_2 >= delta/2$, and interpolate linearly between. All other gates already give continuous maps into $[0,1]$. Updating every output coordinate defines a continuous self-map of $[0,1]^n$, which has a fixed point by #lecture-link("brouwer", <sec-brouwer-general>)[Brouwer's theorem]. Rounding this fixed point to a sufficiently fine rational grid preserves the displayed $delta$ constraints: the arithmetic gates are Lipschitz, and comparisons have a margin between the ramp's transition and the required thresholds. Polynomially many bits suffice. The PPAD reduction and hardness construction are the substantive additional parts of the cited result.
]

The restriction to rational-constant scaling matters. Allowing arbitrary variable multiplication changes the exact fixed-point problem to an algebraic one; exact multiplayer Nash is associated with FIXP #citep(<etessami2010fixedpoints>). The statement above explicitly concerns approximate solutions.

= From gates to games

It is possible to convert an approximate generalized-circuit instance into an approximate Nash equilibrium computation problem in a _multiplayer game_. (The game can also be
converted into a two-player #citep(<chen2009settling>) or three-player game #citep(<dgp09>), but we do not show how in this lecture).

The idea is to use _gadgets_: constructions that simulate the behavior of the gates in the circuit. We first prove their exact equilibrium behavior to expose the mechanism. A full approximation reduction must also bound the error of each gadget, normalize payoffs, and choose the Nash tolerance as a function of the circuit tolerance.

== Addition gate

Consider any game that contains the following interaction between four players $x, y, z, w$, each of which has two actions, denoted ${0,1}$. With a slight abuse of notation, we will call $x,y,z,w$ the probability of playing action $1$; hence, $x, y, z, w in [0,1].$

#example[Addition gadget game][
  Consider any game that contains as a substructure the gadget shown in the diagram below, and payoffs set as follows.

  #figure(
    caption: [Addition gadget game. The dashed blue edges denote possible edges in the game, which do not affect the result in @thm-gadget-addition.],
  )[
    #image(
      "figures/ppad_completeness/addition_gadget.svg",
      width: 4cm,
      alt: "Addition gadget: input players x and y influence w, and w and the output player z influence each other.",
    )
  ]

  #block(width: 100%, breakable: false)[
    #paragraph-marker(shape: "triangle-right") _Payoffs of player $w$._~ The payoff of player $w$ is defined as follows.
    If $w$ plays $0$, her payoff does not depend on $z$'s strategy, but only on $x$ and $y$, according to the payoff table
    #align(center)[#context table(
      columns: payoff-table-columns(),
      align: center,
      fill: none,
      stroke: .2mm,
      [     ], [$y=0$], [$y=1$],
      [$x=0$], [$0$], [$1$],
      [$x=1$], [$1$], [$2$],
    )]
  ]

  #block(width: 100%, breakable: false)[
    If $w$ plays $1$, her payoff does not depend on $x$ and $y$'s strategy and depends on $z$'s according to the table
    #align(center)[#context table(
      columns: payoff-table-columns(),
      align: center,
      fill: none,
      stroke: .2mm,
      [], [$z=0$], [$z=1$],
      [], [$0$], [$1$],
    )]
  ]

  #block(width: 100%, breakable: false)[
    #paragraph-marker(shape: "triangle-right") _Payoffs of player $z$._~ The payoff of player $z$ is defined according to the table
    #align(center)[#context table(
      columns: payoff-table-columns(),
      align: center,
      fill: none,
      stroke: .2mm,
      [     ], [$z=0$], [$z=1$],
      [$w=0$], [$1\/2$], [$1$],
      [$w=1$], [$1\/2$], [$0$],
    )]
  ]

  #paragraph-marker(shape: "triangle-right") _Other payoffs and considerations_.~~
  The utilities of players $x$ and $y$ are independent of the strategies of $w$ and $z$.
  Player $w$ does not affect other players in the game.
]

#theorem[
  In all Nash equilibria of the game, $z = min{x + y, 1}$.
] <thm-gadget-addition>
#proof[
  Suppose that $z < min{x + y, 1}.$ Then, $z < x + y$. But then $w$ will deterministically play $w=0$, which will force $z$ to play $z=1$. This is a contradiction, since by hypothesis $z < min{x+y,1}$, which implies $z < 1$.

  Suppose now that $z > min{x+y,1}.$ In this case, $min{x+y,1} != 1$, as otherwise this would imply $z > 1$ which is impossible. Thus, $z > x + y.$ This implies $w = 1$ and hence $z = 0$, which is again impossible since $z > x + y$, which implies $z > 0$.

  The only remaining possibility is therefore $z = min{x+y,1},$ as we wanted to show.
]

== Comparison gate

For input players with action-$1$ probabilities $x,y$, give an output player $z$ payoff equal to the input action of $x$ when she plays $1$, and equal to the input action of $y$ when she plays $0$. Her expected payoff difference between the two actions is $x-y$. Therefore, in an exact equilibrium, $z=1$ if $x>y$, $z=0$ if $x<y$, and any mixture is allowed at a tie.

This also illustrates why approximate comparisons need a gap. In an $epsilon.alt$-Nash equilibrium, if $x-y>delta$, then playing action $0$ with probability $1-z$ incurs deviation gain $(1-z)(x-y)$, so $1-z <= epsilon.alt/delta$. Taking $epsilon.alt <= delta^2$ enforces $z >= 1-delta$. The case $y-x>delta$ is symmetric.

These local arguments explain the gate simulation. They do not by themselves prove the full hardness theorem: composing all gadgets while preserving their incentives, controlling approximation errors, and converting the graphical construction to a fixed number of players require the remaining reductions in the cited papers.

= Other existence arguments and the classes PPA, PPP, and PLS <sec-other-total-classes>

Some search problems always have a solution because a simple mathematical argument guarantees one, even though the argument does not say how to find it quickly. Total search problems can be grouped according to which argument provides this guarantee. We have already met one such group. Recall from #lecture-link("tfnp", <sec-ppad>)[] that PPAD is the class of total search problems that reduce to #lecture-link("tfnp", <sec-end-of-line>)[End-of-Line], where the guarantee is that a directed path that has a start also has an end.

Three other classes arise in the same way from three other arguments. Each class in the table below can be described as the total search problems that reduce to one _defining problem_, in which Boolean circuits on #box[$n$-bit] strings describe an exponentially large object.

// Narrow cells read better ragged-right and without hyphenation. Keep the table on one page.
#block(breakable: false)[
  #set par(justify: false)
  #set text(hyphenate: false)
  #table(
    columns: (3.5cm, 1fr, 1.3fr),
    align: (horizon + left, horizon + left, horizon + left),
    inset: (x: 2mm, y: 2.5mm),
    stroke: .2mm,
    table.header[*Class*][*Existence argument*][*Defining problem*],
    [PPA \ Polynomial Parity Argument #citep(<papadimitriou1994parity>)],
    [In an undirected graph, the number of vertices with an odd number of edges is even. In particular, a path that has one end has another end.],
    [A circuit describes a graph on the #box[$n$-bit] strings in which every vertex has at most two edges and vertex $0$ has exactly one. Find another vertex with exactly one edge.],

    [PPP \ Polynomial Pigeonhole Principle #citep(<papadimitriou1994parity>)],
    [If there are more pigeons than holes, two pigeons share a hole. So a function from a finite set to itself that never outputs some element gives the same output on two different inputs.],
    [A circuit maps #box[$n$-bit] strings to #box[$n$-bit] strings. Find an input that is mapped to the all-zero string, or two different inputs with the same output.],

    [PLS \ Polynomial Local Search #citep(<JohnsonPY88:LocalSearch>)],
    [Costs cannot decrease forever. So a cost function on a finite set has a local optimum, a point that no allowed move makes cheaper.],
    [One circuit proposes a neighbor $S(v)$ of every point $v$ and another computes an integer cost $V(v)$. Find a point $v$ with $V(S(v)) >= V(v)$.],
  )
]

#paragraph-marker() *Reading the table.*~~ The PPA problem is End-of-Line without the directions. In the PPP problem, if no input is mapped to the all-zero string, then $2^n$ inputs share only $2^n - 1$ outputs, so two of them collide. In the PLS problem, the only allowed move from a point $v$ is to $S(v)$, so a point with $V(S(v)) >= V(v)$ is a local optimum. In all three problems a solution is guaranteed to exist but is hard to find, because the object described by the circuits has $2^n$ elements and the obvious search, along the path or through cheaper neighbors, can take exponentially many steps. In short, PPA, PPP, and PLS each collect the problems whose solutions exist for one and the same reason, which is parity for PPA, the pigeonhole principle for PPP, and local improvement for PLS.

#paragraph-marker() *Examples of complete problems.*~~ Recall that a problem is complete for a class if it belongs to the class and every problem of the class reduces to it, so a fast algorithm for a complete problem would give a fast algorithm for the whole class. Approximate Nash equilibrium plays this role for PPAD. Each of the other classes has natural complete problems as well.
- _PPA._ Approximate consensus halving #citep(<FilosRatsikasG18:ConsensusHalving>). Picture an interval as a long cake with different toppings along its length, and $n$ agents who each care about different toppings. The task is to cut the cake in at most $n$ places and to sort the resulting pieces into two piles so that every agent, judging by their own taste, finds the two piles almost equally valuable. For a single agent one cut is enough, placed where the part to its left is worth exactly half to that agent. For several agents the same few cuts must balance everyone at once. A suitable division always exists, and the proof rests on a parity argument, which is why the problem belongs to PPA.
- _PPP._ A constrained version of the short integer solution problem #citep(<SotirakiZZ18:PPP>). In the basic problem we are given a system of linear equations modulo an integer with many more unknowns than equations, and we look for a nonzero solution whose entries are small integers. Here the pigeons are the vectors with entries $0$ or $1$, and the holes are the possible values of the equations. There are more pigeons than holes, so two such vectors give the same values, and their difference is a solution with entries $-1$, $0$, or $1$.
- _PLS._ Finding a pure Nash equilibrium of a congestion game #citep(<FabrikantPT04:PureNash>). Picture drivers who each choose a route made of roads, where a road becomes slower as more drivers use it. In general, a congestion game lets every player choose a set of resources, and the cost of a resource depends only on the number of players that use it. A pure Nash equilibrium is a choice of routes, made without randomizing, in which no driver can shorten their own trip by switching alone. One always exists, because every switch that helps a driver also lowers a common potential function, so drivers who switch one at a time must eventually stop.

#paragraph-marker() *Inclusions.*~~ @fig-total-search-classes shows the known inclusions. Every class contains FP, the total search problems solvable in polynomial time, and is contained in TFNP. PPAD is contained in both PPA and PPP #citep(<papadimitriou1994parity>), and no other inclusion among the four classes is known. Proving that any two of them differ would imply $"P" != "NP"$.

#figure(
  caption: [Known inclusions among the total-search classes of this section. An arrow points from a class to a class that contains it. No inclusion is known to be strict.],
)[
  #image(
    "figures/ppad_completeness/total_search_classes.svg",
    width: 5.2cm,
    alt: "Inclusion diagram in which FP is contained in PPAD and in PLS, PPAD is contained in PPA and in PPP, and each of PPA, PPP, and PLS is contained in TFNP.",
  )
] <fig-total-search-classes>

#lec_bibliography("meta/refs.bib")
