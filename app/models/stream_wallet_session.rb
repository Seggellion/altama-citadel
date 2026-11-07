# One stream's wallet tracking: the admin enters the in-game aUEC balance at Start (immutable baseline) and then the
# latest balance as it changes. Net = current - starting, computed, never stored. This is net wallet change: purchases
# and transfers count too.
class StreamWalletSession < ApplicationRecord
  MAX_AUEC = 999_999_999_999

  class Error < StandardError; end
  class InvalidBalance < Error; end
  class AlreadyActive < Error; end
  class StaleWindow < Error; end
  class NotActive < Error; end

  belongs_to :bot
  belongs_to :started_by, class_name: "User", optional: true
  belongs_to :ended_by, class_name: "User", optional: true
  has_many :entries, -> { order(:id) }, class_name: "StreamWalletEntry", dependent: :restrict_with_exception

  scope :active, -> { where(status: "active") }
  scope :ended, -> { where(status: "ended") }

  validates :status, inclusion: { in: %w[active ended] }
  validates :starting_balance_auec, :current_balance_auec,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_AUEC }
  validate :starting_balance_unchanged, on: :update

  # "1,175,000", "1 175 000" and "1175000" are all 1_175_000. Anything else (blank, decimals, negatives, letters,
  # over the limit) is rejected with a message fit for the admin window.
  def self.parse_balance(raw)
    s = raw.to_s.strip.delete(", _")
    raise InvalidBalance, "Enter the wallet balance in aUEC." if s.empty?
    raise InvalidBalance, "The wallet balance must be a whole number of aUEC (no decimals or minus sign)." unless s.match?(/\A\d+\z/)
    raise InvalidBalance, "The wallet balance can't be more than #{ActiveSupport::NumberHelper.number_to_delimited(MAX_AUEC)} aUEC." if s.length > 13 || s.to_i > MAX_AUEC

    s.to_i
  end

  def self.start!(bot:, balance:, user:, idempotency_key:)
    transaction do
      session = create!(bot: bot, status: "active", starting_balance_auec: balance, current_balance_auec: balance,
                        started_at: Time.current, balance_updated_at: Time.current, started_by: user)
      session.entries.create!(kind: "start", balance_auec: balance, entered_by: user, idempotency_key: idempotency_key.presence || SecureRandom.uuid)
      session
    end
  rescue ActiveRecord::RecordNotUnique
    raise AlreadyActive, "A wallet session is already running. End it before starting a new one."
  end

  # Returns :updated, or :duplicate when this exact form submission was already applied (double-click / resubmit).
  # A submission from an out-of-date window (another update landed since it was rendered) raises StaleWindow.
  def update_balance!(balance:, user:, idempotency_key:, lock_version:)
    key = idempotency_key.presence || SecureRandom.uuid
    self.class.transaction do
      lock!
      return :duplicate if entries.exists?(idempotency_key: key)
      raise NotActive, "This wallet session has ended." unless active?

      self.lock_version = lock_version.to_i if lock_version.present?
      update!(current_balance_auec: balance, balance_updated_at: Time.current)
      entries.create!(kind: "update", balance_auec: balance, entered_by: user, idempotency_key: key)
      :updated
    end
  rescue ActiveRecord::StaleObjectError
    raise StaleWindow, "The balance changed in another window. Check the numbers below and submit again."
  end

  def end!(user:, lock_version: nil)
    self.class.transaction do
      lock!
      return :already_ended unless active?

      self.lock_version = lock_version.to_i if lock_version.present?
      update!(status: "ended", ended_at: Time.current, ended_by: user)
      :ended
    end
  rescue ActiveRecord::StaleObjectError
    raise StaleWindow, "The session changed in another window. Check the numbers below and try again."
  end

  def active? = status == "active"

  def net_auec = current_balance_auec - starting_balance_auec

  private

  def starting_balance_unchanged
    errors.add(:starting_balance_auec, "can't change after Start") if starting_balance_auec_changed?
  end
end
