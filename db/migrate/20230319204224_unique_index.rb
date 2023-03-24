class UniqueIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :locations, :name, unique: true
    add_index :articles, :title, unique: true
    remove_column :commodities, :location_id
    add_column :commodities, :location, :string
  end
end
