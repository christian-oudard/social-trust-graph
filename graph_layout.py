import sys
import networkx as nx
import matplotlib.pyplot as plt

# Read the DOT file
graph = nx.drawing.nx_pydot.read_dot(sys.argv[1])

# Apply a layout algorithm (e.g., spring layout)
pos = nx.spring_layout(graph)

# Draw the nodes
nx.draw_networkx_nodes(graph, pos, node_size=800, node_color='lightblue')

# Get the edge styles and colors
edge_styles = nx.get_edge_attributes(graph, 'style')
edge_colors = ['red' if style == 'dashed' else 'black' for style in edge_styles.values()]

# Draw the edges
nx.draw_networkx_edges(graph, pos, edge_color=edge_colors, style=edge_styles.values())

# Draw the edge labels
edge_labels = nx.get_edge_attributes(graph, 'label')
nx.draw_networkx_edge_labels(graph, pos, edge_labels=edge_labels)

# Draw the node labels, strip quotes.
node_labels = nx.get_node_attributes(graph, 'label')
node_labels = {node: label.strip('"') for node, label in node_labels.items()}
nx.draw_networkx_labels(graph, pos, labels=node_labels, font_size=8)

# Show the plot
plt.axis('off')
plt.tight_layout()
plt.show()
