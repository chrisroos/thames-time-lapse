class Image < ActiveRecord::Base
  validates :s3_key, :url, :taken_at, presence: true

  def self.number_of_days
    earliest_image_taken_at = Image.order(taken_at: :asc).first.taken_at
    latest_image_taken_at = Image.order(taken_at: :desc).first.taken_at
    (latest_image_taken_at.to_date - earliest_image_taken_at.to_date).to_i
  end

  def self.latest
    order('taken_at DESC').limit(1).first
  end

  def self.most_recent(number)
    order('taken_at DESC').limit(number)
  end

  def self.taken_on(date)
    where("DATE(taken_at) = ?", date)
  end

  def self.per_hour(date)
    where("taken_at IN (
      SELECT MIN(taken_at) FROM images
      WHERE DATE(taken_at) = ?
      GROUP BY DATE_PART('hour', taken_at)
      ORDER BY DATE_PART('hour', taken_at)
    )", date)
  end

  def thumbnail_url
    url.sub('original', '200x150').sub('.jpg', '.200x150.jpg')
  end
end
