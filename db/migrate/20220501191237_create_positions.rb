class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.string :title
      t.string :description
      t.integer :department_id
      t.integer :guildstone_id
      t.integer :term_length_days
      t.float :compensation
      t.integer :parent_position_id
      t.timestamps
    end
  end
end
