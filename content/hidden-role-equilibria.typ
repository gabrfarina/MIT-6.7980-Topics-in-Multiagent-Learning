#let custom-thm(
  title: "Theorem",
  number: none,        // e.g., "1.2", "A", or none for unnumbered
  name: none,          // e.g., "Pythagoras"
  color: blue,         // accent color for border & header
  fill: black,
  body,
) = block(
  fill: color.lighten(90%),
  stroke: (left: 3pt + color),
  inset: (left: 1em, rest: 0.8em),
  radius: 4pt,
  width: 100%,
  {
    // Build the header line
    let header = {
      set text(weight: "bold", fill: color.darken(20%))
      title
      if number != none {
        [ ]
        number
      }
      if name != none {
        [ (]
        name
        [)]
      }
      [.]
    }
    header
    v(0.2em)
    body
  }
)
#let star = $""^ast$
#let val(a, cmp, b, c, marked: false) = box[$#a #h(0.14em) #sym.slash #h(0.14em) #b #cmp #c #h(0.05em) #(if marked { star })$]
= 12.X Computation of Hidden-Role Equilibria
== 12.X.1 Results Overview

Given three reasonable and common assumptions, it becomes possible to compute hidden-role equilibria efficiently! The criteria are:

+ *Private communication* between any pair of players, which can be implemented e.g. by public-key encryption (still viable as of Nov. 2026)
+ "Bad" team is a *minority* (reasonable in many games where e.g. majority voting is involved)
+ "Bad" team can *coordinate* (i.e. know each other's identities, can share randomness, etc.)

Assuming no collapse of computational complexity classes, private communication and coordination are both necessary for efficient computation. Whether "Bad" team minority is required is still open. As found in #cite(<Carminati2023HRG>), here is a table of the state of the art knowledge of computational complexity in hidden-role equilibria:
#figure(
table(
  columns: 4,
  stroke: 0.5pt,
  align: center + horizon,

  // Header
  [*Adversary Team Assumptions*],
  table.cell(colspan: 3)[*Communication Type*],

  [],
  [*None*],
  [*Public*],
  [*Private*],

  // Coordinated rows
  [*Coordinated, Minority*],
  table.cell(rowspan: 2)[NP-complete],
  table.cell(rowspan: 2)[NP-hard],
  [P],

  [*Coordinated*],
  [_open_],

  // Uncoordinated rows
  [*Minority*],
  table.cell(rowspan: 2)[$Sigma_2^P$-complete],
  table.cell(rowspan: 2)[$Sigma_2^P$-hard],
  table.cell(rowspan: 2)[coNP-hard],

  [*None*],
),
caption: [
    Complexity results for computing hidden-role value with a constant number of players, for various assumptions about the adversary team and notions of communication.
  ]
)

Let us now sketch a proof of this theorem, more directly stated as follows:
#custom-thm(
  title: "Theorem",
  number: "12.Y",
  name: "Efficient Hidden-Role Equilibria",
)[
  Consider a hidden-role game $Gamma$ with $n$ players, $k$ of which are on the bad team. All players can communicate pairwise privately and all the bad players can be coordinated as if they were a single player. If $k < n\/2$, then there exists a poly-time $epsilon$-approximation of the hidden-role equilibrium for the good players.
]

== 12.X.2 Proof Sketch using a Mediated-Hidden-Role Game

We introduce a slight variant of the hidden-role game which introduces a *mediator* player on the "Good" team. This player is known to be good but does not know the "goodness" of the players in the game, and all players are free to interface with this player with the same private bidirectional communications as between normal players. Clearly this game $Gamma'$ is strictly better for the "Good" team and thus has an equilibrium value at least that of $Gamma$; the challenge will be to prove that this game $Gamma'$ has an efficiently computable equilibrium strategy that is actually also playable in $Gamma$, which ultimately proves that it is a hidden-role equilibrium strategy for $Gamma$ as well.

In other words, there remain three more pieces to this proof that we will provide high-level sketches for:

+ A description of the mediator-good player interface to reduce to a two-player zero-sum game
+ Explaining why this mediator interface isn't exploitable (i.e. the equilibrium value of the zero-sum game is at least that of the mediated hidden-role game)
+ Explaining how to simulate this mediator in the original hidden-role game setting, deriving a hidden-role equilibrium for $Gamma$.

