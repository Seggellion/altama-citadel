class Position < ApplicationRecord
  belongs_to :department
  has_many :user_positions
  has_many :position_nominations
end