require "test_helper"
require_relative "../support/giveaway_test_helper"

# M5 gate (Rails): event setup, donation review, manual assignment, status confirmation, cancellation, authorization.
class ExtraLifeOperatorTest < GiveawayIntegrationTestCase
  include ExtraLifeTestData

  class FakeLookup
    USERS = { "seggellion" => "1000", "dana" => "2004", "alice" => "2001" }.freeze
    attr_accessor :fail

    def by_login(login)
      raise TwitchUserLookup::Error, "twitch_http_503" if fail

      id = USERS[login.to_s.strip.downcase]
      id && TwitchUserLookup::User.new(id: id, login: login.to_s.strip.downcase, display_name: login.to_s.strip)
    end

    def by_id(id)
      raise TwitchUserLookup::Error, "twitch_http_503" if fail

      login = USERS.key(id.to_s)
      login && TwitchUserLookup::User.new(id: id.to_s, login: login, display_name: login.capitalize)
    end
  end

  setup do
    @lookup = FakeLookup.new
    TwitchUserLookup.backend = @lookup
    @bot = make_bot
    @event = make_event(@bot)
    @g1 = make_event_giveaway(@bot, @event, "prize#{SecureRandom.hex(2)}")
    @admin = make_user("owner", user_type: 0)
    @operator = make_user("mod", user_type: 30)
    @event.operators.create!(user: @operator)
    @outsider = make_user("othermod", user_type: 30)
    @donation = make_donation(outcome: "NO_LOGIN_CANDIDATE")
    @donation.update_columns(donor_name: "Dana D")
  end

  teardown { TwitchUserLookup.backend = nil }

  def event_path
    bot_extra_life_event_path(@bot, @event)
  end

  test "event page renders for operators with preview, review list and health" do
    login_as(@operator)
    get event_path
    assert_response :success
    assert_match "Donations needing review (1)", response.body
    assert_match "Dana D", response.body
    refute_match "Settings (admins)", response.body
  end

  test "outsiders, anonymous users and cross-event ids are denied (T33)" do
    other_event = make_event(make_bot(channel: "other"))
    other_donation = make_donation(campaign: "99999999-2222-3333-4444-555555555555", outcome: "NO_NAME")
    [nil, @outsider].each do |user|
      login_as(user)
      get event_path
      assert_redirected_to root_path
      post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "2004", reason: "x" }
      assert_nil @donation.reload.manual_twitch_user_id
    end
    login_as(@operator)
    get bot_extra_life_event_path(other_event.bot, other_event)
    assert_redirected_to root_path
    assert_raises(ActiveRecord::RecordNotFound) do # another campaign's donation is not reachable through this event
      post assign_bot_extra_life_event_donation_path(@bot, @event, other_donation), params: { twitch_user_id: "2004", reason: "x" }
    end
    assert_nil other_donation.reload.manual_twitch_user_id
    post bot_extra_life_events_path(@bot), params: { extra_life_event: { name: "x" } }
    assert_redirected_to root_path # operators cannot create or reconfigure events
    patch event_path, params: { extra_life_event: { enabled: "0" } }
    assert @event.reload.enabled
  end

  test "two-step manual assignment shows the canonical account, is audited and populates undrawn giveaways only" do
    login_as(@operator)
    get assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { login: "  Dana " }
    assert_match "Twitch id <strong>2004</strong>", response.body
    assert_nil @donation.reload.manual_twitch_user_id

    post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "2004", reason: "" }
    assert_match "reason is required", flash[:alert]
    post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "2004", reason: "donor DM'd" }
    @donation.reload
    assert_equal ["2004", "2004", @operator.id], [@donation.manual_twitch_user_id, @donation.resolved_twitch_user_id, @donation.manual_assigned_by_user_id]
    audit = @donation.audit_events.last
    assert_equal ["manual_assigned", @operator.id, "donor DM'd"], [audit.event_type, audit.actor_user_id, audit.reason]
    assert_equal [0, 1, 1, nil], pool(@g1)["2004"]
    g2 = make_event_giveaway(@bot, @event, "later#{SecureRandom.hex(2)}") # T05 through Rails creation
    assert_equal [0, 1, 1, nil], pool(g2)["2004"]
  end

  test "assignment fails safely when Twitch is down or the account does not exist" do
    login_as(@operator)
    @lookup.fail = true
    get assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { login: "dana" }
    assert_match "could not be reached", response.body
    post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "2004", reason: "x" }
    assert_match "could not verify", flash[:alert]
    @lookup.fail = false
    post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "999999", reason: "x" }
    assert_match "does not exist", flash[:alert]
    post assign_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { twitch_user_id: "1000", reason: "x" }
    assert_match "broadcaster", flash[:alert]
    assert_nil @donation.reload.manual_twitch_user_id
  end

  test "operator confirms a missing donation's status; audited; unblocks or revokes" do
    alice = make_account("2001", "alice")
    missing = make_donation(account_id: alice.twitch_user_id, status: "missing")
    cutoff = Time.utc(2026, 11, 7, 20)
    blockers = -> { ActiveRecord::Base.connection.select_rows(ActiveRecord::Base.sanitize_sql(["SELECT * FROM extra_life_draw_blockers(?, ?)", @g1.id, cutoff])).to_h }
    assert_equal 1, blockers.call["missing_donation_status_unconfirmed"]
    login_as(@operator)
    post confirm_status_bot_extra_life_event_donation_path(@bot, @event, @donation), params: { status: "refunded" }
    assert_match "Only donations marked missing", flash[:alert]
    post confirm_status_bot_extra_life_event_donation_path(@bot, @event, missing), params: { status: "completed", note: "seen in dashboard" }
    missing.reload
    assert_equal ["completed", "operator_confirmed", @operator.id, "seen in dashboard"],
                 [missing.provider_status, missing.status_source, missing.status_confirmed_by_user_id, missing.status_note]
    assert_equal "status_confirmed", missing.audit_events.last.event_type
    assert_nil blockers.call["missing_donation_status_unconfirmed"]
    assert_equal 1, pool(@g1)["2001"][1]
  end

  test "pending draw can be cancelled with a reason; finalized cannot" do
    attempt = GiveawayDrawAttempt.create!(giveaway: @g1, extra_life_event: @event, cutoff_at: Time.current, blocking_reason: "twitch_verification_pending")
    @g1.update_columns(entry_state: "frozen")
    login_as(@operator)
    post cancel_bot_extra_life_event_draw_attempt_path(@bot, @event, attempt), params: { reason: "" }
    assert_equal "pending", attempt.reload.status
    post cancel_bot_extra_life_event_draw_attempt_path(@bot, @event, attempt), params: { reason: "Twitch outage, redo later" }
    assert_equal ["cancelled", @operator.id], [attempt.reload.status, attempt.cancelled_by_user_id]
    assert_equal "open", @g1.reload.entry_state
  end

  test "admin creates an event; broadcaster resolved to id; stream start converted from local zone" do
    login_as(@admin)
    # 09:00 America/Vancouver on 2027-11-06 is PDT (DST ends 2027-11-07) = 16:00 UTC.
    post bot_extra_life_events_path(@bot), params: { extra_life_event: {
      name: "EL 2027", broadcaster_login: "Seggellion", tiltify_campaign_url: "https://tiltify.com/@seggellion/el-2027",
      stream_start_local: "2027-11-06T09:00", time_zone: "America/Vancouver", enabled: "0" } }
    e = ExtraLifeEvent.order(:id).last
    assert_equal ["EL 2027", "1000", "seggellion", Time.utc(2027, 11, 6, 16)], [e.name, e.broadcaster_twitch_id, e.broadcaster_login, e.stream_start_at]
    post bot_extra_life_events_path(@bot), params: { extra_life_event: { name: "bad", broadcaster_login: "nobodyhere", stream_start_local: "2027-11-06T09:00" } }
    assert_match "is not a Twitch account", flash[:alert]
    patch bot_extra_life_event_path(@bot, e), params: { extra_life_event: { enabled: "1" } }
    assert_match "requires a resolved Tiltify campaign id", flash[:alert]
  end

  test "admin creates an event-mode giveaway from the existing panel form" do
    login_as(@admin)
    post bot_giveaways_path(@bot), params: { giveaway: { title: "Prize", description: "d", mode: "extra-life-tiltify",
                                                         command_name: "elprize#{SecureRandom.hex(2)}", channel: @bot.channel, extra_life_event_id: @event.id, cost: 0 } }
    g = Giveaway.order(:id).last
    assert_equal [@event.id, "open"], [g.extra_life_event_id, g.entry_state]
    post bot_giveaways_path(@bot), params: { giveaway: { title: "P", description: "d", mode: "extra-life-tiltify", command_name: "x#{SecureRandom.hex(2)}", channel: @bot.channel } }
    assert_match "Extra life event is required", flash[:alert]
  end
end
