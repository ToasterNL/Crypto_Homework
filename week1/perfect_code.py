# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
"""Crack perfect code cryptosystem graphs"""
import scipy.linalg
import random

# Graph structure: {str_name: (int_value, [str_neighbours], bool_selected)}

def solve(graph):
    """Solve graph for pre-summed values using linear algebra"""
    variables = sorted(graph.keys())
    matrix_data = []
    vector_b = scipy.array([graph[x][0] for x in variables]).astype(int)
    for node in variables:
        a_row = []
        for variable in variables:
            used = variable in graph[node][1] or variable == node
            coefficient = 1 if used else 0
            a_row.append(coefficient)
        matrix_data.append(a_row)

    matrix_a = scipy.matrix(matrix_data)

    try:
        solutions = scipy.linalg.solve(matrix_a, vector_b)
    except scipy.linalg.LinAlgError:
        print ''.join(["Warning: Matrix is not singular, ",
                "closest approximation using least-squares follows"])
        solutions = scipy.linalg.lstsq(matrix_a, vector_b)[0]
    return solutions.round().astype(int)

def connect(graph, node_a, node_b):
    """Connect two nodes in the graph"""
    graph[node_a][1].append(node_b)
    graph[node_b][1].append(node_a)
    return graph

def get_random_node(graph, current_node):
    """Get a random unselected node from the graph"""
    random_node = None
    loop_cnt = 0
    # Get a node
    # that is not selected,
    # not the same node we are in
    # and not already connected
    while (not random_node
            or graph[random_node][2]
            or random_node == current_node
            or random_node in graph[current_node][1]):
        random_node = random.choice(graph.keys())
        loop_cnt += 1
        if loop_cnt > len(graph.keys()):
            return None
    return random_node

def create_graph(values=xrange(0, 100), selection_chance=30, fuzz_chance=20):
    """Create a graph with given characteristics"""
    graph = {}

    # Step 0: Draw nodes
    for i in range(0, len(values)):
        graph[i] = (values[i], [], False)
    secret_original = sum([graph[x][0] for x in graph.keys()])

    # Step 1: select random selection of nodes (and mark them)
    selected_nodes = random.sample(graph.keys(),
                                   (10*len(values)/selection_chance))
    for i in selected_nodes:
        graph[i] = (graph[i][0], graph[i][1], True)

    # Step 2: connect all nodes to selected nodes
    for i in range(0, len(values)):
        # if not selected
        if not graph[i][2]:
            # connect to random selected node
            connecting_node = random.choice(selected_nodes)
            graph[i][1].append(connecting_node)
            graph[connecting_node][1].append(i)
    assert all(len(graph[i][1]) > 0 or graph[i][2] for x in graph.keys())

    # Step 3: randomly connect unselected nodes
    for repetitions in xrange(0, 20):
        for i in graph.keys():
            # if not selected, fuzz_chance % of times
            if not graph[i][2] and random.randint(0, 100) < fuzz_chance:
                connecting_node = get_random_node(graph, i)
                if connecting_node:
                    graph = connect(graph, i, connecting_node)

    # Step 4: sum up connecting nodes
    new_graph = {}
    secret_check = 0
    for node in graph:
        new_graph[node] = (
           sum([graph[x][0] for x in graph[node][1]]) + graph[node][0],
           graph[node][1],
           graph[node][2]
        )
        if new_graph[node][2]:
            secret_check += new_graph[node][0]

    assert secret_check == secret_original
    return secret_original, new_graph


def create_random_graph(size=100,
                        selection_chance=30,
                        fuzz_chance=20,
                        minnum=-20,
                        maxnum=20):
    """Create a random graph with given characteristics"""
    return create_graph(
             [random.randint(minnum, maxnum) for x in xrange(0, size)],
             selection_chance,
             fuzz_chance)

def main():
    """Crack the graphs we have, and crack some large random ones"""
    # The graph from homework assignment 1
    graph_1 = {
                    'A': (17,['F','H']),
                    'B': (3,['G','E',]),
                    'C': (-4,['D','E']),
                    'D': (16,['C','F','H']),
                    'E': (4,['B','C','H']),
                    'F': (14,['A','D',]),
                    'G': (10,['B']),
                    'H': (12,['A','D','E']),
            }

    # The graph from the first lecture's slides
    graph_slides = {
                    'A': (5,['C','D','G']),
                    'B': (6,['F','G',]),
                    'C': (4,['A']),
                    'D': (5,['A','H','E','G']),
                    'E': (7,['D']),
                    'F': (2,['B','G','H']),
                    'G': (11,['A','B','D','F']),
                    'H': (2,['D','F']),
            }

    # The graph of my friend Mark
    graph_mark = {
                    'A': (276,['C','D','E','F']),
                    'B': (80,['D',]),
                    'C': (110,['A']),
                    'D': (173,['A','B','E']),
                    'E': (150,['A','D','G']),
                    'F': (63,['A','H']),
                    'G': (90,['E']),
                    'H': (53,['F']),
            }
    ciphertexts = {'Slides':       graph_slides,
                   'Mark\'s':      graph_mark,
                   'Assignment 1': graph_1}

    for ciphertext in ciphertexts:
        print "%s graph" % ciphertext
        sol = solve(ciphertexts[ciphertext])
        print "Cracking result: %i" % sum(sol)

    for graph_size in [20, 50, 100, 1000]:
        print "%i node graph" % graph_size
        secret, random_graph = create_random_graph(graph_size)
        print "Secret: %i" % secret
        sol = solve(random_graph)
        print "Cracking result: %i" % sum(sol)
        assert sum(sol) == secret

if __name__ == "__main__":
    main()
