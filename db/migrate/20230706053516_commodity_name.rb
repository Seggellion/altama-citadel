class CommodityName < ActiveRecord::Migration[7.0]
  def change
    remove_column :milk_runs, :commodity_id
    add_column :milk_runs, :commodity_name, :string
  end
end
