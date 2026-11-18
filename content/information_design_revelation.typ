#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Section 6 (revelation principle) of the Lecture 11 notes.
// Checked against the Lecture 11 slides (17--21, 28) and the class recording.

= The revelation principle <sec-l11-revelation>

Earlier in the lecture, a communication equilibrium was defined as a tuple $(mu, x_1, ..., x_n)$ in which every player best responds to the committed mediator strategy $mu$ and to the other players. The messages in that definition are arbitrary. A strategy may say "if I observe $t$, send $m_1$; if I then receive $m_2$, play $a$; if I receive $m_3$, play $a'$", and the sets of possible messages can be infinite. Optimizing over such strategies directly is hopeless.

This section carries out the first of the three steps behind the main theorem of the lecture. We show that the message spaces can be fixed, without loss of generality, to a finite and very structured form. Players send reports of their private information, and the mediator sends action recommendations. This result is known as the _revelation principle_ for communication equilibria #citep(<Forges1986Approach>). We follow the version and the proof idea presented in class #citep(<Zhang2026Mechanism>, [slides 17--21]), which is developed in full generality by #citet(<ZhangSandholm2022Mediator>).

== The communication model <sec-l11-rp-model>

Fix a finite extensive-form game $Gamma$ with players $[n] = {1, ..., n}$ and a chance player. As in #lecture-link("efg_intro")[the notes on extensive-form games], $H$ is the set of histories, $Z subset.eq H$ is the set of terminal histories, $cal(I)_i$ is the collection of information sets of Player $i$, and $A_I$ is the set of actions at information set $I in cal(I)_i$. Each player $i in [n]$ receives utility $u_(i)(z)$ at terminal history $z in Z$. The mediator has its own objective $u_(upright(M))(z)$. We assume throughout that every player has _perfect recall_. Then the information set $I in cal(I)_i$ at which Player $i$ acts records everything the player knows about the play so far, including all of its own past actions.

#paragraph-marker() *Communication rounds.*~~ The mediator is not a player of $Gamma$. It takes no actions in the game, and it observes nothing about the game except what the players tell it. A _communication protocol_ specifies, for each player $i$, two nonempty sets: a set $cal(M)_i$ of messages that Player $i$ can send to the mediator, and a set $cal(R)_i$ of messages that the mediator can send to Player $i$. Both sets may be infinite. Whenever Player $i$ is about to act at an information set $I in cal(I)_i$, one communication round takes place.

+ Player $i$ privately sends a message $m in cal(M)_i$ to the mediator.
+ The mediator privately replies with a message $r in cal(R)_i$.
+ Player $i$ plays an action $a in A_I$ in the game.

Communication is costless and has no direct effect on the outcome. Utilities depend only on the terminal history $z$. Messages matter only because strategies condition on them. The mediator knows which player it is talking to in each round. Nothing else about the game state reaches it.

#paragraph-marker() *Strategies.*~~ Consider Player $i$ in its $k$-th communication round. Let $I_1, ..., I_k$ be the information sets at which it has acted so far, the current one included, and let $r_1, ..., r_(k-1)$ be the replies it has received. By perfect recall, this sequence contains everything Player $i$ has observed. A _pure strategy_ $pi_i = (phi_i, alpha_i)$ of Player $i$ is a pair of rules:

$
  m_k = phi_(i)(I_1, r_1, ..., I_(k-1), r_(k-1), I_k) in cal(M)_i, quad quad a_k = alpha_(i)(I_1, r_1, ..., I_k, r_k) in A_(I_k).
$

The _message rule_ $phi_i$ chooses what to send, and the _action rule_ $alpha_i$ chooses what to play after the reply. The player's own past messages and actions are not listed as inputs, because they are already determined by these inputs and the rules themselves. Let $Pi_i$ denote the set of pure strategies of Player $i$.

A pure mediator strategy $rho$ maps the sequence of messages the mediator has received so far, each tagged with its sender, to a reply. If the $t$-th round overall is with Player $j_t$, the reply is $r_t = rho((j_1, m_1), ..., (j_t, m_t)) in cal(R)_(j_t)$. Let $P_upright(M)$ denote the set of pure mediator strategies.

