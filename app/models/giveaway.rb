class Giveaway < ApplicationRecord
    belongs_to :bot
    has_many :giveaway_users
  
    validates :title, presence: true
    validates :description, presence: true


  end
  