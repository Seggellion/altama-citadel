class UserPosition < ApplicationRecord
  belongs_to :user
  belongs_to :position
  has_one :user_position_history
  #has_one :position
end