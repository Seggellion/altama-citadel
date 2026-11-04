require "test_helper"
require_relative "../support/giveaway_test_helper"

class GiveawayValidationTest < GiveawayModelTestCase
  setup { @bot = make_bot }

  test "normalizes and accepts a valid command name" do
    g = make_giveaway(@bot, "  !Prize_1 ")
    assert_equal "prize_1", g.command_name
  end

  test "rejects reserved bot commands, including heist's join" do
    %w[join odds drawing giveaway-clear].each do |name|
      g = @bot.giveaways.new(title: "t", description: "d", mode: "single", command_name: name)
      refute g.valid?, name
      assert_includes g.errors[:command_name].join, "already a bot command"
    end
  end

  test "rejects malformed names" do
    ["two words", "a" * 26, "émoji", "x!"].each do |name|
      g = @bot.giveaways.new(title: "t", description: "d", mode: "single", command_name: name)
      refute g.valid?, name
    end
  end

  test "rejects a case-insensitive duplicate among open giveaways only" do
    make_giveaway(@bot, "prize")
    dup = @bot.giveaways.new(title: "t", description: "d", mode: "single", command_name: "PRIZE")
    refute dup.valid?
    Giveaway.where(command_name: "prize").update_all(winner: "someone")
    assert dup.valid?
  end

  test "rejects unknown modes but leaves existing records editable" do
    refute @bot.giveaways.new(title: "t", description: "d", mode: "weird").valid?
    legacy = make_giveaway(@bot, "old")
    legacy.update_column(:mode, "weird")
    assert legacy.reload.update(title: "renamed")
  end
end
