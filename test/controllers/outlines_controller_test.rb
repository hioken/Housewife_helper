require "test_helper"

class OutlinesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get outlines_show_url
    assert_response :success
  end

  test "should get edit" do
    get outlines_edit_url
    assert_response :success
  end

  test "should get update" do
    get outlines_update_url
    assert_response :success
  end
end
