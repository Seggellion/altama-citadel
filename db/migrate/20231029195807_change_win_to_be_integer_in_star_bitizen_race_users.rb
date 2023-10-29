class ChangeWinToBeIntegerInStarBitizenRaceUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :star_bitizen_race_users, :win, 'integer USING CASE WHEN win THEN 1 ELSE 0 END'
  end

  def down
    change_column :star_bitizen_race_users, :win, 'boolean USING CASE WHEN win=1 THEN true ELSE false END'
  end
end
