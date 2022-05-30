class RuleProposal < ApplicationRecord
  belongs_to :user, foreign_key: 'proposer_id'
  has_one :rule


  def already_voted?(user)
    Vote.find_by(rule_proposal_id: self.id, user_id: user.id)
    #binding.break
  end
end
