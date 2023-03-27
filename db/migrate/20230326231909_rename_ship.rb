class RenameShip < ActiveRecord::Migration[7.0]
  def change
    rename_column :userships, :ship, :model
    add_index :ships, :model, unique: true
  end
end
