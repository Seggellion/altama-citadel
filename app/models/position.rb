class Position < ApplicationRecord
  belongs_to :department
  has_many :position_nominations
  
  def user
    if self.user_position
      self.user_position.user
    end
  end

  def user_position
    UserPosition.find_by(position_id: self.id)
  end

  def already_voted?(user)
    Vote.find_by(position_id: self.id, user_id: user.id)
  end

def status
  if user
   nomination = PositionNomination.where(nominee_id: self.user.id, position_id: self.id).first
   message = ""
   if nomination && nomination.nominee_id == nomination.nominator_id
    message =  "Application"
   elsif nomination
   message =  "Nomination"
   end
   message
  end
end

  def nomination(user)
   PositionNomination.where(nominee_id: user, position_id: self.id).first
  end

  def applications
    PositionNomination.where(position_id: self.id)
  end

  def position_username

    unless self.user.nil?
      self.user.username
    else
      puts "Apply today!"
    end
  end

end