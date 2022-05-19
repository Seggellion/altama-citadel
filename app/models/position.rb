class Position < ApplicationRecord
  belongs_to :department
  has_many :position_nominations
  
  def user
    unless self.position_nominations.empty?
      self.position_nominations.first.user
    end
  end

  def user_position
    UserPosition.find_by(position_id: self.id)
  end

  def nomination(user)
    if user
   PositionNomination.where(nominee_id: user.id, position_id: self.id)
    end
  end

  def application(user)
    PositionApplication.where(nominee_id: user.id, position_id: self.id)
  end

  def position_username

    unless self.user.nil?
      self.user.username
    else
      puts "Apply today!"
    end
  end

end