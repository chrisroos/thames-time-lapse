cmd = %%s3cmd ls s3://thames-time-lapse/images/ | grep -o "s3:.*"%
directories = `#{cmd}`
directories.split("\n").each do |date_directory_uri|
  date = date_directory_uri[/\d{4}-\d{2}-\d{2}/]

  cmd = %%s3cmd ls #{File.join(date_directory_uri, 'original', '/')}%
  image_uris = `#{cmd}`
  image_uris = image_uris.split("\n")

  first_image_uri = image_uris.first[/s3:.*/]
  first_image_name = File.basename(first_image_uri)

  last_image_uri = image_uris.last[/s3:.*/]
  last_image_name = File.basename(last_image_uri)

  # Download the first image of the day and extract image size
  cmd = %%s3cmd get --skip-existing #{first_image_uri}%
  `#{cmd}`
  cmd = %%exiftool -ImageSize #{first_image_name} | cut -d":" -f2%
  first_image_resolution = `#{cmd}`.strip

  # Download the last image of the day and extract image size
  cmd = %%s3cmd get --skip-existing #{last_image_uri}%
  `#{cmd}`
  cmd = %%exiftool -ImageSize #{last_image_name} | cut -d":" -f2%
  last_image_resolution = `#{cmd}`.strip

  puts [date, first_image_resolution, last_image_resolution].join(', ')
end
