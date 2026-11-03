#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  title: "Information asymmetry and the size of the TB-DAG",
  instructor: [Brian Hu Zhang],
)

// L12 material contribution, task 6 (slides 18--21).
// Standalone section for later integration with the team-belief-DAG section.

= Information asymmetry <sec-team-information-asymmetry>

The team belief DAG (TB-DAG) represents a team's coordinated strategies without listing all of its pure joint plans. Its usefulness depends on how large this representation becomes. Following slides 18--21 #citep(<Zhang26:TeamGames>), we bound its size by counting the possibilities within each public state. The key parameter is the amount of information that individual teammates possess but that is not common knowledge within the team.

Recall that a decision point contains a belief $B$, a set of possible game-tree nodes. A prescription specifies an action at each information set intersecting $B$. Applying that prescription produces an observation point; a subsequent public observation determines the next decision point. A public state groups histories that cannot be separated using the team's common knowledge. In particular, a public state may contain several beliefs, because past prescriptions can rule out different histories.

== Branching factor and last-infosets

Write $N$ for the number of nodes in the original game tree and $b$ for its maximum branching factor. Thus every information set has at most $b$ available actions. Assume that individual teammates have perfect recall, as in the preceding team-game construction.

To identify the information still relevant at a public state, consider the team as one merged player. An information set $J$ _remembers_ $I$ when every history in $J$ passes through $I$ and takes the same action there. At a history $h$, retain the information sets visited along $h$ that no later visited information set remembers; call these $"LI"(h)$, the _last-infosets_. They include the current information set when the team acts at $h$.

#definition[Information asymmetry][
  For a public state $P$, let
  $
    cal(L)(P) := union_(h in P) "LI"(h), quad
    k_P := |cal(L)(P)|, quad
    k := max_P k_P.
  $
  The parameter $k$ is the team's _information asymmetry_ (also called information complexity). For two teams, take the maximum over both teams' public states.
] <def-team-information-asymmetry>

This definition follows #citet(<Carminati26:Representations>). The union over histories matters: $k$ is not the number of teammates, nor the number of last-infosets on one realized path. One teammate can have many possible private observations within the same public state, each giving a different last-infoset. Perfect recall removes older information sets remembered by that teammate's latest information set, but it does not make their private information public to the team.

At the symmetric-information extreme $k=1$, the team can be represented by a single perfect-recall player. There is then no collection of distinct private information sets on which a coordinator must simultaneously prescribe actions. Larger $k$ allows more such contingencies, even if the number of teammates stays fixed.

== Counting observation points

Fix a public state $P$. For each $J in cal(L)(P)$, record one of the following:

- $⊥$: the player's own choices prevent it from reaching $J$;
- $a in A_J$: the player can reach $J$ and its pure plan selects action $a$ there.

Here reachability is determined by the player's own plan: choices of the other players and chance are allowed to vary. It does not mean that $J$ occurs in every play, or with positive probability against one particular opponent strategy.

The resulting vector is a _signature_ of the plan at $P$. Each coordinate has at most $b+1$ possibilities, so
$
  "number of signatures at" P
    <= product_(J in cal(L)(P)) (|A_J|+1)
    <= (b+1)^(k_P)
    <= (b+1)^k.
$

Why does this count help? The reachability entries retain which histories are compatible with the team's choices. The action entries also specify the current prescription. Information sets omitted from the list are remembered by retained ones, so their relevant past actions need not be encoded again. Thus we count the decision-point/prescription possibilities together, instead of independently counting beliefs and then multiplying by all possible prescriptions.

#example[
  Suppose a public state has three last-infosets and each has actions $L$ and $R$. There are at most $3^3=27$ signatures. For example, $(⊥,L,R)$ says that the first information set is excluded by its player's plan, while the other two prescribe $L$ and $R$. This is an upper bound: some signatures may violate the game's reachability constraints, and different signatures need not create different DAG nodes. If all three information sets must be reachable under every plan, only the $2^3=8$ action-only signatures remain.
]

#figure(
  image("figures/team_games/last_infoset_signature.svg", width: 100%),
  caption: [Encoding a plan at a public state with $k_P=3$ and $b=2$. Each last-infoset contributes $⊥$, $L$, or $R$; the highlighted choices give $(⊥,L,R)$. These are encoding choices, not branches of a game tree. Some combinations may be infeasible, so $27$ is an upper bound.],
) <fig-team-last-infoset-signature>

The lecture's $(b+1)^k$ bound captures this combinatorial part of the observation-point count. In a construction that further separates compatible histories into public-observation components, one signature may generate several disjoint components. Accounting for their incident edges gives the more explicit bound
$
  E <= N (b+1)^(k+1)
      = (b+1)^k dot N(b+1),
$
where $E$ is the number of TB-DAG edges; see Theorem 6.2 of #citet(<Carminati26:Representations>). In either convention, the exponential dependence is on $k$, with only a polynomial factor in the original tree size.

== Consequences for regret minimization

The TB-DAG supports regret minimization directly #citep(<Zhang23:TeamDAG>). A CFR iteration propagates values through the DAG and updates local regrets, with work proportional to its representation size. Consequently, the size bound gives
$
  "time per CFR iteration"
    = O(N(b+1)^(k+1))
    = (b+1)^k "poly"(N).
$
For two teams, the iteration visits both representations; using their maximum $k$ gives the same asymptotic bound. Three consequences clarify the guarantee.

First, *constant information asymmetry gives polynomial per-iteration time*. Since $b <= N$, fixing $k$ makes the displayed expression polynomial in $N$. The exponent of that polynomial can nevertheless depend on $k$.

Second, *the representation may still be large*. Even with binary actions, the counting term is $3^k$. The bound is useful when information asymmetry is small relative to the game, not merely when the team has few members.

Third, *this is a per-iteration bound*. Running $T$ CFR iterations costs $O(T N(b+1)^(k+1))$, apart from constructing the representation. The accuracy of the averaged strategies depends on the regret accumulated over those iterations. The size bound alone does not specify how many iterations achieve a requested approximation error, and one iteration does not compute an exact equilibrium.

== How much improvement should we expect?

Slide 21 uses bridge to illustrate the scale of the savings. Its rough estimates are $N approx 2^200$, $b < 2^6$, and $k approx binom(52,13) < 2^40$. Plugging these estimates into the counting term yields
$
  (b+1)^k <= 2^(6k) < 2^(6 dot 2^40).
$
This is much smaller than the slide's naive normal-form estimate of roughly $2^(2^200)$, even after allowing polynomial overhead in $N$. Both quantities remain enormous. The comparison demonstrates the benefit of organizing computation around private-information contingencies; it is not a practical running-time prediction for solving bridge.

Finally, could we replace the dependence on $b$ and $k$ by $2^(O(k)) "poly"(N)$ in general? The lecture rules this out assuming $"FPT" != "W[1]"$, a standard parameterized-complexity assumption weaker than the Exponential Time Hypothesis. The general imperfect-recall value problem admits no $f(k) "poly"(N)$ algorithm under that assumption #citep(<Carminati26:Representations>). There is no contradiction with the constant-$k$ guarantee: in $N(b+1)^(k+1)$ the exponent of $N$ may grow with $k$, whereas the exponent in $f(k) "poly"(N)$ must be independent of $k$. Extra structure can still make particular game families easier.

#lec_bibliography("meta/refs.bib", title: none)
