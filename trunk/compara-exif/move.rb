require 'fileutils'

require 'repetidos'

include FileUtils::DryRun

repetidos = r
repetidos.each do |path|
  dir = File.dirname(path).gsub('hdd5/', 'hdd5/fotos-repetidas/')
  FileUtils.mkdir_p dir
  FileUtils.mv path, dir
end
