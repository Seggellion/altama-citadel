# Fuelling accidents, append-only. The counter is "days since the most recent fuelling accident": the difference in
# calendar days in the accident's time zone (America/Vancouver), so an accident today is 0 and yesterday is 1.
#
# PostgreSQL computes the day count for both this app and the altama_sys bot (`!accident`), from the same SQL, so the
# two can never disagree because their hosts ship different tzdata. Keep CURRENT_SQL identical to
# altama_sys/stream/accident.py (contract: docs/stream-overlay/contract.md).
class FuellingAccident < ApplicationRecord
  DEFAULT_TIME_ZONE = "America/Vancouver".freeze

  # $1 = as_of (timestamptz text, or NULL for now()), $2 = channel.
  CURRENT_SQL = <<~SQL.squish.freeze
    SELECT a.id, ((COALESCE(CAST($1 AS timestamptz), now()) AT TIME ZONE a.time_zone)::date - a.occurred_on) AS days
    FROM fuelling_accidents a JOIN bots b ON b.id = a.bot_id
    WHERE LOWER(b.channel) = LOWER($2) AND a.voided_at IS NULL
    ORDER BY a.occurred_at DESC, a.id DESC LIMIT 1
  SQL

  class Error < StandardError; end

  belongs_to :bot
  belongs_to :recorded_by, class_name: "User", optional: true
  belongs_to :voided_by, class_name: "User", optional: true

  scope :live, -> { where(voided_at: nil) }

  validates :occurred_at, :occurred_on, presence: true
  validates :source, inclusion: { in: %w[now historic] }
  validates :time_zone, inclusion: { in: ->(_) { TZInfo::Timezone.all_identifiers }, message: "is not a known IANA time zone" }
  validate :not_in_the_future, on: :create

  Current = Struct.new(:accident, :days, keyword_init: true)

  # The channel's current accident and its day count, or nil when none is recorded.
  def self.current_for(channel, as_of: nil)
    row = connection.select_one(sanitize_sql_array([CURRENT_SQL.gsub("$1", "?").gsub("$2", "?"), as_of&.utc&.iso8601(6), channel.to_s]))
    row && Current.new(accident: find(row["id"]), days: row["days"].to_i)
  end

  # Today's calendar date in time_zone, according to PostgreSQL (same clock and tzdata as CURRENT_SQL).
  def self.local_today(time_zone = DEFAULT_TIME_ZONE, as_of: nil)
    Date.parse(connection.select_value(sanitize_sql_array(["SELECT (COALESCE(CAST(? AS timestamptz), now()) AT TIME ZONE ?)::date", as_of&.utc&.iso8601(6), time_zone])).to_s)
  end

  def self.record_now!(bot:, user:, time_zone: DEFAULT_TIME_ZONE)
    create!(bot: bot, occurred_at: Time.current, occurred_on: local_today(time_zone), time_zone: time_zone, source: "now", recorded_by: user)
  end

  # An accident on an earlier calendar date (for example the real last accident before this tool existed).
  def self.record_historic!(bot:, user:, date:, time_zone: DEFAULT_TIME_ZONE)
    day = date.is_a?(Date) ? date : Date.iso8601(date.to_s)
    zone = ActiveSupport::TimeZone[time_zone]
    create!(bot: bot, occurred_at: zone.local(day.year, day.month, day.day, 12), occurred_on: day, time_zone: time_zone,
            source: "historic", recorded_by: user)
  rescue Date::Error
    raise Error, "Enter the accident date as YYYY-MM-DD."
  end

  def void!(user:)
    update!(voided_at: Time.current, voided_by: user) unless voided_at
  end

  private

  def not_in_the_future
    return if occurred_on.blank? || time_zone.blank?

    errors.add(:occurred_on, "can't be in the future") if occurred_on > self.class.local_today(time_zone)
  end
end
