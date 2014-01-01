date = ARGV.shift
unless date && date =~ /\d{4}-\d{2}-\d{2}/
  puts "Usage: #{File.basename(__FILE__)} <date>"
  exit 1
end

size = '800x600'

puts "Downloading images from S3"
`mkdir -p #{date}`
`s3cmd get --recursive s3://thames-time-lapse/images/#{date}/ #{date}/`

puts "Resizing images"
`ruby resize-images.rb #{date} #{size}`

puts "Creating video"
`ffmpeg -f image2 -pattern_type glob -i "#{date}/#{size}/*.jpg" #{date}.#{size}.mp4`

puts "Removing images"
`rm -rf #{date}`
