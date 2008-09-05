#!/usr/bin/env jruby
require 'java'

import 'edu.uci.ics.jung.graph.Graph'

import 'abstractor.cluster.mq.optimization.MQRanker'
import 'abstractor.cluster.mq.MQClusterer'
import 'abstractor.util.FileUtilities'

import 'design.model.Design'

class MQFuzzyRanker
	include MQRanker

	def initialize(distance_metric)
		@distance_metric = distance_metric
	end

	def each_pair(set)
		set.each do |e1|
			set.each do |e2|
				yield e1, e2
			end
		end
	end

	def calculate_cohesion(clusterSet)
		cohesion = 0.0
		clusterSet.iterator.each do |cluster|
			cluster_cohesion = 0.0
			each_pair(cluster) do |e1, e2|
					cluster_cohesion += @distance_metric.distance(e1, e2)
			end
			cluster_cohesion /= cluster.size**2
			cohesion += cluster_cohesion
		end
		cohesion /= clusterSet.size
		return cohesion
	end

	def calculate_inter(clusterSet)
		sumE = 0.0
		each_pair(clusterSet.iterator) do |cluster1, cluster2|
			sumEpsilon = 0.0
			cluster1.each do |e1|
				cluster2.each do |e2|
					sumEpsilon += @distance_metric.distance(e1, e2)
				end
			end
			sumE += sumEpsilon / (2 * cluster1.size * cluster2.size)
		end
		k = clusterSet.size
		return sumE / ((k * (k - 1)) / 2.0)
	end

	def calculateMQ(clusterSet)
		intra_connectivity = calculate_cohesion(clusterSet)
		inter_connectivity = calculate_inter(clusterSet)

		return intra_connectivity - inter_connectivity
	end
end

class Distance
	def initialize
		@dists = Hash.new
	end

	def distance(e1, e2)
		d = @dists[[e1,e2]]
		if d.nil?
			d = rand
			@dists[[e1,e2]] = d
			return d
		else
			return d
		end
		#0.5 # rand
	end
end

# --------------------------------------------------------------------

require 'ir_distance'
import 'edu.uci.ics.jung.graph.Vertex'

class IRDistance
	def initialize(doc_space)
		@doc_space = doc_space
	end

	def distance(e1, e2)
		d1 = @doc_space.doc_list[e1.getUserDatum('label')]
		d2 = @doc_space.doc_list[e2.getUserDatum('label')]
		#assert { !d1.nil?}
		#assert { !d2.nil?}

		return @doc_space.dist(d1, d2)
	end
end

def abstract(inputFilename, outputFilename, propFilename) #, srcfolder)
	d = Design.new inputFilename

	props = FileUtilities.loadProperties propFilename

	graph = d.getGraph(d.size - 1)
	mqClusterer = MQClusterer.new(graph, props);
	mqClusterer.setRanker(MQFuzzyRanker.new(Distance.new))
	d.addGraph(mqClusterer.getClusteredDesign);

	d.saveDesign outputFilename
end

p abstract

abstract ARGV[0], ARGV[1], 'mqcluster.properties'

# ranker = MQFuzzyRanker.new(Distance.new)
