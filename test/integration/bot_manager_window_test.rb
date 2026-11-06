require "test_helper"
require_relative "../support/giveaway_test_helper"

# The Windows 95 Bot Manager window (desktop ALTAMA.EXE) and the Extra Life event window.
class BotManagerWindowTest < GiveawayIntegrationTestCase
  include ExtraLifeTestData

  class FakeLookup
    def by_login(login)
      login = login.to_s.strip.downcase
      { "seggellion" => "1000" }[login]&.then { |id| TwitchUserLookup::User.new(id: id, login: login, display_name: login) }
    end

    def by_id(_id) = nil
  end

  setup do
    TwitchUserLookup.backend = FakeLookup.new
    @bot = make_bot
    @admin = make_user("owner", user_type: 0)
  end

  teardown { TwitchUserLookup.backend = nil }

  def render_panel(params: {})
    ApplicationController.renderer.new("action_dispatch.request.parameters" => params.stringify_keys)
                         .render(partial: "desktop/apps/altama_exe", assigns: { bots: Bot.where(id: @bot.id) })
  end

  test "giveaways list puts open giveaways first and folds drawn ones into a collapsed group" do
    open_g = make_giveaway(@bot, "open#{SecureRandom.hex(2)}", title: "Open prize")
    drawn = make_giveaway(@bot, "old#{SecureRandom.hex(2)}", title: "Old prize")
    drawn.update_columns(winner: "bob")
    login_as(@admin)
    html = render_panel

    doc = Nokogiri::HTML.fragment(html)
    open_row = doc.at_css("tr.w95-row[data-id='g#{open_g.id}']")
    drawn_row = doc.at_css("tr.w95-row[data-id='g#{drawn.id}']")
    assert open_row, "open giveaway row"
    assert drawn_row, "drawn giveaway row"
    assert_nil open_row.ancestors("tbody[data-group='closed']").first, "open giveaway is not in the closed group"
    closed_group = drawn_row.ancestors("tbody").first
    assert_equal "closed", closed_group["data-group"]
    assert closed_group.key?("hidden"), "closed group starts collapsed"
    assert_match "Drawn / closed (1)", html
    assert_match "bob", drawn_row.text
    # one detail pane per giveaway, hidden until selected
    assert doc.at_css(".w95-detail[data-id='g#{open_g.id}'][hidden]")
    assert doc.at_css(".w95-detail[data-id='new'][hidden]")
  end

  test "admins always see the Extra Life tab and a create form without an Enabled box" do
    login_as(@admin)
    html = render_panel
    assert_match "Extra Life events", html
    assert_match "New Extra Life event", html
    assert_match "The event starts disabled", html
    refute_match "extra_life_event[enabled]", html
  end

  test "non-admins without events do not get the Extra Life tab" do
    login_as(make_user("viewer", user_type: 100))
    html = render_panel
    refute_match "data-tab=\"extra_life\"", html
  end

  test "the selected tab and giveaway come from the redirect parameters" do
    g = make_giveaway(@bot, "sel#{SecureRandom.hex(2)}")
    login_as(@admin)
    html = render_panel(params: { bexe_tab: "giveaways", bexe_giveaway: "g#{g.id}" })
    assert_match %(data-w95-tab-value="giveaways"), html
    assert_match %(data-w95-selected-value="g#{g.id}"), html
  end

  test "creating an event with Enabled ticked is refused with the reason, back in the Extra Life tab" do
    login_as(@admin)
    post bot_extra_life_events_path(@bot), params: { extra_life_event: {
      name: "EL 2026", broadcaster_login: "seggellion", tiltify_campaign_url: "https://tiltify.com/@seggellion/el-2026",
      stream_start_local: "2026-11-07T09:00", time_zone: "America/Vancouver", enabled: "1"
    } }
    assert_redirected_to desktop_path(bexe_tab: "extra_life")
    assert_match "requires a resolved Tiltify campaign id", flash[:alert]
    assert_equal 0, @bot.extra_life_events.count
  end

  test "a new event opens on its overview, disabled, with stream start converted from Vancouver time" do
    login_as(@admin)
    post bot_extra_life_events_path(@bot), params: { extra_life_event: {
      name: "EL 2026", broadcaster_login: "seggellion", tiltify_campaign_url: "https://tiltify.com/@seggellion/el-2026",
      stream_start_local: "2026-11-07T09:00", time_zone: "America/Vancouver"
    } }
    event = @bot.extra_life_events.last
    assert_redirected_to bot_extra_life_event_path(@bot, event, tab: "overview")
    refute event.enabled
    assert_equal ActiveSupport::TimeZone["America/Vancouver"].parse("2026-11-07 09:00").utc, event.stream_start_at
  end

  test "event window shows readiness, the add-prize form and settings to admins" do
    event = make_event(@bot, tiltify_campaign_id: nil, enabled: false, tiltify_campaign_url: "https://tiltify.com/@seggellion/el")
    login_as(@admin)
    get bot_extra_life_event_path(@bot, event, tab: "prizes")
    assert_response :success
    assert_match "Ready for stream?", response.body
    assert_match "Waiting for the bot to resolve", response.body
    assert_match "<legend>Add a prize</legend>", response.body
    assert Nokogiri::HTML(response.body).at_css("input[type=hidden][name=return_to][value=event]"), "prize form returns to the event"
    assert_match "Save settings", response.body
    assert_match %(data-w95-tab-value="prizes"), response.body
    # enabling is not offered before the campaign is resolved
    doc = Nokogiri::HTML(response.body)
    enable = doc.css("button").find { |b| b.text.strip == "Enable event" }
    assert enable && enable.key?("disabled"), "Enable button is disabled until the campaign resolves"
  end

  test "adding a prize from the event window creates a free event giveaway and returns to the Prizes tab" do
    event = make_event(@bot)
    login_as(@admin)
    post bot_giveaways_path(@bot), params: { return_to: "event", giveaway: {
      title: "Shattered Vanduul Lance Display", description: "First Extra Life prize", command_name: "!Lance",
      mode: Giveaway::EVENT_MODE, extra_life_event_id: event.id, cost: 0, channel: @bot.channel
    } }
    assert_redirected_to bot_extra_life_event_path(@bot, event, tab: "prizes")
    g = event.giveaways.last
    assert_equal "lance", g.command_name
    assert_equal "open", g.entry_state
    assert_equal 0, g.cost
  end

  test "a refused prize reports why on the event window" do
    event = make_event(@bot)
    login_as(@admin)
    post bot_giveaways_path(@bot), params: { return_to: "event", giveaway: {
      title: "Bad", description: "d", command_name: "odds", mode: Giveaway::EVENT_MODE, extra_life_event_id: event.id, cost: 0
    } }
    assert_redirected_to bot_extra_life_event_path(@bot, event, tab: "prizes")
    assert_match "Giveaway not created", flash[:alert]
  end

  test "desktop giveaway forms return to the Bot Manager with the giveaway selected" do
    login_as(@admin)
    post bot_giveaways_path(@bot), params: { giveaway: { title: "x", description: "d", mode: "single", command_name: "xyz#{SecureRandom.hex(2)}", cost: 0 } }
    g = @bot.giveaways.last
    assert_redirected_to desktop_path(bexe_tab: "giveaways", bexe_giveaway: "g#{g.id}")

    patch bot_giveaway_path(@bot, g), params: { giveaway: { title: "renamed" } }
    assert_redirected_to desktop_path(bexe_tab: "giveaways", bexe_giveaway: "g#{g.id}")
    assert_equal "renamed", g.reload.title

    post bot_giveaways_path(@bot), params: { giveaway: { title: "", description: "", mode: "single" } }
    assert_redirected_to desktop_path(bexe_tab: "giveaways", bexe_giveaway: "new")
    assert_match "Giveaway not created", flash[:alert]
  end

  test "enable and disable from the event toolbar change only the enabled flag" do
    event = make_event(@bot, enabled: false)
    start = event.stream_start_at
    login_as(@admin)
    patch bot_extra_life_event_path(@bot, event), params: { tab: "overview", extra_life_event: { enabled: "1" } }
    assert_redirected_to bot_extra_life_event_path(@bot, event, tab: "overview")
    event.reload
    assert event.enabled
    assert_equal start, event.stream_start_at
    assert_equal "seggellion", event.broadcaster_login
  end

  test "operators cannot toggle or reconfigure the event" do
    event = make_event(@bot, enabled: false)
    operator = make_user("mod", user_type: 30)
    event.operators.create!(user: operator)
    login_as(operator)
    get bot_extra_life_event_path(@bot, event)
    assert_response :success
    refute_match "Enable event", response.body
    refute_match "<legend>Add a prize</legend>", response.body
    patch bot_extra_life_event_path(@bot, event), params: { extra_life_event: { enabled: "1" } }
    assert_redirected_to root_path
    refute event.reload.enabled
  end

  test "the selected tab is drawn active on the server and only its panel is shown" do
    event = make_event(@bot)
    login_as(@admin)
    get bot_extra_life_event_path(@bot, event, tab: "donations")
    doc = Nokogiri::HTML(response.body)
    active = doc.css(".w95-tab.active")
    assert_equal ["donations"], active.map { |t| t["data-tab"] }
    assert_equal "true", active.first["aria-selected"]
    visible = doc.css(".w95-tabpanel").reject { |p| p.key?("hidden") }.map { |p| p["data-tab"] }
    assert_equal ["donations"], visible

    get bot_extra_life_event_path(@bot, event, tab: "bogus")
    assert_equal ["overview"], Nokogiri::HTML(response.body).css(".w95-tab.active").map { |t| t["data-tab"] }

    html = render_panel(params: { bexe_tab: "extra_life" })
    panel = Nokogiri::HTML.fragment(html)
    assert_equal ["extra_life"], panel.css(".w95-tab.active").map { |t| t["data-tab"] }
    assert panel.at_css(".w95-tabpanel[data-tab='giveaways'][hidden]")
  end
end
