require 'date'

s3_base = 's3://thames-time-lapse/'
image_directory = 'images/'

latest_image = Image.order('taken_at DESC').first
latest_date = latest_image ? latest_image.taken_at.to_date : Date.parse('2013-01-01')

folders = `s3cmd ls #{File.join(s3_base, image_directory)}`
folders.split("\n").each do |folder|
  if folder =~ /(#{s3_base}.*(\d{4}-\d{2}-\d{2}))/
    folder_url = $1
    date = $2
    if Date.parse(date) < latest_date
      # puts "Ignoring: #{folder_url}"
    else
      puts "Processing: #{folder_url}"
      images = `s3cmd ls --recursive #{folder_url}`
      images.split("\n").each do |image|
        if image =~ /#{s3_base}(.*original.*\.jpg)/
          s3_key = $1
          image_url = 'http://thames-time-lapse.s3.amazonaws.com' + s3_key
          if image_url =~ /(\d{4}-\d{2}-\d{2})-(\d{2})-(\d{2})-(\d{2})\.jpg/
            date = $1
            hour, minute, second = $2, $3, $4
            unless Image.find_by_s3_key(s3_key)
              taken_at = DateTime.parse("#{date} #{hour}:#{minute}:#{second}")
              image = Image.create!(s3_key: s3_key, url: image_url, taken_at: taken_at)
              puts "Created image with key: #{s3_key}"
            end
          end
        end
      end
    end
  end
end
