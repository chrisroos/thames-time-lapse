require 'date'

s3_base = 's3://thames-time-lapse'
upload_directory = '_uploads'

uploads = `s3cmd ls --recursive #{File.join(s3_base, upload_directory)}`
uploads.split("\n").each do |upload|
  if upload =~ /imageSequence_/
    old_url = upload[/(#{s3_base}.*\.jpg)/, 1]
    taken_at = DateTime.parse(upload[/imageSequence_(\d+).jpg/, 1])
    new_key = "images/#{taken_at.to_date}/original/#{taken_at.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"
    new_url = File.join(s3_base, new_key)

    puts "Moving from #{old_url} to #{new_url}"

    cmd = "s3cmd mv #{old_url} #{new_url}"

    `#{cmd}`
  end
end
