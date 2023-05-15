class LocationAmmentities < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :ammenities_fuel, :boolean
    add_column :locations, :ammenities_repair, :boolean
    add_column :locations, :ammenities_rearm, :boolean
    add_column :locations, :trade_terminal, :boolean

    add_column :trade_sessions, :owner_id, :integer
    add_column :commodities, :vices, :boolean
    add_column :trade_runs, :profit, :boolean

  end
end
