#!/usr/bin/env jruby
require 'java'

import 'abstractor.util.FileUtilities'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'

def abstract(clusterer, inputFilename, outputFilename, params)
	puts "Loading design..."
	d = Design.new inputFilename
	puts "Done"

	if params[:propfile]
		props = FileUtilities.loadProperties(params[:propfile])
		params.delete :propfile
	else
		props = Java::JavaUtil::Properties.new
		props.setProperty 'verboseMode', 'false'
		props.setProperty 'keepInternal', 'false'
		props.setProperty 'keepUnclustered', 'false'
		props.setProperty 'edgeType', 'simple'
	end
	params.each_pair { |k,v| props.setProperty(k.to_s, v.to_s) }

	graph = d.getGraph

	if clusterer.kind_of? String
		import clusterer
		classname = clusterer.split('.')[-1]
		clusterer = eval "#{classname}.new(graph, props)"

		#klass = Java::JavaClass.for_name(clusterer)
		#clusterer = klass.new(graph, props)
	#elsif clusterer.kind_of? Class
	#	clusterer = clusterer.new(graph, props)
	end

	#ctype = props.getProperty("clustererType").downcase
	#clusterer = $clusterers[ctype].new(graph, props)

	d.addGraph(clusterer.getClusteredDesign)

	d.saveDesign outputFilename

	return {:design => d, :clusterer => clusterer}
end

def help_and_exit
	puts "Usage:"
	puts "  #{$0} clusterer inputFilename outputFilename args"
	puts
	puts "Example:"
	puts "  #{$0} abstractor.cluster.DerivedEdgeBetweennessClusterer jedit_l1.gxl jedit_l2.gxl '{:numEdgesToRemove => 20}'"
	puts
	exit 1
end

if __FILE__ == $0
	#propFilename = ARGV.shift
	help_and_exit if ARGV.size < 4

	clusterer = ARGV.shift
	inputFilename = ARGV.shift
	outputFilename = ARGV.shift
	args = if ARGV.empty? then Hash.new else eval(ARGV[0]) end

	abstract clusterer, inputFilename, outputFilename, args
end

