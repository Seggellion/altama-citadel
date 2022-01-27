class CreateEventRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :event_records do |t|
      t.integer :event_type
      t.integer :event_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :duration
      t.integer :team_id
      t.integer :control_point_id
      t.integer :points
      t.integer :rank_placement

      t.timestamps
    end

    add_column :control_points, :capture_team_id, :integer
    add_column :teams, :team_color, :string
  end
end
