#!/usr/bin/env jruby
require 'java'
require 'fileutils'
require 'set'

import 'abstractor.util.FileUtilities'
import 'edu.uci.ics.jung.graph.Graph'
import 'design.model.Design'
#import 'abstractor.cluster.hierarchical.Similarity'

class CharPairSimilarity
	#include Similarity
	
	def similarity(v1, v2)
		s1 = Set.new
		s2 = Set.new
		v1.getUserDatum('shortlabel').split(/\s*/).each_cons(2) { |x| s1 << x }
		v2.getUserDatum('shortlabel').split(/\s*/).each_cons(2) { |x| s2 << x }
		value = (2.0 * (s1 & s2).size) / (s1.size + s2.size)
		# puts 'value = ' + value.to_s
		return value
	end
end

def gxl_to_csv(inputFilename, outputFilename)
	puts "Loading design from #{inputFilename}"
	d = Design.new inputFilename
	puts "Done"

	graph = d.getGraph #(d.size - 1)
	
	sim = CharPairSimilarity.new

	vertices = graph.getVertices.toArray
	n = graph.numVertices
	File.open(outputFilename, 'w') do |out|
		out.puts n
		table = Array.new(n) { Array.new(n) }
		0.upto(n-1) do |i|
			puts "#{i+1} / #{n}"
			i.upto(n-1) do |j|
				table[i][j] = table[j][i] = sim.similarity(vertices[i], vertices[j])
			end
		end
		table.each do |row|
			out.puts row.join(',')
		end

		vertices.each do |v|
			out.puts v.getUserDatum('shortlabel')
			out.puts v.getUserDatum('label')
			out.puts v.getUserDatum('id')
		end
	end
end

files = Dir.glob('/home/roberto/experimentos/systems/l1/*.gxl') + \
	Dir.glob('/home/roberto/experimentos/versions/*/l1/*.gxl')
files.sort!

puts "Processing #{files.size} directories."

files.each_with_index do |file, i|
	puts "Directory #{i+1}/#{files.size}: #{file}"
	gxl_to_csv file, '/home/rodrigo/csv/' + file.gsub('/', '__')
end

gxl_to_csv ARGV[0], ARGV[1]
