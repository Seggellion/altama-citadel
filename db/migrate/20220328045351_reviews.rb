class Reviews < ActiveRecord::Migration[7.0]
  def change

    create_table :reviews do |t|
      t.integer :user_id
      t.integer :rfa_id
      t.integer :reviewee_id
      t.integer :rating
      t.string :description
      t.timestamps
      t.index ['user_id', 'rfa_id'], name: 'one_review_per_rfa', unique: true
    end

    
    create_table :badges do |t|
      t.string :badge_name
      t.string :badge_description
      t.string :badge_image
      t.string :badge_color
      t.timestamps
    end

    create_table :user_badges do |t|
      t.integer :user_id
      t.integer :badge_id
      t.index ['user_id', 'badge_id'], name: 'one_badge_per_user', unique: true
      t.timestamps
    end

    add_column :users, :aec, :integer, :null => false, :default => 0
    add_column :users, :fame, :integer, :null => false, :default => 0
    add_column :users, :karma, :integer, :null => false, :default => 0
    add_column :users, :last_login, :datetime
    add_column :users, :desktop_background, :string
    add_column :users, :org_title, :string
    add_column :users, :crew_title, :string
    add_column :ships, :hyd_fuel_capacity, :float
    add_column :ships, :qnt_fuel_capacity, :float
    add_column :ships, :liquid_storage_capacity, :float

  end
end
