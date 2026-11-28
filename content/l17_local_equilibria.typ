#import "meta/gabri_notes.typ": *
#import "meta/reference-solutions.typ": reference-solutions as disclosure
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games: local equilibria",
  instructor: [Weiqiang Zheng],
)

= Local Nash and local $Phi$-equilibria <sec-l17-local-definitions>

*Action profiles and unilateral deviations.* In a game with $n$ players, let $X_i$ be the set of actions available to player $i$. An _action profile_ is a tuple
$
  x=(x_1,...,x_n) in X, quad X=X_1 times ... times X_n.
$
Each entry records one player's action. The payoff function $u_i:X->RR$ assigns player $i$ a payoff at each profile. Write $x_(-i)$ for the other players' actions. If player $i$ alone changes to $z_i in X_i$, the new profile is $(z_i,x_(-i))$ and their payoff gain is
$
  Delta u_i=u_(i)(z_i,x_(-i))-u_(i)(x).
$
This is a _unilateral deviation_. Only one action changes, although several players' payoffs may change.

*The distance game.* Take $n=2$ and $X_1=X_2=[0,1]$. Let the payoff functions be
$
  u_(1)(x_1,x_2)=(x_1-x_2)^2, quad u_(2)(x_1,x_2)=-(x_1-x_2)^2.
$
The actions are positions on a line. Player 1 wants the positions far apart. Player 2 wants them close together. At $x=(0.5,0.5)$, both receive zero. Take $i=1$ and $z_1=0.7$. Then $x_(-1)$ is Player 2's position, $0.5$, and the general payoff comparison becomes
$
  Delta u_1 = u_(1)(0.7,0.5)-u_(1)(0.5,0.5)
            = (0.7-0.5)^2-(0.5-0.5)^2 = 0.04.
$
Player 1 moves a distance of $0.2$ and gains $0.04$. Player 2 stays at $0.5$ and loses $0.04$.

== Local Nash equilibrium <sec-l17-local-nash-definition>

#definition[Local Nash equilibrium][
  Let $epsilon>=0$ and $delta>0$. A profile $x^star in X$ is an _$(epsilon,delta)$-local Nash equilibrium_ if, for every player $i$ and every $x_i in X_i$ with $norm(x_i-x_i^star)<=delta$,
  $
    u_(i)(x^star) >= u_(i)(x_i,x_(-i)^star)-epsilon.
  $
]

The left side is the current payoff. The right side is the payoff from a feasible nearby move, less the allowed improvement $epsilon$. The radius $delta$ is measured in action space, using Euclidean distance. An _exact local Nash equilibrium_ satisfies the inequality with $epsilon=0$ for some positive radius.

In the distance game, set $x^star=(0.5,0.5)$ and $delta=0.2$. For Player 1, write the alternative as $x_1=0.5+h$, where $abs(h)<=0.2$, and keep $x_2^star=0.5$. Substituting into the definition gives
$
  u_(1)(0.5,0.5) &>= u_(1)(0.5+h,0.5)-epsilon, \
  0 &>= h^2-epsilon.
$
The condition is $epsilon>=h^2$ for *every* allowed $h$. The largest $h^2$ is $0.04$. For Player 2 the same substitution gives $0>=-h^2-epsilon$, which holds even at $epsilon=0$. Combining the two players' conditions, the midpoint is an $(epsilon,0.2)$-local Nash equilibrium exactly when $epsilon>=0.04$. It fails exact local Nash for every positive radius because any sufficiently small nonzero move by Player 1 earns $h^2>0$.

== Local $Phi$-equilibrium <sec-l17-local-phi-definition>

Let $r in Delta(X)$ be a joint distribution on action profiles. First a profile $x$ is drawn from $r$. Each player $i$ privately receives its $i$th entry, $x_i$. A _deviation rule_ $phi$ specifies which action the player would take for each possible recommendation. Two draws that give the player the same recommendation must therefore give the same replacement action.

#definition[Local $Phi$-equilibrium][
  Fix $epsilon>=0$ and $delta>0$. For each player $i$, let $Phi_(i)(delta)$ consist of all measurable rules $phi:X_i->X_i$ such that
  $
    norm(phi(z)-z)<=delta quad "for every" z in X_i.
  $
  A distribution $r$ on $X$ is an _$(epsilon,delta)$-$Phi$-equilibrium_ if, for every player $i$ and every $phi in Phi_(i)(delta)$,
  $
    EE_(x ~ r) [u_(i)(phi(x_i),x_(-i))-u_(i)(x)] <= epsilon.
  $
]

