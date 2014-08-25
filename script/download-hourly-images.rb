require 'date'

start_date = Date.parse('2014-01-01')
end_date = Date.parse('2014-08-24')

(start_date..end_date).each do |date|
  output_directory = Rails.root.join("tmp/hourly/#{date}")
  FileUtils.mkdir_p output_directory

  Image.per_hour(date).each do |image|
    filename = File.basename(image.s3_key)
    output_filename = File.join(output_directory, filename)

    `curl -s #{image.url} -o #{output_filename}`
  end
end
