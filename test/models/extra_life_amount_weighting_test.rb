require "test_helper"
require_relative "../support/giveaway_test_helper"

# extra_life_pool v2: optional amount-weighted donor tickets (owner decision 2026-11-07).
class ExtraLifeAmountWeightingTest < GiveawayModelTestCase
  include ExtraLifeTestData

  setup do
    @bot = make_bot
    @event = make_event(@bot) # stream start 2026-11-07 16:00 UTC
    @g = make_event_giveaway(@bot, @event, "lance#{SecureRandom.hex(2)}")
    make_account("2001", "alice")
    make_account("2002", "bob")
    make_account("1000", "seggellion")
  end

  def donate(account, amount, at: Time.utc(2026, 11, 7, 17), status: "completed")
    d = make_donation(account_id: account, completed_at: at, status: status)
    d.update_columns(amount_value: amount)
    d
  end

  def chat(account)
    GiveawayTicketSource.create!(giveaway: @g, twitch_user_id: account, source: "chat", granted_at: Time.current)
  end

  def weigh(per_dollar)
    @event.update!(donor_tickets_per_dollar: per_dollar)
    @event.refresh_donor_sources!
    pool(@g)
  end

  test "flat rule is unchanged when the setting is blank or zero" do
    donate("2001", 10)
    donate("2001", 25)
    chat("2001")
    [nil, 0].each do |setting|
      assert_equal [1, 1, 2, nil], weigh(setting)["2001"], "setting #{setting.inspect}"
    end
  end

  test "10 per dollar: $10 = 100 donor tickets, chat adds exactly 1" do
    donate("2001", 10)
    donate("2002", 10)
    chat("2002")
    p = weigh(10)
    assert_equal [0, 100, 100, nil], p["2001"]
    assert_equal [1, 100, 101, nil], p["2002"]
  end

  test "cents are floored, repeat donations are summed, tiny donations still give 1" do
    donate("2001", 12.50)
    donate("2002", 0.05)
    donate("2002", 0.04)
    p = weigh(10)
    assert_equal 125, p["2001"][1]
    assert_equal 1, p["2002"][1] # floor(0.9) = 0, but a qualifying donor always has at least 1
    donate("2001", 7.25)
    assert_equal 197, weigh(10)["2001"][1] # floor(197.5)
  end

  test "refunded, missing, pre-stream and post-cutoff donations do not count" do
    donate("2001", 10)
    refunded = donate("2001", 50)
    donate("2001", 40, at: Time.utc(2026, 11, 7, 15)) # before stream start
    assert_equal 600, weigh(10)["2001"][1]
    refunded.update_columns(provider_status: "refunded")
    assert_equal 100, weigh(10)["2001"][1]
    only = donate("2002", 5)
    assert_equal 50, weigh(10)["2002"][1]
    only.update_columns(provider_status: "missing")
    assert_nil weigh(10)["2002"], "no qualifying donation left: donor ticket revoked"

    # A pending draw freezes the amounts at its cutoff.
    GiveawayDrawAttempt.create!(giveaway: @g, extra_life_event: @event, status: "pending", cutoff_at: Time.utc(2026, 11, 7, 18))
    donate("2001", 30, at: Time.utc(2026, 11, 7, 19))
    assert_equal 100, weigh(10)["2001"][1]
  end

  test "the broadcaster stays at weight 0 however much they donate" do
    donate("1000", 100)
    chat("1000")
    p = weigh(10)
    assert_equal [1, 0, 0, "broadcaster"].values_at(0, 2, 3), p["1000"].values_at(0, 2, 3)
  end

  test "the setting is validated" do
    @event.donor_tickets_per_dollar = -1
    refute @event.valid?
    @event.donor_tickets_per_dollar = 1001
    refute @event.valid?
    @event.donor_tickets_per_dollar = 10
    assert @event.valid?
    assert_match "10 donor tickets per $1", @event.donor_rule_text
  end
end
