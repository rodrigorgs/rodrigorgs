#!/usr/bin/env jruby
require 'java'

BASE_DIR = '/home/rodrigo/cvs/DesignChecker/conformance' 
Dir.glob(BASE_DIR + '/**/*.jar') { |file| require file if !(file =~ /(bkp)/)}
Dir.chdir(BASE_DIR + '/abstractor')
  
import 'edu.uci.ics.jung.graph.Graph'
import 'edu.uci.ics.jung.graph.Vertex'
import 'edu.uci.ics.jung.graph.impl.SparseVertex'
import 'edu.uci.ics.jung.graph.impl.SparseGraph'
import 'edu.uci.ics.jung.graph.impl.DirectedSparseEdge'
import 'edu.uci.ics.jung.graph.impl.UndirectedSparseEdge'
import 'edu.uci.ics.jung.algorithms.blockmodel.GraphCollapser' 

import 'abstractor.cluster.mq.optimization.MQTurboRanker'
import 'abstractor.cluster.jung.VertexClusterSet'
import 'abstractor.cluster.GeneralClusterer'
import 'abstractor.cluster.ContainerClusterer'
import 'abstractor.cluster.RegexClusterer'
import 'abstractor.util.FileUtilities'

import 'design.model.Design'
import 'design.model.HierarchicalSparseGraph'
import 'design.util.Utilities'

class SparseGraph
  def addCompleteSubgraph(noOfVertices)
    vertices = Array.new(noOfVertices) { self.addVertex(SparseVertex.new) }
    vertices.each do |u|; vertices.each do |v|
        self.addEdge(DirectedSparseEdge.new u, v)
        self.addEdge(DirectedSparseEdge.new v, u)
    end; end
    return vertices
  end
end

class VertexClusterSet
  def addCluster2(x)
    self.addCluster(Java::JavaUtil::HashSet.new x)
  end  
end

graph = SparseGraph.new

n = 2
u = graph.addCompleteSubgraph(n)
v = graph.addCompleteSubgraph(n)
c = graph.addVertex(SparseVertex.new)
graph.addEdge(DirectedSparseEdge.new u[0], c)
graph.addEdge(DirectedSparseEdge.new c, v[0])

design = Design.new graph
ranker = MQTurboRanker.new

clusterSet = VertexClusterSet.new graph
[u, v, [c]].each { |x| clusterSet.addCluster2 x } #puts(ranker.calculateMQ clusterSet)

import 'edu.uci.ics.jung.utils.UserData'
i = 0
graph.getVertices.each do |x|
  x.addUserDatum('id', "node#{i}", UserData::SHARED)
  x.addUserDatum('shortlabel', "#{i}", UserData::SHARED)
  x.addUserDatum('label', "#{i}", UserData::SHARED)
  x.addUserDatum('access', "public", UserData::SHARED)
  x.addUserDatum('type', "class", UserData::SHARED)
  i += 1 
end
Utilities.saveGXLFile('/tmp/teste.glx', graph)

hgraph = HierarchicalSparseGraph.new
map = hgraph.getSubgraphMap

hgraph.importUserData graph

i = 0
clusterSet.iterator.each do |set|
  cluster = GraphCollapser::CollapsedSparseVertex.new set
  cluster.addUserDatum('id', "cluster#{i}", UserData::SHARED)
  cluster.addUserDatum('shortlabel', "#{i}", UserData::SHARED)
  cluster.addUserDatum('label', "#{i}", UserData::SHARED)
  cluster.addUserDatum('type', "module", UserData::SHARED)
  hgraph.addVertex cluster
  i += 1  
end

design.addGraph hgraph
design.saveDesign '/tmp/teste_cc.glx'

