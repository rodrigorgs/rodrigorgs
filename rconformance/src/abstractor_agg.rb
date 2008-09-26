#!/usr/bin/env jruby
require 'java'

import 'abstractor.util.FileUtilities'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'
#import 'abstractor.cluster.ClusterFacade'

#import 'abstractor.cluster.ContainerClusterer'
#import 'abstractor.cluster.DerivedEdgeBetweennessClusterer'
#import 'abstractor.cluster.DerivedKMeansClusterer'
#import 'abstractor.cluster.DerivedVoltageClusterer'
#import 'abstractor.cluster.DerivedWeakComponentClusterer'
#import 'abstractor.cluster.EdgeCollapser'
#import 'abstractor.cluster.GeneralClusterer'
#import 'abstractor.cluster.RegexClusterer'
#import 'abstractor.cluster.dsm.DSMClusterer'
#import 'abstractor.cluster.mq.MQClusterer'
import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.AgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.Similarity'

#$clusterers = {'container' => ContainerClusterer,
#	'modularizationquality' => MQClusterer,
#	'dsm' => DSMClusterer,
#	'edgebetweenness' => DerivedEdgeBetweennessClusterer,
#	'kmeans' => DerivedEdgeBetweennessClusterer,
#	'regularexpressions' => RegexClusterer,
#	'voltage' => DerivedVoltageClusterer,
#	'weakcomponent' => DerivedWeakComponentClusterer}


# String similarity used in UMLDiff
class CharPairSimilarity
	include Similarity
	
	def similarity(v1, v2)
		if v1.nil? || v2.nil? then return 0.0 end
		s1 = v1.getUserDatum('label').enum_cons(2).to_a.uniq
		s2 = v2.getUserDatum('label').enum_cons(2).to_a.uniq
		return 2.0 * (s1 & s2).size / (s1.size + s2.size)
	end
end

def abstract(propFilename, inputFilename, outputFilename, args=nil)
	puts "Loading design..."
	d = Design.new inputFilename
	puts "Done"

	props = FileUtilities.loadProperties propFilename
	#props = Java::JavaUtil::Properties.new
	props.setProperty 'height', '0.1'

	graph = d.getGraph

	puts 'Clustering...'
	similarity = CompleteLinkage.new(CharPairSimilarity.new)
	agg = DerivedAgglomerativeClusterer.new(graph, similarity, props)

	#d.addGraph(agg.getClusteredDesign);

	#d.saveDesign outputFilename
end

#abstract '/tmp/classcluster.properties', ARGV[0], ARGV[1]
#propFilename = ARGV.shift
#inputFilename = ARGV.shift
#outputFilename = ARGV.shift
#args = Hash.new
#
#while !ARGV.empty?
#	case ARGV.shift
#		when '-level'
#			args["level"] = ARGV.shift.to_i
#	end
#end
#
#abstract propFilename, inputFilename, outputFilename, args
