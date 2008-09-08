#!/usr/bin/env ruby

require 'set'

def javadoc(sourcepath, args)
	packages = Set.new

	Dir.glob("#{sourcepath}/**/*.java") do |file|
		IO.readlines(file).grep(/package (.*);/) { packages.add $1 }
	end

	command = "javadoc #{args.join(' ')} #{packages.to_a.join(' ')}"
	puts "Running command #{command}"
	puts `#{command}`
	
end

#sourcepath = ARGV.shift || '.'
#javadoc sourcepath, ARGV