In the first inequality, $z$ is any recommendation the player could receive and $phi(z)$ is the action they would take instead. The radius $delta$ limits the distance between the two actions. In the second inequality, compare the payoffs from playing $phi(x_i)$ and from following $x_i$ on the _same draw_, holding the other players' actions $x_(-i)$ fixed. Average those differences using their probabilities under $r$. A rule may help on some draws and hurt on others. The tolerance $epsilon$ is the largest permitted _average_ gain. At $epsilon=0$, even one rule with positive expected gain violates equilibrium.

There is another way to read the inequality. Fix player $i$. Following the recommendation gives an expected payoff of $EE_(x ~ r)[u_(i)(x)]$. This number is the same whichever deviation rule we are testing. By linearity of expectation, we can move it to the right side of the inequality. We can then compare it with the best expected payoff available across all allowed rules. When a best rule exists, the condition becomes
$
  max_(phi in Phi_(i)(delta)) EE_(x ~ r) [u_(i)(phi(x_i),x_(-i))]
  <= EE_(x ~ r) [u_(i)(x)] + epsilon.
$
The order of the operations matters. For each rule, first compute its average payoff over all draws. Then take the largest of those averages. Choosing the most profitable move separately after seeing each _entire profile_ would give the player information beyond their own recommendation. This order of maximization and averaging is the one in #link("https://arxiv.org/html/2403.08171v4#Thmdefinition1")[Cai et al., Definition 1].

*Substitution in the distance game.* Keep $delta=0.2$ and let $r$ assign probability $1/2$ to each profile $(0.5,0.3)$ and $(0.5,0.7)$. Player 1 receives $x_1=0.5$ in either case. Consider the rule $phi(z)=min{z+0.2,1}$, which moves right by $0.2$ or stops at the boundary. Since $phi(0.5)=0.7$, Player 1 plays $0.7$ in both rows below.

