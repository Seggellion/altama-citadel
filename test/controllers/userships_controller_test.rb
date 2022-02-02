require "test_helper"

class UsershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usership = userships(:one)
  end

  test "should get index" do
    get userships_url
    assert_response :success
  end

  test "should get new" do
    get new_usership_url
    assert_response :success
  end

  test "should create usership" do
    assert_difference("Usership.count") do
      post userships_url, params: { usership: { description: @usership.description, paint: @usership.paint, ship_id: @usership.ship_id, ship_name: @usership.ship_name, user_id: @usership.user_id, year_purchased: @usership.year_purchased } }
    end

    assert_redirected_to usership_url(Usership.last)
  end

  test "should show usership" do
    get usership_url(@usership)
    assert_response :success
  end

  test "should get edit" do
    get edit_usership_url(@usership)
    assert_response :success
  end

  test "should update usership" do
    patch usership_url(@usership), params: { usership: { description: @usership.description, paint: @usership.paint, ship_id: @usership.ship_id, ship_name: @usership.ship_name, user_id: @usership.user_id, year_purchased: @usership.year_purchased } }
    assert_redirected_to usership_url(@usership)
  end

  test "should destroy usership" do
    assert_difference("Usership.count", -1) do
      delete usership_url(@usership)
    end

    assert_redirected_to userships_url
  end
end
