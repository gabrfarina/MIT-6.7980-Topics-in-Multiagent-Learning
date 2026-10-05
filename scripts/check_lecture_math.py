#!/usr/bin/env python3
"""Independent finite checks supporting the September 2026 lecture audit.

These compare explicit enumeration with the notes' formulas. They supplement,
not replace, the proofs; they are not a general theorem-proving test suite.
Run with the bundled Python runtime (NumPy is required).
"""
from fractions import Fraction as F
from itertools import combinations, product
import math
import random
import unittest

import numpy as np


class LectureMathChecks(unittest.TestCase):
    def test_combinatorial_kernels_against_enumeration(self):
        rng = random.Random(20260916)
        weight = lambda: F(rng.randrange(-3, 5), rng.randrange(1, 5))

        for d in range(1, 7):
            for _ in range(5):
                q = [weight() for _ in range(d)]
                hypercube = sum(math.prod(q[k] for k, bit in enumerate(v) if bit)
                                for v in product((0, 1), repeat=d))
                self.assertEqual(math.prod(1 + x for x in q), hypercube)
                coefficients = [F(1)] + [F(0)] * d
                for x in q:
                    coefficients = [coefficients[0]] + [
                        coefficients[r] + x * coefficients[r - 1]
                        for r in range(1, d + 1)]
                for m in range(d + 1):
                    explicit = sum(math.prod(q[k] for k in subset)
                                   for subset in combinations(range(d), m))
                    self.assertEqual(coefficients[m], explicit)

        for battlefields, budget in product(range(1, 4), range(5)):
            for _ in range(5):
                q = [[weight() for _ in range(budget + 1)]
                     for _ in range(battlefields)]
                explicit = sum(
                    math.prod(q[j][s] for j, s in enumerate(allocation))
                    for allocation in product(range(budget + 1), repeat=battlefields)
                    if sum(allocation) == budget)
                partial = [F(1)] + [F(0)] * budget
                for row in q:
                    partial = [sum(row[s] * partial[r - s] for s in range(r + 1))
                               for r in range(budget + 1)]
                self.assertEqual(partial[budget], explicit)

        # A destination with outgoing edges and a dead-end branch ensure that
        # only paths ending at the designated destination contribute.
        edges = [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (2, 3), (3, 4)]
        for _ in range(20):
            q = {edge: weight() for edge in edges}
            for destination in (0, 3, 4):
                explicit = F(0)
                for length in range(5):
                    for interior in combinations(range(1, destination), length):
                        nodes = (0, *interior, destination) if destination else (0,)
                        path = list(zip(nodes, nodes[1:]))
                        if destination == 0 and length != 0:
                            continue
                        if all(edge in q for edge in path):
                            explicit += math.prod(q[edge] for edge in path)
                suffix = {}
                for node in reversed(range(5)):
                    suffix[node] = (F(1) if node == destination else sum(
                        q[u, v] * suffix[v] for u, v in edges if u == node))
                self.assertEqual(suffix[0], explicit)

    def test_kernel_forest_against_vertex_enumeration(self):
        # Two roots, branching observations after one action, and an action
        # with no children: using an action-independent child set fails here.
        actions = {'I': ['a', 'b'], 'J': ['c', 'd'], 'K': ['e', 'f'], 'R': ['g', 'h']}
        children = {'b': ['J', 'K']}
        coords = list('abcdefgh')

        def plans(node):
            result = []
            for a in actions[node]:
                subtrees = [plans(j) for j in children.get(a, [])]
                for subplans in product(*subtrees):
                    result.append(frozenset([a]).union(*subplans))
            return result

        vertices = [i | r for i, r in product(plans('I'), plans('R'))]
        rng = random.Random(20260912)
        for _ in range(50):
            b = {a: F(rng.randrange(1, 20), rng.randrange(1, 10)) for a in coords}
            weights = [math.prod(b[a] for a in v) for v in vertices]
            total = sum(weights)
            explicit = {a: sum(w for v, w in zip(vertices, weights) if a in v)/total for a in coords}
            z, branch, mean = {}, {}, {}

            def backward(i):
                for a in actions[i]:
                    branch[a] = b[a]*math.prod(backward(j) for j in children.get(a, []))
                z[i] = sum(branch[a] for a in actions[i])
                return z[i]

            def forward(i, reach):
                for a in actions[i]:
                    mean[a] = reach*branch[a]/z[i]
                    for j in children.get(a, []):
                        forward(j, mean[a])

            self.assertEqual(backward('I')*backward('R'), total)
            forward('I', F(1)); forward('R', F(1))
            self.assertEqual(mean, explicit)
            for a in coords:
                excluded = sum(w for v, w in zip(vertices, weights) if a not in v)
                self.assertEqual(explicit[a], 1-excluded/total)

    def test_end_of_line_all_two_bit_circuit_functions(self):
        functions = list(product(range(4), repeat=4))
        for predecessor, successor in product(functions, repeat=2):
            incoming = [int(predecessor[v] != v and successor[predecessor[v]] == v) for v in range(4)]
            outgoing = [int(successor[v] != v and predecessor[successor[v]] == v) for v in range(4)]
            self.assertEqual(sum(incoming), sum(outgoing))
            if incoming[0] != outgoing[0]:
                self.assertTrue(any(incoming[v] != outgoing[v] for v in range(1, 4)))

    def test_shapley_certificate_against_all_stationary_best_responses(self):
        def saddle(a):
            lo = a.min(axis=1); hi = a.max(axis=0)
            i, j = lo.argmax(), hi.argmin()
            if abs(lo[i]-hi[j]) < 1e-12:
                return np.eye(2)[i], np.eye(2)[j]
            den = a[0,0]-a[0,1]-a[1,0]+a[1,1]
            p = (a[1,1]-a[1,0])/den
            q = (a[1,1]-a[0,1])/den
            return np.array([p,1-p]), np.array([q,1-q])

        rng = np.random.default_rng(20260912)
        for gamma in (0, .5, .9, .99):
            for _ in range(30):
                reward = rng.uniform(-1,1,(2,2,2))
                transition = rng.dirichlet([1,1],size=(2,2,2))
                estimate = rng.normal(size=2)/(1-gamma)
                q = reward + gamma*np.einsum('sabu,u->sab',transition,estimate)
                pairs = [saddle(q[s]) for s in range(2)]
                p1, p2 = np.array([x[0] for x in pairs]), np.array([x[1] for x in pairs])
                updated = np.einsum('sa,sab,sb->s',p1,q,p2)
                rho = np.max(abs(updated-estimate))

                def evaluate(x,y):
                    rewards = np.einsum('sa,sab,sb->s',x,reward,y)
                    trans = np.einsum('sa,sabu,sb->su',x,transition,y)
                    return np.linalg.solve(np.eye(2)-gamma*trans,rewards)

                value = evaluate(p1,p2)
                deterministic = [np.eye(2)[list(a)] for a in product(range(2),repeat=2)]
                br1 = np.max([evaluate(x,p2) for x in deterministic],axis=0)
                br2 = np.min([evaluate(p1,y) for y in deterministic],axis=0)
                gain = max(np.max(br1-value),np.max(value-br2))
                self.assertLessEqual(gain,2*rho/(1-gamma)+1e-9)
        self.assertAlmostEqual(1/(1-.9999)-1/.01,9900)

    def test_uniform_sequence_perturbation_by_feasible_vertex_enumeration(self):
        # Feasible black-player polytope vertices at epsilon=1/10.
        eps = F(1,10)
        candidates = []
        for b in (2*eps,1-eps):
            for d,q in product((eps,b-eps),repeat=2):
                candidates.append((b,b-d,d,b-q,q))
        for r in (eps,F(1,2),1-eps):
            utility = lambda x: 2*(1-x[0])+r*(x[1]-2*x[2])
            best = max(utility(x) for x in candidates)
            optimizers = set(x for x in candidates if utility(x)==best)
            self.assertEqual(optimizers,{(2*eps,eps,eps,eps,eps)})
        # The former 4 epsilon root probability admits a profitable deviation.
        self.assertGreater(2*(1-2*eps)-(1-eps)*eps,2*(1-4*eps)-(1-eps)*2*eps)

    def test_hart_schmeidler_including_zero_mass_player(self):
        rng = np.random.default_rng(75)
        for zero in (False,True):
            nu = rng.random((3,2))
            if zero: nu[1]=0
            nu /= nu.sum()
            mu = np.array([row/row.sum() if row.sum() else [0.5,0.5] for row in nu])
            payoffs = rng.normal(size=(3,2,2,2))
            total = 0.
            for a in product(range(2),repeat=3):
                probability = math.prod(mu[i,a[i]] for i in range(3))
                for i,d in product(range(3),range(2)):
                    changed = list(a); changed[i]=d
                    total += nu[i,d]*probability*(payoffs[(i,*changed)]-payoffs[(i,*a)])
            self.assertAlmostEqual(total,0)

    def test_blum_mansour_equality_by_all_swap_maps(self):
        rng=np.random.default_rng(19)
        history=[]
        for _ in range(12):
            matrix=rng.dirichlet([1,1,1],size=3).T
            system=matrix-np.eye(3); system[-1]=1
            rhs=np.array([0.,0.,1.]); x=np.linalg.solve(system,rhs)
            history.append((matrix,x,rng.uniform(-1,1,3)))
        swap=max(sum(sum(x[i]*(g[mapping[i]]-g[i]) for i in range(3)) for _,x,g in history)
                 for mapping in product(range(3),repeat=3))
        local=sum(max(sum(x[i]*(g[j]-g@matrix[:,i]) for matrix,x,g in history) for j in range(3)) for i in range(3))
        self.assertAlmostEqual(swap,local)

    def test_lemke_howson_examples_by_exact_pivoting(self):
        # Symmetric example of nash_algorithms.typ: vertices, doubly represented
        # actions, and the equilibrium reached for each special action.
        R = [[4, 8, 1], [2, 7, 3], [9, 4, 5]]
        vertices, picked = symmetric_lemke_howson(R, 2)
        self.assertEqual(vertices, [(0, 0, 0), (0, F(1, 8), 0), (F(1, 14), F(5, 56), 0),
                                    (F(4, 173), F(18, 173), F(13, 173))])
        self.assertEqual(picked, [1, 3, 2])
        self.assertEqual(support_equilibria(R, transpose(R), symmetric=True),
                         [((0, 0, 1),) * 2, ((0, F(2, 5), F(3, 5)),) * 2,
                          ((F(4, 35), F(18, 35), F(13, 35)),) * 2])
        for k, sequence, end in ((1, [3, 1], (0, 0, 1)), (2, [1, 3, 2], (F(4, 35), F(18, 35), F(13, 35))),
                                 (3, [3], (0, 0, 1))):
            vertices, picked = symmetric_lemke_howson(R, k)
            self.assertEqual((picked, normalize(vertices[-1])), (sequence, end))
        self.assertEqual(symmetric_lemke_howson(R, 1)[0][1:], [(F(1, 9), 0, 0), (0, 0, F(1, 5))])

        # Asymmetric example (von Stengel's 3 x 2 game).
        R, C = [[3, 3], [2, 5], [0, 6]], [[3, 2], [2, 6], [3, 1]]
        mixed, pure, other = ((0, F(1, 3), F(2, 3)), (F(1, 3), F(2, 3))), ((1, 0, 0), (1, 0)), \
            ((F(4, 5), F(1, 5), 0), (F(2, 3), F(1, 3)))
        self.assertEqual(sorted(support_equilibria(R, C)), sorted([pure, other, mixed]))
        steps = bimatrix_lemke_howson(R, C, 2)
        self.assertEqual(steps, [
            ('P', 2, 5, ((0, F(1, 6), 0), (0, 0))), ('Q', 5, 3, ((0, F(1, 6), 0), (0, F(1, 6)))),
            ('P', 3, 4, ((0, F(1, 8), F(1, 4)), (0, F(1, 6)))),
            ('Q', 4, 2, ((0, F(1, 8), F(1, 4)), (F(1, 12), F(1, 6))))])
        expected = {1: ([4, 1], pure), 2: ([5, 3, 4, 2], mixed), 3: ([4, 1, 3], pure),
                    4: ([1, 4], pure), 5: ([3, 4, 2, 5], mixed)}
        for k, (sequence, end) in expected.items():
            steps = bimatrix_lemke_howson(R, C, k)
            x, y = steps[-1][3]
            self.assertEqual(([s[2] for s in steps], (normalize(x), normalize(y))), (sequence, end))

        # Dropping label 1 at the mixed equilibrium reaches the third one in two pivots.
        G2 = symmetrize(R, C)
        x, y = mixed
        z = x + y
        u = [sum(G2[i][j] * z[j] for j in range(5)) for i in range(5)]
        start = {i for i in range(5) if z[i]} | {5 + i for i in range(5) if u[i] != max(u[:3] if i < 3 else u[3:])}
        vertices, picked = symmetric_lemke_howson(G2, 1, basis=start)
        self.assertEqual(len(picked), 2)
        self.assertEqual((normalize(vertices[-1][:3]), normalize(vertices[-1][3:])), other)

        # The symmetric algorithm on [[0, R], [C^T, 0]] repeats the asymmetric pivots.
        rng = random.Random(6798)
        for _ in range(40):
            m, n = rng.randint(1, 4), rng.randint(1, 4)
            R = [[rng.randint(1, 9) for _ in range(n)] for _ in range(m)]
            C = [[rng.randint(1, 9) for _ in range(n)] for _ in range(m)]
            for k in range(1, m + n + 1):
                steps = bimatrix_lemke_howson(R, C, k)
                vertices, picked = symmetric_lemke_howson(symmetrize(R, C), k)
                self.assertEqual(picked, [s[2] for s in steps])
                self.assertEqual(vertices[1:], [s[3][0] + s[3][1] for s in steps])


