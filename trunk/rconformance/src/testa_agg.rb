#!/usr/bin/env jruby
require 'java'
require 'fileutils'

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
import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
import 'abstractor.cluster.hierarchical.CharPairSimilarity'
import 'abstractor.cluster.hierarchical.Similarity'
import 'abstractor.cluster.hierarchical.SimilarityCacher'
import 'abstractor.cluster.hierarchical.CompleteLinkage'

#class CharPairSimilarity
#	include Similarity
#	
#	def similarity(v1, v2)
#		if v1.nil? || v2.nil? then return 0.0 end
#		s1 = v1.getUserDatum('shortlabel').split(/\s*/).enum_cons(2).to_a.uniq
#		s2 = v2.getUserDatum('shortlabel').split(/\s*/).enum_cons(2).to_a.uniq
#		value = (2.0 * (s1 & s2).size) / (s1.size + s2.size)
#		#puts 'value = ' + value.to_s
#		if (value.nan? || value < 0.0 || value > 1.0) then return 0.0 end
#		return value
#	end
#end

# extracted from http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_substring#Ruby
def lcs(s1, s2)
    num=Array.new(s1.size){Array.new(s2.size)}
    len,ans=0
 
   s1.scan(/./).each_with_index do |l1,i |
     s2.scan(/./).each_with_index do |l2,j |
 
        unless l1==l2
           num[i][j]=0
        else
          (i==0 || j==0)? num[i][j]=1 : num[i][j]=1 + num[i-1][j-1]
          len = ans = num[i][j] if num[i][j] > len
        end
     end
   end
 
   ans
end


def abstract(propFilename, inputFilename, outputFilename, args={})
	puts "Loading design..."
	d = Design.new inputFilename
	puts "Done"

	puts "reading props from " + propFilename
	props = FileUtilities.loadProperties(propFilename)
	args.each_pair { |key, value| props.setProperty(key, value) }
	graph = d.getGraph #(d.size - 1)

	sim = CharPairSimilarity.new
	complink = CompleteLinkage.new(sim)
	#complink = SimilarityCacher.new(complink)
	clusterer = DerivedAgglomerativeClusterer.new(graph, complink, props)

	d.addGraph(clusterer.getClusteredDesign);

	d.saveDesign outputFilename
end


#abstract propFilename, inputFilename, outputFilename, args

def run_experiment(propFilename)
	base = '/home/rodrigo/experimentos'
	height = '0.9'
	name = "pair#{height}"
	dir1 = base + '/data/' + name
	dir2 = base + '/output/' + name
	[dir1, dir2].each do |dir|
		FileUtils.mkdir(dir) unless File.exist? dir
	end
	Dir.glob('/home/rodrigo/experimentos/l1/*.gxl') do |input|
		output = input.sub('/l1/', "/output/#{name}/").sub('_l1', "_#{name}_l2")
		puts "===" + input
		abstract propFilename, input, output, {'height' => height}
	end
end

run_experiment ARGV[0]
