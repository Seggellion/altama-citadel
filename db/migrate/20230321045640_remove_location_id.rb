class RemoveLocationId < ActiveRecord::Migration[7.0]
  def change
    remove_column :articles, :location_id
    add_column :articles, :location, :string

    remove_column :rfas, :location_id
    add_column :rfas, :location, :string

    remove_column :rfas, :ship_id
    add_column :rfas, :ship, :string

    remove_column :userships, :ship_id
    add_column :userships, :ship, :string

    remove_column :event_ships, :ship_id
    add_column :event_ships, :ship, :string
  end
end
