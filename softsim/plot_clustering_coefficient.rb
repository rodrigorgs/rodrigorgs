#!/usr/bin/env jruby

require 'plot_degree_dist'

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


def entities(pairs)
  pairs.flatten.uniq
end

require 'set'
# undirected
def compute_clustering_coefficients(pairs)
  STDERR.puts pairs.size
  # remove duplicate pairs -- note that [a, b] == [b, a]
  pairs = pairs.map{ |pair| pair.sort }.uniq
  STDERR.puts pairs.size
  hash = {}
  entities(pairs).each do |e|
    entity_pairs = pairs.select { |pair| pair.include? e }
    neighbors = entities(entity_pairs) - [e]
    neighbors_pairs = pairs.select{ |pair| (pair & neighbors).size == 2 }
    
    n = neighbors_pairs.size # number of linked neighbors
    k = entity_pairs.size # degree
    c_k = (2 * n).to_f / (k * (k - 1))
    hash[e] = [k, c_k] unless c_k.nan?
  end
  return hash
end

filename = ARGV[0]
relations = ARGV[1..-1]
pairs = read_rsf_pairs(filename, relations)
hash = compute_clustering_coefficients(pairs)
#plot hash.values, :filename => "#{filename}-clust.png"
hash.values.each do |k, c_k|
  puts "#{k}\t#{c_k}"
end

=begin
def plot_clustering_coefficient(filename, relations)
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
=end
