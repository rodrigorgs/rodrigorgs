require 'set'

class DocSpace
	attr_reader :doc_list, :terms, :idf, :weight

	def initialize
		@doc_list = []
	end
	
	def add_doc(doc)
		@doc_list << doc
		return doc
	end

	def add_text(text)
		doc = Document.new text
		@doc_list << doc
		return doc
	end

	def done
		@terms = []
		@doc_list.each { |doc| @terms += doc.terms }
		@terms.uniq!

		compute_idf
		compute_weights
	end

	def compute_idf
		@idf = Hash.new
		@terms.each do |term|
			c = @doc_list.select { |d| d.contain? term }.size
			@idf[term] = if c == 0 then 
				@idf[term] = 0 
			else 
				@idf[term] = Math.log(@doc_list.size.fdiv c)
			end
		end
	end

	# TODO: compute weights also for queries
	def compute_weights
		@weight = Hash.new #Array.new(@terms.size) { Array.new(@doc_list.size) }
		
		@terms.each do |term|
			@doc_list.each do |doc|
				@weight[[term,doc]] = doc.freq_rel(term) * @idf[term]
			end
		end
	end

	def dist(doc, query)
		num = 0
		den1 = 0
		den2 = 0
		@terms.each do |term|
			num += @weight[[term,doc]] * @weight[[term,query]]
			den1 += @weight[[term,doc]]**2
			den2 += @weight[[term,query]]**2
		end
		return num.fdiv (Math.sqrt(den1) * Math.sqrt(den2))
	end
end

class Document
	#attr_reader :freq_rel

	def freq_rel(term)
		@freq_rel[term] || 0
	end

	def initialize(text)
		@text = text
		@freq_abs = Document::compute_term_freq(text)
	
		max_freq = @freq_abs.values.max
		@freq_rel = Hash.new
		@freq_abs.each_pair { |k, v| @freq_rel[k] = v.fdiv max_freq }
	end

	def contain?(term)
		@freq_abs.has_key? term
	end

	def self.compute_term_freq(text)
		freq = Hash.new(0)
		words = text.split(/[^A-Za-z]/).map {|x| x.downcase}.
			select { |x| !x.empty? }
		words.each do |w| freq[w] += 1 end
		return freq
	end

	def terms
		@freq_abs.keys
	end
end


space = DocSpace.new

a = space.add_text <<EOL
This is the JMX interface for the runtime statistics for the data node. Many of the statistics are sampled and averaged on an interval which can be specified in the config file.

For the statistics that are sampled and averaged, one must specify a metrics context that does periodic update calls. Most do. The default Null metrics context however does NOT. So if you aren't using any other metrics context then you can turn on the viewing and averaging of sampled metrics by specifying the following two lines in the hadoop-meterics.properties file:

        dfs.class=org.apache.hadoop.metrics.spi.NullContextWithUpdateThread
        dfs.period=10
  

Note that the metrics are collected regardless of the context used. The context with the update thread is used to average the data periodically.

Name Node Status info is reported in another MBean 
EOL

b = space.add_text <<EOL
This Interface defines the methods to get the status of a the FSDataset of a data node. It is also used for publishing via JMX (hence we follow the JMX naming convention.)

Data Node runtime statistic info is report in another MBean 
EOL

c = space.add_text <<EOL
This class is for maintaining the various DataNode statistics and publishing them through the metrics interfaces. This also registers the JMX MBean for RPC.

This class has a number of metrics variables that are publicly accessible; these variables (objects) have methods to update their values; for example:

blocksRead.inc() 
EOL

space.done

p space.terms
p space.idf

puts space.dist a, b
puts space.dist a, c
puts space.dist b, c
