#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 16,
  date: [Tue, Nov 10, 2026],
  title: "High-dimensional games",
  instructor: [Prof. Constantinos Daskalakis (`costis@mit.edu`)],
)

Extensive-form games belong to a larger class of games that we will call _combinatorial games_. Two properties characterize the representation we use:

- For each player $i$, the deterministic strategies form a nonempty set $V_i subset.eq {0,1}^(d_i)$ of bit strings.
- Each player's utility is a multilinear function of these strategy vectors.

Write $X_i = "conv"(V_i)$. A distribution $vlambda_i in Delta(V_i)$ induces a mean strategy $vx_i = sum_(vv in V_i) lambda_(i)(vv) vv in X_i$. By multilinearity, when the players randomize independently, their expected utilities depend only on these means. Thus we can work in dimension $d_i$, even when the number of deterministic strategies $|V_i|$ is exponentially larger.

The central question of this lecture is whether #lecture-link("learning1", <sec-mwu>)[multiplicative weights] can also exploit this compact representation. We follow the kernelization approach of #citet(<Farina22:Kernelized>).

= Examples of combinatorial games

Normal-form and extensive-form games are both examples. Resource allocation, paths, and fixed-size subsets provide other useful strategy spaces.

== Normal-form games

If Player $i$ has $d_i$ actions, represent action $k$ by the unit vector $ve_k in {0,1}^(d_i)$. Then
$ V_i = {ve_1, ..., ve_(d_i)}, quad X_i = Delta(d_i). $
The mean of a distribution over these vectors is exactly the usual mixed strategy. Expected utility is multilinear in the players' mixed strategies, so this is a combinatorial-game representation. Here $|V_i|=d_i$: the number of strategies and their encoding dimension coincide.

== Extensive-form games

In a finite perfect-recall extensive-form game, utility is multilinear in the players' #lecture-link("efg_intro", <sec-sequence-form>)[sequence-form strategies]. The vertices of a player's sequence-form polytope have entries in ${0,1}$. They describe _reduced pure realization plans_: choices below an unselected own action have realization weight zero. Different full contingency plans can therefore represent the same vertex.

#example[Sequence-form vertices][
  In the game below, black nodes belong to Player 1 and white nodes to Player 2. Player 1 observes the move at $P$, but not the move at $Q$: the two nodes in information set $D$ require the same action. The nine numbered actions give the coordinates of Player 1's realization plan.
  #figure(
    caption: [An extensive-form game. Repeated labels 7, 8, and 9 belong to one information set and therefore one set of sequence coordinates.],
  )[
    #image(
      "figures/kernelized/tree.svg",
      width: 6cm,
      alt: "A two-player game with nine sequence coordinates for Player 1, separate continuations B and C after the left root action, and one shared information set D after the right root action.",
    )
  ]
  The seven reduced pure realization plans are shown next. Choosing root action 1 leaves two independent binary choices at $B$ and $C$, giving four vertices. Choosing root action 2 leaves a three-way choice at $D$, giving three more. Blue edges indicate the coordinates equal to one.
]

#figure(
  caption: [The seven binary vertices of Player 1's sequence-form polytope, shown as reduced pure realization plans. See also the #lecture-link("efg_intro", <sec-strategic-form>)[reduced normal-form plans in the modeling notes].],
)[
  #image(
    "figures/efg_intro/nf_strategies.svg",
    width: 100%,
    alt: "Seven pure realization plans separated by gray grid lines, with selected sequences highlighted in blue: 101010000, 101001000, 100110000, 100101000, 010000100, 010000010, and 010000001.",
  )
]

#remark[Number of strategies versus dimension][
  If $I_i$ is the set of Player $i$'s information sets and $A_i$ is the largest number of actions at one of them, then
  $ |V_i| <= product_(I in I_i) |A(I)| <= A_i^(|I_i|). $
  In contrast, the encoding dimension is $d_i = sum_(I in I_i) |A(I)|$, omitting the empty sequence, whose realization weight is always one. An exponential number of vertices can fit in a representation of size linear in the game tree.
]

