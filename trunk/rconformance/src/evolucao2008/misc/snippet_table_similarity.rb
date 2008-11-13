require 'java'

import 'abstractor.util.FileUtilities'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'

import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.CharPairSimilarity'
import 'abstractor.cluster.hierarchical.TableSimilarity'

import 'abstractor.cluster.hierarchical.AgglomerativeClusterer'

require '../view_matrix'
require '../view_clusters'

# ---------

filename = '/home/rodrigo/experimentos/systems/l1/01_junit_l1.gxl'

# ---------

design = Design.new filename
vertices = design.getGraph.getVertices.to_a
n = vertices.size

cpsim = CharPairSimilarity.new

ruby_array = fn_to_array(n) { |i, j| cpsim.similarity vertices[i], vertices[j] }
java_array = ruby_array.to_java(Java::double[])

tsim = TableSimilarity.new(java_array)
sim = tsim

list = java.util.ArrayList.new
0.upto(n-1) { |x| list.add java.lang.Integer.new(x) }

agg = AgglomerativeClusterer.new(list, CompleteLinkage.new(tsim))
clusters = agg.getClusters(0.5).to_a

view_clusters(clusters) { |x| vertices[x].getUserDatum('shortlabel') }