A (possibly randomized) strategy is a probability distribution over pure strategies. We write $x_i in Delta(Pi_i)$ for Player $i$ and $mu in Delta(P_upright(M))$ for the mediator. When message sets are infinite, we only consider distributions for which the expectations below are well defined, for example finitely supported ones. Before play starts, $rho ~ mu$ and $pi_i ~ x_i$ are drawn independently. The mediator _commits_ to $mu$: every player knows $mu$, but no player sees the realized $rho$. The strategy profile and chance together induce a distribution over terminal histories, and we write

$
  u_(i)(mu, x_1, ..., x_n) := EE[u_(i)(z)], quad quad u_(upright(M))(mu, x_1, ..., x_n) := EE[u_(upright(M))(z)].
$

#definition[Communication equilibrium (recalled)][
  A tuple $(mu, x_1, ..., x_n)$ is a _communication equilibrium_ if no player benefits from a unilateral deviation:
  $
    u_(i)(mu, x_i, x_(-i)) >= u_(i)(mu, x'_i, x_(-i)) quad quad forall i in [n], forall x'_i in Delta(Pi_i).
  $
  The mediator is not subject to any incentive constraint, since it is committed to $mu$.
] <def-l11-rp-comm-eq>

== Direct communication equilibria <sec-l11-rp-direct>

The _direct protocol_ is the communication protocol in which

$
  cal(M)_i = cal(I)_i quad "and" quad cal(R)_i = A_i := union.big_(I in cal(I)_i) A_I quad quad "for every player" i in [n].
$

In every round, Player $i$ sends a _report_ $hat(I) in cal(I)_i$, read as "my current information set is $hat(I)$". The mediator replies with a _recommendation_ $hat(a)$, read as "play $hat(a)$". We require every mediator strategy in the direct protocol to recommend a legal action at the reported information set, that is, $hat(a) in A_(hat(I))$. Since an information set encodes everything the player knows, reporting $I$ means revealing all of one's private information. The player does not need to repeat the past recommendations, because the mediator already knows them. We write $hat(Pi)_i$ and $hat(P)_upright(M)$ for the pure strategies of Player $i$ and of the mediator in the direct protocol.

#definition[Direct strategy][
  The _direct strategy_ $x_i^*$ of Player $i$ is the pure strategy that reports honestly and obeys:
  $
    phi_(i)^*(I_1, hat(a)_1, ..., I_k) = I_k, quad quad alpha_(i)^*(I_1, hat(a)_1, ..., I_k, hat(a)_k) = hat(a)_k.
  $
  The direct profile is $x^* = (x_1^*, ..., x_n^*)$.
] <def-l11-rp-direct-strategy>

The rule $alpha_i^*$ is well defined on every history that $x_i^*$ can produce. After an honest report of $I_k$, the recommendation $hat(a)_k$ lies in $A_(I_k)$, so obeying is always feasible. Note also that $x^*$ does not depend on the mediator. It is fixed by the structure of the direct protocol alone.

#definition[Direct communication equilibrium #citep(<Zhang2026Mechanism>, [slide 28])][
  A _direct communication equilibrium_ is a (possibly randomized) mediator strategy $hat(mu) in Delta(hat(P)_upright(M))$ in the direct protocol such that, for every player $i in [n]$, the direct strategy is a best response when all other players are direct:
  $
    u_(i)(hat(mu), x_i^*, x_(-i)^*) = max_(x'_i in Delta(hat(Pi)_i)) u_(i)(hat(mu), x'_i, x_(-i)^*).
  $
  Equivalently, $(hat(mu), x_1^*, ..., x_n^*)$ is a communication equilibrium of the direct protocol. That is, $x^*$ is a Nash equilibrium of the players when $hat(mu)$ is held fixed.
] <def-l11-rp-direct-ce>

The maximum may be written as "$>=$", because the choice $x'_i = x_i^*$ already attains the left-hand side. The deviations $x'_i$ range over all strategies of Player $i$ in the direct protocol. Each one may combine two kinds of departure, and it may choose them adaptively as play unfolds.

- _Misreporting_: sending $hat(I)_k != I_k$. The constraints that rule this out are _honesty_ constraints.
- _Disobeying_: playing an action other than $hat(a)_k$. The constraints that rule this out are _obedience_ constraints.

