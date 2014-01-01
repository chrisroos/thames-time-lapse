def print_usage_command_and_exit
  puts "Usage: #{File.basename(__FILE__)} <input-filename> <output-filename> <caption>"
  exit 1
end

print_usage_command_and_exit unless input_filename = ARGV.shift
input_filename = File.expand_path(input_filename)
unless File.exist?(input_filename)
  warn "#{input_filename} does not exist"
  print_usage_command_and_exit
end

print_usage_command_and_exit unless output_filename = ARGV.shift

print_usage_command_and_exit unless caption = ARGV.shift

image_width = `identify -format %w "#{input_filename}"`.chomp
cmd = %!convert -background '#0008' -fill white -gravity center -size #{image_width}x30 caption:"#{caption}" "#{input_filename}" +swap -gravity south -composite "#{output_filename}"!
`#{cmd}`
