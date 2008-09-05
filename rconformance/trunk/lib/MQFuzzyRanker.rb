#!/usr/bin/env jruby
require 'java'

# TODO: cleanup imports
import 'edu.uci.ics.jung.graph.Graph'
import 'edu.uci.ics.jung.graph.Vertex'
import 'edu.uci.ics.jung.graph.impl.SparseVertex'
import 'edu.uci.ics.jung.graph.impl.SparseGraph'
import 'edu.uci.ics.jung.graph.impl.DirectedSparseEdge'
import 'edu.uci.ics.jung.graph.impl.UndirectedSparseEdge'
import 'edu.uci.ics.jung.algorithms.blockmodel.GraphCollapser' 

import 'abstractor.cluster.mq.optimization.MQTurboRanker'
import 'abstractor.cluster.mq.optimization.MQRanker'
import 'abstractor.cluster.jung.VertexClusterSet'
import 'abstractor.cluster.GeneralClusterer'
import 'abstractor.cluster.ContainerClusterer'
import 'abstractor.cluster.RegexClusterer'
import 'abstractor.util.FileUtilities'

import 'design.model.Design'
import 'design.model.HierarchicalSparseGraph'
import 'design.util.Utilities'

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
		return somatorio_e / ((k * (k - 1)) / 2.0)
	end

	def calculateMQ(clusterSet)
		intra_connectivity = calculate_cohesion(clusterSet)
		inter_connectivity = calculate_inter(clusterSet)

		return inter_connectivity - intra_connectivity
	end
end

class Distance
	def distance(e1, e2)
		0.5
	end
end

# ranker = MQFuzzyRanker.new(Distance.new)
