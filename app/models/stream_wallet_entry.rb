# Append-only audit row for each balance the admin entered.
class StreamWalletEntry < ApplicationRecord
  belongs_to :session, class_name: "StreamWalletSession", foreign_key: :stream_wallet_session_id
  belongs_to :entered_by, class_name: "User", optional: true

  validates :kind, inclusion: { in: %w[start update] }
  validates :balance_auec, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: StreamWalletSession::MAX_AUEC }
  validates :idempotency_key, presence: true

  def readonly? = persisted?
end
