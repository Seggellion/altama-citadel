class Shipsaltnamecolumn < ActiveRecord::Migration[7.0]
  def change
    add_column :ships, :alt_ship_name, :string
    add_column :userships, :source, :string, default: 'manual'
  end
end
