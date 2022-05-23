class UserPositionHistory < ApplicationRecord
  has_many :user_positions

  
  def self.my_positions
    UserPositionHistory.where(user_id: current_user.id)
  end

  def all_users
  end

  def all_user_positions

  end

end