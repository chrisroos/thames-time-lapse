class S3Downloader
  class << self
    def download
      aws_s3_connection_attrs = {
        access_key_id: AWS_ACCESS_KEY_ID.to_s,
        secret_access_key: AWS_SECRET_ACCESS_KEY.to_s
      }

      service = S3::Service.new(aws_s3_connection_attrs)
      if bucket = service.buckets.find('thames-time-lapse')
        bucket.objects.each do |object|
          s3_key = object.key
          if s3_key =~ /imageSequence/
            image = Image.find_or_initialize_by(s3_key: s3_key)
            taken_at = DateTime.parse(s3_key[/imageSequence_(\d+).jpg/, 1])
            new_key = "#{taken_at.to_date}/#{taken_at.strftime('%Y-%m-%d-%H-%M-%S')}.jpg"
            if new_object = object.copy(key: new_key)
              object.destroy
            end
            image.update_attributes!(url: new_object.url, taken_at: taken_at)
          end
        end
      end
    end
  end
end
