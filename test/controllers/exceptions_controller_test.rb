require "test_helper"

class ExceptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get exceptions_show_url
    assert_response :success
  end
end
