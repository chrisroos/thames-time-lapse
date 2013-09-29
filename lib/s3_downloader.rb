class S3Downloader
  class << self
    def move_images
      aws_s3_connection_attrs = {
        access_key_id: AWS_ACCESS_KEY_ID.to_s,
        secret_access_key: AWS_SECRET_ACCESS_KEY.to_s
      }

      service = S3::Service.new(aws_s3_connection_attrs)
      if bucket = service.buckets.find('thames-time-lapse')
        bucket.objects.each do |object|
          s3_key = object.key
          if s3_key =~ /^_uploads.*\.jpg/
            taken_at = DateTime.parse(s3_key[/imageSequence_(\d+).jpg/, 1])
            new_key = "images/#{taken_at.to_date}/original/#{taken_at.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"
            puts "Moving from #{s3_key} to #{new_key}"
            if new_object = object.copy(key: new_key)
              object.destroy
            end
          end
        end
      end
    end

    def record_image_information
      aws_s3_connection_attrs = {
        access_key_id: AWS_ACCESS_KEY_ID.to_s,
        secret_access_key: AWS_SECRET_ACCESS_KEY.to_s
      }

      service = S3::Service.new(aws_s3_connection_attrs)
      if bucket = service.buckets.find('thames-time-lapse')
        bucket.objects.each do |object|
          s3_key = object.key
          next unless s3_key =~ /^images\/\d{4}-\d{2}-\d{2}\/original\/.*\.jpg/
          if s3_key =~ /(\d{4}-\d{2}-\d{2})-(\d{2})-(\d{2})-(\d{2})\.jpg/
            date = $1
            hour, minute, second = $2, $3, $4
            unless Image.find_by_s3_key(s3_key)
              taken_at = DateTime.parse("#{date} #{hour}:#{minute}:#{second}")
              image = Image.create!(s3_key: s3_key, url: object.url, taken_at: taken_at)
            end
          end
        end
      end
    end
  end
end
