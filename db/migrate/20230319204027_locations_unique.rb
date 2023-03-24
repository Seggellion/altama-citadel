class LocationsUnique < ActiveRecord::Migration[7.0]
  def change
    change_column :locations, :name, :string, unique: true
  end
end
