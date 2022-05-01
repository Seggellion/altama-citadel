class PositionNomination < ApplicationRecord
  belongs_to :user
  has_one :position
end