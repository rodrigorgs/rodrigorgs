require 'find'
require 'exif'

Find.find('.') do |path|
  basename = File.basename(path)
  if basename.size > 3 && basename.upcase[-3..-1] == 'JPG'
    t = Exif.new(path)['Date and Time'].gsub(/[ :]/, '')
    t = t[0..-3] + '.' + t[-2..-1]
    `touch -m -t #{t} "#{path}"`
  end
end
