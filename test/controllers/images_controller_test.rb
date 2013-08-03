require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test "index displays an error message if there are no images" do
    get :index
    assert response.body =~ /no images found/i
  end

  test "index redirects to the latest image" do
    image = Image.new
    Image.stubs(:latest).returns(image)
    get :index
    assert_redirected_to image_path(image)
  end

  test "show displays the image" do
    image = Image.new(id: 1, url: 'http://example.com/image.jpg', taken_at: Time.now)
    Image.stubs(:find).returns(image)
    get :show, id: image
    assert_select "img[src='http://example.com/image.jpg']"
  end

  test "show displays the time the picture was taken" do
    taken_at = Time.zone.now
    image = Image.new(id: 1, taken_at: taken_at)
    Image.stubs(:find).returns(image)
    get :show, id: image
    assert_select ".taken_at[datetime='#{taken_at.to_datetime.rfc3339}']"
  end
end