#table(
  columns: (auto, auto, auto, auto), align: center,
  inset: (x: 7pt, y: 4pt), stroke: 0.4pt + luma(175),
  table.header([Player 2's $x_2$], [Follow $x_1=0.5$], [Play $x_1=0.7$], [Gain]),
  [$0.3$], [$0.04$], [$0.16$], [$+0.12$],
  [$0.7$], [$0.04$], [$0$], [$-0.04$],
)
In the first row, moving right increases the distance between the players. In the second, it puts them at the same position. Substituting the two gains and their probabilities into the definition gives
$
  1/2 (0.16-0.04) + 1/2 (0-0.04) = 0.04.
$
This rule violates the inequality for any $epsilon<0.04$. To see whether $epsilon=0.04$ suffices, we must check all allowed rules for both players.

*Player 1 sees the same recommendation twice.* Write $phi(0.5)=0.5+h$, where $abs(h)<=0.2$. A positive $h$ moves Player 1 right and a negative $h$ moves them left. The first row of the table gives the solid blue curve in the left panel of @fig-l17-local-gains. Player 2 is at $0.3$, so a move to the right takes Player 1 farther away. The second row gives the dashed red curve. Player 2 is at $0.7$, so that same move brings Player 1 closer. Substituting each of Player 2's positions into Player 1's payoff gives
$
  x_2=0.3: quad &(0.2+h)^2-0.04 = h^2+0.4h, \
  x_2=0.7: quad &(-0.2+h)^2-0.04 = h^2-0.4h.
$
The two draws are equally likely, so at each $h$ the average of the two gains is $h^2$. The dotted curve shows this average. Its maximum is $0.04$ at $h=plus.minus 0.2$. In expected-payoff terms, following earns $0.04$ and the best rule earns $0.04+0.04=0.08$. Substitution into the maximum formula gives $0.08<=0.04+epsilon$.

*Player 2 can distinguish the draws.* Player 2 receives $0.3$ on one draw and $0.7$ on the other. Both recommendations start $0.2$ from Player 1 at $0.5$. Let $t$ measure how far Player 2 moves _toward_ $0.5$, with $t<0$ indicating a move away. The new action is $0.3+t$ after a recommendation of $0.3$, and $0.7-t$ after a recommendation of $0.7$. In either case the new distance is $0.2-t$ for $-0.2<=t<=0.2$. Subtracting the payoff from following gives
$
  -(0.2-t)^2-(-0.04)=0.4t-t^2.
$
The right panel shows this gain. One curve covers both draws because moving the same distance toward the midpoint gives the same payoff in either case. A rule can choose a different $t$ for each recommendation, but the best choice on each is $t=0.2$. It takes Player 2 from $0.3$ to $0.5$ on one draw and from $0.7$ to $0.5$ on the other.

#figure(
  context {
    let ink = rgb("#252c32")
    let grid-color = rgb("#d4dbe1")
    let solid = 1.5pt + rgb("#175c89")
    let dashed = (paint: rgb("#a34222"), thickness: 1.5pt, dash: "dashed")
    let dotted = (paint: ink, thickness: 1.7pt, dash: "dotted", cap: "round")
    let width = 181pt
    let px(move) = 28pt + (move + 0.2) / 0.4 * 143pt
    let py(gain) = 23pt + (0.12 - gain) / 0.24 * 99pt
    let segment(x1, y1, x2, y2, pen) = place(top + left,
      line(start: (x1, y1), end: (x2, y2), stroke: pen))
    let label(x, y, w, body, position: left, weight: "regular", size: 8pt) = place(top + left, dx: x, dy: y, box(width: w, {
        set align(position)
        text(size: size, weight: weight, body)
      }))
    // The three exact Bézier control ordinates for q·s² + a·s on [-0.2, 0.2].
    let gain-curve(q, a, pen) = place(top + left, curve(
      curve.move((px(-0.2), py(0.04*q - 0.2*a))),
      curve.quad((px(0), py(-0.04*q)), (px(0.2), py(0.04*q + 0.2*a))),
      stroke: pen,
    ))
    let key(y, pen, body) = {
      segment(12pt, y+3pt, 26pt, y+3pt, pen)
      label(31pt, y, 148pt, body)
    }
    let panel(player) = box(width: width, height: 189pt, {
      set text(font: "Source Sans 3", fill: ink)
      label(0pt, 0pt, width, "Player " + str(player) + "’s payoff gain", weight: "bold", size: 10pt)
      for (g, tick) in ((-0.12,"−0.12"),(-0.08,"−0.08"),(-0.04,"−0.04"),
                         (0,"0"),(0.04,"0.04"),(0.08,"0.08"),(0.12,"0.12")) {
        segment(px(-0.2), py(g), px(0.2), py(g), if g==0 {0.7pt + ink} else {0.35pt + grid-color})
        label(0pt, py(g)-2.8pt, 24pt, tick, position: right)
      }
      segment(px(-0.2), py(-0.12), px(-0.2), py(0.12), 0.5pt + ink)
      segment(px(0), py(-0.12), px(0), py(0.12), (paint: grid-color, thickness: 0.5pt, dash: "dashed"))
      for (h, tick) in ((-0.2,"−0.2"),(-0.1,"−0.1"),(0,"0"),(0.1,"0.1"),(0.2,"0.2")) {
        segment(px(h), py(-0.12), px(h), py(-0.12)+2pt, 0.5pt + ink)
        label(px(h)-10pt, 126pt, 20pt, tick, position: center)
      }
      if player == 1 {
        gain-curve(1, 0.4, solid)
        gain-curve(1, -0.4, dashed)
        gain-curve(1, 0, dotted)
        label(20pt, 140pt, 158pt, "Move h (right is positive)", position: center, weight: "bold")
        key(155pt, solid, "Player 2 at 0.3     h² + 0.4h")
        key(166pt, dashed, "Player 2 at 0.7     h² − 0.4h")
        key(177pt, dotted, "Expected gain     h²")
      } else {
        gain-curve(-1, 0.4, solid)
        place(top+left, dx: px(0.2)-2.4pt, dy: py(0.04)-2.4pt,
          circle(radius: 2.4pt, fill: rgb("#175c89")))
        segment(px(0.2)-6pt, py(0.04)-9pt, px(0.2)-1.5pt, py(0.04)-2pt, 0.55pt + ink)
        label(81pt, py(0.04)-18pt, 82pt, "Maximum gain 0.04", position: right, weight: "bold")
        label(20pt, 140pt, 158pt, "Move t (toward 0.5 is positive)", position: center, weight: "bold")
        key(155pt, solid, "Both starting positions     0.4t − t²")
      }
    })
    if target() == "html" {
      let description = (
        "Player 1 always receives 0.5 and makes the same signed move h on both draws. The two conditional gains are h squared plus or minus 0.4h. Their average is h squared, attaining 0.04 at either endpoint.",
        "Player 2 moves t toward 0.5 from either starting position. Both payoff gains equal 0.4t minus t squared. The best gain is 0.04 for t equal to 0.2.",
      )
      html.elem("div", attrs: (style: "display:flex;flex-wrap:wrap;justify-content:center;gap:0.75em;"), {
        for i in (1,2) {
          html.elem("span", attrs: (class: "lecture-image", role: "img", "aria-label": description.at(i - 1)),
            html.frame(panel(i)))
        }
      })
    } else {
      grid(columns: (width,width), gutter: 10pt, panel(1), panel(2))
    }
  },
  caption: [The two profiles are equally likely. Player 1 receives $0.5$ in both and must use the same move $h$. Player 2 observes their own position. Moving $t=0.2$ toward $0.5$ means moving right from $0.3$ and left from $0.7$.],
) <fig-l17-local-gains>

