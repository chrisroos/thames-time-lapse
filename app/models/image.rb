class Image < ActiveRecord::Base
  validates :s3_key, :url, :taken_at, presence: true

  def self.latest
    order('taken_at DESC').limit(1).first
  end
end