The introductory examples are special cases of this pattern. In a correlated equilibrium, players have no private information to report, so only obedience matters. In the mechanism design example, buyers report valuations, so honesty is the central requirement. In information design, the buyer must obey a recommendation from a better-informed seller. In each case, the optimal solution was a mediator strategy such that, holding it fixed, the direct profile is a Nash equilibrium. Since $x^*$ is a constant, the only unknown in @def-l11-rp-direct-ce is $hat(mu)$. Later sections exploit this.

== Statement of the revelation principle <sec-l11-rp-statement>

#theorem[Revelation principle #citep(<Forges1986Approach>, <ZhangSandholm2022Mediator>)][
  Let $Gamma$ be a finite extensive-form game in which all players have perfect recall. Consider any communication protocol and any communication equilibrium $(mu, x_1, ..., x_n)$ of it. Then there exists a direct communication equilibrium $hat(mu)$ such that $(hat(mu), x^*)$ and $(mu, x)$ induce the same probability distribution over terminal histories $Z$. In particular,
  $
    u_(i)(hat(mu), x^*) = u_(i)(mu, x) quad forall i in [n], quad quad u_(upright(M))(hat(mu), x^*) = u_(upright(M))(mu, x).
  $
] <thm-l11-revelation-principle>

The converse holds trivially. A direct communication equilibrium is a communication equilibrium of one particular protocol. The two notions therefore produce exactly the same set of outcome distributions. This gives the use of the theorem in the lecture.

#corollary[
  The best mediator objective over all protocols and all communication equilibria equals the best objective over direct communication equilibria:
  $
    sup_("protocols," (mu, x) "comm. eq.") u_(upright(M))(mu, x) = max_(hat(mu) "direct comm. eq.") u_(upright(M))(hat(mu), x^*).
  $
] <cor-l11-rp-optimal>

#proof[
  By @thm-l11-revelation-principle, every value on the left is attained on the right. By the converse, every value on the right appears on the left. It remains to see that the maximum on the right exists. The direct protocol has finitely many messages, so $hat(P)_upright(M)$ and each $hat(Pi)_i$ are finite. Utilities are linear in each strategy, so a profitable deviation exists exactly when a profitable pure deviation exists. The direct communication equilibria are therefore the distributions $hat(mu)$ satisfying the finitely many linear inequalities $u_(i)(hat(mu), x^*) >= u_(i)(hat(mu), pi'_i, x_(-i)^*)$ for $pi'_i in hat(Pi)_i$. This set is a polytope. It is nonempty. A Nash equilibrium of $Gamma$ exists. Let the mediator always send one fixed message, and let the players ignore all messages and play that Nash equilibrium. Messages then carry no information, so this is a communication equilibrium, and the theorem converts it into a direct one. A linear objective attains its maximum on a nonempty polytope.
]

#paragraph-marker() *Assumptions.*~~ The result relies on the assumptions built into the model.

- _Commitment._ The mediator commits to $hat(mu)$, and the players believe it. The proof uses this in an essential way, because the new mediator promises to run a computation faithfully on the players' behalf.
- _Communication._ Messages are private, costless and payoff-irrelevant. Each player talks only to the mediator, and a round precedes each of its moves.
- _Perfect recall._ It makes an information set a complete report of what a player knows.
- _Equilibrium notion._ Incentives are Nash conditions with the mediator held fixed. Only unilateral deviations by players are considered, and the mediator has no incentive constraint.

#paragraph-marker() *What is and is not preserved.*~~ The transformation preserves the distribution over terminal histories. Hence it preserves every player's expected utility and any mediator objective that depends only on the outcome $z$. It does not preserve the messages themselves or the amount of information exchanged. In the direct protocol, players reveal all of their private information. The lecture noted that this can matter for reasons outside the model, such as privacy, or a failure of trust in the mediator's commitment.

#paragraph-marker() *Formal statement versus intuition.*~~ Informally, the theorem says that "honesty and obedience are without loss of generality". Formally, it is an existence and equivalence statement about outcome distributions. It does not claim that every communication equilibrium is direct, or that the direct equilibrium is unique. It also differs from the classical revelation principle of one-shot mechanism design, where players report types once and the mechanism selects the outcome. Here, reports and recommendations are interleaved with play over many rounds, and the players still choose their own actions in the game.

