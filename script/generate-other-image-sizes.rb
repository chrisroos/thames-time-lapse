def log(string)
  puts "(#{File.basename(__FILE__)}) #{string}"
end

def run(cmd)
  log cmd
  `#{cmd}`
end

cmd = %%s3cmd ls s3://thames-time-lapse/images/ | grep -o "s3:.*"%
directories = `#{cmd}`
directories.split("\n").each do |date_directory_uri|
  date = date_directory_uri[/\d{4}-\d{2}-\d{2}/]

  s3_output = run "s3cmd ls #{File.join(date_directory_uri, 'original', '/')}"
  s3_files = s3_output.split("\n")

  s3_files.each do |file_information|
    image_uri = file_information[/s3:.*/]
    filename = File.basename(image_uri)

    run "s3cmd get --skip-existing #{image_uri}"

    ['800x600', '200x150'].each do |resize_to|
      resized_filename = filename.sub('.jpg', ".#{resize_to}.jpg")
      run "convert -resize #{resize_to} #{filename} #{resized_filename}"
      run "s3cmd put #{resized_filename} s3://thames-time-lapse/images/#{date}/#{resize_to}/"
      run "rm #{resized_filename}"
    end

    run "rm #{filename}"
  end
end
