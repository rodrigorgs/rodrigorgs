require 'tempfile'

# matrix is an array of arrays
def array2d_to_html(array2d)
	file = Tempfile.new('array2d')

	file.puts '<table border="0" cellpadding="0" cellspacing="0">'
	array2d.each do |row|
		file.puts '<tr>'
		row.each do |n| 
			color = "#00#{"%2X" % (255*n).to_i}00"
			file.puts "<td bgcolor=\"#{color}\">#{'%.2f' % n}</td>" 
		end
		file.puts '</tr>'
	end

	`firefox #{file.path}`
	#file.close
end

#---------------------------------#
if false
	require 'java'
	import 'design.model.Design'

	import 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'
	import 'abstractor.cluster.hierarchical.CompleteLinkage'
	import 'abstractor.cluster.hierarchical.CharPairSimilarity'

	#sim = CompleteLinkage.new(CharPairSimilarity.new)
	sim = CharPairSimilarity.new

	base = '/home/rodrigo/experimentos/systems'
	clusterer = 'abstractor.cluster.hierarchical.DerivedAgglomerativeClusterer'

	design = Design.new '/home/rodrigo/experimentos/systems/l1/06_SweetHome3D_l1.gxl'

	vertices = design.getGraph.getVertices.toArray
	n = vertices.size

	array2d = Array.new(n) { Array.new(n) { 1.0 } }

	0.upto(n-1) do |i|
		i.upto(n-1) do |j|
			array2d[i][j] = array2d[j][i] = sim.similarity(vertices[i], vertices[j])
		end
	end

	array2d_to_html(array2d)
end
