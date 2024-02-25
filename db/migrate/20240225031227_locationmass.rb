class Locationmass < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :mass, :float
    add_column :locations, :periapsis, :float
    add_column :locations, :apoapsis, :float
    add_column :locations, :slots, :integer

  end
end
