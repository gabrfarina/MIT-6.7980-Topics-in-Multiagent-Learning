#import "meta/gabri_notes.typ": *
#show: gabri_notes.with(
  lec_num: 12,
  title: "The team belief DAG construction",
  instructor: [Brian Hu Zhang],
)

// L12 material contribution, task 5 (slides 11--17).
// Standalone section for later integration with the other team-games sections.

= The team belief DAG <sec-team-belief-dag>

This section presents the team belief DAG construction, following slides
11--17 #citep(<Zhang26:TeamGames>); the construction is due to
#citet(<Zhang23:TeamDAG>).

== Setup

Since different players do not have access to the private observations of
teammates (communication is only allowed before play begins), treating
teammates as one merged player removes the notion of perfect recall. I.e.,
Player 1 does not have the same infoset as teammate player 2 at a given
decision point. Computing a TMECor is also hard, so we convert the original
game tree into a new construction: a *team belief DAG* (TB-DAG).

#bpar[The idea:] The two assumptions underlying TMECor are key to the TB-DAG
construction. Recall:

- *Known teammate strategies:* The plan is agreed in advance $==>$ any member
  can counterfactually reconstruct what a teammate would have done in any
  situation.
- *No in-play mixing:* Team members do not randomize beyond the distribution
  shared in advance.

Based on these assumptions, it is possible to construct a single-player
decision problem (like sequence form) by representing what is _common
knowledge_ for the team.

== The construction

Each game tree (left) is converted into its TB-DAG (right):

#figure(
  image("figures/team_belief_dag/construction.svg", width: 100%),
  caption: [A team game tree (left) and its team belief DAG (right).],
) <fig-tbdag-construction>

- *Left: the team game tree.* Chance moves first. The first team member acts
  at $A$ or $B$ and knows which (separate infosets). The second member acts at
  $C, D, E, F$ but cannot tell $C$ and $D$ apart (see dotted line to represent
  this).
- *Right: the TB-DAG.* The blue boxes represent decision points of the team,
  while the white boxes represent observation points. The root is labeled
  $A B$. After chance moves, only the acting team member knows whether play is
  at $A$ or $B$ --- the other members do not see anything. The DAG tracks the
  team instead of the individual player. For each decision-point level, an
  observation point level is added below it, alternating between the two.

#bpar[Decision points and belief:] A _belief_ is represented by the set of
tree nodes the team may have reached at that point in time given all past
public actions as common knowledge. At the root nothing public has happened
yet, so play could be at $A$ or $B$. Thus the root is labeled with belief
${A, B}$. If every team member saw all private actions, each belief set would
shrink to an ordinary infoset because a player would be able to distinguish
all decision points. The whole object would then collapse back to sequence
form $==>$ the TB-DAG strictly generalizes sequence form.

A belief can cover infosets of several different members, so "pick one
action" does not make sense here --- whose action would it be? Instead, the
team commits to something like an answer sheet: one action for every
situation it might be in:

#figure(
  image("figures/team_belief_dag/prescription.svg", width: 100%),
  caption: [Each edge out of ${A, B}$ is one answer sheet. Two infosets, two
    actions each $==>$ four sheets $==>$ four edges.],
) <fig-tbdag-prescription>

#bpar[Prescriptions: the edges out of a belief node.] A prescription, as
shown above, is a pre-determined singular action for each infoset that meets
the belief. Ex: ${A, B}$ meets two infosets with two actions each $==>$
$2 times 2 = 4$ prescriptions $==>$ $4$ edges. Each edge has a different
representation corresponding to the original game tree: the edge to $C D$
says "left at $A$, left at $B$," while the edge to $C F$ says "left at $A$,
right at $B$." etc. The child's label is just where those deterministic
choices can lead.

== Observation points and public observations

After the team commits to its answer sheet, others respond. An _observation
point_ is simply "where could we be now?" For example, if a team starts at
${A, B}$, with the sheet ($A -> C$, $B -> D$), play could be at $C$ or $D$,
which we denote in white with the observation point ${C, D}$.

#figure(
  image("figures/team_belief_dag/public_observation.svg", width: 100%),
  caption: [After ($A -> C$, $B -> D$): the mover cannot tell $C$ from $D$
    $==>$ ${C, D}$ stays one belief. After ($A -> C$, $B -> F$): everyone can
    tell $C$ from $F$ $==>$ split into ${C}$ and ${F}$.],
) <fig-tbdag-public-observation>

#bpar[The splitting rule (public observations):]

- The team only "observes" what becomes common knowledge, i.e. the public
  observation.
- Rule: As shown above, split the observation point into connected components
  under the infoset structure, s.t. each component becomes a new belief. Two
  nodes stay together if at least one member cannot tell them apart. Ex:
  ${C, D}$ does *not* split under the answer sheet above, while ${C, F}$
  does.

This splitting rule determines branching degree in the TB-DAG: observation
point $C D$ has one child because the team cannot distinguish between ${C}$
and ${D}$, while observation point $C F$ (distinguishable) has two --- the
beliefs ${C}$ and ${F}$.

Note that the splitting rule takes connected components, not pairs, because
of transitivity: if one member cannot distinguish $x$ from $y$ and another
cannot distinguish $y$ from $z$, no public signal can separate $x$ from $z$
$==>$ ${x, y, z}$ would stay as one belief.

== A DAG is enough

Why a DAG and not a tree? The answer is size constraints. Observe that the
same belief can be reached along different paths. For example, in the TB-DAG
above, the belief ${G}$ has two parents:

- Parent 1: belief ${C}$: the answer sheet leads to observation point $G$,
  which becomes the belief ${G}$;
- Parent 2: belief ${C, D}$: the answer sheet leads to observation point
  ${G, I}$, which splits since $G$ and $I$ are publicly distinguishable.

A full tree of histories would have two separate copies of ${G}$ as leaves,
greatly increasing its size. Merging is safe because the belief itself
represents the team's entire memory. Two histories ending in the same belief
look identical from there on: same possible positions, same answer sheets,
and same information structure. Separate copies contain information that only
individuals, but not the team, can act on, making them unnecessary for this
construction.

As such, the TB-DAG enables:

- *Solving the team game as a single-player problem:* the constructed
  player's memory is common knowledge that can be accessed by the entire team
  $==>$ there is perfect recall $==>$ the sequence-form machinery that fails
  on the merged team player applies to the TB-DAG. An optimal distribution
  over flows through the DAG _is_ a TMECor.
- *Decentralized execution of the joint plan:* Since the plan is agreed in
  advance, each member can privately simulate everything the team as a whole
  can deduce $==>$ during play, every member knows the current belief and
  which prescription applies without any communication during the game.

#lec_bibliography("meta/refs.bib", title: none)
