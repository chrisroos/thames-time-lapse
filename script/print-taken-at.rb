require 'date'

unless filename = ARGV.shift
  puts "Usage: #{File.basename(__FILE__)} <image-file-name>"
  exit 1
end

filename = "2013-10-18-08-06-51.jpg"
unless filename =~ /(\d{4}-\d{2}-\d{2})-(\d{2})-(\d{2})-(\d{2})/
  puts "Error: Filename expected to be in the format 'yyyy-mm-dd-hh-mm-ss'"
  exit 1
end

date, hour, minute, second = $1, $2, $3, $4
datetime = "#{date} #{hour}:#{minute}:#{second}"
datetime = DateTime.parse(datetime)
puts datetime.strftime("%A, %d %B %Y at %H:%M:%S")
