class Rule < ApplicationRecord
belongs_to :user
has_one :rule_proposal

def already_voted?(user)
  Vote.find_by(id: self.id, user_id: user.id)
end


end