== Resource allocation games

In resource allocation games such as Colonel Blotto, a player distributes an integer budget $R$ among $B$ activities or battlefields. Use a table with one row per battlefield and columns indexed by $s=0,...,R$. Set $v_(j,s)=1$ exactly when battlefield $j$ receives $s$ units. The valid bit strings satisfy
$ sum_(s=0)^R v_(j,s)=1 quad (j=1,...,B), quad sum_(j=1)^B sum_(s=0)^R s v_(j,s)=R. $
Thus $d=B(R+1)$. There are $binom(R+B-1, B-1)$ possible allocations, which can be much larger than $d$.

For the usual additive battlefield utilities, each battlefield's payoff depends on the allocations to that battlefield. Its expectation is multilinear in the players' one-hot vectors, and summing over battlefields preserves multilinearity. The representation is polynomial in the budget _value_ $R$; it need not be polynomial in the length of a binary encoding of $R$.

== Games on graphs

A path in a directed acyclic graph can be represented by its edge-indicator vector: $v_e=1$ exactly when the path uses edge $e$. Fix a source and destination with at least one connecting path. The dimension is the number of edges, although there may be exponentially many paths.

Edge-additive interaction payoffs can be multilinear in these indicators. For example, the weighted overlap of two players' paths is $sum_e c_e v_(1,e) v_(2,e)$. We will use the acyclic structure to evaluate the corresponding kernel efficiently.

== Games on fixed-size subsets

If a player selects exactly $m$ of $d$ objects, use the set
$ V = {vv in {0,1}^d : sum_(k=1)^d v_k=m}, quad 0 <= m <= d. $
These strategies are often called _$m$-sets_. There are $binom(d, m)$ of them. Their indicator vectors again give a compact representation for games with multilinear selection payoffs. If the cardinality restriction is removed, the strategy set is the entire hypercube ${0,1}^d$.

= Learning in combinatorial games and kernelization <sec-kernelization>

One way to learn over $X_i$ is projected gradient descent, provided projections onto $X_i$ can be computed efficiently. But the choice of learning algorithm also affects regret. For normal-form games with coordinate payoffs in $[-1,1]$, the standard Euclidean analysis gives an $O(sqrt(d_i T))$ bound, whereas MWU gives $O(sqrt(T log d_i))$. The geometry used by MWU yields a substantially better dependence on the number of actions.

#lecture-link("learning2", <sec-optimism>)[Optimistic MWU] provides another motivation. In suitable self-play settings, optimism improves the dependence on the number of rounds; those guarantees require their own payoff and learning-rate hypotheses. An exact implementation on combinatorial strategies transfers the corresponding normal-form guarantees under the same hypotheses. Here we concentrate on how to obtain that implementation.

== Multiplicative weights on deterministic strategies

Fix one player and drop the player index. Against fixed opponents, write the utility as $u(vx)=ip(vg, vx)$, where $vg in RR^d$ is its gradient. We assume this gradient can be computed efficiently from the opponents' mean strategies. This is an assumption on the payoff representation, separate from having a compact strategy space.

We can run MWU on the simplex $Delta(V)$ by maintaining a weight for each deterministic strategy. The vector we play is the expectation of that distribution. We call this algorithm _vertex MWU_; replacing the observed gradient by an optimistic correction gives vertex OMWU.

#pseudocode-list(
  max-width: true,
  numbered-title: [Vertex MWU/OMWU],
  caption: [Vertex MWU/OMWU. Both the expectation and the weight update appear to require enumerating all vertices.],
)[
  + Initialize $vlambda_1$ uniformly on $V$, set $vg_0=0$, and set $t=1$.
  + *function* `NextStrategy()`:
    + Return $vx_t=sum_(vv in V) lambda_(t)(vv)vv$.
  + *function* `ObserveUtility`$(vg_t)$:
    + Set $vh_t=vg_t$ (MWU) or $vh_t=2vg_t-vg_(t-1)$ (OMWU).
    + For every $vv in V$, set $lambda_(t+1)(vv) prop lambda_(t)(vv) exp(eta ip(vh_t, vv))$.
    + Normalize the weights to sum to one, then increment $t$.
] <algo:vertex-mwu>

