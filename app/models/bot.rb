class Bot < ApplicationRecord
    has_many :giveaways
    has_many :extra_life_events
    has_many :stream_wallet_sessions
    has_many :fuelling_accidents
    has_one :stream_overlay

    validates :channel, presence: true
    validates :bot_name, presence: true
  end
  