def transpose(M):
    return [list(column) for column in zip(*M)]


def normalize(v):
    return tuple(F(a) / sum(v) for a in v)


def symmetrize(R, C):
    m, n = len(R), len(R[0])
    return [[0] * m + list(R[i]) for i in range(m)] + [list(transpose(C)[j]) + [0] * n for j in range(n)]


def pivot_path(tableaus, k, side):
    """Complementary pivoting on tableaus {name: (rows, rhs, basis, labels)} of
    systems M v + s = 1. Drops label k, starting in tableau `side`, and pivots
    with the lexicographic minimum ratio test until label k is picked up."""
    label, steps, left = k, [], None
    while True:
        rows, rhs, basis, labels = tableaus[side]
        # Enter the nonbasic variable with this label, other than the one that
        # just left (with a single tableau, both are momentarily nonbasic).
        col = next(c for c in range(len(labels)) if labels[c] == label and c not in basis and c != left)
        width = len(labels) - len(rows)
        key = lambda r: [rhs[r] / rows[r][col]] + [rows[r][width + j] / rows[r][col] for j in range(len(rows))]
        row = min((r for r in range(len(rows)) if rows[r][col] > 0), key=key)
        p, leaving = rows[row][col], basis[row]
        rows[row], rhs[row] = [a / p for a in rows[row]], rhs[row] / p
        for r in range(len(rows)):
            if r != row:
                f = rows[r][col]
                rows[r] = [a - f * b for a, b in zip(rows[r], rows[row])]
                rhs[r] -= f * rhs[row]
        basis[row] = col
        steps.append((side, label, labels[leaving]))
        yield steps[-1]
        if labels[leaving] == k:
            return
        label = labels[leaving]
        left = leaving if len(tableaus) == 1 else None
        side = next(s for s in tableaus if s != side) if len(tableaus) > 1 else side