#custom-thm(
  title: "Key Idea",
  number: "1",
  name: "Mediator Interface",
  color: green
)[
  In a mediated hidden-role game, we will have the mediator take on the role of simulating all of the strategies. In other words, the good players and mediator agree on the following scheme:
  + The good players privately communicate all observed info to the mediator
  + The mediator sends out actions to all actors
  + All good players execute actions as issued by the mediator
]

With this interface, only the mediator makes any decisions; the "good" players simply report their observations to the mediator and follow its instructions. In other words, this is our "reduction" of the mediated hidden-role game into a two-player zero-sum game, as all good player strategic decision-making is subsumed into the mediator and all bad player decision-making was coordinated to begin with and thus can also be subsumed into the decisions of one actor. 

An extension: bad players can (and in a sense "should", to be as "confusing" as possible) send observations to the mediator, they just aren't obligated to be truthful. Moreover, they receive actions from the mediator, as the mediator may not know if they are bad. In other words; bad players send potentially misleading info in step 1, receive potentially useful info in step 3.
#custom-thm(
  title: "Key Idea",
  number: "2",
  name: "Mediator optimality",
  color: green
)[
  We can simulate any strategy $x$ in the mediated game with the interface in Key Idea 1(call the simulated strategy $x'$), such that we do at least as good as the worst-case strategy against $x$. Moreover, if $x$ is any hidden-role equilibrium of $Gamma'$, then our simulated strategy $x'$ must also be a hidden-role equilibrium of $Gamma'$.
]

_Proof Sketch._ For any strategy $x$; all observations can be forwarded to the mediator, and then the individual players can just be internally simulated within the mediator, including any communications with one another, and then actions can be issued to the players themselves; this is our strategy $x'$. Now consider any best-response to $x'$, call this $y'$; we can turn $y'$ into a (possibly suboptimal) way of playing against $x$ by filling in the "virtual" interactions in a strategy $y^*$.

In other words, we use $x, y'$ to simulate a  $(x,y^*)$ that is equivalent to $(x', y')$:

For each bad player in $y^*$ simulate your "bad" best-response _actor_ $y'$ and your "good" response _communicator_ $x$. Let the simulated $x$ communicate with the $y'$ info but otherwise act like an $x$(basically act like a "misled" good actor communications wise), but the actions from your $y'$ determine your actual actions from your $y^*$. The communications between $x$ and $y^*$ are the same as the ones internally simulated in the mediator and the actions of $x$ the simulated ones with the same info as $x'$, and similarly the actions of $y^*$ are the same actions simulated in $y'$. This is illustrated much more clearly in the figures below:

#figure(image("figures/mediator-hidden-role/6.7980_L12_P9_F1.pdf", width:100%), caption: [Anatomy of $y'$ best response to $x'$. Note that y' can still essentially "zombify" $x_i$ to potentially send deceptive messages within the mediator simulation.])

#figure(image("figures/mediator-hidden-role/6.7980_L12_P9_F2.pdf", width:100%), caption: [Anatomy of $y^*$ response to $x$. Note that internal functionality is exactly the same as it was in Figure 1, so the distribution over the outcomes in $Gamma$ are the same, so the expected utility is the same as well.])

As the utility from $(x',y')$ is the same as the utility from $(x, y^*)$, if we base $x'$ off of $x_"OPT" $ then we create an $(x',y')$ that is equal to $(x_"OPT" , y^*)$, which is in turn at least as good as $(x_"OPT" , y_"OPT")$, which must be optimal. Hence $(x', y')$ is in this case always an equilibrium. Because $(x', y')$ are also a Nash equilibrium of a two-player zero-sum game, they can be computed efficiently. 

#custom-thm(
  title: "Key Idea",
  number: "3",
  name: "MPC Simulation of mediator behavior",
  color: green
)[
  We can simulate any such mediator strategy using secure multiparty computation.
]

The secure multiparty computation paradigm goes as follows:

Consider some (possibly randomized) function $f:X^n arrow.r X^n$ (where $X$ is some set of possible inputs/outputs to a function, e.g. bitstrings of length at most $m$). We want each player to evaluate their output $in X$, i.e. $f_i (X_1, X_2, dots, X_n)$. Then secure MPC guarantees the following(in a private messaging environment):

+ Each player computes their output correctly with high probability.
+ No group of $< n \/ 2$ players can learn any significant info other than their own outputs.

A similar(and related) cryptographic paradigm is "secret sharing". It looks like the following: a secret $x$ is distributed into $n$ pieces $x_i = "Share"(x,i)$ to $n$ players such that the following to guarantees are satisfied:

