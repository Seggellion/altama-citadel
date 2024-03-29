class PositionNomination < ApplicationRecord
  belongs_to :user, foreign_key: 'nominator_id'
  belongs_to :position
  validates :nominator_id, uniqueness: { scope: :position_id, message: 'has already nominated this position' }
  def user_nominated?
   # PositionNomination.find_by(position_id: self.id)
    #PositionNomination.find_by(nominee_id: self.user.id, position_id: self.id)
    #@position_nomination = PositionNomination.where(nominee_id: current_user, position_id: self.id)
  
  end
  def nominee
    User.find_by_id(self.nominee_id)
  end

  def total_votes
    Vote.where(position_nomination_id: self.id).count
  end


end