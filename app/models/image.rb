class Image < ActiveRecord::Base
  validates :s3_key, :url, :taken_at, presence: true

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
end
