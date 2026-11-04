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
  has_many :giveaway_users

  validates :title, presence: true
  validates :description, presence: true
  validates :mode, inclusion: { in: MODES, message: "is not a supported giveaway mode" }, if: -> { new_record? || will_save_change_to_mode? }
  validates :command_name, format: { with: COMMAND_FORMAT, message: "must be 1-25 letters, digits, _ or - (no spaces or !)" }, allow_blank: true
  validate :command_name_not_reserved
  validate :command_name_unique_among_open_giveaways

  before_validation :normalize_command_name

  scope :undrawn, -> { where(winner: nil) }

  def open?
    winner.nil?
  end

  private

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
