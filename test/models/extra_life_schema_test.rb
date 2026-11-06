require "test_helper"
require_relative "../support/giveaway_test_helper"

# M2 gate: invariants enforced by the migrated database itself, plus the shared SQL functions.
class ExtraLifeSchemaTest < GiveawayModelTestCase
  include ExtraLifeTestData

  setup do
    @bot = make_bot
    @event = make_event(@bot)
    @g1 = make_event_giveaway(@bot, @event, "prize#{SecureRandom.hex(2)}")
    @alice = make_account("2000000000123", "alice") # beyond 32-bit integer range
    @bob = make_account("98765", "bob")
  end

  def sql(statement)
    ActiveRecord::Base.connection.execute(statement)
  end

  # Constraint violations abort the surrounding test transaction; run them inside a savepoint.
  def assert_db_rejects(error = ActiveRecord::StatementInvalid, &block)
    assert_raises(error) { ActiveRecord::Base.transaction(requires_new: true, &block) }
  end

  test "string-safe Twitch ids larger than any integer column" do
    big = "92233720368547758079"
    make_account(big, "huge")
    assert_equal big, TwitchAccount.find_by(twitch_user_id: big).twitch_user_id
  end

  test "two independent sources per account per giveaway, each unique" do
    GiveawayTicketSource.create!(giveaway: @g1, twitch_user_id: @alice.twitch_user_id, source: "chat", granted_at: Time.current)
    make_donation(account_id: @alice.twitch_user_id)
    @event.refresh_donor_sources!
    assert_equal [1, 1, 2, nil], pool(@g1)[@alice.twitch_user_id]
    assert_db_rejects(ActiveRecord::RecordNotUnique) do
      GiveawayTicketSource.create!(giveaway: @g1, twitch_user_id: @alice.twitch_user_id, source: "chat", granted_at: Time.current)
    end
    assert_db_rejects do
      sql("INSERT INTO giveaway_ticket_sources (giveaway_id, twitch_user_id, source, granted_at, created_at, updated_at) " \
          "VALUES (#{@g1.id}, '#{@alice.twitch_user_id}', 'bonus', now(), now(), now())")
    end
  end

  test "same provider donation id is stored once" do
    make_donation(ext: "dup-1")
    assert_db_rejects(ActiveRecord::RecordNotUnique) { make_donation(ext: "dup-1") }
  end

  test "repeat donations and later giveaways: one donor ticket each, populated on creation" do
    3.times { make_donation(account_id: @alice.twitch_user_id) }
    @event.refresh_donor_sources!
    g2 = make_event_giveaway(@bot, @event, "later#{SecureRandom.hex(2)}")
    assert_equal [0, 1, 1, nil], pool(@g1)[@alice.twitch_user_id]
    assert_equal [0, 1, 1, nil], pool(g2)[@alice.twitch_user_id]
  end

  test "window is [stream_start, cutoff) and other campaigns, pending and refunded donations do not count" do
    make_donation(account_id: @alice.twitch_user_id, completed_at: @event.stream_start_at - 1)
    make_donation(account_id: @alice.twitch_user_id, campaign: "99999999-2222-3333-4444-555555555555")
    make_donation(account_id: @alice.twitch_user_id, status: "refunded")
    make_donation(account_id: @alice.twitch_user_id, status: "missing")
    make_donation(account_id: @bob.twitch_user_id, completed_at: @event.stream_start_at)
    @event.refresh_donor_sources!
    assert_nil pool(@g1)[@alice.twitch_user_id]
    assert_equal 1, pool(@g1)[@bob.twitch_user_id][1]
  end

  test "refunding all support revokes the donor source but keeps chat; one remaining donation keeps it" do
    GiveawayTicketSource.create!(giveaway: @g1, twitch_user_id: @alice.twitch_user_id, source: "chat", granted_at: Time.current)
    d1 = make_donation(account_id: @alice.twitch_user_id)
    d2 = make_donation(account_id: @alice.twitch_user_id)
    @event.refresh_donor_sources!
    d1.update!(provider_status: "refunded")
    @event.refresh_donor_sources!
    assert_equal [1, 1, 2, nil], pool(@g1)[@alice.twitch_user_id]
    d2.update!(provider_status: "refunded")
    @event.refresh_donor_sources!
    assert_equal [1, 0, 1, nil], pool(@g1)[@alice.twitch_user_id]
    revoked = GiveawayTicketSource.find_by(giveaway: @g1, twitch_user_id: @alice.twitch_user_id, source: "donor")
    assert_equal false, revoked.active
    assert_equal "no_qualifying_donation", revoked.revoke_reason
  end

  test "broadcaster excluded by exact id; similar login is not" do
    owner = make_account("1000", "seggellion")
    fan = make_account("1001", "seggellionfan")
    [owner, fan].each { |a| GiveawayTicketSource.create!(giveaway: @g1, twitch_user_id: a.twitch_user_id, source: "chat", granted_at: Time.current) }
    make_donation(account_id: owner.twitch_user_id)
    @event.refresh_donor_sources!
    assert_equal [1, 0, 0, "broadcaster"], pool(@g1)["1000"]
    assert_equal [1, 0, 1, nil], pool(@g1)["1001"]
  end

  def finalize!(giveaway, account)
    attempt = GiveawayDrawAttempt.create!(giveaway: giveaway, extra_life_event: giveaway.extra_life_event, cutoff_at: Time.current,
                                          status: "finalized", finalized_at: Time.current, pool: [], result: "winner",
                                          winner_twitch_user_id: account.twitch_user_id)
    GiveawayAward.create!(giveaway: giveaway, extra_life_event: giveaway.extra_life_event, twitch_user_id: account.twitch_user_id,
                          draw_attempt: attempt, awarded_at: Time.current)
  end

  test "one award per giveaway and one per account per event; other events unaffected" do
    g2 = make_event_giveaway(@bot, @event, "second#{SecureRandom.hex(2)}")
    finalize!(@g1, @alice)
    assert_db_rejects(ActiveRecord::RecordNotUnique) { finalize!(g2, @alice) }
    GiveawayTicketSource.create!(giveaway: g2, twitch_user_id: @alice.twitch_user_id, source: "chat", granted_at: Time.current)
    assert_equal [1, 0, 0, "event_winner"], pool(g2)[@alice.twitch_user_id]

    other_event = make_event(@bot)
    g3 = make_event_giveaway(@bot, other_event, "next#{SecureRandom.hex(2)}")
    GiveawayTicketSource.create!(giveaway: g3, twitch_user_id: @alice.twitch_user_id, source: "chat", granted_at: Time.current)
    assert_equal [1, 0, 1, nil], pool(g3)[@alice.twitch_user_id]
    finalize!(g3, @alice)
  end

  test "award event must equal the giveaway's event" do
    other_event = make_event(@bot)
    attempt = GiveawayDrawAttempt.create!(giveaway: @g1, extra_life_event: @event, cutoff_at: Time.current)
    assert_db_rejects(ActiveRecord::InvalidForeignKey) do
      GiveawayAward.create!(giveaway: @g1, extra_life_event: other_event, twitch_user_id: @bob.twitch_user_id, draw_attempt: attempt, awarded_at: Time.current)
    end
  end

  test "only one live draw attempt per giveaway; finalized snapshot is complete" do
    GiveawayDrawAttempt.create!(giveaway: @g1, extra_life_event: @event, cutoff_at: Time.current)
    assert_db_rejects(ActiveRecord::RecordNotUnique) { GiveawayDrawAttempt.create!(giveaway: @g1, extra_life_event: @event, cutoff_at: Time.current) }
    assert_db_rejects do
      sql("UPDATE giveaway_draw_attempts SET status = 'finalized' WHERE giveaway_id = #{@g1.id}")
    end
  end

  test "finalized giveaways keep their donor sources when ledger changes" do
    make_donation(account_id: @alice.twitch_user_id)
    @event.refresh_donor_sources!
    finalize!(@g1, @bob)
    @g1.update_columns(winner: "bob", entry_state: "finalized")
    ExternalDonation.update_all(provider_status: "refunded")
    @event.refresh_donor_sources!
    assert GiveawayTicketSource.find_by(giveaway: @g1, twitch_user_id: @alice.twitch_user_id, source: "donor").active
  end

  test "resolved identity and manual assignment audit are enforced by the database" do
    d = make_donation
    assert_db_rejects { d.update_columns(resolved_twitch_user_id: @alice.twitch_user_id) }
    assert_db_rejects do
      d.update_columns(manual_twitch_user_id: @alice.twitch_user_id, resolved_twitch_user_id: @alice.twitch_user_id)
    end
  end

  test "event-mode consistency, no silent conversion, deletion guard" do
    assert_db_rejects { sql("UPDATE giveaways SET mode = 'single' WHERE id = #{@g1.id}") }
    legacy = make_giveaway(@bot, "legacy#{SecureRandom.hex(2)}")
    refute legacy.update(mode: Giveaway::EVENT_MODE, extra_life_event: @event)
    refute @bot.giveaways.new(title: "t", description: "d", mode: Giveaway::EVENT_MODE, command_name: "x#{SecureRandom.hex(2)}").valid?
    GiveawayDrawAttempt.create!(giveaway: @g1, extra_life_event: @event, cutoff_at: Time.current)
    refute @g1.destroy
    assert Giveaway.exists?(@g1.id)
  end

  test "event identity fields are frozen after a finalized draw" do
    finalize!(@g1, @alice)
    refute @event.update(stream_start_at: Time.utc(2026, 11, 1))
    assert_includes @event.errors[:stream_start_at].join, "cannot change"
    assert @event.reload.update(name: "renamed")
  end

  test "draw blockers and unresolved counts" do
    cutoff = Time.utc(2026, 11, 7, 20)
    blockers = -> { ActiveRecord::Base.connection.select_rows(ActiveRecord::Base.sanitize_sql(["SELECT * FROM extra_life_draw_blockers(?, ?)", @g1.id, cutoff])).to_h }
    assert_equal({}, blockers.call)
    make_donation(outcome: "PENDING_VERIFICATION")
    make_donation(outcome: "AMBIGUOUS")
    m = make_donation(account_id: @alice.twitch_user_id, status: "missing")
    assert_equal({ "twitch_verification_pending" => 1, "missing_donation_status_unconfirmed" => 1 }, blockers.call)
    make_donation(account_id: @alice.twitch_user_id) # other confirmed support makes the missing one irrelevant
    assert_equal({ "twitch_verification_pending" => 1 }, blockers.call)
    @event.update!(last_complete_sync_at: cutoff - 1)
    assert_includes blockers.call.keys, "donation_sync_not_complete_through_cutoff"
    unresolved = ActiveRecord::Base.connection.select_rows(ActiveRecord::Base.sanitize_sql(["SELECT * FROM extra_life_unresolved_counts(?, ?)", @g1.id, cutoff])).to_h
    assert_equal({ "AMBIGUOUS" => 1 }, unresolved)
    assert m
  end
end
