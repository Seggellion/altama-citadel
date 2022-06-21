class NonConfidence < ApplicationRecord

  def getNonConfidencedUser
    @nonConfidencedUser = UserPosition.where(id: self.user_position_id).user_id
  end
end
