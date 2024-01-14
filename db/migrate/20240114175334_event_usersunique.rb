class EventUsersunique < ActiveRecord::Migration[7.0]
  def change
    add_index :event_users, [:user_id, :event_id], unique: true
    add_reference :userships, :ship, foreign_key: true
  end
end
