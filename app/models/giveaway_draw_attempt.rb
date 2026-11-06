# A reserved cutoff and, once finalized, the immutable pool snapshot and result for one event-mode draw.
class GiveawayDrawAttempt < ApplicationRecord
  belongs_to :giveaway
  belongs_to :extra_life_event
  belongs_to :winner_account, class_name: "TwitchAccount", foreign_key: :winner_twitch_user_id, primary_key: :twitch_user_id, optional: true
  has_one :award, class_name: "GiveawayAward", foreign_key: :draw_attempt_id

  before_update :prevent_finalized_changes

  private

  def prevent_finalized_changes
    return unless status_in_database == "finalized"

    allowed = %w[announcement_state announcement_attempts announced_at updated_at]
    return if (changed - allowed).empty?

    errors.add(:base, "A finalized draw cannot be changed")
    throw :abort
  end
end
