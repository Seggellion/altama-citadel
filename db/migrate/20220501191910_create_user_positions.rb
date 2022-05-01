class CreateUserPositions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_positions do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.integer :department_id
      t.float :compensation
      t.integer :parent_position_id
      t.integer :guildstone_id
      t.date :term_end
      t.timestamps
    end
  end
end
