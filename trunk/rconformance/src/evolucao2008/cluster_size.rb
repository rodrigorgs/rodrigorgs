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

hash = Hash.new
Dir.glob(base + '/output/agg*/*.gxl') do |file|
	basename = 'agg'
	file =~ /\/output\/#{basename}(.*?)\//
	height = $1.to_f
	file =~ /#{basename}.*?\/(.*)_#{basename}/
	system = $1

	puts file
	design = Design.new file
	clusters = design.getClusters.size
	vertices = design.getClusters.inject(0) { |sum, cv| sum + cv.getRootSet.size }
	hash[system] = [] unless hash[system]
	hash[system] << [height, vertices.to_f / clusters]
	#hash[system] << [height, clusters]
end
plot hash, :view => true, :type => :ScatterPlot, :labelx => "Height", :labely => "Vertices / Clusters"

exit 1

3.upto(9) do |height|
	args[:height] = height / 10.0
	name = "agg#{args[:height]}"
	batch_cluster(base, name) do |input, output|
		if File.exist? output
			design = Design.new output
		else
			design = abstract(clusterer, input, output, args)[:design]
		end
		clusters = design.getClusters
		size = design.getGraph(0).getVertices.size
		
		puts "#{clusters.size} clusters"
		xy = Hash.new(0)
		clusters.each { |c| xy[c.getRootSet.size] += 1 }

		puts "Plotting..."
		data = { name => xy.to_a }
		plot data, :title => "#{clusters.size} clusters, #{size} nodes", :type => :Histogram, :view => false, :file => "#{output}.png", :labelx => 'Size', :labely => 'Number of Clusters'
	end
end
