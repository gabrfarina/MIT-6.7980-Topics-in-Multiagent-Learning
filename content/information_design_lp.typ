#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Drafted with assistance from Claude for Typst formatting.

#let matF = $upright(bold(F))$

= Solving the reduced game <sec-l11-solving>

The revelation principle and the two reductions leave us with a
communication game: an extensive-form game of size polynomial in the
original game tree, in which the players' reports and the mediator's
recommendations are ordinary actions. Each player $i$ has a fixed direct
strategy $vx^*_i$, which reports private information truthfully and obeys
every recommendation. What remains is to find the mediator strategy that
maximizes the mediator's utility while keeping every player direct. We now
show that this is a linear program of polynomial size, which completes the
proof of the main theorem #citep(<ZhangSandholm2022Polynomial>).

Let $cX_M$ and $cX_1, ..., cX_n$ denote the
#lecture-link("efg_intro", <sec-sequence-form>)[sequence-form polytopes] of the
mediator and the players in the communication game. The mediator has
perfect recall there, since it remembers every report it receives and every
recommendation it sends, so by
#lecture-link("efg_intro", <sec-behavioral-form>)[Kuhn's theorem] we can
represent its randomized strategy by a sequence-form vector vmu in cX_M.

== The optimization problem <sec-l11-program>

By the revelation principle, it suffices to search over direct
communication equilibria: mediator strategies $vmu$ such that no player can
gain by abandoning $vx^*_i$ while the others remain direct. The best one
solves

#set math.equation(numbering: "(1)")
$
  max_(vmu in cX_M) u_M (vmu, vx^*_1, ..., vx^*_n)
  quad "s.t." quad
  u_i (vmu, vx^*_i, vx^*_(-i)) >= max_(vx'_i in cX_i) u_i (vmu, vx'_i, vx^*_(-i))
  quad forall i in [n].
$ <eq-l11-program>
#set math.equation(numbering: none)

The definition of a communication equilibrium asks for equality in each
constraint, but the inequality is equivalent: taking $vx'_i = vx^*_i$ shows
that the right side is never smaller than the left. The only variable is
$vmu$. The direct strategies are constants, since they depend only on the
structure of the communication game, and each $vx'_i$ is bound by its
maximum.

Two features of program (@eq-l11-program) make it look hard to solve: the utilities
are products of several strategies, and every constraint contains a
maximization over all of player $i$'s strategies. We handle them in turn.

== Linearity in the sequence form <sec-l11-linearity>

Let $Z$ be the set of terminal nodes of the communication game. For
$z in Z$, let $p_c (z)$ be the product of the chance probabilities on the
path to $z$, and let $sigma_M (z)$ and $sigma_i (z)$ be the last sequences
of the mediator and of player $i$ on that path (the empty sequence $∅$ if
they do not act). In the sequence form, the expected utility of each
participant $k in {M, 1, ..., n}$ is

$
  u_k (vmu, vx_1, ..., vx_n)
  = sum_(z in Z) p_c (z) thin u_k (z) thin vmu[sigma_M (z)]
  product_(j = 1)^n vx_j [sigma_j (z)],
$

which is linear in each strategy when the others are held fixed. Applying
this to the three terms of (@eq-l11-program):

- *Objective.* All players are direct, so $u_M (vmu, vx^*) = vc^top vmu$,
  where
  $ vc[sigma] := sum_(z : sigma_M (z) = sigma) p_c (z) thin u_M (z) product_(j = 1)^n vx^*_j [sigma_j (z)]. $
- *Left side of constraint $i$.* Likewise $u_i (vmu, vx^*) = vb_i^top vmu$,
  with $u_i (z)$ in place of $u_M (z)$.