The regret of the played means is exactly the regret of these distributions over vertices, since $ip(vg_t, vx_t)=sum_vv lambda_(t)(vv) ip(vg_t, vv)$. The comparator can be any point of $X$: a linear function attains its maximum at a vertex.

For ordinary MWU with fixed $eta>0$ and $|ip(vg_t, vv)|<=M$ for every $t,vv$, where $M>0$, the usual exponential-weights analysis gives
$ "Reg"_T <= frac(log |V|, eta) + frac(eta M^2 T, 2). $
For $|V|>1$, choosing $eta=sqrt(frac(2 log |V|, M^2 T))$ gives $"Reg"_T <= M sqrt(2T log |V|)$. If $|V|=1$, regret is zero. This is the ordinary MWU bound; the optimistic update has a separate analysis.

#proofsketch[
  Let $W_t=sum_vv exp(eta sum_(tau<t) ip(vg_tau, vv))$. The log moment-generating-function bound for a variable in $[-M,M]$ gives
  $ log(W_(t+1)/W_t) <= eta ip(vg_t, vx_t)+frac(eta^2 M^2, 2). $
  Sum over $t$, use $W_1=|V|$, and lower bound $W_(T+1)$ by the exponential weight of the best vertex.
]

== Main result

An explicit implementation of @algo:vertex-mwu uses time and storage proportional to $|V|$. The main result replaces this dependence by evaluations of a function determined by the combinatorial structure of $V$.

#block(breakable: false)[
  #theorem[Kernelization][
    There is a kernel $K_V:RR^d times RR^d -> RR$ such that each round of vertex MWU or OMWU can be implemented using $d+1$ evaluations of $K_V$, together with $O(d)$ scalar operations and $O(d)$ stored coordinates. The implementation produces exactly the same mean strategies under exact arithmetic. The kernel evaluator's own time and workspace, and the cost of obtaining the gradient, are additional.
  ] <thm:kernelization>
]

We call the implementation _kernelized MWU_ (KMWU) or _kernelized OMWU_ (KOMWU). The theorem does not assert that every binary strategy set has an efficient kernel. Instead, it reduces efficient learning to a concrete computational question about $V$.

#corollary[
  If $K_V$ can be evaluated efficiently, then vertex MWU/OMWU can be simulated efficiently even when $|V|$ is exponential in $d$.
]

The next three subsections prove @thm:kernelization: first define the kernel, then encode the entire weight vector implicitly, and finally recover its expectation.

== The 0/1-polyhedral kernel

#definition[0/1-polyhedral feature map][
  For $vz in RR^d$, define the vector $phi_(V)(vz) in RR^V$ by
  $ phi_(V)(vz)_vv = product_(k:v_k=1) z_k quad (vv in V). $
  An empty product is one. Each coordinate of the feature map is a monomial corresponding to one binary strategy.
]

The feature map may have exponentially many coordinates. We introduce it to describe the computation, without constructing it explicitly.

#definition[0/1-polyhedral kernel][
  The kernel is the inner product of two feature maps:
  $ K_(V)(vz,vw)=ip(phi_(V)(vz), phi_(V)(vw))=sum_(vv in V) product_(k:v_k=1) z_k w_k. $
]

For the hypercube, for instance, this sum includes one monomial for each subset of coordinates. Its apparent exponential size will disappear when we factor it in the final section.

== Keeping track of the distribution over vertices

The update in @algo:vertex-mwu adds a linear score to the exponent of each vertex's weight. Those scores can be stored in just $d$ coordinates.

#block(breakable: false)[
  #theorem[Implicit weights][
    Let $vh_t=vg_t$ for MWU and $vh_t=2vg_t-vg_(t-1)$ for OMWU. Define, coordinatewise,
    $ b_(t,k)=exp(eta sum_(tau=1)^(t-1) h_(tau,k)). $
    At every round, the distribution maintained by vertex MWU/OMWU satisfies $lambda_(t)(vv) prop phi_(V)(vb_t)_vv$.
  ] <thm:implicit-weights>
]

