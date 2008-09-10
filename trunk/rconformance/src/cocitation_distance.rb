require 'java'

import 'com.google.gdata.client.codesearch.CodeSearchService'
import 'com.google.gdata.data.codesearch.CodeSearchFeed'
import 'com.google.gdata.data.codesearch.CodeSearchEntry'

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

class CodeSearchEntry
	def code
		get_code self.getHtmlLink.getHref
	end
end

def search(query, maxresults=nil)
	service = CodeSearchService.new("exampleCo-example1")
	feedUrl = Java::JavaNet::URL.new("http://www.google.com/codesearch/feeds/search?q=#{URI.escape(query)}")
	count = 0
	while true
		res = service.getFeed feedUrl, CodeSearchFeed.java_class
		res.getEntries.each do |e|
			yield e
			count += 1
			return if (!maxresults.nil? && count == maxresults)
		end
		nextLink = res.getNextLink
		if nextLink.nil?
			break
		else
			feedUrl = service.getFeed nextLink.getHref, CodeSearchFeed.java_class
		end
	end
end

def main
	search("// TODO", 2) do |entry|
		puts entry.getFile.getName
		puts entry.code
	end
end

main
