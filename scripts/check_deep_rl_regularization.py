#!/usr/bin/env python3
"""Reproduce the matrix-game calculations in deep_rl_regularization.typ."""

from fractions import Fraction
from math import exp, fsum, isclose, log, log1p


def sigmoid(x):
    if x >= 0:
        return 1 / (1 + exp(-x))
    ex = exp(x)
    return ex / (1 + ex)


def logit(p):
    return log(p) - log1p(-p)


def kl(p, q):
    """Bernoulli KL, including deterministic first arguments."""
    terms = []
    if p > 0:
        terms.append(p * log1p((p - q) / q))
    if p < 1:
        terms.append((1 - p) * log1p((q - p) / (1 - q)))
    return fsum(terms)


def log_partition(a, b, rho):
    shift = max(a, b)
    return shift + log(rho * exp(a - shift) + (1 - rho) * exp(b - shift))


def residual(p, q, alpha, rho):
    return max(abs(4 * q - 2 - alpha * (logit(p) - logit(rho))),
               abs(2 - 4 * p - alpha * (logit(q) - logit(rho))))


def nash_gap(p, q):
    return abs(2 * p - 1) + abs(2 * q - 1)


def regularized_gap(p, q, alpha, rho):
    # Evaluate both best-response values analytically, without optimization.
    u, v = (2 * q - 1) / alpha, (2 * p - 1) / alpha
    return alpha * (log_partition(u, -u, rho)
                    + log_partition(-v, v, rho) + kl(p, rho) + kl(q, rho))


def fixed_point(alpha, rho):
    # Eliminate p. q - BR_2(BR_1(q)) is strictly increasing on [0, 1].
    def row_response(q):
        return sigmoid(logit(rho) + (4 * q - 2) / alpha)

    def equation(q):
        p = row_response(q)
        return q - sigmoid(logit(rho) + (2 - 4 * p) / alpha)

    lo, hi = 0.0, 1.0
    assert equation(lo) < 0 < equation(hi)
    for _ in range(80):
        mid = (lo + hi) / 2
        if mid in (lo, hi):
            break
        if equation(mid) < 0:
            lo = mid
        else:
            hi = mid
    q = (lo + hi) / 2
    return row_response(q), q


def main():
    for i in range(-2, 3):
        for j in range(-2, 3):
            a, b = Fraction(i, 10), Fraction(j, 10)
            for eta in (Fraction(1, 100), Fraction(1, 20)):
                ap, bp = a + 4 * eta * b, b - 4 * eta * a
                assert abs(ap) < Fraction(1, 2) and abs(bp) < Fraction(1, 2)
                assert ap**2 + bp**2 == (1 + 16 * eta**2) * (a**2 + b**2)
                assert 2 * a * (4 * b) + 2 * b * (-4 * a) == 0
    print("Exact scalar GDA radius identity: passed (50 rational cases)")

    alpha, eta, rho = 0.3, 0.1, 0.8
    ps, qs = fixed_point(alpha, rho)
    assert residual(ps, qs, alpha, rho) < 1e-13
    p, q = 0.8, 0.35
    contraction = 1 / (1 + eta * alpha)
    max_roundoff = 0.0
    for _ in range(1000):
        distance = kl(ps, p) + kl(qs, q)
        # Simultaneous updates: both right-hand sides use the old p and q.
        pn = sigmoid((logit(p) + eta * (4 * q - 2)
                      + eta * alpha * logit(rho)) / (1 + eta * alpha))
        qn = sigmoid((logit(q) + eta * (2 - 4 * p)
                      + eta * alpha * logit(rho)) / (1 + eta * alpha))
        next_distance = kl(ps, pn) + kl(qs, qn)
        error = next_distance - contraction * distance
        max_roundoff = max(max_roundoff, error)
        assert error < 5e-15, (p, q, error)
        p, q = pn, qn
    assert abs(p - ps) < 1e-11 and abs(q - qs) < 1e-11
    assert residual(p, q, alpha, rho) < 2e-11
    assert isclose(nash_gap(p, q), 0.37981390830535566, rel_tol=0, abs_tol=1e-12)
    assert abs(regularized_gap(p, q, alpha, rho)) < 1e-14
    print(f"1000-step MMD: p={p:.15f}, q={q:.15f}")
    print(f"KKT residual={residual(p, q, alpha, rho):.3e}; "
          f"original Nash gap={nash_gap(p, q):.15f}")
    print(f"Independent bisection and KL contraction: passed "
          f"(maximum roundoff={max_roundoff:.3e})")

    checks = 0
    for rho in (0.2, 0.5, 0.8):
        for alpha in (0.03, 0.3, 1.0):
            bias_bound = 2 * alpha * log(1 / min(rho, 1 - rho))
            for i in range(21):
                for j in range(21):
                    p, q = i / 20, j / 20
                    delta = regularized_gap(p, q, alpha, rho)
                    assert delta >= -1e-14
                    assert nash_gap(p, q) <= delta + bias_bound + 1e-14
                    checks += 1
    print(f"Approximate-solution bias bound: passed ({checks} grid profiles)")


if __name__ == "__main__":
    main()
