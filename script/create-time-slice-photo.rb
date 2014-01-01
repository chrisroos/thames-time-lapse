require 'fileutils'

directory = ARGV.shift
unless directory and Dir.exists?(directory)
  puts "Usage: #{File.basename(__FILE__)} /path/to/images"
  exit 1
end

output_directory = File.join(directory, '_time-slices')
FileUtils.mkdir_p(output_directory)

images = Dir.glob(File.join(directory, '*.jpg'))
number_of_images = images.length
number_of_segments = 24
step = number_of_images / (number_of_segments - 0)

cmd = %%identify "#{images.first}"%
identify_output = `#{cmd}`

identify_output =~ /(\d+)x(\d+)/
image_width = $1.to_i
image_height = $2.to_i

segment_width = image_width / number_of_segments
y_offset = 0
total_count = 1
segment_count = 1

images = []

Dir[File.join(directory, '*.jpg')].each do |file|
  next unless file =~ /imageSequence/

  if total_count == 1 or (total_count % step == 0)
    x_offset = segment_count * segment_width
    if x_offset < image_width
      output_filename = File.join(output_directory, "#{File.basename(file)}")
      cmd = %%convert "#{file}" -crop #{segment_width}x#{image_height}+#{x_offset}+#{y_offset} +repage "#{output_filename}"%
      images << output_filename
      # p cmd
      system cmd
      segment_count += 1
    end
  end

  total_count += 1
end

date = directory[/(\d{4}-\d{2}-\d{2})/, 1]
combined_output_filename = File.join(output_directory, "#{date}-time-slice.jpg")
input_file_list = images.map { |image| '"' + image + '"' }.join(' ')
cmd = %%convert #{input_file_list} +append "#{combined_output_filename}"%
system cmd
