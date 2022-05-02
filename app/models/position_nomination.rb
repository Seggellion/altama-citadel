class PositionNomination < ApplicationRecord
  belongs_to :user, foreign_key: 'nominator_id'
  has_one :position
end