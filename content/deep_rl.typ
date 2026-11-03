#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 9,
  date: [Thu, Oct 15, 2026],
  title: "Multiagent deep RL",
  instructor: [Prof. Gabriele Farina (`gfarina@mit.edu`)],
)

In this lecture, 

= Deep Game Theory Algorithms <sec-game-theory-algorithms>

= Game Theory-ifying Part 1 <sec-game-theory-pt1>

= Game Theory-ifying Part 2 <sec-game-theory-pt2>

= Game Theory-ifying Part 3 <sec-game-theory-pt3>

= Stratego and Ataraxos Case Study <sec-ataraxos>
Stratego is a two-player zero-sum board game played on a $10$ by $10$ grid. Each player has $10$ unique pieces ordered by the "strength" of the piece, $2$ unique special pieces with certain effects, and $40$ pieces total. Before starting play, the players secretly arranges these pieces on their side of the board. Their opponent can see the location of the pieces, but not the type of the piece. 

Players then alternate moving one piece at a time (with a few exceptions, these pieces
can only move one square horizontally and vertically). When a player moves a piece into a square occupied by an opponent, the identity of those pieces are revealed and the weaker piece is removed (both are removed when the ranks of the pieces are equal; there's some intricacy with the two special pieces). A player wins when they capture their opponents flag. 



#example[A game of Stratego][
  To make Stratego more concrete, we've adapted a game from Figure 2 of #citep(<Sokota26:Scalable>).

  #align(center)[
    #image("figures/deep_rl/stratego.svg", width: 100%)
  ]
] <ex:stratego>

The important thing about Stratego is the size of its #lecture-link("efg_intro", <sec-game-trees>)[information sets]. There are over $10^33$ possible arrangements for the opponent's starting position, and the information set contains one history for each arrangement #citep(<Sokota26:Scalable>)! As a point of comparison, in Texas hold'em, your opponent has $1225$ possible hands at the start. Moreover, the size of the game tree in Stratego has $10^535$ nodes, compared to $10^164$ in no-limit Texas hold'em #citep(<Perolat22:Mastering>). As a result, to make a superhuman AI for Stratego without just throwing absurd amounts of compute at the problem, we need to employ some of the concepts we learned this lecture.

== Stratego AI in 2022
Before 2022, Stratego was one of the last _famous_ board games without expert-level AI. DeepNash #citep(<Perolat22:Mastering>) by DeepMind was the first Stratego AI to reach human expert level. It uses Regularized Nash Dynamics (R-NaD) and self-play. Essentially R-NaD changes the reward function by adding a term that penalizes drift from reference policy we set. This regularization term aids convergence to an approximate Nash equilibrium (instead of just cycling around it). We run R-NaD until it converges onto a fixed point, and update the reward function with the new fixed point as the reference policy. 

// here we can write the algorithm for R-NaD if necessary, but I don't think it is really essential here (?) 

For this case study, we should explictly note that training DeepNash was insanely expensive. It trained on $1024$ TPUs (v3) for 2-3 months; this would cost approximately between $\$3$ million and $\$4.5$ million at 2025 API pricing. It used approximately $5.5$ billion games of Stratego in its training data and between $5\-10$ trillion training examples. At the conclusion of training, DeepNash won 42 out of 50 ranked games on an online Stratego server called Gravon, ultimately reaching rank three on the leaderboard. At the 2023 World Championship, it tallied 19 wins and 9 losses, losing to most of its highest-ranked opponents.

== Ataraxos <sec-ataraxos-agent>

Ataraxos #citep(<Sokota26:Scalable>) is a Stratego AI that combines self-play reinforcement learning with decision-time planning (DTP). We'll look into the design of Ataraxos and then the training itself to see what's special about it. 

// do we talk about PPO?

== Design and Implementation

Ataraxos has four main parts: a policy over the entire setup that helps construct the setup that we play, a belief network that refines our estimates about hidden pieces based on the board position, a behavioral policy that estimates the value of certain moves, and DTP to refine our behavioral policy.


*Setup network:* Ataraxos uses a decoder-only transformer to place our $40$ pieces autoregressively during setup time. This network also outputs estimates of the entropy of the setup and the probabilities of winning, drawing, and losing. These values are important because Ataraxos is trained to win, and also trained with some amount of unpredictability. We can perform training on this network because we can estimate the probabilities via averaging the final outcome of games from the corresponding starting position, and we can estimate the entropy also via Monte Carlo.

#figure(
  caption: [Setup Network; taken from #citep(<Sokota26:Scalable>)],
)[
  #image("figures/deep_rl/ataraxos_ed1_setup.png", width: 100%)
] <fig-ataraxos-setup-network>

