class StarBitizenRacesShips < ActiveRecord::Migration[7.0]
  def change
    add_column :star_bitizen_race_users, :ship, :string
    add_column :star_bitizen_race_users, :win, :boolean
    add_column :star_bitizen_race_users, :best_lap, :float
    add_column :star_bitizen_race_users, :total_time, :float
    add_column :userships, :boost, :integer
    add_column :ships, :component_size, :integer
    add_column :star_bitizen_race_users, :usership_id, :integer


    create_table :ship_components do |t|
      t.string :component_name
      t.string :component_type
      t.string :component_manufacturer

      t.integer :modifier, default: 1
      t.integer :size, default: 0
      
      t.timestamps
    end

    create_table :usership_components do |t|
      t.integer :powered, default: 1
      t.integer :damaged, default: 0

      t.references :usership, null: false, foreign_key: true
      t.references :ship_components, null: false, foreign_key: true
      t.timestamps
    end




  end
end
