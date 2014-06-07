require 'date'

s3cmd = "/usr/local/bin/s3cmd"

start_date = Date.parse('2013-08-07')
end_date = Date.parse('2014-05-30')

hour = 12
minute = 00

hour   = "%02d" % hour
minute = "%02d" % minute

puts "Searching for images from #{hour}:#{minute}"
(start_date..end_date).each do |date|
  puts date
  (0..59).each do |second|
    second = "%02d" % second

    s3_path = "s3://thames-time-lapse/images/#{date}/original/#{date}-#{hour}-#{minute}-#{second}.jpg"
    cmd = %%#{s3cmd} ls #{s3_path}%
    output = `#{cmd}`

    if output != ''
      cmd = "#{s3cmd} get #{s3_path} #{date}-#{hour}-#{minute}.jpg"
      `#{cmd}`
      break
    end
  end
end
