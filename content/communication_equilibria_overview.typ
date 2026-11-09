#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 11,
  date: [Thu, Oct 22, 2026],
  title: "Information and mechanism design",
  instructor: [Brian Hu Zhang],
)

// Section 5: (MD) Tying it all together. Contributor: Aaron Hu.
// Prepared with OpenAI Codex assistance for drafting, editing, and validation.

= Tying it all together <sec-l11-communication-overview>

The four examples have the same general setup: a *mediator* commits to a
strategy and communicates with the *players* to influence their actions.
The mediator could be a leader, auctioneer, seller, or correlation device.
Its goal is to maximize an objective while ensuring that the players have
no incentive to deviate.

Let $mu$ denote the mediator's committed strategy. Players can send private
information to the mediator, which can remember prior messages and send
information or recommendations back. Communication itself has no direct
effect on payoffs, but it can change what players know and how they act.
Commitment means that the mediator must follow $mu$, including its
responses to the players' messages.

#definition[Communication equilibrium][
  In an extensive-form game with $n$ players, let $x_i$ specify player $i$'s
  messages and actions based on the information available to that player.
  A _communication equilibrium_ is a tuple of possibly randomized
  strategies $(mu, x_1, ..., x_n)$ such that
  $
    u_(i)(mu, x_i, x_(-i)) >= u_(i)(mu, x_i', x_(-i))
    quad forall i, x_i',
  $
  where $u_i$ denotes expected utility, $x_(-i)$ denotes the other players'
  strategies, and $x_i'$ ranges over all strategies available to player $i$.
] <def-l11-communication-equilibrium>

Thus, holding $mu$ fixed, the players' strategies form a Nash equilibrium
of the game with communication. A deviation can change both messages and
actions. We impose no incentive constraint on the mediator, since its
strategy is fixed by commitment. We seek an equilibrium maximizing its
expected utility $u_(M)(mu, x_1, ..., x_n)$.

#theorem[Zhang and Sandholm, 2022][
  For a finite extensive-form game with perfect recall and fixed turn
  order, with each information set contained in one tree level, a
  communication equilibrium maximizing the mediator's expected utility
  can be computed in time polynomial in the explicit game-tree input
  size #citep(<ZhangSandholm2022Mediator>, [Theorem 3.2]).
] <thm-l11-optimal-communication-equilibrium>

Initially, messages can be arbitrary, so we cannot directly enumerate all
possible communication histories. The proof proceeds in three steps:

+ *Reduce to a finite game.* By the revelation principle, we can restrict
  attention to equilibria where players truthfully report private
  information and follow action recommendations. This gives a finite
  message space without changing the achievable equilibrium outcomes.
+ *Reduce to polynomial size.* Keeping all transcripts still gives an
  exponentially large game. We restrict transcripts to histories
  consistent with the original game, handling detected deviations
  separately. Since Nash equilibrium only requires checking unilateral
  deviations, we need only keep track of one deviator at a time.
+ *Solve the reduced game.* Fix the players' truthful and obedient
  strategies, and optimize the mediator's strategy subject to their
  incentive constraints. Sequence-form representations and LP duality
  give a polynomial-size linear program, which we can solve in
  polynomial time.

The following sections develop these three steps.

= Bibliography for this section
#lec_bibliography("meta/refs.bib", title: none)
