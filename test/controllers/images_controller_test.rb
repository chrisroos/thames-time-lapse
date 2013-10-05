require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test "index renders an atom feed of the 10 most recent images" do
    created_at = updated_at = taken_at = Time.zone.now
    image = Image.new(id: 123, created_at: created_at, updated_at: updated_at, taken_at: taken_at, url: 'http://example.com/image.png')
    Image.stubs(:most_recent).with(10).returns([image])
    get :index, format: 'atom'
    assert_select 'feed title', text: 'Most recent images from thames-time-lapse'
    assert_select 'feed updated', text: taken_at.xmlschema
    assert_select 'feed entry id', text: /Image\/123/
    assert_select 'feed entry published', text: created_at.xmlschema
    assert_select 'feed entry updated', text: updated_at.xmlschema
    assert_select "feed entry content img[src='http://example.com/image.png']"
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
