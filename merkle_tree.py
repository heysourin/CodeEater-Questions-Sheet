import hashlib

class MerkleTree:
    def __init__(self, transactions):
        self.transactions = transactions
        self.levels = self.build_merkle_tree()

    def build_merkle_tree(self):
        levels = [self.transactions]
        while len(levels[-1]) > 1:
            level = []
            for i in range(0, len(levels[-1]), 2):
                node = hashlib.sha256()
                node.update(levels[-1][i])
                if i+1 < len(levels[-1]):
                    node.update(levels[-1][i+1])
                level.append(node.digest())
            levels.append(level)
        return levels

    def get_root(self):
        return self.levels[-1][0]
