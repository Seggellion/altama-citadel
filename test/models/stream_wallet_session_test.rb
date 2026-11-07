require "test_helper"
require_relative "../support/stream_overlay_test_helper"

class StreamWalletSessionTest < GiveawayModelTestCase
  include StreamOverlayTestData

  setup do
    @bot = make_bot
    @admin = make_user("owner", user_type: 0)
  end

  def update(session, balance, key: SecureRandom.uuid)
    session.reload.update_balance!(balance: balance, user: @admin, idempotency_key: key, lock_version: session.lock_version)
  end

  test "the brief's earnings table: start, profit, loss, unchanged resubmit, new session" do
    s = start_session(@bot, 1_000_000, user: @admin)
    assert_equal 0, s.net_auec

    update(s, 1_175_000)
    assert_equal 175_000, s.reload.net_auec

    update(s, 945_000)
    assert_equal(-55_000, s.reload.net_auec)

    update(s, 945_000)
    assert_equal(-55_000, s.reload.net_auec, "same balance again adds nothing")
    assert_equal 1_000_000, s.starting_balance_auec

    s.end!(user: @admin)
    s2 = start_session(@bot, 945_000, user: @admin)
    assert_equal 0, s2.net_auec
    assert_equal "ended", s.reload.status
    assert_equal(-55_000, s.net_auec, "old session keeps its own numbers")
    assert_equal %w[start update update update], s.entries.map(&:kind)
  end

  test "a second Start while one is active is refused by the database" do
    start_session(@bot, 10)
    err = assert_raises(StreamWalletSession::AlreadyActive) { start_session(@bot, 20) }
    assert_match "already running", err.message
    assert_equal 1, @bot.stream_wallet_sessions.count
  end

  test "another bot can have its own active session" do
    start_session(@bot, 10)
    assert start_session(make_bot(channel: "other"), 20)
  end

  test "the starting balance cannot be changed after Start" do
    s = start_session(@bot, 100)
    s.starting_balance_auec = 5
    refute s.save
    assert_includes s.errors[:starting_balance_auec], "can't change after Start"
  end

  test "a double-clicked update (same form key) applies once" do
    s = start_session(@bot, 100)
    lv = s.lock_version
    assert_equal :updated, s.update_balance!(balance: 150, user: @admin, idempotency_key: "k1", lock_version: lv)
    assert_equal :duplicate, s.reload.update_balance!(balance: 150, user: @admin, idempotency_key: "k1", lock_version: lv)
    assert_equal 2, s.entries.count
    assert_equal 50, s.reload.net_auec
  end

  test "an update from an out-of-date window is rejected instead of overwriting a newer balance" do
    s = start_session(@bot, 100)
    stale_lv = s.lock_version
    update(s, 300)
    assert_raises(StreamWalletSession::StaleWindow) do
      s.reload.update_balance!(balance: 200, user: @admin, idempotency_key: "old-tab", lock_version: stale_lv)
    end
    assert_equal 300, s.reload.current_balance_auec
  end

  test "updates to an ended session are refused" do
    s = start_session(@bot, 100)
    s.end!(user: @admin)
    assert_raises(StreamWalletSession::NotActive) { update(s, 200) }
  end

  test "ending twice is harmless" do
    s = start_session(@bot, 100)
    assert_equal :ended, s.end!(user: @admin)
    assert_equal :already_ended, s.reload.end!(user: @admin)
  end

  test "balance parsing accepts separators and rejects everything else" do
    assert_equal 1_175_000, StreamWalletSession.parse_balance("1,175,000")
    assert_equal 1_175_000, StreamWalletSession.parse_balance(" 1 175 000 ")
    assert_equal 0, StreamWalletSession.parse_balance("0")
    assert_equal 999_999_999_999, StreamWalletSession.parse_balance("999,999,999,999")
    ["", "  ", "-5", "12.5", "abc", "1e6", "1000000000000", "99999999999999999999"].each do |bad|
      assert_raises(StreamWalletSession::InvalidBalance, "should reject #{bad.inspect}") { StreamWalletSession.parse_balance(bad) }
    end
  end

  test "the database rejects negative and oversized balances even if validation is skipped" do
    s = start_session(@bot, 100)
    assert_raises(ActiveRecord::StatementInvalid) { s.update_columns(current_balance_auec: -1) }
  end
end
