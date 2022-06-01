class ChangeRuleIdToRuleProposalIdFromVotes < ActiveRecord::Migration[7.0]
  def change
    rename_column :votes, :rule_id, :rule_proposal_id
  end
end
