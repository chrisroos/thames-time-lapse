require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test "index redirects to the latest image" do
    image = Image.new
    Image.stubs(:latest).returns(image)
    get :index
    assert_redirected_to image_path(image)
  end

  test "show displays the image" do
    image = Image.create!(s3_key: 'unique-key', url: 'http://example.com/image.jpg', taken_at: Time.now)
    get :show, id: image
    assert_select "img[src='http://example.com/image.jpg']"
  end
end
