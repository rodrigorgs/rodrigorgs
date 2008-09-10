#!/usr/bin/ruby  
  
require 'exif'  
require 'fileutils'
require 'find'
include FileUtils::Verbose

DIRS = ['/mnt/hdd5/BACKUP SET06/FotosD',
  '/mnt/sda3/home/rodrigo/arq/fotos']

hashes = [Hash.new, Hash.new]
DIRS.each_with_index do |dir, i|
  Find.find(dir) do |path|
    if path[-3..-1].upcase == 'MPG'
      #info = Exif.new(path)['Date and Time'] #+ ' ' + File.size(path).to_s
      info = File.basename(path)[0..-5].upcase
      hashes[i][info] = path
    end
  end
end

#############

repetidos = []
hashes[0].each_pair do |info, path|
  if hashes[1].keys.include? info
    repetidos << path
  else
    #p path
  end
end

###########

require 'fileutils'

repetidos.each do |path|
  dir = File.dirname(path).gsub('hdd5/', 'hdd5/videos-repetidos-nome/')
  p path
  mkdir_p dir
  mv path, dir
end
