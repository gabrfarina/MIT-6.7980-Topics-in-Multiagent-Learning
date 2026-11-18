#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: "S5",
  date: [Fall 2026],
  title: "Sequential irrationality and perfect equilibria",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

As we discussed on multiple occasions, Nash equilibrium strategies encode the idea of playing optimally against the strongest possible opponent. Even when the opponent is only close to optimal (for example, in the poker competitions where the opponent were top professional poker players), playing a Nash equilibrium is often the safe choice, as professional players are very quick at exploiting suboptimal strategies, making opponent modeling risky. However, as we reveal today, not all Nash equilibria are equally strong in extensive-form games when playing against players that might make mistakes.

= Sequential irrationality

Nash equilibrium strategies are only optimized for the strongest possible opponent. Because of that, they are completely indifferent to what happens in parts of the game tree that are reached only if a player makes a mistake.

#example[
  To make the discussion more concrete, consider the _Guess-the-Ace_ game, introduced by~#citet(<Miltersen06:Computing>) and described below. The two panels show the same game tree. In each panel, the thick orange edges mark the actions that one Nash equilibrium prescribes, and a payoff of $(-\$, \$)$ means that Player~$1$ pays \$1000 to Player~$2$.

  #align(center)[
    #image("figures/perfection/guess-the-ace.svg", width: 100.0%)
  ]
] <ex:guess-the-ace>

In Guess-the-Ace, at the start a standard 52-card deck is perfectly shuffled, face down, by a dealer. Then, Player~$1$ can decide whether to immediately end the game, at which point no money is transferred between the players, or offer \$1000 to Player~$2$ if they can correctly guess whether the top card of the shuffled deck is the ace of spades or not. If Player~$2$ guesses correctly, the \$1000 get transferred from Player~$1$ to Player~$2$; if not, no money is transferred. The game tree is summarized in @ex:guess-the-ace.

Clearly, the only Nash equilibrium strategy for Player~$1$ is to quit immediately, or they are guaranteed to _lose_ money. Since Player~$2$ does not get to play, any strategy for Player~$2$ is a Nash equilibrium strategy.

In particular, consider the two strategy profiles highlighted in @ex:guess-the-ace. In both, Player~$1$ quits at both nodes of information set A. The profiles differ only at information set B, which is never reached because Player~$1$ quits: on the left, Player~$2$ would guess that the top card is _not_ the ace of spades (action ‘$not$A$suit.spade.filled$’); on the right, Player~$2$ would guess that it _is_ (action ‘A$suit.spade.filled$’). Because B is never reached, the guess changes neither player's utility, and both profiles are Nash equilibria. In practice, however, the two equilibria differ a great deal. Imagine that Player~$2$ is a bot playing against opponents in the real world, blindly following the Nash equilibrium strategy it has precomputed. Suppose Player~$1$ makes a mistake and offers the \$1000 instead of quitting. The bot that guesses ‘$not$A$suit.spade.filled$’ then wins the \$1000 with probability $51\/52$, an expected gain of more than \$980. The bot that guesses ‘A$suit.spade.filled$’ wins it with probability only $1\/52$, an expected gain of less than \$20.

So, while both strategy profiles in @ex:guess-the-ace are Nash equilibria, only the left one is _“sensible”_.

Formalizing this subtle notion of rationality within the set of Nash equilibria has been a major endeavor for the game-theoretic literature in the 70s and 80s. Today, we say that the equilibrium in @ex:guess-the-ace (Right) is _sequentially irrational_, while the one on the left is _sequentially rational_. At information set B, the top card is the ace of spades with probability $1\/52$ whatever Player~$1$ did; so guessing ‘A$suit.spade.filled$’ is not a best response at B, even though B is never reached at equilibrium. The takeaway lesson is:

#remark[
  Not all Nash equilibria are equally “good” when the agents can make mistakes. Specifically, sequentially-irrational Nash equilibria might leave value on the table, by being incapable of capitalizing on opponents' mistakes.
]

The goal of this lecture is to investigate how one can rule out sequential irrationality and compute a sequentially-rational Nash equilibrium in a two-player zero-sum imperfect-information game.

= Undomination is not the solution
<sec:une>

