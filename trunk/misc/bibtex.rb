#!/usr/bin/env ruby

=begin
  Recupera informações de arquivos bibtex gerados pelo JabRef.
  Este script é quase nada robusto, e não é capaz de processar um arquivo
bibtex arbitrário!
  Este script cria um arquivo para cada review presente no bibtex.
=end

Entry = Struct.new("Entry", :key, :author, :title, :year, :abstract, :review)

def parse_bibtex(filename)
  modes = %w(author title year abstract review)
  entry_types = "(ARTICLE|PHDTHESIS|MASTERTHESIS|MISC|INPROCEEDINGS|INCOLLECTION|CONFERENCE|BOOK)"

  entries = []
  mode = ""
  entry = nil
  IO.foreach(filename) do |line|
    if mode.empty?
      if line =~ /^@#{entry_types}\{(.+),/i
        entry = Entry.new
        entry.key = $2
        entries << entry
        puts "\n#{entry.key}"
      else
        modes.each do |m|
          if line =~ /^\s*#{m} = \{(.+)\}/
            entry[m] = $1
            puts "#{m} = #{entry[m]}"
          elsif line =~ /^\s*#{m} = \{(.+)/
            entry[m] = $1.lstrip.chomp + " "
            mode = m
          end
        end
      end
    else
      if line =~ /(.+)\}(,|\s*$)/
        entry[mode] += $1.lstrip.chomp
        puts "#{mode} = #{entry[mode]}"
        mode = ""
      elsif line.strip.empty?
        entry[mode] += "\n"
      else
        entry[mode] += line.lstrip.chomp + " "
      end
    end
  end
#    case mode
#    when :free
#      elsif line =~ /author = \{(.+)\}/
#        entry.author = $1
#        puts $1
#      elsif line =~ /title = \{(.+)\}/
#        entry.title = $1
#      elsif line =~ /year = \{(.+)\}/
#        entry.year = $1
#
#
#      elsif line =~ /review = \{(.+)\}/
#        entry.review = $1
#      elsif line =~ /review = \{(.+)/
#        entry.review = $1
#        mode = :review
#      end
#    when :review
#      if line =~ /(.+)\}[,$]/
#        entry.review += $1.lstrip.chomp
#        mode = :free
#      elsif line.strip.empty?
#        entry.review += "\n"
#      else
#        entry.review += line.lstrip.chomp
#      end
#    end
#  end

  entries
end

if __FILE__ == $0
  if ARGV.empty?
    puts "
    Usage: #{File.basename($0)} bibtexfile
    "
    exit 1
  end

  filename = ARGV[0]
  entries = parse_bibtex(filename)

  entries.select{ |e| !e.review.nil? }.each do |entry|
    review_file = File.open("Review#{entry.key}", "w") do |f|
      f.puts "#summary \"#{entry.title}\": revisao

*Titulo*: #{entry.title}

*Autores*: #{entry.author}

*Ano*: #{entry.year}

----

#{entry.review}
      "
    end
  end
end