At that choice Player 2 earns $0$, an improvement of $0.04$ over following. Both players' largest expected gain is $0.04$, so $r$ is an $(epsilon,0.2)$-$Phi$-equilibrium exactly when $epsilon>=0.04$.

Neither recommended profile is itself a $(0.04,0.2)$-local Nash equilibrium. At either fixed profile, Player 1 can move $0.2$ away from Player 2 and gain $0.4^2-0.2^2=0.12$. This requires moving right at the first profile and left at the second. Player 1's recommendation alone cannot distinguish them. If a distribution puts all its probability on a single profile, the two tests coincide because every feasible nearby move at that profile can be made by a local rule.

== Why the error scales as $L delta^2$ <sec-l17-local-curvature>

Assume each action set is convex and each payoff is differentiable with an $L$-Lipschitz gradient in its player's own action. For a move $h=z_i-x_i$ with $norm(h)<=delta$, smoothness gives
$
  abs(Delta u_i-ip(nabla_(x_i) u_(i)(x),h)) <= L/2 norm(h)^2 <= L delta^2/2.
$
The inner product is the gain predicted by the gradient at the starting point. To see where the factor $1/2$ comes from, follow the straight line from $x_i$ to $z_i$. At a fraction $t$ of the way, the gradient has changed by at most $L t norm(h)$. Integrating its effect on the payoff from $t=0$ to $1$ gives $L norm(h)^2/2$.

For Player 1 in the distance game, $h=z_1-x_1$, the starting slope is $2(x_1-x_2)$, and $L=2$ because a displacement $h$ changes the slope by $2h$. Expanding the actual payoff gain gives
$
  u_(1)(x_1+h,x_2)-u_(1)(x_1,x_2)=2(x_1-x_2)h+h^2.
$
Subtracting the predicted gain $2(x_1-x_2)h$ leaves exactly $h^2$. With $x_1=x_2=0.5$, $h=0.2$, and $delta=0.2$, the slope is zero and the error equals the full bound, $L delta^2/2=2(0.2)^2/2=0.04$. Under the two-point recommendation, the slopes $+0.4$ and $-0.4$ cancel in expectation, leaving the same quadratic gain.

The bound also holds after averaging over recommendations. If every allowed rule has expected linear gain at most $alpha$, its expected payoff gain is at most $alpha+L delta^2/2$. For $epsilon>L delta^2/2$, it suffices to bring the linear gain down to $epsilon-L delta^2/2$. Below the bound, even a zero linear gain can conceal an improvement larger than $epsilon$. See #link("https://arxiv.org/html/2403.08171v4#Thmlemma1")[Cai et al., Lemma 1 and Appendix C].

With nonempty compact convex action sets and continuously differentiable payoffs satisfying this smoothness assumption, a stationary profile exists. At such a profile every player's feasible linear gain is nonpositive, so it is an $(L delta^2/2,delta)$-local Nash equilibrium. See #link("https://arxiv.org/html/2403.08171v4#A1.SS0.SSS0.Px2")[Cai et al., Appendix A].

