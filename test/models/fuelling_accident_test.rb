require "test_helper"
require_relative "../support/stream_overlay_test_helper"

# Day counts are computed by PostgreSQL at an explicit instant (as_of), so these tests pin the clock in the
# database itself; Rails time travel would not move PostgreSQL's now().
# The same instants and expected values are in altama_sys/tests/test_accident.py (cross-app agreement).
class FuellingAccidentTest < GiveawayModelTestCase
  include StreamOverlayTestData

  setup do
    @bot = make_bot(channel: "Seggellion")
    @admin = make_user("owner", user_type: 0)
  end

  def days(as_of, channel: "seggellion") = FuellingAccident.current_for(channel, as_of: as_of)&.days

  test "no accident recorded means no count, not zero" do
    assert_nil FuellingAccident.current_for("seggellion")
  end

  test "midnight in Vancouver, not UTC midnight, advances the count (summer, UTC-7)" do
    accident_on(@bot, Date.new(2026, 7, 10))
    assert_equal 0, days(utc(2026, 7, 11, 6, 59))   # 23:59 Jul 10 local
    assert_equal 1, days(utc(2026, 7, 11, 7, 1))    # 00:01 Jul 11 local
    assert_equal 0, days(utc(2026, 7, 11, 0, 30)), "UTC midnight has passed but it is still Jul 10 in Vancouver"
  end

  test "the count follows the calendar across the March 2026 clock change" do
    accident_on(@bot, Date.new(2026, 3, 7))
    assert_equal 0, days(utc(2026, 3, 8, 7, 59))    # 23:59 PST Mar 7
    assert_equal 1, days(utc(2026, 3, 8, 8, 1))     # 00:01 PST Mar 8 (clocks jump at 02:00)
    assert_equal 1, days(utc(2026, 3, 9, 6, 59))    # 23:59 PDT Mar 8: a 23-hour day still counts as one
    assert_equal 2, days(utc(2026, 3, 9, 7, 1))     # 00:01 PDT Mar 9
  end

  test "the most recent non-voided accident wins and voiding falls back to the previous one" do
    accident_on(@bot, Date.new(2026, 7, 1))
    latest = accident_on(@bot, Date.new(2026, 7, 8))
    assert_equal 2, days(utc(2026, 7, 10, 19))
    latest.void!(user: @admin)
    assert_equal 9, days(utc(2026, 7, 10, 19))
  end

  test "a historic entry older than the current accident does not reset the counter" do
    accident_on(@bot, Date.new(2026, 7, 8))
    FuellingAccident.record_historic!(bot: @bot, user: @admin, date: "2026-06-01")
    assert_equal 2, days(utc(2026, 7, 10, 19))
  end

  test "record now reads today from PostgreSQL and shows 0" do
    a = FuellingAccident.record_now!(bot: @bot, user: @admin)
    assert_equal FuellingAccident.local_today, a.occurred_on
    assert_equal 0, FuellingAccident.current_for("seggellion").days
  end

  test "channel match is case-insensitive and other channels are ignored" do
    accident_on(make_bot(channel: "someoneelse"), Date.new(2026, 7, 9))
    accident_on(@bot, Date.new(2026, 7, 1))
    assert_equal 9, days(utc(2026, 7, 10, 19), channel: "SEGGELLION")
  end

  test "future dates are rejected" do
    tomorrow = FuellingAccident.local_today + 1
    err = assert_raises(ActiveRecord::RecordInvalid) { FuellingAccident.record_historic!(bot: @bot, user: @admin, date: tomorrow.iso8601) }
    assert_match "future", err.message
  end

  test "a malformed date is a friendly error" do
    assert_raises(FuellingAccident::Error) { FuellingAccident.record_historic!(bot: @bot, user: @admin, date: "next tuesday") }
  end
end
