class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.boolean :vote
      t.integer :user_id
      t.integer :position_id
      t.integer :rule_id
      t.integer :position_nomination_id
      t.string :feedback
      t.integer :guildstone_id
      t.timestamps
    end
  end
end
