class Locationcolor < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :ocean_color, :string
    add_column :locations, :surface_color, :string
  end
end
