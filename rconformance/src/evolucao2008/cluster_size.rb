#!/usr/bin/env jruby
require '../experiment'
require '../plot'

import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.CharPairSimilarity'

sim = CompleteLinkage.new(CharPairSimilarity.new)
DerivedAgglomerativeClusterer.setSimilarity sim

base = '/home/rodrigo/experimentos/systems'
clusterer = 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
args = {:height => nil}

3.upto(9) do |height|
	args[:height] = height / 10.0
	name = "agg#{args[:height]}"
	batch_cluster(base, name) do |input, output|
		ret = abstract clusterer, input, output, args
		clusters = ret[:design].getClusters
		size = ret[:design].getGraph(0).getVertices.size
		
		puts "#{clusters.size} clusters"
		xy = Hash.new(0)
		clusters.each { |c| xy[c.getRootSet.size] += 1 }

		puts "Plotting..."
		data = { name => xy.to_a }
		plot data, :title => "#{clusters.size} clusters, #{size} nodes", :type => :Histogram, :view => false, :file => "#{output}.png", :labelx => 'Size', :labely => 'Number of Clusters'
	end
end
