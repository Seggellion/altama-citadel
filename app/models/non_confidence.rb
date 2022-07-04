class NonConfidence < ApplicationRecord

  def getNonConfidencedUser
    @nonConfidencedUser = UserPosition.where(id: self.user_position_id).user_id
  end

  def already_voted?(user)
    Vote.find_by(non_confidence_id: self.id, user_id: user.id)
  end
end
