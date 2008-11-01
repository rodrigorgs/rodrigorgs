require 'uri'
include URI::Escape

txt = STDIN.read
pages = []
txt.scan(/title="(User:RodrigoRocha.*?)"/) { |page| pages << $1 }

print pages.map{ |p| encode(p) }.join('%0D%0A')
