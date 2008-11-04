#!/usr/bin/env jruby

require 'plot_degree_dist'
require '../rconformance/src/plot'

def compute_node_degrees(pairs)
  hash = Hash.new #([0, 0]) # [out, in]
  pairs.each do |x, y|
    hash[x] ||= [0, 0]
    hash[y] ||= [0, 0]
    hash[x][0] += 1
    hash[y][1] += 1
  end
  return hash
end

def plot_in_out(filename, relations)
  pairs = read_rsf_pairs(filename, relations)
  
  degrees = compute_node_degrees(pairs)
  
  data = []
  degrees.values.each { |p| data << p }
  
  
  #File.open('bli.graph', 'w') { |f| data.each { |xy| f.puts xy.join("\t") } }
  data = {' ' => data}
	plot data, :type => :ScatterPlot,
			:title => "#{filename} - #{relations.join(', ')}",
			:filename => "#{filename}-outXin-#{relations.join(',')}.png",
      :labelx => 'out degree', :labely => 'in degree', :legend => false
end


if __FILE__ == $0
  if ARGV.size < 1
    puts "Usage: #{$0} filename.rsf [relation1 relation2 relation3 ...]"
    exit 1
  end
  plot_in_out(ARGV[0], ARGV[1..-1])
end
