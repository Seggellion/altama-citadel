class FuelCommodities < ActiveRecord::Migration[7.0]
  def change
    add_column :commodities, :fuel_product, :boolean, default: false
  end
end
