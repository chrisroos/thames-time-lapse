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

# Create the timeslice photo for yesterday
run "ruby script/create-time-slice-photo.rb ./#{date}/#{size}"

# Upload the timeslice to S3
run %%s3cmd put ./#{date}/#{size}/_time-slices/#{date}-time-slice.jpg s3://thames-time-lapse/timeslices/%

finished_at = Time.now
log "Finished at: #{finished_at}"

log "Duration: #{finished_at - started_at} seconds"
