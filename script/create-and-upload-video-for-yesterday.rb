# This expects to find images in Rails.root + /yyyy-mm-dd/800x600/

def log(string)
  puts "(#{File.basename(__FILE__)}) #{string}"
end

def run(cmd)
  log cmd
  `#{cmd}`
end

started_at = Time.now
log "Started at: #{started_at}"

date = Date.yesterday.to_s
size = '800x600'

# Create the video using the images captured yesterday
run %%ffmpeg -f image2 -pattern_type glob -i "./#{date}/#{size}/*.jpg" ./#{date}.#{size}.mp4%

# Upload the video to S3
run %%s3cmd put ./#{date}.#{size}.mp4 s3://thames-time-lapse/videos/%

# Remove the images captured yesterday and the video
run %%rm -rf ./#{date}%
run %%rm ./#{date}.#{size}.mp4%

finished_at = Time.now
log "Finished at: #{finished_at}"

log "Duration: #{finished_at - started_at} seconds"
