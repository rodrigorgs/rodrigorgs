#!/usr/bin/env ruby

$KCODE = 'UTF-8'

# TODO: consider using http://code.google.com/p/ir-themis/

require 'set'
require 'stemmer-pt-br-rslp.rb'
#require 'edit_distance'
#require 'rgl/

def assert
  raise "Assertion failed !" unless yield # if $DEBUG
end

class DocSpace
  attr_reader :doc_list, :terms, :idf, :weight
  attr_reader :edges

  def initialize
    @doc_list = Hash.new
    @edges = []
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

  # Detectando cola
  #
  # Seja D um documento suspeito de ter sido resultado de cola. As seguintes
  # condicoes reforcam a hipotese de que D foi produzido por cola:
  # * Um n-gram aparece em D e em poucos outros documentos (n-gram colado)
  # --- essa comparacao de n-grams pode ser feita com distancia de edicao
  # * Um n-gram colado tem n grande
  # * Ha muitos n-grams colados
  # 
  # TODO: normalizar valor
  # TODO: guardar coeficiente entre dois docs a fim de montar um grafo
  def coeficiente_de_colagem(doc, debug=false)
    other_docs = @doc_list.values - [doc]
    edges = other_docs.map { |d| [d, 0.0] }

    max = doc.terms.size

    coef = 0.0
    doc.terms.each do |term|
      common_docs = other_docs.select { |other_doc| other_doc.terms.include? term }
      freq = common_docs.size #/ other_docs.size.to_f
      if freq > 0
        score = (1.0 - (freq.to_f - 1) / (other_docs.size - 1)) / max.to_f
        common_docs.each { |common_doc| edges.assoc(common_doc)[1] += score }
        coef += score
      end
    end

    relevant_edges = edges.select{ |document, score| score >= 0.2 }.
        map { |document, score| [doc, document] }
    @edges += relevant_edges unless relevant_edges.empty?

    #p relevant_edges.map{ |a, b| [a.name, b.name]} unless relevant_edges.empty?
        #puts "  #{'%8.2f' % score} -- #{term} -- #{common_docs.map{|x| x.name}}" if debug
    #puts "max: %s,  coef: %s" % [max, coef]
    #max = 1.0 if max == 0.0
    return coef #/ max
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

STOPWORDS = IO.readlines('portuguese.stop').map { |x| x.strip }

def remove_acentos(string)
  a = string.dup

  a.gsub! /[äâàáã]/, 'a'
  a.gsub! /[êéèë]/, 'e'
  a.gsub! /[ïîìí]/, 'i'
  a.gsub! /[üúùû]/, 'u'
  a.gsub! /[ôöóòõ]/,'o'
  a.gsub! /[ç]/, 'c'
  
  a.gsub! /[ÄÂÀÁÃ]/, 'A'
  a.gsub! /[ÊÉÈË]/, 'E'
  a.gsub! /[ÏÎÌÍ]/, 'I'
  a.gsub! /[ÜÚÙÛ]/, 'U'
  a.gsub! /[ÔÖÓÒÕ]/,'O'
  a.gsub! /[Ç]/, 'C'

  return a
end

class Document
  #attr_reader :freq_rel
  attr_reader :name, :text
  attr_reader :terms

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
    words = text.split(/[^A-Za-záéíóúàâêôãõçÁÉÍÓÚÀÂÊÔÃÕÇ]/).
        select { |x| !x.empty? }

    words.map! { |x| remove_acentos(x) }

    words.map! { |x| x.downcase }

    words.delete_if { |x| STOPWORDS.include?(x) }

    stemmer = StemmerPortuguese.new
    words.map! { |x| stemmer.stem(x) }

    grams = []
    2.upto(7) do |i|
      words.each_cons(i) { |x| grams << x.join(" ") }
    end

    words = grams # XXX  XXX   XXX     XXX      XXX

    words.each do |w| freq[w] += 1 end

    @terms = words
    return freq
  end

  def terms
    @freq_abs.keys
  end
end

def create_space()
end

if __FILE__ == $0
  QUESTAO = "6.1"

  space = create_space
  space = DocSpace.new
  Dir.glob("../corpora/questoes/#{QUESTAO}/*") do |file|
    space.add_doc(Document.new(File.basename(file.split("-")[0]), IO.read(file)))
  end

  distances = []

  docs = space.doc_list.values
  n = docs.size

  (0..n-1).each do |i|
    distances << [docs[i], docs[i], space.coeficiente_de_colagem(docs[i])]
  end

  distances = distances.sort_by { |d1, d2, dist| dist }

  distances.each do |d1, d2, dist|
    puts "%.2f     %s" % [dist, File.basename(d1.name).split("-")[0]]
  end

  puts "(QUESTAO #{QUESTAO})"

  require 'rgl/adjacency'
  require 'rgl/dot'
  edges = space.edges.map { |a, b| [a.name, b.name] }
  p edges
  g = RGL::DirectedAdjacencyGraph[*edges.flatten]
  #space.doc_list.each_key { |name| g.add_vertex name }
  g.write_to_graphic_file('png')
  `eog graph.png`



  #doc = distances[-1][0]
  #space.coeficiente_de_colagem(doc, true)
end
