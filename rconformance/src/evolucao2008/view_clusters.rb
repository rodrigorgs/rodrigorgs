#!/usr/bin/env jruby

require 'design'

def main(filename)
  clustering = Clustering.from_gxl(filename).clustering
  i = 0
  clustering.each do |cluster|
    puts "cluster#{i}"
    i += 1

    cluster.each do |v|
      puts "  - #{v.getUserDatum('label')}"
    end
  end
end

if __FILE__ == $0
  main ARGV[0]
end
