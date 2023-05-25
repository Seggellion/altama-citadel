class Bot < ApplicationRecord
    has_many :giveaways

    validates :channel, presence: true
    validates :bot_name, presence: true
  end
  