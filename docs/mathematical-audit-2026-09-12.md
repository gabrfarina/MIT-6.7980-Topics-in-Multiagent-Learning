# Lecture integration and mathematical audit

Date: September 12, 2026. Baseline: the live MIT 6.7980 homepage and its 15 lecture HTML pages matched the local generated pages byte for byte at the beginning of the comparison. This update produces a local site with 17 notes. Publication is a separate operation.

## Material integrated

- **Lecture 16, High-dimensional games:** `content/kernelized.typ` now follows Fall 2024 Lecture 14, *Combinatorial games and Kernelized MWU*, as its main source. It restores the source's three-part progression: examples of combinatorial games; vertex MWU and kernelization, with separate feature-map, implicit-weight, normalization, and expectation-recovery arguments; and efficiently computable kernels. The examples include normal-form games, EFGs, resource allocations, graph paths, and fixed-size subsets. A resource-allocation dynamic program makes that example computationally explicit. The complete two-pass sequence-form implementation retains action-dependent child sets, multiple roots, and a numerical example, completing the older source's announced linear-time implementation.
- **Lecture 18, Total search and TFNP:** new `content/tfnp.typ`, adapted from L17 and the archive's lec6/lec6b. It covers polynomial balance, totality, search reductions, succinct End-of-Line, PPAD, related existence principles, input precision, and the distinction between approximate equilibria and exact algebraic solutions. The NP/coNP observation states the specific decision-recovering reduction it requires.
- Both chapters use the existing syllabus IDs (`kernelized`, `tfnp`). The course dates/order remain as scheduled. All authored Typst titles were explicitly aligned with the syllabus or supplementary list. The build validates agreement and rejects mismatches without overriding titles. Tests cover every current note, a simulated syllabus rename, and preservation of matching authored titles. The site checker also validates rendered HTML titles. Their descriptions are authored in the syllabus, and the build derives lecture numbers/dates and generates the index and both syllabus PDF copies.

## Figures included

The kernelized chapter includes an extensive-form tree, all seven highlighted pure-strategy vertices, and the vertex MWU/OMWU algorithm. The seven-strategy figure reuses `content/figures/efg_intro/nf_strategies.svg` from Lecture 7 at full width, including its gray grid, and the caption refers back to *Modeling extensive-form games*. Its separate tree drawing helper is `content/figures/kernelized/vertices.typ`, with updated CeTZ and font compatibility while preserving the game and labels.

The TFNP chapter retains the complexity-class schematic, with the total-search region labeled and a caption distinguishing known inclusions from conjectured separations. The six geometric illustrations remain in Lecture 2, where the coloring, padding, and path arguments are developed. Section L18.5 now refers back to that exposition and explains short cell encodings, local predecessor/successor circuits, decoding every endpoint, and the computational precision requirements. This removes the duplicated geometric recap from Lecture 18.

The perfection counterexample has a new editable tree and a native table, so the corrected probabilities are no longer embedded in an uneditable image.

## Corrections and retained differences

