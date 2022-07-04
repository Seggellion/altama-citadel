class CreateNonConfidences < ActiveRecord::Migration[7.0]
  def change
    create_table :non_confidences do |t|
      t.integer :guildstone_id
      t.integer :user_position_id
      t.integer :rule_id
      t.integer :originator_id
      t.timestamps
    end
  end
end
