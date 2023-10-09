class ShipComponentShipModel < ActiveRecord::Migration[7.0]
  def change
    add_column :ship_components, :ship_model, :string
  end
end
