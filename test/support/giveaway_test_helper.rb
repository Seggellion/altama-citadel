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

module ExtraLifeTestData
  CAMPAIGN = "11111111-2222-3333-4444-555555555555".freeze

  def make_event(bot, name: "EL #{SecureRandom.hex(3)}", **attrs)
    ExtraLifeEvent.create!({
      bot: bot, name: name, broadcaster_twitch_id: "1000", broadcaster_login: "seggellion",
      tiltify_campaign_id: CAMPAIGN, stream_start_at: Time.utc(2026, 11, 7, 16), enabled: true,
      last_complete_sync_at: Time.utc(2030, 1, 1)
    }.merge(attrs))
  end

  def make_account(id, login = "user#{id}")
    TwitchAccount.find_or_create_by!(twitch_user_id: id.to_s) { |a| a.login = login }
  end

  def make_event_giveaway(bot, event, command)
    bot.giveaways.create!(title: "t #{command}", description: "d", mode: Giveaway::EVENT_MODE, command_name: command,
                          channel: bot.channel, extra_life_event: event)
  end

  def make_donation(account_id: nil, completed_at: Time.utc(2026, 11, 7, 17), status: "completed", campaign: CAMPAIGN, outcome: nil, ext: SecureRandom.uuid)
    ExternalDonation.create!(
      external_id: ext, campaign_id: campaign, completed_at: completed_at, provider_status: status,
      first_seen_at: Time.current, last_seen_at: Time.current,
      match_outcome: outcome || (account_id ? "MATCHED" : "NO_LOGIN_CANDIDATE"),
      auto_twitch_user_id: account_id&.to_s, resolved_twitch_user_id: account_id&.to_s, amount_value: 5, amount_currency: "USD"
    )
  end

  def pool(giveaway)
    giveaway.event_pool.to_h { |r| [r["twitch_user_id"], [r["chat_tickets"], r["donor_tickets"], r["weight"], r["excluded_reason"]]] }
  end
end
