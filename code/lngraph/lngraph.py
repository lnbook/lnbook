#!/usr/bin/env python3
# coding: utf-8

import networkx as nx
import matplotlib.pyplot as plt
import sys
import ujson as json

get_ipython().run_line_magic('matplotlib', 'inline')

filename = 'lngraph0721'


# Load channel graph exported from LND
# To create the JSON file, use the following command
# on an LND node that is fully synced:
# lndcli describegraph > filename.json

describegraph = open(filename+'.json', 'r')
lngraph = json.load(describegraph)



# Construct network graph
graph = nx.Graph()

# Add edges and nodes
for edge in lngraph['edges']:
    # Name the nodes by last 4 characters of node ID
    node1 = edge['node1_pub'][-4:]
    node2 = edge['node2_pub'][-4:]

    graph.add_node(node1)
    graph.add_node(node2)
    graph.add_edge(node1, node2)

# Show graph info before reduction
print(nx.info(graph))

# Remove nodes with fewer than 3 channels to make graph cleaner
remove = [node for node,degree in dict(graph.degree()).items() if degree < 3]
graph.remove_nodes_from(remove)

# Show graph info after reduction
print(nx.info(graph))





# Set figure/diagram options (thin grey lines for channels, black dots for nodes)
options = {
    "node_color": "black",
    "node_size": 2,
    "edge_color" : "grey",
    "linewidths": 0,
    "width": 0.01,
}

# 16:9 image ratio
fig = plt.figure(figsize=(16,9))

# Spring layout arranges nodes automatically.
# Channels cause "attraction" (spring), nodes cause "repulsion" (opposite)
# k controls distance between nodes. Spread them out to make graph less dense
# Seed for reproducible layout
pos = nx.spring_layout(graph,k=0.4, iterations=10, seed=721)
nx.draw(graph, pos, **options)

# Save PNG image
plt.savefig(filename+'.png', format="png", dpi=600)
