require 'date'

def log(string)
  puts "(#{File.basename(__FILE__)}) #{string}"
end

def run(cmd)
  log cmd
  `#{cmd}`
end

started_at = Time.now
log "Started at: #{started_at}"

s3_base = 's3://thames-time-lapse'
upload_directory = '_uploads'

uploads = `s3cmd ls --recursive #{File.join(s3_base, upload_directory)}`
uploads.split("\n").each do |upload|
  if upload =~ /imageSequence_/
    # For images uploaded with LapseItPro before they changed the naming convention
    # Filename format: imageSequence_yyyymmddhhmmss.jpg (e.g. imageSequence_20130731102329.jpg)

    old_url = upload[/(#{s3_base}.*\.jpg)/, 1]
    taken_at = DateTime.parse(upload[/imageSequence_(\d+).jpg/, 1])
    new_key = "images/#{taken_at.to_date}/original/#{taken_at.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"
    new_url = File.join(s3_base, new_key)

    log "Moving from #{old_url} to #{new_url}"

    cmd = "s3cmd mv #{old_url} #{new_url}"

    `#{cmd}`
  elsif upload =~ /(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})/
    # For images uploaded with Controlled Capture
    # Filename format: mm_dd_yy_hh_mm_ss.jpg (e.g. 12_22_13_12_25_29.jpg)

    day, month, year = $2, $1, $3
    hour, minute, second = $4, $5, $6

    date = [year, month, day].join('-')
    time = [hour, minute, second].join(':')
    date_and_time = [date, time].join(' ')
    taken_at = DateTime.parse(date_and_time)

    old_url = upload[/(#{s3_base}.*\.jpg)/, 1]
    old_filename = old_url[/(\d{2}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.jpg)/, 1]
    new_filename = "#{taken_at.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"

    new_key = "images/#{taken_at.to_date}/original/#{new_filename}"
    new_url = File.join(s3_base, new_key)

    resize_to = '800x600'

    # Create a directory to hold the resized images ready to make a timelapse video
    run "mkdir -p #{taken_at.to_date}/#{resize_to}"

    # Download and remove the image from S3
    run "s3cmd get #{old_url}"
    run "s3cmd del #{old_url}"

    # Rotate and upload the image to S3
    run "convert -rotate 180 #{old_filename} #{new_filename}"
    run "s3cmd put #{new_filename} #{new_url}"

    # Resize the image and save locally
    run "convert -resize #{resize_to} #{new_filename} ./#{taken_at.to_date}/#{resize_to}/#{new_filename}"

    # Remove the original and rotated images from the local disk
    run "rm #{old_filename}"
    run "rm #{new_filename}"
  end
end

finished_at = Time.now
log "Finished at: #{finished_at}"

log "Duration: #{finished_at - started_at} seconds"