#proof[
  We induct on $t$. Initially $vb_1=vone$, so every coordinate of $phi_(V)(vb_1)$ equals one, giving the uniform distribution.

  For the inductive step, the binary entries of $vv$ imply
  $ exp(eta ip(vh_t, vv))=product_(k:v_k=1) exp(eta h_(t,k)). $
  Substituting the inductive hypothesis in the vertex update yields
  $
    lambda_(t+1)(vv) & prop phi_(V)(vb_t)_vv exp(eta ip(vh_t, vv)) \
                    & = product_(k:v_k=1) (b_(t,k) exp(eta h_(t,k))) \
                    & = phi_(V)(vb_(t+1))_vv.
  $
  This proves the claim for both choices of $vh_t$.
]

In particular, we can update the implicit weights using only
$ b_(t+1,k)=b_(t,k) exp(eta h_(t,k)) quad (k=1,...,d). $
There is no need to sum the entire gradient history at each round.

#corollary[Normalization][
  The exact distribution over vertices is
  $ lambda_(t)(vv)=frac(phi_(V)(vb_t)_vv, K_(V)(vb_t,vone)). $
]
#proof[
  Since $phi_(V)(vone)_vv=1$ for every vertex, the sum of the unnormalized weights is
  $ sum_(vv in V) phi_(V)(vb_t)_vv=ip(phi_(V)(vb_t), phi_(V)(vone))=K_(V)(vb_t,vone). $
  This quantity is positive because $V$ is nonempty and all coordinates of $vb_t$ are positive.
]

== Reconstructing the expectation

Encoding the distribution is only half the task. `NextStrategy()` must also recover its mean without enumerating the vertices. The following identity supplies that step, extending the path-kernel idea of #citet(<Takimoto03:Path>).

#theorem[Recovering the mean][
  For each $k$, let $overline(ve)_k=vone-ve_k$, the vector with a zero in coordinate $k$ and ones elsewhere. Then
  $ x_(t,k)=sum_(vv in V) lambda_(t)(vv)v_k=1-frac(K_(V)(vb_t,overline(ve)_k), K_(V)(vb_t,vone)). $
  The same denominator is used for every coordinate, so $d+1$ kernel evaluations recover the entire mean.
] <thm:kernel-mean>

#proof[
  A monomial survives the zero in coordinate $k$ exactly when its vertex has $v_k=0$. Thus
  $ phi_(V)(overline(ve)_k)_vv=cases(0 & "if" v_k=1, 1 & "if" v_k=0)=1-v_k. $
  It follows that
  $
    K_(V)(vb_t,overline(ve)_k) & = sum_(vv:v_k=0) phi_(V)(vb_t)_vv \
                             & = K_(V)(vb_t,vone) sum_(vv:v_k=0) lambda_(t)(vv).
  $
  Dividing by the normalizer gives the probability that coordinate $k$ is zero. Its complement is the expected value of that binary coordinate.
]

Together, @thm:implicit-weights and @thm:kernel-mean prove @thm:kernelization. Maintain $vb_t$, evaluate one common normalizer and $d$ coordinate-exclusion kernels, return the resulting mean, and update $vb_t$ after observing the gradient. No explicit vector indexed by $V$ is needed.

= Examples of efficiently computable kernels

We now turn the abstract reduction into algorithms for the strategy sets introduced above. It is convenient to write $q_k=z_k w_k$ and
$ Z(vq)=sum_(vv in V) product_(k:v_k=1) q_k, quad K_(V)(vz,vw)=Z(vq). $
The recurrences below evaluate the kernel for arbitrary real inputs. When $vq=vb_t>0$, $Z(vq)$ is also the normalizing partition function of the learning distribution.

== Hypercube