*Move network:* An encoder-only transformer takes a token per valid board position and a fixed value token for value prediction. A move is simply a tuple consisting of a source square and a destination square. The move network outputs logits for each possible move and a win, draw, loss probability for the corresponding position. For training the logits, only moves with a large estimated advantage are kept, and we estimate the advantage of such moves via generalized advantage estimation. For training the probabilities, we use TD$(lambda)$. 

#figure(
  caption: [Move Network; taken from #citep(<Sokota26:Scalable>)],
)[
  #image("figures/deep_rl/ataraxos_ed1_move.png", width: 100%)
] <fig-ataraxos-move-network>

*Belief network:* After training the setup network and move network, Ataraxos plays games against itself to train the belief network. The belief network is an encoder-decoder transformer that reads the board positions and generates guesses for the opponent's pieces. During training, the true type of the pieces are known, so this is simply supervised learning on board states.
#figure(
  caption: [Belief Network; taken from #citep(<Sokota26:Scalable>)],
)[
  #image("figures/deep_rl/ataraxos_ed4_belief.png", width: 100%)
] <fig-ataraxos-belief>

*Decision-time Planning:* We use the belief network to generate complete boards on which Ataraxos can actually simulate moves. This allows us to search deeper into the tree of possible outcomes can perform DTP by using the belief network. It allows Ataraxos to sample complete boards on which to run the moves and evaluate expected rewards (with this sampled "complete" information). Ataraxos searches 40-ply deep, with 1000 rollouts per move. 


== Back to the Present! <sec-ataraxos-relation>


// kveni12 PR where they talk about REINFORCE is important here
Hopefully this doesn't come as a surprise, but we've actually studied many of the components that make Ataraxos effective. Ataraxos simply uses the techniques that scale well with compute, instead of building in additional structure.


*Behavioral policies:* Ataraxos takes advantage of the hidden concavity we discussed earlier. However, if a policy never reaches a decision point, it never receives a gradient. As a result, if we add a bit of entropy at a decision point, the regularized utility now becomes strongly concave in sequence form. The regularlized utility satisfies the P\u{141} condition. This guarantees the gradient ascent condition that we discussed earlier. 


*Training:* Ataraxos performs gradient ascent on the regularized objective
$
  J(theta) = EE_(tau ~ pi_theta) [R(tau)] - alpha sum_j Pr[j] dot "KL"(pi_theta (dot bar.v j) || rho(dot bar.v j))
$
where $R(tau)$ is the outcome of the game, $rho$ is a magnet policy (which is a uniform distribution over all of the moves), $Pr[j]$ is the probability of reaching decision point $j$, and the same network plays both seats. We cannot compute $nabla J$ exactly, so we use REINFORCE, refined with a learned critic. Ataraxos spends its compute on the parts of the game tree that strong play actually reaches. It also only trains on moves with a large estimated advantage, since moves whose value is close to the average barely contribute to the gradient.


*Regularization:* At each iteration, the move network maximizes a function that roughly resembles PPO. There also exists a reverse KL term, which represents a regularization toward the magnet policy, and a second reverse KL term that limits how far a single step can move from the policy that collected the data. The fact that these are reverse KL terms means that the magnet term is exactly an entropy bonus (when the magnet is uniform), the second term keeps each update from moving probability onto moves the training data says little about, and together they give the form of a magnetic mirror descent step. This regularization is strongest at the start of training and annealed toward zero over time. 


Hopefully, you have realized that we've talked about many of these things before, but if you haven't, it might be a good idea to go review some previous lectures. 

== Results

Ataraxos is the first agent to be superhuman at Stratego! It won against Pim Niemeijer, who is the most decorated Stratego player of all time (more than $600$ weeks at rank 1). Ataraxos went $15-1-4$ against Pim. Interesting, Pim could adapt to Ataraxos, the first ten games going $9-1-0$ to Ataraxos, and the next ten going $6-0-4$ to Ataraxos. In another test, Ataraxos went $38-2-0$ in the 2025 World Championship. 

In total, reinforcement learning took a week on $16$ H100s, and the belief network took four days on $4$ H100s. This cost less than $\$8,000$ at 2025 cloud prices. It used about $160$ million self-play games and $50$ billion training examples, meaning it took around 
 $1\/500$ of the compute, $1\/30$ of the self-play games, and $1\/100$ of the training examples compared to DeepNash.

= Further Modifications and Take-aways <sec-modifications>


#lec_bibliography("meta/refs.bib")