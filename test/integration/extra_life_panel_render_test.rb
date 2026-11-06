require "test_helper"
require_relative "../support/giveaway_test_helper"

# The existing ALTAMA.EXE giveaway panel partials render with event-mode giveaways and legacy ones.
class ExtraLifePanelRenderTest < GiveawayIntegrationTestCase
  include ExtraLifeTestData

  test "panel, forms and participants render for admin" do
    bot = make_bot
    event = make_event(bot, name: "Panel EL")
    eg = make_event_giveaway(bot, event, "panel#{SecureRandom.hex(2)}")
    legacy = make_giveaway(bot, "legacy#{SecureRandom.hex(2)}")
    make_account("2001", "alice")
    GiveawayTicketSource.create!(giveaway: eg, twitch_user_id: "2001", source: "chat", granted_at: Time.current)
    login_as(make_user("owner", user_type: 0))
    html = ApplicationController.render(partial: "desktop/apps/altama_exe", assigns: { bots: Bot.where(id: bot.id) })
    assert_match "Extra Life events", html
    assert_match "Panel EL", html
    assert_match "Extra Life + Tiltify event (1 free chat ticket + 1 donor ticket)", html
    assert_match "alice", html # event participants table
    assert_match "mode cannot be changed", html
    assert_match "joinDate", html # legacy participants table unchanged
    assert legacy
  end
end
