#!/usr/bin/env jruby

require 'tempfile'

# clusters is a list of lists
def view_clusters(clusters, &block)
	tmp = Tempfile.new('viewc')
	filename = tmp.path
	tmp.close!

	block = lambda{|x| x} if block.nil?

	File.open(filename, 'w') do |file|
		file.puts "<html><body>"
		file.puts "<ul>"
		clusters.each_with_index do |cluster, i|
			file.puts "<li>Cluster #{i}</li>"
			file.puts "<ul>"
			cluster.each { |entity| file.puts "<li>#{block.call(entity)}</li>" }
			file.puts "</ul>"
		end
		file.puts "</ul>"
		file.puts "</body></html>"
	end

	`firefox #{filename}`
end

# view_clusters([[:banana, :maca], [:aviao, :carro]]) { |e| e.to_s.upcase }