One might believe that the problem of sequential irrationality is that of picking dominated strategies. So, one might be inclined to look into the problem of finding a Nash equilibrium whose support does not include any (weakly) dominated strategy (the concept is not immediately well defined, but for the purposes of this discussion let's restrict ourselves to Nash equilibria in deterministic strategies).

Unfortunately, domination of strategies is not the root cause of sequential irrationality, and therefore undomination is not its solution. Indeed, as much as undomination _does_ get rid of the undesirable behavior of @ex:guess-the-ace (Right), since action ‘A$suit.spade.filled$’ is strictly dominated by action ‘$not$A$suit.spade.filled$’, it does not prevent sequential irrationality in more complex settings, such as @ex:guess-the-ace-x.

#example[
  #wrapped-figure(
    [
      Undomination does _not_ prevent a player from playing risky actions, hoping for an opponent's mistake. In this example, again due to #citet(<Miltersen06:Computing>), the Guess-the-Ace game is slightly modified in that, when Player~$2$ guesses wrong, Player~$1$ can decide whether they still want to give \$1000 to Player~$2$ out of the kindness of their heart or not. By introducing that possibility, action ‘$not$A$suit.spade.filled$’ is not strictly dominating anymore, because Player~$2$ might still hope that the second gift of \$1000 is given only when the insensible guess ‘A$suit.spade.filled$’ is made.
    ],
    [#image("figures/perfection/guess-the-ace-x.svg", width: 200pt)],
    side: right,
    text-width: 65%,
  )
] <ex:guess-the-ace-x>

= Trembling-hand refinements

The issue of sequential irrationality stems from the fact that some parts of the game tree are unreachable at equilibrium. For those excluded parts of the game tree, any strategy can be picked without affecting the equilibrium.  The idea behind trembling-hand refinements is simple: to avoid sequential irrationality, it forces all players to explore the whole game tree. It does so by forcing the players to _tremble_, that is, by constraining them to play all actions at all decision points with a strictly positive lower bound probability that grows as a function of a hyperparameter $epsilon.alt > 0$. For each $epsilon.alt > 0$, a Nash equilibrium subject to the trembling constraints is found. A trembling-hand refinements is then any limit points of such Nash equilibria as $epsilon.alt -> 0^(+)$.

Different equilibrium notions differ as to how the lower bounds are set as a function of $epsilon.alt$. We will see two, which are the two best known: extensive-form perfect equilibrium and quasi-perfect equilibrium.

== Extensive-form perfect equilibrium (EFPE)
<sec:efpe>

_Extensive-form perfect equilibrium (EFPE)_, due to #citet(<Selten75:Reexamination>), is conceptually the simplest of the two. In an EFPE, the trembles are #lecture-link("efg_intro", <sec-behavioral-form>)[_behavioral_]: given $epsilon.alt > 0$, the perturbed game simply mandates that every action at every decision point must be picked with probability at least $epsilon.alt$.

Since our game solving formalism is based around the #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form representation of strategies], it is important to check that those behavioral trembling constraints can be expressed in the sequence form. That is the case: asking that action $a$ at decision point $j$ of Player~$1$ be selected with probability at least $epsilon.alt$ corresponds to the sequence-form constraint

#math.equation(
  block: true,
  numbering: "(1)",
  $x_(j a) >= cases(delim: "{", epsilon.alt & upright("if ") p_j = ∅, epsilon.alt dot.op x_(p_j) & upright("otherwise") .)$.body,
)#label("eq:efpe constraint")

Collecting all sequence-form trembling constraints (#ref(label("eq:efpe constraint"))) constraints across all decision points $j in J$ and actions $a in A_j$ of Player~$1$, we can express the whole set of trembling constraints in matrix form as $M_1 \( epsilon.alt \) vx >= vm_1 \( epsilon.alt \)$. (An analogous statement holds for Player~$2$). So, given sufficiently small $epsilon.alt > 0$, and indicating with $F_1 vx = vf_1 \, vx >= 0$ and $F_2 vy = vf_2 \, vy >= 0$ the polytope of sequence form strategies of Player 1 and Player 2 respectively, a Nash equilibrium strategy for Player~$1$ under the trembling constraints can be expressed as the saddle point problem

#math.equation(
  block: true,
  numbering: "(1)",
  $cases(max_vx min_vy vx^top U_1 vy, upright("s.t.") upright("①") thin F_2 vy = vf_2, upright("") upright("②") thin M_2 \( epsilon.alt \) vy >= vm_2 \( epsilon.alt \), upright("") upright("③") thin F_1 vx = vf_1, upright("") upright("④") thin M_1 \( epsilon.alt \) vx >= vm_1 \( epsilon.alt \) .)$.body,
) <eq:efpe>

We will look into how to compute a limit point of solutions to @eq:efpe as $epsilon.alt -> 0^(+)$ in @sec:trembling-lp.

