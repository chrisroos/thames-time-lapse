require 'test_helper'

class ImageValidationTest < ActiveSupport::TestCase
  setup do
    @image = Image.new s3_key: 's3-key', url: 'http://example.com/image.jpg', taken_at: Time.now
  end

  test 'should be valid' do
    assert @image.valid?
  end

  test 'should be invalid without an s3_key' do
    @image.s3_key = nil
    refute @image.valid?
    assert @image.errors[:s3_key].present?
  end

  test 'should be invalid without a url' do
    @image.url = nil
    refute @image.valid?
    assert @image.errors[:url].present?
  end

  test 'should be invalid without a taken_at' do
    @image.taken_at = nil
    refute @image.valid?
    assert @image.errors[:taken_at].present?
  end
end

class ImageTest < ActiveSupport::TestCase
  test 'returns the n most recent images' do
    oldest_image = Image.create!(s3_key: 'key-1', url: 'url-1', taken_at: 3.weeks.ago)
    older_image = Image.create!(s3_key: 'key-2', url: 'url-2', taken_at: 2.weeks.ago)
    newer_image = Image.create!(s3_key: 'key-3', url: 'url-3', taken_at: 1.week.ago)
    newest_image = Image.create!(s3_key: 'key-4', url: 'url-4', taken_at: Time.now)
    assert_equal [newest_image, newer_image], Image.most_recent(2)
  end

  test 'returns the latest image' do
    newer_image = Image.create!(s3_key: 'key-1', url: 'url-1', taken_at: Time.now)
    older_image = Image.create!(s3_key: 'key-2', url: 'url-2', taken_at: 1.day.ago)
    assert_equal newer_image, Image.latest
  end

  test 'returns all images for a given date' do
    image_1 = Image.create!(s3_key: 'key-1', url: 'url-1', taken_at: Date.yesterday)
    image_2 = Image.create!(s3_key: 'key-2', url: 'url-2', taken_at: Date.today)
    image_3 = Image.create!(s3_key: 'key-3', url: 'url-3', taken_at: Date.tomorrow)
    assert_equal [image_2], Image.taken_on(Date.today)
  end

  test 'returns the earliest image for each hour of the given date' do
    image_1 = Image.create!(s3_key: 'key-1', url: 'url-1', taken_at: '2013-01-01 09:00:00')
    image_2 = Image.create!(s3_key: 'key-2', url: 'url-2', taken_at: '2013-01-01 09:01:00')
    image_3 = Image.create!(s3_key: 'key-3', url: 'url-3', taken_at: '2013-01-01 10:00:00')
    image_4 = Image.create!(s3_key: 'key-4', url: 'url-4', taken_at: '2013-01-01 10:01:00')
    assert_equal [image_1, image_3], Image.per_hour(Date.parse('2013-01-01'))
  end
end
