class Position < ApplicationRecord
  belongs_to :department
  
  has_many :position_nominations
  has_one :user, :through => :user_position


  def position_username
    user_position = UserPosition.find_by(position_id: self.id)
    unless user_position.nil?
      user_position.user.username
    else
      puts "Apply today!"
    end
  end

end