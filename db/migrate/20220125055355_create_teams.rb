class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :team_name
      t.integer :owner_id
      t.string :description
      t.integer :karma
      t.integer :fame
      t.string :website

      t.timestamps
    end
    create_table :control_points do |t|
      t.string :title
      t.string :description
      t.integer :event_id
      t.integer :location_id

      t.timestamps
    end
  end
end
