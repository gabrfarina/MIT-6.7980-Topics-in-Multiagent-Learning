"""Kernelized vertex MWU for symmetric, zero-sum Colonel Blotto."""

import argparse

import numpy as np

from vertex_mwu import payoff_gradient


def _budget_table(scores, aggregate):
    """Combine log weights or payoffs for prefixes with each exact budget."""
    battlefields, columns = scores.shape
    table = np.full((battlefields + 1, columns), -np.inf)
    table[0, 0] = 0.0
    for j, row in enumerate(scores):
        for r in range(columns):
            table[j + 1, r] = aggregate(table[j, :r + 1] + row[r::-1])
    return table


def marginals(log_weights):
    """Return P(a_j = s) when P(a) is proportional to exp(sum_j log_weights[j, a_j])."""
    _, columns = log_weights.shape
    troops = columns - 1
    prefix = _budget_table(log_weights, np.logaddexp.reduce)
    suffix = _budget_table(log_weights[::-1], np.logaddexp.reduce)[::-1]
    log_z = prefix[-1, troops]
    strategy = np.empty(log_weights.shape)
    for j, row in enumerate(log_weights):
        for s, score in enumerate(row):
            remaining = troops - s
            left = prefix[j, :remaining + 1]
            right = suffix[j + 1, :remaining + 1][::-1]
            log_mass = score + np.logaddexp.reduce(left + right)
            strategy[j, s] = np.exp(log_mass - log_z)
    return strategy


def run(values, troops, num_steps):
    """Run the vertex demo's self-play schedule and return last and mean marginals."""
    values = np.asarray(values, dtype=float)
    log_weights = np.zeros((values.size, troops + 1))
    strategy = marginals(log_weights)
    strategy_sum = strategy.copy()
    for step in range(num_steps):
        learning_rate = 1.5 / np.sqrt(1 + step)
        log_weights += learning_rate * payoff_gradient(strategy, values)
        # Each allocation uses one entry per row, so centering cancels in normalization.
        log_weights -= log_weights.max(axis=1, keepdims=True)
        strategy = marginals(log_weights)
        strategy_sum += strategy
    return strategy, strategy_sum / (num_steps + 1)


def best_response_value(strategy, values):
    """Maximum payoff of a single feasible allocation against these marginals."""
    grad = payoff_gradient(strategy, np.asarray(values, dtype=float))
    return _budget_table(grad, np.maximum.reduce)[-1, -1]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--values", type=float, nargs="+", default=[1, 2, 3, 4])
    parser.add_argument("--troops", type=int, default=10)
    parser.add_argument("--steps", type=int, default=400)
    args = parser.parse_args()
    if args.troops < 0 or args.steps < 0:
        parser.error("--troops and --steps must be nonnegative")
    if not np.all(np.isfinite(args.values)):
        parser.error("--values must be finite")

    last, average = run(args.values, args.troops, args.steps)
    print("Rows are battlefields. Columns are troop counts from 0 to R.")
    with np.printoptions(precision=4, suppress=True):
        print("Average marginals:")
        print(average)
    print(f"Best-response payoff against last iterate: {best_response_value(last, args.values):.6f}")
    print(f"Best-response payoff against average: {best_response_value(average, args.values):.6f}")
