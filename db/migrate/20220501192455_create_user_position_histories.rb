class CreateUserPositionHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :user_position_histories do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.integer :department_id
      t.date :term_end
      t.float :compensation
      t.integer :guildstone_id
      t.timestamps
    end
  end
end