def tableau(M, labels, basis=None):
    rows = [[F(a) for a in M[i]] + [F(int(i == j)) for j in range(len(M))] for i in range(len(M))]
    rhs, start = [F(1)] * len(M), list(range(len(M[0]), len(M[0]) + len(M)))
    for col in sorted(set(basis or start) - set(start)):  # pivot to a given basis
        row = next(r for r in range(len(M)) if start[r] not in (basis or start) and rows[r][col] != 0)
        p = rows[row][col]
        rows[row], rhs[row] = [a / p for a in rows[row]], rhs[row] / p
        for r in range(len(M)):
            if r != row:
                f = rows[r][col]
                rows[r] = [a - f * b for a, b in zip(rows[r], rows[row])]
                rhs[r] -= f * rhs[row]
        start[row] = col
    return rows, rhs, start, labels


def value(t, cols):
    return tuple(t[1][t[2].index(c)] if c in t[2] else 0 for c in cols)


def symmetric_lemke_howson(R, k, basis=None):
    """Walk on R z <= 1, z >= 0; z_i and w_i both represent action i."""
    n = len(R)
    t = tableau(R, [i % n + 1 for i in range(2 * n)], basis)
    vertices, picked = [value(t, range(n))], []
    for _, _, label in pivot_path({'Z': t}, k, 'Z'):
        vertices.append(value(t, range(n)))
        picked.append(label)
    return vertices, picked


