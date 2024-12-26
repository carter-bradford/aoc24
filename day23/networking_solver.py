import networkx as nx
from itertools import combinations

def read_input(filename):
    with open(filename, 'r') as file:
        return file.readlines()

def create_graph(input_lines):
    G = nx.Graph()
    for line in input_lines:
        node1, node2 = line.strip().split('-')
        G.add_edge(node1, node2)
    return G

def get_t_nodes(network_graph):
    t_nodes = [n for n in network_graph if n.startswith('t')]
    seen_triangles = set()
    for t in t_nodes:
        neighbors = list(network_graph.neighbors(t))
        for i in range(len(neighbors)):
            for j in range(i + 1, len(neighbors)):
                if network_graph.has_edge(neighbors[i], neighbors[j]):
                    triangle = tuple(sorted([t, neighbors[i], neighbors[j]]))
                    seen_triangles.add(triangle)
    return len(seen_triangles)
    

input_lines = read_input('network.txt')
network_graph = create_graph(input_lines)

print(f"Number of triangles with at least one 't' node: {get_t_nodes(network_graph)}")

largest_clique = max(nx.find_cliques(network_graph), key=len)
print("Size of the biggest LAN Party:", len(largest_clique))
print("Nodes in LAN Party:", ','.join(sorted(largest_clique)))