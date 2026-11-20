import numpy as np
from scipy.special import logsumexp

class MWU:

    # learning_rate = 0.01

    def __init__(self, squares: int, values: list[int], troops: int):
        self.squares = squares
        self.values = np.array(values)
        self.troops = troops
        self.all_strategies = []
        strat = [0] * squares
        self.generate_strategies(strat, 0, self.all_strategies, troops)
        self.num_vertices = len(self.all_strategies)
        self.all_strategies = np.array(self.all_strategies)
        self.cur_mix = -np.ones(self.num_vertices) * np.log(self.num_vertices)
        self.sum_mix = -np.ones(self.num_vertices) * np.log(self.num_vertices)

    def to_one_hot(self, strat):
        one_hot = np.zeros((self.squares, self.troops + 1))
        for i, v in enumerate(strat):
            one_hot[i, v] = 1
        return one_hot

    def generate_strategies(self, strat, index, all_strategies, troops):
        if index == len(strat)-1:
            strat[index] = troops
            all_strategies.append(self.to_one_hot(strat))
            return
        
        for i in range(troops + 1):
            strat[index] = i
            self.generate_strategies(strat, index + 1, all_strategies, troops - i)

    def mix_to_strategy(self, mix):
        return np.sum(self.all_strategies * np.exp(mix)[:, None, None], axis=0)

    def cur_strategy(self):
        return self.mix_to_strategy(self.cur_mix)

    def compute_grad(self, strategy):
        grad = np.zeros_like(strategy)
        grad[:, 1:] = np.cumsum(strategy, axis=1)[:, :-1]
        grad[:, :-1] -= np.cumsum(strategy[:, ::-1], axis=1)[:, :-1][:, ::-1]
        return grad * self.values[:, None]

    def compute_value(self, s1, s2):
        val = 0
        for i in range(self.squares):
            for j in range(self.troops + 1):
                for k in range(self.troops + 1):
                    if j > k:
                        val += self.values[i] * s1[i][j] * s2[i][k]
                    elif j < k:
                        val -= self.values[i] * s1[i][j] * s2[i][k]
        return val

    def update_mix(self, grad):
        self.cur_mix += self.learning_rate * np.sum(self.all_strategies * grad[None, :, :], axis=(1, 2))
        self.cur_mix -= logsumexp(self.cur_mix)
        self.sum_mix = np.logaddexp(self.sum_mix, self.cur_mix)

    def run(self, num_steps: int):
        for _ in range(num_steps):
            self.learning_rate = 1.5 / (1 + _) ** 0.5
            strategy = self.cur_strategy()
            grad = self.compute_grad(strategy)
            # upd = np.sum(self.all_strategies * grad[None, :, :], axis=(1, 2))
            # masked = upd[np.where(self.cur_mix > -20)]
            # if _ % 100 == 0:
            #     print(np.mean(masked), np.std(masked))
            self.update_mix(grad)
            
        return self.cur_strategy(), self.mix_to_strategy(self.sum_mix - np.log(num_steps+1))
    
def print_summary(mwu, strategy):
    all_vals = np.array([mwu.compute_value(strategy, x) for x in mwu.all_strategies])
    print()
    print(all_vals.mean())
    print(all_vals.min())

if __name__ == "__main__":
    mwu = MWU(4, [1, 2, 3, 4], 10)
    iterate, avg = mwu.run(100000)
    print_summary(mwu, iterate)
    print_summary(mwu, avg)