#example[Ascending auction and second-price auction][
  The lecture gave an informal illustration. In an ascending clock auction, a price rises continuously and each buyer decides when to drop out. The auction ends when one buyer remains, who pays the current price. When valuations are private, one equilibrium has each buyer drop out once the price reaches their value. The winner is then the buyer with the highest value, and the price equals the second-highest value. The direct version asks every buyer for their value and simulates the clock on their behalf. This is exactly the second-price auction, and it produces the same outcome. The two formats still differ in what is communicated. In the ascending auction, the winner never reveals their value. In the second-price auction, everyone does.
] <ex-l11-rp-auction>

== Proof sketch <sec-l11-rp-proof>

The idea, as presented in class, is a _simulation argument_. The new mediator runs the original equilibrium internally and performs on behalf of each player the computations that the player's original strategy would have performed. It uses two transformations.

+ _Reports._ In the original equilibrium, the message a player sends is some function $f$ of its private information. For example, a buyer with value \$6k bids $f(\$6"k")$. In the direct equilibrium, the player reports its information honestly. The mediator commits to computing $f$ itself and acting as if it had received $f(\$6"k")$ #citep(<Zhang2026Mechanism>, [slide 20]).
+ _Recommendations._ In the original equilibrium, the mediator sends an arbitrary message $m$, and the player converts it into an action $a = f(m)$. In the direct equilibrium, the mediator computes $a = f(m)$ itself and simply recommends $a$ #citep(<Zhang2026Mechanism>, [slide 21]).

In class, $f$ was written as a function of the current observation or message only, and the lecture called this a benign simplification. Below, the rules $phi_i$ and $alpha_i$ take the player's whole history as input, which makes the simulation exact.

