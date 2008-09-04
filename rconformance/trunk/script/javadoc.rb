#!/usr/bin/env ruby

require 'set'

packages = Set.new
sourcepath = ARGV.shift || '.'

Dir.glob("#{sourcepath}/**/*.java") do |file|
	IO.readlines(file).grep(/package (.*);/) { packages.add $1 }
end

command = "javadoc #{ARGV.join(' ')} #{packages.to_a.join(' ')}"
puts "Running command #{command}"
puts `#{command}`
