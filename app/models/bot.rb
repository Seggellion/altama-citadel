class Bot < ApplicationRecord
    has_many :giveaways
    has_many :extra_life_events

    validates :channel, presence: true
    validates :bot_name, presence: true
  end
  