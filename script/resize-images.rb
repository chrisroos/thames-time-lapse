require 'fileutils'

directory = ARGV.shift
unless directory && Dir.exists?(directory)
  puts "Usage: #{File.basename(__FILE__)} <directory> <size>"
  exit 1
end

resize_to = ARGV.shift
unless resize_to
  puts "Usage: #{File.basename(__FILE__)} <directory> <size>"
  exit 1
end

Dir[File.join(directory, '*.jpg')].each do |f|
  source           = File.expand_path(f)
  source_directory = File.dirname(source)
  source_extension = File.extname(source)
  source_filename  = File.basename(source, source_extension)

  destination_directory = File.join(source_directory, resize_to)
  destination_filename  = [source_filename, ".#{resize_to}", source_extension].join('')
  destination           = File.join(destination_directory, destination_filename)

  FileUtils.mkdir(destination_directory) unless Dir.exists?(destination_directory)

  p cmd = %%convert "#{source}" -resize #{resize_to} "#{destination}"%
  system(cmd)
end
