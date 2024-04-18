import networkx as nx
import matplotlib.pyplot as plt

graph = nx.drawing.nx_pydot.read_dot('output.dot')
pos = nx.kamada_kawai_layout(graph)

# Draw the graph
nx.draw(
    graph,
    pos=pos,
    with_labels=True,
    node_size=500,
    node_color='lightblue',
    font_size=12,
    font_weight='bold',
)

# Read edge-style attributes
edge_styles = nx.get_edge_attributes(graph, 'style')

# Add edge labels
labels = nx.get_edge_attributes(graph, 'label')
nx.draw_networkx_edge_labels(graph, pos, edge_labels=labels)

# Show the plot
plt.axis('off')
plt.tight_layout()
plt.show()
