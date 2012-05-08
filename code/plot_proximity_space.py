###############################
## Author: Mark Huberty
## Date:   1 May 2012
## Generates mst plots of the HS6 trade data; superior with networkx versus with
## graphviz for R
###############################

import os
import csv
import networkx as nx
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import pandas as pds
import numpy as np


os.chdir('/home/markhuberty/Documents/trade_data/unrca6')

## Define the green node data
green_nodes = ['850231', '854140']
green_labels = ['Wind turbines', 'Solar cells']
## Generate the trade data
trade_colors = pds.read_csv('../data/col_map_hs2.csv')
trade_data = pds.read_csv('../undata_yr/undata.2007.csv')

td_grouped = trade_data.groupby('cmdCode')

td_sum = td_grouped.agg({'TradeValue':np.sum})
hs6_rows = [i for i,idx in enumerate(td_sum.index) if len(str(idx))==6]
td_sum = td_sum.ix[hs6_rows]
    
## Read in the edgelist
threshold = 0.1
conn = open('summary.prox.file.period.4.csv', 'rb')
reader = csv.reader(conn, delimiter=' ')
edgelist = []
for i, row in enumerate(reader):
    if i > 0:
        if float(row[2]) >= threshold:
            edge_tuple = (row[0], row[1], 1 - float(row[2]))
            edgelist.append(edge_tuple)
conn.close()
        
g = nx.Graph()
g.add_weighted_edges_from(edgelist)
g_mst = nx.minimum_spanning_tree(g)
g_layout = nx.graphviz_layout(g_mst, prog='neato')


edges_to_add = [e for e in edgelist if e[2] < 0.47]
g_mst.add_weighted_edges_from(edges_to_add)

edge_cmap = nx.get_edge_attributes(g_mst, 'weight')
edge_cmap_val = [1 - edge_cmap[k] for k in edge_cmap.keys()]


node_color = [trade_colors['col'][list(trade_colors['hs2']).index(int(k[0:2]))]
              for k in g_mst.nodes_iter() if k not in green_nodes]
node_size = np.array([td_sum.ix[k] for k in g_mst.nodes_iter() if
                      k in td_sum.index and k not in green_nodes])
node_size = np.log(node_size / np.mean(node_size) + 1) + 0.1

nx.draw_networkx_edges(g_mst,
                       g_layout,
                       alpha=0.2,
                       edge_color=edge_cmap_val,
                       edge_cmap=plt.cm.get_cmap('YlGnBu'),
                       edge_vmin=min(edge_cmap_val),
                       edge_vmax=max(edge_cmap_val),
                       width=0.5
                       )
nx.draw_networkx_nodes(g_mst,
                       g_layout,
                       node_size=node_size,
                       node_color=node_color,
                       alpha=0.8,
                       linewidths=0.1
                       )
nx.draw_networkx_nodes(g_mst,
                       g_layout,
                       nodelist=green_nodes,
                       node_size=10,
                       node_color='green',
                       alpha=1.0,
                       linewidths=0.1,
                       node_shape='s'
                       )
nx.draw_networkx_labels(g_mst,
                        g_layout,
                        labels=dict(zip(green_nodes, green_labels)),
                        font_size=4,
                        horizontalalignment='left'
                        )
plt.axis('off')
plt.savefig('test_mst.pdf')
plt.close()
