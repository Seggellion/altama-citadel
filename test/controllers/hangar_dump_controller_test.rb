require "test_helper"

class HangardumpsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get hangardump_index_url
    assert_response :success
  end

  test "should get new" do
    get hangardump_new_url
    assert_response :success
  end

  test "should get create" do
    get hangardump_create_url
    assert_response :success
  end

  test "should get destroy" do
    get hangardump_destroy_url
    assert_response :success
  end
end
