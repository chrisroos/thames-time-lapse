require 'test_helper'

class DaysControllerTest < ActionController::TestCase
  test 'redirects to the current date' do
    get :index
    assert_redirected_to day_path(Date.today)
  end

  test 'displays images for the given date' do
    january_1st = DateTime.parse('2013-01-01 09:00')
    january_2nd = DateTime.parse('2013-01-02 09:00')
    image_1 = Image.create!(s3_key: 'key-1', url: 'january-1st', taken_at: january_1st)
    image_2 = Image.create!(s3_key: 'key-2', url: 'january-2nd', taken_at: january_2nd)

    get :show, id: '2013-01-01'

    assert_select "img[src*='january-1st']"
    assert_select "img[src*='january-2nd']", false
  end
end
