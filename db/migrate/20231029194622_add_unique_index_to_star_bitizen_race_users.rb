class AddUniqueIndexToStarBitizenRaceUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :star_bitizen_race_users, [:user_id, :star_bitizen_race_id], unique: true, name: 'index_star_bitizen_race_users_on_user_id_and_race_id'
  end
end
