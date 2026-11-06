class GiveawayAward < ApplicationRecord
  belongs_to :giveaway
  belongs_to :extra_life_event
  belongs_to :draw_attempt, class_name: "GiveawayDrawAttempt"
  belongs_to :twitch_account, foreign_key: :twitch_user_id, primary_key: :twitch_user_id

  def readonly?
    persisted?
  end
end
