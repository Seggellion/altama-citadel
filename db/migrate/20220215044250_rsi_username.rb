class RsiUsername < ActiveRecord::Migration[7.0]
  def change

    add_column :users, :rsi_username, :string
    
    add_index :users, :rsi_username, unique: true
    add_column :ships, :image_topdown, :string
  end
end