== Quasi-perfect equilibrium (QPE)

_Quasi-perfected equilibrium (QPE)_, introduced by #citet(<vanDamme84:relation>), is a bit more intricate than EFPE.  Specifically, while in an EFPE each trembling constraints mandates a lower bound of $epsilon.alt$ on the probability of playing each _action_, in the case of a QPE the lower bounds are given on the probability of each _sequence_ of actions.  More precisely, for all sufficiently small $epsilon.alt > 0$ and player $i in { 1 \, 2 }$, let $vell_i : bb(R)_(> 0) -> bb(R)_(> 0)^(Sigma_i)$ denote the vector parametrized on $epsilon.alt$ and indexed on the sequences $Sigma_i$ of Player~$i$, whose entries are defined as

#math.equation(
  block: true,
  numbering: "(1)",
  $ell_(i \, sigma) \( epsilon.alt \) = epsilon.alt^(\| sigma \|) #h(2em) forall sigma in Sigma_i \,$.body,
) <eq:ms-ell>

where $\| sigma \|$ denotes the number of actions for Player~$i$ in the sequence $sigma$. #citet(<Miltersen10:Computing>) proved that any limit point of the solution to the perturbed optimization problem

#math.equation(
  block: true,
  numbering: "(1)",
  $cases(max_vx min_vy vx^top U_1 vy, upright("s.t.") upright("①") thin F_2 vy = vf_2, upright("") upright("②") thin vy >= vell_2 \( epsilon.alt \), upright("") upright("③") thin F_1 vx = vf_1, upright("") upright("④") thin vx >= vell_1 \( epsilon.alt \))$.body,
) <eq:qpe>

is a QPE. (Recently, #citet(<Gatti20:Characterization>) took this construction further, and showed that _any_ QPE can be expressed as a limit point of solutions to @eq:qpe, as long as more general vectors of polynomials $vell_1 \, vell_2$ are used than in (@eq:ms-ell). In this paper we will focus on Miltersen-Sørensen-style perturbation as defined in (@eq:ms-ell).)

Once again, we will discuss how to compute a limit point of solutions to @eq:qpe as $epsilon.alt -> 0^(+)$ in @sec:trembling-lp.

== Relationships between the equilibria

We already know from @sec:une that undomination does not imply sequential rationality. Interestingly, the converse also is not true in general. So, undomination and sequential rationality are actually incomparable concepts, in the sense that neither implies the other.

At this point, one might naturally wonder whether a refinement that is both undominated and sequentially-rational can be devised. The answer is yes: a nice property of QPE is that not only it is sequentially rational, but it is also undominated! The same cannot be said of EFPE. So, as #citet(<Mertens95:Two>) noted, a _quasi-perfect equilibrium_ is nowadays considered superior to EFPE.

#quote(block: true)[
  « Observe that the “quasi-perfect” equilibria $\[$..$\]$ are still sequential---and sequential equilibria have all backward-induction properties (_e.g._, Kohlberg and Mertens, 1986)---but are at the same time normal form perfect---which can be viewed as the strong version of undominated. (And every proper equilibrium is quasi-perfect.) Thus, by some irony of terminology, the “quasi”-concept seems in fact far superior to the original unqualified perfection itself. »

  (from #citet(<Mertens95:Two>))
]

The relationships among the different refinements is summarized in the Venn diagram of @fig:refinements.

#figure(caption: [Relationships between the different Nash equilibrium refinements. The labels (a), (b), and (c) mark the regions that the three profiles of @ex:separating occupy.])[
  #image("figures/perfection/venn.svg", width: 60.0%)
] <fig:refinements>

Every inclusion in @fig:refinements is strict. The next example exhibits, in the single game of @fig:separating, three profiles that separate the sets: an EFPE that is not normal-form perfect, a normal-form perfect equilibrium that is not sequential, and a QPE that is not an EFPE. Together they show that extensive-form perfection is incomparable with both normal-form perfection and quasi-perfection; the classical examples of these phenomena are due to #citet(<Selten75:Reexamination>), #citet(<vanDamme84:relation>), #citet(<kohlberg1986strategic>), and #citet(<Mertens95:Two>), whose example even has disjoint sets of EFPE and of QPE #citep(<Farina18:Practical>). For a systematic treatment, see Chapter~6 of #citet(<vanDamme91:Stability>) or the survey by #citet(<Hillas02:Foundations>).

