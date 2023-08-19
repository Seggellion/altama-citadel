# app/models/star_bitizen_race.rb

class StarBitizenRace < ApplicationRecord
    # Associations
    belongs_to :user
    has_many :star_bitizen_race_users
    has_many :participants, through: :star_bitizen_race_users, source: :user
    
    # Validations
    validates :race_name, presence: true
    validates :race_date, presence: true
  end
  