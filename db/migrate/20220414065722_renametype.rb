class Renametype < ActiveRecord::Migration[7.0]
  def change
    rename_column :ships, :type, :vehicle_type
  end
end