+ The secret can be reconstructed from any group of $> n\/2$ people's secret pieces with a function $"Merge"(x_1, x_2, dots, x_n)$ that can accept $< n\/2$ faulty inputs.
+ No group of $< n\/2$ players has can learn any significant info about the secret.

Both of these cryptographic protocols exist, as shown in #cite(<Rabin1989MPCSecret>).

Effectively what happens is this. The mediator strategy is effectively a function $f$ that takes in the infostate $s$ and $n$ inputs from the players $o_i$. Then the mediator outputs a new infostate $s'$ and $n$ actions $a_i$. More formally, if $"Update"$ is the infostate update function, 
$ f(s, o_1, o_2, dots, o_n) = s', a_1, a_2, dots, a_n, $
where $s' = "Update"(s, o_1, o_2, dots, o_n)$. 

Clearly we want this $f$ in the MPC to map $o_i$ to $a_i$, but what to do with $s, s'$? The answer is to break it up with secret sharing, so that the function computed in MPC is actually $ f'((s_1, o_1), (s_2, o_2), dots, (s_n, o_n)) = ((s'_1, a_1), (s'_2, a_2), dots (s'_n, a_n)), $ where $ s'_i = "Share"("Update"("Merge"(s_1, s_2, dots, s_n), a_1, a_2, dots, a_n),i) $ and $ a_i = f_i ("Merge"(s_1,s_2, dots,s_n), o_1,o_2, dots,o_n). $

This $f'$ computed with MPC is correct with high probability and thus has expected utility at least $"OPT"(Gamma') - W/2^lambda $, where $W$ is some constant that rolls in both the worst case utility and the number of times error can accumulate throughout the game itself. Two natural results:

+ Taking $lambda arrow.r infinity$ means that $"OPT"(Gamma) >= "OPT"(Gamma') - epsilon$ for all $epsilon$, which coupled with the fact that $"OPT"(Gamma) >= "OPT"(Gamma')$ means $"OPT"(Gamma) >= "OPT"(Gamma')$. Because a hidden-role equilibrium for $Gamma'$ is computable, so too is a hidden-role equilibrium EV for $Gamma$.
+ Moreover, such a simulated strategy is in fact playable in polynomial time, as long as you're willing to accept error $epsilon$ with extra polynomial terms in $log(1\/epsilon) = lambda + O(1)$.

== 12.X.3 An Application of Efficient Hidden-Role Equilibria

The famous game _Avalon_ becomes solvable with $<7$ players, as the bad team can be treated as if they are coordinated #cite(<Carminati2023HRG>). Using the optimal zero sum game from Key Idea 2 with some (lossless) computational simplification, #cite(<Carminati2023HRG>) calculated optimum values with PCFR+ that are detailed in the table below:

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    stroke: none,
    inset: (x: 0.7em, y: 0.18em),

    // top rule
    table.hline(stroke: 0.6pt),
    [*Variant*], [*5 Players*], [*6 Players*],
    // rule below header
    table.hline(stroke: 0.6pt),

    [No special roles (_Resistance_)],
      val([3], [=], [10], [0.3000], marked: true),
      val([1], [$approx$], [3], [0.3333], marked: true),
    [Merlin],
      val([2], [$approx$], [3], [0.6667], marked: true),
      val([3], [=], [4], [0.7500], marked: true),
    [Merlin & Mordred],
      val([731], [$approx$], [1782], [0.4102]),
      val([6543], [$approx$], [12464], [0.5250]),
    [Merlin & 2 Mordreds],
      val([5], [$approx$], [18], [0.2778]),
      val([99], [$approx$], [340], [0.2912]),
    [Merlin, Mordred, Percival, Morgana],
      val([67], [$approx$], [120], [0.5583]),
      [$—$], // em dash: too large to solve

    // bottom rule
    table.hline(stroke: 0.6pt),
  ),
  caption: [
    Exact equilibrium values for 5- and 6-player _Avalon_. The values marked
    $""^ast$ were also manually derived
    by Christiano #cite(<Christiano2018Avalon>).
  ],
)

This demonstrates the feasibility of this poly-time equilibrium EV finding algorithm on real-world games, as equilibrium EVs for Avalon were previously computationally intractable.

== 12.X.4 AI Acknowledgement
DeepSeek-V4.1-Flash-1017 was used to generate table, theorem box, and figure code. I also asked it for a surface-level proofread.

#bibliography("meta/refs.bib")