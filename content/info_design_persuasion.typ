#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Section: Introduction -- (MD) Information design.
// Drafted with assistance from Claude for exposition, Typst, and figures.

= Information design <sec-l11-information-design>

Information design, also called _Bayesian persuasion_ #citep(<Kamenica2011Oct>), is mechanism design in reverse: now the party that commits holds the private information, and the other player acts.

#paragraph-marker() *Setup.*~~ A car is on sale for \$5k. It is good (worth \$6k to the buyer) with probability $1 \/ 3$ and bad (worth \$4k) with probability $2 \/ 3$, and only the seller knows which. The buyer buys (B) or passes (P). If the buyer buys, the seller gets $5$ and the buyer gets $1$ for a good car or $-1$ for a bad one (in \$k); if the buyer passes, both get $0$. The seller commits in advance to a _signaling scheme_: it tells the buyer "buy" with probability $q_g$ if the car is good and $q_b$ if it is bad, and "pass" otherwise. The buyer sees the message, updates its belief by Bayes' rule, and acts.

#paragraph-marker() *Benchmarks.*~~ With no information, buying yields $1 \/ 3 dot.op 1 - 2 \/ 3 dot.op 1 = -1 \/ 3 < 0$, so the buyer never buys and the seller gets $0$. Revealing the quality sells only good cars, giving the seller $5 \/ 3$.

#paragraph-marker() *Optimal scheme.*~~ The seller maximizes $5 (q_g \/ 3 + 2 q_b \/ 3)$, the probability of a sale times the price, subject to the buyer obeying each message:
$
  q_g \/ 3 - 2 q_b \/ 3 >= 0 #h(1em) ("buy" "on" "buy"), #h(2em) (1 - q_g) \/ 3 - 2 (1 - q_b) \/ 3 <= 0 #h(1em) ("pass" "on" "pass").
$
The second constraint is implied by the first, which reads $q_g >= 2 q_b$. The objective increases in both $q_g$ and $q_b$, so the best choice is $q_g = 1$, the largest value allowed, and then $q_b = q_g \/ 2$, the most the first constraint permits. The optimum is $q_g = 1$ and $q_b = 1 \/ 2$: the seller always says "buy" for a good car, and says "buy" half the time for a bad car. After "buy", the car is good with probability $(1 \/ 3) \/ (1 \/ 3 + 1 \/ 3) = 1 \/ 2$, so the buyer is (weakly) willing to buy; after "pass", the car is surely bad. Even though the car is good only $1 \/ 3$ of the time, it sells $2 \/ 3$ of the time, for revenue $10 \/ 3$. The seller pools just enough bad cars with the good ones to leave the buyer exactly indifferent after "buy", which is the most persuasion the buyer's incentives allow; revealing everything is strictly worse, and revealing nothing sells nothing.

#paragraph-marker() *Extensive form.*~~ In the tree below, nature draws the quality, the seller sends a recommendation according to its scheme, and the buyer, who sees only the recommendation, decides. The buyer's two information sets group the nodes with the same recommendation, so after "buy" it cannot tell the good car from the bad one. The leaves list (seller, buyer) payoffs. Bold edges mark the optimal scheme and the buyer's direct strategy of following the recommendation.

#figure(
  image("figures/info_design_persuasion/persuasion_tree.svg", width: 85%,
    alt: "Nature draws a good car with probability 1/3 or a bad car with probability 2/3. The seller then recommends buy or pass, saying buy always for a good car and half the time for a bad car. The buyer sees only the recommendation and chooses to buy or pass, with seller and buyer payoffs at the leaves."),
  caption: [The persuasion game. Dashed regions are the buyer's information
    sets, and bold edges mark the optimal scheme and obedience.],
) <fig-l11-persuasion>

#paragraph-marker() *Connection to the common theme.*~~ The optimal scheme is a strategy for the seller such that, holding it fixed, the direct strategy is a best response for the buyer, and among such strategies it maximizes the seller's expected utility.

= Bibliography for this lecture
#lec_bibliography("meta/refs.bib", title: none)
