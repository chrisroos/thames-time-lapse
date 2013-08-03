unless AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID']
  warn "Set the AWS_ACCESS_KEY_ID environment variable in order to download image information from S3."
end

unless AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']
  warn "Set the AWS_SECRET_ACCESS_KEY environment variable in order to download image information from S3."
end
