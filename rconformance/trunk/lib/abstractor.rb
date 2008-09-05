#!/usr/bin/env jruby
require 'java'

require 'set'
require 'ir_distance'

import 'edu.uci.ics.jung.graph.Vertex'
import 'abstractor.util.FileUtilities'
import 'abstractor.cluster.mq.MQClusterer'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'
import 'DummyDoclet'    

def list_of_packages(srcpath)
	packages = Set.new

	Dir.glob("#{srcpath}/**/*.java") do |file|
		IO.readlines(file).grep(/package (.*);/) { packages.add $1 }
	end

	return packages.to_a
end

def create_space(srcpath)
	packages = list_of_packages(srcpath)
	params = ['-sourcepath', srcpath, 
			'-doclet', 'DummyDoclet', 
			'-docletpath', '.'] + packages
	Java::ComSunToolsJavadoc::Main.execute(params.to_java :string)

	space = DocSpace.new
	root = DummyDoclet.rootDoc
	root.classes.each do |c|
		puts c.qualifiedName
		doc = Document.new(c.qualifiedName, c.commentText)
		space.add_doc doc
	end
	space.done
end

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

def abstract_ir(inFilename, outFilename, srcpath)
	# ...
end

def properties
	prop = Java::JavaUtil::Properties.new
	hash = {'clustererType' => 'modularizationQuality',
	'verboseMode' => 'true',
	'logFile' => 'MQLog.log',
	'keepUnclustered' => 'false',
	'edgeType' => 'multiple',
	'MQAlgorithm' => 'RANDOMIZED_SEARCH',
	'optimizationFunction' => 'TURBO',
	'convergenceThreshold' => '1.0E-6',
	'maxIterations' => '1000',
	'numPaths' => '10'
	}
	hash.each_pair do |key, value|
		prop.setProperty key, value
	end
	return prop
end

def abstract(inputFilename, outputFilename, ranker) 
	d = Design.new inputFilename

	props = properties

	graph = d.getGraph(d.size - 1)
	mqClusterer = MQClusterer.new(graph, props);
	mqClusterer.setRanker(ranker)
	d.addGraph(mqClusterer.getClusteredDesign);

	d.saveDesign outputFilename
end

create_space '../resources/src/junit-3.8.1'
