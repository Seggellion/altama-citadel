# One independent ticket source (chat or donor) for one account in one event-mode giveaway.
# Donor rows are written only by the SQL function extra_life_refresh_donor_sources.
class GiveawayTicketSource < ApplicationRecord
  SOURCES = %w[chat donor].freeze
  belongs_to :giveaway
  belongs_to :twitch_account, foreign_key: :twitch_user_id, primary_key: :twitch_user_id
  validates :source, inclusion: { in: SOURCES }
  scope :active, -> { where(active: true) }
end