#proofsketch[
  Fix a communication equilibrium $(mu, x_1, ..., x_n)$ of an arbitrary protocol $(cal(M)_i, cal(R)_i)_(i in [n])$.

  #paragraph-marker() *Step 1: constructing the direct mediator.*~~ The mediator strategy $hat(mu)$ works as follows. Before play starts, it privately samples $rho ~ mu$ and $pi_i = (phi_i, alpha_i) ~ x_i$ for every player $i$, all independently. It then keeps a simulated copy of the original interaction. Suppose that in the $t$-th round overall, Player $i = j_t$ is in its $k$-th round and reports $hat(I)_k$. The mediator does three things.
  + It computes the message that $pi_i$ would have sent, $m_k = phi_(i)(hat(I)_1, r_1, ..., hat(I)_(k-1), r_(k-1), hat(I)_k)$, where $r_1, ..., r_(k-1)$ are the simulated replies to Player $i$ in its earlier rounds.
  + It feeds $m_k$ to the simulated original mediator and obtains the simulated reply $r_k = rho((j_1, m'_1), ..., (j_t, m'_t))$. Here $m'_s$ is the simulated message of round $s$, so $m'_t = m_k$.
  + It recommends $hat(a)_k = alpha_(i)(hat(I)_1, r_1, ..., hat(I)_k, r_k)$, the action that $pi_i$ would have played after receiving $r_k$.
  The simulated replies $r_k$ are never sent to anyone. Since $alpha_i$ outputs an action in $A_(hat(I)_k)$, the recommendation is legal at the reported information set, so $hat(mu)$ is a valid mediator strategy in the direct protocol.

  #paragraph-marker() *Step 2: the outcome is preserved.*~~ Couple the two interactions by using the same draws of $rho$, of each $pi_i$, and of chance. Suppose all players follow $x^*$ against $hat(mu)$. We claim the two interactions follow the same path in $Gamma$. We argue by induction over the rounds. Assume the paths agree up to some round. Then the acting player is at the same information set $I_k$ in both. It reports $hat(I)_k = I_k$ honestly, so the simulated message $m_k$ equals the message $pi_i$ actually sends in the original interaction. The simulated mediator has received exactly the same tagged messages as the real one, so the simulated reply $r_k$ equals the real reply. The recommendation $hat(a)_k$ is therefore exactly the action $pi_i$ plays in the original interaction, and the obedient player plays it. Chance moves agree by the coupling. Hence the paths agree after this round too. Since the paths agree for every draw, the distributions over $Z$ coincide. This proves the outcome part of the theorem.

  #paragraph-marker() *Step 3: no profitable deviation.*~~ Suppose, for contradiction, that some Player $i$ has a profitable deviation against $hat(mu)$ when the others are direct. Utilities are linear in Player $i$'s strategy, so we may take it to be a pure strategy $hat(pi)'_i = (hat(phi)'_i, hat(alpha)'_i) in hat(Pi)_i$ with
  $
    u_(i)(hat(mu), hat(pi)'_i, x_(-i)^*) > u_(i)(hat(mu), x^*).
  $
  We build a deviation $x'_i$ in the original protocol. Player $i$ privately samples $pi_i = (phi_i, alpha_i) ~ x_i$ and then runs the direct deviation in its head. At its $k$-th round, it is at its true information set $I_k$ and has received real replies $r_1, ..., r_(k-1)$ from $mu$.
  + It computes the report the deviation would make, $hat(I)_k = hat(phi)'_(i)(I_1, hat(a)_1, ..., I_k)$, where the $hat(a)_s$ are the virtual recommendations computed in earlier rounds.
  + It sends the message $phi_(i)(hat(I)_1, r_1, ..., hat(I)_k)$, the message its original strategy would have sent at the reported information set. In the auction picture, it bids $f(\$4"k")$ instead of $f(\$6"k")$.
  + After receiving $r_k$, it computes the virtual recommendation $hat(a)_k = alpha_(i)(hat(I)_1, r_1, ..., hat(I)_k, r_k)$.
  + It plays $hat(alpha)'_(i)(I_1, hat(a)_1, ..., I_k, hat(a)_k)$, which is what the deviation does when recommended $hat(a)_k$. In the lecture's notation, this is $g(f(m))$ in place of $g(a)$.

  The same coupling argument as in Step 2 applies. The players $j != i$ are direct against $hat(mu)$, which simulates $pi_j$ exactly, so they behave as $pi_j$ does in the original protocol. Player $i$'s real messages equal the simulated messages inside $hat(mu)$. The real mediator $rho$ therefore sees the same inputs and sends the same replies. Every action taken by every player is the same in both interactions. The only difference is who samples $pi_i$: the mediator in the direct protocol, and the player itself under $x'_i$. In both cases it is an independent draw from $x_i$, so the joint distribution of all random draws is the same. Hence
  $
    u_(i)(mu, x'_i, x_(-i)) = u_(i)(hat(mu), hat(pi)'_i, x_(-i)^*) > u_(i)(hat(mu), x^*) = u_(i)(mu, x),
  $
  where the last equality is Step 2. This contradicts the assumption that $(mu, x)$ is a communication equilibrium. So no profitable deviation exists, and $hat(mu)$ is a direct communication equilibrium.

  #paragraph-marker() *Conclusion.*~~ Steps 1 and 2 show that $hat(mu)$ reproduces the outcome distribution of $(mu, x)$. Step 3 shows that it is a direct communication equilibrium. Together, these give @thm-l11-revelation-principle.
]

The argument maps each deviation in the direct protocol to a deviation in the original protocol with the same payoff. The following table summarizes this correspondence for the two parts of the proof.

#align(center)[#block(breakable: false)[
  #table(
    columns: 3,
    align: (left, left, left),
    inset: 6pt,
    [], [*Original equilibrium*], [*Direct equilibrium*],
    [Equilibrium play], [Sends $f(t)$ for true information $t$. Plays $f(m)$ after message $m$.], [Reports $t$. Mediator acts as if it received $f(t)$ and recommends $a = f(m)$. Player obeys.],
    [Deviation], [Sends $f(t')$. Plays $g(f(m))$.], [Reports $t'$. Plays $g(a)$ after recommendation $a$.],
  )
]]

Within each row, the two columns lead to the same outcome distribution. So any gain from deviating in the direct column is also a gain in the original column.

The revelation principle completes Step 1 of the proof of the main theorem. The search over communication equilibria with arbitrary, possibly infinite message spaces reduces to a search over mediator strategies in the direct protocol. That protocol is a finite game. It is still very large, however, because the mediator's strategy can depend on the entire sequence of reports. The next section shows how to shrink it to polynomial size.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
