class AddOutOfDateColumnToCommodityTable < ActiveRecord::Migration[7.0]
  def change
    add_column :commodities, :out_of_date, :boolean, default: false
  end
end
