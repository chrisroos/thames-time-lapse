require 's3_downloader'

namespace :s3 do
  task :move_images => :environment do
    S3Downloader.move_images
  end
  task :record_image_information => :environment do
    S3Downloader.record_image_information
  end
end