== Computational hardness <sec-l17-local-hardness>

For some restricted families of rules, efficient algorithms control expected linear gain. When the tolerance leaves room for curvature, the smoothness bound converts this into a guarantee on expected payoff. See #link("https://arxiv.org/html/2403.08171v4#S4")[Cai et al., Section 4].

=== Computing an equilibrium distribution <sec-l17-clique-proof>

For the full family of local rules, even a smooth single-player game can encode a hard problem. #link("https://arxiv.org/html/2403.08171v4#Thmtheorem7")[Cai et al., Theorem 7] gives games in dimension $d$ with $L=2d$ for which a polynomial-time equilibrium algorithm would imply P = NP whenever
$ 0<delta<=1, quad 0<epsilon<=delta^2/(16d^2). $

#disclosure(title: [Proof of NP-hardness for equilibrium distributions], proof[
  A _clique_ is a set of vertices in a graph in which every pair is connected. Let $omega$ be the size of the largest clique in a graph with $d$ vertices and adjacency matrix $A$. For an integer $1<=k<=d$, give the player a nonnegative vector $x$ with $norm(x)_1<=1$ and payoff
  $
    f_(k)(x)=x^T A x-(1-1/k) norm(x)_1^2.
  $
  The #link("https://doi.org/10.4153/CJM-1965-053-6")[Motzkin–Straus theorem] gives
  $ max_(p>=0, norm(p)_1=1) p^T A p=1-1/omega. $
  To see why, choose a maximizer that assigns positive weight to as few vertices as possible. If two of those vertices are unconnected, moving weight between them changes the objective linearly. Putting their combined weight at one endpoint preserves the maximum and removes a vertex. Hence the positive weights lie on a clique. On a clique of size $m$, the objective equals $1-sum_j p_j^2<=1-1/m$. Uniform weights on a largest clique attain $1-1/omega$.

  Thus the best payoff on the face $norm(p)_1=1$ is $c=1/k-1/omega$, attained at some $p^star$. If $k!=omega$, then $abs(c)=abs(omega-k)/(k omega)>1/d^2$. The quadratic satisfies $f_(k)(t x)=t^2 f_(k)(x)$ and has smoothness bound $2d$ (#link("https://arxiv.org/html/2403.08171v4#Thmlemma3")[Lemma 3]).

  Write $tau=delta/2$ and $eta=delta^2/(16d^2)$. Consider the event $S={x : norm(x)_1<=tau}$. We show that the sign of $c$ forces an equilibrium to put most of its probability on one side of this threshold.

  - If $k>omega$, then $c<0$. Take an action with $t=norm(x)_1>=tau$. Shrink it to $(1-tau/t)x$, a move of Euclidean length at most $tau$. Since $f_(k)(x)<=c t^2$, the gain is at least $abs(c)(2t tau-tau^2)>=abs(c)tau^2>2eta$.
  - If $k<omega$, then $c>0$. Take $x in S$. Both $2x$ and $tau p^star$ are feasible and within distance $delta$ of $x$, since $2 tau=delta<=1$. If $f_(k)(x)>2eta$, doubling $x$ gains $3 f_(k)(x)>2eta$. Otherwise switching to $tau p^star$ gains $tau^2 c-f_(k)(x)>4eta-2eta=2eta$.

  In each case a single rule can make the indicated move on the entire set of profitable actions and follow the recommendation elsewhere. If the set had probability at least $1/2$, the rule would gain more than $eta$ on average, which violates the definition when $epsilon<=eta$. Thus an equilibrium puts *less than half* its mass in $S$ when $k<omega$, and *more than half* there when $k>omega$. This is the probability test behind #link("https://arxiv.org/html/2403.08171v4#Thmlemma4")[Lemma 4 and Theorem 7].

  To decide whether a given graph contains a clique of size $s$, take two copies of the graph and connect every vertex in one copy to every vertex in the other. The largest clique now has twice its original size. Set $k=2s-1$ in the game for this new graph, using its vertex count for $d$. The new clique number is even, so equality with $k$ is impossible. It exceeds $k$ exactly when the original graph has a clique of size at least $s$. Reading the probability of $S$ from the returned equilibrium would therefore decide the NP-complete Clique problem in polynomial time.

  The theorem's second bound follows by substitution. For a positive polynomial factor $g$ in the game parameters and $b>0$, choosing $delta$ so that $g delta^b<=1/(16d^2)$ gives $g delta^(2+b)<=delta^2/(16d^2)$. An algorithm attaining that tolerance on all such instances would solve the same problem.
])

