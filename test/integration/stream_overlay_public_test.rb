require "test_helper"
require_relative "../support/stream_overlay_test_helper"

# Public OBS overlay: token-gated, read-only, and it must never reveal balances or internals.
class StreamOverlayPublicTest < GiveawayIntegrationTestCase
  include StreamOverlayTestData

  setup do
    @bot = make_bot
    @overlay = StreamOverlay.for_bot(@bot)
    @token = @overlay.rotate_token!
    s = start_session(@bot, 1_000_000)
    s.update_balance!(balance: 1_175_000, user: nil, idempotency_key: "k", lock_version: s.lock_version)
    accident_on(@bot, FuellingAccident.local_today - 4)
  end

  test "the JSON carries only the net and the day count, with no-store and noindex headers" do
    get stream_overlay_path(token: @token, format: :json)
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["v"]
    assert_equal({ "state" => "active", "net_auec" => 175_000 }, body["wallet"])
    assert_equal({ "state" => "recorded", "days" => 4, "caption" => StreamOverlay::DEFAULT_CAPTION }, body["accident"])
    assert_equal %w[accident generated_at v wallet], body.keys.sort
    refute_match(/1000000|1175000|1,000,000|1,175,000/, response.body)
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
    assert_nil response.headers["Set-Cookie"], "no session cookie for OBS"
  end

  test "the page renders without a login, layout, analytics or balances" do
    get stream_overlay_path(token: @token)
    assert_response :success
    html = response.body
    assert_match "NET aUEC SINCE START", html
    assert_match "background: transparent", html
    refute_match(/googletagmanager|gtag|csrf-token|1000000|1175000|1,175,000/, html)
    refute_match(/desktop|bots\/#{@bot.id}/, html)
    assert_nil response.headers["Set-Cookie"]
  end

  test "unknown, malformed, rotated and disabled tokens get a bare 404" do
    old = @token
    new_token = @overlay.rotate_token!
    [old, "nope", "a" * 43, "#{new_token}x"].each do |t|
      get stream_overlay_path(token: t, format: :json)
      assert_response :not_found
      assert_empty response.body
    end
    get stream_overlay_path(token: new_token, format: :json)
    assert_response :success

    @overlay.update!(enabled: false)
    get stream_overlay_path(token: new_token, format: :json)
    assert_response :not_found
  end

  test "the overlay route cannot change anything" do
    assert_raises(ActionController::RoutingError) { post "/overlay/#{@token}" }
  rescue Minitest::Assertion
    assert_response :not_found
  ensure
    assert_equal 175_000, @bot.stream_wallet_sessions.active.first.net_auec
  end

  test "empty states are honest" do
    @bot.stream_wallet_sessions.active.first.end!(user: nil)
    @bot.fuelling_accidents.each { |a| a.void!(user: nil) }
    get stream_overlay_path(token: @token, format: :json)
    body = JSON.parse(response.body)
    assert_equal({ "state" => "ended" }, body["wallet"])
    assert_equal "none", body["accident"]["state"]
    refute body["accident"].key?("days")
  end

  test "a server error returns a fixed, harmless JSON body" do
    StreamOverlay.class_eval { alias_method :__payload, :payload; define_method(:payload) { |**| raise "secret detail" } }
    get stream_overlay_path(token: @token, format: :json)
    assert_response :service_unavailable
    assert_equal({ "v" => 1, "error" => "unavailable" }, JSON.parse(response.body))
    refute_match "secret", response.body
  ensure
    StreamOverlay.class_eval { alias_method :payload, :__payload; remove_method :__payload }
  end
end
