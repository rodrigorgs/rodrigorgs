#!/usr/bin/env jruby

require 'java'
require 'design'
import 'design.util.Measures'
import 'design.model.Design'

if __FILE__ == $0
  INPUT_DIR='l1'
  PKG_DIR='l2'
  OUTPUT_DIR='out'
  minThreshold = 5
  maxThreshold = 100

  puts "Measures: mojo, NED (#{minThreshold}-#{maxThreshold})"

  Dir.glob("#{INPUT_DIR}/*.gxl").sort.each do |input_filename|
    filename = File.basename(input_filename)
    pkg_filename = "#{PKG_DIR}/#{filename}"

    puts "#{pkg_filename}"
    puts "-" * pkg_filename.size

    pkg_design = Design.new(pkg_filename)

    files = [pkg_filename] + Dir.glob("#{OUTPUT_DIR}/**/#{filename}").sort
    len = files.inject(0) { |max, s| [s.size, max].max }
    files.each do |out_filename|
      out_design = Design.new(out_filename)
      clustering = Clustering.from_design(out_design).clustering

      out_filename += " " * (len - out_filename.size)
      
      mojo = Measures::mojo(out_design, pkg_design)
      ned = Measures::nonExtremeDistribution(out_design, 0, minThreshold, maxThreshold)
      score = mojo * (2 - ned)**1 #0.5
      puts "#{out_filename} \t#{mojo}\t" +
          "#{'%.2f' % ned}\t" +
          "#{'%.2f' % score}\t" +
          "#{clustering.size}\t" +
          "#{clustering.flatten.size}"
    end

    puts
  end
end
