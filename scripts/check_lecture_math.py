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


if __name__ == '__main__':
    unittest.main(verbosity=2)
