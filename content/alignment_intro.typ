#import "meta/gabri_notes.typ": *
#import "meta/note-status.typ": note-status
#show: gabri_notes.with(
  lec_num: 13,
  date: [Thu, Nov 5, 2026],
  title: "Alignment (part I)",
  instructor: [Natalie Collina],
)

// Tasks 12 and 13. Insert before the section on modeling alignment.
= Introduction to alignment <sec-alignment-intro>

In the prior sections, we made significant progress in improving prediction accuracy by having the two parties repeatedly exchange their predictions and update them. In the repeated, perfectly conversation-calibrated setting, the two parties $epsilon$-agree on all but a $delta$ fraction of days within a number of rounds that depends only on $epsilon$ and $delta$. Moreover, the final predictions are at least as accurate as either party's initial predictions alone, in the sense that their total squared error summed over the days is no larger. (This need not hold on each individual day.)

However, this rests on an assumption: that both parties (the human and the AI model) are optimizing for the same objective. Let's consider an example where this is not true.

#example[A model funded by a drug maker][
  Returning to the lecture's drug-prescription example, suppose the doctor asks a model funded by J&J, “Which medication should I prescribe?” In this hypothetical case, its training data indicates that Pfizer's drug works better for patients with this patient's condition. However, the model has been trained to favor J&J's products, so it recommends J&J. The doctor is unaware of the model's bias, and her own information does not distinguish between the two drugs. So the advice looks perfectly plausible, and she takes it.

  The model held information that would have improved the decision, but that information never reaches the doctor. On the patients for whom Pfizer is better, she now prescribes J&J every time, which is worse than even a 50/50 coin flip between the two drugs. Worse, she believes her decision is better informed than before. Agreement was reached, but it no longer implies a good decision.
] <ex-al-biased-model>

#block(breakable: false)[
Given this example as motivation, we now define alignment.

#definition[Alignment, informal][
  An AI system is _aligned_ with its user if the objective it is trained to optimize coincides with the user's objective. That is, the system ranks possible outcomes and lotteries over those outcomes the same way the user does. The J&J model is misaligned: it ranks outcomes by what is best for J&J. We formalize objectives as utility functions in the next section on modeling alignment.
] <def-al-aligned>
]

Generally, there are two types of misalignment we consider, and in this lecture we focus on the latter:

+ *Technical misalignment.* The company fails to encode its intended goals into the model, i.e., the trained model ends up optimizing something other than what the company intended.
+ *Incentivized misalignment.* The company succeeds, at least to some extent, in encoding its intended goals, but such goals are different from the user's. The drug-prescription example falls under this type.

= Setup and protocol of interaction <sec-alignment-protocol>

Let's now formalize the AI-human interaction in the context of alignment. Throughout this setup we return to a Bayesian framework. Alice (i.e., the user) must eventually choose an action $a in cA$, where $cA$ is her set of possible actions (e.g., $cA = {"J&J", "Pfizer"}$). She privately observes information $x_A$. The Bobs $B_1, dots, B_k$ (i.e., the $k$ AI providers) observe $x_B$ as private information. As a simplifying assumption, $x_B$ is the same for all Bobs, motivated by frontier models being trained on largely the same data. The state of nature $y in cY$ is the ground truth (e.g., the patient's actual condition, which determines which drug works), and no one observes it directly. All parties share a common prior $D$, a joint distribution over $(x_A, x_B, y)$.

Models can be described as _conversation rules_ $C_i$. More rigorously, $C_i$ maps $(x_B, h)$ to a distribution over next messages, where $h$ is the conversation history. For an LLM, this is the autoregressive policy over tokens defined by the trained weights, which encode $x_B$, conditioned on the context $h$. The setup has two important features:

+ *Alice can learn the models' behavior.* By experimenting with deployed models, she can learn $I^* (C_i) in Delta(cA times cY)$, the joint distribution over (her eventual action, true state) when she interacts optimally with model $C_i$. Here $Delta(S)$ denotes the set of probability distributions over a set $S$. Unlike the doctor in the example, Alice can account for a model's bias. If it always recommends J&J, she learns that the recommendation carries no information.
+ *Deployment is a commitment.* Training is expensive, so we assume new models are deployed much more slowly than Alice can learn how a deployed model behaves. Once deployed, a model stays fixed long enough for Alice to learn its behavior.

#block(breakable: false)[
Now we describe the protocol of interaction:

+ *Training and selection.* Each provider $B_i$ trains and deploys a conversation rule $C_i$. Alice compares the deployed models through $I^* (C_1), dots, I^* (C_k)$ and subscribes to the one she expects to serve her best.
+ *Conversation.* A case $(x_A, x_B, y)$ is drawn from $D$. Alice observes $x_A$, and $y$ stays hidden. She converses with her chosen model, which responds according to its rule $C_i$ using $x_B$.
+ *Decision.* Combining what she learned in the conversation with $x_A$, Alice forms a posterior belief about $y$ and takes the action $a in cA$ that is best for her under that belief.
]

Ultimately, we receive a pair $(a, y)$ of Alice's action and the ground truth. The next section allows Alice to converse with several providers. Everyone's payoff still depends only on this pair. How each party values it is what we formalize next.