def bimatrix_lemke_howson(R, C, k):
    """P = {x >= 0 : C^T x <= 1} and Q = {y >= 0 : R y <= 1}, with labels
    1..m for Row's actions and m+1..m+n for Column's."""
    m, n = len(R), len(R[0])
    P = tableau(transpose(C), list(range(1, m + n + 1)))
    Q = tableau(R, list(range(m + 1, m + n + 1)) + list(range(1, m + 1)))
    return [(side, dropped, picked, (value(P, range(m)), value(Q, range(n))))
            for side, dropped, picked in pivot_path({'P': P, 'Q': Q}, k, 'P' if k <= m else 'Q')]


def support_equilibria(R, C, symmetric=False):
    """Equilibria with equal-size supports (all of them for non-degenerate games)."""
    m, n, found = len(R), len(R[0]), []
    for size in range(1, min(m, n) + 1):
        for I, J in product(combinations(range(m), size), combinations(range(n), size)):
            if symmetric and I != J:
                continue
            sol = []
            for M, rows, cols in ((transpose(C), J, I), (R, I, J)):
                # Mix over `cols` so that every action in `rows` earns the same payoff.
                A = [[M[i][j] for j in cols] + [-1] for i in rows] + [[1] * size + [0]]
                p = solve_exact(A, [0] * size + [1])
                if p is None:
                    break
                v = [F(0)] * len(M[0])
                for j, q in zip(cols, p):
                    v[j] = q
                sol.append(tuple(v))
            if len(sol) < 2 or min(sol[0] + sol[1]) < 0:
                continue
            x, y = sol
            u = [sum(R[i][j] * y[j] for j in range(n)) for i in range(m)]
            w = [sum(C[i][j] * x[i] for i in range(m)) for j in range(n)]
            if all(u[i] == max(u) for i in I) and all(w[j] == max(w) for j in J) and (x, y) not in found:
                found.append((x, y))
    return found


def solve_exact(A, b):
    """Probabilities (all but the last unknown) of the square system A v = b,
    or None if it is singular."""
    a = [[F(v) for v in row] + [F(c)] for row, c in zip(A, b)]
    n = len(a)
    for c in range(n):
        p = next((r for r in range(c, n) if a[r][c] != 0), None)
        if p is None:
            return None
        a[c], a[p] = a[p], a[c]
        for r in range(n):
            if r != c:
                f = a[r][c] / a[c][c]
                a[r] = [x - f * y for x, y in zip(a[r], a[c])]
    return [a[r][n] / a[r][r] for r in range(n)][:-1]


if __name__ == '__main__':
    unittest.main(verbosity=2)
