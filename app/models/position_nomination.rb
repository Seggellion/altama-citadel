class PositionNomination < ApplicationRecord
  belongs_to :user, foreign_key: 'nominator_id'
  has_one :position

  def user_nominated?
   # PositionNomination.find_by(position_id: self.id)
    #PositionNomination.find_by(nominee_id: self.user.id, position_id: self.id)
    #@position_nomination = PositionNomination.where(nominee_id: current_user, position_id: self.id)
  
  end



end