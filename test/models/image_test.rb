require 'test_helper'

class ImageTest < ActiveSupport::TestCase
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
