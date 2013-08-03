class Image < ActiveRecord::Base
  validates :s3_key, :url, presence: true
end
