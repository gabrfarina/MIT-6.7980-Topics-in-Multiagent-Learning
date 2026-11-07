"""Check game-tree CFR against direct Kuhn play and independent pure-policy payoffs."""
import contextlib
import importlib.util
import io
from itertools import permutations, product
import json
from pathlib import Path
import sys
import types
import unittest


NOTEBOOK = Path(__file__).resolve().parents[1] / 'content/notebooks/learning_efg/cfr_template.ipynb'


@unittest.skipUnless(importlib.util.find_spec('numpy'), 'NumPy is required for the CFR notebook')
class KuhnTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = types.ModuleType('cfr_kuhn_notebook')
        sys.modules[cls.code.__name__] = cls.code
        cells = json.loads(NOTEBOOK.read_text())['cells']
        cls.run_source = ''.join(next(c for c in cells if c['id'] == 'kuhn-run')['source'])
        for cell in cells:
            if cell['id'] == 'kuhn-run':
                break
            if cell['cell_type'] == 'code':
                exec(''.join(cell['source']), cls.code.__dict__)
        cls.np, cls.game, cls.cards = cls.code.np, cls.code.kuhn, cls.code.cards
        cls.infosets = [[j for j in cls.game.information_sets if j.player == i] for i in range(2)]
        cls.choices = [list(product(range(2), repeat=len(js))) for js in cls.infosets]
        cls.strategies, cls.plans = [], []
        for infosets, choices in zip(cls.infosets, cls.choices):
            cls.strategies.append([
                {j: cls.np.eye(2)[a] for j, a in zip(infosets, choice)} for choice in choices
            ])
            cls.plans.append([
                {(j.metadata['card'], j.metadata['history']): j.actions[a]
                 for j, a in zip(infosets, choice)} for choice in choices
            ])
        # This matrix is a test oracle from direct chip accounting, not notebook code.
        cls.direct_payoffs = cls.np.array([
            [sum(cls.direct_payoff(deal, [first, second])
                 for deal in permutations(cls.cards, 2)) / 6 for second in cls.plans[1]]
            for first in cls.plans[0]
        ])

    @classmethod
    def direct_payoff(cls, cards, plans):
        """Play a hand using contributions, independently of the notebook's game tree."""
        contributions = [1, 1]
        history = ()
        while True:
            player = len(history) % 2
            action = plans[player][cards[player], history]
            if action == 'fold':
                return -contributions[0] if player == 0 else contributions[1]
            if action in ('bet', 'call'):
                contributions[player] += 1
            history += (action,)
            if action == 'call' or history == ('check', 'check'):
                if cls.cards.index(cards[0]) > cls.cards.index(cards[1]):
                    return contributions[1]
                return -contributions[0]

    def pure_policy_weights(self, player, strategy):
        return self.np.array([
            self.np.prod([strategy[j][a] for j, a in zip(self.infosets[player], choice)])
            for choice in self.choices[player]
        ])

    def test_information_sets_and_tree_match_all_pure_profiles(self):
        self.assertEqual([len(js) for js in self.infosets], [6, 6])
        self.assertEqual(len(self.game.top_down), 55)
        self.assertEqual(sum(h.payoff is not None for h in self.game.top_down), 30)
        for player, histories in enumerate([((), ('check', 'bet')), (('check',), ('bet',))]):
            self.assertEqual({(j.metadata['card'], j.metadata['history']) for j in self.infosets[player]},
                             set(product(self.cards, histories)))
        self.assertTrue(all(len(hs) == 2 for hs in self.game.histories.values()))
        for i, first in enumerate(self.strategies[0]):
            for j, second in enumerate(self.strategies[1]):
                values = self.game.continuation_values(0, {**first, **second})
                self.assertAlmostEqual(values[self.game.root], self.direct_payoffs[i, j])

    def test_best_response_matches_independent_pure_policy_payoffs(self):
        rng = self.np.random.default_rng(7)
        for player in range(2):
            opponent = 1 - player
            for trial in range(10):
                strategy = {j: (self.np.eye(2)[rng.integers(2)] if trial < 3 else
                                rng.dirichlet([1, 1])) for j in self.infosets[opponent]}
                weights = self.pure_policy_weights(opponent, strategy)
                expected = (max(self.direct_payoffs @ weights) if player == 0 else
                            -min(weights @ self.direct_payoffs))
                self.assertAlmostEqual(self.code.best_response_value(self.game, player, strategy), expected)

    def test_known_equilibrium_value_and_zero_exploitability(self):
        second_action_probabilities = [
            {(): [1/3, 0, 1], ('check', 'bet'): [0, 2/3, 1]},
            {('check',): [1/3, 0, 1], ('bet',): [0, 1/3, 1]},
        ]
        strategies = [{}, {}]
        for player, infosets in enumerate(self.infosets):
            for j in infosets:
                card = self.cards.index(j.metadata['card'])
                p = second_action_probabilities[player][j.metadata['history']][card]
                strategies[player][j] = self.np.array([1 - p, p])
        values = self.game.continuation_values(0, {**strategies[0], **strategies[1]})
        self.assertAlmostEqual(values[self.game.root], -1/18)
        self.assertAlmostEqual(self.code.best_response_value(self.game, 0, strategies[1]), -1/18)
        self.assertAlmostEqual(-self.code.best_response_value(self.game, 1, strategies[0]), -1/18)

    def hidden_continuation_game(self, root_player=0):
        Node, Info = self.code.GameNode, self.code.InformationSet
        root, later = Info(root_player, ('enter', 'quit')), Info(0, ('a', 'b'))
        hidden = Node(chance_probabilities={'left': .25, 'right': .75}, children={
            'left': Node(information_set=later, children={
                'a': Node(payoff=(8, -8)), 'b': Node(payoff=(0, 0))}),
            'right': Node(information_set=later, children={
                'a': Node(payoff=(-4, 4)), 'b': Node(payoff=(4, -4))}),
        })
        game = self.code.GameTree(Node(information_set=root, children={
            'enter': hidden, 'quit': Node(payoff=(2, -2))}))
        return game, root, later

    def test_counterfactual_updates_at_zero_own_reach_sum_hidden_histories(self):
        game, root, later = self.hidden_continuation_game()
        learner = self.code.CFR(game, 0)
        learner.local_learners[root].regret_sum[:] = [-1, 1]
        strategies = learner.NextStrategy()
        values = game.continuation_values(0, strategies)
        own, external = game.reach_probabilities(0, strategies)
        utilities = game.counterfactual_utilities(0, values, external)
        self.assertEqual(values[game.root], 2)
        self.np.testing.assert_allclose([own[h] for h in game.histories[later]], [0, 0])
        self.np.testing.assert_allclose([external[h] for h in game.histories[later]], [.25, .75])
        self.np.testing.assert_allclose(utilities[later], [-1, 3])
        self.np.testing.assert_allclose(utilities[root], [1, 2])
        learner.ObserveUtility({})
        self.np.testing.assert_allclose(learner.local_learners[later].regret_sum, [-2, 2])
        self.np.testing.assert_allclose(learner.local_learners[root].regret_sum, [-2, 1])
        self.np.testing.assert_array_equal(learner.strategy_sum[later], [0, 0])
        self.np.testing.assert_array_equal(learner.AverageStrategy()[later], [.5, .5])

    def test_zero_external_reach_gives_zero_regrets_but_still_averages(self):
        game, root, later = self.hidden_continuation_game(root_player=1)
        learner = self.code.CFR(game, 0)
        learner.NextStrategy()
        learner.ObserveUtility({root: self.np.array([0, 1])})
        self.np.testing.assert_array_equal(learner.local_learners[later].regret_sum, [0, 0])
        self.np.testing.assert_array_equal(learner.strategy_sum[later], [.5, .5])

    def test_average_uses_own_reach_once_per_information_set(self):
        game, root, later = self.hidden_continuation_game()
        learner = self.code.CFR(game, 0)
        for root_strategy, later_strategy in [([.25, .75], [.75, .25]), ([.75, .25], [.25, .75])]:
            learner.local_learners[root].regret_sum[:] = root_strategy
            learner.local_learners[later].regret_sum[:] = later_strategy
            learner.NextStrategy()
            learner.ObserveUtility({})
        self.np.testing.assert_allclose(learner.strategy_sum[root], [1, 1])
        self.np.testing.assert_allclose(learner.strategy_sum[later], [.375, .625])
        self.np.testing.assert_allclose(learner.AverageStrategy()[root], [.5, .5])
        self.np.testing.assert_allclose(learner.AverageStrategy()[later], [.375, .625])

    def test_round_updates_keep_current_strategies_fixed(self):
        forward = [self.code.CFR(self.game, i) for i in range(2)]
        reverse = [self.code.CFR(self.game, i) for i in range(2)]
        for _ in range(20):
            for learners, order in [(forward, (0, 1)), (reverse, (1, 0))]:
                strategies = [learner.NextStrategy() for learner in learners]
                saved = [{j: b.copy() for j, b in strategy.items()} for strategy in strategies]
                for i in order:
                    learners[i].ObserveUtility(strategies[1 - i])
                for strategy, original in zip(strategies, saved):
                    for j in strategy:
                        self.np.testing.assert_array_equal(strategy[j], original[j])
            for first, second in zip(forward, reverse):
                for j in first.local_learners:
                    self.np.testing.assert_array_equal(first.local_learners[j].regret_sum,
                                                       second.local_learners[j].regret_sum)

    def test_regret_matching_keeps_signed_cumulative_regrets(self):
        learner = self.code.RegretMatching(2)
        self.np.testing.assert_array_equal(learner.NextStrategy(), [.5, .5])
        learner.ObserveRegret(self.np.array([-2., 1.]))
        self.np.testing.assert_array_equal(learner.NextStrategy(), [0, 1])
        learner.ObserveRegret(self.np.array([1., -3.]))
        self.np.testing.assert_array_equal(learner.regret_sum, [-1, -2])
        self.np.testing.assert_array_equal(learner.NextStrategy(), [.5, .5])

    def test_training_averages_valid_strategies_and_converges(self):
        self.code.iterations = 5_000
        with contextlib.redirect_stdout(io.StringIO()):
            exec(self.run_source, self.code.__dict__)
        first, second, history = self.code.average1, self.code.average2, self.code.history
        self.assertEqual(history[0, 0], 1)
        self.assertEqual(history[-1, 0], 5_000)
        self.assertTrue(self.np.isfinite(history).all())
        self.assertTrue((self.np.diff(history[:, 0]) > 0).all())
        for strategy in [first, second]:
            for probabilities in strategy.values():
                self.assertTrue((probabilities >= 0).all())
                self.assertAlmostEqual(probabilities.sum(), 1)
        self.assertTrue((history[:, 2] <= -1/18 + 1e-12).all())
        self.assertTrue((history[:, 3] >= -1/18 - 1e-12).all())
        self.assertTrue((history[:, 2] <= history[:, 1] + 1e-12).all())
        self.assertTrue((history[:, 1] <= history[:, 3] + 1e-12).all())
        self.assertLess(abs(history[-1, 1] + 1/18), 0.001)
        exploitability = (history[:, 3] - history[:, 2]) / 2
        self.assertLess(exploitability[-1], 0.005)
        self.assertLess(exploitability[-1], exploitability[0] / 50)
        direct_value = (self.pure_policy_weights(0, first) @ self.direct_payoffs @
                        self.pure_policy_weights(1, second))
        self.assertAlmostEqual(history[-1, 1], direct_value)


if __name__ == '__main__':
    unittest.main()
