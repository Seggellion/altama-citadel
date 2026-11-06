# One provider donation (unique per provider + external id). Only the fields needed for matching and review.
class ExternalDonation < ApplicationRecord
  FINAL_UNMATCHED = %w[NO_NAME ANONYMOUS_PLACEHOLDER NO_LOGIN_CANDIDATE UNKNOWN_TWITCH_USER AMBIGUOUS].freeze
  BLOCKING = %w[UNPROCESSED PENDING_VERIFICATION].freeze
  STATUSES = %w[completed pending missing refunded].freeze

  belongs_to :auto_account, class_name: "TwitchAccount", foreign_key: :auto_twitch_user_id, primary_key: :twitch_user_id, optional: true
  belongs_to :manual_account, class_name: "TwitchAccount", foreign_key: :manual_twitch_user_id, primary_key: :twitch_user_id, optional: true
  belongs_to :resolved_account, class_name: "TwitchAccount", foreign_key: :resolved_twitch_user_id, primary_key: :twitch_user_id, optional: true
  belongs_to :manual_assigned_by, class_name: "User", foreign_key: :manual_assigned_by_user_id, optional: true
  belongs_to :status_confirmed_by, class_name: "User", foreign_key: :status_confirmed_by_user_id, optional: true
  has_many :audit_events, class_name: "DonationAuditEvent", dependent: :restrict_with_error

  validates :provider_status, inclusion: { in: STATUSES }

  scope :for_event, ->(event) { where(provider: "tiltify", campaign_id: event.tiltify_campaign_id) }

  def manual?
    manual_twitch_user_id.present?
  end

  def review_needed?
    !manual? && (FINAL_UNMATCHED.include?(match_outcome) || BLOCKING.include?(match_outcome)) || provider_status == "missing"
  end
end
