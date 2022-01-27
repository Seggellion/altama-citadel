class CreateEventTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :event_teams do |t|
      t.integer :event_id
      t.integer :team_id

      t.timestamps
    end
    add_index :event_teams, [:team_id, :event_id], unique: true, name: 'one_team_per_event'
  end
end
