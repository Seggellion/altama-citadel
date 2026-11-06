# Append-only history for a donation: ingestion, status changes, matching results, operator actions.
class DonationAuditEvent < ApplicationRecord
  belongs_to :external_donation
  belongs_to :actor, class_name: "User", foreign_key: :actor_user_id, optional: true
  validates :event_type, presence: true

  def readonly?
    persisted?
  end
end
