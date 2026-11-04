# Shared setup for the giveaway / Extra Life tests.
#
# The repository's global `fixtures :all` cannot load (test/fixtures/users.yml rows have no username, which is
# NOT NULL), so these tests opt out of global fixtures and build their own records.
module GiveawayTestLogin
  mattr_accessor :user
end

ApplicationController.prepend(Module.new do
  def current_user
    GiveawayTestLogin.user || super
  end
end)

module GiveawayTestData
  def make_user(username, user_type: 100, **attrs)
    username = "#{username}_#{SecureRandom.hex(4)}"
    User.create!({ username: username, user_type: user_type, provider: "twitch", password: "x" * 12 }.merge(attrs))
  rescue ActiveRecord::RecordInvalid
    u = User.new({ username: username, user_type: user_type, provider: "twitch" }.merge(attrs))
    u.save!(validate: false)
    u
  end

  def make_bot(channel: "seggellion")
    Bot.create!(channel: channel, bot_name: "altama_exe")
  end

  def make_giveaway(bot, command, mode: "single", **attrs)
    bot.giveaways.create!({ title: "t #{command}", description: "d", mode: mode, command_name: command, channel: bot.channel }.merge(attrs))
  end

  def login_as(user)
    GiveawayTestLogin.user = user
  end
end

class GiveawayModelTestCase < ActiveSupport::TestCase
  self.fixture_table_names = []
  include GiveawayTestData
  teardown { GiveawayTestLogin.user = nil }
end

class GiveawayIntegrationTestCase < ActionDispatch::IntegrationTest
  self.fixture_table_names = []
  include GiveawayTestData
  teardown { GiveawayTestLogin.user = nil }
end
