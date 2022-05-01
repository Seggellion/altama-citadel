class CreateRules < ActiveRecord::Migration[7.0]
  def change
    create_table :rules do |t|
      t.integer :guildstone_id
      t.integer :position_id
      t.integer :user_id
      t.string :description
      t.integer :term_length_days
      t.timestamps
    end
  end
end
