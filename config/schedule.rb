# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, '/home/thames-time-lapse/app/log/cron.log'

env :PATH, '/home/thames-time-lapse/bin:/usr/local/bin:/usr/bin:/bin'

every 10.minutes do
  command 'cd /home/thames-time-lapse/app && bin/rails runner -e production script/process-images.rb'
  command 'cd /home/thames-time-lapse/app && bin/rails runner -e production script/record-image-information.rb'
end

every 1.day, at: '1:00 am' do
  command 'cd /home/thames-time-lapse/app && bin/rails runner -e production script/create-and-upload-timeslice-for-yesterday.rb'
end

every 1.day, at: '2:00 am' do
  command 'cd /home/thames-time-lapse/app && bin/rails runner -e production script/create-and-upload-video-for-yesterday.rb'
end
