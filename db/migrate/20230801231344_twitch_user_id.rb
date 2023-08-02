class TwitchUserId < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :twitch_username, :string
    add_column :users, :twitch_id, :integer
  end
end
