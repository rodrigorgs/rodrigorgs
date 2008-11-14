#!/usr/bin/env jruby

require 'java'
require 'design'
import 'design.util.Measures'
import 'design.model.Design'

def intra_pairs(clustering)
  clustering_ids = []
  clustering.each do |cluster|
    clustering_ids << cluster.map { |v| v.getUserDatum("id") }
  end

  intra = []
  clustering_ids.each do |cluster|
    cluster.each do |x|
      cluster.each do |y|
        intra << [x, y]
      end
    end
  end
  return intra
end

def pr(clustering, expert)
  intra_clustering = intra_pairs(clustering)
  intra_expert = intra_pairs(expert)
  #p intra_expert

  common = intra_clustering & intra_expert

  precision = common.size.to_f / intra_clustering.size
  recall = common.size.to_f / intra_expert.size
  f_measure = (2*precision*recall) / (precision + recall)

  return {:precision => precision, :recall => recall, :f_measure => f_measure}
end


if __FILE__ == $0
  INPUT_DIR='l1'
  PKG_DIR='l2'
  OUTPUT_DIR='out'
  minThreshold = 5
  maxThreshold = 100

  fields = []
  fields << "system"
  fields << "out_filename"
  fields << "f_measure"
  fields << "precision"
  fields << "recall"
  fields << "score"
  fields << "mojo"
  fields << "ned"
  fields << "n_clusters"
  fields << "n_classes"
  fields << "max_cluster_rel_size"
  fields << "min_cluster_abs_size"

  # TODO: precision/recall

  puts fields.join("\t")

  Dir.glob("#{INPUT_DIR}/*.gxl").sort.each do |input_filename|
    filename = File.basename(input_filename)
    pkg_filename = "#{PKG_DIR}/#{filename}"

    #puts "#{pkg_filename}"
    #puts "-" * pkg_filename.size

    pkg_design = Design.new(pkg_filename)

    files = [pkg_filename] + Dir.glob("#{OUTPUT_DIR}/**/#{filename}").sort
    len = files.inject(0) { |max, s| [s.size, max].max }
    files.each do |out_filename|
      out_design = Design.new(out_filename)
      clustering = Clustering.from_design(out_design).clustering
      expert = Clustering.from_design(pkg_design).clustering

      mojo_n = Measures::mojo(out_design, pkg_design)
      ned_n = Measures::nonExtremeDistribution(out_design, 0, minThreshold, maxThreshold)
      score_n = mojo_n * (2 - ned_n)**2 #0.5
      prf = pr(clustering, expert)

      system = filename
      precision = '%.2f' % prf[:precision]
      recall = '%.2f' % prf[:recall]
      f_measure = '%.2f' % prf[:f_measure]
      score = '%.2f' % score_n
      mojo = '%3d' % mojo_n
      ned = '%.2f' % ned_n
      out_filename += " " * (len - out_filename.size)
      n_clusters = clustering.size
      n_classes = clustering.flatten.size
      max_cluster_rel_size = '%.2f' % (clustering.map{|x| x.size}.max / n_classes.to_f)
      min_cluster_abs_size = '%3d' % (clustering.map{|x| x.size}.min)

      row = '"' + fields.map{|x| '#{' + x + '}'}.join("\t") + '"'
      puts eval(row)
    end

    puts
  end
end
