class EventUser < ActiveRecord::Migration[7.0]
  def change

    create_table :event_users do |t|
      t.integer :user_id
      t.integer :event_series_id
      t.integer :event_id
      t.string :ship_fid
      t.integer :usership_id
      t.timestamps
    end

    create_table :event_ships do |t|
      t.integer :usership_id
      t.integer :event_user_id
      t.integer :event_id
      t.string :ship_fid
      t.string :ship_name
      t.integer :ship_id
      t.timestamps
    end

    create_table :event_series do |t|
      t.integer :event_id
      t.string :title
      t.boolean :must_join_all
      t.timestamps
    end
    
    add_column :userships, :fid, :string
    add_column :events, :maximum_attendees, :integer
    add_column :events, :keyword_required, :string
    add_column :events, :event_series_id, :integer

  end
end
