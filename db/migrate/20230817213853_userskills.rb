class Userskills < ActiveRecord::Migration[7.0]
  def change
    create_table :user_skills do |t|
      t.string :skill_name
      t.integer :value, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :star_bitizen_races do |t|
      t.string :race_name
      t.string :channel_name
      t.integer :prize_pool, default: 0
      t.integer :laps, default: 1
      t.date :race_date
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end

    create_table :star_bitizen_race_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :star_bitizen_race, null: false, foreign_key: true
      
      t.timestamps
    end


  end
end
