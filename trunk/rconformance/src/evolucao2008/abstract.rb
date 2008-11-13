#!/usr/bin/env jruby

require 'java'
require 'fileutils'
require 'design'

def dendogram(table)
  n = table.size
  return Dendogram.new agg_hier_cluster(n, CompleteLinkage.new(TableSimilarity.new(table)))
end

def name_generator(filename)
  dirname = File.dirname(filename)
  basename = File.basename(filename)
  components = basename.split /\./
  filepart = components[0..-2].join('.')
  extpart = components[-1]
  return Proc.new do |output_dir| #|label, output_dir| 
    base = output_dir.nil? && dirname || output_dir
    FileUtils.mkdir_p(base) unless File.exist? base
    #"#{base}/#{filepart}-#{label}.#{extpart}"
    "#{base}/#{basename}"
  end
end

def time(&block)
  t1 = Time.now.tv_sec
  block.call
  t2 = Time.now.tv_sec
  return (t2 - t1)
end

def gogogo(filename)
  fname = name_generator(filename)
  d = ClassDesign.new filename
  n = d.size

  puts "size = #{n}"

  save_cuts = Proc.new do |table, name, h|
    dendo = dendogram(table)
    #clustering = dendo.cut(0.75) #.to_vertices(d)
    #d.save_clustering(clustering, fname.call("#{name}75"))
    clustering = dendo.cut(h) #.to_vertices(d)
    d.save_clustering(clustering, fname.call("#{name}"))
  end


  ################################################## 
 
  print "Jaccard... "
  jac = nil
  puts time {
    jac = fn_to_array(n) { |i, j| jaccard_coefficient(d.depends[i], d.depends[j]) }
    save_cuts.call(jac, 'out/1_jac', 0.90)
  }

  ################################################## 

  print "Jaccard + Euclidean... "
  euc = nil
  puts time {
    euc = fn_to_array(n) { |i, j| euclidean_distance(jac[i], jac[j]) }
    max = euc.inject(0) { |acc, v| [acc, v.max].max }
    euc.each { |v| v.map! { |x| max - x } }
    save_cuts.call(euc, 'out/2_euc', 0.90)
  }

  ################################################## 

  k = 5
  h = 0.75
  print "Jaccard + kNN (k = #{k}, h = #{h})... "
  knn_table = nil
  puts time {
    knn_table = knn(jac, k)
    save_cuts.call(knn_table, 'out/3_knn', h)
  }

  ##################################################
  
  print "Jaccard + kNN + SNN... "
  snn_table = nil
  puts time {
    snn_table = snn_from_knn(knn_table)
    save_cuts.call(snn_table, 'out/4_snn', 0.75)
  }

end

if __FILE__ == $0
  Dir.glob('l1/*.gxl').sort.each do |f| 
    puts "== #{f} =="
    gogogo(f)
    puts
  end
end

