#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 17,
  date: [Thu, Nov 12, 2026],
  title: "Nonconvex games",
  instructor: [Weiqiang Zheng],
)

= Unilateral stability and coordinated deviations <sec-l17-coordinated-deviations>

Can both players gain by moving together from a Nash equilibrium? Let
$x, y in [-1, 1]$ be the two players' actions and give both players the payoff
$
  u(x, y) = 3 x y - x^2 - y^2 + (x^4 + y^4) / 2.
$
The game is smooth and nonconcave in each player's own action. For example,
the second derivative with respect to $x$ is $-2 + 6 x^2$, which is positive
near either endpoint.

*Unilateral moves.* At $(0, 0)$, both players receive zero. If player 1
alone moves to $t != 0$, the payoff change is
$-t^2 + t^4 / 2 <= -t^2 / 2 < 0$. The same holds for player 2 by symmetry,
so $(0, 0)$ is a strict Nash equilibrium. The point mass at $(0, 0)$ is
also an exact local $Phi$-equilibrium for every deviation radius, since each
rule changes only one player's action.

*Coordinated moves.* Both players gain $u(t, t) = t^2 + t^4 > 0$ by moving
to any common nonzero action $t$. The term $3 x y$ vanishes along the axes
and rewards moving together along the diagonal. Since $t$ can be arbitrarily
small, every neighborhood of the equilibrium contains a profile both strictly prefer.

#figure(
  image(
    "figures/l17_coordinated_deviations/payoff_contours.svg",
    width: 240pt,
    alt: "Shared payoff contours over the two action coordinates. From the origin, each axis arrow leads to a loss, and the diagonal arrow leads to a gain.",
  ),
  caption: [
    From the equilibrium at the origin, the dashed arrows show unilateral
    moves that lower the payoff. The solid arrow shows a joint move that raises it.
  ],
) <fig-l17-coordinated-payoff>