For $V={0,1}^d$, each coordinate is either absent from a monomial or contributes $q_k$. Distributing the product gives
$ K_(V)(vz,vw)=product_(k=1)^d (1+z_k w_k). $
The kernel takes $O(d)$ arithmetic operations to evaluate. For positive weights, the mean has the particularly simple form $x_k=b_k/(1+b_k)$.

== Multiple choices: m-sets

For subsets of size $m$, the kernel is the coefficient of $gamma^m$ in
$ product_(k=1)^d (1+gamma z_k w_k). $
Each choice of $m$ factors contributes exactly the monomial for that subset. Let $E_(j,r)$ be the coefficient of $gamma^r$ after the first $j$ factors. Then
$ E_(j,r)=E_(j-1,r)+q_j E_(j-1,r-1). $
Initialize $E_(0,0)=1$ and all invalid entries to zero. Only degrees through $m$ are needed, so this dynamic program evaluates $K_(V)(vz,vw)=E_(d,m)$ in $O(d(m+1))$ operations. The recurrence separates subsets that omit object $j$ from those that include it.

== Paths in a directed acyclic graph

For a directed acyclic graph $G=(N,E)$, let $Z_u$ be the sum of products of edge weights over all paths from node $u$ to the destination. In reverse topological order, compute
$ Z_"destination"=1, quad Z_u=sum_(e=(u,v)) q_e Z_v quad (u != "destination"). $
The kernel is $Z_"source"$. The empty path at the destination contributes one; outgoing edges of the destination are ignored. A node with no route to the destination contributes zero.

Every source-to-destination path has a unique first edge, which proves the recurrence. Evaluating it takes $O(|N|+|E|)$ operations. This is the path-kernel setting studied by #citet(<Takimoto03:Path>); acyclicity is what makes this single backward pass sufficient.

== Resource allocations

For the one-hot allocation representation, let $F_(j)(r)$ be the total weight of allocations of $r$ units to the first $j$ battlefields. With $q_(j,s)=z_(j,s)w_(j,s)$, the recurrence is
$ F_(0)(0)=1, quad F_(0)(r)=0 quad (r>0), $
$ F_(j)(r)=sum_(s=0)^r q_(j,s) F_(j-1)(r-s). $
The last battlefield receives $s$ units and contributes $q_(j,s)$; the preceding battlefields receive the remaining $r-s$ units. Consequently $K_(V)(vz,vw)=F_(B)(R)$. The computation uses $O(B(R+1)^2)$ operations, polynomial in the size of the one-hot representation.

== Extensive-form games

We finish with the sequence-form polytope. Besides evaluating one kernel in linear time, we will share computation across the $d+1$ evaluations to implement an entire learning round in linear time.

Fix a player in a finite perfect-recall game. Let $I$ range over this player's information sets, with action set $A(I)$. Coordinate $I a$ is the sequence ending in action $a$ at $I$. Perfect recall gives $I$ a unique preceding own sequence $p(I)$.

Let $C(I,a)$ contain the information sets whose preceding sequence is $I a$, and let $R$ contain the information sets whose preceding sequence is empty. Different members of $C(I,a)$ correspond to different observations; a pure realization plan specifies a continuation in _all_ of them. The sequence-form constraints are
$ sum_(a in A(I)) x_(I a)=x_(p(I)), quad x_(I a)>=0, quad x_∅=1. $
We omit the fixed empty-sequence coordinate from the kernel. For a subtree rooted at $I$, let $V_I$ be its reduced pure continuation plans _conditional on the preceding sequence being selected_. Each plan chooses one action at $I$, specifies continuations below that action, and puts zero on branches below unselected actions.

#paragraph-marker() *One kernel evaluation.*~~ Define the partial kernel
$ K_(I)(vz,vw)=sum_(vv in V_I) product_(k:v_k=1) z_k w_k. $
Conditional continuation plans are essential here: an unconditional projection of all full-game vertices could also contain the all-zero vector from plans that never reach $I$.