=== Computing a constrained local min-max equilibrium <sec-l17-minmax-proof>

In #link("https://arxiv.org/pdf/2009.09623")[#emph[The Complexity of Constrained Min-Max Optimization]], Daskalakis, Skoulakis, and Zampetakis study a two-player zero-sum game. The first player chooses $x$ to minimize $f(x,y)$ and the second chooses $y$ to maximize it. Joint linear constraints require $(x,y)$ to belong to a nonempty rational polytope $K$ inside the unit cube. A move from $x$ to $x'$ is feasible only if $(x',y) in K$. The feasible moves for $y$ depend on $x$ in the same way.

Suppose $f$ is bounded, $G$-Lipschitz, and $L$-smooth, and its value and gradient can be computed to a requested precision in polynomial time. #link("https://arxiv.org/pdf/2009.09623#page=19")[Theorem 4.3] establishes existence and membership in PPAD for $L delta^2/2<epsilon$. #link("https://arxiv.org/pdf/2009.09623#page=19")[Theorem 4.4] establishes PPAD-hardness in the part of that regime where $epsilon<=L delta^2$. In this overlap the problem is PPAD-complete. A polynomial-time solver for these games would also give a polynomial-time solver for the approximate Brouwer fixed-point problem. The paper uses a strict payoff-gain bound. The slack in the existence argument below gives this stricter guarantee.

#disclosure(title: [Proof of existence and PPAD membership], proof[
  *Existence and membership in PPAD.* Write $z=(x,y)$ and let $s=(-nabla_x f(z),nabla_y f(z))$ point in each player's preferred direction. Let $Pi_K$ denote Euclidean projection onto $K$ and set $T(z)=Pi_(K)(z+s)$. This continuous map takes $K$ into itself, so Brouwer's theorem gives a fixed point. At a fixed point, the projection inequality gives $ip(s,w-z)<=0$ for every feasible $w$. Taking $w=(x',y)$ or $w=(x,y')$ shows that every feasible unilateral move has nonpositive linear gain. By smoothness its actual gain is at most $L delta^2/2<epsilon$.

  For a computation with finite precision, put $e=T(z)-z$ and let $h$ be any feasible unilateral move with $norm(h)<=delta$. The projection inequality is $ip(s-e,h-e)<=0$. Expanding it and using $norm(s)<=G$ gives
  $
    ip(s,h) <= ip(s,e)+ip(e,h)-norm(e)^2 <= (G+delta) norm(e).
  $
  The actual gain is therefore at most $(G+delta)norm(e)+L delta^2/2$. A fixed-point residual smaller than $(epsilon-L delta^2/2)/(G+delta)$ suffices. Projection is nonexpansive and computable to the required precision on a rational polytope. Thus $T$ is efficiently evaluable and $(1+L)$-Lipschitz. The approximate Brouwer problem belongs to PPAD (#link("https://arxiv.org/pdf/2009.09623#page=13")[Lemma 2.5]). To use its cube formulation, extend $T$ by first projecting the input onto $K$. Projecting an approximate fixed point of the extension onto $K$ can only decrease its residual, since the image is already in $K$.
])

