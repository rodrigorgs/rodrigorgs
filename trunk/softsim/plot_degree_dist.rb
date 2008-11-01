# graph_pairs = [[id1, id2], [íd1, id2], ...]

def read_rsf_pairs(filename, relations=nil)
	relations = [relations] if !relations.nil? && !relations.kind_of?(Array)

	pairs = []
	lines = IO.readlines(filename)
	lines.map{ |line| line.strip.split(/\s+/) }.each do |rel, e1, e2|
		pairs << [e1, e2] if relations.nil? || relations.include?(rel)
	end

	return pairs
end

def compute_degrees(edges)
	out_degrees = Hash.new(0)
	in_degrees = Hash.new(0)
	edges.each do |from, to|
		out_degrees[from] += 1
		in_degrees[to] += 1
	end

	return {:in => in_degrees, :out => out_degrees}
end

# degrees: a hash from node_id to degree
# output: a hash from degree to count
def degree_vs_node_count(degrees)
	node_count = Hash.new(0)
	degrees.each_pair { |id, degree| node_count[degree] += 1 }
	return node_count
end

def cumulative_plot(hash)
	cum_hash = hash.dup
	hash.each_pair do |degree, count|
		0.upto(degree - 1) { |k| cum_hash[k] += 1 }
	end
	return cum_hash
end

# node_count: a hash from degree to count
# output: a hash from degree to count(degree >= k)
def cumulative_degree_vs_node_count(degrees)
	return cumulative_plot(degree_vs_node_count(degrees))
	#cum_node_count = node_count.dup
	#node_count.each_pair do |degree, count|
	#	0.upto(degree - 1) { |k| cum_node_count[k] += 1 }
	#end
end

def xy_hash_to_xy_list(hash)
	return hash.to_a
end

# -------------------------------------------------

require '../rconformance/src/plot'

def plot_degree_vs_node_count(filename, relations)
	pairs = read_rsf_pairs(filename, relations)

	degrees = compute_degrees(pairs)
	data = {}
	data[:in] = cumulative_degree_vs_node_count(degrees[:in]).to_a
	data[:out] = cumulative_degree_vs_node_count(degrees[:out]).to_a
	data.each_pair do |k, plott|
		plott.map! { |xypair| [Math.log(xypair[0]), Math.log(xypair[1])] }
		plott.delete_if { |xypair| !xypair[0].infinite?.nil? || !xypair[1].infinite?.nil? }
	end
	p data
	plot data, :type => :ScatterPlot, :view => true, 
			:title => "#{filename} (log-log)"
end

plot_degree_vs_node_count(ARGV[0], %w[depends_on])