#figure(caption: [A two-player zero-sum perfect-information game, drawn once for each of the three profiles of @ex:separating. The first payoff belongs to Player~$1$, who moves at A and C (black nodes); Player~$2$ moves at B. If Player~$2$ plays $r$, Player~$1$ receives $t$; the gray label beside that leaf gives the value of $t$ in each panel. Thick orange edges are the actions that the profile prescribes. The gray labels in parentheses are the trembles that each argument relies on: in (a), the uniform trembles $epsilon.alt$ of the perturbed problem (@eq:efpe), under which continuing at A is worth $1 - epsilon.alt + 2 epsilon.alt^2 < 1$; in (b), C can be reached only if Player~$1$ deviates from $a$, so the plan $a d$ is never tested at C; in (c), a quasi-perfect Player~$1$ accounts for Player~$2$'s tremble $eta$ at B but not for a tremble of their own at C, so continuing at A is worth exactly $1$.])[
  #image("figures/perfection/separating.svg", width: 100%)
] <fig:separating>

#figure(
  kind: table,
  supplement: [Table],
  caption: [Player~$1$'s payoffs in the normal form of the game of @fig:separating: each entry is what Player~$1$ earns by following the plan in its row when Player~$2$ plays the action in its column. Player~$2$'s payoffs are their negatives. The plans $a c$ and $a d$ form a single row because C is unreached after $a$. For $t = 2$, the plan $b c$ weakly dominates stopping; for $t = 1$, every plan other than $b d$ earns $1$ whatever Player~$2$ does.],
)[
  #table(
    stroke: none,
    columns: 5,
    align: (left, center, center, center, center),
    inset: .7em,
    table.header(
      [], table.cell(colspan: 2)[*$t = 2$*, Player~$2$ plays], table.cell(colspan: 2)[*$t = 1$*, Player~$2$ plays],
      [*Plan of Player~$1$*], [$r$], [$s$], [$r$], [$s$],
    ),
    [$a c$, $a d$], [$1$], [$1$], [$1$], [$1$],
    [$b c$], [$2$], [$1$], [$1$], [$1$],
    [$b d$], [$2$], [$-1$], [$1$], [$-1$],
  )
] <tab:normal-form>