#disclosure(title: [Proof of PPAD-hardness for constrained equilibria], proof[
  *PPAD-hardness.* The starting problem is a grid whose vertices carry one sign, $+1$ or $-1$, for each coordinate. The prescribed signs point into the cube at each boundary face. A solution is a single grid cell containing both signs in every coordinate, or a vertex violating a boundary sign condition. Finding such a solution is PPAD-hard (#link("https://arxiv.org/pdf/2009.09623#page=35")[Theorems 7.1–7.2]). We show how a local equilibrium solver would locate it.

  Write $C_(j)(v)$ for the sign at vertex $v$ in coordinate $j$. The paper supplies smooth weights $P_(v)(x)$ that average the nearby vertex labels. The weights are nonnegative and sum to one. Construct a game on $x,y in [0,1]^d$ with joint constraints $abs(x_j-y_j)<=Delta$ and payoff
  $
    a_(j)(x)=-sum_v P_(v)(x) C_(j)(v), quad
    f(x,y)=sum_(j=1)^d (x_j-y_j)a_(j)(x).
  $
  #link("https://arxiv.org/pdf/2009.09623#page=38")[Lemma 7.5 and Theorem 7.6] bound the smoothness of this payoff and give a polynomial-time procedure to evaluate it and its gradient.

  To see how the game encodes a grid cell, suppose all contributing vertices in an interior cell have sign $-1$ in coordinate $j$. Then $a_(j)(x)=1$ and $partial_(y_j) f=-1$. Differentiating with respect to $x_j$ also gives a main term of $1$. The choice of strip width $Delta$ bounds the sum of the remaining terms in magnitude by $1/2$. Thus lowering $x_j$ helps the minimizer and lowering $y_j$ helps the maximizer. If the strip blocks one move, it leaves room for the other. Reversing all signs reverses these directions. #link("https://arxiv.org/pdf/2009.09623#page=40")[Lemmas 7.7–7.8] give the following quantitative implication. Whenever the two separately projected gradient steps have combined length below $alpha=Delta/3$, the active vertices reveal both signs in every coordinate or a violated boundary condition. The construction lists these vertices in polynomial time.

  It remains to show that a local equilibrium produces steps short enough for this test. For either player let $s_i$ be their signed gradient, and let $d_i$ be the displacement obtained by projecting their gradient step onto their feasible set with the opponent fixed. Put $rho=norm(d_i)$. Projection gives $ip(s_i,d_i)>=rho^2$. If $rho>=delta$, convexity allows the shorter move $delta d_i/rho$. Smoothness bounds its gain from below by $delta rho-L delta^2/2$. At equilibrium this implies
  $
    rho <= epsilon/delta + L delta/2.
  $
  Choose $delta_0=alpha/(5L+2)$ and $epsilon=L delta_0^2$. At radius $delta_0$, the displayed bound gives $rho<=3L delta_0/2<alpha/2$ whenever $rho>=delta_0$. If $rho<delta_0$, the same conclusion follows from $delta_0<=alpha/2$. Both players' steps are therefore short enough to decode the grid solution. Any equilibrium at the same tolerance and a larger radius also passes the test at $delta_0$. The width $Delta$ and hence the fixed-point accuracy $alpha$ are inverse-polynomial, while $G$ and $L$ are polynomially bounded. The reduction therefore has polynomial size and proves hardness for $sqrt(epsilon/L)<=delta<sqrt(2epsilon/L)$. The interpolation and boundary lemmas used in this reduction are proved in #link("https://arxiv.org/pdf/2009.09623#page=33")[Sections 7–8 and Appendices C–D].
])

== References <sec-l17-local-references>

- Constantinos Daskalakis, #link("https://www.mit.edu/~6.7980/nfgs_nash.html#sec-normal-form")[Setting and equilibria: the Nash equilibrium]. MIT 6.7980, §1.1.
- Weiqiang Zheng, #link("https://www.mit.edu/~6.7980/slides/L17_nonconvex_games.pdf")[Nonconvex Games]. MIT 6.7980, Lecture 17, pp. 2–5. The distance game's action sets and payoffs appear on p. 2. The numerical radius, two-point distribution, and figure are chosen for these notes.
- Yang Cai, Constantinos Daskalakis, Haipeng Luo, Chen-Yu Wei, and Weiqiang Zheng, #link("https://arxiv.org/html/2403.08171v4")[On Tractable $Phi$-Equilibria in Non-Concave Games], arXiv v4. Appendix B.1, #link("https://arxiv.org/html/2403.08171v4#Thmexample4")[Example 4], studies the same payoff functions on $[-1,1]$.
- Constantinos Daskalakis, Stratis Skoulakis, and Manolis Zampetakis, #link("https://arxiv.org/abs/2009.09623")[The Complexity of Constrained Min-Max Optimization], STOC 2021, Theorems 4.3–4.4.

#changelog[
  - 2026-11-17: Alfredo Celedon Fuentes wrote the definitions, worked examples, two-player figure, and explanations of the curvature bound and hardness proofs. ChatGPT assisted with drafting, checking the mathematics and references, and preparing the Typst source.
]
