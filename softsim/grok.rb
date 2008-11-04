#!/usr/bin/env ruby

def read_rsf_pairs(filename, relations=[])
	relations = [relations] if !relations.kind_of?(Array)

	pairs = []
	lines = IO.readlines(filename)
	lines.map{ |line| line.strip.split(/\s+/) }.each do |rel, e1, e2|
		pairs << [e1, e2] if relations.empty? || relations.include?(rel)
	end

	return pairs
end