#theorem[Sequence-form kernel recurrence][
  For any $vz,vw in RR^d$, the partial kernels satisfy
  $ K_(I)(vz,vw)=sum_(a in A(I)) (z_(I a)w_(I a) product_(J in C(I,a)) K_(J)(vz,vw)), $
  and the full kernel is
  $ K_(V)(vz,vw)=product_(I in R) K_(I)(vz,vw). $
  These recurrences evaluate the kernel in linear time in the sequence-form representation.
] <thm:sequence-kernel>
#proof[
  A continuation plan at $I$ selects exactly one action $a$. Conditional on that choice, the continuation plans at the information sets in $C(I,a)$ can be chosen independently. Their monomial weights multiply, along with the selected coordinate $z_(I a)w_(I a)$. Summing over actions gives $K_I$. The plans at distinct roots can also be chosen independently, yielding the product for $K_V$.

  Evaluate information sets from descendants to ancestors. Each action and parent-child incidence is processed a constant number of times, so the total arithmetic cost is linear.
]

#remark[
  The child set depends on the chosen action: it is $C(I,a)$. Multiplying by every descendant of $I$ regardless of $a$ would count choices on branches that the player's own action has ruled out.
]

Using this linear-time evaluator independently for each of the $d+1$ kernels already gives a polynomial-time implementation of vertex MWU/OMWU. It would, however, cost $O(d^2)$ per round. The special relationship among the required evaluations allows a faster implementation.

#paragraph-marker() *A whole iteration in linear time.*~~ Set $vz=vb_t$ and $vw=vone$. A backward pass computes and stores
$ B_(I a)=b_(t,I a) product_(J in C(I,a)) Z_J, quad Z_I=sum_(a in A(I)) B_(I a). $
Here $Z_I=K_(I)(vb_t,vone)$ and the total normalizer is $product_(I in R)Z_I$. All these weights are positive. The conditional probability of selecting action $a$, given the preceding sequence, is $B_(I a)/Z_I$.

A forward pass starts with $x_(t,∅)=1$ and visits information sets from ancestors to descendants, setting
$ x_(t,I a)=x_(t,p(I)) frac(B_(I a), Z_I). $
Every child information set in $C(I,a)$ inherits the same preceding-sequence realization weight $x_(t,I a)$. We do not divide that weight among observations. The product decomposition used in @thm:sequence-kernel proves that these are exactly the coordinate marginals of $vlambda_t$. In particular, $sum_(a in A(I)) x_(t,I a)=x_(t,p(I))$.

The backward and forward passes each take linear time. After observing the gradient, update the $d$ coordinates of $vb_t$ as before. This computes all the expectations required by @algo:vertex-mwu without repeating a separate traversal for each coordinate.

#block(breakable: false)[
  #example[A branch with a continuation][
    At $I$, action $a$ ends the player's decisions, while action $b$ leads to an information set $J$ with actions $c,d$. In coordinates $(a,b,c,d)$, the vertices are
    $ (1,0,0,0), quad (0,1,1,0), quad (0,1,0,1). $
    For weights $(2,3,5,7)$, the backward pass gives $Z_J=5+7=12$ and $Z_I=2+3(5+7)=38$. The forward pass gives
    $ vx=(2/38,36/38,15/38,21/38). $
    In particular, $x_c+x_d=x_b$. Multiplying the continuation factor into both root actions would instead give the incorrect normalizer $(2+3)(5+7)=60$.
  ]
]

#corollary[Linear-time vertex learning in extensive-form games][
  For each player, vertex MWU/OMWU can be implemented exactly with arithmetic cost linear in that player's sequence-form representation per round, beyond the cost of computing the payoff gradient. Its regret and equilibrium-convergence guarantees transfer under the corresponding assumptions of the vertex algorithm.
]

This recovers learning over the reduced normal-form strategies without explicitly constructing that normal-form game. It is a different update from CFR, which combines local regret minimizers. The advantage here is that results about the vertex learning dynamics can be used directly.

The exact identities above use real arithmetic. In an implementation, logarithms and log-sum-exp prevent overflow in the positive weights; a finite-precision guarantee must also account for rounding error.

#lec_bibliography("meta/refs.bib")
