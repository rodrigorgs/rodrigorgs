require 'java'

import 'com.google.gdata.client.codesearch.CodeSearchService'
import 'com.google.gdata.data.codesearch.CodeSearchFeed'

service = CodeSearchService.new("exampleCo-example1")
feedUrl = Java::JavaNet::URL.new('http://www.google.com/codesearch/feeds/search?q=objectweb')

res = service.getFeed feedUrl, CodeSearchFeed.java_class
puts res.getEntries.size
puts res.getEntries[0].getFile.getName

p res.getEntries[0].getLinks(nil, nil).to_a[0].getHref

#feedUrl = Java::JavaNet::URL.new res.getNextLink.getHref
#res = service.getFeed feedUrl, CodeSearchFeed.java_class
#p res.getEntries.to_a