| Notes | Audit outcome |
|---|---|
| Normal-form games and Nash | No additional import needed. The supplied revision was already represented. No mathematical changes in this update; titles follow the syllabus. |
| Brouwer and Sperner | Existing geometric exposition and all six illustrations retained in Lecture 2. Lecture 18 now builds on them through succinct circuit encodings and endpoint decoding, with the extension to variable dimension identified separately. |
| Properties and relaxations of Nash | Existing named-source revision retained. No mathematical changes in this update; titles follow the syllabus. |
| Foundations of learning | Existing framework retained. No mathematical changes in this update; titles follow the syllabus. |
| Learning algorithms I | Retained the correct cumulative-regret summation and consecutive-iterate stability statement. Fixed the self-referential OMD update to use the preceding iterate; corrected MWU timing; restored the `1/(2 eta)` Euclidean penalty; fixed missing constants in RM/RM+/MWU bounds and the false centered-gradient norm inequality; corrected the OGD learning rate and domain-diameter dependence. The general OMD bound now uses its initial Bregman radius, and FTRL/OMD equivalence is qualified by the domain constraints. |
| Learning algorithms II | Retained the predictive/optimistic updates and supplementary placement. Kernelized ordinary MWU and optimistic MWU are distinguished: the ordinary bound is not asserted for the optimistic update without its separate hypotheses. |
| Bandit feedback | Retained the expanded feedback/adversary discussion; corrected the history index and conditional importance-sampling calculation. Replaced unsupported positive-reward exponential weighting without exploration by a loss-form Exp3 update with a short potential proof. Tsallis receives the same negative loss estimate. Exp3.P now includes its confidence bonus, valid exploration parameters, and logarithmic confidence dependence. |
| Phi-regret | Retained the site's stronger **equality** for Blum–Mansour. For each fixed comparison matrix the bound is an inequality; independent maximization over columns gives equality. Checked against exhaustive swap-map enumeration on sampled histories with stationary distributions. |
| Extensive-form foundations | Existing sequence-form/perfect-recall material retained. The new kernel chapter uses the same realization-flow interpretation. |
| Learning in extensive-form games | Existing CFR notes retained. The new notes explicitly distinguish vertex MWU from CFR. |
| Perfect equilibria | Fixed the player-1 constraints from `F_1 y = f_1` to `F_1 x = f_1` in both formulations. Reworked the uniform-sequence-tremble example: the root probability is **2 epsilon**, not 4 epsilon, because both continuation information sets inherit the same own-sequence weight. Replaced the diagram/table, supplied the best-response calculation, and restricted uniqueness to positive feasible perturbations. Qualified the LP discussion's feasibility/boundedness assumptions. |
| Kernelized MWU | Follows the Fall 2024 L14 exposition, with its examples and detailed kernelization proof restored. The partial EFG kernel uses continuation plans conditional on selecting the preceding sequence; an unconditional projection could wrongly include a zero plan. Child sets remain action dependent. Gradient access, efficient kernel evaluation, and exact versus finite-precision arithmetic are separate requirements. Resource-allocation complexity is stated in the one-hot representation, including its dependence on the budget value. Optimistic guarantees retain their hypotheses. |
| Ellipsoid-Against-Hope | Replaced the appendix's unnormalized product calculation with normalized conditional distributions, including zero-mass players. Fixed deviation-action indices that had made constraints identically zero, and made recovery coefficients sum to one. Stated payoff/oracle/bit-complexity assumptions and distinguished approximate ellipsoid termination from an exact finite infeasibility certificate. |
| Stochastic games | Corrected Markov history equivalence to require the same current state, finite-horizon truncation, stationary-policy assumptions, the next-state summation, and the Bellman continuation index. Completed the Banach uniqueness and Shapley security arguments. Replaced the invalid discount-substitution claim with an explicit counterexample and a proven residual-to-equilibrium certificate. Separated simultaneous-move discounted games from turn-based simple stochastic games and polynomial bit complexity from strongly polynomial arithmetic complexity. |
| Total search / PPAD I | Newly integrated. End-of-Line has an explicit convention for all circuit pairs, a polynomial verifier, and a proof of totality. Search reductions require existence of target solutions as well as decoding **every** target solution. |
| PPAD-hardness / PPAD II | Preserved rational-constant scaling rather than introducing variable multiplication. Replaced the unqualified exact Arithmetic Circuit SAT claim by an explicit approximate generalized-circuit formulation with a comparison gap and inverse-polynomial precision. Preserved the addition gadget and added a complete comparison-gadget argument, including its approximation error. The notes accurately describe the remaining composition and fixed-player reductions as omitted. |
| Centralized Nash algorithms | Existing named-source material retained. The older archive's additional worked Lemke–Howson and LMM supplements were not part of these two missing chapters or this correction pass. |

### Correction to the original coverage report

The uniform-lower-bound QPE appendix was already present in the supplied perfect-equilibria notes. The original comparison incorrectly called it a website addition. The comparison report has been corrected. The erroneous 4-epsilon root probability was inherited by both versions. The original source files were not edited.

## Key arguments checked independently

**Sequence-form marginals.** At information set I, define `B_Ia = b_Ia * product_{J in C(I,a)} Z_J`, then `Z_I = sum_a B_Ia`. At each root take preceding weight 1; propagate `x_Ia = x_parent * B_Ia/Z_I`. Children following different observations each receive `x_Ia`. Products combine independent continuation plans; sums combine the mutually exclusive own actions. This yields both the partition function and all marginals in linear arithmetic complexity. The lecture also proves the general `d+1` kernel-evaluation identity.

**Stochastic-game stopping condition.** For a local saddle profile computed from V, the profile Bellman operator and both unilateral best-response operators agree at V and are gamma-contractions. If `rho = ||T(V)-V||_infinity`, each fixed point is within `rho/(1-gamma)` of V. Either deviation gain is therefore at most `2 rho/(1-gamma)`. The algorithm returns the policies used to compute the tested residual and stops at `rho <= epsilon*(1-gamma)/2`. Exact local solves are assumed in this displayed certificate.

**Discount counterexample.** A one-state game paying 1 forever has unnormalized value `1/(1-gamma)`. Changing gamma from 0.9999 to 0.99 changes value from 10,000 to 100. Thus replacing gamma by `1-epsilon` does not generically give an O(epsilon) value approximation. The notes retain the actual discount dependence in value iteration.

**Uniform perturbations.** With lower bound epsilon, `x_bc+x_bd=x_b` and `x_bp+x_bq=x_b`, so the minimum root weight is 2 epsilon. Against Player 2's probability r, Player 1's utility is `2-(2-r)x_b-3r*x_bd`, uniquely optimized by `x_b=2 epsilon`, `x_bd=epsilon` for the stated positive range. The limiting continuation at C remains suboptimal, so the pedagogical counterexample survives with the corrected numbers.

## Primary references

