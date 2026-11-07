require "test_helper"
require_relative "../support/stream_overlay_test_helper"

class StreamOverlayTest < GiveawayModelTestCase
  include StreamOverlayTestData

  setup { @bot = make_bot }

  test "only the digest of the token is stored and rotation revokes the old token" do
    overlay = StreamOverlay.for_bot(@bot)
    t1 = overlay.rotate_token!
    assert_match StreamOverlay::TOKEN_FORMAT, t1
    refute_equal t1, overlay.reload.token_digest
    assert_equal overlay, StreamOverlay.find_by_token(t1)

    t2 = overlay.rotate_token!
    assert_nil StreamOverlay.find_by_token(t1)
    assert_equal overlay, StreamOverlay.find_by_token(t2)
  end

  test "disabled overlays and junk tokens are not found" do
    overlay = StreamOverlay.for_bot(@bot)
    t = overlay.rotate_token!
    overlay.update!(enabled: false)
    assert_nil StreamOverlay.find_by_token(t)
    assert_nil StreamOverlay.find_by_token("")
    assert_nil StreamOverlay.find_by_token("short")
  end

  test "payload exposes only the net and the day count" do
    overlay = StreamOverlay.for_bot(@bot)
    assert_equal({ state: "not_started" }, overlay.payload[:wallet])
    assert_equal "none", overlay.payload[:accident][:state]

    s = start_session(@bot, 1_000_000)
    s.update_balance!(balance: 945_000, user: nil, idempotency_key: "x", lock_version: s.lock_version)
    accident_on(@bot, Date.new(2026, 7, 8))
    p = overlay.payload(as_of: utc(2026, 7, 10, 19))
    assert_equal({ state: "active", net_auec: -55_000 }, p[:wallet])
    assert_equal({ state: "recorded", days: 2, caption: StreamOverlay::DEFAULT_CAPTION }, p[:accident])
    json = p.to_json
    refute_match "1000000", json
    refute_match "945000", json
    refute_match(/"id"|bot_id|token/, json)

    s.reload.end!(user: nil)
    assert_equal({ state: "ended" }, overlay.payload[:wallet], "an ended session no longer shows its net")
  end
end
