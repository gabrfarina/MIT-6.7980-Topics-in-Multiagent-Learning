// Standalone L12 supplement for integration after the team belief DAG construction.
// Codex assisted with drafting, editing, and verification.

#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  date: [Tue, Oct 27, 2026],
  title: "A public signal in an adversarial parity game",
  instructor: [Brian Hu Zhang],
)

An adversary chooses two bits $(x,y)$. Alice sees $x$ and Bob sees $y$. Before either teammate acts, chance independently reveals $x$ to both with probability $r$. Write $s = x$ if the bit is revealed and $s = bot$ otherwise. Alice and Bob then choose bits $a$ and $b$ simultaneously. They win if $a xor b = x y$, where $xor$ denotes exclusive OR. The winning predicate comes from the classical CHSH game (#link("https://arxiv.org/abs/quant-ph/0404076")[Cleve, Høyer, Toner, and Watrous, §3.1]).

The adversary sees the committed team strategy before choosing $(x,y)$. It cannot see the teammates’ random draws. The teammates can sample their coins before play, independently of the inputs and the reveal. Let $v_"ind"(r)$ be the maximum worst-case win probability with independent private randomization, and let $v_"cor"(r)$ be the corresponding value when a shared random draw is also allowed.

#theorem[
  For every reveal probability $r in [0,1]$,
  $ v_"ind"(r) = (1+r)/2, quad v_"cor"(r) = (3+r)/4. $
]

= When the bit is hidden

Assume $r < 1$ so the hidden branch has positive probability.

*Independent strategies.* Write $u_x = EE[(-1)^a | x, s = bot]$, and $w_y = EE[(-1)^b | y, s = bot]$. Independence gives
$ Pr("win" | x,y,s=bot) = (1 + (-1)^(x y) u_x w_y)/2. $
If every input pair had win probability strictly greater than $1/2$, then $u_0 w_0$, $u_0 w_1$, and $u_1 w_0$ would be positive and $u_1 w_1$ would be negative. This is impossible: $(u_0 w_0)(u_1 w_1) = (u_0 w_1)(u_1 w_0)$. One input pair therefore holds the team to at most $1/2$. Alice can guarantee $1/2$ on every input by outputting a fair private coin.

#block(breakable: false)[
*Correlated strategies.* Fix a deterministic joint plan with outputs $a_0,a_1,b_0,b_1$. XORing the four winning equations gives $0=1$ because each output bit occurs twice, and only $(1,1)$ requires odd parity. Each plan thus wins on at most three inputs. Any mixture wins with probability at most $3/4$ under uniform inputs, so at least one input holds it to $3/4$ or less.
]

The team can meet the bound on *every* input. Choose a row of @tbl-parity-plans uniformly before playing. For any input pair, exactly one row loses.

#figure(
  table(
    columns: 3,
    align: center,
    table.header([Losing input $(x,y)$], [Alice's $(a_0,a_1)$], [Bob's $(b_0,b_1)$]),
    [$(0,0)$], [$(0,1)$], [$(1,0)$],
    [$(0,1)$], [$(0,0)$], [$(0,1)$],
    [$(1,0)$], [$(0,1)$], [$(0,0)$],
    [$(1,1)$], [$(0,0)$], [$(0,0)$],
  ),
  caption: [Four joint plans with different losing inputs.],
) <tbl-parity-plans>

= When the bit is revealed

For either strategy class, Alice can choose $a=0$ and Bob can choose $b=s y$, winning surely whenever $s$ reveals $x$. The hidden-branch upper bound is witnessed by some input pair, and the reveal probability is the same for every input pair. Thus the adversary can hold the team to at most $r$ plus $(1-r)$ times the hidden-branch bound. The strategies above attain this upper bound on every input pair, proving the formulas. At $r=1$ only the revealed branch is reached, so both values are $1$.

In team belief DAG terms, the null signal leads to a belief containing all four input pairs. A revealed bit leads to a belief containing the two pairs with that first bit. The team's prescription then maps Bob's private input $y$ to $s y$. Shared randomness instead selects a joint prescription without narrowing the set of possible inputs. The resulting value gap is $(1-r)/4$.

#exercise[
  With no reveal, allow arbitrary finite input sets and specify a target bit $c_(x y)$ for each allowed pair $(x,y)$. Form a bipartite graph with these pairs as edges labeled by their target bits. Prove that the team can win surely exactly when the labels XOR to zero on every cycle. What if one input pair is removed from the original four-input game?
]

#solution[
  A sure win requires a deterministic plan that wins on every edge, since any plan used with positive probability must win on each edge. A plan assigns bits to vertices whose endpoint XOR must equal each edge label. XORing around any cycle cancels every vertex bit. Conversely, in each component fix a root bit and propagate along a spanning tree. Each remaining edge closes a cycle, so its label agrees with the assigned bits. Removing any edge from the four-input game leaves a tree. The row in @tbl-parity-plans that loses on the removed input gives a sure win.
]
