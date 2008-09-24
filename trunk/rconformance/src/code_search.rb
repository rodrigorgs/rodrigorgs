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

STOP_SEARCH = 'Please stop searching!'

# FIXME: can't return more than 10 results
# TODO: handle server error (error 500)
def code_search(query, &block)
	service = CodeSearchService.new("exampleCo-example1")
	# TODO: use Query (from gdata API) instead of constructing a query string
	feedUrl = Java::JavaNet::URL.new("http://www.google.com/codesearch/feeds/search?q=#{URI.escape(query)}")
	count = 0
	res = service.getFeed feedUrl, CodeSearchFeed.java_class
	results_count = res.getTotalResults

	while !block.nil?
		res.getEntries.each do |e|
			count += 1
			r = block.call e, count
			return results_count if r == STOP_SEARCH
		end
		nextLink = res.getNextLink
		if nextLink.nil?
			break
		else
			# FIXME: exception here
			feedUrl = service.getFeed nextLink.getHref, CodeSearchFeed.java_class
			res = service.getFeed feedUrl, CodeSearchFeed.java_class
		end
	end

	return results_count
end

def main
	r = code_search("// TODO") do |entry, i|
		puts "#{i}: #{entry.getFile.getName}"
		#puts entry.code
		STOP_SEARCH if i == 2
	end
	
	puts "Total results: #{r}"
end

if __FILE__ == $0
	main
end

