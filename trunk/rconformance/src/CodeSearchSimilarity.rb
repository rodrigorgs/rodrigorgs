#!/usr/bin/env jruby

require 'java'
require 'cache'
require 'code_search'
require 'view_matrix'
require 'uri'
require 'fileutils'

#import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
#import 'abstractor.cluster.hierarchical.AgglomerativeClusterer'
#import 'abstractor.cluster.hierarchical.CompleteLinkage'
import 'abstractor.cluster.hierarchical.Similarity'


class CodeSearchSimilarity
	include Java::AbstractorClusterHierarchical::Similarity
	CACHE_DIR = 'data'

	def initialize
		FileUtils.mkdir CACHE_DIR unless File.exist? CACHE_DIR
	end

	def similarity_ids(id1, id2)
		queries = ["lang:java #{id1} #{id2}",
				"lang:java #{id1}",
				"lang:java #{id2}"]

		results = queries.map do |q|
			begin
				cache lambda {puts 'Caching'; code_search(q)}, CACHE_DIR, URI.encode(q), CACHE_TO_S, CACHE_TO_I
			rescue Exception
				File.open(CACHE_DIR + '/' + URI.encode(q), 'w') { |f| f.write('0') }
				return 0.0
			end
		end

		#total = results[1] + results[2] - results[0]
		total = results.max
		if total == 0 then return 0.0 else return results[0].to_f / total end
	end

	def similarity(v1, v2)
		id1 = v1.getUserDatum('label')
		id2 = v2.getUserDatum('label')

		return similarity_ids(id1, id2)
	end
end

#if __FILE__ == $0
#	ids = %w(
#			junit.framework.ComparisonCompactor
#			junit.framework.Assert
#			junit.framework.TestResult
#			junit.runner.BaseTestRunner
#			junit.extensions.TestDecorator
#			junit.extensions.ActiveTestSuite
#			junit.framework.JUnit4TestAdapterCache
#			junit.framework.ComparisonFailure
#			junit.framework.TestListener
#			junit.framework.JUnit4TestAdapter
#			junit.framework.Protectable
#			junit.framework.TestCase
#			junit.runner.TestRunListener
#			junit.textui.TestRunner
#			junit.framework.AssertionFailedError
#			junit.extensions.TestSetup
#			junit.extensions.RepeatedTest
#			junit.framework.JUnit4TestCaseFacade
#			junit.runner.Version
#			junit.framework.Test
#			junit.framework.TestFailure
#			junit.textui.ResultPrinter
#			junit.framework.TestSuite).sort
#
#
#	n = ids.size
#	sim = CodeSearchSimilarity.new
#	array2d = Array.new(n) { Array.new(n) { 1.0 } }
#
#	0.upto(n-1) do |i|
#		i.upto(n-1) do |j|
#			puts "Comparing: #{ids[i]} - #{ids[j]}"
#			array2d[i][j] = array2d[j][i] = sim.similarity_ids(ids[i], ids[j])
#		end
#	end
#
#	puts "Visualizaing array..."
#	array2d_to_html(array2d)
#		
#end
#
