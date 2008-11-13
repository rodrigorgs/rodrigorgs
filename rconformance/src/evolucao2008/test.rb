#!/usr/bin/env jruby

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'RAgglomerativeClusterer'

include Test::Unit

class TC_Dendogram < Test::Unit::TestCase

  def setup
    @sim = [
    # 1     2     3     4     5     6
    [1.00, 0.76, 0.78, 0.63, 0.66, 0.77],  # 1
    [0.76, 1.00, 0.855, 0.80, 0.86, 0.75], # 2
    [0.78, 0.855, 1.00, 0.85, 0.72, 0.89], # 3
    [0.63, 0.80, 0.85, 1.00, 0.71, 0.78],  # 4
    [0.66, 0.86, 0.72, 0.71, 1.00, 0.61],  # 5 
    [0.77, 0.75, 0.89, 0.78, 0.61, 1.00]]  # 6
    @table_sim = TableSimilarity.new(@sim)
    @items = @sim.size #(0..@sim.size - 1).to_a

    @dendo_single = Dendogram.new(agg_hier_cluster(@items, CompleteLinkage.new(@table_sim)))
  end

  def teardown
  end

  def test_complete
    dendo = [[[[2], [5]], [3]], [[0], [[1], [4]]]]
    ret = agg_hier_cluster(@items, CompleteLinkage.new(@table_sim))
    assert Dendogram::equal(ret, dendo)
  end

  def test_single
    dendo = [[[[[2], [5]], [[1], [4]]], [3]], [0]]
    ret = agg_hier_cluster(@items, SingleLinkage.new(@table_sim))
    assert Dendogram::equal(ret, dendo)
  end

  def test_dendogram_equal
    assert Dendogram::equal([[1], [2]], [[2], [1]])
  end

  def test_dendogram_distinct
    assert !Dendogram::equal([[1], [1]], [[1], [2]])
  end

  def test_min_height
    assert @dendo_single.cut(0.0).size == @sim.size 
  end

  def test_max_height
    assert @dendo_single.cut(1.0).size == 1
  end
end

class TC_SimilarityMetrics < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def knn
    table = [
      [1.00, 0.76, 0.78, 0.63, 0.66, 0.77],  # 1
      [0.76, 1.00, 0.855, 0.80, 0.86, 0.75], # 2
      [0.78, 0.855, 1.00, 0.85, 0.72, 0.89], # 3
      [0.63, 0.80, 0.85, 1.00, 0.71, 0.78],  # 4
      [0.66, 0.86, 0.72, 0.71, 1.00, 0.61],  # 5 
      [0.77, 0.75, 0.89, 0.78, 0.61, 1.00]]  # 6

    table_knn4 = [
      [1.00, 0.00,  0.00,  0.00, 0.00, 0.77],  # 1 -
      [0.00, 1.00,  0.855, 0.80, 0.86, 0.00], # 2 -
      [0.00, 0.855, 1.00,  0.85, 0.00, 0.89], # 3 -
      [0.00, 0.80,  0.85,  1.00, 0.00, 0.78],  # 4 -
      [0.00, 0.86,  0.00,  0.00, 1.00, 0.00],  # 5 -
      [0.77, 0.00,  0.89,  0.78, 0.00, 1.00]]  # 6

      assert knn(table, 4) == table_knn4
  end

  def test_euclidean
    assert euclidean_distance([3,0], [0,4]) == 5.0
  end

  def test_jaccard
    assert jaccard_coefficient([0, 1, 1, 0], [1, 0, 1, 0]) == 1.0 / 3
  end
end

class TS_Evolucao2008
  def self.suite
    suite = Test::Unit::TestSuite.new
    suite << TC_Dendogram.suite
    suite << TC_SimilarityMetrics.suite
    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_Evolucao2008)

