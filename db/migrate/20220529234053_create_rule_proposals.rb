class CreateRuleProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :rule_proposals do |t|
      t.string :title
      t.integer :guildstone_id
      t.integer :position_id
      t.integer :proposer_id
      t.string :description
      t.integer :term_length_days
      t.integer :department_id
      t.boolean :code_enforced
      t.string :category

      t.timestamps
    end
  end
end
