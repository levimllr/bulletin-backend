require 'test_helper'

class ScheduleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get schedule_index_url
    assert_response :success
  end

  test "should get create" do
    get schedule_create_url
    assert_response :success
  end

  test "should get show" do
    get schedule_show_url
    assert_response :success
  end

end
