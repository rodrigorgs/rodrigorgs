require 'tempfile'

# matrix is an array of arrays
def array2d_to_html(array2d)
	tmp = Tempfile.new('array2d')
	path = tmp.path
	tmp.close!

	File.open(path, 'w') do |file|
		file.puts '<table border="0" cellpadding="0" cellspacing="0">'
		array2d.each do |row|
			file.puts '<tr>'
			row.each do |n| 
				color = "#00#{"%02X" % (255*n).to_i}00"
				file.puts "<td bgcolor=\"#{color}\">#{'%.2f' % n}</td>" 
			end
			file.puts '</tr>'
		end
	end

	`firefox #{path}`
	#file.close
end

