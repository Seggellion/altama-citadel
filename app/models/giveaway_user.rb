class GiveawayUser < ApplicationRecord
    belongs_to :giveaway
    belongs_to :user

    validates :user_id, uniqueness: { scope: :giveaway_id, message: "has already been entered into this giveaway" }

end
  