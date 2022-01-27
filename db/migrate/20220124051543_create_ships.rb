class CreateShips < ActiveRecord::Migration[7.0]
  def change
    create_table :ships do |t|
      t.string :model
      t.integer :make_id
      t.integer :scu
      t.integer :crew
      t.integer :fuel
      t.integer :quantum
      t.integer :length
      t.integer :beam
      t.integer :height
      t.integer :weight
      t.integer :msrp

      t.timestamps
    end
  end
end
