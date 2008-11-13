#!/usr/bin/env jruby

require 'abstract'
import 'design.util.Measures'
import 'design.model.Design'

if __FILE__ == $0
  Dir.glob('l1/*.gxl').sort.each do |input_filename|
    pkg_filename = 'l2/' + File.basename(input_filename)
    puts "== #{input_filename} =="
    
    d = ClassDesign.new input_filename
    n = d.size
    pkg_design = Design.new pkg_filename

    jac = fn_to_array(n){|i,j| jaccard_coefficient(d.depends[i], d.depends[j])}
    puts "#{dendogram(jac).cut(0.75).size}"


    [5, 10, 15, 20].each do |k|
      [0.10, 0.25, 0.50, 0.75, 0.90].each do |height|
        knn_table = knn(jac, k)
        clustering = dendogram(knn_table).cut(height)
        clustering.each { |cluster| cluster.map! { |i| d.vertices[i] } }
        out_design = Clustering.from_array(clustering, d.graph).design
        ned = Measures::nonExtremeDistribution(out_design, 0, 5, 100) 
        mojo = Measures::mojo(out_design, pkg_design)

        puts "k = #{'%2d' % k}, h = #{'%.2f' % height}  ==>  " +
            "#{'%2d' % clustering.size}, #{'%.2f' % ned}, #{'%4d' % mojo}"
      end
    end
  end
end
