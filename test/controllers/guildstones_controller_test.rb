require "test_helper"

class GuildstonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guildstone = guildstones(:one)
  end

  test "should get index" do
    get guildstones_url
    assert_response :success
  end

  test "should get new" do
    get new_guildstone_url
    assert_response :success
  end

  test "should create guildstone" do
    assert_difference("Guildstone.count") do
      post guildstones_url, params: { guildstone: { charter: @guildstone.charter, title: @guildstone.title } }
    end

    assert_redirected_to guildstone_url(Guildstone.last)
  end

  test "should show guildstone" do
    get guildstone_url(@guildstone)
    assert_response :success
  end

  test "should get edit" do
    get edit_guildstone_url(@guildstone)
    assert_response :success
  end

  test "should update guildstone" do
    patch guildstone_url(@guildstone), params: { guildstone: { charter: @guildstone.charter, title: @guildstone.title } }
    assert_redirected_to guildstone_url(@guildstone)
  end

  test "should destroy guildstone" do
    assert_difference("Guildstone.count", -1) do
      delete guildstone_url(@guildstone)
    end

    assert_redirected_to guildstones_url
  end
end
