#!/usr/bin/env ruby

require 'set'


def assert
	raise "Assertion failed !" unless yield # if $DEBUG
end


class DocSpace
	attr_reader :doc_list, :terms, :idf, :weight

	def initialize
		@doc_list = Hash.new
	end
	
	def add_doc(doc)
		@doc_list[doc.name] = doc
		return doc
	end

	def done
		@terms = []
		@doc_list.values.each { |doc| @terms += doc.terms }
		@terms.uniq!

		compute_idf
		compute_weights
	end

	def compute_idf
		@idf = Hash.new
		@terms.each do |term|
			c = @doc_list.values.select { |d| d.contain? term }.size
			if c == 0 then 
				@idf[term] = 0  # TODO: does it make sense in IR?
			else 
				@idf[term] = Math.log(@doc_list.size / (0.0 + c))
			end
		end
	end

	# TODO: compute weights also for queries
	def compute_weights
		@weight = Hash.new
		
		@terms.each do |term|
			@doc_list.values.each do |doc|
				value = doc.freq_rel(term) * @idf[term]
				@weight[[term,doc]] = value

				assert { value >= 0 }
			end
		end
	end

	def weight(keyval)
		@weight[keyval] || 0.0
	end

	def dist(doc, query)
		num = 0
		den1 = 0
		den2 = 0
		@terms.each do |term|
			num += weight([term,doc]) * weight([term,query])
			den1 += weight([term,doc])**2
			den2 += weight([term,query])**2
		end
		den = Math.sqrt(den1) * Math.sqrt(den2)
		if den == 0
			return num # TODO: does it make sense in IR?
		else
			return (0.0 + num) / den
		end
	end
end

class Document
	#attr_reader :freq_rel
	attr_reader :name, :text

	def freq_rel(term)
		@freq_rel[term] || 0
	end

	def initialize(name, text)
		@name = name
		@text = text
		@freq_abs = Document::compute_term_freq(text)
	
		max_freq = @freq_abs.values.max
		@freq_rel = Hash.new
		@freq_abs.each_pair { |k, v| @freq_rel[k] = (0.0 + v) / max_freq }
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

DELIMITER = '---IRDelimiter---'

def create_space(instream)
	space = DocSpace.new
	# TODO: catch EOF exception
	line = ''
	line = instream.readline while line.strip != DELIMITER

	# TODO: catch empty document (input consists of two delimiters)
	while !instream.eof?
		name = instream.readline.strip
		text = ''
		begin 
			line = instream.readline
			text += line if line.strip != DELIMITER
		end while line.strip != DELIMITER
		space.add_doc(Document.new name, text)
	end

	space.done
	return space
end

def print_dists(instream, outstream)
	space = create_space(instream)

	docs = space.doc_list.values
	n = docs.size
	(0..n-1).each do |i|
		(i..n-1).each do |j|
			outstream.puts "#{docs[i].name} #{docs[j].name} #{space.dist(docs[i], docs[j])}"
		end
	end
end

#print_dists STDIN, STDOUT
