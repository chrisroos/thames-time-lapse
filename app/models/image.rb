class Image < ActiveRecord::Base
  validates :s3_key, :url, :taken_at, presence: true
end
