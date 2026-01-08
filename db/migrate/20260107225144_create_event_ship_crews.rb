class CreateEventShipCrews < ActiveRecord::Migration[7.0]
  def change
create_table :event_ship_crews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event_ship, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
    
    # Ensures a user cannot join the same ship twice
    add_index :event_ship_crews, [:user_id, :event_ship_id], unique: true
  end
end