- [Farina, Lee, Luo and Kroer (ICML 2022)](https://proceedings.mlr.press/v162/farina22a.html), especially Theorems 4.1–4.3 and 5.2: kernelized vertex updates and the action-dependent sequence-form recurrence.
- [Papadimitriou (1994)](https://doi.org/10.1016/S0022-0000(05)80063-7): parity-based total-search classes.
- [Chen, Deng and Teng](https://arxiv.org/abs/0704.1678): PPAD-completeness and generalized-circuit precision. [Daskalakis, Goldberg and Papadimitriou's exposition](https://www.cs.ox.ac.uk/people/paul.goldberg/papers/CACM-dgp09.pdf) provides context for the fixed-point/game reductions.
- [Etessami and Yannakakis](https://homepages.inf.ed.ac.uk/kousha/nash_focs07_full_j_spec_issue_sub.pdf): exact versus approximate fixed points, FIXP, and the piecewise-linear PPAD setting.
- [Auer, Cesa-Bianchi, Freund and Schapire](https://cesa-bianchi.di.unimi.it/Pubblicazioni/J18.pdf), Section 6: Exp3.P's confidence correction and parameterized high-probability guarantee. The loss-form Exp3 proof in the lecture is given directly.
- [Condon (1992)](https://doi.org/10.1016/0890-5401(92)90048-K): the separate simple-stochastic-game model and its NP/coNP decision bounds.

## Validation

`scripts/check_lecture_math.py` contains seven independent finite checks, using exact rational arithmetic where appropriate:

1. Kernel recurrence and coordinate-exclusion identity versus explicit enumeration of a realization-plan forest, for 50 positive weight assignments.
2. End-of-Line totality for all 65,536 pairs of two-bit predecessor/successor functions.
3. The Shapley residual certificate against enumerated stationary deterministic best responses in 120 random two-state games, including gamma=0 and gamma=0.99.
4. The corrected uniform perturbation solution against all vertices of the example's feasible sequence polytope.
5. Hart–Schmeidler cancellation by explicit payoff enumeration, including a zero-mass player.
6. Blum–Mansour equality against enumeration of all swap maps on a three-action example with varying stationary distributions.
7. Hypercube, fixed-size-subset, resource-allocation, and DAG-path kernels against exhaustive enumeration, including zero and negative weights and boundary cases.

All seven checks passed after the Fall 2024 Lecture 14 revision. These finite checks support the displayed arguments and examples; they are not a formal verification of every theorem in the lecture collection or the older teaching archive. The full omitted PPAD hardness reductions remain referenced proofs, rather than newly authored lecture content.

The initial integration build and `make check` passed: 77 Python tests, 71 Rust tests, 17 note-title comparisons, 53 source-image occurrences, and 2,390 KaTeX expressions with zero errors or SVG fallbacks. The title tests cover both HTML and PDF preparation, explicit failure after a syllabus rename, and preservation of the authored title. The rendered HTML titles are checked independently against the schedule or supplementary list.

All 17 PDF titles were checked against the canonical titles, accounting for line wrapping and discretionary hyphenation. The eight new or substantively revised notes and the five-page syllabus were rendered for visual inspection; the new figures and corrected formulas were inspected at readable size. The syllabus embeds Frutiger Bold and New Computer Modern regular/italic text, with no PT Sans. The two syllabus PDF copies are byte-identical. The generated website and `dist/6.7980-notes.zip` include the new notes, figures, sources, and PDF downloads. These are local outputs; this update does not publish them.

After the lecture 18 overlap revision, the site build checks 47 source-image occurrences and 2,395 KaTeX expressions, with zero errors or fallbacks. All 17 title checks still pass. The removed six geometric illustrations remain in Lecture 2; the TFNP chapter now contains only its complexity-class figure. The syllabus and index description emphasize succinct End-of-Line reductions.

The Lecture 16 revision follows the Fall 2024 Lecture 14 source and has been checked visually across all 12 pages of the final PDF. This inspection found that Typst absorbed function arguments into ungrouped subscripts, for example in `K_V(z,w)` and `lambda_t(v)`. Explicit grouping now keeps the arguments at the main baseline in the kernel, probability, feature-map, and resource-allocation formulas. `scripts/test_kernelized_math.py` compiles all 228 authored math expressions and inspects the resulting math trees for this error; it also verifies that known faulty examples are rejected. The same check passes for all 233 equations in the complete compiled PDF. Parentheses, compound subscripts, fractions, and the displayed recurrences were then inspected page by page. Algorithm 1 and the shared extensive-form strategy gallery remain full width.

The final revision passed 79 Python tests and all seven finite mathematical checks. Its full site build passed 18 title comparisons, 47 source-image checks, and 2,666 KaTeX expressions with zero errors or SVG fallbacks; this build also includes the supplementary note added concurrently. The Lecture 16 description is synchronized between the index and syllabus, and the two syllabus PDF copies match. The original Fall 2024 files were not modified.
