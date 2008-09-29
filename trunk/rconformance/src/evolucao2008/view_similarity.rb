#!/usr/bin/env jruby

require 'java'
require '../view_matrix'

import 'design.model.Design'

import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.CharPairSimilarity'

#sim = CompleteLinkage.new(CharPairSimilarity.new)
sim = CharPairSimilarity.new
#sim2 = SimilarityPower(sim, 4)

base = '/home/rodrigo/experimentos/systems'
clusterer = 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'

design = Design.new '/home/rodrigo/experimentos/systems/l1/01_junit_l1.gxl'

vertices = design.getGraph.getVertices.toArray
n = vertices.size

matrix = fn_to_matrix(n) { |i, j| sim.similarity(vertices[i], vertices[j]) }
view_matrix(matrix, vertices.map{ |v| v.getUserDatum("label") })

#array2d = Array.new(n) { Array.new(n) { 1.0 } }
#
#0.upto(n-1) do |i|
#	i.upto(n-1) do |j|
#		array2d[i][j] = array2d[j][i] = sim.similarity(vertices[i], vertices[j])
#	end
#end
#
#array2d_to_html(array2d)
#array2d_to_html(array2d.map{|row| row.map{|e| e**4}})
