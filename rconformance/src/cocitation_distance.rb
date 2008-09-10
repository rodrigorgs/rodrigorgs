require 'java'

import 'com.google.gdata.client.codesearch.CodeSearchService'
import 'com.google.gdata.data.codesearch.CodeSearchFeed'
import 'com.google.gdata.util.common.xml.XmlWriter'
import 'java.io.PrintWriter'

require 'net/http'
require 'uri'
require 'tempfile'

def get_code(codeUrl)
	s = ''
	go = false
	Net::HTTP.get_response URI.parse(codeUrl) do |res|
		res.read_body.each_line do |line|
			go = true if !go && line =~ /<div id="code">/
			s += line if go
		end
	end

	input = Tempfile.new('code')
	File.open(input.path, 'w') { |w| w.puts(s) }
	opts = "-no-references -no-numbering -dump-width 255"
	cmd = "elinks #{opts} -dump #{input.path}"
	ret = `#{cmd}`
	input.delete
	return ret
end

query = "objectweb"

service = CodeSearchService.new("exampleCo-example1")
feedUrl = Java::JavaNet::URL.new("http://www.google.com/codesearch/feeds/search?q=#{query}") # TODO: URI.escape

res = service.getFeed feedUrl, CodeSearchFeed.java_class
e = res.getEntries[0]

puts e.getFile.getName

codeUrl = res.getEntries[0].getHtmlLink.getHref
puts get_code(codeUrl)
