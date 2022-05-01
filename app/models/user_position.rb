class UserPosition < ApplicationRecord
  belongs_to :user
  has_one :user_position_history
  has_one :position
end