require 'find'
require 'fileutils'
require 'exif'
#require 'date'
require 'tempfile'
include FileUtils::Verbose

MOUNT_POINT = '/mnt/sdb1'
CAM_DIR = MOUNT_POINT + '/dcim'
LOCAL_DIR = '/mnt/sda3/home/rodrigo/arq/fotos'

def mount(mount_point)
  `mount #{mount_point}`
  raise "Couldn't mount #{mount_point}" if $? != 0
  begin
    yield
  ensure
    `umount #{mount_point}`
    raise "Couldn't unmount #{mount_point}" if $? != 0
  end
end

mount MOUNT_POINT do
  local_files = []
  Find.find(LOCAL_DIR) { |path| local_files << path }

  Dir.foreach(CAM_DIR) do |cam_folder|
    next if !File.directory?("#{CAM_DIR}/#{cam_folder}") || ['.', '..'].include?(cam_folder)

    puts cam_folder

    local_folder = nil
    dates = []

    Dir.foreach("#{CAM_DIR}/#{cam_folder}") do |cam_file|
      #puts "  " + cam_file
      cam_path = "#{CAM_DIR}/#{cam_folder}/#{cam_file}"
      next if File.directory?(cam_path)

      cam_exif = Exif.new(cam_path)#['Date and Time']
      cam_exif = (cam_exif.list_tags(2).empty? ? nil : cam_exif['Date and Time'])
      ignore_file = false

      regexp = "/#{Regexp.escape(cam_file)}$"
      local_files.grep Regexp.new(regexp, Regexp::IGNORECASE) do |local|
        if cam_exif
          local_exif = Exif.new(local)['Date and Time']
          ignore_file = true if local_exif == cam_exif
        else
          ignore_file = true if File.size(local) == File.size(cam_path)
        end
      end

      unless ignore_file
        unless local_folder
          tmp = Tempfile.new('__', '.')
          local_folder = File.basename(tmp.path)
          tmp.delete

          mkdir local_folder
        end

        if cam_exif
          d = cam_exif.split(/[ :]/).map { |x| x.to_i }
          dates << Time.local(*d)
        end

        cp cam_path, local_folder, :preserve => true
      end
    end

    if local_folder && !dates.empty?
      d = dates.min
      `touch -m -t #{d.strftime("%Y%m%d%H%M.%S")} #{local_folder}`
      mv local_folder, "#{local_folder} #{d.strftime('%d-%m-%Y')}"
    end
  end
end

puts "The end."
