# app/models/star_bitizen_race_user.rb

class StarBitizenRaceUser < ApplicationRecord
    # Associations
    belongs_to :user
    belongs_to :star_bitizen_race
  end
  