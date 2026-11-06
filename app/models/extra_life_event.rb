# One Extra Life fundraising stream. Owns its winner scope: an account can win one prize per event.
class ExtraLifeEvent < ApplicationRecord
  belongs_to :bot
  has_many :giveaways, dependent: :restrict_with_error
  has_many :operators, class_name: "ExtraLifeEventOperator", dependent: :destroy
  has_many :sync_runs, class_name: "DonationSyncRun", dependent: :restrict_with_error
  has_many :draw_attempts, class_name: "GiveawayDrawAttempt", dependent: :restrict_with_error
  has_many :awards, class_name: "GiveawayAward", dependent: :restrict_with_error

  TILTIFY_CAMPAIGN_ID = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

  validates :name, :broadcaster_login, :stream_start_at, presence: true
  validates :broadcaster_twitch_id, presence: true, format: { with: /\A\d+\z/, message: "must be the numeric Twitch user id" }
  validates :time_zone, inclusion: { in: ->(_) { TZInfo::Timezone.all_identifiers }, message: "is not a known IANA time zone" }
  validates :tiltify_campaign_id, format: { with: TILTIFY_CAMPAIGN_ID, message: "must be the campaign UUID" }, allow_blank: true
  validates :tiltify_campaign_url, format: { with: %r{\Ahttps://(www\.)?tiltify\.com/}, message: "must be a https://tiltify.com/ URL" }, allow_blank: true
  validate :frozen_fields_unchanged_after_finalized_draw
  validate :enable_requires_campaign

  # Identity and window fields define recorded eligibility; changing them after a finalized draw would rewrite history.
  FROZEN_AFTER_FINAL_DRAW = %w[broadcaster_twitch_id tiltify_campaign_id stream_start_at bot_id].freeze

  def finalized_draws?
    draw_attempts.where(status: "finalized").exists?
  end

  def operator?(user)
    return false unless user
    return true if user.isAdmin?

    operators.exists?(user_id: user.id)
  end

  def stream_start_local
    stream_start_at&.in_time_zone(time_zone)
  end

  # Re-materialise donor ticket sources for all undrawn giveaways (SQL function shared with the bot).
  def refresh_donor_sources!
    self.class.connection.select_value("SELECT extra_life_refresh_donor_sources(#{Integer(id)})")
  end

  private

  def frozen_fields_unchanged_after_finalized_draw
    return unless persisted? && finalized_draws?

    (changed & FROZEN_AFTER_FINAL_DRAW).each do |attr|
      errors.add(attr, "cannot change after a prize in this event has been drawn")
    end
  end

  def enable_requires_campaign
    errors.add(:enabled, "requires a resolved Tiltify campaign id") if enabled && tiltify_campaign_id.blank?
  end
end
