#!/usr/bin/env ruby

require 'grok'

# Returns a hash: node_id => [out_degree, in_degree]
def node_degrees(pairs)
  hash = Hash.new
  pairs.each do |x, y|
    hash[x] ||= [0, 0]
    hash[y] ||= [0, 0]
    hash[x][0] += 1
    hash[y][1] += 1
  end
  return hash
end

# List of [out_degree, in_degree] pairs (one pair for each node)
def out_in_degrees(pairs)
  node_degrees(pairs).values
end

# register(:out_in_degrees)

=begin
def plot_in_out(filename, relations)
  pairs = read_rsf_pairs(filename, relations)
 
  degrees = compute_node_degrees(pairs)
 
  degrees.values.each { |x, y| puts "#{x} #{y}" }
  return degrees.values
end


if __FILE__ == $0
  if ARGV.size < 1
    puts "Usage: #{$0} filename.rsf [relation1 relation2 relation3 ...]"
    exit 1
  end
  plot_in_out(ARGV[0], ARGV[1..-1])
end
=end