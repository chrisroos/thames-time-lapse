require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test "show displays the image" do
    image = Image.create!(s3_key: 'unique-key', url: 'http://example.com/image.jpg', taken_at: Time.now)
    get :show, id: image
    assert_select "img[src='http://example.com/image.jpg']"
  end
end
