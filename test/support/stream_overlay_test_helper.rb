require_relative "giveaway_test_helper"

module StreamOverlayTestData
  def utc(*args) = Time.utc(*args)

  def start_session(bot, balance, user: nil, key: SecureRandom.uuid)
    StreamWalletSession.start!(bot: bot, balance: balance, user: user, idempotency_key: key)
  end

  def accident_on(bot, date, time_zone: "America/Vancouver")
    zone = ActiveSupport::TimeZone[time_zone]
    FuellingAccident.create!(bot: bot, occurred_on: date, occurred_at: zone.local(date.year, date.month, date.day, 12),
                             time_zone: time_zone, source: "historic")
  end
end
