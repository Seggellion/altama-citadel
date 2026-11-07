require "test_helper"
require "minitest/mock"
require_relative "../support/stream_overlay_test_helper"

# Stream tab in ALTAMA.EXE: admin-only wallet session, accident and overlay-link actions.
class StreamAdminTest < GiveawayIntegrationTestCase
  include StreamOverlayTestData

  setup do
    @bot = make_bot
    @admin = make_user("owner", user_type: 0)
  end

  def session = @bot.stream_wallet_sessions.order(:id).last

  def update_to(balance, key: SecureRandom.uuid)
    s = session.reload
    post update_balance_bot_stream_path(@bot), params: { session_id: s.id, lock_version: s.lock_version, idempotency_key: key, balance: balance }
  end

  def render_panel
    ApplicationController.renderer.new("action_dispatch.request.parameters" => { "bexe_tab" => "stream" })
                         .render(partial: "desktop/apps/altama_exe", assigns: { bots: Bot.where(id: @bot.id) })
  end

  test "anonymous and non-admin users cannot touch anything" do
    s = start_session(@bot, 1_000)
    a = accident_on(@bot, Date.new(2026, 7, 1))
    [nil, make_user("viewer", user_type: 30)].each do |user|
      login_as(user)
      post start_session_bot_stream_path(@bot), params: { balance: "5" }
      assert_redirected_to root_path
      post update_balance_bot_stream_path(@bot), params: { session_id: s.id, balance: "9999" }
      post end_session_bot_stream_path(@bot), params: { session_id: s.id }
      post record_accident_bot_stream_path(@bot)
      post record_historic_accident_bot_stream_path(@bot), params: { occurred_on: "2026-07-05" }
      post void_accident_bot_stream_path(@bot), params: { accident_id: a.id }
      post rotate_overlay_bot_stream_path(@bot)
      post update_overlay_bot_stream_path(@bot), params: { enabled: "0" }
      post start_session_bot_stream_path(@bot, format: :json), params: { balance: "5" }
      assert_response :forbidden
    end
    assert_equal 1, @bot.stream_wallet_sessions.count
    assert_equal [1_000, 1_000, "active"], [s.reload.starting_balance_auec, s.current_balance_auec, s.status]
    assert_equal 1, @bot.fuelling_accidents.count
    assert_nil a.reload.voided_at
    assert_nil @bot.reload.stream_overlay
  end

  test "writes need a valid CSRF token" do
    login_as(@admin)
    ActionController::Base.allow_forgery_protection = true
    post start_session_bot_stream_path(@bot), params: { balance: "1000" }
    assert_response :unprocessable_entity
  rescue ActionController::InvalidAuthenticityToken
    pass
  ensure
    ActionController::Base.allow_forgery_protection = false
    assert_equal 0, @bot.stream_wallet_sessions.count
  end

  test "start, profit, loss, duplicate, end and restart through the admin actions" do
    login_as(@admin)
    post start_session_bot_stream_path(@bot), params: { balance: "1,000,000", idempotency_key: "s1" }
    assert_redirected_to desktop_path(bexe_tab: "stream")
    assert_match "started at 1,000,000 aUEC", flash[:notice]
    assert_equal 0, session.net_auec

    update_to("1,175,000")
    assert_match "+175,000 aUEC", flash[:notice]
    update_to("945000", key: "dup")
    assert_match "−55,000 aUEC", flash[:notice]
    s = session.reload
    post update_balance_bot_stream_path(@bot), params: { session_id: s.id, lock_version: s.lock_version - 1, idempotency_key: "dup", balance: "945000" }
    assert_match "already saved", flash[:notice]
    assert_equal(-55_000, session.reload.net_auec)

    post start_session_bot_stream_path(@bot), params: { balance: "5" }
    assert_match "already running", flash[:alert]

    post end_session_bot_stream_path(@bot), params: { session_id: session.id, lock_version: session.lock_version }
    assert_match "ended at −55,000 aUEC", flash[:notice]
    post start_session_bot_stream_path(@bot), params: { balance: "945,000" }
    assert_equal 2, @bot.stream_wallet_sessions.count
    assert_equal 0, session.net_auec
  end

  test "bad input and stale windows come back as visible messages" do
    login_as(@admin)
    post start_session_bot_stream_path(@bot), params: { balance: "-5" }
    assert_match "whole number", flash[:alert]
    post start_session_bot_stream_path(@bot), params: { balance: "" }
    assert_match "Enter the wallet balance", flash[:alert]
    assert_equal 0, @bot.stream_wallet_sessions.count

    post start_session_bot_stream_path(@bot), params: { balance: "100" }
    stale = session.lock_version
    update_to("300")
    post update_balance_bot_stream_path(@bot), params: { session_id: session.id, lock_version: stale, idempotency_key: "old", balance: "200" }
    assert_match "another window", flash[:alert]
    assert_equal 300, session.reload.current_balance_auec
  end

  test "accident: past date, record now, undo, future date refused" do
    login_as(@admin)
    post record_historic_accident_bot_stream_path(@bot), params: { occurred_on: (FuellingAccident.local_today - 4).iso8601 }
    assert_match "4 days", flash[:notice]
    post record_accident_bot_stream_path(@bot)
    assert_match "0 days", flash[:notice]
    assert_equal 0, FuellingAccident.current_for(@bot.channel).days
    post void_accident_bot_stream_path(@bot), params: { accident_id: FuellingAccident.current_for(@bot.channel).accident.id }
    assert_match "4 days", flash[:notice]
    post record_historic_accident_bot_stream_path(@bot), params: { occurred_on: (FuellingAccident.local_today + 1).iso8601 }
    assert_match "future", flash[:alert]
    post record_historic_accident_bot_stream_path(@bot), params: { occurred_on: "soon" }
    assert_match "YYYY-MM-DD", flash[:alert]
  end

  test "an OBS link is shown once and rotating it revokes the old one" do
    login_as(@admin)
    post rotate_overlay_bot_stream_path(@bot)
    url1 = flash[:stream_overlay_url]
    assert_match %r{/overlay/[A-Za-z0-9_-]{43}\z}, url1
    post rotate_overlay_bot_stream_path(@bot)
    url2 = flash[:stream_overlay_url]
    refute_equal url1, url2
    assert_nil StreamOverlay.find_by_token(url1.split("/").last)
    assert StreamOverlay.find_by_token(url2.split("/").last)

    post update_overlay_bot_stream_path(@bot), params: { enabled: "0", accident_caption: "Days without a fuel fire" }
    assert_equal [false, "Days without a fuel fire"], [@bot.stream_overlay.reload.enabled, @bot.stream_overlay.accident_caption]
  end

  test "the Stream tab renders for admins in every state and not for others" do
    login_as(make_user("viewer", user_type: 100))
    refute_match 'data-tab="stream"', render_panel

    login_as(@admin)
    html = render_panel
    assert_match "NOT STARTED", html
    assert_match "No accident on record", html
    assert_match "No OBS link yet", html
    assert_match "Giveaways", html, "existing tabs still render"

    s = start_session(@bot, 1_000_000)
    s.update_balance!(balance: 945_000, user: nil, idempotency_key: "k", lock_version: s.lock_version)
    accident_on(@bot, FuellingAccident.local_today - 1)
    StreamOverlay.for_bot(@bot).rotate_token!
    html = render_panel
    doc = Nokogiri::HTML.fragment(html)
    assert doc.at_css(".w95-tab.active[data-tab='stream']"), "stream tab selected from bexe_tab"
    assert_match "ACTIVE", html
    assert_match "−55,000 aUEC", html
    assert_match "1 day</strong> since", html
    assert_match "An OBS link exists", html
  end

  test "before the migration has run, ALTAMA.EXE still renders without the Stream tab" do
    login_as(@admin)
    StreamWalletSession.stub(:table_exists?, false) do
      html = render_panel
      refute_match 'data-tab="stream"', html
      assert_match "Giveaways", html
    end
  end
end