#example[Witnesses for the strict inclusions in @fig:refinements][
  Consider the game of @fig:separating, whose three panels show the same tree with the payoff $t$ and the highlighted profile of the corresponding part below. We write a strategy profile as $(x y; z)$, where Player~$1$ plays $x$ at A and $y$ at C, and Player~$2$ plays $z$ at B; @tab:normal-form lists Player~$1$'s payoffs in the normal form. For either value of $t$, Player~$1$ can guarantee $1$ by stopping at A, and Player~$2$ can hold Player~$1$ to $1$ by playing $s$; so the value of the game is $1$. In all three profiles below, Player~$2$ plays $s$, and only Player~$1$'s behavior at A and at C changes.

  *(a) An EFPE that is not normal-form perfect* ($t = 2$). Let $sigma = (a c; s)$. It is a Nash equilibrium: against $s$, Player~$1$ cannot earn more than the $1$ that $a$ earns, and B is unreached. It is also sequentially rational: at C, $c$ beats $d$; at B, $s$ earns Player~$2$ $-1$ while $r$ earns $-2$. To see that $sigma$ is an EFPE, consider the perturbed problem (@eq:efpe), in which every action has probability at least $epsilon.alt$ (the gray labels in @fig:separating(a)). Player~$1$ still strictly prefers $c$ at C, and Player~$2$ still strictly prefers $s$ at B, so each plays the other action with probability exactly $epsilon.alt$. Continuing at A is then worth $2 epsilon.alt + (1 - epsilon.alt)(1 - 2 epsilon.alt) = 1 - epsilon.alt + 2 epsilon.alt^2 < 1$, so Player~$1$ plays $b$ with probability exactly $epsilon.alt$. As $epsilon.alt -> 0^+$, these perturbed equilibria converge to $sigma$, which is therefore an EFPE. Yet $sigma$ is not normal-form perfect. The plan $b c$ earns Player~$1$ $2$ against $r$ and $1$ against $s$ (@tab:normal-form), so it weakly dominates stopping; hence stopping is not a best response to any completely mixed strategy of Player~$2$, which normal-form perfection requires #citep(<Selten75:Reexamination>, <Myerson78:Refinements>). Since every QPE is normal-form perfect #citep(<vanDamme84:relation>), $sigma$ is not a QPE either. The mechanism is the one noted by #citet(<vanDamme84:relation>) and #citet(<Mertens95:Two>): under the uniform trembles of (@eq:efpe), the agent at A fears Player~$1$'s own tremble at C, which costs about $2 epsilon.alt$, more than it values Player~$2$'s tremble at B, which gains about $epsilon.alt$. In the normal form, Player~$1$ commits to the whole plan $b c$ at once and has no own tremble to fear.

  *(b) A normal-form perfect equilibrium that is not sequential* ($t = 1$). Let $sigma' = (a d; s)$. It is a Nash equilibrium: against $s$, no plan of Player~$1$ earns more than the $1$ that stopping earns, and B is unreached. Recall that a profile is normal-form perfect if and only if it is the limit of completely mixed profiles to each of which it is a best response #citep(<Selten75:Reexamination>, <Myerson78:Refinements>). For $k >= 4$, let Player~$2$ play $r$ with probability $1\/k$, and let Player~$1$ play each of the plans $a c$, $b c$, and $b d$ with probability $1\/k$ and the plan $a d$ otherwise. Against Player~$2$, the plan $a d$ earns $1$, as do $a c$ and $b c$, whereas $b d$ earns less; so $a d$ is a best response. Against Player~$1$, action $s$ earns Player~$2$ $-1 + 2\/k$ whereas $r$ earns $-1$; so $s$ is a best response. Letting $k -> oo$ shows that $sigma'$ is normal-form perfect. (Because the game has two players, it would suffice to note that $sigma'$ is a Nash equilibrium in undominated strategies #citep(<vanDamme91:Stability>, [Theorem~3.2.2]).) Yet at C, $d$ earns $-1$ while $c$ earns $1$; so $sigma'$ is not sequentially rational, and not even subgame perfect. Normal-form perfection guards against the opponents' mistakes, not against one's own: once Player~$1$ plans to stop at A, no strategy of Player~$2$ ever reaches C, so what the plan does there is never tested, and $a c$ and $a d$ are the same row of @tab:normal-form. #citet(<Selten75:Reexamination>) defined perfection on the agent normal form precisely to close this gap. The modified Guess-the-Ace game of @ex:guess-the-ace-x shows the same failure at an opponent's decision point: the profile in which Player~$1$ quits and never gifts while Player~$2$ guesses ‘A$suit.spade.filled$’ is a Nash equilibrium in undominated strategies (the guess ‘A$suit.spade.filled$’ is the better one against a Player~$1$ who bets and gifts only after a wrong ‘A$suit.spade.filled$’ guess), hence normal-form perfect, but Player~$2$'s guess is not a best response at B.

  *(c) A QPE that is not an EFPE* ($t = 1$). Let $sigma'' = (b c; s)$. It is a Nash equilibrium ($a$ and $b$ both earn $1$ against $s$ and $c$; $r$ and $s$ both earn $-1$ against $c$), and it is sequentially rational at every decision point. In a quasi-perfect equilibrium, each player best responds at each decision point to the perturbed strategies of the _opponents_ but to their _own_ unperturbed continuation #citep(<vanDamme84:relation>), as the gray labels in @fig:separating(c) indicate. Along any sequence of completely mixed profiles converging to $sigma''$: at A, continuing and then playing $c$ earns exactly $1$, the same as stopping, so $b$ is a best response; at C, $c$ is optimal; at B, $s$ is strictly better than $r$ as long as Player~$1$ trembles to $d$. Hence $sigma''$ is a QPE. The same conclusion follows from the perturbed problem (@eq:qpe): Player~$1$'s utility there is $1 - 2(1 - y_r) x_(b d)$, so every feasible $vx$ with $x_(b d) = epsilon.alt^2$ is optimal, including $x_a = epsilon.alt$, $x_(b c) = 1 - epsilon.alt - epsilon.alt^2$, which converges to $sigma''$. Yet $sigma''$ is not an EFPE. Whenever Player~$2$ plays $r$ with some probability $eta_r < 1$ and Player~$1$ plays $d$ with some probability $eta_d > 0$, as every perturbed game forces, continuing at A earns $eta_r + (1 - eta_r)(1 - 2 eta_d) = 1 - 2 eta_d (1 - eta_r) < 1$. So the agent at A strictly prefers to stop, every perturbed equilibrium plays $b$ with the minimum allowed probability, and no limit of perturbed equilibria plays $b$, however the trembles vanish.#footnote[@sec:efpe defines an EFPE with the same lower bound $epsilon.alt$ on every action. Selten's original definition lets the lower bounds of different actions vanish at different rates #citep(<Selten75:Reexamination>). The argument covers both definitions, since it holds for every positive $eta_r$ and $eta_d$.] The unique EFPE for $t = 1$ is $(a c; s)$. The sequence-form constraints show the contrast: problem (@eq:qpe) charges Player~$1$ a fixed tremble $x_(b d) >= epsilon.alt^2$ however often they continue, whereas problem (@eq:efpe) charges $x_(b d) >= epsilon.alt x_b$, a tremble proportional to how often they continue. In words, Player~$1$ continues at A only when trusting that no mistake will be made at C; a QPE allows that trust, and an EFPE does not #citep(<Mertens95:Two>).
] <ex:separating>

