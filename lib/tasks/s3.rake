require 's3_downloader'

namespace :s3 do
  task :download_image_information => :environment do
    S3Downloader.download
  end
end
