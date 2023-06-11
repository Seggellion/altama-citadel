class PositionNomination < ApplicationRecord
  belongs_to :user, foreign_key: 'nominator_id'
  belongs_to :position

  def user_nominated?
   # PositionNomination.find_by(position_id: self.id)
    #PositionNomination.find_by(nominee_id: self.user.id, position_id: self.id)
    #@position_nomination = PositionNomination.where(nominee_id: current_user, position_id: self.id)
  
  end
  def nominee
    User.find_by_id(self.nominee_id)
  end



end