@tab:separating summarizes the three profiles. Parts (a) and (c) rely on Player~$1$ being indifferent at A between stopping and continuing, and they must: for generic payoffs, the sets of sequential, extensive-form perfect, and quasi-perfect equilibrium profiles coincide #citep(<Kreps82:Sequential>, <Blume94:Algebraic>, <Pimienta14:Equivalence>), and quasi-perfect equilibria are always normal-form perfect #citep(<vanDamme84:relation>), so neither witness exists for generic payoffs. Part (b) needs no tie.

#figure(
  kind: table,
  supplement: [Table],
  caption: [Membership of the three strategy profiles of @ex:separating in the sets of @fig:refinements.],
)[
  #table(
    stroke: none,
    columns: 7,
    align: (left, left, center, center, center, center, center),
    inset: .7em,
    table.header([*Part*], [*Profile*], [*Nash*], [*Sequential*], [*EFPE*], [*Normal-form perfect*], [*QPE*]),
    [(a)], [$(a c; s)$, $t = 2$], [#sym.checkmark], [#sym.checkmark], [#sym.checkmark], [#sym.crossmark], [#sym.crossmark],
    [(b)], [$(a d; s)$, $t = 1$], [#sym.checkmark], [#sym.crossmark], [#sym.crossmark], [#sym.checkmark], [#sym.crossmark],
    [(c)], [$(b c; s)$, $t = 1$], [#sym.checkmark], [#sym.checkmark], [#sym.crossmark], [#sym.checkmark], [#sym.checkmark],
  )
] <tab:separating>

== Computational complexity

Perhaps surprisingly, finding an EFPE or a QPE in a two-player game is not harder than finding a Nash equilibrium. In particular, in zero-sum games, an EFPE and a QPE can be found in polynomial time in the size of the input game. @tab:complexity summarizes the computational complexity of computing the Nash equilibrium refinements mentioned so far in two-player games.

#figure(
  kind: table,
  supplement: [Table],
  caption: [Complexity of computing different Nash equilibrium refinements in two-player games.],
)[

  #table(
    stroke: none,
    columns: 3,
    align: left + top,
    inset: .7em,
    table.header([*Solution concept*], [*General-sum*], [*Zero-sum*]),
    [Nash equilibrium (NE)],
    [PPAD-complete #citep(<Daskalakis09:Complexity>)],
    [FP #citep(<Romanovskii62:Reduction>, <Stengel96:Efficient>)],

    [Subgame perfect equilibrium (SPE)], [PPAD-complete], [FP],
    [Quasi perfect equilibrium (QPE)],
    [PPAD-complete #citep(<Miltersen10:Computing>)],
    [FP #citep(<Miltersen10:Computing>)],

    [Extensive-form perfect equilibrium (EFPE)],
    [PPAD-complete #citep(<Farina17:Extensive>)],
    [FP #citep(<Farina17:Extensive>)],
  )
] <tab:complexity>

= Trembling linear programs and computation of QPE and EFPE

<sec:trembling-lp>

We can compute a limit point of solutions to @eq:efpe and @eq:qpe using the same machinery. As a first step, just like what we did for the Nash equilibrium, we convert the bilinear saddle-point formulations @eq:efpe, @eq:qpe into linear programs by dualizing the internal minimization problems. This gives us a linear program where the constraints matrix and the objective function depend polynomially on $epsilon.alt$. In particular, for both QPE and EFPE we end up with a linear program of the form

$
  P(epsilon.alt) : cases(
    max_vx & vc(epsilon.alt)^top vx,
    upright("s.t.") & A(epsilon.alt) vx = vb(epsilon.alt),
    & vx >= 0 .,
  )
$

where $vc \, A$ and $vb$ are _polynomial_ functions of $epsilon.alt$ with rational coefficients.  We will call an object of that form a _trembling linear program (TLP)_, and a limit point of solutions to $P \( epsilon.alt \)$ as $epsilon.alt -> 0^(+)$ a _limit solution_ of the TLP.  With this formalism, we can reframe the computation of an EFPE or a QPE as the problem of finding a limit solution to their corresponding TLPs.

For the following discussion, assume the perturbed LP is feasible with a finite optimum for every sufficiently small positive perturbation, and that the optimal solutions under consideration have a finite limit. These conditions hold for the bounded strategy polytopes in our game applications. We will now discuss the complexity of solving a TLP, and two different computational approaches. Both of them are based on the concept of _basis stability_ (Recall that a _basis_ of an LP is a subset of the program's variables such that when only those columns of matrix $A$ that correspond to those variables are included in a new matrix $A$, the new matrix $A$ is invertible #citep(<Bertsimas97:Introduction>, [page 55]).

#definition[Stable basis][
  Let $P \( epsilon.alt \)$ be a TLP. The LP basis $B$ is said to be _stable_ if there exists $macron(epsilon.alt) > 0$ such that $B$ is optimal for $P \( epsilon.alt \)$ for all $epsilon.alt : 0 < epsilon.alt <= macron(epsilon.alt)$.
] <def:stable-basis>

If a stable basis were to be found, from there a limit solution of $P \( epsilon.alt \)$ could be computed in polynomial time. As it turns out, a stable basis always exists, and can be computed in polynomial time.

== Negligible Positive Perturbations (NPP)

<sec:npp>

#citet(<Farina18:Practical>), extending prior work by #citet(<Miltersen10:Computing>) and #citet(<Farina17:Extensive>), showed the following.

#theorem[#citet(<Farina18:Practical>)][
  Given as input a TLP $P \( epsilon.alt \)$, there exists $epsilon.alt^(*) > 0$---called a _negligible positive perturnation (NPP)_---such that for all $0 < macron(epsilon.alt) <= epsilon.alt^(*)$, any optimal basis for the numerical LP $P (macron(epsilon.alt))$ is stable. Furthermore, such a value $epsilon.alt^(*)$ can be computed in polynomial time in the input size, assuming that a polynomial of degree $d$ requires $Omega \( d \)$ space in the input.#footnote[If this were not the case, evaluating a polynomial in an integer $n$ would not be an efficient operation, since it requires $Omega (d log n)$ bits to represent the output.]
] <thm:npp>

So, at least in principle, a solution to a TLP $P \( epsilon.alt \)$ could be computed as follows:

- First, compute the value of the NPP $epsilon.alt^(*)$ using the constructive proof of @thm:npp.
- Then, solve the numerical linear program $P (epsilon.alt^(*))$ to optimality. Since the bit complexity of $epsilon.alt^(*)$ is polynomial in the size of the TLP, the numerical LP can be solved to optimality in polynomial time, and a basis $B$ can be extracted. From @thm:npp, such a basis is stable (@def:stable-basis).
- Finally, extract the limit solution to the TLP from the stable basis.

The algorithm just described has polynomial complexity in the TLP size. In the case of the TLP arising form QPE and EFPE, that translates into a polynomial-time algorithm to find an exact EFPE and QPE in a two-player zero-sum game (see also @tab:complexity).

== A significantly more scalable approach

While technically polynomial, the NPP-based algorithm described in the previous subsection is mostly of conceptual interest. In practice, because the value of the NPP is so small, any linear programming solver that wants to have a chance at solving the numerical linear program $P (epsilon.alt^(*))$ must---as a minimum---use rational arithmetic, rendering the algorithm extremely slow.

A significantly more scalable algorithm for solving TLPs, due to~#citet(<Farina18:Practical>), avoids the pessimistically small numerical NPP $epsilon.alt^(*)$ of @thm:npp by using an efficient stability-checking oracle for checking if a basis is stable or not.

The iterative algorithm repeatedly picks a numerical perturbation $macron(epsilon.alt)$, computes an optimal basis for the perturbed LP $P (macron(epsilon.alt))$, and queries the basis-stability oracle. If the basis is not stable, the algorithm concludes that the perturbation value $macron(epsilon.alt)$ was too optimistic, and a new iteration is performed with a smaller perturbation reduced by a multiplicative constant (for example, divide it by $upright("1000")$). On the other hand, if the basis is stable, the algorithm takes the limit of the LP solution and returns it as the limit solution of the TLP. Correctness and termination are guaranteed by the following observation.

#remark[
  Any value of $macron(epsilon.alt)$ in the range $lr((0 \, epsilon.alt^(*)])$ guarantees termination of the algorithm. Indeed, by @thm:npp, any optimal basis for $P (macron(epsilon.alt))$ is stable and makes our iterative algorithm terminate. Furthermore, if after every negative stability test the value of $macron(epsilon.alt)$ is reduced by a constant multiplicative factor (_e.g._, halved), then since $epsilon.alt^(*)$ only has a polynomial number of bits, the algorithm terminates after trying at most a polynomial number of different values for $macron(epsilon.alt)$.
]

The practical algorithm is 3-4 orders of magnitude faster than the conceptual algorithm described in @sec:npp, and is the current state-of-the-art algorithm for computing QPE and EFPE.

= Bibliography for this lecture

#lec_bibliography("meta/refs.bib", title: none)

#appendix[
  = Why not uniform lower bounds in QPE?

  Not all vanishing perturbations $vell_1 \( epsilon.alt \) \, vell_2 \( epsilon.alt \)$ in the QPE
  formulation @eq:qpe lead to a sequentially-rational
  equilibrium.
  For example, it is natural to wonder whether it is _really_ necessary
  to consider lower bounds of the form $epsilon.alt^sigma$ instead of,
  for example, the uniform lower bound $epsilon.alt$ for all sequences.
  After all,

  surely a
  uniform lower bound of $epsilon.alt$ would still force the whole game to be
  explored, wouldn't it?
  While appealing on the surface, such a uniform lower
  bound might result in a solution that is not even subgame perfect, much less
  sequentially rational!

  We illustrate this point with an example.

  #example[
    Consider this perfect-information zero-sum game, with the first payoff belonging to Player 1 (black nodes). For $0<epsilon.alt<1/3$, the perturbed equilibrium has the behavioral probabilities in the table.

    #wrapped-figure(
      [
        #image(
          "figures/perfection/uniform_game.svg",
          width: 100%,
          alt: "Player 1 chooses a for payoff (2,-2) or b. After b, Player 2 chooses r or s. After r, Player 1 chooses c for (1,-1) or d for (-2,2). After s, Player 1 chooses p or q, both for (0,0).",
        )
      ],
      [
        #table(
          columns: (auto, auto),
          inset: 4pt,
          stroke: .2mm,
          table.header[*Action*][*Probability*],
          [$a$], [$1-2epsilon.alt$],
          [$b$], [$2epsilon.alt$],
          [$c,d,p,q$], [$1/2$],
          [$r$], [$1-epsilon.alt$],
          [$s$], [$epsilon.alt$],
        )
      ],
      side: right,
      text-width: 57%,
    )
  ]

  Put the same lower bound $epsilon.alt$ on every nonempty sequence. Player 1's sequence-form constraints include
  $ x_(b c)+x_(b d)=x_b, quad x_(b p)+x_(b q)=x_b. $
  The two continuation information sets follow different actions of Player 2. They each inherit realization weight $x_b$; their weights are not added together. Thus the four lower bounds imply $x_b>=2epsilon.alt$, rather than $4epsilon.alt$.

  Write $r$ for the probability that Player 2 selects action $r$. Against any feasible $r in [epsilon.alt,1-epsilon.alt]$, Player 1's utility is
  $ 2(1-x_b)+r(x_(b c)-2x_(b d)) = 2-(2-r)x_b-3r x_(b d). $
  It is maximized uniquely by $x_b=2epsilon.alt$ and $x_(b d)=epsilon.alt$. The flow constraints then force $x_(b c)=x_(b p)=x_(b q)=epsilon.alt$. Hence all four continuation actions have conditional probability $1/2$. The bound $epsilon.alt<1/3$ ensures $x_a=1-2epsilon.alt>=epsilon.alt$.

  Given those continuations, Player 2 receives $1/2$ conditional on choosing $r$, and $0$ conditional on choosing $s$. Since $x_b>0$, the unique best response is $r=1-epsilon.alt$. This proves the claimed perturbed equilibrium for positive $epsilon.alt$.

  As $epsilon.alt$ tends to zero, the limiting profile selects $a$ at the root, but still mixes equally between $c$ and $d$ at $C$. In that subgame, $c$ gives Player 1 payoff $1$ and $d$ gives $-2$. Thus the continuation fails to be a best response, so the limit is not subgame perfect and therefore cannot be sequentially rational. Uniqueness was claimed only for the positive perturbations; the unperturbed game has other equilibria.
]
