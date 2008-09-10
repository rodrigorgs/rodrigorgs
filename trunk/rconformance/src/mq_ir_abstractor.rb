#!/usr/bin/env jruby
require 'java'

require 'set'
require 'ir_distance'
require 'MQFuzzyRanker'

import 'edu.uci.ics.jung.graph.Vertex'
import 'abstractor.util.FileUtilities'
import 'abstractor.cluster.mq.MQClusterer'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'
import 'DummyDoclet'    

def list_of_packages(srcpath)
	packages = Set.new

	Dir.glob("#{srcpath}/**/*.java") do |file|
		IO.readlines(file).grep(/^package (.+);/) { packages.add $1 }
	end

	p packages.to_a

	return packages.to_a
end

def create_space(srcpath)
	packages = list_of_packages(srcpath)
	params = ['-sourcepath', srcpath, '-quiet',
			'-doclet', 'DummyDoclet', 
			'-docletpath', '.'] + packages
	Java::ComSunToolsJavadoc::Main.execute(params.to_java :string)

	space = DocSpace.new
	root = DummyDoclet.rootDoc
	root.classes.each do |c|
		doc = Document.new(c.qualifiedName, c.commentText)
		space.add_doc doc
	end
	space.done
	return space
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

def abstract_ir(inputFilename, outputFilename, srcpath)
	space = create_space(srcpath)
	ranker = MQFuzzyRanker.new(IRDistance.new(space))
	abstract(inputFilename, outputFilename, ranker)
end

def html(srcpath, outstream)
	space = create_space(srcpath)
	distances = []
	n = space.doc_list.size
	puts "-- Number of elements: #{n}"
	docs = space.doc_list.values.dup

	(0..n-1).each do |i|
		doc1 = docs[i]
		(i+1..n-1).each do |j|
			doc2 = docs[j]
			distances << [doc1, doc2, space.dist(doc1, doc2)] if doc1 != doc2
		end
	end

	distances.sort! { |a, b| b[2] <=> a[2] }

	outstream.puts "<table border=\"1\">"
	distances.first(20).each do |d|
		outstream.puts "<tr>"
		(0..1).each { |i| 
			outstream.puts "<td valign=\"top\">#{'%.2f' % d[2]} - 
			<b>#{d[i].name}</b><br/>#{d[i].text}</td>"
		}
		outstream.puts "<tr/>"
	end
	outstream.puts "</table>"

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
	'convergenceThreshold' => '0.2', #'1.0E-6',
	'maxIterations' => '20', # '1000'
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

#abstract_ir '../resources/gxl/junit-3.8.1_l1.gxl',
#		'out.gxl',
#		'../resources/src/junit-3.8.1'

File.open('vai.html', 'w') do |file|
	html '../resources/src/javaparser-1.0.3/src', file
end
