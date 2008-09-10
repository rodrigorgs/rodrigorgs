#!/usr/bin/env jruby
require 'java'

import 'abstractor.util.FileUtilities'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'
import 'abstractor.cluster.ClusterFacade'

import 'abstractor.cluster.ContainerClusterer'
import 'abstractor.cluster.DerivedEdgeBetweennessClusterer'
import 'abstractor.cluster.DerivedKMeansClusterer'
import 'abstractor.cluster.DerivedVoltageClusterer'
import 'abstractor.cluster.DerivedWeakComponentClusterer'
import 'abstractor.cluster.EdgeCollapser'
import 'abstractor.cluster.GeneralClusterer'
import 'abstractor.cluster.RegexClusterer'
import 'abstractor.cluster.dsm.DSMClusterer'
import 'abstractor.cluster.mq.MQClusterer'

$clusterers = {'container' => ContainerClusterer,
	'modularizationquality' => MQClusterer,
	'dsm' => DSMClusterer,
	'edgebetweenness' => DerivedEdgeBetweennessClusterer,
	'kmeans' => DerivedEdgeBetweennessClusterer,
	'regularexpressions' => RegexClusterer,
	'voltage' => DerivedVoltageClusterer,
	'weakcomponent' => DerivedWeakComponentClusterer}


def abstract(propFilename, inputFilename, outputFilename, args)
	puts "Loading design..."
	d = Design.new inputFilename
	puts "Done"

	props = FileUtilities.loadProperties(propFilename)

	puts "Levels: from 0 to #{d.size - 1}"
	graph = d.getGraph(args["level"] || d.size - 1)

	ctype = props.getProperty("clustererType").downcase
	clusterer = $clusterers[ctype].new(graph, props)

	d.addGraph(clusterer.getClusteredDesign);

	d.saveDesign outputFilename
end

propFilename = ARGV.shift
inputFilename = ARGV.shift
outputFilename = ARGV.shift
args = Hash.new

while !ARGV.empty?
	case ARGV.shift
		when '-level'
			args["level"] = ARGV.shift.to_i
	end
end

abstract propFilename, inputFilename, outputFilename, args

