#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Section: Introduction -- (MD) Mechanism design.
// Drafted with assistance from Claude for exposition, Typst, and figures.

= Mechanism design <sec-l11-mechanism-design>

#paragraph-marker() *Setup.*~~ An auctioneer sells a car to two buyers and wants to maximize expected revenue, but does not know how much the buyers value the car. Buyer $i$ privately knows its value $v_i ~ D_i$, drawn independently, and reports $v'_i in RR$, possibly lying. The auctioneer commits to a _mechanism_ mapping reports to a winner $i^* in {bot, 1, 2}$ and a price $p$. If $i^* = bot$, everyone gets $0$; otherwise $u_A = p$, $u_(i^*) = v_(i^*) - p$, and the other buyer gets $0$. The _direct_ strategy of buyer $i$ is to report truthfully, $v'_i = v_i$.

#theorem[Myerson's optimal auction #citep(<Myerson1981Feb>)][
  If values are i.i.d. from a regular distribution $D$ (CDF $F$, density $f$, with virtual value $phi(v) := v - (1 - F(v)) \/ f(v)$ nondecreasing), then among mechanisms in which truthful reporting is an equilibrium and participation is voluntary, revenue is maximized by the _second-price auction with reserve $r := phi^(-1)(0)$_: nobody wins if every report is below $r$; otherwise the highest bidder wins and pays $max {"second-highest report", r}$.
]

The virtual value $phi(v)$ is the revenue the auctioneer can extract at a buyer of value $v$, so it should sell only where this is nonnegative, and to the buyer with the highest one. For values uniform on $[0, 10]$ (in \$k), $phi(v) = 2 v - 10$ and $r = 5$, so with bids $6$ and $4$, Buyer 1 wins and pays $5$. Truthful reporting is optimal: with $t := max {v'_(-i), r}$, buyer $i$ wins iff $v'_i > t$ and then pays $t$, so reporting $v_i$ wins exactly when winning is profitable.

#paragraph-marker() *Extensive form.*~~ Below, values are $2$ or $6$ with probability $1 \/ 2$ each, and the auctioneer commits to the second-price auction with reserve $6$ (ties broken at random), which appears only through the payoffs $(u_A, u_1, u_2)$. Each buyer reports knowing only its own value. Bold edges mark the direct strategies, which give revenue $4.5$, versus $3$ without a reserve. Reserve $6$ is optimal here: a reserve $r in (2, 6]$ sells exactly when some buyer has value $6$ (probability $3 \/ 4$) and gives revenue $r \/ 2 + 3 \/ 2$, which is largest at $r = 6$, whereas $r <= 2$ gives only $3$. To read the tree, nature draws the pair of values at the root; Buyer 1 then reports, and Buyer 2 reports without seeing Buyer 1's report, which is why its decision nodes are grouped. Each leaf lists the resulting payoffs, and in every information set the bold edge, reporting the true value, is a best response.

#figure(
  image("figures/info_design_mechanism/auction_tree.svg", width: 100%,
    alt: "Nature draws the two buyers' values, each 2 or 6. Buyer 1 reports knowing only its own value, then Buyer 2 reports knowing only its own value. Leaves list the auctioneer's and buyers' payoffs under the second-price auction with reserve 6."),
  caption: [The auction as an extensive-form game. Dashed regions are the buyers'
    information sets, and bold edges mark truthful reports.],
) <fig-l11-auction>

#paragraph-marker() *Connection to the common theme.*~~ An optimal mechanism is a strategy for the auctioneer such that, holding it fixed, the direct profile is a Nash equilibrium for the buyers. That restricting to direct mechanisms loses nothing is the revelation principle, discussed later.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
