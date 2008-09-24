#!/usr/bin/env jruby

require 'java'
require '../view_table'

import 'design.model.Design'

import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.CharPairSimilarity'
import 'abstractor.cluster.hierarchical.SimilarityPower'

#sim = CompleteLinkage.new(CharPairSimilarity.new)
sim = CharPairSimilarity.new
#sim2 = SimilarityPower(sim, 4)

base = '/home/rodrigo/experimentos/systems'
clusterer = 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'

design = Design.new '/home/rodrigo/experimentos/systems/l1/06_SweetHome3D_l1.gxl'

vertices = design.getGraph.getVertices.toArray
n = vertices.size

array2d = Array.new(n) { Array.new(n) { 1.0 } }

0.upto(n-1) do |i|
	i.upto(n-1) do |j|
		array2d[i][j] = array2d[j][i] = sim.similarity(vertices[i], vertices[j])
	end
end

array2d_to_html(array2d)
array2d_to_html(array2d.map{|row| row.map{|e| e**4}})
