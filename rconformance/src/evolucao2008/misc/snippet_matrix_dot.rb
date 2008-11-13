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

sim = CharPairSimilarity.new

ruby_array = fn_to_array(n) { |i, j| sim.similarity vertices[i], vertices[j] }
java_array = ruby_array.to_java(Java::double[])

#list = java.util.ArrayList.new
#0.upto(n-1) { |x| list.add java.lang.Integer.new(x) }

agg = AgglomerativeClusterer.new(vertices, CompleteLinkage.new(sim))
clusters = agg.getClusters(0.5)
sort_list = AgglomerativeClusterer.flatten(clusters).to_a

int_sort_list = sort_list.map { |v| vertices.index(v) }

view_matrix_dots(ruby_array, 3)
sort_matrix! ruby_array, int_sort_list
view_matrix_dots(ruby_array, 3)

# TODO: parece que o resultado eh sempre o mesmo, nao importa qual a altura de
# corte escolhida
