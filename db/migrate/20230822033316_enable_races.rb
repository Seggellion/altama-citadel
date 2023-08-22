class EnableRaces < ActiveRecord::Migration[7.0]
  def change
    add_column :star_bitizen_race_users, :channel, :string
    add_column :star_bitizen_races, :enabled, :boolean, default: false
  end
end
