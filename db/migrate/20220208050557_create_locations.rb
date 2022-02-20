class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.integer :location_type
      t.integer :parent
      t.boolean :trade_port
      t.string :image
      t.string :classification
      t.integer :system
      t.boolean :habitable
      t.string :affiliation

      t.timestamps
    end
  end
end