- *Right side of constraint $i$.* Only $vx'_i$ and $vmu$ vary, so the
  utility is bilinear: $u_i (vmu, vx'_i, vx^*_(-i)) = vmu^top matA_i vx'_i$,
  where
  $ matA_i [sigma, tau] := sum_(z : sigma_M (z) = sigma, thin sigma_i (z) = tau) p_c (z) thin u_i (z) product_(j != i) vx^*_j [sigma_j (z)]. $

The direct strategies are deterministic, so their entries are $0$ or $1$,
and each product simply keeps the terminal nodes reached when the relevant
players are direct. Each terminal node contributes to at most one entry of
$vc$, $vb_i$, and $matA_i$, so these can be built in time linear in the
size of the communication game. The program becomes

#set math.equation(numbering: "(1)")
$
  max_(vmu in cX_M) vc^top vmu
  quad "s.t." quad
  vb_i^top vmu >= max_(vx'_i in cX_i) vmu^top matA_i vx'_i
  quad forall i in [n].
$ <eq-l11-bilinear>
#set math.equation(numbering: none)

The objective and the left sides are now linear. Each right side is a
maximum of linear functions of $vmu$, so the feasible set is convex, but
writing one inequality for each vertex of $cX_i$ (each pure strategy of
player i) would take exponentially many constraints. Duality avoids this.

== From the program to a linear program <sec-l11-lp>

Write each player's polytope in standard form,
$cX_i = {vx >= vzero : matF_i vx = vf_i}$, where $matF_i$ has one row for
the constraint $x_∅ = 1$ and one row for each decision node $j$ of
player $i$, encoding $sum_(a in A_j) x_(j a) - x_(p_j) = 0$. Thus $vf_i$
is $1$ in the first row and $0$ elsewhere. For a fixed $vmu$, the right
side of constraint $i$ in (@eq-l11-bilinear) is a linear program in $vx'_i$.
It is feasible and bounded, so strong duality gives

$
  max_(vx'_i >= vzero, thin matF_i vx'_i = vf_i) (matA_i^top vmu)^top vx'_i
  = min_(vv_i thin : thin matF_i^top vv_i >= matA_i^top vmu) vf_i^top vv_i ,
$

with one free dual variable per row of $matF_i$. This is the same step
that turns the #lecture-link("correlated", <sec-zero-sum>)[max-min problem
of a zero-sum game] into a linear program, and with sequence-form
strategies it yields the classical linear program for zero-sum
extensive-form games #citep(<Koller96:Efficient>, <Stengel96:Efficient>).

Swapping the maximum for a minimum is exactly what we need. The constraint
$vb_i^top vmu >= min_(vv_i) vf_i^top vv_i$ holds if and only if some
feasible $vv_i$ satisfies $vb_i^top vmu >= vf_i^top vv_i$, because the
minimum is attained. We can therefore make each $vv_i$ a variable and let
the solver find this witness. The optimal communication equilibrium is the
$vmu$-part of an optimal solution to

#set math.equation(numbering: "(1)")
$
  max_(vmu, thin vv_1, ..., thin vv_n) vc^top vmu
  quad "s.t." quad
  cases(
    vmu in cX_M,
    vb_i^top vmu >= vf_i^top vv_i & quad forall i in [n],
    matF_i^top vv_i >= matA_i^top vmu & quad forall i in [n] .
  )
$ <eq-l11-lp>
#set math.equation(numbering: none)

It has one variable per mediator sequence and one per decision node of
each player, plus $n$ more, so its size is polynomial in that of the
communication game, and hence in that of the original game tree. It is
also feasible, since every Nash equilibrium of the original game is a
communication equilibrium with a mediator that does nothing. Linear
programs can be solved in polynomial time, which proves the main theorem.

#paragraph-marker() *Interpreting the dual variables.*~~ At an optimal
solution, we may take $vv_i [j]$ to be the value player $i$ obtains by best
responding from decision node $j$ onward, against $vmu$ and the direct
strategies of the others. The row of $matF_i^top vv_i >= matA_i^top vmu$
for a sequence $j a$ reads

$ vv_i [j] >= (matA_i^top vmu)[j a] + sum_(j' : p_(j') = j a) vv_i [j'] , $

that is, the value at $j$ is at least the value of playing $a$ and then
continuing optimally. The root entry $vf_i^top vv_i$ is then the value of
player $i$'s best deviation. The linear program thus checks incentive
compatibility by writing the bottom-up best-response computation as
inequalities, so it never enumerates player $i$'s exponentially many pure
strategies.

#example[Selling a car][
  Consider the car-selling example from information design, measuring
  money in thousands of dollars. The car is good with probability $1/3$ and
  bad with probability $2/3$. The seller, acting as the mediator, observes
  the quality and recommends _Buy_ or _Pass_. The buyer has nothing to
  report. Buying gives the seller $5$, and gives the buyer $1$ for a good
  car and $-1$ for a bad one.

  Write $mu_g$ and $mu_b$ for the probabilities of recommending _Buy_ after
  seeing a good or a bad car. Then $vc^top vmu = 5 (mu_g + 2 mu_b) \/ 3$,
  and the buyer's expected utility if she follows each recommendation is
  $
    alpha := mu_g / 3 - (2 mu_b) / 3 quad "(told Buy)",
    qquad
    beta := (1 - mu_g) / 3 - (2 (1 - mu_b)) / 3 quad "(told Pass)".
  $
  The direct strategy earns $vb^top vmu = alpha$, since obeying _Pass_
  earns nothing. The buyer has two decision nodes, after hearing _Buy_ and
  after hearing _Pass_, so $vv = (vv[∅], vv[upsans(B)], vv[upsans(P)])$ and
  the dual constraints read
  $
    vv[∅] >= vv[upsans(B)] + vv[upsans(P)], quad
    vv[upsans(B)] >= max{alpha, 0}, quad
    vv[upsans(P)] >= max{beta, 0}.
  $
  Together with $alpha >= vv[∅]$, the constraints of (@eq-l11-lp) reduce to
  $alpha >= 0$ and $beta <= 0$: the buyer must want to buy when told _Buy_
  and to pass when told _Pass_. Maximizing $mu_g + 2 mu_b$ subject to
  $mu_g >= 2 mu_b$ gives $mu_g = 1$ and $mu_b = 1/2$, and the second
  constraint then holds since $beta = -1/3$. The seller sells the car with
  probability $2/3$ and earns $10/3$ in expectation, as in the information
  design example.
] <ex-l11-car-lp>

The linear program is exact and polynomial, but, as in zero-sum games,
general-purpose solvers scale poorly to large game trees. The next section
replaces it with a zero-sum game that the learning algorithms from earlier
lectures can solve.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
