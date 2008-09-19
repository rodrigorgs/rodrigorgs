#!/usr/bin/env jruby
require 'java'
require 'fileutils'
require 'abstractor'

# base_dir is .../systems. TODO: adapt to .../versions
def batch_cluster(base_dir, name)
	dir1 = base_dir + '/data/' + name
	dir2 = base_dir + '/output/' + name
	[dir1, dir2].each { |dir| FileUtils.mkdir(dir) unless File.exist? dir }

	Dir.glob("#{base_dir}/l1/*.gxl") do |input|
		output = input.sub('/l1/', "/output/#{name}/").sub('_l1', "_#{name}_l2")
		puts "== From: " + input
		puts "== To: " + output
		puts
		yield input, output
	end
end

if false
	base = '/home/rodrigo/experimentos/systems'
	clusterer = 'abstractor.cluster.DerivedEdgeBetweennessClusterer'
	args = {:numEdgesToRemove => 50}

	batch_cluster(base, 'bli') do |input, output|
		abstract clusterer, input, output, args
	end
end
