class Giveaway < ApplicationRecord
  LEGACY_MODES = %w[single multiple multiple-extra-life extra-life].freeze
  EVENT_MODE = "extra-life-tiltify".freeze
  MODES = (LEGACY_MODES + [EVENT_MODE]).freeze

  # Commands the Twitch bot (altama_sys) already registers. A giveaway using one of these could never be entered,
  # and before the bot fix a collision crashed bot startup.
  RESERVED_COMMANDS = %w[
    aec commands discord donate drawing extralife followage giveaway giveaway-clear join odds ping race referral
    shoutout shutdown status trade transfer ultimacraft version
  ].freeze
  COMMAND_FORMAT = /\A[a-z0-9_-]{1,25}\z/

  belongs_to :bot
  belongs_to :extra_life_event, optional: true
  has_many :giveaway_users, dependent: :delete_all
  has_many :ticket_sources, class_name: "GiveawayTicketSource", dependent: :delete_all
  has_many :draw_attempts, class_name: "GiveawayDrawAttempt", dependent: :restrict_with_error
  has_one :award, class_name: "GiveawayAward", dependent: :restrict_with_error

  validates :title, presence: true
  validates :description, presence: true
  validates :mode, inclusion: { in: MODES, message: "is not a supported giveaway mode" }, if: -> { new_record? || will_save_change_to_mode? }
  validates :command_name, format: { with: COMMAND_FORMAT, message: "must be 1-25 letters, digits, _ or - (no spaces or !)" }, allow_blank: true
  validate :command_name_not_reserved
  validate :command_name_unique_among_open_giveaways

  validate :event_mode_rules

  before_validation :normalize_command_name
  before_validation :default_event_entry_state, on: :create
  before_destroy :guard_event_history, prepend: true
  after_create_commit :populate_event_donors

  scope :undrawn, -> { where(winner: nil) }

  def open?
    winner.nil?
  end

  def event_mode?
    mode == EVENT_MODE
  end

  # Same SQL function the bot uses for !odds and the draw.
  def event_pool
    return [] unless event_mode?

    self.class.connection.select_all(
      self.class.sanitize_sql(["SELECT * FROM extra_life_pool(?)", id])
    ).to_a
  end

  def live_draw_attempt
    draw_attempts.where(status: %w[pending finalized]).order(:id).last
  end

  private

  def default_event_entry_state
    self.entry_state ||= "open" if event_mode?
  end

  def event_mode_rules
    if event_mode?
      errors.add(:extra_life_event, "is required for Extra Life (Tiltify) giveaways") if extra_life_event.nil?
      errors.add(:extra_life_event, "belongs to a different bot") if extra_life_event && bot_id && extra_life_event.bot_id != bot_id
      errors.add(:command_name, "is required for Extra Life (Tiltify) giveaways") if command_name.blank?
      errors.add(:cost, "must be 0: Extra Life chat entry is free") if cost.to_i != 0
    elsif extra_life_event_id.present?
      errors.add(:extra_life_event, "can only be set on Extra Life (Tiltify) giveaways")
    end
    if persisted? && will_save_change_to_mode? && [mode_in_database, mode].include?(EVENT_MODE)
      errors.add(:mode, "cannot be converted to or from Extra Life (Tiltify); create a new giveaway instead")
    end
    if persisted? && will_save_change_to_extra_life_event_id? && draw_attempts.exists?
      errors.add(:extra_life_event, "cannot change after a draw was started")
    end
  end

  def guard_event_history
    return unless draw_attempts.exists? || award.present?

    errors.add(:base, "This giveaway has draw records; it cannot be deleted. Close it instead.")
    throw :abort
  end

  def populate_event_donors
    extra_life_event&.refresh_donor_sources! if event_mode?
  end

  def normalize_command_name
    return if command_name.nil?

    self.command_name = command_name.strip.delete_prefix("!").downcase.presence
  end

  def command_name_not_reserved
    return if command_name.blank?

    errors.add(:command_name, "!#{command_name} is already a bot command") if RESERVED_COMMANDS.include?(command_name)
  end

  def command_name_unique_among_open_giveaways
    return if command_name.blank? || winner.present?

    clash = Giveaway.undrawn.where("LOWER(TRIM(command_name)) = ?", command_name)
    clash = clash.where(bot_id: bot_id) if bot_id
    clash = clash.where.not(id: id) if persisted?
    errors.add(:command_name, "!#{command_name} is already used by an open giveaway") if clash.exists?
  end
end
