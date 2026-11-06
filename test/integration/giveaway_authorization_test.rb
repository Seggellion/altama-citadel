require "test_helper"
require_relative "../support/giveaway_test_helper"

class GiveawayAuthorizationTest < GiveawayIntegrationTestCase
  setup do
    @bot = make_bot
    @giveaway = make_giveaway(@bot, "prize")
    @params = { giveaway: { title: "x", description: "y", mode: "single", command_name: "newprize", channel: "seggellion" } }
  end

  test "anonymous and non-admin users cannot manage giveaways or bots" do
    [nil, make_user("viewer", user_type: 30)].each do |user|
      login_as(user)
      assert_no_difference("Giveaway.count") { post bot_giveaways_path(@bot), params: @params }
      assert_redirected_to root_path
      patch bot_giveaway_path(@bot, @giveaway), params: { giveaway: { title: "hacked" } }
      delete bot_giveaway_path(@bot, @giveaway)
      patch toggle_online_bot_path(@bot)
      assert_equal "t prize", @giveaway.reload.title
      assert_nil @bot.reload.bot_online
    end
  end

  test "admin can create, and validation errors are reported instead of a blank page" do
    login_as(make_user("owner", user_type: 0))
    assert_difference("Giveaway.count") { post bot_giveaways_path(@bot), params: @params }
    assert_no_difference("Giveaway.count") do
      post bot_giveaway_path(@bot, @giveaway).sub(%r{/#{@giveaway.id}\z}, ""), params: { giveaway: @params[:giveaway].merge(command_name: "join") }
    end
    assert_match "already a bot command", flash[:alert]
  end
end
