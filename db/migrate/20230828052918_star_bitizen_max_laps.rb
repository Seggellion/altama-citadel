class StarBitizenMaxLaps < ActiveRecord::Migration[7.0]
  def change
    add_column :star_bitizen_races, :max_laps, :integer
    add_column :star_bitizen_races, :fee, :integer
    add_column :star_bitizen_races, :winners, :string
    add_column :star_bitizen_races, :owner_name, :string
  end
end
