require "test_helper"

class FridgeItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get fridge_items_new_url
    assert_response :success
  end
end
