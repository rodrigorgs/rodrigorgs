#!/usr/bin/env jruby

require 'java'
require 'RAgglomerativeClusterer'

import 'design.util.Measures'
import 'design.model.Design'

import 'edu.uci.ics.jung.graph.Graph'
import 'edu.uci.ics.jung.graph.Vertex'
import 'edu.uci.ics.jung.graph.impl.SparseVertex'
import 'edu.uci.ics.jung.graph.impl.SparseGraph'
import 'edu.uci.ics.jung.graph.impl.DirectedSparseEdge'
import 'edu.uci.ics.jung.graph.impl.UndirectedSparseEdge'
import 'edu.uci.ics.jung.algorithms.blockmodel.GraphCollapser'
import 'design.model.HierarchicalSparseGraph'
import 'abstractor.cluster.jung.VertexClusterSet'
import 'edu.uci.ics.jung.utils.UserData'

class Clustering
  attr_reader :design, :graph, :clustering

  def initialize(design, graph, clustering)
    @design, @graph, @clustering = design, graph, clustering
  end

  def self.from_design(design)
    clustering = design.getGraph.getVertices.to_a.map do |collapsed_vertex|
      collapsed_vertex.getRootSet.to_a
    end

    return Clustering.new(design, design.getGraph, clustering)
  end

  def self.from_gxl(filename)
    design = Design.new filename
    return self.from_design(design)
  end

  def self.from_array(clustering, base_graph)
    clustering = clustering
    graph = HierarchicalSparseGraph.new
    graph.importUserData base_graph

    clusterSet = VertexClusterSet.new graph

    i = 0
    clustering.each do |cluster|
      set = Java::JavaUtil::HashSet.new(cluster)
      collapsed = GraphCollapser::CollapsedSparseVertex.new(set)
      collapsed.addUserDatum('id', "cluster#{i}", UserData::SHARED)
      collapsed.addUserDatum('shortlabel', "#{i}", UserData::SHARED)
      collapsed.addUserDatum('label', "#{i}", UserData::SHARED)
      collapsed.addUserDatum('type', "module", UserData::SHARED)
      graph.addVertex collapsed
      i += 1
    end

    design = Design.new(graph)

    return Clustering.new(design, graph, clustering)
  end

  def save_gxl(filename)
    @design.saveDesign(filename)
  end
end

class ClassDesign
  attr_reader :design, :vertices, :depends

  def initialize(filename)
    @design = Design.new filename
    @vertices = @design.getGraph.getVertices.to_a
    
    n = @vertices.size
    @depends = fn_to_array(n) do |i, j|
      if @vertices[i].findEdge(@vertices[j]).nil? then 0 else 1 end
    end
  end

  def graph
    @design.getGraph
  end

  def size
    @vertices.size
  end

  def ids
    @vertices.map { |x| x.getUserDatum("id") }
  end

  def labels
    @vertices.map { |x| x.getUserDatum("label") }
  end

  def save_clustering(clustering, filename)
    clustering = clustering.dup
    clustering.each { |cluster| cluster.map! { |i| @vertices[i] } }
    Clustering.from_array(clustering, graph).save_gxl(filename)
  end
end
