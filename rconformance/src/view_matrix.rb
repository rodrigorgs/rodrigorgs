require 'tempfile'
require 'matrix'

def fn_to_array(n, &block)
	array = Array.new(n) { Array.new(n) { 1.0 } }
	0.upto(n - 1) do |i|
		(i + 1).upto(n - 1) do |j|
			array[i][j] = array[j][i] = block.call(i, j)
		end
	end
	return array
end

def fn_to_matrix(n, &block)
	array = fn_to_array(n, &block)
	return Matrix[*array]
end

# matrix is an array of arrays
def view_matrix(matrix, labels)
	tmp = Tempfile.new('mview')
	path = tmp.path
	tmp.close!

	File.open(path, 'w') do |file|
		file.puts '<table border="0" cellpadding="0" cellspacing="0">'
		file.puts "<tr><td></td>"
		0.upto(matrix.row_size-1) { |i| file.puts "<td align=\"center\">#{i}</td>" }
		file.puts "</tr>"
		0.upto(matrix.row_size-1) do |i|
			file.puts "<tr><td><tt><b>#{'%3i' % i}</b></tt>&nbsp;#{labels[i]}</td>"
			matrix.row(i) do |n|
				color = "#00#{"%02X" % (255*n).to_i}00"
				file.puts "<td bgcolor=\"#{color}\">#{'%.2f' % n}</td>" 
			end
			file.puts '</tr>'
		end
	end

	`firefox #{path}`
	#file.close
end

